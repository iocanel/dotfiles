#!/usr/bin/env bash
set -euo pipefail

: "${QUTE_URL:?Must be run as a qutebrowser userscript}"
URL="$QUTE_URL"

ASANA_BASE="https://app.asana.com/0/search?q="
OPEN_CMD=(qutebrowser --target window)

die() { echo "ERROR: $*" >&2; exit 1; }

is_github() { [[ "$1" =~ /pull/[0-9]+ ]]; }
is_gitlab() { [[ "$1" =~ /merge_requests/[0-9]+ ]]; }

extract_github_pr() { [[ "$1" =~ /pull/([0-9]+) ]] && echo "${BASH_REMATCH[1]}"; }
extract_gitlab_mr() { [[ "$1" =~ /merge_requests/([0-9]+) ]] && echo "${BASH_REMATCH[1]}"; }

# GitHub: https://host/org/repo/pull/123 -> org/repo
extract_github_repo() {
  echo "$1" | sed -E 's#https?://[^/]+/([^/]+/[^/]+).*#\1#'
}

# GitLab: https://host/group/subgroup/repo/-/merge_requests/114 -> https://host/group/subgroup/repo
extract_gitlab_project_url() {
  echo "$1" | sed -E 's#(https?://[^/]+/.+)/-/merge_requests/[0-9]+.*#\1#'
}

get_title() {
  if is_github "$URL"; then
    local pr repo
    pr="$(extract_github_pr "$URL")"
    repo="$(extract_github_repo "$URL")"
    [[ -n "${pr:-}" && -n "${repo:-}" ]] || die "Could not extract GitHub repo/pr from URL"

    gh pr view "$pr" -R "$repo" --json title -q .title

  elif is_gitlab "$URL"; then
    local mr project_url
    mr="$(extract_gitlab_mr "$URL")"
    project_url="$(extract_gitlab_project_url "$URL")"
    [[ -n "${mr:-}" && -n "${project_url:-}" ]] || die "Could not extract GitLab project/mr from URL"

    # Debug: log token and command
    echo "DEBUG: GITLAB_TOKEN='${GITLAB_TOKEN:-unset}'" >&2
    echo "DEBUG: GITLAB_TOKEN length=${#GITLAB_TOKEN}" >&2
    echo "DEBUG: GITLAB_TOKEN hex=$(printf '%s' "$GITLAB_TOKEN" | od -An -tx1)" >&2
    echo "DEBUG: Command: glab mr view $mr -R $project_url" >&2

    # Works outside a git repo; no --json required
    glab mr view "$mr" -R "$project_url" \
      | sed -n 's/^title:[[:space:]]*//Ip' \
      | head -n1
  else
    die "Unsupported URL (not a PR/MR?): $URL"
  fi
}

title="$(get_title)"
[[ -n "${title:-}" ]] || die "Empty title returned"

# Extract all CR references from title
# Match: CR-1234, #CR-1234, CR 1234, #CR 1234, cr-1234, cr 1234
extract_cr_refs() {
  local text="$1"
  echo "$text" | grep -oEi '(#[[:space:]]*)?cr[[:space:]-]*[0-9]+' \
    | grep -oE '[0-9]+' \
    | sort -u \
    | while read -r num; do echo "CR-$num"; done
}

mapfile -t cr_refs < <(extract_cr_refs "$title")

if [[ ${#cr_refs[@]} -eq 0 ]]; then
  die "No CR reference found (expected CR-#### or 'cr ####'): $title"
fi

echo "Title: $title"
echo "Found: ${cr_refs[*]}"

for cr in "${cr_refs[@]}"; do
  asana_url="${ASANA_BASE}${cr}"
  echo "Opening: $asana_url"
  "$OPEN_CMD" "$asana_url" >/dev/null 2>&1 || true
done
