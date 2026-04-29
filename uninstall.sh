#!/usr/bin/env bash
set -e

SKILLS_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_SKILLS="$HOME/.claude/skills"
CLAUDE_MD="$HOME/.claude/CLAUDE.md"
MARKER="# ISO27001AGENT"

SKILL_NAMES=(
  interview
  gap-assessment
  annex-review
  risk-assessment
  risk-treatment
  soa
  roadmap
  policy-gen
  internal-audit
  management-review
  audit-prep
  engagement-save
  engagement-restore
  isms-health
)

# ── Remove skill symlinks ─────────────────────────────────────────────────────
echo "Removing skill symlinks from $CLAUDE_SKILLS ..."
for skill in "${SKILL_NAMES[@]}"; do
  target_dir="$CLAUDE_SKILLS/$skill"
  if [ -L "$target_dir/SKILL.md" ]; then
    rm "$target_dir/SKILL.md"
    rmdir "$target_dir" 2>/dev/null || true
    echo "  removed: $skill"
  fi
done

# ── Remove CLAUDE.md routing block ───────────────────────────────────────────
if [ ! -f "$CLAUDE_MD" ]; then
  echo "Nothing to remove from $CLAUDE_MD — file does not exist."
else
  if ! grep -q "$MARKER" "$CLAUDE_MD"; then
    echo "ISO27001AGENT routing block not found in $CLAUDE_MD"
  else
    awk "
      /^# ISO27001AGENT/{found=1; next}
      found && /^# [A-Z]/{found=0}
      !found
    " "$CLAUDE_MD" > "$CLAUDE_MD.tmp" && mv "$CLAUDE_MD.tmp" "$CLAUDE_MD"
    sed -i '' -e 's/[[:space:]]*$//' "$CLAUDE_MD"
    echo "✓ Routing block removed from $CLAUDE_MD"
  fi
fi

echo ""
echo "✓ ISO27001AGENT uninstalled"
echo ""
echo "Your engagement documents in ./engagements/ are untouched."
echo "To reinstall, run ./setup.sh"
