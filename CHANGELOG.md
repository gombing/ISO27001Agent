# Changelog

All notable changes to ISO27001AGENT are documented here.

---

## [1.0.0] — 2026-04-28

**Full ISO 27001:2022 certification lifecycle, end-to-end, in one toolkit.**

First public release. Covers the complete journey from client intake to audit
readiness — 14 skills, all 29 mandatory clauses, all 93 Annex A controls, up to
30 policy templates. Every skill reads prior documents first and pre-populates
answers so consultants confirm rather than re-enter. Engagement documents are
written to `./engagements/` in the current directory, so each client gets their
own clean workspace.

### Skills added

**Engagement lifecycle (run in order):**
- `/interview` — Client intake: 8 forcing questions → Engagement Brief
- `/gap-assessment` — Clause 4–10 review (29 items) → Gap Report with RAG ratings
- `/annex-review` — All 93 Annex A controls → RAG table with evidence notes
- `/risk-assessment` — Clause 6.1.2 risk scoring on 5×5 likelihood × impact matrix → Risk Register
- `/risk-treatment` — Clause 6.1.3 treatment decisions (Treat/Transfer/Avoid/Accept) → Risk Treatment Plan
- `/soa` — Statement of Applicability: all 93 controls with justification and implementation status
- `/roadmap` — 6 workstreams, 4 phases, phase exit gates, critical path → Project Plan
- `/policy-gen` — 30 document types, pre-populated with client context → Policy Templates
- `/internal-audit` — Clause 9.2 audit with Major NC / Minor NC / Observation / Conformity classification → Audit Report
- `/management-review` — All 10 mandatory Clause 9.3 inputs + 3 outputs → Signed Minutes
- `/audit-prep` — Stage 1 (18 items) + Stage 2 (26 items) readiness checklists → Readiness Report

**Session management:**
- `/engagement-save` — Checkpoint full engagement state (phase, documents, actions, decisions)
- `/engagement-restore` — Resume from latest checkpoint with full welcome-back briefing

**Monitoring:**
- `/isms-health` — 6-dimension scored dashboard (D1 Documentation, D2 Controls, D3 Risk, D4 NCs, D5 Roadmap, D6 Objectives) with weighted overall RAG verdict and top-3 action list

### Infrastructure
- `lib/PREAMBLE.md` — shared context loader injected by every skill; extracts client, scope, sponsor, certification target from the latest engagement brief
- `iso27001requirments.md` — source of truth for all 29 mandatory clauses and 93 Annex A controls
- `ETHOS.md` — consulting philosophy: auditor-defensible output, pre-populate before asking, completeness is cheap
- `setup.sh` — one-command install: symlinks all skills into `~/.claude/skills/` and registers routing in `~/.claude/CLAUDE.md`
- `uninstall.sh` — clean removal
- `docs/guide.md` — full consultant guide with per-skill documentation and when-to-use guidance
