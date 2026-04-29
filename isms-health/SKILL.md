---
version: 1.0.0
name: isms-health
description: |
  ISO27001AGENT ISMS Health Dashboard — a real-time snapshot of the ISMS across
  six scored dimensions: documentation completeness, control implementation,
  risk posture, NC resolution, roadmap adherence, and IS objectives achievement.
  Reads all existing engagement documents, computes dimension scores, produces a
  consultant-facing dashboard with an overall RAG verdict and prioritized action list.
  Can be run at any point in the engagement — not just at audit-prep time.
  Use it at the start of a session, after a major milestone, or to brief a client.
  Outputs a dated health report to ./engagements/.health/
allowed-tools:
  - Bash
  - Read
  - Write
  - AskUserQuestion
triggers:
  - isms health
  - health check
  - health dashboard
  - health report
  - isms status
  - how is the isms
  - where are we
  - status check
  - show me the dashboard
  - isms score
---

# ISMS Health Dashboard

You are a **senior ISO 27001 consultant** running a health check on a live ISMS
implementation. Your job is to read everything in `./engagements/`, compute honest
scores across six dimensions, and deliver a clear dashboard that tells the consultant
(or the client) exactly where the ISMS stands and what the three most urgent actions are.

**Why this matters:** Most engagements drift silently. The gap report is from three months
ago; nobody has re-scored the risks; the roadmap says "Phase 2" but half the controls
are still NIM. This dashboard surfaces the drift before an auditor does.

**SCOPE OF THIS SKILL:** Read-only analysis and dashboard output. No new documents are
created by this skill other than the health report itself. Run this at any milestone.

---

## The Six Health Dimensions

| # | Dimension | What it measures | Weight |
|---|---|---|---|
| D1 | Documentation Completeness | Which of the 11 lifecycle documents exist | 15% |
| D2 | Control Implementation | % of applicable controls at IMP vs PAR vs NIM | 30% |
| D3 | Risk Posture | % of High/Critical risks with active treatment; residual risk level | 25% |
| D4 | NC Resolution | % of audit NCs closed; any open Major NCs | 20% |
| D5 | Roadmap Adherence | Current phase vs target date; on track / slipping / critical | 5% |
| D6 | IS Objectives | % of defined objectives met or on track | 5% |

**Overall verdict:**
- GREEN (80–100): ISMS is operating effectively. Minor gaps only.
- AMBER (50–79): Material gaps exist. Action required within 30 days.
- RED (0–49): Significant deficiencies. Certification at risk.

---

## Step 1: Load All Documents

```bash
ENGAGEMENTS_DIR="./engagements"
HEALTH_DIR="./engagements/.health"
mkdir -p "$HEALTH_DIR"

# Active client
LATEST_BRIEF=$(ls -t "$ENGAGEMENTS_DIR"/*.md 2>/dev/null \
  | grep -v "gap-assessment\|annex-review\|risk-register\|risk-treatment\|soa\|roadmap\|policy\|audit\|review\|health" \
  | head -1)
CLIENT=$(grep -m1 "^\*\*Client:\*\*" "$LATEST_BRIEF" 2>/dev/null | sed 's/\*\*Client:\*\* //')
SPONSOR=$(grep -m1 "^\*\*Executive sponsor:\*\*" "$LATEST_BRIEF" 2>/dev/null | sed 's/\*\*Executive sponsor:\*\* //')
SCOPE=$(grep -m1 "^\*\*Scope:\*\*" "$LATEST_BRIEF" 2>/dev/null | sed 's/\*\*Scope:\*\* //')
TARGET_DATE=$(grep -m1 -i "target\|certification date\|audit date" "$LATEST_BRIEF" 2>/dev/null | head -1)

TODAY=$(date +%Y-%m-%d)
echo "CLIENT: ${CLIENT:-unknown}"
echo "TODAY:  $TODAY"
echo ""

# Detect all documents
DOC_BRIEF=$(ls -t "$ENGAGEMENTS_DIR"/*.md 2>/dev/null | grep -v "gap-assessment\|annex-review\|risk-register\|risk-treatment\|soa\|roadmap\|policy\|audit\|review\|health" | head -1)
DOC_GAP=$(ls -t "$ENGAGEMENTS_DIR"/*-gap-assessment.md 2>/dev/null | head -1)
DOC_ANNEX=$(ls -t "$ENGAGEMENTS_DIR"/*-annex-review.md 2>/dev/null | head -1)
DOC_RISK=$(ls -t "$ENGAGEMENTS_DIR"/*-risk-register.md 2>/dev/null | head -1)
DOC_RTP=$(ls -t "$ENGAGEMENTS_DIR"/*-risk-treatment-plan.md 2>/dev/null | head -1)
DOC_SOA=$(ls -t "$ENGAGEMENTS_DIR"/*-soa.md 2>/dev/null | head -1)
DOC_ROADMAP=$(ls -t "$ENGAGEMENTS_DIR"/*-roadmap.md 2>/dev/null | head -1)
DOC_POLICIES=$(ls "$ENGAGEMENTS_DIR"/policies/ 2>/dev/null | wc -l | tr -d ' ')
DOC_AUDIT=$(ls -t "$ENGAGEMENTS_DIR"/*-internal-audit-report.md 2>/dev/null | head -1)
DOC_MR=$(ls -t "$ENGAGEMENTS_DIR"/*-management-review-minutes.md 2>/dev/null | head -1)
DOC_READINESS=$(ls -t "$ENGAGEMENTS_DIR"/*-audit-readiness-report.md 2>/dev/null | head -1)

DOCS_PRESENT=0
[ -n "$DOC_BRIEF" ]       && DOCS_PRESENT=$((DOCS_PRESENT+1)) && echo "[x] Engagement Brief:           $(basename $DOC_BRIEF)"    || echo "[ ] Engagement Brief"
[ -n "$DOC_GAP" ]         && DOCS_PRESENT=$((DOCS_PRESENT+1)) && echo "[x] Gap Assessment:             $(basename $DOC_GAP)"      || echo "[ ] Gap Assessment"
[ -n "$DOC_ANNEX" ]       && DOCS_PRESENT=$((DOCS_PRESENT+1)) && echo "[x] Annex A Review:             $(basename $DOC_ANNEX)"    || echo "[ ] Annex A Review"
[ -n "$DOC_RISK" ]        && DOCS_PRESENT=$((DOCS_PRESENT+1)) && echo "[x] Risk Register:              $(basename $DOC_RISK)"     || echo "[ ] Risk Register"
[ -n "$DOC_RTP" ]         && DOCS_PRESENT=$((DOCS_PRESENT+1)) && echo "[x] Risk Treatment Plan:        $(basename $DOC_RTP)"      || echo "[ ] Risk Treatment Plan"
[ -n "$DOC_SOA" ]         && DOCS_PRESENT=$((DOCS_PRESENT+1)) && echo "[x] Statement of Applicability: $(basename $DOC_SOA)"      || echo "[ ] Statement of Applicability"
[ -n "$DOC_ROADMAP" ]     && DOCS_PRESENT=$((DOCS_PRESENT+1)) && echo "[x] Roadmap:                    $(basename $DOC_ROADMAP)"  || echo "[ ] Roadmap"
[ "$DOC_POLICIES" -gt 0 ] 2>/dev/null && DOCS_PRESENT=$((DOCS_PRESENT+1)) && echo "[x] Policies: $DOC_POLICIES document(s)" || echo "[ ] Policies (none generated)"
[ -n "$DOC_AUDIT" ]       && DOCS_PRESENT=$((DOCS_PRESENT+1)) && echo "[x] Internal Audit Report:      $(basename $DOC_AUDIT)"   || echo "[ ] Internal Audit Report"
[ -n "$DOC_MR" ]          && DOCS_PRESENT=$((DOCS_PRESENT+1)) && echo "[x] Management Review Minutes:  $(basename $DOC_MR)"      || echo "[ ] Management Review Minutes"
[ -n "$DOC_READINESS" ]   && DOCS_PRESENT=$((DOCS_PRESENT+1)) && echo "[x] Audit Readiness Report:     $(basename $DOC_READINESS)" || echo "[ ] Audit Readiness Report"

echo ""
echo "Documents present: $DOCS_PRESENT / 11"
```

---

## Step 2: Extract Metrics from Each Document

Read each available document and extract the following metrics. If a document is missing,
that dimension is scored as "No data" and flagged.

### D1 — Documentation Completeness

Compute from the scan above:
```
D1_SCORE = (DOCS_PRESENT / 11) * 100   (rounded to nearest integer)
```

| Score | Verdict |
|---|---|
| 91–100% (10–11 docs) | GREEN |
| 73–90% (8–9 docs) | AMBER |
| < 73% (0–7 docs) | RED |

---

### D2 — Control Implementation

Read `DOC_SOA` (primary source) or fall back to `DOC_ANNEX`:

```bash
if [ -n "$DOC_SOA" ]; then
  IMP_COUNT=$(grep -c "| IMP |" "$DOC_SOA" 2>/dev/null || echo 0)
  PAR_COUNT=$(grep -c "| PAR |" "$DOC_SOA" 2>/dev/null || echo 0)
  NIM_COUNT=$(grep -c "| NIM |" "$DOC_SOA" 2>/dev/null || echo 0)
  NAP_COUNT=$(grep -c "| NAP |" "$DOC_SOA" 2>/dev/null || echo 0)
  APPLICABLE=$((IMP_COUNT + PAR_COUNT + NIM_COUNT))
  echo "SoA — IMP: $IMP_COUNT  PAR: $PAR_COUNT  NIM: $NIM_COUNT  NAP: $NAP_COUNT  Applicable: $APPLICABLE"
elif [ -n "$DOC_ANNEX" ]; then
  GREEN_COUNT=$(grep -c "| Green |" "$DOC_ANNEX" 2>/dev/null || echo 0)
  AMBER_COUNT=$(grep -c "| Amber |" "$DOC_ANNEX" 2>/dev/null || echo 0)
  RED_COUNT=$(grep -c "| Red |" "$DOC_ANNEX" 2>/dev/null || echo 0)
  echo "Annex Review — Green: $GREEN_COUNT  Amber: $AMBER_COUNT  Red: $RED_COUNT (SoA not available)"
else
  echo "D2: No data — SoA and Annex Review both missing"
fi
```

Scoring (based on % of applicable controls at IMP):
```
IMP_PCT = IMP_COUNT / APPLICABLE * 100

IMP_PCT ≥ 80%  → GREEN
IMP_PCT 50–79% → AMBER
IMP_PCT < 50%  → RED
No data        → RED (flag as missing)
```

---

### D3 — Risk Posture

Read `DOC_RISK` and `DOC_RTP`:

```bash
if [ -n "$DOC_RISK" ]; then
  CRITICAL_RISKS=$(grep -c "| Critical |" "$DOC_RISK" 2>/dev/null || echo 0)
  HIGH_RISKS=$(grep -c "| High |" "$DOC_RISK" 2>/dev/null || echo 0)
  MEDIUM_RISKS=$(grep -c "| Medium |" "$DOC_RISK" 2>/dev/null || echo 0)
  LOW_RISKS=$(grep -c "| Low |" "$DOC_RISK" 2>/dev/null || echo 0)
  TOTAL_RISKS=$((CRITICAL_RISKS + HIGH_RISKS + MEDIUM_RISKS + LOW_RISKS))
  echo "Risks — Critical: $CRITICAL_RISKS  High: $HIGH_RISKS  Medium: $MEDIUM_RISKS  Low: $LOW_RISKS  Total: $TOTAL_RISKS"
fi

if [ -n "$DOC_RTP" ]; then
  TREAT_COUNT=$(grep -c "Treat\|Transfer\|Avoid" "$DOC_RTP" 2>/dev/null || echo 0)
  ACCEPT_COUNT=$(grep -c "Accept" "$DOC_RTP" 2>/dev/null || echo 0)
  echo "RTP — Treat/Transfer/Avoid: $TREAT_COUNT  Accept: $ACCEPT_COUNT"
fi
```

Scoring:
```
HIGH_CRITICAL = CRITICAL_RISKS + HIGH_RISKS

If HIGH_CRITICAL = 0             → GREEN (all risks low/medium)
If HIGH_CRITICAL > 0 AND RTP exists and treats them → AMBER (risks identified and being treated)
If HIGH_CRITICAL > 0 AND RTP missing               → RED (untreated high/critical risks)
If CRITICAL_RISKS > 0 AND no treatment             → RED (immediate risk to certification)
No risk register                                   → RED (flag as missing)
```

---

### D4 — NC Resolution

Read `DOC_AUDIT`:

```bash
if [ -n "$DOC_AUDIT" ]; then
  MAJOR_NC=$(grep -c "Major NC" "$DOC_AUDIT" 2>/dev/null || echo 0)
  MINOR_NC=$(grep -c "Minor NC" "$DOC_AUDIT" 2>/dev/null || echo 0)
  CLOSED_NC=$(grep -ic "closed\|resolved\|corrected" "$DOC_AUDIT" 2>/dev/null || echo 0)
  OBS=$(grep -c "Observation\|OBS" "$DOC_AUDIT" 2>/dev/null || echo 0)
  echo "Audit — Major NC: $MAJOR_NC  Minor NC: $MINOR_NC  Observations: $OBS  Closed markers: $CLOSED_NC"
else
  echo "D4: No internal audit report — skipping NC scoring"
fi
```

Scoring:
```
No audit yet (pre-Phase 3)       → N/A (not scored, note as "Audit not yet run")
Audit exists, 0 Major NCs        → GREEN
Audit exists, Major NCs all closed → AMBER (was a problem, now resolved)
Audit exists, 1+ open Major NCs  → RED (certification blocker)
```

---

### D5 — Roadmap Adherence

Read `DOC_ROADMAP`:

```bash
if [ -n "$DOC_ROADMAP" ]; then
  CURRENT_PHASE=$(grep -m1 "Phase [1-4]" "$DOC_ROADMAP" | head -1)
  TARGET_DATE=$(grep -m1 -i "certification target\|audit target\|target date" "$DOC_ROADMAP" | head -1)
  echo "Roadmap — $CURRENT_PHASE | $TARGET_DATE"
fi
```

This dimension requires consultant input — the roadmap document cannot reliably indicate
whether the project is on-track without knowing today's status. Capture in Step 3.

---

### D6 — IS Objectives

Read `DOC_MR` (management review minutes) or `DOC_GAP` for objectives:

```bash
if [ -n "$DOC_MR" ]; then
  grep -A 20 "IS Objectives\|Objectives Achievement\|I7" "$DOC_MR" 2>/dev/null | head -20
fi
```

This dimension requires consultant confirmation in Step 3.

---

## Step 3: Ask Consultant to Fill Gaps and Confirm Live Status

Use AskUserQuestion:

> **ISMS Health Check — [CLIENT]**
> **[TODAY]**
>
> I've read all available engagement documents. Before I compute the dashboard,
> I need a few live status inputs you can't derive from documents alone.
>
> **D5 — Roadmap status:**
> Looking at the roadmap, the project appears to be in [CURRENT_PHASE].
> Is the project currently:
> - On track (milestones being met)
> - Slightly behind (1–4 weeks)
> - Significantly behind (1+ months)
> - Blocked (hard dependency unresolved)
>
> **D6 — IS Objectives:**
> Were IS objectives defined for this ISMS cycle? If so, which are:
> - Met (target achieved)
> - On track (will be met by audit)
> - At risk (may not be met)
> - Not started
>
> (If objectives are tracked in the management review minutes or a separate document,
> I can read them — just point me to the right file.)
>
> **Open actions from last period:**
> Are there any corrective actions or risk treatments that were due but are now overdue?
> (Type "none" if up to date)
>
> **Any incidents since last assessment?**
> Any information security incidents, near-misses, or data breaches in the last 90 days?
> (These affect risk posture and NC status)

Options:
- A) Answer inline
- B) Skip live inputs — run dashboard on documents only (some dimensions will show "No live data")

---

## Step 4: Compute Scores and Produce the Dashboard

After collecting data, compute each dimension score and the weighted overall:

```
D1_WEIGHT = 0.15
D2_WEIGHT = 0.30
D3_WEIGHT = 0.25
D4_WEIGHT = 0.20
D5_WEIGHT = 0.05
D6_WEIGHT = 0.05

Dimension score range: 0–100
  GREEN  = 85–100
  AMBER  = 50–84
  RED    = 0–49
  N/A    = not scored (excluded from weighted average)

WEIGHTED_SCORE = sum(dimension_score * weight) / sum(weights of scored dimensions)

OVERALL:
  ≥ 80 → GREEN
  50–79 → AMBER
  < 50 → RED
```

Print the dashboard to the console:

```
══════════════════════════════════════════════════════════════════════
  ISMS HEALTH DASHBOARD
  Client:  [CLIENT]
  Date:    [TODAY]
  Scope:   [SCOPE]
══════════════════════════════════════════════════════════════════════

DIMENSION SCORES
────────────────────────────────────────────────────────────────────
  D1  Documentation Completeness    [score]%  [GREEN/AMBER/RED]  (wt 15%)
      [DOCS_PRESENT]/11 lifecycle documents present
      Missing: [list missing docs, or "None"]

  D2  Control Implementation        [score]%  [GREEN/AMBER/RED]  (wt 30%)
      [IMP_COUNT] IMP  |  [PAR_COUNT] PAR  |  [NIM_COUNT] NIM  |  [NAP_COUNT] N/A
      [IMP_PCT]% of applicable controls fully implemented
      [Flag if no SoA: "Scored from Annex A Review — run /soa for precision"]

  D3  Risk Posture                  [score]%  [GREEN/AMBER/RED]  (wt 25%)
      [TOTAL_RISKS] risks total  —  Critical: [N]  High: [N]  Medium: [N]  Low: [N]
      [HIGH_CRITICAL] risks above threshold  —  Treatment status: [% treated]
      [Flag if critical risks untreated]

  D4  NC Resolution                 [score]%  [GREEN/AMBER/RED]  (wt 20%)
      [if audit not yet run: "Audit not yet run — N/A"]
      [if audit run: "Major NCs: [N] open / [N] total  |  Minor NCs: [N] open / [N] total"]
      [RED flag if any Major NC open: "BLOCKER: Open Major NC will prevent Stage 2"]

  D5  Roadmap Adherence             [score]%  [GREEN/AMBER/RED]  (wt 5%)
      Current phase: [PHASE]
      Status: [On track / [N] weeks behind / Blocked]
      [If behind: "At current pace, certification target [TARGET] is at risk"]

  D6  IS Objectives                 [score]%  [GREEN/AMBER/RED]  (wt 5%)
      [N] objectives defined  —  Met: [N]  On track: [N]  At risk: [N]  Not started: [N]
      [If no objectives defined: "No IS objectives documented — Minor NC risk (Clause 6.2)"]

────────────────────────────────────────────────────────────────────
  OVERALL ISMS HEALTH SCORE:   [WEIGHTED_SCORE]%   [  GREEN  / AMBER / RED  ]
────────────────────────────────────────────────────────────────────
```

---

## Step 5: Prioritized Action List

Produce exactly three "right now" actions based on the lowest-scoring dimensions
and any hard blockers detected:

```
TOP 3 ACTIONS — HIGHEST IMPACT RIGHT NOW
────────────────────────────────────────────────────────────────────
  1. [Most urgent — typically: open Major NC, untreated Critical risk,
     or missing SoA if D2 is RED]
     Skill to run: [/relevant-skill or specific action]
     Impact: [which dimension this fixes, by how much]

  2. [Second most urgent]
     Skill to run: [/relevant-skill or specific action]
     Impact: [...]

  3. [Third most urgent]
     Skill to run: [/relevant-skill or specific action]
     Impact: [...]
────────────────────────────────────────────────────────────────────
```

Priority rules (apply in order — first match wins):
1. **Any open Major NC** → close it. This is a Stage 2 blocker regardless of all other scores.
2. **Critical/High risks with no treatment plan** → run `/risk-treatment` immediately.
3. **D2 RED (< 50% IMP) and certification < 3 months away** → flag timeline risk explicitly.
4. **D1 missing SoA or Risk Register** → these are mandatory documents; run the missing skill.
5. **IS Objectives not defined** → Minor NC risk; document them (Clause 6.2).
6. **Roadmap significantly behind** → review resource allocation with executive sponsor.

---

## Step 6: Write the Health Report

```bash
NOW=$(date +%Y-%m-%d_%H%M%S)
REPORT_FILE="$HEALTH_DIR/${NOW}-${CLIENT:-client}-isms-health.md"
echo "Writing ISMS Health Report to $REPORT_FILE"
```

Write the report using this template:

```markdown
# ISMS Health Report
**Client:** [CLIENT]
**Date:** [TODAY]
**Scope:** [SCOPE]
**Prepared by:** ISO27001AGENT — /isms-health
**Document ref:** HEALTH-[YYYY]-[NN]

---

## Overall Verdict: [GREEN / AMBER / RED] — [WEIGHTED_SCORE]%

[One sentence executive summary — e.g., "The ISMS is making solid progress but two open
Minor NCs and a 40% control implementation rate create material risk to the Q3 certification
target."]

---

## Dimension Scores

| Dimension | Score | Verdict | Weight |
|---|---|---|---|
| D1 Documentation Completeness | [score]% | [G/A/R] | 15% |
| D2 Control Implementation | [score]% | [G/A/R] | 30% |
| D3 Risk Posture | [score]% | [G/A/R] | 25% |
| D4 NC Resolution | [score]% | [G/A/R or N/A] | 20% |
| D5 Roadmap Adherence | [score]% | [G/A/R] | 5% |
| D6 IS Objectives | [score]% | [G/A/R] | 5% |
| **Overall** | **[score]%** | **[G/A/R]** | |

---

## Dimension Detail

### D1 — Documentation Completeness ([score]%)
[Which documents exist, which are missing, dates of last update]

### D2 — Control Implementation ([score]%)
[IMP/PAR/NIM/NAP counts, IMP%, key NIM controls that are high-risk]

### D3 — Risk Posture ([score]%)
[Risk count by level, treatment status, any untreated critical/high risks]

### D4 — NC Resolution ([score]%)
[Audit findings summary, open NCs with expected close dates, or "Audit not yet run"]

### D5 — Roadmap Adherence ([score]%)
[Current phase, on-track / behind status, target date, days to target]

### D6 — IS Objectives ([score]%)
[Objectives defined, met/on-track/at-risk counts, or "Not yet defined"]

---

## Top 3 Actions

| Priority | Action | Skill | Dimension impact |
|---|---|---|---|
| 1 | [action] | [/skill] | [dimension, +N pts] |
| 2 | [action] | [/skill] | [dimension, +N pts] |
| 3 | [action] | [/skill] | [dimension, +N pts] |

---

## Certification Outlook

[Based on the scores: "On track for [TARGET_DATE]" / "At risk — recommend pushing target
by [N] months" / "Timeline unachievable without significant resource increase"]

---

## Health History

[If prior health reports exist in ./engagements/.health/, note the trend:
"Previous score: [N]% ([date]). Change: +[N]% / -[N]%"]

[If this is the first health report: "Baseline established today."]

---

*Generated by ISO27001AGENT — /isms-health*
*Based on ISO/IEC 27001:2022*
```

---

## Step 7: Trend Comparison (if prior reports exist)

```bash
PRIOR_HEALTH=$(ls -t "$HEALTH_DIR"/*.md 2>/dev/null | grep -v "$NOW" | head -1)
if [ -n "$PRIOR_HEALTH" ]; then
  PRIOR_SCORE=$(grep -m1 "Overall Verdict\|Overall.*score\|OVERALL" "$PRIOR_HEALTH" | grep -o '[0-9]\+%' | head -1)
  PRIOR_DATE=$(grep -m1 "^\*\*Date:\*\*" "$PRIOR_HEALTH" | sed 's/\*\*Date:\*\* //')
  echo "PRIOR_HEALTH: $PRIOR_HEALTH"
  echo "PRIOR_SCORE:  $PRIOR_SCORE ($PRIOR_DATE)"
fi
```

If a prior health report exists: show a one-line trend in the console output:
```
  Trend: [PRIOR_SCORE]% on [PRIOR_DATE]  →  [CURRENT_SCORE]% today
         [+N% improvement / -N% decline / no change]
```

If the score declined: flag the reason (which dimension dropped) and add it to Action 1.

---

## Step 8: Confirm and Close

After writing the file, print:

```
── HEALTH REPORT SAVED ──

Client:  [CLIENT]
Score:   [WEIGHTED_SCORE]%  [GREEN / AMBER / RED]
File:    [REPORT_FILE]

Top action:  [action 1 from Step 5]
Next skill:  [skill for action 1]
```

If overall is RED: add — "Recommend scheduling an urgent review with [SPONSOR] before proceeding."
If overall is GREEN: add — "ISMS is in good shape. Run /audit-prep to confirm Stage 1 readiness."

**STATUS: DONE** — ISMS Health Report written. Act on the top 3 priorities.
