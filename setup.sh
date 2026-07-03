#!/usr/bin/env bash
set -euo pipefail

# Directory where you call ./setup.sh from
TARGET_DIR="$(pwd)"

# Directory where this script is physically located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Setup target directory: ${TARGET_DIR}"
echo ""

clone_or_update() {
  local url="$1"
  local dest="$2"
  local branch="${3:-}"

  if [ -d "${dest}/.git" ]; then
    echo "Repo already exists: ${dest}"
    cd "${dest}"

    echo "Fetching latest changes..."
    git fetch --all --prune

    current_branch="$(git rev-parse --abbrev-ref HEAD)"

    if [ -n "${branch}" ]; then
      echo "Switching to branch: ${branch}"
      git switch "${branch}" 2>/dev/null || git switch -c "${branch}" "origin/${branch}"
    else
      echo "Keeping current branch: ${current_branch}"
    fi

    echo "Pulling latest changes..."
    git pull --ff-only || {
      echo ""
      echo "Could not fast-forward ${dest}."
      echo "This usually means you have local commits or divergent history."
      echo "Please check manually with:"
      echo "  cd ${dest}"
      echo "  git status"
      echo "  git log --oneline --graph --decorate --all -10"
      exit 1
    }

    cd "${TARGET_DIR}"
  else
    echo "Cloning ${url} into ${dest}"

    if [ -n "${branch}" ]; then
      git clone --branch "${branch}" "${url}" "${dest}"
    else
      git clone "${url}" "${dest}"
    fi
  fi

  echo ""
}

echo "=== Cloning/updating home repositories ==="
clone_or_update "git@github.com:Ultimate-TEMI/temi_addimgloc.git" "${HOME}/temi_addimgloc"
clone_or_update "git@github.com:Ultimate-TEMI/Temi_DBInfo.git" "${HOME}/Temi_DBInfo" "LanguageUpdate"

echo "=== Importing repositories from temi.repos ==="

if ! command -v vcs >/dev/null 2>&1; then
  echo "ERROR: vcs is not installed."
  echo "Install it with:"
  echo "  sudo apt update"
  echo "  sudo apt install python3-vcstool"
  exit 1
fi

# Prefer temi.repos from the directory where ./setup.sh was called.
# If not found there, use temi.repos next to this script.
if [ -f "${TARGET_DIR}/temi.repos" ]; then
  REPOS_FILE="${TARGET_DIR}/temi.repos"
elif [ -f "${SCRIPT_DIR}/temi.repos" ]; then
  REPOS_FILE="${SCRIPT_DIR}/temi.repos"
else
  echo "ERROR: Could not find temi.repos."
  echo "Expected either:"
  echo "  ${TARGET_DIR}/temi.repos"
  echo "or:"
  echo "  ${SCRIPT_DIR}/temi.repos"
  exit 1
fi

echo "Using repos file: ${REPOS_FILE}"
echo "Importing into: ${TARGET_DIR}"

cd "${TARGET_DIR}"
vcs import < "${REPOS_FILE}"

echo ""
echo "=== Done ==="
echo "Home repos:"
echo "  ${HOME}/temi_addimgloc"
echo "  ${HOME}/Temi_DBInfo"
echo ""
echo "Repos from temi.repos imported into:"
echo "  ${TARGET_DIR}"
