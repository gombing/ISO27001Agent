# ISO27001AGENT — Consultant Guide

AI-assisted ISO 27001:2022 consulting toolkit. Each skill is a structured workflow
that walks you through one phase of the ISO 27001 lifecycle — from client intake
through to audit readiness.

**Current version:** 1.0.0

---

## Installation

One command installs all 14 skills:

```bash
git clone --depth 1 https://github.com/gombing/ISO27001Agent.git ISO27001AGENT && ISO27001AGENT/setup.sh
```

`setup.sh` does two things:

1. Creates a symlink for each skill in `~/.claude/skills/[name]/SKILL.md` so Claude Code
   discovers them natively. Each skill appears as a named slash command.
2. Appends the ISO27001AGENT routing block to `~/.claude/CLAUDE.md` so skill invocations
   trigger automatically when your input matches a known trigger phrase.

To uninstall: run `./uninstall.sh` — removes all symlinks and the routing block.
Your `./engagements/` documents are never touched.

To reinstall after an update: `git pull && ./setup.sh` (idempotent — safe to re-run).

---

## How It Works

Every skill is invoked by typing the skill name (e.g. `/interview`) in the chat.
The skill loads client context from prior documents automatically, asks you structured
questions, and writes a dated output document to `./engagements/`.

You never start from a blank page. Each skill reads what the previous skill produced
and pre-populates answers where it can. Your job is to confirm, correct, and add what
only you know.

---

## The Engagement Lifecycle

Skills are designed to run in order. Each one depends on the output of the one before it.

```
/interview
    ↓
/gap-assessment
    ↓
/annex-review
    ↓
/risk-assessment
    ↓
/risk-treatment
    ↓
/soa
    ↓
/roadmap
    ↓
/policy-gen
    ↓
/internal-audit
    ↓
/management-review
    ↓
/audit-prep
```

You can also run `/isms-health` at any point to get a scored snapshot of where the
ISMS stands across all six dimensions. Run `/engagement-save` and `/engagement-restore`
to checkpoint and resume across multiple sessions.

---

## Skill Reference

---

### `/interview`

**Purpose:** Client intake. Captures the 8 pieces of information every subsequent skill
needs — who the client is, what they do, what's in scope, who owns the ISMS, what's
already in place, and what the certification target is.

**When to use:**
- First meeting with a new client
- Starting a brand-new engagement from scratch
- Onboarding a client who has never had an ISMS

**Do not skip this.** Every other skill loads the engagement brief for client context.
Without it, nothing is pre-populated.

**Inputs required from you:**
- Client name, industry, size, locations
- Executive sponsor name and role
- ISMS scope (what systems, processes, sites are in scope)
- Certification target date
- Any existing security policies or frameworks already in place
- Known pain points or prior audit findings

**Output:** `./engagements/YYYY-MM-DD-[client]-engagement-brief.md`

**ISO 27001 clause:** Context of the organization (Clauses 4.1, 4.2, 4.3)

---

### `/gap-assessment`

**Purpose:** Maps the client's current state against every mandatory requirement in
Clauses 4 through 10 — all 29 items. Produces a RAG-rated gap report with a prioritized
remediation list.

**When to use:**
- Immediately after `/interview`
- When a client asks "how compliant are we?"
- When scoping the implementation effort before quoting a project
- At the start of a re-certification cycle to refresh the baseline

**What you'll be asked:**
- For each clause, what evidence exists (policies, records, meetings, documented processes)
- Whether documented information is actually maintained or just claimed to exist
- Your judgment on whether the evidence is audit-defensible

**Output:** `./engagements/YYYY-MM-DD-[client]-gap-assessment.md`

**ISO 27001 clauses:** 4.1 through 10.2 (all mandatory clauses)

---

### `/annex-review`

**Purpose:** Reviews all 93 Annex A controls across four domains (A.5 Organizational,
A.6 People, A.7 Physical, A.8 Technological). Rates each control Green / Amber / Red / N/A
and identifies which controls are the highest priority to remediate.

**When to use:**
- After `/gap-assessment` — the clause-level gaps tell you *what* is missing; the annex
  review tells you *which controls* need to be implemented to fix it
- When a client asks "which of the 93 controls do we actually need?"
- Before starting the risk assessment (the Red/Amber findings seed the risk register)

**What you'll be asked:**
- For each control, whether it is implemented, partially implemented, or not in place
- Evidence or notes supporting your rating (these appear in the output and are auditor-facing)
- Whether any controls are genuinely not applicable (scope exclusions must be justified)

**Output:** `./engagements/YYYY-MM-DD-[client]-annex-review.md`

**ISO 27001 reference:** Annex A (ISO/IEC 27001:2022)

---

### `/risk-assessment`

**Purpose:** Identifies information security risks across six asset categories, scores
them on a 5x5 likelihood x impact matrix, and produces a risk register. Red and Amber
control gaps from the annex review are pre-suggested as risk scenarios.

**When to use:**
- After `/annex-review` — the control gaps map directly to risk scenarios
- When a client needs a formal risk register for Clause 6.1.2
- When re-assessing risks after a significant change (new system, incident, acquisition)

**What you'll be asked:**
- Likelihood and impact scores for each suggested risk (1-5)
- Whether to add risks not covered by the control gaps
- The organization's risk appetite (accept Low only / accept Low+Medium / accept up to High)

**Asset categories covered:**
- Information assets (data, records, intellectual property)
- IT infrastructure (servers, cloud, network)
- Applications (business systems, SaaS, custom software)
- People (staff, contractors, third parties)
- Physical (offices, data centres, equipment)
- Suppliers and third-party processors

**Output:** `./engagements/YYYY-MM-DD-[client]-risk-register.md`

**ISO 27001 clause:** 6.1.2

---

### `/risk-treatment`

**Purpose:** Works through each risk in the register and decides how to treat it —
Treat (implement controls), Transfer (insurance/outsource), Avoid (stop the activity),
or Accept (document and sign off). Maps Annex A controls to each treatment decision.

**When to use:**
- Directly after `/risk-assessment` — this is the second half of the risk process
- Before building the SoA (the SoA is driven by treatment decisions)
- When a new risk is identified mid-engagement and needs a treatment decision

**What you'll be asked:**
- For each High/Critical risk: treatment option and which Annex A controls address it
- For accepted risks: formal justification and who is accepting the residual risk
- Risk owner sign-off for each treated risk

**Output:** `./engagements/YYYY-MM-DD-[client]-risk-treatment-plan.md`

**ISO 27001 clause:** 6.1.3

---

### `/soa`

**Purpose:** Produces the Statement of Applicability — the document that declares which
of the 93 Annex A controls are applicable, why they are included or excluded, and their
current implementation status. This is one of the two documents an auditor will ask for
on Day 1 of Stage 1.

**When to use:**
- After `/risk-treatment` — the SoA is built from treatment decisions, not invented
- When a client needs to demonstrate control selection rationale to an auditor
- When updating the SoA for re-certification (re-run to refresh implementation status)

**What you will confirm:**
- Which controls were selected via risk treatment (pre-populated)
- Which controls are applicable for legal, contractual, or best-practice reasons
- Exclusions — each excluded control needs a written justification
- Current implementation status (IMP / PAR / NIM / NAP) for each applicable control

**A consistency check runs before the document is written.** If a control is rated Red
in the annex review but marked IMP in the SoA, you will be asked to resolve the conflict.

**Output:** `./engagements/YYYY-MM-DD-[client]-soa.md`

**ISO 27001 clause:** 6.1.3(d)

---

### `/roadmap`

**Purpose:** Turns the NIM (not implemented) and PAR (partially implemented) controls
from the SoA into a phased implementation plan. Groups actions into six workstreams,
sets phase exit gates, and produces a timeline from now to certification audit.

**When to use:**
- After `/soa` — the roadmap is built from the implementation gaps the SoA identifies
- When a client asks "what do we fix first and how long will it take?"
- When presenting a project plan to an executive sponsor for approval
- At the start of each quarter to review progress against the plan

**What you'll be asked:**
- Target certification date (to back-calculate the phase timeline)
- Resource constraints (part-time ISMS owner? external consultant days per month?)
- Whether to adjust workstream groupings for this client's specific context
- Phase dates and milestone owners

**Output:** `./engagements/YYYY-MM-DD-[client]-roadmap.md`

**ISO 27001 reference:** Clause 6.2, Clause 8.1 (operational planning)

---

### `/policy-gen`

**Purpose:** Generates the documented information required by ISO 27001:2022 — policies,
procedures, and records. Reads the SoA to determine which of the 30 document types are
needed, then produces fully client-populated templates (no blank placeholders in the output).

**When to use:**
- After `/soa` — the SoA determines which policies are needed
- When a client has no existing policy documentation
- When existing policies need to be updated to reference ISO 27001:2022 controls
- When preparing for Stage 1 (auditor will ask to see key policies)

**Documents covered (selection based on SoA):**
- IS Policy, ISMS Scope, Acceptable Use, Access Control, Clear Desk/Screen
- Incident Response, Business Continuity, Backup, Password, Encryption
- Asset Management, Supplier Security, Change Management, Vulnerability Management
- Risk Assessment Procedure, Internal Audit Procedure, and more

**Output:** `./engagements/policies/[client]-[policy-name].md` (one file per policy)

**ISO 27001 clause:** 7.5

---

### `/internal-audit`

**Purpose:** Plans and facilitates the internal audit — the formal check that the ISMS
conforms to ISO 27001:2022 before the certification body arrives. Covers Clauses 4-10
and a sample of Annex A controls. Classifies findings as Major NC, Minor NC, Observation,
or Conformity.

**When to use:**
- After the roadmap Phase 2 exit gate (80%+ of controls implemented)
- At least 4-6 weeks before the Stage 1 certification audit
- Annually during the surveillance cycle
- After a significant incident or major change to the ISMS

**Do not run this too early.** If controls are less than 60% implemented, the audit will
produce too many Major NCs to be useful. Run `/isms-health` first to check readiness.

**What you'll be asked:**
- Evidence reviewed for each clause and control sampled
- Finding classification for each item examined
- Corrective action owners and due dates for any NCs raised

**Output:** `./engagements/YYYY-MM-DD-[client]-internal-audit-report.md`

**ISO 27001 clause:** 9.2

---

### `/management-review`

**Purpose:** Prepares the management review agenda, guides you through capturing inputs
and outputs for all 10 mandatory Clause 9.3 items, and produces signed minutes.
Stage 2 auditors routinely ask for these — and minutes that skip the mandatory inputs
are a common Minor NC.

**When to use:**
- After `/internal-audit` — the audit report is a mandatory input (I6) to the review
- Before the Stage 1 audit (management review minutes must exist)
- Annually as part of the surveillance cycle
- When the executive sponsor needs to formally engage with ISMS performance data

**The review must be chaired by the executive sponsor — not the consultant.**
This skill helps you prepare the agenda, capture what was discussed, and write the minutes.

**The 10 mandatory inputs this skill covers:**
I1 Prior MR actions | I2 Context changes | I3 IS performance | I4 NCs and CAs |
I5 Monitoring results | I6 Audit results | I7 Objectives achievement |
I8 Interested party feedback | I9 Risk status | I10 Improvement opportunities

**Output:** `./engagements/YYYY-MM-DD-[client]-management-review-minutes.md`

**ISO 27001 clause:** 9.3

---

### `/audit-prep`

**Purpose:** Final readiness check before the certification audit. Runs a Stage 1
checklist (18 items) and a Stage 2 checklist (26 items), issues a Go / No-Go verdict,
and produces a prioritized punch list of what must be resolved before the auditor arrives.

**When to use:**
- After `/management-review` — all lifecycle documents must exist before audit prep
- 4-8 weeks before the Stage 1 audit date
- When a client asks "are we ready?"
- After closing corrective actions from the internal audit

**What you'll be asked:**
- Status of each mandatory document (does it exist, is it approved, is it current?)
- Whether all Major NCs from the internal audit are closed
- Whether the management review minutes are signed
- Whether staff are aware of the ISMS and their security responsibilities

**Output:** `./engagements/YYYY-MM-DD-[client]-audit-readiness-report.md`

**ISO 27001 clauses:** All (readiness check against the full standard)

---

## Utility Skills

---

### `/isms-health`

**Purpose:** A scored health dashboard that can be run at any point in the engagement.
Reads all available documents, computes scores across six dimensions, and gives you a
weighted overall RAG verdict with the top 3 actions to improve it.

**When to use:**
- At the start of each consulting session to orient yourself
- At monthly or quarterly client check-ins
- When a client asks "how are we doing overall?"
- Before a milestone meeting with the executive sponsor
- When you suspect the project is drifting but need data to make the case

**The six dimensions:**

| Dimension | What it measures | Weight |
|---|---|---|
| D1 Documentation | How many of the 11 lifecycle documents exist | 15% |
| D2 Control Implementation | % of applicable controls at IMP status | 30% |
| D3 Risk Posture | % of High/Critical risks with active treatment | 25% |
| D4 NC Resolution | % of audit NCs closed; any open Major NCs | 20% |
| D5 Roadmap Adherence | Current phase vs target date | 5% |
| D6 IS Objectives | % of defined objectives met or on track | 5% |

**Scores:** GREEN (80-100) / AMBER (50-79) / RED (0-49)

**Output:** `./engagements/.health/YYYY-MM-DD_HHMMSS-[client]-isms-health.md`
Trend comparison is shown if a prior health report exists.

---

### `/engagement-save`

**Purpose:** Saves the full state of the current engagement to a checkpoint file so it
can be resumed in a future conversation. Captures: active client, documents produced,
current phase, outstanding actions, key decisions, and blockers.

**When to use:**
- At the end of every consulting session before closing the conversation
- Before switching to a different client engagement
- After a major milestone (SoA signed, internal audit complete, etc.)
- Any time you want to record a decision or action item for next session

**What you'll be asked:**
- Outstanding actions from this session (e.g. "client to provide asset inventory by Friday")
- Key decisions made (e.g. "scope narrowed to HQ only")
- Blockers or concerns (e.g. "waiting on IT for cloud asset list")
- Any notes for the next session

Quick save option available — saves document state only without the notes prompts.

**Output:** `./engagements/.sessions/YYYY-MM-DD_HHMMSS-[client]-session.md`

---

### `/engagement-restore`

**Purpose:** Loads the most recent checkpoint and delivers a full welcome-back briefing
so you can pick up exactly where you left off — client context, phase, documents produced,
outstanding actions, decisions, and next recommended skill.

**When to use:**
- At the start of any session on an existing engagement
- When you type `/engagement-restore`, you get the briefing immediately with no setup

**What you get back:**
- Client context (name, sponsor, scope, certification target)
- Engagement phase and skill completion count
- Full document inventory with file names
- Outstanding actions from the last session
- Decisions made in prior sessions
- Blockers flagged last time
- Next recommended skill

If the checkpoint is more than 30 days old, you will be reminded to verify that the
certification target and scope are still accurate.

**Output:** Console briefing only (no new document written). The session file was already
written by `/engagement-save`.

---

## Shared Infrastructure

These files govern how every skill behaves. You do not invoke them directly — they run
in the background on every skill execution.

---

### `lib/PREAMBLE.md` — Context loader + shared standards

Every skill begins by running the PREAMBLE. It does two things:

**1. Context loader.** Scans `./engagements/` for the most recent engagement brief and
extracts CLIENT, SCOPE, SPONSOR, CERT_TARGET, URGENCY. Every skill gets this context
automatically — no skill ever asks "which client are we working with?"

**2. Shared standards.** All skills follow the same voice and completion protocol:

**Voice:** Direct, evidence-based, consultant-to-consultant. Name the clause, control,
document, and audit implication. No filler. No AI vocabulary (robust, comprehensive,
nuanced, holistic, leverage, synergy, best-in-class). Short sentences. End with what
the client or auditor needs to do. The consultant has context you do not — present
findings clearly and let them decide.

**Completion Status Protocol:** Every skill exits with one of four statuses:

| Status | When to use |
|---|---|
| `STATUS: DONE` | Skill completed, all mandatory items covered, document written |
| `STATUS: DONE_WITH_CONCERNS` | Completed, but items need attention before the audit |
| `STATUS: BLOCKED` | Cannot proceed — state exact blocker and what was attempted |
| `STATUS: NEEDS_CONTEXT` | Missing information only the consultant can provide |

`DONE_WITH_CONCERNS` format:
```
STATUS: DONE_WITH_CONCERNS
Document written: [path]
Concerns:
  1. [concern — audit implication]
  2. [concern — audit implication]
Recommended action: [what to do before Stage 1]
```

`BLOCKED` format:
```
STATUS: BLOCKED
Blocker: [what is missing or unresolved]
Attempted: [what was tried]
Recommendation: [which skill to run or action to take first]
```

---

### `ETHOS.md` — Consulting philosophy

Six principles that govern every skill's decision logic:

1. **Auditor-Defensible or Nothing** — if it would not survive a Stage 2 audit, the skill
   does not produce it. Partial output with explicit gaps beats a complete document built
   on assumptions.

2. **Pre-Populate, Don't Re-Ask** — prior documents are always read before asking the
   consultant anything. A question that can be answered from an existing document is not
   asked.

3. **The Certification Gap Is the Gap** — compliance is measured against what an accredited
   certification body auditor would accept. Internal standards, client preferences, and
   "industry best practice" are secondary.

4. **Completeness Is Cheap** — the output document covers everything required by the
   clause or control. The consultant edits down; the agent does not thin out.

5. **Scope Is a Decision, Not a Default** — scope inclusions and exclusions are documented
   with justification, not assumed. Every exclusion in the SoA requires a written rationale.

6. **The Consultant Decides** — the agent presents findings, options, and recommendations.
   The consultant makes the call. The agent never treats a pre-populated value as confirmed
   without the consultant having seen it.

---

### `CHANGELOG.md` — Version history

Tracks what changed between versions. Check this when upgrading to understand what new
skills or capabilities were added.

Current release: v1.0.0 (2026-04-28) — full 14-skill toolkit, initial release.

---

### `VERSION`

Single-line file containing the current version string (`1.0.0`). Used by `setup.sh` in
the install confirmation message.

---

## Quick Decision Guide

| Situation | Run this skill |
|---|---|
| Brand new client, first meeting | `/interview` |
| Need to know how big the gap is | `/gap-assessment` |
| Need to know which controls are missing | `/annex-review` |
| Need to identify and score information security risks | `/risk-assessment` |
| Need to decide what to do about the risks | `/risk-treatment` |
| Need the SoA document for Stage 1 | `/soa` |
| Need to show the client a project plan | `/roadmap` |
| Client has no policies | `/policy-gen` |
| Approaching Stage 2, need an internal audit | `/internal-audit` |
| Need management review minutes for the auditor | `/management-review` |
| Asking "are we ready for the cert audit?" | `/audit-prep` |
| Asking "how is the ISMS doing right now?" | `/isms-health` |
| Ending a session, want to resume later | `/engagement-save` |
| Resuming an engagement from a prior session | `/engagement-restore` |

---

## Common Mistakes to Avoid

**Skipping `/interview`.**
Every other skill loads the engagement brief for client context. Without it, nothing is
pre-populated and you will be asked to re-enter the same information in every skill.

**Running `/internal-audit` too early.**
If controls are less than 60% implemented, the audit produces so many Major NCs that it
is not useful. Run `/isms-health` first. If D2 is RED, implement more controls before auditing.

**Skipping `/risk-treatment` before `/soa`.**
The SoA is built from treatment decisions. If you build the SoA without a treatment plan,
control selection will be arbitrary and an auditor will notice. Clause 6.1.3(c) requires
that the SoA reflect what was selected in the risk treatment process.

**Management review minutes without all 10 inputs.**
Minutes that just say "security is fine, no changes needed" are a common Minor NC.
The `/management-review` skill covers all 10 mandatory inputs — do not shortcut it.

**Not saving the session.**
Each conversation starts fresh. Run `/engagement-save` before you close the chat.
A five-minute save prevents a thirty-minute reconstruct next session.

**Ignoring DONE_WITH_CONCERNS.**
If a skill exits with `STATUS: DONE_WITH_CONCERNS`, read the concerns list before moving
on. These are audit risks, not warnings. Each one has an audit implication — address them
before Stage 1.

---

## Output Directory Structure

All documents are written to `./engagements/` with the pattern
`YYYY-MM-DD-[client]-[document-type].md`.

```
engagements/
├── YYYY-MM-DD-[client]-engagement-brief.md
├── YYYY-MM-DD-[client]-gap-assessment.md
├── YYYY-MM-DD-[client]-annex-review.md
├── YYYY-MM-DD-[client]-risk-register.md
├── YYYY-MM-DD-[client]-risk-treatment-plan.md
├── YYYY-MM-DD-[client]-soa.md
├── YYYY-MM-DD-[client]-roadmap.md
├── YYYY-MM-DD-[client]-internal-audit-report.md
├── YYYY-MM-DD-[client]-management-review-minutes.md
├── YYYY-MM-DD-[client]-audit-readiness-report.md
├── policies/
│   ├── [client]-is-policy.md
│   ├── [client]-access-control-policy.md
│   └── ... (one file per policy)
├── .sessions/
│   └── YYYY-MM-DD_HHMMSS-[client]-session.md
└── .health/
    └── YYYY-MM-DD_HHMMSS-[client]-isms-health.md
```

The `engagements/` directory is excluded from git by `.gitignore`. Client data never
leaves your machine unless you explicitly commit and push it.

---

## Repository Structure

```
ISO27001AGENT/
├── setup.sh                    — install: symlinks + CLAUDE.md routing
├── uninstall.sh                — remove symlinks and routing block
├── VERSION                     — current version string (1.0.0)
├── CHANGELOG.md                — version history
├── ETHOS.md                    — consulting philosophy (6 principles)
├── LICENSE                     — MIT
├── README.md                   — quick start
├── .gitignore                  — excludes engagements/* (client data)
├── engagements/
│   └── .gitkeep                — ensures directory exists after fresh clone
├── lib/
│   └── PREAMBLE.md             — shared context loader, voice, completion protocol
├── docs/
│   └── guide.md                — this file
└── [skill-name]/
    └── SKILL.md                — one directory per skill (14 total)
        interview/
        gap-assessment/
        annex-review/
        risk-assessment/
        risk-treatment/
        soa/
        roadmap/
        policy-gen/
        internal-audit/
        management-review/
        audit-prep/
        isms-health/
        engagement-save/
        engagement-restore/
```

Each `SKILL.md` carries YAML frontmatter with `version: 1.0.0`, `name`, `description`,
`allowed-tools`, and `triggers`. The triggers list is what `~/.claude/CLAUDE.md` uses
to auto-invoke the skill without requiring the exact slash command.

---

## ISO 27001:2022 Clause Coverage

| Clause | Topic | Covered by |
|---|---|---|
| 4.1 | Understanding the organization | `/interview` |
| 4.2 | Interested parties | `/interview` |
| 4.3 | Scope | `/interview` |
| 4.4 | ISMS establishment | `/gap-assessment` |
| 5.1 | Leadership | `/gap-assessment` |
| 5.2 | Policy | `/gap-assessment`, `/policy-gen` |
| 5.3 | Roles and responsibilities | `/gap-assessment` |
| 6.1.1 | Risk and opportunity planning | `/gap-assessment` |
| 6.1.2 | Risk assessment | `/risk-assessment` |
| 6.1.3 | Risk treatment + SoA | `/risk-treatment`, `/soa` |
| 6.2 | IS objectives | `/gap-assessment`, `/roadmap` |
| 7.1-7.5 | Support (resources, competence, awareness, documented info) | `/gap-assessment`, `/policy-gen` |
| 8.1-8.3 | Operational planning | `/roadmap`, `/gap-assessment` |
| 9.1 | Monitoring and measurement | `/gap-assessment`, `/isms-health` |
| 9.2 | Internal audit | `/internal-audit` |
| 9.3 | Management review | `/management-review` |
| 10.1-10.2 | Improvement and corrective action | `/internal-audit`, `/audit-prep` |
| Annex A | 93 controls across A.5-A.8 | `/annex-review`, `/soa` |
