#!/bin/sh
# lookin skill installer — auto-detect AI agents and install skill to the right path
# Usage: curl -fsSL https://raw.githubusercontent.com/a573412261/lookin-cli/main/skills/install.sh | sh

set -e

SKILL_NAME="lookin"
SKILL_URL="https://raw.githubusercontent.com/a573412261/lookin-cli/main/skills/lookin/SKILL.md"
TMPDIR=""
IS_LOCAL=false

cleanup() {
    if [ -n "$TMPDIR" ] && [ -d "$TMPDIR" ]; then
        rm -rf "$TMPDIR"
    fi
}
trap cleanup EXIT

# Resolve skill source: local file or download from GitHub
resolve_skill() {
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
    LOCAL_SKILL="$SCRIPT_DIR/lookin/SKILL.md"

    if [ -f "$LOCAL_SKILL" ]; then
        IS_LOCAL=true
        echo "$SCRIPT_DIR/lookin"
    else
        if ! command -v curl >/dev/null 2>&1; then
            echo "Error: curl is required but not installed." >&2
            exit 1
        fi
        TMPDIR="$(mktemp -d)"
        mkdir -p "$TMPDIR/$SKILL_NAME"
        curl -fsSL "$SKILL_URL" -o "$TMPDIR/$SKILL_NAME/SKILL.md"
        echo "$TMPDIR/$SKILL_NAME"
    fi
}

# Install skill directory to a target path.
# Local execution: symlink to real directory. Curl execution: copy content.
install_skill() {
    src="$1"
    dest="$2"

    mkdir -p "$(dirname "$dest")"
    rm -rf "$dest" 2>/dev/null || true

    if [ "$IS_LOCAL" = true ]; then
        ln -s "$src" "$dest" 2>/dev/null || cp -R "$src" "$dest"
    else
        cp -R "$src" "$dest"
    fi
}

# Generate .mdc file for Cursor
generate_cursor_mdc() {
    skill_dir="$1"
    dest="$2"
    skill_md="$skill_dir/SKILL.md"

    desc=""
    if [ -f "$skill_md" ]; then
        desc=$(sed -n 's/^description: *//p' "$skill_md" | head -1)
    fi
    [ -z "$desc" ] && desc="Lookin iOS UI inspection skill"

    body=$(sed '1{/^---$/d}; /^---$/,/^---$/d; 1{/^---$/d}' "$skill_md" 2>/dev/null || cat "$skill_md")

    mkdir -p "$(dirname "$dest")"
    cat > "$dest" <<MDC
---
description: $desc
globs:
alwaysApply: false
---

$body
MDC
}

# Generate .md rule file for Windsurf/Cline/Roo/Trae
generate_md_rule() {
    skill_dir="$1"
    dest="$2"
    skill_md="$skill_dir/SKILL.md"

    body=$(sed '1{/^---$/d}; /^---$/,/^---$/d; 1{/^---$/d}' "$skill_md" 2>/dev/null || cat "$skill_md")

    mkdir -p "$(dirname "$dest")"
    printf '%s\n' "$body" > "$dest"
}

# Detect and install
main() {
    # Check local availability before subshell
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
    if [ -f "$SCRIPT_DIR/lookin/SKILL.md" ]; then
        IS_LOCAL=true
    fi

    skill_dir=$(resolve_skill)
    installed=0

    printf "Installing lookin skill...\n\n"

    # --- Tier 1: Native SKILL.md support ---

    # Claude Code + VS Code Copilot
    if [ -d "$HOME/.claude" ]; then
        install_skill "$skill_dir" "$HOME/.claude/skills/$SKILL_NAME"
        printf "  Claude Code     -> ~/.claude/skills/%s\n" "$SKILL_NAME"
        installed=$((installed + 1))
    fi

    # Universal path (Codex CLI, Gemini CLI, Kiro, Antigravity)
    mkdir -p "$HOME/.agents/skills"
    install_skill "$skill_dir" "$HOME/.agents/skills/$SKILL_NAME"
    printf "  Universal       -> ~/.agents/skills/%s\n" "$SKILL_NAME"
    installed=$((installed + 1))

    # Gemini CLI
    if [ -d "$HOME/.gemini" ]; then
        install_skill "$skill_dir" "$HOME/.gemini/skills/$SKILL_NAME"
        printf "  Gemini CLI      -> ~/.gemini/skills/%s\n" "$SKILL_NAME"
        installed=$((installed + 1))
    fi

    # Goose
    if [ -d "$HOME/.config/goose" ]; then
        install_skill "$skill_dir" "$HOME/.config/goose/skills/$SKILL_NAME"
        printf "  Goose           -> ~/.config/goose/skills/%s\n" "$SKILL_NAME"
        installed=$((installed + 1))
    fi

    # OpenCode
    if [ -d "$HOME/.config/opencode" ]; then
        install_skill "$skill_dir" "$HOME/.config/opencode/skills/$SKILL_NAME"
        printf "  OpenCode        -> ~/.config/opencode/skills/%s\n" "$SKILL_NAME"
        installed=$((installed + 1))
    fi

    # --- Tier 2: Format conversion ---

    # Cursor (per-project, current directory)
    if [ -d ".cursor" ]; then
        generate_cursor_mdc "$skill_dir" ".cursor/rules/$SKILL_NAME.mdc"
        printf "  Cursor          -> .cursor/rules/%s.mdc\n" "$SKILL_NAME"
        installed=$((installed + 1))
    fi

    # Windsurf (per-project, current directory)
    if [ -d ".windsurf" ]; then
        generate_md_rule "$skill_dir" ".windsurf/rules/$SKILL_NAME.md"
        printf "  Windsurf        -> .windsurf/rules/%s.md\n" "$SKILL_NAME"
        installed=$((installed + 1))
    fi

    # Cline
    if [ -d ".clinerules" ]; then
        generate_md_rule "$skill_dir" ".clinerules/$SKILL_NAME.md"
        printf "  Cline           -> .clinerules/%s.md\n" "$SKILL_NAME"
        installed=$((installed + 1))
    fi

    # Roo Code
    if [ -d ".roo" ]; then
        generate_md_rule "$skill_dir" ".roo/rules/$SKILL_NAME.md"
        printf "  Roo Code        -> .roo/rules/%s.md\n" "$SKILL_NAME"
        installed=$((installed + 1))
    fi

    printf "\nDone! Installed to %d location(s).\n" "$installed"
}

main
