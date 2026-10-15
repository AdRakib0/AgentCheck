# AgentCheck

Public student-focused education-agent review directory aligned to AgentCheck PRD Draft v1 (15 October 2026).

## Current status
The interface has been revised to reflect the PRD: 1–5 star review concept, neutral topic tags, state/topic/rating filters, sorting, dispute entry point, privacy language, draft terms, moderation policy and About disclosure page. There are no fabricated sample reviews. Real review submission and admin moderation are intentionally disabled until the secure backend is implemented.

## Required before launch
- Supabase (or equivalent) persistent storage with Row Level Security.
- Server-side email verification and abuse limits (maximum three reviews per email per day).
- Admin-only authentication with MFA and public sign-ups disabled.
- Moderation queue, audit trail, dispute handling and secure hide action.
- Final terms, privacy/collection notice, moderation policy, takedown procedure and operator-interest disclosure.
- Australian defamation/media and privacy legal review.

## Database schema draft
The proposed schema is in supabase/schema.sql. Review it with a security engineer before applying. It enables RLS and grants public reads only for approved reviews; it intentionally does not add public insert/update policies. Server-side routes, email delivery, MFA role checks and audit logging still need to be implemented and tested.

This project can deploy as a frontend without database credentials, but it is not yet a production review service. Never expose a service-role key in browser code. This project documentation is not legal advice.
