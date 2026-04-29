---
version: 1.0.0
name: engagement-save
description: |
  ISO27001AGENT Session Checkpoint — saves the full state of an active consulting
  engagement to a dated session file so work can be resumed in a future conversation.
  Captures: active client, all documents produced, current engagement phase,
  outstanding actions, next recommended skill, and consultant notes.
  Run any time you are ending a session or before switching clients.
  Use /engagement-restore to resume.
allowed-tools:
  - Bash
  - Read
  - Write
  - AskUserQuestion
triggers:
  - save session
  - save engagement
  - checkpoint
  - end of session
  - context save
  - save my progress
  - save context
---

# ISO27001AGENT — Engagement Save

You are a **senior ISO 27001 consultant** saving a session checkpoint so the engagement
can be resumed accurately in a future conversation. Your job is to produce a complete,
self-contained snapshot of where this engagement stands right now.

**Why this matters:** Claude Code has a context window. Without a checkpoint, the next
session starts cold — no client, no phase, no memory of what was built. A good checkpoint
means the next session picks up in 10 seconds, not 10 minutes.

---

## Step 1: Scan the Engagement Directory

```bash
ENGAGEMENTS_DIR="./engagements"
SESSIONS_DIR="./engagements/.sessions"
mkdir -p "$SESSIONS_DIR"

# Detect active client from most recent engagement brief
LATEST_BRIEF=$(ls -t "$ENGAGEMENTS_DIR"/*.md 2>/dev/null \
  | grep -v "gap-assessment\|annex-review\|risk-register\|risk-treatment\|soa\|roadmap\|policy\|audit\|review" \
  | head -1)
CLIENT=$(grep -m1 "^\*\*Client:\*\*" "$LATEST_BRIEF" 2>/dev/null | sed 's/\*\*Client:\*\* //')
SPONSOR=$(grep -m1 "^\*\*Executive sponsor:\*\*" "$LATEST_BRIEF" 2>/dev/null | sed 's/\*\*Executive sponsor:\*\* //')
SCOPE=$(grep -m1 "^\*\*Scope:\*\*" "$LATEST_BRIEF" 2>/dev/null | sed 's/\*\*Scope:\*\* //')
TARGET_DATE=$(grep -m1 "target\|certification\|audit" "$LATEST_BRIEF" 2>/dev/null | head -1 | sed 's/.*: //')

# Detect all produced documents
DOC_BRIEF=$(ls -t "$ENGAGEMENTS_DIR"/*.md 2>/dev/null | grep -v "gap-assessment\|annex-review\|risk-register\|risk-treatment\|soa\|roadmap\|policy\|audit\|review" | head -1)
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

# Compute phase from what exists
SKILLS_DONE=0
[ -n "$DOC_BRIEF" ]    && SKILLS_DONE=$((SKILLS_DONE+1))
[ -n "$DOC_GAP" ]      && SKILLS_DONE=$((SKILLS_DONE+1))
[ -n "$DOC_ANNEX" ]    && SKILLS_DONE=$((SKILLS_DONE+1))
[ -n "$DOC_RISK" ]     && SKILLS_DONE=$((SKILLS_DONE+1))
[ -n "$DOC_RTP" ]      && SKILLS_DONE=$((SKILLS_DONE+1))
[ -n "$DOC_SOA" ]      && SKILLS_DONE=$((SKILLS_DONE+1))
[ -n "$DOC_ROADMAP" ]  && SKILLS_DONE=$((SKILLS_DONE+1))
[ "$DOC_POLICIES" -gt 0 ] 2>/dev/null && SKILLS_DONE=$((SKILLS_DONE+1))
[ -n "$DOC_AUDIT" ]    && SKILLS_DONE=$((SKILLS_DONE+1))
[ -n "$DOC_MR" ]       && SKILLS_DONE=$((SKILLS_DONE+1))
[ -n "$DOC_READINESS" ] && SKILLS_DONE=$((SKILLS_DONE+1))

# Determine current engagement phase
if   [ -n "$DOC_READINESS" ]; then PHASE="Phase 4 — Audit Ready"
elif [ -n "$DOC_AUDIT" ];     then PHASE="Phase 4 — Verification (post-audit)"
elif [ -n "$DOC_ROADMAP" ];   then PHASE="Phase 3 — Implementation"
elif [ -n "$DOC_SOA" ];       then PHASE="Phase 2 — Planning (SoA done, roadmap pending)"
elif [ -n "$DOC_RTP" ];       then PHASE="Phase 2 — Planning (RTP done)"
elif [ -n "$DOC_RISK" ];      then PHASE="Phase 2 — Planning (risk register done)"
elif [ -n "$DOC_ANNEX" ];     then PHASE="Phase 1 — Foundation (annex review done)"
elif [ -n "$DOC_GAP" ];       then PHASE="Phase 1 — Foundation (gap assessment done)"
elif [ -n "$DOC_BRIEF" ];     then PHASE="Phase 1 — Foundation (interview done)"
else                               PHASE="Not started"
fi

# Determine next recommended skill
if   [ -z "$DOC_BRIEF" ];     then NEXT_SKILL="/interview"
elif [ -z "$DOC_GAP" ];       then NEXT_SKILL="/gap-assessment"
elif [ -z "$DOC_ANNEX" ];     then NEXT_SKILL="/annex-review"
elif [ -z "$DOC_RISK" ];      then NEXT_SKILL="/risk-assessment"
elif [ -z "$DOC_RTP" ];       then NEXT_SKILL="/risk-treatment"
elif [ -z "$DOC_SOA" ];       then NEXT_SKILL="/soa"
elif [ -z "$DOC_ROADMAP" ];   then NEXT_SKILL="/roadmap"
elif [ "$DOC_POLICIES" -eq 0 ] 2>/dev/null; then NEXT_SKILL="/policy-gen"
elif [ -z "$DOC_AUDIT" ];     then NEXT_SKILL="/internal-audit"
elif [ -z "$DOC_MR" ];        then NEXT_SKILL="/management-review"
elif [ -z "$DOC_READINESS" ]; then NEXT_SKILL="/audit-prep"
else                               NEXT_SKILL="Engagement complete — prepare for certification audit"
fi

NOW=$(date +%Y-%m-%d_%H%M%S)
TODAY=$(date +%Y-%m-%d)
TIME=$(date +%H:%M)

echo "CLIENT:       ${CLIENT:-unknown}"
echo "SPONSOR:      ${SPONSOR:-unknown}"
echo "PHASE:        $PHASE"
echo "SKILLS_DONE:  $SKILLS_DONE / 11"
echo "NEXT_SKILL:   $NEXT_SKILL"
echo "NOW:          $NOW"
echo ""
echo "DOCUMENTS:"
[ -n "$DOC_BRIEF" ]       && echo "  [x] Engagement Brief:          $(basename $DOC_BRIEF)"    || echo "  [ ] Engagement Brief"
[ -n "$DOC_GAP" ]         && echo "  [x] Gap Assessment:            $(basename $DOC_GAP)"      || echo "  [ ] Gap Assessment"
[ -n "$DOC_ANNEX" ]       && echo "  [x] Annex A Review:            $(basename $DOC_ANNEX)"    || echo "  [ ] Annex A Review"
[ -n "$DOC_RISK" ]        && echo "  [x] Risk Register:             $(basename $DOC_RISK)"     || echo "  [ ] Risk Register"
[ -n "$DOC_RTP" ]         && echo "  [x] Risk Treatment Plan:       $(basename $DOC_RTP)"      || echo "  [ ] Risk Treatment Plan"
[ -n "$DOC_SOA" ]         && echo "  [x] Statement of Applicability:$(basename $DOC_SOA)"      || echo "  [ ] Statement of Applicability"
[ -n "$DOC_ROADMAP" ]     && echo "  [x] Roadmap:                   $(basename $DOC_ROADMAP)"  || echo "  [ ] Roadmap"
[ "$DOC_POLICIES" -gt 0 ] 2>/dev/null && echo "  [x] Policies: $DOC_POLICIES document(s)" || echo "  [ ] Policies (none generated)"
[ -n "$DOC_AUDIT" ]       && echo "  [x] Internal Audit Report:     $(basename $DOC_AUDIT)"   || echo "  [ ] Internal Audit Report"
[ -n "$DOC_MR" ]          && echo "  [x] Management Review Minutes: $(basename $DOC_MR)"      || echo "  [ ] Management Review Minutes"
[ -n "$DOC_READINESS" ]   && echo "  [x] Audit Readiness Report:    $(basename $DOC_READINESS)" || echo "  [ ] Audit Readiness Report"
```

Print a context header:
```
── ENGAGEMENT SAVE ── Client: [CLIENT] ── [TODAY] [TIME] ──
```

---

## Step 2: Capture Outstanding Items and Notes

Use AskUserQuestion:

> **Session Checkpoint — [CLIENT]**
>
> I've scanned the engagement directory. Here's what I found:
>
> **Current phase:** [PHASE]
> **Skills completed:** [SKILLS_DONE] / 11
> **Next recommended skill:** [NEXT_SKILL]
>
> **Documents produced:**
> [print the document checklist from Step 1]
>
> Before I write the checkpoint, tell me:
>
> 1. **Outstanding actions:** Any open action items or agreed next steps from this session?
>    (e.g., "Client to provide asset inventory by Friday", "Revisit risk treatment for IA-03")
>
> 2. **Decisions made this session:** Any important decisions or context the next session
>    should know about?
>    (e.g., "Scope narrowed to HQ only — remote offices excluded", "Certification target moved to Q3")
>
> 3. **Blockers / concerns:** Anything that's blocking progress or needs to be flagged?
>    (e.g., "Waiting on IT to confirm cloud asset list", "MD travel — no availability until month end")
>
> 4. **Notes for next session:** Anything else the next consultant session should know?
>    (optional — type "none" to skip)

Options:
- A) Provide answers above
- B) Quick save — skip notes, save document state only

---

## Step 3: Write the Session Checkpoint File

```bash
SESSION_FILE="$SESSIONS_DIR/${NOW}-${CLIENT:-client}-session.md"
echo "Writing checkpoint to $SESSION_FILE"
```

Write the checkpoint file using this template:

```markdown
---
session: [NOW]
client: [CLIENT]
phase: [PHASE]
skills_done: [SKILLS_DONE]
next_skill: [NEXT_SKILL]
saved_by: ISO27001AGENT
---

# Engagement Checkpoint — [CLIENT]
**Saved:** [TODAY] at [TIME]
**Phase:** [PHASE]
**Progress:** [SKILLS_DONE] / 11 skills complete

---

## Client Context

| Field | Value |
|---|---|
| Client | [CLIENT] |
| Executive Sponsor | [SPONSOR] |
| Scope | [SCOPE] |
| Certification target | [TARGET_DATE] |

---

## Engagement Document Inventory

| Skill | Document | Status |
|---|---|---|
| /interview | [DOC_BRIEF filename or —] | [Done / Pending] |
| /gap-assessment | [DOC_GAP filename or —] | [Done / Pending] |
| /annex-review | [DOC_ANNEX filename or —] | [Done / Pending] |
| /risk-assessment | [DOC_RISK filename or —] | [Done / Pending] |
| /risk-treatment | [DOC_RTP filename or —] | [Done / Pending] |
| /soa | [DOC_SOA filename or —] | [Done / Pending] |
| /roadmap | [DOC_ROADMAP filename or —] | [Done / Pending] |
| /policy-gen | [[DOC_POLICIES] documents] | [Done / Pending] |
| /internal-audit | [DOC_AUDIT filename or —] | [Done / Pending] |
| /management-review | [DOC_MR filename or —] | [Done / Pending] |
| /audit-prep | [DOC_READINESS filename or —] | [Done / Pending] |

---

## Outstanding Actions

[List actions captured in Step 2, or "None recorded"]

---

## Decisions Made This Session

[List decisions captured in Step 2, or "None recorded"]

---

## Blockers / Concerns

[List blockers captured in Step 2, or "None"]

---

## Consultant Notes

[Notes captured in Step 2, or "None"]

---

## Next Session

**Recommended next skill:** [NEXT_SKILL]
**To resume:** Run `/engagement-restore` at the start of the next session.

---
*Checkpoint created by ISO27001AGENT — /engagement-save*
```

---

## Step 4: Confirm Save

After writing the file, tell the consultant:

```
── CHECKPOINT SAVED ──

Client:      [CLIENT]
Phase:       [PHASE]
Progress:    [SKILLS_DONE] / 11 skills complete
Saved to:    [SESSION_FILE]

Next session: run /engagement-restore to resume.
Next skill:   [NEXT_SKILL]
```

If there are outstanding actions, list them as a reminder.
If there are open Major NCs, flag: "Open Major NCs must be closed before Stage 2 audit."

**STATUS: DONE** — Checkpoint saved. Resume with `/engagement-restore`.
