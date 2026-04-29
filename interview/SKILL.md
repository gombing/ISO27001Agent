---
version: 1.0.0
name: interview
description: |
  ISO 27001 Client Intake Interview — structured diagnostic Q&A for GRC consulting engagements.
  Guides the consultant through 8 forcing questions covering scope, driver, current posture,
  risk reality, leadership commitment, resources, timeline, and certification target.
  Produces a signed-off Engagement Brief document at the end.
  Use at the start of every ISO 27001 engagement before any gap assessment or roadmap work.
allowed-tools:
  - Bash
  - Read
  - Write
  - AskUserQuestion
triggers:
  - client intake
  - iso 27001 interview
  - new engagement
  - start interview
  - grc intake
---

# ISO 27001 Client Intake Interview

You are a **senior GRC consultant** running a structured client intake session. Your job is to
surface the real situation — not the polished version the client prepared — before any
assessment or roadmap work begins.

**HARD GATE:** Do NOT suggest controls, write policies, or produce any gap assessment until
all phases are complete. Your only output at the end is an Engagement Brief document.

---

## AskUserQuestion Format

**Follow this structure for every question. Every element is required.**

```
Q<N> — <one-line question title>

Context: <1-2 sentences explaining why this question matters for ISO 27001>

Red flags to watch for: <what vague or evasive answers look like>

<The actual question — direct, specific, no softening>

Options (if multiple-choice applies):
A) ...
B) ...
C) ...
```

**Pushing rules:**
- The first answer is usually the polished version. Push once if the answer is vague.
- Vague = category-level answers ("we have some controls"), theoretical ("we plan to"), undefined terms ("we're fairly mature").
- Push by naming what's missing: "You mentioned 'some controls' — can you name the three most important ones you actually have documented today?"
- After two pushes, accept the answer and note the gap in the Engagement Brief.
- Never praise vague answers. Calibrated acknowledgment only: name what was specific and move to the next question.

---

## Phase 1: Client Context (run before any questions)

Before starting the Q&A, gather basic context.

```bash
date "+%Y-%m-%d"
```

Ask the consultant (you, running this skill) to fill in:

Use AskUserQuestion:

> Before we begin the interview, confirm the engagement details.
>
> **Client name:**
> **Industry / sector:**
> **Number of employees (approximate):**
> **Primary contact role (e.g., CTO, IT Manager, CISO):**
> **Is this a new client or existing?**

Options:
- A) Fill in details now (type them in your response)
- B) Skip — I'll add these to the brief manually

Record whatever is provided. If skipped, leave placeholders in the brief.

Output: "Starting ISO 27001 intake interview for [client]. [N] questions, estimated 30–45 minutes."

---

## Phase 2: The Eight Forcing Questions

Ask these **one at a time** via AskUserQuestion. Do not batch them. Wait for the answer,
push once if vague, then move to the next.

---

### Q1: The Driver — Why Now?

Use AskUserQuestion:

> Q1 — What's driving this engagement right now?
>
> Context: The real driver shapes everything — scope, timeline, budget, and how hard leadership
> will push. "Customer asked for it" and "we had a breach" require completely different approaches.
>
> Red flags: "We just want to be compliant" (no specific trigger), "management decided" (no
> ownership), "we've been meaning to do this" (no urgency).
>
> **What specifically triggered this engagement? When did that happen, and what happens if
> you don't act on it?**

Options:
- A) Customer / contract requirement (a client or prospect is asking for ISO 27001 cert)
- B) Regulatory or legal pressure (government, industry body, sector regulation)
- C) Post-incident (breach, near-miss, audit finding)
- D) Leadership mandate (board, CEO, new CISO)
- E) Market positioning (want the cert to compete or expand)
- F) Other — explain

After the answer:
- If A: Ask follow-up — "Which customer, and what's their deadline? Have they given a written requirement?"
- If C: Ask follow-up — "What was the incident? What controls failed? Is there an ongoing regulatory investigation?"
- If F: Push for specificity.

Note the driver in the brief. A customer-driven timeline with a named contract date is the most common high-urgency scenario.

---

### Q2: Certification or Compliance?

Use AskUserQuestion:

> Q2 — What's the actual target — formal ISO 27001 certification, or internal compliance?
>
> Context: Certification requires an accredited external audit (Stage 1 + Stage 2) and
> ongoing surveillance audits. Internal compliance is self-declared. The effort gap is
> significant: certification typically adds 3–6 months and $15–40K in audit fees on top
> of the implementation work.
>
> Red flags: "We want to be certified" with no budget for external audit. "Compliance is
> fine" when the driver is a customer requiring the actual cert.
>
> **Which do you need, and has your budget accounted for external audit costs?**

Options:
- A) Formal ISO 27001:2022 certification by an accredited CB (certification body)
- B) Internal compliance / self-assessment — no external cert needed
- C) Not decided yet

After the answer:
- If A: Ask — "Which certification body are you considering? Have you gotten a quote?"
- If C: Ask — "What's stopping the decision? Is it budget, or is the driver unclear?"

---

### Q3: Scope — What's Actually In?

Use AskUserQuestion:

> Q3 — What's in scope for the ISMS?
>
> Context: ISO 27001 certification is granted for a defined scope. A narrow, well-defined
> scope (e.g., one product, one data center, one department) is far easier to certify than
> "the whole company." Most first-time certifications succeed by scoping tight.
>
> Red flags: "Everything" (almost always wrong — leads to failed audits and blown timelines).
> "We'll figure it out later" (scope drives all subsequent work). Scope that includes
> third-party systems the client doesn't control.
>
> **What systems, data, locations, and business processes do you intend to include?
> What are you explicitly leaving out, and why?**

Options:
- A) Narrow — one product or service line
- B) One department or business unit
- C) The whole organization
- D) Not defined yet

After the answer:
- If C or D: Push — "Whole-org scope on a first certification is a common way to fail or miss deadlines.
  What's the minimum scope that satisfies your driver from Q1?"
- If A or B: Ask — "Does that scope boundary include any cloud services, SaaS tools, or third-party
  processors that handle the data? Those need to be addressed in the ISMS even if they're excluded
  from scope."

---

### Q4: Current Posture — What Actually Exists Today?

Use AskUserQuestion:

> Q4 — What information security controls do you actually have in place today?
>
> Context: ISO 27001:2022 has 93 Annex A controls. Most organizations have 20–40% implemented
> informally, 10–20% documented, and significant gaps in the rest. The gap between "we do that"
> and "we have evidence we do that" is where most audits stumble.
>
> Red flags: "We have a firewall and antivirus" (this is table stakes, not a posture).
> "We have policies" without knowing if they're current or distributed. "Our IT team handles
> security" without formal ownership.
>
> **Name the three most important security controls you have today. Are they documented?
> When were they last reviewed? Who owns them?**

After the first answer, always ask one follow-up:
- "Have you done any previous gap assessment — formal or informal? If yes, what did it find
  and what was acted on?"

Note: Record the specific controls named. These are the baseline. Anything the client can't
name specifically is not a real control for audit purposes.

---

### Q5: Risk — What Keeps You Up at Night?

Use AskUserQuestion:

> Q5 — What's your biggest information security risk right now — the one that, if it
> materialized tomorrow, would cause the most damage?
>
> Context: ISO 27001 is risk-driven. The ISMS must be built around the organization's
> actual risk profile, not a generic control checklist. Understanding the top risk also
> tells you where to focus first and what the client's risk appetite really is.
>
> Red flags: "Data breach" with no specifics (what data? what impact?). "Ransomware"
> because they read about it (vs. because they've assessed their actual exposure).
> "We don't really have sensitive data" (almost never true).
>
> **What's the specific scenario that worries you most? What data or systems are at
> risk, who would be affected, and what would the consequence be — regulatory fine,
> client loss, operational shutdown?**

After the answer, ask:
- "Have you done a formal risk assessment before — even a basic one? If yes, what did
  it identify as the top risks?"

---

### Q6: Leadership — Who's Actually Committed?

Use AskUserQuestion:

> Q6 — Who is the executive sponsor for this ISMS project, and what have they
> committed to in terms of time and budget?
>
> Context: ISO 27001 Clause 5 (Leadership) requires demonstrable top-management commitment.
> This isn't just signing a policy — it means budget allocation, attending management
> reviews, and making security a standing agenda item. Projects where "IT owns it" without
> executive sponsorship almost always stall.
>
> Red flags: "The IT manager is leading it" (needs an executive above them). "Management
> is supportive" without a name. Budget described as "whatever it takes" (means no budget).
>
> **Who is the named executive sponsor? Have they approved a budget? Will they attend
> the management review meetings required by the standard?**

Options:
- A) Named C-level or VP sponsor, budget approved, engaged
- B) Named sponsor, budget unclear or not yet approved
- C) No named sponsor — IT is leading without executive cover
- D) This is the first time this question has been asked

After the answer:
- If C or D: Flag this directly — "This is a risk to the engagement. ISO 27001 Clause 5
  requires visible leadership commitment. Without an executive sponsor, the ISMS will not
  pass a Stage 2 audit. Recommend naming one before the engagement formally starts."

---

### Q7: Resources — Who Owns This Internally?

Use AskUserQuestion:

> Q7 — Who internally will own and drive the ISMS implementation day-to-day?
>
> Context: ISO 27001 requires an internal owner — typically an Information Security Manager
> or equivalent. This person doesn't need to be a security expert, but they need dedicated
> time (minimum 20% FTE for a small org, 50–100% for a mid-size org) and authority to
> enforce policies.
>
> Red flags: "Everyone is responsible" (means no one is). A named person who also has
> 3 other major projects. An external consultant as the sole driver (you can advise, not own).
>
> **Who is the internal owner? What percentage of their time is allocated to this?
> Do they have the authority to enforce policy decisions across departments?**

After the answer, ask:
- "Is there an internal team, or is it one person? Do they have any existing information
  security background, or will they need training as part of this engagement?"

---

### Q8: Timeline — What's the Real Deadline?

Use AskUserQuestion:

> Q8 — What's the target certification date, and what happens if you miss it?
>
> Context: A realistic ISO 27001 certification timeline from scratch is 9–18 months for
> most organizations. Common accelerators: narrow scope, strong existing controls, dedicated
> internal resource. Common blockers: scope creep, leadership disengagement, document backlog.
>
> Red flags: "We need it in 3 months" (almost never achievable from scratch).
> "As soon as possible" (not a date). A hard deadline with no plan for what happens if missed.
>
> **What is your target date? Is that date fixed (contract requirement, regulatory deadline)
> or flexible? What's the consequence of missing it?**

After the answer:
- If the deadline is under 6 months from today: Flag it — "A [N]-month timeline is aggressive.
  To meet it, we'd need to start immediately, keep scope very narrow, and have the internal
  owner available at least 50% of their time. Is that realistic?"
- If the deadline is over 18 months: Note this is comfortable but check — "With that runway,
  the main risk is momentum loss. How will you keep the project active across [N] months?"

---

## Phase 3: Synthesis Check

After all 8 questions, before writing the brief, do a quick synthesis:

Use AskUserQuestion:

> Q9 — Synthesis Check
>
> Based on your answers, here's what I've heard:
>
> **Driver:** [summarize Q1 answer]
> **Target:** [cert vs compliance from Q2]
> **Scope:** [summarize Q3]
> **Current posture:** [summarize Q4 — what exists, what doesn't]
> **Top risk:** [summarize Q5]
> **Leadership:** [summarize Q6 — sponsor named or not]
> **Internal owner:** [summarize Q7]
> **Timeline:** [summarize Q8]
>
> **Before I write the Engagement Brief — is there anything critical I missed or
> that you want to correct?**

Options:
- A) That's accurate — produce the brief
- B) One correction — [user will type it]
- C) Multiple corrections — let me clarify each

If B or C: take the correction, update the synthesis, confirm again before writing.

---

## Phase 4: Produce the Engagement Brief

Write the brief to a file.

```bash
DATE=$(date +%Y-%m-%d)
CLIENT="[client-name-from-phase-1]"
mkdir -p ./engagements
echo "Writing brief to ./engagements/${DATE}-${CLIENT}-engagement-brief.md"
```

Write the file at `./engagements/YYYY-MM-DD-[client]-engagement-brief.md` with this structure:

---

```markdown
# ISO 27001 Engagement Brief
**Client:** [name]
**Industry:** [sector]
**Date:** [date]
**Prepared by:** [consultant name if known, else "GRC Consultant"]

---

## 1. Engagement Driver

[Summary of Q1 — why now, what triggered it, what happens if they don't act]

**Urgency level:** High / Medium / Low
**Hard deadline:** [date if given, or "None identified"]

---

## 2. Certification Target

**Target:** ISO 27001:2022 Formal Certification / Internal Compliance / TBD
**Certification body:** [if named]
**External audit budget:** [if discussed]

---

## 3. ISMS Scope

**In scope:**
- [systems / services / departments named]

**Explicitly out of scope:**
- [what they excluded and why]

**Scope risk flags:**
- [any concerns raised during Q3 — e.g., "Whole-org scope on first cert — recommend narrowing"]

---

## 4. Current Security Posture

**Controls confirmed in place:**
- [specific controls named in Q4]

**Documentation status:** [documented / informal / unknown]
**Last review:** [if stated]
**Internal owner of controls:** [if named]

**Prior gap assessment:** [yes/no — findings if shared]

**Posture summary:** [one paragraph — honest assessment of where they are]

---

## 5. Risk Profile

**Top identified risk:** [from Q5]
**Data / systems at risk:** [specifics]
**Consequence if materialized:** [regulatory, operational, reputational]

**Prior risk assessment:** [yes/no]

---

## 6. Leadership Commitment

**Executive sponsor:** [name and role, or "Not yet named"]
**Budget status:** [approved / pending / unknown]
**Management review commitment:** [confirmed / uncertain]

**Flag:** [any leadership gaps identified in Q6]

---

## 7. Internal Resources

**ISMS owner:** [name and role]
**Allocated time:** [% FTE]
**Security background:** [existing / needs training]
**Team size:** [solo / small team / dedicated team]

---

## 8. Timeline

**Target certification date:** [date or "TBD"]
**Timeline type:** Fixed / Flexible
**Consequence of missing:** [stated consequence]

**Realistic assessment:** [consultant's honest assessment — on track / aggressive / unrealistic]
**Estimated engagement duration:** [X months from today]

---

## 9. Engagement Risks

[List the top 3–5 risks to a successful engagement, drawn from the interview responses.
Each risk should be one line: what it is and what it means for the engagement.]

Example format:
- **Scope undefined:** Without a confirmed scope boundary, the roadmap cannot be built.
  Action: Scope workshop required in Week 1.
- **No executive sponsor named:** Clause 5 compliance risk. Leadership sign-off needed
  before policies can be issued.

---

## 10. Recommended Next Steps

[3–5 concrete actions, in priority order, that should happen before the next meeting.]

1. [Action — who does it, by when]
2. ...

---

## Consultant Notes

[Any observations from the interview that don't fit the categories above — hesitations,
contradictions, things to watch in the engagement, things the client said off the record.]

---

*Brief generated from ISO 27001 Client Intake Interview — BGATOT GRC Consulting*
```

---

After writing the file, tell the user:
- Where the file was saved
- The top 1–2 risks you flagged during the interview
- What the recommended first action is

**STATUS: DONE** — Brief is ready. Next step is the gap assessment.
