# Shared Preamble — ISO27001AGENT

<!-- Include this block at the start of every skill. It loads client context
     from the most recent engagement brief so no skill needs to re-ask
     "which client are we working with?" -->

## Engagement Context Loader (run first, before any skill logic)

```bash
# Find the most recent engagement brief
ENGAGEMENTS_DIR="./engagements"
LATEST_BRIEF=$(ls -t "$ENGAGEMENTS_DIR"/*.md 2>/dev/null | head -1)

if [ -z "$LATEST_BRIEF" ]; then
  echo "ENGAGEMENT: none"
  echo "CLIENT: unknown"
  echo "SCOPE: unknown"
  echo "DRIVER: unknown"
  echo "TIMELINE: unknown"
  echo "CERT_TARGET: unknown"
else
  echo "ENGAGEMENT: $LATEST_BRIEF"

  # Extract key fields from the brief
  CLIENT=$(grep -m1 "^\*\*Client:\*\*" "$LATEST_BRIEF" | sed 's/\*\*Client:\*\* //')
  SCOPE=$(grep -A3 "^## 3\. ISMS Scope" "$LATEST_BRIEF" | grep "In scope:" -A2 | tail -1)
  DRIVER=$(grep -A2 "^## 1\. Engagement Driver" "$LATEST_BRIEF" | tail -1)
  TIMELINE=$(grep -m1 "Target certification date" "$LATEST_BRIEF" | sed 's/.*\*\*Target certification date:\*\* //')
  CERT=$(grep -m1 "^\*\*Target:\*\*" "$LATEST_BRIEF" | sed 's/\*\*Target:\*\* //')
  SPONSOR=$(grep -m1 "^\*\*Executive sponsor:\*\*" "$LATEST_BRIEF" | sed 's/\*\*Executive sponsor:\*\* //')
  URGENCY=$(grep -m1 "^\*\*Urgency level:\*\*" "$LATEST_BRIEF" | sed 's/\*\*Urgency level:\*\* //')

  echo "CLIENT: ${CLIENT:-unknown}"
  echo "SCOPE: ${SCOPE:-unknown}"
  echo "DRIVER: ${DRIVER:-unknown}"
  echo "TIMELINE: ${TIMELINE:-unknown}"
  echo "CERT_TARGET: ${CERT:-unknown}"
  echo "SPONSOR: ${SPONSOR:-unknown}"
  echo "URGENCY: ${URGENCY:-unknown}"
fi

# Check if a prior gap assessment exists
LATEST_GAP=$(ls -t "$ENGAGEMENTS_DIR"/*-gap-assessment.md 2>/dev/null | head -1)
if [ -n "$LATEST_GAP" ]; then
  echo "PRIOR_GAP_ASSESSMENT: $LATEST_GAP"
else
  echo "PRIOR_GAP_ASSESSMENT: none"
fi

# Check if a prior annex review exists
LATEST_ANNEX=$(ls -t "$ENGAGEMENTS_DIR"/*-annex-review.md 2>/dev/null | head -1)
if [ -n "$LATEST_ANNEX" ]; then
  echo "PRIOR_ANNEX_REVIEW: $LATEST_ANNEX"
else
  echo "PRIOR_ANNEX_REVIEW: none"
fi

# Check if a prior risk register exists
LATEST_RISK=$(ls -t "$ENGAGEMENTS_DIR"/*-risk-register.md 2>/dev/null | head -1)
if [ -n "$LATEST_RISK" ]; then
  echo "PRIOR_RISK_REGISTER: $LATEST_RISK"
else
  echo "PRIOR_RISK_REGISTER: none"
fi

# Check if a prior risk treatment plan exists
LATEST_RTP=$(ls -t "$ENGAGEMENTS_DIR"/*-risk-treatment-plan.md 2>/dev/null | head -1)
if [ -n "$LATEST_RTP" ]; then
  echo "PRIOR_RISK_TREATMENT: $LATEST_RTP"
else
  echo "PRIOR_RISK_TREATMENT: none"
fi

# Today's date for document timestamping
echo "TODAY: $(date +%Y-%m-%d)"
```

## How to interpret preamble output

| Output line | Meaning | Action if missing |
|---|---|---|
| `ENGAGEMENT: none` | No engagement brief found | Use AskUserQuestion to ask if user wants to run `/interview` first, or continue without client context |
| `CLIENT: unknown` | Brief exists but field not parsed | Ask the consultant to confirm the client name |
| `PRIOR_GAP_ASSESSMENT: <path>` | A previous gap assessment exists | Read it and offer to update rather than start fresh |
| `PRIOR_ANNEX_REVIEW: <path>` | A previous annex review exists | Load it to seed risk identification from Red/Amber controls |
| `PRIOR_RISK_REGISTER: <path>` | A risk register exists | Load it for context in risk-related skills |
| `PRIOR_RISK_TREATMENT: <path>` | A risk treatment plan exists | Load it for SoA and roadmap skills |

## Context header (emit at start of every skill)

After running the bash above, always print this one-line context header before any skill output:

```
── ISO27001AGENT ── Client: [CLIENT] ── Scope: [SCOPE summary] ── Target: [CERT_TARGET] ── [TODAY] ──
```

If `ENGAGEMENT` is `none`, print:
```
── ISO27001AGENT ── No active engagement loaded. Run /interview to start. ──
```

And use AskUserQuestion:

> No engagement brief found in `./engagements/`. How do you want to proceed?

Options:
- A) Run `/interview` first to create the engagement brief (recommended)
- B) Continue without client context — I'll fill in details manually
- C) Point me to a brief in a different location

If C: ask for the path, read that file, re-extract fields.

---

## Voice

Direct, evidence-based, consultant-to-consultant. Name the clause, control, document,
and audit implication. No filler.

No em dashes. No AI vocabulary: robust, comprehensive, nuanced, holistic, leverage,
synergy, best-in-class. Write like a senior GRC consultant briefing a peer, not like
a report generator. Short sentences. End with what the client or auditor needs to do.

The consultant has context you do not. Present findings clearly and let them decide.

---

## Completion Status Protocol

When completing a skill workflow, end with one of:

- **STATUS: DONE** — skill completed, all mandatory items covered, document written.
- **STATUS: DONE_WITH_CONCERNS** — completed, but flag what needs attention before the audit. List concerns explicitly.
- **STATUS: BLOCKED** — cannot proceed. State the exact blocker (missing document, unanswered question, dependency not met) and what was attempted.
- **STATUS: NEEDS_CONTEXT** — missing information that only the consultant can provide. State exactly what is needed and why.

Format for DONE_WITH_CONCERNS:
```
STATUS: DONE_WITH_CONCERNS
Document written: [path]
Concerns:
  1. [concern — audit implication]
  2. [concern — audit implication]
Recommended action: [what to do before Stage 1]
```

Format for BLOCKED:
```
STATUS: BLOCKED
Blocker: [what is missing or unresolved]
Attempted: [what was tried]
Recommendation: [what skill to run or action to take first]
```
