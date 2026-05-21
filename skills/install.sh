#!/bin/sh
# lookin skill installer — install skill into current project's AI agent directories
# Usage: cd /your/project && curl -fsSL https://raw.githubusercontent.com/a573412261/lookin-cli/main/skills/install.sh | sh

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

# Copy skill directory to target path
install_skill() {
    src="$1"
    dest="$2"

    mkdir -p "$(dirname "$dest")"
    rm -rf "$dest" 2>/dev/null || true
    cp -R "$src" "$dest"
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

# Detect and install into current project directory
main() {
    # Check local availability before subshell
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
    if [ -f "$SCRIPT_DIR/lookin/SKILL.md" ]; then
        IS_LOCAL=true
    fi

    skill_dir=$(resolve_skill)
    installed=0

    printf "Installing lookin skill into current project...\n\n"

    # --- Tier 1: Native SKILL.md support (project-local) ---

    # Claude Code + VS Code Copilot
    mkdir -p ".claude/skills"
    install_skill "$skill_dir" ".claude/skills/$SKILL_NAME"
    printf "  Claude Code     -> .claude/skills/%s\n" "$SKILL_NAME"
    installed=$((installed + 1))

    # GitHub Copilot
    mkdir -p ".github/skills"
    install_skill "$skill_dir" ".github/skills/$SKILL_NAME"
    printf "  Copilot         -> .github/skills/%s\n" "$SKILL_NAME"
    installed=$((installed + 1))

    # Universal (Codex CLI, Gemini CLI, Kiro, Antigravity)
    mkdir -p ".agents/skills"
    install_skill "$skill_dir" ".agents/skills/$SKILL_NAME"
    printf "  Universal       -> .agents/skills/%s\n" "$SKILL_NAME"
    installed=$((installed + 1))

    # Gemini CLI
    mkdir -p ".gemini/skills"
    install_skill "$skill_dir" ".gemini/skills/$SKILL_NAME"
    printf "  Gemini CLI      -> .gemini/skills/%s\n" "$SKILL_NAME"
    installed=$((installed + 1))

    # Kiro
    mkdir -p ".kiro/skills"
    install_skill "$skill_dir" ".kiro/skills/$SKILL_NAME"
    printf "  Kiro            -> .kiro/skills/%s\n" "$SKILL_NAME"
    installed=$((installed + 1))

    # Goose
    mkdir -p ".config/goose/skills"
    install_skill "$skill_dir" ".config/goose/skills/$SKILL_NAME"
    printf "  Goose           -> .config/goose/skills/%s\n" "$SKILL_NAME"
    installed=$((installed + 1))

    # OpenCode
    mkdir -p ".config/opencode/skills"
    install_skill "$skill_dir" ".config/opencode/skills/$SKILL_NAME"
    printf "  OpenCode        -> .config/opencode/skills/%s\n" "$SKILL_NAME"
    installed=$((installed + 1))

    # --- Tier 2: Format conversion ---

    # Cursor
    mkdir -p ".cursor/rules"
    generate_cursor_mdc "$skill_dir" ".cursor/rules/$SKILL_NAME.mdc"
    printf "  Cursor          -> .cursor/rules/%s.mdc\n" "$SKILL_NAME"
    installed=$((installed + 1))

    # Windsurf
    mkdir -p ".windsurf/rules"
    generate_md_rule "$skill_dir" ".windsurf/rules/$SKILL_NAME.md"
    printf "  Windsurf        -> .windsurf/rules/%s.md\n" "$SKILL_NAME"
    installed=$((installed + 1))

    # Cline
    mkdir -p ".clinerules"
    generate_md_rule "$skill_dir" ".clinerules/$SKILL_NAME.md"
    printf "  Cline           -> .clinerules/%s.md\n" "$SKILL_NAME"
    installed=$((installed + 1))

    # Roo Code
    mkdir -p ".roo/rules"
    generate_md_rule "$skill_dir" ".roo/rules/$SKILL_NAME.md"
    printf "  Roo Code        -> .roo/rules/%s.md\n" "$SKILL_NAME"
    installed=$((installed + 1))

    # Trae
    mkdir -p ".trae/rules"
    generate_md_rule "$skill_dir" ".trae/rules/$SKILL_NAME.md"
    printf "  Trae            -> .trae/rules/%s.md\n" "$SKILL_NAME"
    installed=$((installed + 1))

    printf "\nDone! Installed to %d location(s) in current project.\n" "$installed"
}

main
