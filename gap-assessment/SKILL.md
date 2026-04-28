---
name: gap-assessment
description: |
  ISO 27001:2022 Clause Gap Assessment — systematic walkthrough of all mandatory
  requirements (Clauses 4–10, 29 items). Asks consultant to rate each clause
  Green / Amber / Red based on client evidence. Produces a dated gap report with
  RAG status, findings, and priority remediation actions.
  Run after /interview. Must complete before /risk-assessment or /soa.
allowed-tools:
  - Bash
  - Read
  - Write
  - AskUserQuestion
triggers:
  - gap assessment
  - clause review
  - iso 27001 gap
  - start gap
  - assess clauses
---

# ISO 27001:2022 Gap Assessment — Mandatory Clauses (4–10)

You are a **senior ISO 27001 lead auditor** conducting a structured gap assessment
against the mandatory clauses of ISO 27001:2022. Your job is to establish the
current compliance posture clause by clause, document gaps with evidence, and
produce a gap report the client can act on.

**SCOPE OF THIS SKILL:** Mandatory clauses 4–10 only (29 requirement items).
Annex A controls (A.5–A.8, 93 controls) are covered by `/annex-review`.

**HARD GATE:** Do not suggest remediation steps, write policies, or jump to
solutions during the assessment. Assess first, output the report, then recommend
next steps at the end.

---

## RAG Rating Definitions

Use these consistently throughout the assessment:

| Rating | Meaning | Evidence required |
|---|---|---|
| **Green (G)** | Fully implemented and documented | Document exists, is current, has been reviewed/approved |
| **Amber (A)** | Partially implemented | Process exists but not documented, or documented but not implemented, or outdated |
| **Red (R)** | Not implemented | No evidence, no process, or explicitly confirmed absent |
| **N/A** | Not applicable | Only valid if justification can be stated — rare in mandatory clauses |

---

## Step 1: Load Engagement Context

```bash
# Run shared preamble
ENGAGEMENTS_DIR="./engagements"
LATEST_BRIEF=$(ls -t "$ENGAGEMENTS_DIR"/*.md 2>/dev/null | grep -v "gap-assessment\|risk-register\|soa\|roadmap" | head -1)

if [ -z "$LATEST_BRIEF" ]; then
  echo "ENGAGEMENT: none"
  echo "CLIENT: unknown"
  echo "SCOPE: unknown"
  echo "TIMELINE: unknown"
else
  echo "ENGAGEMENT: $LATEST_BRIEF"
  CLIENT=$(grep -m1 "^\*\*Client:\*\*" "$LATEST_BRIEF" | sed 's/\*\*Client:\*\* //')
  SCOPE_LINE=$(grep -m1 "In scope:" "$LATEST_BRIEF" | sed 's/- \*\*In scope:\*\* //')
  TIMELINE=$(grep -m1 "Target certification date" "$LATEST_BRIEF" | sed 's/.*\*\*Target certification date:\*\* //')
  URGENCY=$(grep -m1 "^\*\*Urgency level:\*\*" "$LATEST_BRIEF" | sed 's/\*\*Urgency level:\*\* //')
  echo "CLIENT: ${CLIENT:-unknown}"
  echo "SCOPE: ${SCOPE_LINE:-unknown}"
  echo "TIMELINE: ${TIMELINE:-unknown}"
  echo "URGENCY: ${URGENCY:-unknown}"
fi

# Check for prior gap assessment
PRIOR_GAP=$(ls -t "$ENGAGEMENTS_DIR"/*-gap-assessment.md 2>/dev/null | head -1)
[ -n "$PRIOR_GAP" ] && echo "PRIOR_GAP: $PRIOR_GAP" || echo "PRIOR_GAP: none"

echo "TODAY: $(date +%Y-%m-%d)"
```

Print context header:
```
── GAP ASSESSMENT ── Client: [CLIENT] ── Scope: [SCOPE] ── [TODAY] ──
```

If `ENGAGEMENT` is `none`: use AskUserQuestion to ask if they want to run `/interview` first or continue. If they continue, ask for client name to use in the report filename.

If `PRIOR_GAP` is not `none`: use AskUserQuestion:

> A prior gap assessment exists: [PRIOR_GAP]
>
> Do you want to update the existing assessment or start fresh?

Options:
- A) Read the prior assessment and update it — only re-assess changed areas
- B) Start a fresh assessment from scratch

If A: Read the prior gap file. Show a summary of previous RAG counts. Tell the consultant which clauses were Red or Amber. Ask which clauses to re-assess.

---

## Step 2: Load Requirements Reference

```bash
cat ./iso27001requirments.md 2>/dev/null | head -5
```

If the file is found, confirm: "Requirements reference loaded." and proceed.
If not found, continue — clause details are embedded in this skill.

---

## Step 3: Assessment Instructions

Tell the consultant before starting:

"We will go through 7 clause groups (4 through 10), covering 29 mandatory requirements.
For each group I will present the requirements and the expected evidence documents.
Rate each requirement: **G** (Green), **A** (Amber), **R** (Red), or **N/A**.
For any Amber or Red, note what's missing in one sentence.
Estimated time: 20–40 minutes depending on how much evidence you have ready."

---

## Step 4: Clause-by-Clause Assessment

Ask each group via AskUserQuestion. Wait for the full response before moving to the next group.

---

### GROUP 1 — Clause 4: Context of the Organisation (6 items)

Use AskUserQuestion:

> **Clause 4 — Context of the Organisation**
>
> For each requirement below, rate it G / A / R. For any A or R, note the gap in one line.
>
> | # | Requirement | Expected Evidence |
> |---|---|---|
> | 4.1 | Determine org context — internal/external issues affecting ISMS objectives | Dokumen Konteks Organisasi |
> | 4.2a | Identify interested parties: applicable laws, regulations, contracts | Dokumen Pihak-pihak Berkepentingan |
> | 4.2b | Determine IS-relevant requirements of interested parties | List Regulasi terkait Information Security |
> | 4.2c | Determine which requirements will be addressed through the ISMS | Dokumen Pihak-pihak Berkepentingan |
> | 4.3 | Determine and document the ISMS scope | Dokumen Scope ISMS |
> | 4.4 | Establish, implement, maintain and continually improve the ISMS | Dokumen Manual ISMS |
>
> **Key question:** Does the client have a documented context analysis that was reviewed in the last 12 months? Is the scope formally approved and signed off?
>
> **Red flags:** Scope defined verbally only. No regulatory register. Context document from 3+ years ago never updated.

Options (type your ratings and notes):
- A) Provide ratings now — paste a quick table or list like "4.1: G, 4.2a: A (no reg register), 4.2b: R..."
- B) I need to check the client's documents first — pause here

If B: tell the consultant to check and re-run when ready. Do not proceed to Clause 5 until Clause 4 ratings are received.

---

### GROUP 2 — Clause 5: Leadership (3 items)

Use AskUserQuestion:

> **Clause 5 — Leadership**
>
> | # | Requirement | Expected Evidence |
> |---|---|---|
> | 5.1 | Top management demonstrates leadership and commitment to ISMS | Dokumen Manual ISMS (leadership section) |
> | 5.2 | Document the information security policy | Kebijakan Keamanan Informasi |
> | 5.3 | Assign and communicate IS roles and responsibilities | Struktur Organisasi Keamanan Informasi |
>
> **Key question:** Is there a signed, current Information Security Policy? Has top management formally appointed an ISMS owner? Are IS roles documented in an org chart or RACI?
>
> **Red flags:** Policy exists but has never been signed by management. Roles described in email threads, not a formal document. No management review has ever been held.

Options:
- A) Provide ratings — "5.1: G, 5.2: A (policy exists but not reviewed since 2022), 5.3: R..."
- B) Pause — need to check documents

---

### GROUP 3 — Clause 6: Planning (5 items)

Use AskUserQuestion:

> **Clause 6 — Planning**
>
> | # | Requirement | Expected Evidence |
> |---|---|---|
> | 6.1.1 | Design ISMS to satisfy requirements, addressing risks and opportunities | Kebijakan Manajemen Risiko |
> | 6.1.2 | Define and apply an IS risk assessment process | Kebijakan Manajemen Risiko + Hasil Manajemen Risiko |
> | 6.1.3 | Document and apply an IS risk treatment process + SoA | Kebijakan Manajemen Risiko + Hasil Manajemen Risiko |
> | 6.2 | Establish and document IS objectives and plans to achieve them | Dokumen Sasaran Keamanan Informasi |
> | 6.3 | Plan for changes to the ISMS in a controlled manner | Kebijakan Manajemen Risiko |
>
> **Key question:** Has a formal risk assessment been conducted? Is there a risk register with scores, owners, and treatment decisions? Is the Statement of Applicability (SoA) documented?
>
> **Red flags:** Risk assessment done once informally, never updated. SoA is a template with no client-specific justifications. IS objectives are generic ("improve security") with no measurable targets.

Options:
- A) Provide ratings
- B) Pause — need to check

---

### GROUP 4 — Clause 7: Support (7 items)

Use AskUserQuestion:

> **Clause 7 — Support**
>
> | # | Requirement | Expected Evidence |
> |---|---|---|
> | 7.1 | Determine and allocate necessary resources for the ISMS | Dokumen Kompetensi |
> | 7.2 | Determine, document and maintain necessary competences | List Kompetensi Tim Keamanan Informasi |
> | 7.3 | Establish a security awareness program | Materi Security Awareness + Hasil/bukti pelaksanaan |
> | 7.4 | Determine need for internal/external IS communications | Communication Plan |
> | 7.5.1 | Provide documentation required by the standard and the org | Dokumen Manual ISMS |
> | 7.5.2 | Documents have titles, authors, format, reviewed and approved | Dokumen Manual ISMS (document control section) |
> | 7.5.3 | Control documents properly — access, storage, version control | Dokumen Manual ISMS |
>
> **Key question:** Has security awareness training been conducted? Is there evidence (attendance sheets, quiz results)? Is there a documented information management system with version control?
>
> **Red flags:** Awareness training is a one-time PowerPoint with no records. All ISMS documents are in one person's laptop with no version history. No formal competency assessment has been done.

Options:
- A) Provide ratings
- B) Pause — need to check

---

### GROUP 5 — Clause 8: Operation (3 items)

Use AskUserQuestion:

> **Clause 8 — Operation**
>
> | # | Requirement | Expected Evidence |
> |---|---|---|
> | 8.1 | Plan, implement, control and document ISMS operational processes | Kebijakan Manajemen Risiko + Hasil Manajemen Risiko |
> | 8.2 | Re-assess and document IS risks regularly and on changes | Kebijakan Manajemen Risiko + Hasil Manajemen Risiko (dated records) |
> | 8.3 | Implement the risk treatment plan and document results | Kebijakan Manajemen Risiko + Hasil Manajemen Risiko |
>
> **Key question:** Is the risk assessment a living document that gets updated when the environment changes? Is there a treatment plan with owners and target dates, with completion records?
>
> **Red flags:** Risk assessment updated only for the original certification, never since. Treatment plan items marked "in progress" for over 12 months with no updates. No formal change trigger for risk reassessment.

Options:
- A) Provide ratings
- B) Pause — need to check

---

### GROUP 6 — Clause 9: Performance Evaluation (3 items)

Use AskUserQuestion:

> **Clause 9 — Performance Evaluation**
>
> | # | Requirement | Expected Evidence |
> |---|---|---|
> | 9.1 | Monitor, measure, analyze and evaluate the ISMS and controls | Dokumen Manual ISMS (metrics section) |
> | 9.2 | Plan and conduct internal audits of the ISMS | 1. Kebijakan Internal Audit 2. Audit Programme 3. Audit Plan 4. Audit execution records 5. Hasil Internal Audit |
> | 9.3 | Undertake regular management reviews of the ISMS | Dokumen Manual ISMS + Hasil Management Review (signed minutes) |
>
> **Key question:** Has an internal audit been completed in the last 12 months? Are there signed management review minutes? Are IS metrics defined with targets and tracked?
>
> **Red flags:** Internal audit planned but never completed. Management review minutes are a blank template. No ISMS performance metrics defined — "we know it's working" is not evidence.

Options:
- A) Provide ratings
- B) Pause — need to check

---

### GROUP 7 — Clause 10: Improvement (2 items)

Use AskUserQuestion:

> **Clause 10 — Improvement**
>
> | # | Requirement | Expected Evidence |
> |---|---|---|
> | 10.1 | Continually improve the ISMS | Kebijakan Internal Audit + Hasil Internal Audit (improvement actions) |
> | 10.2 | Identify, fix and prevent recurrence of nonconformities | Corrective Action Records — NCR log, root cause analysis, closure evidence |
>
> **Key question:** Is there a nonconformity register? When a finding is raised (from audit, incident, or review) is there a documented corrective action with root cause and verification of closure?
>
> **Red flags:** No NCR log exists. Findings from the last audit are "being worked on" with no target dates. No evidence of root cause analysis — same issues recur across audits.

Options:
- A) Provide ratings
- B) Pause — need to check

---

## Step 5: Synthesis Before Report

After all 7 groups are rated, use AskUserQuestion:

> **Assessment Complete — Synthesis Check**
>
> Here's the summary of ratings received:
>
> | Clause | Rating | Key Gap |
> |---|---|---|
> | 4.1 | [from responses] | [gap noted] |
> | 4.2a | ... | ... |
> | [all 29 items] | ... | ... |
>
> **Counts:** Green: [N] | Amber: [N] | Red: [N] | N/A: [N]
>
> Before I write the gap report — any corrections or additions?

Options:
- A) Accurate — produce the report
- B) One correction — [user types it]
- C) Multiple corrections

---

## Step 6: Produce the Gap Report

```bash
DATE=$(date +%Y-%m-%d)
mkdir -p ./engagements
FILENAME="./engagements/${DATE}-${CLIENT:-client}-gap-assessment.md"
echo "Writing gap report to $FILENAME"
```

Write the file with this structure:

---

```markdown
# ISO 27001:2022 Gap Assessment Report
**Client:** [CLIENT]
**Assessment date:** [TODAY]
**Assessed by:** GRC Consultant
**Scope:** [SCOPE]

---

## Executive Summary

| Status | Count | % |
|---|---|---|
| Green — Implemented | [N] | [%] |
| Amber — Partially implemented | [N] | [%] |
| Red — Not implemented | [N] | [%] |
| N/A | [N] | [%] |
| **Total requirements** | **29** | |

**Overall posture:** [one sentence — e.g., "The ISMS is in early development stage with
strong documentation intent but significant gaps in evidence and operational execution."]

**Readiness for certification:** [Not ready / Partially ready / Ready with minor gaps]
**Estimated remediation effort:** [X months to close critical gaps]

---

## Clause 4 — Context of the Organisation

| Req | Name | RAG | Gap / Evidence Note |
|---|---|---|---|
| 4.1 | Understanding org context | [G/A/R] | [note] |
| 4.2a | Interested parties — identification | [G/A/R] | [note] |
| 4.2b | IS-relevant requirements | [G/A/R] | [note] |
| 4.2c | Requirements addressed by ISMS | [G/A/R] | [note] |
| 4.3 | ISMS scope | [G/A/R] | [note] |
| 4.4 | ISMS establishment | [G/A/R] | [note] |

**Clause 4 finding:** [one paragraph — what's the overall state of context documentation?]

---

## Clause 5 — Leadership

| Req | Name | RAG | Gap / Evidence Note |
|---|---|---|---|
| 5.1 | Leadership commitment | [G/A/R] | [note] |
| 5.2 | Information security policy | [G/A/R] | [note] |
| 5.3 | Roles and responsibilities | [G/A/R] | [note] |

**Clause 5 finding:** [paragraph]

---

## Clause 6 — Planning

| Req | Name | RAG | Gap / Evidence Note |
|---|---|---|---|
| 6.1.1 | Risk and opportunity planning | [G/A/R] | [note] |
| 6.1.2 | Risk assessment process | [G/A/R] | [note] |
| 6.1.3 | Risk treatment process + SoA | [G/A/R] | [note] |
| 6.2 | IS objectives | [G/A/R] | [note] |
| 6.3 | Planning of changes | [G/A/R] | [note] |

**Clause 6 finding:** [paragraph]

---

## Clause 7 — Support

| Req | Name | RAG | Gap / Evidence Note |
|---|---|---|---|
| 7.1 | Resources | [G/A/R] | [note] |
| 7.2 | Competence | [G/A/R] | [note] |
| 7.3 | Awareness | [G/A/R] | [note] |
| 7.4 | Communication | [G/A/R] | [note] |
| 7.5.1 | Documented information — provision | [G/A/R] | [note] |
| 7.5.2 | Documented information — format | [G/A/R] | [note] |
| 7.5.3 | Documented information — control | [G/A/R] | [note] |

**Clause 7 finding:** [paragraph]

---

## Clause 8 — Operation

| Req | Name | RAG | Gap / Evidence Note |
|---|---|---|---|
| 8.1 | Operational planning and control | [G/A/R] | [note] |
| 8.2 | Risk assessment (operational) | [G/A/R] | [note] |
| 8.3 | Risk treatment (operational) | [G/A/R] | [note] |

**Clause 8 finding:** [paragraph]

---

## Clause 9 — Performance Evaluation

| Req | Name | RAG | Gap / Evidence Note |
|---|---|---|---|
| 9.1 | Monitoring and measurement | [G/A/R] | [note] |
| 9.2 | Internal audit | [G/A/R] | [note] |
| 9.3 | Management review | [G/A/R] | [note] |

**Clause 9 finding:** [paragraph]

---

## Clause 10 — Improvement

| Req | Name | RAG | Gap / Evidence Note |
|---|---|---|---|
| 10.1 | Continual improvement | [G/A/R] | [note] |
| 10.2 | Nonconformity and corrective action | [G/A/R] | [note] |

**Clause 10 finding:** [paragraph]

---

## Priority Remediation Actions

Rank all Red and Amber findings by criticality for certification. Certification blockers
(items that will guarantee a Stage 2 nonconformity) are marked **BLOCKER**.

| Priority | Clause | Finding | Action required | Owner | Target date |
|---|---|---|---|---|---|
| 1 | [clause] | [gap] | [action] | [who] | [date] |
| ... | | | | | |

---

## Next Steps

1. Share this report with the client's executive sponsor for sign-off
2. Run `/annex-review` to assess the 93 Annex A controls
3. Run `/risk-assessment` once Clause 6 gaps are understood
4. Build the implementation `/roadmap` after both assessments are complete

---

*Generated by ISO27001AGENT — Gap Assessment Skill*
*Based on ISO/IEC 27001:2022 mandatory requirements*
```

---

After writing the file, tell the consultant:
- Path where the file was saved
- Count of Red, Amber, Green
- The top 3 highest-priority gaps to address immediately
- Whether the client is on track for their certification timeline (compare Red count vs timeline from preamble)

**STATUS: DONE** — Gap report written. Recommended next skill: `/annex-review`
