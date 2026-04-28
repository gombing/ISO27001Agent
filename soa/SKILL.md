---
name: soa
description: |
  ISO 27001:2022 Statement of Applicability (SoA) — Clause 6.1.3(d) compliant.
  Loads the Risk Treatment Plan and Annex A Review to pre-populate inclusion/exclusion
  status for all 93 Annex A controls. Consultant reviews and confirms each decision.
  Documents justification (risk treatment, legal, contractual, best practice, or N/A)
  and implementation status for every control.
  Produces the formal SoA document required for Stage 1 and Stage 2 audits.
  Run after /risk-treatment. Required for /roadmap and /audit-prep.
allowed-tools:
  - Bash
  - Read
  - Write
  - AskUserQuestion
triggers:
  - statement of applicability
  - soa
  - applicable controls
  - control applicability
  - clause 6.1.3
  - annex a applicability
---

# ISO 27001:2022 Statement of Applicability (Clause 6.1.3)

You are a **senior ISO 27001 lead auditor** producing the Statement of Applicability.
Your job is to determine the applicable/not-applicable status of all 93 Annex A controls,
document the justification for every decision, and confirm the implementation status of
each included control.

**Why the SoA matters:** An auditor will use this document to verify that:
1. Controls were selected systematically (from risk treatment — not arbitrarily)
2. Every exclusion has a sound justification (not just "doesn't apply")
3. The implementation status is honest — Amber/Red controls cannot be marked "Implemented"

**SCOPE OF THIS SKILL:** All 93 Annex A controls, Clause 6.1.3(d).
The SoA references the Risk Treatment Plan and Annex A Review as source documents.

**HARD GATE:** Do not write policy content or implementation detail here. Decisions only.

---

## Justification Categories

Use these consistently throughout the SoA:

| Code | Justification | Meaning |
|---|---|---|
| **RT** | Risk treatment | Control selected to treat one or more identified risks |
| **LR** | Legal/regulatory requirement | Control required by applicable law or regulation |
| **CR** | Contractual requirement | Control required by customer, partner, or contract |
| **BP** | Best practice | Control included as good practice; no specific risk driver |
| **NA** | Not applicable | Control excluded — justification required |

A control can have more than one justification (e.g., RT + LR).

---

## Implementation Status Codes

| Code | Meaning |
|---|---|
| **IMP** | Implemented — control is operational, evidence exists |
| **PAR** | Partially implemented — some elements in place, gaps remain |
| **NIM** | Not implemented — not yet in place; scheduled in roadmap |
| **NAP** | Not applicable — excluded from SoA |

---

## Step 1: Load Prior Work

```bash
ENGAGEMENTS_DIR="./engagements"

LATEST_BRIEF=$(ls -t "$ENGAGEMENTS_DIR"/*.md 2>/dev/null \
  | grep -v "gap-assessment\|annex-review\|risk-register\|risk-treatment\|soa\|roadmap" \
  | head -1)
CLIENT=$(grep -m1 "^\*\*Client:\*\*" "$LATEST_BRIEF" 2>/dev/null | sed 's/\*\*Client:\*\* //')

ANNEX_REVIEW=$(ls -t "$ENGAGEMENTS_DIR"/*-annex-review.md 2>/dev/null | head -1)
RISK_TREATMENT=$(ls -t "$ENGAGEMENTS_DIR"/*-risk-treatment-plan.md 2>/dev/null | head -1)
PRIOR_SOA=$(ls -t "$ENGAGEMENTS_DIR"/*-soa.md 2>/dev/null | head -1)

[ -n "$ANNEX_REVIEW" ]    && echo "ANNEX_REVIEW: $ANNEX_REVIEW"    || echo "ANNEX_REVIEW: none"
[ -n "$RISK_TREATMENT" ]  && echo "RISK_TREATMENT: $RISK_TREATMENT" || echo "RISK_TREATMENT: none"
[ -n "$PRIOR_SOA" ]       && echo "PRIOR_SOA: $PRIOR_SOA"          || echo "PRIOR_SOA: none"
echo "CLIENT: ${CLIENT:-unknown}"
echo "TODAY: $(date +%Y-%m-%d)"
```

Print context header:
```
── STATEMENT OF APPLICABILITY ── Client: [CLIENT] ── [TODAY] ──
```

**If `RISK_TREATMENT` is `none`:** use AskUserQuestion:

> No Risk Treatment Plan found. The SoA must reference which risks drove each control
> selection (Clause 6.1.3). It is strongly recommended to run `/risk-treatment` first.
>
> Proceed without a treatment plan?

Options:
- A) Proceed — I'll assign justifications manually
- B) Run `/risk-treatment` first (strongly recommended)

**If `ANNEX_REVIEW` is `none`:** warn — implementation status will need to be entered
manually for all 93 controls. Allow proceeding.

**If `PRIOR_SOA` is not `none`:** use AskUserQuestion:

> A prior SoA exists: [PRIOR_SOA]
>
> Update it or start fresh?

Options:
- A) Update — review only controls whose status has changed
- B) Start fresh

---

## Step 2: Build the Pre-Population Map

Read both source documents, then internally derive the pre-populated status for each
control before asking any questions. Do not display this working — use it to answer
questions intelligently.

```bash
# Extract controls selected in risk treatment plan
[ -n "$RISK_TREATMENT" ] && grep -E "^\| A\.[5678]\." "$RISK_TREATMENT" 2>/dev/null | head -100

# Extract RAG status for each control from annex review
[ -n "$ANNEX_REVIEW" ] && grep -E "^\| A\.[5678]\." "$ANNEX_REVIEW" 2>/dev/null | head -100
```

Build an internal map:
- **Selected in risk treatment** → default to **Applicable, justification=RT**
- **RAG = Green in annex review** → implementation status = IMP
- **RAG = Amber in annex review** → implementation status = PAR
- **RAG = Red in annex review** → implementation status = NIM
- **RAG = N/A in annex review** → candidate for NAP — confirm with consultant
- **Not selected in risk treatment AND no RAG** → ask consultant for justification

---

## Step 3: Confirm Scope Exclusions First

Before reviewing all 93 controls, establish what's definitively out of scope.
This avoids marking controls N/A one at a time for obvious whole-category exclusions.

Use AskUserQuestion:

> **Step 1 of 5 — Scope Exclusions**
>
> Before we review each control, confirm any whole-category exclusions.
> These will automatically mark a group of controls as Not Applicable in the SoA.
>
> Common exclusions — does any of the following apply to this client?
>
> | # | Exclusion scenario | Controls affected |
> |---|---|---|
> | E1 | Organization does not develop software (no in-house dev) | A.8.4, A.8.25, A.8.26, A.8.27, A.8.28, A.8.29, A.8.30, A.8.33 |
> | E2 | Organization has no physical data centre / server room (cloud-only) | A.7.1–A.7.14 (partial) — review per control |
> | E3 | No outsourced / third-party software development | A.8.30 |
> | E4 | Organization has no ICT supply chain (no hardware procurement) | A.5.21 |
> | E5 | No removable media used in operations | A.7.10 |
> | E6 | No remote working permitted | A.6.7 |
>
> Which exclusions apply? List the numbers (e.g., "E1, E3") or "None."
>
> **Important:** Each exclusion still requires a written justification in the SoA.
> "We don't do X" is sufficient if accurate and specific.

Record confirmed exclusions. Auto-mark those controls as NAP with justification:
"[Exclusion reason — confirmed by consultant on [TODAY]]"

---

## Step 4: Review Controls by Theme

Work through each theme. For each group, present the pre-populated status and ask the
consultant to confirm, correct, or add justification. Do NOT ask them to rate controls
they already rated in the annex review — confirm pre-populated values instead.

---

### A.5 ORGANIZATIONAL — Part 1 (A.5.1–A.5.19)

Use AskUserQuestion:

> **A.5 Organizational Controls — Part 1 (A.5.1–A.5.19)**
>
> Below is the pre-populated status based on your risk treatment and annex review.
> Review each row. Type corrections in the format: [A.5.X]: Applicable/NA, Justification, Status
> If a row is correct, no action needed.
>
> | Control | Name | Applicable | Justification | Status | Notes |
> |---|---|---|---|---|---|
> | A.5.1 | Policies for information security | [Y/N] | [RT/LR/CR/BP/NA] | [IMP/PAR/NIM/NAP] | |
> | A.5.2 | IS roles and responsibilities | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.5.3 | Segregation of duties | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.5.4 | Management responsibilities | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.5.5 | Contact with authorities | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.5.6 | Contact with special interest groups | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.5.7 | Threat intelligence | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.5.8 | IS in project management | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.5.9 | Inventory of assets | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.5.10 | Acceptable use of assets | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.5.11 | Return of assets | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.5.12 | Classification of information | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.5.13 | Labelling of information | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.5.14 | Information transfer | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.5.15 | Access control | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.5.16 | Identity management | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.5.17 | Authentication information | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.5.18 | Access rights | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.5.19 | IS in supplier relationships | [Y/N] | [pre-pop] | [pre-pop] | |
>
> **Red flags to correct before confirming:**
> - Any control with a Red annex rating but marked IMP — change to NIM
> - Any exclusion without a specific written justification
> - A.5.1 and A.5.2 cannot be excluded without a major Clause 5 nonconformity

Options:
- A) All rows confirmed — proceed to next group
- B) Corrections — [type them]

---

### A.5 ORGANIZATIONAL — Part 2 (A.5.20–A.5.37)

Use AskUserQuestion:

> **A.5 Organizational Controls — Part 2 (A.5.20–A.5.37)**
>
> | Control | Name | Applicable | Justification | Status | Notes |
> |---|---|---|---|---|---|
> | A.5.20 | IS in supplier agreements | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.5.21 | IS in ICT supply chain | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.5.22 | Monitoring of supplier services | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.5.23 | IS for cloud services | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.5.24 | Incident management planning | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.5.25 | Assessment of IS events | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.5.26 | Response to IS incidents | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.5.27 | Learning from incidents | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.5.28 | Collection of evidence | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.5.29 | IS during disruption | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.5.30 | ICT readiness for business continuity | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.5.31 | Legal, statutory, regulatory requirements | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.5.32 | Intellectual property rights | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.5.33 | Protection of records | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.5.34 | Privacy and PII protection | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.5.35 | Independent review of IS | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.5.36 | Compliance with IS policies | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.5.37 | Documented operating procedures | [Y/N] | [pre-pop] | [pre-pop] | |
>
> **Note:** A.5.24–A.5.27 (incident management cluster) are almost always applicable.
> An auditor will probe any exclusion of these controls very carefully.

Options:
- A) Confirmed — proceed
- B) Corrections

---

### A.6 PEOPLE (A.6.1–A.6.8)

Use AskUserQuestion:

> **A.6 People Controls (A.6.1–A.6.8)**
>
> | Control | Name | Applicable | Justification | Status | Notes |
> |---|---|---|---|---|---|
> | A.6.1 | Screening | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.6.2 | Terms and conditions of employment | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.6.3 | IS awareness, education and training | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.6.4 | Disciplinary process | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.6.5 | Responsibilities after termination | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.6.6 | Confidentiality / NDA agreements | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.6.7 | Remote working | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.6.8 | IS event reporting | [Y/N] | [pre-pop] | [pre-pop] | |
>
> **Note:** A.6.2, A.6.3, A.6.5, A.6.8 are applicable in virtually all organizations.
> A.6.7 can be excluded only if remote working is genuinely not permitted and enforced.

Options:
- A) Confirmed — proceed
- B) Corrections

---

### A.7 PHYSICAL (A.7.1–A.7.14)

Use AskUserQuestion:

> **A.7 Physical Controls (A.7.1–A.7.14)**
>
> | Control | Name | Applicable | Justification | Status | Notes |
> |---|---|---|---|---|---|
> | A.7.1 | Physical security perimeters | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.7.2 | Physical entry | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.7.3 | Securing offices, rooms and facilities | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.7.4 | Physical security monitoring | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.7.5 | Protection against physical/environmental threats | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.7.6 | Working in secure areas | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.7.7 | Clear desk and clear screen | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.7.8 | Equipment siting and protection | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.7.9 | Security of assets off-premises | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.7.10 | Storage media | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.7.11 | Supporting utilities | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.7.12 | Cabling security | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.7.13 | Equipment maintenance | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.7.14 | Secure disposal or re-use of equipment | [Y/N] | [pre-pop] | [pre-pop] | |
>
> **Cloud-only note:** If the client uses no physical servers (pure cloud), A.7.1–A.7.6,
> A.7.8, A.7.11, A.7.12, A.7.13 may be excluded — but A.7.9 (laptops), A.7.14 (disposal)
> and A.7.7 (clear desk) almost always remain applicable.

Options:
- A) Confirmed — proceed
- B) Corrections

---

### A.8 TECHNOLOGICAL — Part 1 (A.8.1–A.8.17)

Use AskUserQuestion:

> **A.8 Technological Controls — Part 1 (A.8.1–A.8.17)**
>
> | Control | Name | Applicable | Justification | Status | Notes |
> |---|---|---|---|---|---|
> | A.8.1 | User endpoint devices | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.8.2 | Privileged access rights | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.8.3 | Information access restriction | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.8.4 | Access to source code | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.8.5 | Secure authentication | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.8.6 | Capacity management | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.8.7 | Protection against malware | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.8.8 | Management of technical vulnerabilities | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.8.9 | Configuration management | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.8.10 | Information deletion | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.8.11 | Data masking | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.8.12 | Data leakage prevention | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.8.13 | Information backup | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.8.14 | Redundancy of information processing | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.8.15 | Logging | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.8.16 | Monitoring activities | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.8.17 | Clock synchronization | [Y/N] | [pre-pop] | [pre-pop] | |

Options:
- A) Confirmed — proceed
- B) Corrections

---

### A.8 TECHNOLOGICAL — Part 2 (A.8.18–A.8.34)

Use AskUserQuestion:

> **A.8 Technological Controls — Part 2 (A.8.18–A.8.34)**
>
> | Control | Name | Applicable | Justification | Status | Notes |
> |---|---|---|---|---|---|
> | A.8.18 | Use of privileged utility programs | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.8.19 | Installation of software on operational systems | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.8.20 | Network security | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.8.21 | Security of network services | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.8.22 | Segregation of networks | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.8.23 | Web filtering | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.8.24 | Use of cryptography | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.8.25 | Secure development lifecycle | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.8.26 | Application security requirements | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.8.27 | Secure system architecture and engineering | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.8.28 | Secure coding | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.8.29 | Security testing in development | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.8.30 | Outsourced development | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.8.31 | Separation of dev/test/prod environments | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.8.32 | Change management | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.8.33 | Test information | [Y/N] | [pre-pop] | [pre-pop] | |
> | A.8.34 | Protection of systems during audit testing | [Y/N] | [pre-pop] | [pre-pop] | |
>
> **Development controls note:** A.8.25–A.8.34 can be excluded if no software development
> occurs in scope. The exclusion must state: "The organization does not develop software
> within the ISMS scope. These controls are therefore not applicable." Each control
> needs this written individually.

Options:
- A) Confirmed — proceed
- B) Corrections

---

## Step 5: Legal and Contractual Inclusion Check

Use AskUserQuestion:

> **Step 4 of 5 — Legal and Contractual Drivers**
>
> Some controls must be included due to legal or contractual obligations regardless of
> whether a specific risk was identified. Review the following:
>
> | Control | Likely legal/contractual driver | Include? |
> |---|---|---|
> | A.5.31 | Applicable IS-related legislation register | Yes (LR) if any regulation applies |
> | A.5.34 | PII / privacy protection | Yes (LR) if PDPA, GDPR, or similar applies |
> | A.5.32 | Intellectual property rights | Yes (LR) for most organizations |
> | A.5.33 | Protection of records | Yes (LR) if records retention rules apply |
> | A.6.1 | Screening | Yes (LR/CR) if customer contracts require it |
> | A.6.6 | NDA agreements | Yes (CR) if confidential data is shared with third parties |
>
> Are there any controls currently marked N/A that should be included due to a specific
> legal or regulatory requirement in this client's industry?
> (e.g., PDPA, OJK regulations, sector-specific requirements)

Options:
- A) No changes needed — legal/contractual drivers already reflected
- B) Yes — add or change these: [list control + justification]

---

## Step 6: Validation — Completeness Check

Before writing the SoA, run a completeness check:

> **Step 5 of 5 — Completeness Validation**
>
> Running the Clause 6.1.3(c) check — verifying that no necessary controls were omitted.
>
> Cross-referencing:
> - Risk treatment controls selected → confirmed in SoA? [Y/N per control]
> - Controls with no risk driver but included as BP → justification present? [Y/N]
> - Controls marked NA → written justification present for each? [Y/N]
>
> **Results:**
> - Total applicable controls: [N] / 93
> - Total excluded controls (N/A): [N] / 93
> - Controls with no justification (must fix): [list any]
> - Controls marked IMP with Red annex rating (inconsistency): [list any]
>
> Issues found: [N]

If issues exist, use AskUserQuestion to surface them before writing:

> **[N] issues found before writing the SoA:**
>
> [List each issue, e.g.:]
> - A.8.15 (Logging): marked IMP but annex review rated it Red. Correct status to NIM.
> - A.5.7 (Threat intelligence): marked N/A but no justification text provided.
>   Add: "Organization does not have resources for dedicated threat intelligence;
>   threat info is consumed via MS Defender and NCSC advisories — included as BP."
>
> Fix these before I write the SoA?

Options:
- A) Apply corrections as suggested and write the SoA
- B) I'll correct them manually — list my corrections
- C) Ignore — write the SoA as-is (not recommended)

---

## Step 7: Produce the Statement of Applicability

```bash
DATE=$(date +%Y-%m-%d)
mkdir -p ./engagements
FILENAME="./engagements/${DATE}-${CLIENT:-client}-soa.md"
echo "Writing Statement of Applicability to $FILENAME"
```

Write the file with this structure:

---

```markdown
# Statement of Applicability
**Client:** [CLIENT]
**ISMS Scope:** [SCOPE from engagement brief]
**Date:** [TODAY]
**Version:** 1.0
**Prepared by:** GRC Consultant
**Approved by:** [Executive sponsor — to be signed]

**Source documents:**
- Risk Treatment Plan: [filename]
- Annex A Review: [filename]

---

## Summary

| Theme | Total | Applicable | Not Applicable | IMP | PAR | NIM |
|---|---|---|---|---|---|---|
| A.5 Organizational | 37 | [N] | [N] | [N] | [N] | [N] |
| A.6 People | 8 | [N] | [N] | [N] | [N] | [N] |
| A.7 Physical | 14 | [N] | [N] | [N] | [N] | [N] |
| A.8 Technological | 34 | [N] | [N] | [N] | [N] | [N] |
| **Total** | **93** | **[N]** | **[N]** | **[N]** | **[N]** | **[N]** |

**Justification breakdown (applicable controls):**
- Risk treatment (RT): [N] controls
- Legal/regulatory (LR): [N] controls
- Contractual (CR): [N] controls
- Best practice (BP): [N] controls

**Implementation readiness:**
- Fully implemented (IMP): [N] ([%])
- Partially implemented (PAR): [N] ([%]) — gaps being addressed in roadmap
- Not yet implemented (NIM): [N] ([%]) — planned in roadmap

---

## A.5 — Organizational Controls

| Control | Name | Applicable | Justification code | Justification detail | Implementation status | Implementing document |
|---|---|---|---|---|---|---|
| A.5.1 | Policies for information security | Yes | RT, BP | Selected to treat IA-01; required as organizational baseline | IMP | Information Security Policy v1.2 |
| A.5.2 | IS roles and responsibilities | Yes | RT, BP | Required to define ISMS ownership and accountability | PAR | IS Roles and Responsibilities document (draft) |
| A.5.3 | Segregation of duties | Yes | RT | Selected to treat IT-05 (privileged access) | NIM | To be implemented — see roadmap |
| A.5.4 | Management responsibilities | Yes | BP | Required for management commitment per Clause 5 | IMP | ISMS Manual Section 3 |
| A.5.5 | Contact with authorities | Yes | LR | Required to comply with [applicable regulation] | NIM | Authority contact register — not yet created |
| [continue all 37 A.5 controls] | | | | | | |

---

## A.6 — People Controls

| Control | Name | Applicable | Justification code | Justification detail | Implementation status | Implementing document |
|---|---|---|---|---|---|---|
| A.6.1 | Screening | Yes | RT, CR | Selected to treat PE-02; customer contract requires background checks | PAR | HR Recruitment Policy (screening section incomplete) |
| [continue all 8 A.6 controls] | | | | | | |

---

## A.7 — Physical Controls

| Control | Name | Applicable | Justification code | Justification detail | Implementation status | Implementing document |
|---|---|---|---|---|---|---|
| A.7.1 | Physical security perimeters | Yes | RT, BP | Selected to treat PH-01 (physical access) | IMP | Physical Security Policy; access control system in place |
| [continue all 14 A.7 controls] | | | | | | |

---

## A.8 — Technological Controls

| Control | Name | Applicable | Justification code | Justification detail | Implementation status | Implementing document |
|---|---|---|---|---|---|---|
| A.8.1 | User endpoint devices | Yes | RT, BP | Selected to treat PH-02 (device theft); MDM policy | PAR | Endpoint Security Policy; MDM partially deployed |
| [continue all 34 A.8 controls] | | | | | | |

---

## Excluded Controls (Not Applicable Register)

Each excluded control is listed here with a complete written justification.
This register must be reviewed and approved before the Stage 1 audit.

| Control | Name | Exclusion justification |
|---|---|---|
| A.8.25 | Secure development lifecycle | The organization does not develop software within the ISMS scope. All software used is procured from third-party vendors. This control is therefore not applicable. |
| [all N/A controls] | | |

---

## Version History

| Version | Date | Author | Changes |
|---|---|---|---|
| 1.0 | [TODAY] | GRC Consultant | Initial SoA — produced from risk treatment plan and annex review |

---

## Approval Sign-Off

This SoA must be reviewed and approved by the executive sponsor before the Stage 1 audit.

**ISMS Owner:** __________________ Date: __________
**Executive Sponsor:** __________________ Date: __________

---

*Generated by ISO27001AGENT — Statement of Applicability Skill*
*Based on ISO/IEC 27001:2022 Clause 6.1.3(d)*
```

---

After writing the file, tell the consultant:
- Path where the file was saved
- Count: applicable vs not-applicable controls (out of 93)
- Implementation readiness split: IMP / PAR / NIM
- Number of controls with no implementing document yet — these are the `/policy-gen` targets
- Any controls still marked NIM with a High or Critical risk attached — these are the urgent roadmap items
- Recommended next skill: `/roadmap`

**STATUS: DONE** — Statement of Applicability written. Recommended next skill: `/roadmap`
