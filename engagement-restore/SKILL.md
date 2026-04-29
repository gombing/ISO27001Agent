---
version: 1.0.0
name: engagement-restore
description: |
  ISO27001AGENT Session Restore — loads the most recent engagement checkpoint and
  produces a full briefing so the consultant can resume exactly where they left off.
  Shows: active client, engagement phase, documents produced, outstanding actions,
  decisions made in prior sessions, blockers, and the next recommended skill.
  Run at the start of any session on an existing engagement.
  Use /engagement-save to create a checkpoint first.
allowed-tools:
  - Bash
  - Read
  - AskUserQuestion
triggers:
  - restore session
  - restore engagement
  - resume engagement
  - context restore
  - load engagement
  - resume session
  - what were we working on
  - where did we leave off
  - load context
---

# ISO27001AGENT — Engagement Restore

You are a **senior ISO 27001 consultant** reopening an engagement. Your job is to load
the most recent checkpoint and brief yourself so the next skill can be invoked immediately
— no wasted time re-establishing context.

**Why this matters:** Multi-session engagements are the norm in ISO 27001 consulting.
A certification project runs 3–9 months. Without a restore, the consultant has to
re-explain everything. A good restore means the next skill starts with full context.

---

## Step 1: Find All Saved Sessions

```bash
SESSIONS_DIR="./engagements/.sessions"
ENGAGEMENTS_DIR="./engagements"

if [ ! -d "$SESSIONS_DIR" ]; then
  echo "NO_SESSIONS: Sessions directory not found at $SESSIONS_DIR"
  echo "Run /engagement-save first to create a checkpoint."
  exit 0
fi

SESSION_COUNT=$(ls "$SESSIONS_DIR"/*.md 2>/dev/null | wc -l | tr -d ' ')

if [ "$SESSION_COUNT" -eq 0 ]; then
  echo "NO_SESSIONS: No saved sessions found in $SESSIONS_DIR"
  echo "Run /engagement-save first to create a checkpoint."
  exit 0
fi

echo "SESSIONS_FOUND: $SESSION_COUNT"
echo ""
echo "All saved sessions (newest first):"
ls -t "$SESSIONS_DIR"/*.md 2>/dev/null | while read f; do
  SESSION_DATE=$(grep -m1 "^session:" "$f" | sed 's/session: //')
  SESSION_CLIENT=$(grep -m1 "^client:" "$f" | sed 's/client: //')
  SESSION_PHASE=$(grep -m1 "^phase:" "$f" | sed 's/phase: //')
  SESSION_DONE=$(grep -m1 "^skills_done:" "$f" | sed 's/skills_done: //')
  echo "  $(basename $f)"
  echo "    Client: ${SESSION_CLIENT:-unknown} | Phase: ${SESSION_PHASE:-unknown} | Skills: ${SESSION_DONE:-?}/11"
  echo "    Saved: $SESSION_DATE"
  echo ""
done

LATEST_SESSION=$(ls -t "$SESSIONS_DIR"/*.md 2>/dev/null | head -1)
echo "LATEST_SESSION: $LATEST_SESSION"
```

If `NO_SESSIONS` is printed: tell the consultant no checkpoint exists and recommend
running `/engagement-save` at the end of the current session, or `/interview` if this
is a brand-new engagement. Stop here.

---

## Step 2: Load the Latest Checkpoint

Read the latest session file. Extract all fields.

```bash
LATEST_SESSION=$(ls -t "$SESSIONS_DIR"/*.md 2>/dev/null | head -1)

SESSION_DATE=$(grep -m1 "^session:" "$LATEST_SESSION" | sed 's/session: //')
CLIENT=$(grep -m1 "^client:" "$LATEST_SESSION" | sed 's/client: //')
PHASE=$(grep -m1 "^phase:" "$LATEST_SESSION" | sed 's/phase: //')
SKILLS_DONE=$(grep -m1 "^skills_done:" "$LATEST_SESSION" | sed 's/skills_done: //')
NEXT_SKILL=$(grep -m1 "^next_skill:" "$LATEST_SESSION" | sed 's/next_skill: //')

TODAY=$(date +%Y-%m-%d)
DAYS_SINCE=$(( ( $(date +%s) - $(date -j -f "%Y-%m-%d_%H%M%S" "${SESSION_DATE}" +%s 2>/dev/null || date -d "${SESSION_DATE/_/ }" +%s 2>/dev/null) ) / 86400 ))

echo "CLIENT:      $CLIENT"
echo "PHASE:       $PHASE"
echo "SKILLS_DONE: $SKILLS_DONE / 11"
echo "NEXT_SKILL:  $NEXT_SKILL"
echo "SAVED:       $SESSION_DATE ($DAYS_SINCE days ago)"
echo "TODAY:       $TODAY"
```

Print a context header:
```
── ENGAGEMENT RESTORE ── Client: [CLIENT] ── [TODAY] ──
```

---

## Step 3: Cross-Check Against Actual Documents

Re-scan `./engagements/` to verify the checkpoint still matches reality
(in case documents were added or deleted since the last save):

```bash
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

# Recompute current next skill from live documents
if   [ -z "$DOC_BRIEF" ];     then LIVE_NEXT="/interview"
elif [ -z "$DOC_GAP" ];       then LIVE_NEXT="/gap-assessment"
elif [ -z "$DOC_ANNEX" ];     then LIVE_NEXT="/annex-review"
elif [ -z "$DOC_RISK" ];      then LIVE_NEXT="/risk-assessment"
elif [ -z "$DOC_RTP" ];       then LIVE_NEXT="/risk-treatment"
elif [ -z "$DOC_SOA" ];       then LIVE_NEXT="/soa"
elif [ -z "$DOC_ROADMAP" ];   then LIVE_NEXT="/roadmap"
elif [ "$DOC_POLICIES" -eq 0 ] 2>/dev/null; then LIVE_NEXT="/policy-gen"
elif [ -z "$DOC_AUDIT" ];     then LIVE_NEXT="/internal-audit"
elif [ -z "$DOC_MR" ];        then LIVE_NEXT="/management-review"
elif [ -z "$DOC_READINESS" ]; then LIVE_NEXT="/audit-prep"
else                               LIVE_NEXT="Engagement complete"
fi

echo "LIVE_NEXT_SKILL: $LIVE_NEXT"

[ -n "$DOC_BRIEF" ]       && echo "LIVE [x] Brief"         || echo "LIVE [ ] Brief"
[ -n "$DOC_GAP" ]         && echo "LIVE [x] Gap"           || echo "LIVE [ ] Gap"
[ -n "$DOC_ANNEX" ]       && echo "LIVE [x] Annex"         || echo "LIVE [ ] Annex"
[ -n "$DOC_RISK" ]        && echo "LIVE [x] Risk Register" || echo "LIVE [ ] Risk Register"
[ -n "$DOC_RTP" ]         && echo "LIVE [x] RTP"           || echo "LIVE [ ] RTP"
[ -n "$DOC_SOA" ]         && echo "LIVE [x] SoA"           || echo "LIVE [ ] SoA"
[ -n "$DOC_ROADMAP" ]     && echo "LIVE [x] Roadmap"       || echo "LIVE [ ] Roadmap"
[ "$DOC_POLICIES" -gt 0 ] 2>/dev/null && echo "LIVE [x] Policies ($DOC_POLICIES)" || echo "LIVE [ ] Policies"
[ -n "$DOC_AUDIT" ]       && echo "LIVE [x] Audit Report"  || echo "LIVE [ ] Audit Report"
[ -n "$DOC_MR" ]          && echo "LIVE [x] MR Minutes"    || echo "LIVE [ ] MR Minutes"
[ -n "$DOC_READINESS" ]   && echo "LIVE [x] Readiness"     || echo "LIVE [ ] Readiness"
```

If `LIVE_NEXT` differs from the checkpoint's `NEXT_SKILL`: note that the live directory
is ahead of the checkpoint — use the live state as ground truth.

---

## Step 4: Deliver the Welcome-Back Briefing

Print the full engagement briefing to the console. Do not use AskUserQuestion for this —
just output it directly so the consultant can read it immediately.

```
══════════════════════════════════════════════════════════════
  WELCOME BACK — [CLIENT]
  Checkpoint from [SESSION_DATE] ([DAYS_SINCE] days ago)
══════════════════════════════════════════════════════════════

CLIENT CONTEXT
──────────────
  Client:               [CLIENT]
  Executive Sponsor:    [SPONSOR]
  Scope:                [SCOPE]
  Certification target: [TARGET_DATE]

ENGAGEMENT STATUS
─────────────────
  Phase:           [PHASE]
  Skills complete: [SKILLS_DONE] / 11
  Next skill:      [LIVE_NEXT_SKILL]

DOCUMENT INVENTORY
──────────────────
  [x] /interview        — [brief filename or "Done (date)"]
  [x] /gap-assessment   — [gap filename or "Done (date)"]
  [x] /annex-review     — [annex filename or "Done (date)"]
  [x] /risk-assessment  — [risk filename or "Done (date)"]
  [x] /risk-treatment   — [rtp filename or "Done (date)"]
  [x] /soa              — [soa filename or "Done (date)"]
  [x] /roadmap          — [roadmap filename or "Done (date)"]
  [x] /policy-gen       — [[N] policies generated]
  [x] /internal-audit   — [audit filename or "Done (date)"]
  [x] /management-review— [mr filename or "Done (date)"]
  [x] /audit-prep       — [readiness filename or "Done (date)"]
  [ ] skills not yet run shown with empty box

OUTSTANDING ACTIONS (from last session)
────────────────────────────────────────
  [print the "Outstanding Actions" section from the checkpoint file, or "None recorded"]

DECISIONS FROM PRIOR SESSIONS
──────────────────────────────
  [print the "Decisions Made This Session" section from the checkpoint file, or "None recorded"]

BLOCKERS / CONCERNS
────────────────────
  [print the "Blockers / Concerns" section from the checkpoint file, or "None"]

CONSULTANT NOTES
────────────────
  [print the "Consultant Notes" section from the checkpoint file, or "None"]

══════════════════════════════════════════════════════════════
  READY — run [LIVE_NEXT_SKILL] to continue.
══════════════════════════════════════════════════════════════
```

If `DAYS_SINCE` > 30: add a note — "It's been [N] days. Verify the certification target
date is still accurate and check for any changes in the client's context (staff changes,
regulatory updates, scope changes)."

If there are outstanding actions from the last session: highlight them prominently.
If there are open Major NCs (detectable from the audit report): flag them.

---

## Step 5: Handle Multiple Sessions (Optional)

If there are 2 or more saved sessions and the consultant might want to see history,
offer this before closing:

Use AskUserQuestion:

> **Session History**
>
> I found [SESSION_COUNT] saved sessions for this engagement.
> I've loaded the most recent one ([SESSION_DATE]).
>
> Would you like to:
> - A) Continue with the current state (recommended)
> - B) View all session history (shows decisions and actions across all sessions)
> - C) Load an older checkpoint (specify which one)

If A: proceed immediately.
If B: read all session files in `./engagements/.sessions/` and print a timeline:

```
SESSION HISTORY — [CLIENT]
──────────────────────────────────────────────────────────────
[date] — Phase: [phase] — Skills: [N]/11 — [N] actions outstanding
  Decisions: [key decisions from that session]
  Actions:   [actions from that session]

[date] — ...
```

If C: load the specified session file instead and re-run Step 4 with that data.

---

**STATUS: DONE** — Engagement restored. Run [LIVE_NEXT_SKILL] to continue.
