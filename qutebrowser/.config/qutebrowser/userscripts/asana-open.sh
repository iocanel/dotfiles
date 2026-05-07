#!/usr/bin/env bash
set -euo pipefail

: "${QUTE_URL:?Must be run as a qutebrowser userscript}"
URL="$QUTE_URL"

ASANA_BASE="https://app.asana.com/0/search?q="
OPEN_CMD=(qutebrowser --target window)

die() { echo "ERROR: $*" >&2; exit 1; }

is_github_pr() { [[ "$1" =~ /pull/[0-9]+ ]]; }
is_gitlab_mr() { [[ "$1" =~ /merge_requests/[0-9]+ ]]; }
is_github_commit() { [[ "$1" =~ github\.[^/]+/[^/]+/[^/]+/commit/[0-9a-f]+ ]]; }
is_gitlab_commit() { [[ "$1" =~ /-/commit/[0-9a-f]+ ]]; }

extract_github_pr() { [[ "$1" =~ /pull/([0-9]+) ]] && echo "${BASH_REMATCH[1]}"; }
extract_gitlab_mr() { [[ "$1" =~ /merge_requests/([0-9]+) ]] && echo "${BASH_REMATCH[1]}"; }
extract_commit_sha() { [[ "$1" =~ /commit/([0-9a-f]+) ]] && echo "${BASH_REMATCH[1]}"; }

# GitHub: https://host/org/repo/pull/123 -> org/repo
extract_github_repo() {
  echo "$1" | sed -E 's#https?://[^/]+/([^/]+/[^/]+).*#\1#'
}

# GitLab: https://host/group/subgroup/repo/-/merge_requests/114 -> https://host/group/subgroup/repo
extract_gitlab_project_url() {
  echo "$1" | sed -E 's#(https?://[^/]+/.+)/-/(merge_requests|commit)/[^/]+.*#\1#'
}

get_title() {
  if is_github_pr "$URL"; then
    local pr repo
    pr="$(extract_github_pr "$URL")"
    repo="$(extract_github_repo "$URL")"
    [[ -n "${pr:-}" && -n "${repo:-}" ]] || die "Could not extract GitHub repo/pr from URL"

    gh pr view "$pr" -R "$repo" --json title -q .title

  elif is_gitlab_mr "$URL"; then
    local mr project_url
    mr="$(extract_gitlab_mr "$URL")"
    project_url="$(extract_gitlab_project_url "$URL")"
    [[ -n "${mr:-}" && -n "${project_url:-}" ]] || die "Could not extract GitLab project/mr from URL"

    glab mr view "$mr" -R "$project_url" \
      | sed -n 's/^title:[[:space:]]*//Ip' \
      | head -n1

  elif is_github_commit "$URL"; then
    local sha repo
    sha="$(extract_commit_sha "$URL")"
    repo="$(extract_github_repo "$URL")"
    [[ -n "${sha:-}" && -n "${repo:-}" ]] || die "Could not extract GitHub repo/commit from URL"

    gh api "repos/$repo/commits/$sha" --jq '.commit.message' | head -n1

  elif is_gitlab_commit "$URL"; then
    local sha project_url
    sha="$(extract_commit_sha "$URL")"
    project_url="$(extract_gitlab_project_url "$URL")"
    [[ -n "${sha:-}" && -n "${project_url:-}" ]] || die "Could not extract GitLab project/commit from URL"

    glab api "projects/$(python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1].split('://')[1].lstrip('/'), safe=''))" "$project_url")/repository/commits/$sha" \
      | jq -r '.title'

  else
    die "Unsupported URL (not a PR/MR/commit): $URL"
  fi
}

get_branch() {
  if is_github_pr "$URL"; then
    local pr repo
    pr="$(extract_github_pr "$URL")"
    repo="$(extract_github_repo "$URL")"
    [[ -n "${pr:-}" && -n "${repo:-}" ]] || return 1

    gh pr view "$pr" -R "$repo" --json headRefName -q .headRefName

  elif is_gitlab_mr "$URL"; then
    local mr project_url
    mr="$(extract_gitlab_mr "$URL")"
    project_url="$(extract_gitlab_project_url "$URL")"
    [[ -n "${mr:-}" && -n "${project_url:-}" ]] || return 1

    glab mr view "$mr" -R "$project_url" --output json \
      | jq -r '.source_branch // empty'
  else
    return 1
  fi
}

title="$(get_title)"
[[ -n "${title:-}" ]] || die "Empty title returned"

# Extract all CR references from text
# Match: CR-1234, #CR-1234, CR 1234, #CR 1234, cr-1234, cr 1234, cr_1234, cr1234
extract_cr_refs() {
  local text="$1"
  echo "$text" | grep -oEi '(#[[:space:]]*)?cr[[:space:]_-]*[0-9]+' \
    | grep -oE '[0-9]+' \
    | sort -u \
    | while read -r num; do echo "CR-$num"; done
}

mapfile -t cr_refs < <(extract_cr_refs "$title")

if [[ ${#cr_refs[@]} -eq 0 ]]; then
  echo "No CR reference in title, checking branch name..."
  branch="$(get_branch)" || branch=""
  if [[ -n "${branch:-}" ]]; then
    echo "Branch: $branch"
    mapfile -t cr_refs < <(extract_cr_refs "$branch")
  fi
fi

if [[ ${#cr_refs[@]} -eq 0 ]]; then
  die "No CR reference found in title or branch (expected CR-####, cr_####, cr####): $title"
fi

echo "Title: $title"
echo "Found: ${cr_refs[*]}"

for cr in "${cr_refs[@]}"; do
  asana_url="${ASANA_BASE}${cr}"
  echo "Opening: $asana_url"
  "${OPEN_CMD[@]}" "$asana_url" >/dev/null 2>&1 || true
done
