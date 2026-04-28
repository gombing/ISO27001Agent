# ISO27001AGENT v1.0.0

AI-assisted ISO 27001:2022 consulting toolkit. Each skill is a structured workflow
that follows the ISO 27001 lifecycle — from client intake through to audit readiness.


---

## ISO 27001 Skills (use these for all GRC work)

### Session management — run these to save / restore across conversations

- `/engagement-save` — Save full engagement state to a checkpoint file → Resume later
- `/engagement-restore` — Load the latest checkpoint and resume exactly where you left off

### Monitoring — run at any point in the engagement

- `/isms-health` — Live ISMS health dashboard: 6 scored dimensions + overall RAG verdict → Health Report

### Engagement lifecycle — run in this order

- `/interview` — Client intake: 8 forcing questions → Engagement Brief document
- `/gap-assessment` — Mandatory clause review: Clauses 4–10 (29 items) → Gap Report
- `/annex-review` — Annex A control review: A.5–A.8 (93 controls) → Annex A RAG table
- `/risk-assessment` — Risk assessment: Clause 6.1.2 → Risk Register
- `/risk-treatment` — Risk treatment: Clause 6.1.3 → Risk Treatment Plan
- `/soa` — Statement of Applicability: all 93 Annex A controls → SoA document
- `/roadmap` — Implementation roadmap from gap + risk findings → Project Plan
- `/policy-gen` — Generate required documented information (Clause 7.5) → Policy templates
- `/internal-audit` — Internal audit planning and execution: Clause 9.2 → Audit Report
- `/management-review` — Management review agenda and minutes: Clause 9.3 → Signed Minutes
- `/audit-prep` — Stage 1 and Stage 2 audit readiness checklist → Readiness Report

---

## ISO 27001 Skill Routing

When the user's request matches an ISO 27001 consulting task, invoke the skill via the
Skill tool. The skill has structured Q&A workflows, clause-level checklists, and
document output. Always invoke the skill — do not answer ad-hoc.

**Run `/interview` before any other skill.** It creates the engagement brief that all
other skills load for client context.

Key routing rules:
- New client, first meeting, "start the engagement" → invoke `/interview`
- "Client intake", "onboarding a client", "new engagement" → invoke `/interview`
- "Gap assessment", "clause review", "how compliant are they" → invoke `/gap-assessment`
- "Annex A", "control review", "check the 93 controls" → invoke `/annex-review`
- "Risk assessment", "risk register", "assess risks", Clause 6.1.2 → invoke `/risk-assessment`
- "Risk treatment", "treat the risks", "control selection" → invoke `/risk-treatment`
- "Statement of Applicability", "SoA", "applicable controls" → invoke `/soa`
- "Implementation plan", "roadmap", "what do we fix first" → invoke `/roadmap`
- "Write a policy", "generate policy", "they need a policy for..." → invoke `/policy-gen`
- "Internal audit", "audit programme", "prepare for internal audit" → invoke `/internal-audit`
- "Management review", "MR agenda", "review minutes" → invoke `/management-review`
- "Are they ready for the audit", "Stage 1 readiness", "Stage 2 prep" → invoke `/audit-prep`
- "Save session", "save engagement", "end of session", "checkpoint" → invoke `/engagement-save`
- "Restore session", "resume engagement", "where did we leave off", "load context" → invoke `/engagement-restore`
- "ISMS health", "health check", "health dashboard", "status check", "where are we", "how is the ISMS" → invoke `/isms-health`

---

## Shared Infrastructure

- `lib/PREAMBLE.md` — shared client context loader included by every skill
- `iso27001requirments.md` — source of truth: all mandatory clauses and Annex A controls
- `engagements/` — all output documents land here (briefs, gap reports, risk registers, etc.)
