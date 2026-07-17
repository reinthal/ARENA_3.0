#!/bin/bash
set -e

# =============================================================================
# First clone the ARENA_3.0 repo using:
#   git clone -b alignment-science https://github.com/callummcdougall/ARENA_3.0.git
# Then, usage:
#   bash ARENA_3.0/install.sh                        # RunPod (default), with llm-context repo
#   bash ARENA_3.0/install.sh --platform vastai      # Vast.ai platform
#   bash ARENA_3.0/install.sh --no-llm-context       # Skip cloning arena-llm-context
# =============================================================================

# Defaults
PLATFORM="runpod"
CLONE_LLM_CONTEXT=true
PRIMARY_REPO_DIR="ARENA_3.0"

# Parse args
while [[ $# -gt 0 ]]; do
    case $1 in
        --platform)
            PLATFORM="$2"
            shift 2
            ;;
        --no-llm-context) CLONE_LLM_CONTEXT=false; shift ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

echo "=== Setup: platform=$PLATFORM, clone_llm_context=$CLONE_LLM_CONTEXT ==="

# --- Install system packages (git, curl) ---
echo "=== Installing system packages ==="
if [[ "$PLATFORM" == "runpod" ]]; then
    apt update && apt install -y git curl
elif [[ "$PLATFORM" == "vastai" ]]; then
    sudo apt update && sudo apt install -y git curl
fi

# --- Install uv ---
if ! command -v uv &> /dev/null; then
    echo "=== Installing uv ==="
    curl -LsSf https://astral.sh/uv/install.sh | sh
    # Make uv available in the current shell
    export PATH="$HOME/.local/bin:$PATH"
    [ -f "$HOME/.local/bin/env" ] && source "$HOME/.local/bin/env"
fi
echo "=== uv: $(uv --version) ==="

# Maybe clone the repo which gives you extra context for LLMs (to help with exercises)
if $CLONE_LLM_CONTEXT; then
    REPO="callummcdougall/arena-llm-context"
    BRANCH="main"
    echo "=== Cloning $REPO (branch: $BRANCH) ==="
    git clone -b "$BRANCH" "https://github.com/${REPO}.git"
fi

# # --- Git config ---
# git config --global user.name callummcdougall
# git config --global user.email cal.s.mcdougall@gmail.com

# --- Install Python + deps from primary repo (creates .venv) ---
echo "=== Installing Python dependencies from $PRIMARY_REPO_DIR ==="
cd "$PRIMARY_REPO_DIR"
# uv reads .python-version + pyproject.toml, downloads the interpreter if needed,
# resolves from uv.lock, and builds .venv
uv sync

# --- VS Code workspace settings ---
bash setup_vscode.sh
cd ..

echo "=== Done! Activate with: source $PRIMARY_REPO_DIR/.venv/bin/activate ==="
