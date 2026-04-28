---
name: policy-gen
description: |
  ISO 27001:2022 Policy Generator — produces required documented information per Clause 7.5.
  Reads the SoA to identify which controls need supporting policies and procedures.
  Asks the consultant which documents to generate, then produces complete policy templates
  pre-filled with the client's name, scope, and IS context from the engagement brief.
  Each policy follows ISO 27001 documented information requirements: title, owner,
  version, review date, approval signature block.
  Run after /soa. Can be run multiple times — once per policy needed.
allowed-tools:
  - Bash
  - Read
  - Write
  - AskUserQuestion
triggers:
  - policy gen
  - generate policy
  - write a policy
  - policy template
  - documented information
  - they need a policy for
  - clause 7.5
---

# ISO 27001:2022 Policy Generator (Clause 7.5)

You are a **senior ISO 27001 documentation specialist** producing required documented
information. Your job is to generate complete, audit-ready policy templates tailored
to the client's context — not generic boilerplate that an auditor can see was downloaded
off the internet.

**What makes a policy audit-ready:**
- Client name, scope, and context throughout (not "[COMPANY NAME]" placeholders)
- Specific enough to be enforceable — vague policies fail audits
- Signed and dated approval block
- Version control section
- Aligned to the Annex A controls it implements

**HARD GATE:** Do not generate a policy without loading the engagement brief first.
Generic policies unconnected to the client's scope and risk profile are a red flag in Stage 2.

---

## Required Documented Information — ISO 27001:2022 Reference

ISO 27001:2022 mandates the following documented information as minimum:

| # | Document | Clause / Control | Mandatory? |
|---|---|---|---|
| D01 | Information Security Policy | 5.2 | Mandatory |
| D02 | ISMS Scope Document | 4.3 | Mandatory |
| D03 | Risk Assessment Methodology | 6.1.2 | Mandatory |
| D04 | Risk Register | 6.1.2 | Mandatory |
| D05 | Risk Treatment Plan | 6.1.3 | Mandatory |
| D06 | Statement of Applicability | 6.1.3(d) | Mandatory |
| D07 | IS Objectives | 6.2 | Mandatory |
| D08 | Competence Records | 7.2 | Mandatory |
| D09 | Awareness Training Records | 7.3 | Mandatory |
| D10 | Internal Audit Programme | 9.2 | Mandatory |
| D11 | Internal Audit Results | 9.2 | Mandatory |
| D12 | Management Review Minutes | 9.3 | Mandatory |
| D13 | Nonconformity and Corrective Action Records | 10.2 | Mandatory |
| D14 | Access Control Policy | A.5.15 | If A.5.15 applicable |
| D15 | Asset Management Policy | A.5.9, A.5.12 | If applicable |
| D16 | Acceptable Use Policy | A.5.10 | If applicable |
| D17 | Information Classification Scheme | A.5.12 | If applicable |
| D18 | Supplier Security Policy | A.5.19, A.5.20 | If applicable |
| D19 | Incident Response Procedure | A.5.24–A.5.27 | If applicable |
| D20 | Business Continuity / ICT Continuity Plan | A.5.29, A.5.30 | If applicable |
| D21 | Password and Authentication Policy | A.5.17, A.8.5 | If applicable |
| D22 | Patch and Vulnerability Management Procedure | A.8.8 | If applicable |
| D23 | Backup Policy | A.8.13 | If applicable |
| D24 | Remote Working Policy | A.6.7 | If A.6.7 applicable |
| D25 | Physical Security Policy | A.7.1–A.7.14 | If applicable |
| D26 | Change Management Procedure | A.8.32 | If applicable |
| D27 | Cryptography Policy | A.8.24 | If applicable |
| D28 | Secure Development Policy | A.8.25–A.8.29 | If software dev in scope |
| D29 | Clear Desk and Clear Screen Policy | A.7.7 | If applicable |
| D30 | Data Retention and Deletion Policy | A.8.10 | If applicable |

---

## Step 1: Load Engagement Context

```bash
ENGAGEMENTS_DIR="./engagements"

LATEST_BRIEF=$(ls -t "$ENGAGEMENTS_DIR"/*.md 2>/dev/null \
  | grep -v "gap-assessment\|annex-review\|risk-register\|risk-treatment\|soa\|roadmap\|policy" \
  | head -1)
CLIENT=$(grep -m1 "^\*\*Client:\*\*" "$LATEST_BRIEF" 2>/dev/null | sed 's/\*\*Client:\*\* //')
INDUSTRY=$(grep -m1 "^\*\*Industry:\*\*" "$LATEST_BRIEF" 2>/dev/null | sed 's/\*\*Industry:\*\* //')
SCOPE=$(grep -A3 "^## 3\. ISMS Scope" "$LATEST_BRIEF" 2>/dev/null | grep "In scope:" -A1 | tail -1)
SPONSOR=$(grep -m1 "^\*\*Executive sponsor:\*\*" "$LATEST_BRIEF" 2>/dev/null | sed 's/\*\*Executive sponsor:\*\* //')

SOA=$(ls -t "$ENGAGEMENTS_DIR"/*-soa.md 2>/dev/null | head -1)

echo "CLIENT: ${CLIENT:-unknown}"
echo "INDUSTRY: ${INDUSTRY:-unknown}"
echo "SCOPE: ${SCOPE:-unknown}"
echo "SPONSOR: ${SPONSOR:-unknown}"
[ -n "$SOA" ] && echo "SOA: $SOA" || echo "SOA: none"
echo "TODAY: $(date +%Y-%m-%d)"
```

Print context header:
```
── POLICY GENERATOR ── Client: [CLIENT] ── [TODAY] ──
```

If SOA exists, read it to determine which controls are applicable — only generate policies
for controls included in the SoA. Skip policies for excluded controls.

---

## Step 2: Select Policies to Generate

Use AskUserQuestion:

> **Which policies do you want to generate this session?**
>
> Mandatory documents (must exist before Stage 1):
> - D01 Information Security Policy
> - D07 IS Objectives
> - D14 Access Control Policy
> - D18 Supplier Security Policy
> - D19 Incident Response Procedure
>
> Common topic-specific policies:
> - D15 Asset Management Policy
> - D16 Acceptable Use Policy
> - D21 Password and Authentication Policy
> - D22 Patch and Vulnerability Management Procedure
> - D23 Backup Policy
> - D24 Remote Working Policy
> - D25 Physical Security Policy
> - D26 Change Management Procedure
> - D27 Cryptography Policy
> - D30 Data Retention and Deletion Policy
>
> Type the document numbers to generate (e.g., "D01, D14, D21")
> or type "ALL MANDATORY" to generate D01 + D07 + D14 + D18 + D19.

Generate each requested policy one at a time. Write each to its own file.

---

## Step 3: Generate Each Policy

For each requested policy, produce a complete document using the template below.
Substitute [CLIENT], [INDUSTRY], [SCOPE], [SPONSOR], and [TODAY] throughout.
Do not leave placeholder brackets in the output — fill every field from the context loaded.

---

### TEMPLATE: Information Security Policy (D01)

```bash
FILENAME="./engagements/policies/${CLIENT:-client}-information-security-policy.md"
mkdir -p ./engagements/policies
echo "Writing to $FILENAME"
```

```markdown
# Information Security Policy
**Organisation:** [CLIENT]
**Document ID:** IS-POL-001
**Version:** 1.0
**Date:** [TODAY]
**Owner:** ISMS Owner
**Approved by:** [SPONSOR]
**Next review date:** [TODAY + 12 months]

---

## 1. Purpose

[CLIENT] is committed to protecting the confidentiality, integrity, and availability
of its information and information systems. This policy establishes the intent and
direction for information security management within [CLIENT].

## 2. Scope

This policy applies to all information assets within the ISMS scope: [SCOPE].
It covers all personnel (employees, contractors, third parties) with access to
[CLIENT]'s information systems and data.

## 3. Information Security Objectives

[CLIENT] will:
- Protect information from unauthorized access, disclosure, modification, and destruction
- Comply with applicable legal, regulatory, and contractual obligations
- Manage information security risks to an acceptable level
- Maintain and continually improve the ISMS

Specific IS objectives are documented separately (IS-DOC-007).

## 4. Policy Statements

**4.1 Leadership Commitment**
Top management is committed to providing resources, direction, and visible support
for information security across all operations.

**4.2 Risk-Based Approach**
Information security decisions are based on a formal risk assessment process.
Risks are identified, assessed, and treated according to the Risk Management Policy.

**4.3 Compliance**
All personnel must comply with this policy and supporting topic-specific policies.
Non-compliance may result in disciplinary action up to and including termination.

**4.4 Continual Improvement**
The ISMS will be reviewed at least annually through internal audit and management
review to ensure it remains effective and aligned with business objectives.

## 5. Responsibilities

| Role | Responsibility |
|---|---|
| Executive Sponsor | Approve this policy; provide resources; attend management reviews |
| ISMS Owner | Maintain the ISMS; report on performance; manage the audit programme |
| All Staff | Read, understand, and comply with this policy and all IS procedures |
| IT | Implement and maintain technical controls as directed by the ISMS |

## 6. Supporting Policies

This policy is supported by topic-specific policies including:
- Access Control Policy (IS-POL-002)
- Acceptable Use Policy (IS-POL-003)
- Incident Response Procedure (IS-PRO-001)
- [list applicable supporting policies]

## 7. Review

This policy will be reviewed annually or following significant changes to
[CLIENT]'s operations, legal obligations, or threat environment.

---

## Approval

| Role | Name | Signature | Date |
|---|---|---|---|
| Executive Sponsor | [SPONSOR] | __________________ | |
| ISMS Owner | | __________________ | |

---

## Version History

| Version | Date | Author | Changes |
|---|---|---|---|
| 1.0 | [TODAY] | GRC Consultant | Initial issue |
```

---

### TEMPLATE: Access Control Policy (D14)

```bash
FILENAME="./engagements/policies/${CLIENT:-client}-access-control-policy.md"
```

```markdown
# Access Control Policy
**Organisation:** [CLIENT]
**Document ID:** IS-POL-002
**Version:** 1.0
**Date:** [TODAY]
**Owner:** IT Manager / ISMS Owner
**Approved by:** [SPONSOR]
**Next review date:** [TODAY + 12 months]
**Implements:** A.5.15, A.5.16, A.5.17, A.5.18, A.8.2, A.8.3, A.8.5

---

## 1. Purpose

To ensure that access to [CLIENT]'s information and systems is granted on the
principle of least privilege, is formally managed throughout the access lifecycle,
and is revoked promptly when no longer required.

## 2. Scope

All information systems, applications, and data within the ISMS scope: [SCOPE].
Applies to all users — employees, contractors, and third parties.

## 3. Access Provisioning

- Access rights are granted based on job role and business need (least privilege)
- All access requests must be formally approved by the relevant system owner
- Privileged access (admin rights) requires additional justification and approval
- Third-party and contractor access is time-limited and scoped to engagement needs

## 4. Authentication

- All users must have a unique, individual account — no shared accounts permitted
- Passwords must comply with the Password Policy (minimum 12 characters, complexity enforced)
- Multi-factor authentication (MFA) is mandatory for:
  - Remote access to internal systems
  - Cloud administration consoles
  - Systems holding sensitive or regulated data
  - Email accounts

## 5. Access Review

- Access rights will be reviewed quarterly by system owners
- Any access rights no longer required must be removed within 5 business days
- Privileged accounts must be reviewed monthly

## 6. Access Revocation

- Upon employment termination, all access must be revoked on the last working day
- The IT team must be notified at least 24 hours before the termination date
- Revocation must be confirmed and recorded in the offboarding checklist

## 7. Responsibilities

| Role | Responsibility |
|---|---|
| IT Manager | Implement and maintain access controls; action provisioning and revocation requests |
| System Owners | Approve access requests for their systems; conduct quarterly access reviews |
| HR | Notify IT of new starters, role changes, and leavers |
| All Users | Use only the access they are granted; report suspected unauthorized access |

---

## Approval

| Role | Name | Signature | Date |
|---|---|---|---|
| Executive Sponsor | [SPONSOR] | __________________ | |
| ISMS Owner | | __________________ | |

---

## Version History

| Version | Date | Author | Changes |
|---|---|---|---|
| 1.0 | [TODAY] | GRC Consultant | Initial issue |
```

---

### TEMPLATE: Incident Response Procedure (D19)

```bash
FILENAME="./engagements/policies/${CLIENT:-client}-incident-response-procedure.md"
```

```markdown
# Information Security Incident Response Procedure
**Organisation:** [CLIENT]
**Document ID:** IS-PRO-001
**Version:** 1.0
**Date:** [TODAY]
**Owner:** ISMS Owner
**Approved by:** [SPONSOR]
**Next review date:** [TODAY + 12 months]
**Implements:** A.5.24, A.5.25, A.5.26, A.5.27, A.5.28

---

## 1. Purpose

To ensure information security incidents are identified, reported, assessed, and
responded to consistently and effectively — minimising impact and enabling learning.

## 2. Scope

All information security events and incidents affecting systems, data, or people
within the ISMS scope: [SCOPE].

## 3. Definitions

| Term | Definition |
|---|---|
| IS Event | Any observed change in state that may indicate a security concern |
| IS Incident | An IS event that has been assessed as having an actual adverse effect on CIA |
| Major Incident | An incident causing significant operational, regulatory, or reputational impact |

## 4. Incident Reporting

All staff must report suspected IS events immediately via:
- **Email:** [IS incident mailbox or ticketing system]
- **Phone:** [ISMS Owner / IT helpdesk]

No staff member will face disciplinary action for reporting an incident in good faith.

## 5. Incident Response Phases

**Phase 1 — Detect & Report**
- Any staff member observing a suspected event reports it immediately
- IT or ISMS Owner logs the event in the Incident Register within 1 hour

**Phase 2 — Assess**
- ISMS Owner assesses within 4 hours: IS event or IS incident?
- If incident: assign severity (P1 Critical / P2 Major / P3 Minor)
- Notify executive sponsor for P1 and P2 incidents

**Phase 3 — Contain**
- Immediately isolate affected systems if active attack is suspected
- Preserve evidence before remediation (do not wipe without forensic capture)
- Engage external IR support if required (contact: [vendor/CERT])

**Phase 4 — Eradicate & Recover**
- Remove malicious artefacts and patch vulnerabilities exploited
- Restore from clean backup if required
- Verify system integrity before returning to production

**Phase 5 — Report (regulatory)**
- If personal data is involved, assess PDPA / regulatory notification obligation
- Notification deadline: [72 hours / as required by applicable regulation]

**Phase 6 — Learn**
- Conduct post-incident review within 5 business days of closure
- Document root cause, timeline, and lessons learned
- Raise corrective action if a control failure contributed to the incident

## 6. Escalation Matrix

| Severity | Definition | Response time | Escalate to |
|---|---|---|---|
| P1 Critical | Active breach, data exfiltration, ransomware | Immediate | Executive Sponsor + ISMS Owner |
| P2 Major | Confirmed incident with operational impact | 2 hours | ISMS Owner |
| P3 Minor | Contained incident, no data loss | 24 hours | IT Manager |

---

## Approval

| Role | Name | Signature | Date |
|---|---|---|---|
| Executive Sponsor | [SPONSOR] | __________________ | |
| ISMS Owner | | __________________ | |
```

---

### TEMPLATE: Password and Authentication Policy (D21)

```bash
FILENAME="./engagements/policies/${CLIENT:-client}-password-authentication-policy.md"
```

```markdown
# Password and Authentication Policy
**Organisation:** [CLIENT]
**Document ID:** IS-POL-005
**Version:** 1.0
**Date:** [TODAY]
**Owner:** IT Manager / ISMS Owner
**Approved by:** [SPONSOR]
**Next review date:** [TODAY + 12 months]
**Implements:** A.5.17, A.8.5

---

## 1. Purpose

To ensure that authentication to [CLIENT]'s systems provides adequate assurance of
user identity and protects against unauthorized access through compromised credentials.

## 2. Password Requirements

All system passwords must meet the following minimum standards:

| Requirement | Standard |
|---|---|
| Minimum length | 12 characters |
| Complexity | Mix of uppercase, lowercase, numbers, and symbols |
| Password reuse | Last 10 passwords must not be reused |
| Maximum age | 12 months (or on suspected compromise) |
| Sharing | Prohibited — all accounts must be individual |
| Storage | Must not be written down or stored in plain text |

Privileged accounts (admin / root): minimum 16 characters.

## 3. Multi-Factor Authentication (MFA)

MFA is mandatory for:
- All remote access (VPN, RDP, SSH from external networks)
- Cloud platform administration consoles (Azure, AWS, GCP, M365 Admin)
- Email accounts for all staff
- Systems processing sensitive or regulated data

Acceptable MFA methods:
- Authenticator app (TOTP — preferred)
- Hardware token (FIDO2)
- SMS OTP (permitted only where stronger methods are unavailable)

## 4. Account Lockout

- Accounts lock after 10 consecutive failed login attempts
- Locked accounts require IT intervention to unlock (no automatic reset)
- Lockouts are logged and reviewed monthly

## 5. Default Credentials

- All default vendor passwords must be changed before a system enters production
- IT is responsible for maintaining a record of systems where default credentials
  were present and confirming they have been changed

---

## Approval

| Role | Name | Signature | Date |
|---|---|---|---|
| Executive Sponsor | [SPONSOR] | __________________ | |
| ISMS Owner | | __________________ | |
```

---

### TEMPLATE: Backup Policy (D23)

```bash
FILENAME="./engagements/policies/${CLIENT:-client}-backup-policy.md"
```

```markdown
# Information Backup Policy
**Organisation:** [CLIENT]
**Document ID:** IS-POL-006
**Version:** 1.0
**Date:** [TODAY]
**Owner:** IT Manager
**Approved by:** [SPONSOR]
**Next review date:** [TODAY + 12 months]
**Implements:** A.8.13

---

## 1. Purpose

To ensure that [CLIENT]'s critical information and systems can be recovered in the
event of data loss, system failure, or a security incident.

## 2. Backup Strategy

[CLIENT] follows a 3-2-1 backup strategy:
- **3** copies of data (production + 2 backups)
- **2** different storage media or locations
- **1** copy stored offsite or in an immutable/air-gapped location

## 3. Backup Schedule

| Data type | Frequency | Retention | Offsite copy |
|---|---|---|---|
| Critical business data | Daily | 90 days | Yes |
| Databases | Daily (full) + hourly (incremental) | 30 days | Yes |
| System configurations | Weekly | 12 months | Yes |
| Email / collaboration | Daily | 12 months | Yes |

## 4. Recovery Objectives

| System tier | RTO (Recovery Time Objective) | RPO (Recovery Point Objective) |
|---|---|---|
| Tier 1 — Critical | 4 hours | 1 hour |
| Tier 2 — Important | 24 hours | 4 hours |
| Tier 3 — Standard | 72 hours | 24 hours |

## 5. Restoration Testing

- Backup restoration tests must be performed at least **monthly**
- Results must be documented: date, system tested, data recovered, time taken, outcome
- Failed restoration tests must be raised as IS incidents

## 6. Backup Security

- Backup media must be encrypted at rest
- Offsite backups must be stored in a physically secure location
- Access to backup systems is restricted to IT — access log reviewed monthly
- Backups must be protected from ransomware (immutable storage or air-gapped copy)

---

## Approval

| Role | Name | Signature | Date |
|---|---|---|---|
| Executive Sponsor | [SPONSOR] | __________________ | |
| ISMS Owner | | __________________ | |
```

---

## Step 4: Post-Generation Confirmation

After writing each policy file, use AskUserQuestion:

> **[Policy name] generated at [path]**
>
> Before this policy is used:
> 1. Review all fields marked [in brackets] — some may need client-specific content
> 2. Get the ISMS Owner to review for accuracy
> 3. Obtain executive sponsor signature
> 4. Add to the document register in version control
> 5. Distribute to relevant staff and record acknowledgement
>
> Generate another policy?

Options:
- A) Yes — generate [next policy name]
- B) Done for this session

---

After all requested policies are written:
- List all generated files with their paths
- Note which mandatory documents are still missing (not yet generated)
- Remind consultant: policies must be approved and distributed before Stage 1 audit

**STATUS: DONE** — Policies written to `./engagements/policies/`. Next: distribute for approval.
