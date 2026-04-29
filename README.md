# ISO27001AGENT
**v1.0.0** — ISO 27001:2022 · 14 skills · Full certification lifecycle

AI-assisted ISO 27001:2022 consulting toolkit for Claude Code. Each skill is a structured
workflow that follows the certification lifecycle — from client intake through to audit
readiness — guiding you step by step, pre-populating answers from prior documents, and
writing auditor-ready output files.

---

## Installation

```bash
git clone --depth 1 https://github.com/gombing/ISO27001Agent.git ~/.claude/skills/iso27001agent \
  && ~/.claude/skills/iso27001agent/setup.sh
```

That's it. Skills are registered globally — open Claude Code in any directory and run `/interview` to start.

---

## What It Does

You type a skill command (e.g. `/interview`). The skill loads your client context
automatically, asks you structured questions, and writes a dated document to
`./engagements/`. Each skill feeds the next. You never start from a blank page.

The full lifecycle produces:

- Engagement Brief
- Gap Assessment Report (Clauses 4–10)
- Annex A RAG Table (93 controls)
- Risk Register
- Risk Treatment Plan
- Statement of Applicability
- Implementation Roadmap
- Policy Templates (up to 30 documents)
- Internal Audit Report
- Management Review Minutes
- Audit Readiness Report

---

## Prerequisites

- [Claude Code](https://claude.ai/code) CLI installed and authenticated
- No other dependencies

---

## How It Works After Install

Skills are registered globally in `~/.claude/CLAUDE.md`.
Open Claude Code in any directory and the skills are available immediately.

Engagement documents are written to `./engagements/` in your current working directory —
so create a folder per client to keep data separate:

```bash
mkdir acme-corp && cd acme-corp
claude
# then run /interview
```

---

## Quick Start

```
/interview
```

This is always the first skill. It captures 8 pieces of information about the client
and writes the engagement brief that every subsequent skill reads for context.

After that, follow the lifecycle in order:

```
/interview → /gap-assessment → /annex-review → /risk-assessment → /risk-treatment
→ /soa → /roadmap → /policy-gen → /internal-audit → /management-review → /audit-prep
```

Run `/isms-health` at any point to get a scored dashboard of where the ISMS stands.

---

## Skills

### Engagement Lifecycle

| Skill | Purpose | Output |
|---|---|---|
| `/interview` | Client intake — 8 forcing questions | Engagement Brief |
| `/gap-assessment` | Clause 4–10 review (29 items) | Gap Assessment Report |
| `/annex-review` | Annex A control review (93 controls) | RAG Table |
| `/risk-assessment` | Clause 6.1.2 risk scoring | Risk Register |
| `/risk-treatment` | Clause 6.1.3 treatment decisions | Risk Treatment Plan |
| `/soa` | Statement of Applicability | SoA Document |
| `/roadmap` | Phased implementation plan | Project Roadmap |
| `/policy-gen` | Required documented information | Policy Templates |
| `/internal-audit` | Clause 9.2 internal audit | Audit Report |
| `/management-review` | Clause 9.3 review agenda + minutes | Signed Minutes |
| `/audit-prep` | Stage 1 + Stage 2 readiness checklist | Readiness Report |

### Session Management

| Skill | Purpose |
|---|---|
| `/engagement-save` | Save full engagement state → resume later |
| `/engagement-restore` | Load latest checkpoint → pick up where you left off |

### Monitoring

| Skill | Purpose |
|---|---|
| `/isms-health` | Scored health dashboard — 6 dimensions + overall RAG verdict |

---

## Multi-Session Engagements

ISO 27001 projects run 3–9 months. Use the session skills to checkpoint your work:

```bash
# End of session
/engagement-save

# Start of next session
/engagement-restore
```

The restore skill prints a full briefing — client context, current phase, documents
produced, outstanding actions, and the next skill to run.

---

## Multiple Clients

Create a folder per client. Each folder has its own `./engagements/` directory.

```bash
mkdir ~/clients/acme-corp && cd ~/clients/acme-corp && claude
mkdir ~/clients/globex    && cd ~/clients/globex    && claude
```

---

## Documentation

See [docs/guide.md](docs/guide.md) for the full consultant guide:
- Detailed description of every skill
- When to use each one
- Common mistakes to avoid
- Full output directory structure
- ISO 27001:2022 clause coverage map

---

## ISO 27001:2022 Coverage

All mandatory clauses (4–10) and all 93 Annex A controls are covered.

| Scope | Coverage |
|---|---|
| Mandatory clauses | 4.1 – 10.2 (all 29 items) |
| Annex A controls | A.5–A.8 (all 93 controls) |
| Required documented information | Clause 7.5 (up to 30 document types) |

---

## License

MIT — see [LICENSE](LICENSE)
