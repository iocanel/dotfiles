#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
whisper-api — transcribe via OpenAI API with smart prepare+split
  • Prepares input to MP3 (mono, 16 kHz, 64 kbps) to shrink below 25 MB when possible.
  • Falls back to splitting the prepared MP3 if still >25 MB.
  • Automatically selects whisper-1 if timestamps are requested.
  • Full timestamps (verbose_json / srt / vtt) require: -m whisper-1

USAGE:
  whisper-api [options] <input-media>

OPTIONS:
  -m, --model NAME          Model (default: gpt-4o-transcribe; whisper-1 supports timestamps)
  -f, --format FMT          text|json|srt|vtt|verbose_json (default: text)
  -l, --language LANG       Language hint (e.g., en, el). Optional.
  -p, --prompt TEXT         Initial prompt. Optional.
  -t, --temperature VAL     Decoding temperature (e.g., 0 or 0.2). Optional.
  -H, --header KEY=VALUE    Extra header (repeatable).
  --chunk-mb N              Target chunk size in MB for splitting (default: 20)
  --no-split                Do not split; fail if file > API limit.
  --no-prepare              Skip MP3 preparation step (upload original or split original).
  -o, --output PATH         Write output to PATH.
  --stdout                  Force write to stdout even if attached to a TTY.
  --verbose                 Print debug logs to stderr.
  -h, --help                Show help.

ENV:
  OPENAI_API_KEY            Your API key (required).
EOF
}

# --- Defaults (recommendations applied) ---
MODEL=""  # ← now empty by default; we'll auto-select later
FORMAT="text"
LANGUAGE=""
PROMPT=""
TEMP=""
CHUNK_MB=20
NO_SPLIT=0
NO_PREPARE=0                   # prepare to MP3 mono 16kHz 64kbps by default
VERBOSE=0
FORCE_STDOUT=0
OUT_PATH=""
declare -a EXTRA_HEADERS=()

# --- Parse args ---
INPUT_FILE=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    -m|--model) MODEL="$2"; shift 2;;
    -f|--format) FORMAT="$2"; shift 2;;
    -l|--language) LANGUAGE="$2"; shift 2;;
    -p|--prompt) PROMPT="$2"; shift 2;;
    -t|--temperature) TEMP="$2"; shift 2;;
    -H|--header) EXTRA_HEADERS+=("$2"); shift 2;;
    --chunk-mb) CHUNK_MB="$2"; shift 2;;
    --no-split) NO_SPLIT=1; shift 1;;
    --no-prepare) NO_PREPARE=1; shift 1;;
    -o|--output) OUT_PATH="$2"; shift 2;;
    --stdout) FORCE_STDOUT=1; shift 1;;
    --verbose) VERBOSE=1; shift 1;;
    -h|--help) usage; exit 0;;
    -*) echo "Unknown option: $1" >&2; usage; exit 2;;
    *) INPUT_FILE="$1"; shift;;
  esac
done

# --- Helpers ---
supports_verbose() { [[ "$MODEL" == "whisper-1" ]]; }
wants_timestamps() { case "$FORMAT" in verbose_json|srt|vtt) return 0;; *) return 1;; esac; }
logv() {
  if (( VERBOSE )); then
    echo "[whisper-api] $*" >&2
  fi
  return 0
}

emit() {
  local data="$1" fmt="$2" dest="$OUT_PATH"
  if (( FORCE_STDOUT )); then printf "%s\n" "$data"; return; fi
  if [[ -n "$dest" ]]; then printf "%s\n" "$data" > "$dest"; logv "wrote output to $dest"; return; fi
  if [[ ! -t 1 ]]; then printf "%s\n" "$data"; return; fi
  local dir base ext name
  dir="$(dirname -- "$INPUT_FILE")"; name="$(basename -- "$INPUT_FILE")"; base="${name%.*}"
  case "$fmt" in
    text)         ext="txt" ;;
    json)         ext="json" ;;
    verbose_json) ext="verbose.json" ;;
    srt)          ext="srt" ;;
    vtt)          ext="vtt" ;;
    *)            ext="out" ;;
  esac
  dest="$dir/$base.$ext"
  printf "%s\n" "$data" > "$dest"
  echo "Saved transcript to: $dest" >&2
}

# --- Preconditions ---
if [[ -z "${OPENAI_API_KEY:-}" ]]; then echo "OPENAI_API_KEY is required" >&2; exit 2; fi
if [[ -z "$INPUT_FILE" ]]; then echo "Error: input media file is required." >&2; usage; exit 2; fi
if [[ ! -f "$INPUT_FILE" ]]; then echo "Error: file not found: $INPUT_FILE" >&2; exit 2; fi

# --- Auto-model selection ---
if [[ -z "$MODEL" ]]; then
  if wants_timestamps; then
    MODEL="whisper-1"
    logv "auto-selected model=whisper-1 (timestamps requested by format $FORMAT)"
  else
    MODEL="gpt-4o-transcribe"
    logv "auto-selected model=gpt-4o-transcribe (default)"
  fi
fi

# --- Constants ---
API_URL="https://api.openai.com/v1/audio/transcriptions"
BYTES_PER_MB=$((1024*1024))
API_LIMIT_MB=25

file_size_bytes() { stat --printf="%s" "$1" 2>/dev/null || wc -c < "$1"; }
media_duration() { ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$1" 2>/dev/null | awk '{printf "%.6f", $1+0}'; }

# --- Send one request ---
send_one() {
  local file="$1" format="$2"
  if [[ "$format" == "verbose_json" && "$MODEL" != "whisper-1" ]]; then
    logv "downgrading response_format verbose_json -> json for model $MODEL"
    format="json"
  fi
  local -a form=( -F "file=@$file" -F "model=$MODEL" -F "response_format=$format" )
  [[ -n "$LANGUAGE" ]] && form+=( -F "language=$LANGUAGE" )
  [[ -n "$PROMPT" ]]   && form+=( -F "prompt=$PROMPT" )
  [[ -n "$TEMP" ]]     && form+=( -F "temperature=$TEMP" )
  local -a hdrs=( -H "Authorization: Bearer $OPENAI_API_KEY" )
  for kv in "${EXTRA_HEADERS[@]}"; do hdrs+=( -H "$kv" ); done
  local tmp_resp tmp_code; tmp_resp=$(mktemp); tmp_code=$(mktemp)
  curl -sS -X POST "$API_URL" -H "Content-Type: multipart/form-data" \
    "${hdrs[@]}" "${form[@]}" -w "%{http_code}" -o "$tmp_resp" >"$tmp_code" || true
  local code body; code=$(cat "$tmp_code"); body=$(cat "$tmp_resp"); rm -f "$tmp_code" "$tmp_resp"
  if echo "$body" | jq -e '.error? // empty' >/dev/null 2>&1; then echo "OpenAI API error:" >&2; echo "$body" | jq -r '.error.message // .error' >&2; exit 1; fi
  if [[ "$code" != "200" ]]; then echo "HTTP error $code from API" >&2; echo "Body: $body" >&2; exit 1; fi
  printf "%s" "$body"
}

# --- Working directory & preparation (MP3 mono, 16 kHz, 64 kbps) ---
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

WORK_FILE="$INPUT_FILE"
if (( NO_PREPARE == 0 )); then
  PREPARED="$TMPDIR/prepared.mp3"
  logv "preparing MP3 (mono, 16kHz, 64kbps) -> $PREPARED"
  ffmpeg -hide_banner -loglevel error -y \
    -i "$INPUT_FILE" -ac 1 -ar 16000 -b:a 64k -vn "$PREPARED"
  WORK_FILE="$PREPARED"
fi

WORK_BYTES=$(file_size_bytes "$WORK_FILE")
WORK_MB=$(( (WORK_BYTES + BYTES_PER_MB - 1) / BYTES_PER_MB ))
logv "work file size: ${WORK_MB} MB (bytes=$WORK_BYTES)"

# --- If small enough (or --no-split), single request ---
if (( NO_SPLIT == 1 || WORK_MB <= API_LIMIT_MB )); then
  REQ_FMT="$FORMAT"
  if wants_timestamps && supports_verbose; then REQ_FMT="verbose_json"; fi
  if [[ "$REQ_FMT" == "verbose_json" && "$MODEL" != "whisper-1" ]]; then REQ_FMT="json"; fi
  logv "single-call: model=$MODEL user_format=$FORMAT request_format=$REQ_FMT"
  OUT=$(send_one "$WORK_FILE" "$REQ_FMT")
  case "$FORMAT" in
    json|verbose_json) emit "$(echo "$OUT" | jq .)" "$FORMAT" ;;
    *)                 emit "$OUT" "$FORMAT" ;;
  esac
  exit 0
fi

# --- Split path (segment the prepared MP3 without re-encoding) ---
TARGET_BYTES=$((CHUNK_MB * BYTES_PER_MB))
BYTES_PER_SEC=8000                        # 64 kbps MP3 ≈ 8k bytes/sec
SEGMENT_TIME=$(( TARGET_BYTES / BYTES_PER_SEC ))
(( SEGMENT_TIME < 30 )) && SEGMENT_TIME=30

logv "splitting: segment_time=${SEGMENT_TIME}s (~${CHUNK_MB}MB per chunk)"
ffmpeg -hide_banner -loglevel error -y \
  -i "$WORK_FILE" -c copy \
  -f segment -segment_time "$SEGMENT_TIME" -reset_timestamps 1 \
  "$TMPDIR/segment-%03d.mp3"

shopt -s nullglob
segments=( "$TMPDIR"/segment-*.mp3 )
(( ${#segments[@]} == 0 )) && { echo "Failed to create segments." >&2; exit 1; }

REQUEST_FORMAT="json"
if wants_timestamps && supports_verbose; then REQUEST_FORMAT="verbose_json"; fi
if [[ "$REQUEST_FORMAT" == "verbose_json" && "$MODEL" != "whisper-1" ]]; then REQUEST_FORMAT="json"; fi
logv "split-call: model=$MODEL user_format=$FORMAT request_format=$REQUEST_FORMAT"

MERGE_TARGET="$FORMAT"
declare -a RESP_FILES=()

offset="0.000000"
for seg in "${segments[@]}"; do
  chunk_dur=$(media_duration "$seg")
  logv "chunk $(basename "$seg") dur=${chunk_dur}s offset_start=${offset}s"
  raw=$(send_one "$seg" "$REQUEST_FORMAT")

  if supports_verbose && [[ "$REQUEST_FORMAT" == "verbose_json" ]]; then
    adj=$(printf "%s" "$raw" | jq --argjson off "$offset" --argjson dur "$chunk_dur" '
      if (.segments // null) then
        .segments = (map(.start += $off | .end += $off))
      else
        .segments = [ {id: 0, start: $off, end: ($off + $dur), text: (.text // "") } ]
      end')
  else
    adj=$(jq -n --arg text "$(printf "%s" "$raw" | jq -r '.text // ""')" \
             --argjson off "$offset" --argjson dur "$chunk_dur" '
          { text: $text,
            segments: [ { id: 0, start: $off, end: ($off + $dur), text: $text } ] }')
  fi

  resp_path="$TMPDIR/resp-$RANDOM.json"
  printf "%s" "$adj" > "$resp_path"
  RESP_FILES+=( "$resp_path" )

  offset=$(awk -v a="$offset" -v b="$chunk_dur" 'BEGIN{printf "%.6f", a + b}')
  sleep 0.2
done

# --- Merge & emit ---
merged_text=$(jq -rs 'map(.text // "") | join("\n\n")' "${RESP_FILES[@]}")
merged_segments_json=$(jq -s '[ .[] | (.segments // [])[] ]' "${RESP_FILES[@]}")

merged_verbose_path="$TMPDIR/merged.json"
jq -n --argjson segs "$merged_segments_json" --arg text "$merged_text" \
  '{ text: $text, segments: $segs }' > "$merged_verbose_path"

case "$MERGE_TARGET" in
  verbose_json) emit "$(jq . "$merged_verbose_path")" "verbose_json" ;;
  json)         emit "$(jq -n --arg text "$(jq -r '.text' "$merged_verbose_path")" '{text:$text}')" "json" ;;
  text)         emit "$(jq -r '.text' "$merged_verbose_path")" "text" ;;
  srt)
    emit "$(
      jq -r '.segments[] | [.start, .end, .text] | @tsv' "$merged_verbose_path" \
      | gawk -F'\t' '
        function f(s,h,m,sec,ms){h=int(s/3600);m=int((s-h*3600)/60);sec=s-h*3600-m*60;ms=int((sec-int(sec))*1000);
          return sprintf("%02d:%02d:%02d,%03d",h,m,int(sec),ms)}
        BEGIN{i=0}
        {i++;printf("%d\n%s --> %s\n%s\n\n",i,f($1),f($2),$3)}'
    )" "srt"
    ;;
  vtt)
    emit "$(
      { echo "WEBVTT"; echo; }
      jq -r '.segments[] | [.start, .end, .text] | @tsv' "$merged_verbose_path" \
      | gawk -F'\t' '
        function f(s,h,m,sec,ms){h=int(s/3600);m=int((s-h*3600)/60);sec=s-h*3600-m*60;ms=int((sec-int(sec))*1000);
          return sprintf("%02d:%02d:%02d.%03d",h,m,int(sec),ms)}
        {printf("%s --> %s\n%s\n\n",f($1),f($2),$3)}'
    )" "vtt"
    ;;
  *) echo "Unknown format: $MERGE_TARGET" >&2; exit 2;;
esac
