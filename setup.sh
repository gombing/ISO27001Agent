#!/usr/bin/env bash
# ISO27001AGENT setup — symlink skills into ~/.claude/skills/ and register routing
set -e

SKILLS_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_SKILLS="$HOME/.claude/skills"
CLAUDE_MD="$HOME/.claude/CLAUDE.md"
MARKER="# ISO27001AGENT"

# ── Already installed check ──────────────────────────────────────────────────
if [ -f "$CLAUDE_MD" ] && grep -q "$MARKER" "$CLAUDE_MD"; then
  echo "ISO27001AGENT is already installed."
  echo "Skills:   $CLAUDE_SKILLS"
  echo "Routing:  $CLAUDE_MD"
  echo ""
  echo "To reinstall, run ./uninstall.sh first."
  exit 0
fi

# ── Create skill directories ─────────────────────────────────────────────────
mkdir -p "$CLAUDE_SKILLS"

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

echo "Linking skills into $CLAUDE_SKILLS ..."
for skill in "${SKILL_NAMES[@]}"; do
  source_skill="$SKILLS_DIR/$skill/SKILL.md"
  target_dir="$CLAUDE_SKILLS/$skill"
  if [ ! -f "$source_skill" ]; then
    echo "  warning: $source_skill not found — skipping"
    continue
  fi
  mkdir -p "$target_dir"
  # Remove stale symlink if it exists
  [ -L "$target_dir/SKILL.md" ] && rm "$target_dir/SKILL.md"
  ln -sf "$source_skill" "$target_dir/SKILL.md"
  echo "  linked: $skill"
done

# ── Register routing in ~/.claude/CLAUDE.md ──────────────────────────────────
mkdir -p "$HOME/.claude"

cat >> "$CLAUDE_MD" <<EOF

# ISO27001AGENT

ISO 27001:2022 consulting toolkit. Skills installed at: $SKILLS_DIR

When the user's request matches an ISO 27001 consulting task, invoke the skill
via the Skill tool. Always invoke the skill — do not answer ad-hoc.

**Run \`/interview\` before any other skill.** Engagement documents are written
to \`./engagements/\` in the current working directory.

## Skill Routing

- New client, first meeting, "start the engagement" → \`/interview\`
- "Client intake", "onboarding a client", "new engagement" → \`/interview\`
- "Gap assessment", "clause review", "how compliant are they" → \`/gap-assessment\`
- "Annex A", "control review", "check the 93 controls" → \`/annex-review\`
- "Risk assessment", "risk register", Clause 6.1.2 → \`/risk-assessment\`
- "Risk treatment", "treat the risks", Clause 6.1.3 → \`/risk-treatment\`
- "Statement of Applicability", "SoA" → \`/soa\`
- "Implementation plan", "roadmap", "what do we fix first" → \`/roadmap\`
- "Write a policy", "generate policy" → \`/policy-gen\`
- "Internal audit", "audit programme" → \`/internal-audit\`
- "Management review", "MR agenda", "review minutes" → \`/management-review\`
- "Are they ready for the audit", "Stage 1 readiness" → \`/audit-prep\`
- "Save session", "save engagement", "checkpoint" → \`/engagement-save\`
- "Restore session", "resume engagement", "where did we leave off" → \`/engagement-restore\`
- "ISMS health", "health check", "health dashboard", "status check" → \`/isms-health\`
EOF

# ── Done ─────────────────────────────────────────────────────────────────────
echo ""
echo "✓ ISO27001AGENT v$(cat "$SKILLS_DIR/VERSION" 2>/dev/null || echo "1.0.0") installed"
echo ""
echo "Skills linked: ${#SKILL_NAMES[@]} → $CLAUDE_SKILLS"
echo "Routing:        $CLAUDE_MD"
echo ""
echo "Available skills:"
echo "  /interview           /gap-assessment      /annex-review"
echo "  /risk-assessment     /risk-treatment      /soa"
echo "  /roadmap             /policy-gen          /internal-audit"
echo "  /management-review   /audit-prep          /isms-health"
echo "  /engagement-save     /engagement-restore"
echo ""
echo "To start a new engagement:"
echo "  1. Create a folder for your client:  mkdir my-client && cd my-client"
echo "  2. Open Claude Code:                 claude"
echo "  3. Run the first skill:              /interview"
echo ""
echo "Docs: $SKILLS_DIR/docs/guide.md"
