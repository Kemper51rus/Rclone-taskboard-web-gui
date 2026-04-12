#!/usr/bin/env bash
set -euo pipefail

REMOTE="${REMOTE:-origin}"
BRANCH="${BRANCH:-}"
COMMIT_MESSAGE=""
PUSH_ONLY=false

usage() {
  cat <<'USAGE'
Usage:
  ./git-push.sh -m "commit message"  # add all changes, commit and push
  ./git-push.sh --push-only          # push current branch without committing

Environment:
  REMOTE=origin
  BRANCH=<current branch by default>
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -m|--message)
      [[ $# -ge 2 ]] || { usage >&2; exit 2; }
      COMMIT_MESSAGE="$2"
      shift 2
      ;;
    --push-only)
      PUSH_ONLY=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown argument: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

if [[ -z "$BRANCH" ]]; then
  BRANCH="$(git branch --show-current)"
fi
[[ -n "$BRANCH" ]] || { printf 'Cannot determine current branch.\n' >&2; exit 1; }

if [[ "$PUSH_ONLY" == false ]]; then
  [[ -n "$COMMIT_MESSAGE" ]] || {
    printf 'Commit message is required unless --push-only is used.\n' >&2
    usage >&2
    exit 2
  }
  git add -A
  if git diff --cached --quiet; then
    printf 'No staged changes to commit.\n'
  else
    git commit -m "$COMMIT_MESSAGE"
  fi
fi

printf 'Pushing %s %s -> %s/%s\n' "$REMOTE" "$BRANCH" "$REMOTE" "$BRANCH"
git push "$REMOTE" "$BRANCH"
git status --short
