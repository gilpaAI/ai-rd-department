---
name: tutor
description: GenAI Math Tutor for students ages 12-18 using Socratic pedagogy, SymPy verification, and a modular Lego-Architecture for Phase 2 extensibility
status: backlog
created: 2026-02-18T10:35:19Z
local_path: C:/Users/gilpa/Projects/AI TUTOR/Tutor
repo: gilpaAI/tutor
---

# PRD: Tutor — GenAI Math Tutor (Lego-Architecture)

## Executive Summary

Tutor is a Socratic, AI-powered math coaching application for students ages 12–18. A student uploads a homework PDF (or types a problem), and Tutor guides them step-by-step toward the answer — never giving it outright, only surfacing the next logical hint. Every hint is verified for mathematical correctness by a deterministic SymPy Truth Engine before it reaches the student, eliminating AI hallucinations from the learning loop.

The system is designed as interchangeable "Lego bricks": the PDF input can be swapped for Voice (Whisper) or Photo (OpenCV) in Phase 2 without changing the core logic. The architecture is defined by three layers: I/O Adapters (Layer A), a LangGraph State Bus (Layer B), and specialized Logic Agents (Layer C).

## Problem Statement

### The Problem
Students ages 12–18 are increasingly using ChatGPT, Google, and other tools to get direct answers to homework problems. This produces a superficial sense of completion while creating compounding learning gaps — the student never internalizes the underlying reasoning.

### Why Now
LLMs are now capable enough to generate step-level hints, not just answers. Pairing this with deterministic math solvers (SymPy) creates a system that is both pedagogically sound and mathematically trustworthy — something no existing tool delivers.

### The Gap in the Market
- Khan Academy: Pre-recorded. Not responsive to the student's specific work.
- Wolfram Alpha: Gives the answer directly. Anti-Socratic.
- ChatGPT: No guardrails. Will happily write the student's essay.
- Photomath: Step-by-step answers. No pedagogical scaffolding.

**Tutor's differentiator:** The Socratic Constraint (FR-01) is enforced at the system level, not by prompt alone. The Verifier ensures every hint is mathematically grounded.

## Target Users

### Primary — The Student (Ages 12–18)
- Doing math homework (algebra, pre-calc, calculus, fractions, geometry)
- Gets stuck and wants a push, not the answer
- Motivated by progress, not grades
- Low tolerance for friction or complexity in the UI

### Secondary — The Parent / Guardian
- Wants to know their child is actually learning, not cheating
- Interested in the Mastery Progress Map as a progress report

### Tertiary — The Teacher (Future Scope)
- Could use gap detection logs as formative assessment data
- Out of scope for MVP

## User Stories

### US-01: Upload and Start
**As a student**, I want to upload my math homework PDF and immediately begin receiving help, **so that** I don't have to retype problems manually.

**Acceptance Criteria:**
- [ ] Student can upload a PDF or paste text directly
- [ ] System extracts problem text within 5 seconds
- [ ] If extraction fails, student is offered a manual paste option
- [ ] System acknowledges the problem and asks where the student is stuck

### US-02: Socratic Hint Flow
**As a student**, I want to receive a hint for my next step (not the answer), **so that** I can reason through the problem myself.

**Acceptance Criteria:**
- [ ] System never outputs the final numerical answer directly (FR-01)
- [ ] Each hint is limited to <3 sentences
- [ ] Student can request: "Next step", "Explain why", or "I'm stuck"
- [ ] Hints escalate in specificity with each request

### US-03: Answer Verification
**As a student**, I want to submit my answer attempt and get immediate feedback, **so that** I know if my reasoning was correct.

**Acceptance Criteria:**
- [ ] Green feedback: "Logic holds!" if answer is correct
- [ ] Yellow feedback: "Close! Check your sign in the last step." if partially correct
- [ ] System identifies the error category (FR-02: e.g., "Negative Sign Error")
- [ ] No red/failure language — framing is always growth-oriented

### US-04: Mastery Progress Map
**As a student**, I want to see which math concepts I've successfully worked through, **so that** I feel a sense of accomplishment and can identify where to practice more.

**Acceptance Criteria:**
- [ ] Progress shown as a node map (not a score or leaderboard)
- [ ] Each node represents a math concept (e.g., "Solving Linear Equations")
- [ ] Conquered nodes shown in green; attempted nodes in yellow; untouched in grey
- [ ] Map persists across sessions (session state saved)

### US-05: Grade-Level Adaptation
**As a student**, I want the tutor to use vocabulary appropriate for my grade level, **so that** explanations don't confuse or condescend.

**Acceptance Criteria:**
- [ ] Student selects grade level on first use (7th–12th grade)
- [ ] Teacher Agent uses grade level to adapt vocabulary (FR-04)
- [ ] E.g., "Fractions" vocabulary for 7th grade vs. "Rational Functions" for 12th grade

## Functional Requirements

| ID | Requirement | Logic Brick | Priority |
|----|-------------|-------------|----------|
| FR-01 | **Socratic Constraint:** System must never provide the numerical answer until the student proves understanding. | Socratic Agent | Must Have |
| FR-02 | **Passive Gap Detection:** Every error must be categorized (e.g., "Negative Sign Error," "Fraction Error") and logged to the Mastery Graph. | Teacher Agent | Must Have |
| FR-03 | **Logic QA:** Every hint generated by the AI must be verified by the SymPy Verifier to ensure it leads to a valid result before delivery. | Verifier Agent | Must Have |
| FR-04 | **Adaptive Context:** The system must recognize grade-level vocabulary based on student-selected grade. | Teacher Agent | Must Have |
| FR-05 | **PDF Extraction:** System must extract clean text and LaTeX from uploaded PDFs. | I/O Adapter | Must Have |
| FR-06 | **Intent Classification:** System must distinguish between "help with homework" and "new topic" intents. | Teacher Agent | Must Have |
| FR-07 | **Selection Buttons:** UI must offer pre-defined response options to reduce student cognitive load. | Frontend | Must Have |
| FR-08 | **Split-Screen View:** PDF on the left, Socratic chat on the right. | Frontend | Must Have |
| FR-09 | **Progressive Disclosure:** Only reveal the next logical step; never the full solution path. | Socratic Agent | Must Have |
| FR-10 | **Session Persistence:** Mastery Graph and Conversation History persist across sessions for the same user. | LangGraph State Bus | Should Have |

## Architecture (Lego-Architecture)

### Layer A — Inlet Bricks (I/O Adapters)
- **PDF/Text Adapter:** PyMuPDF or Marker-PDF
  - Extracts clean text + LaTeX from student uploads
  - Fallback: student pastes problem text manually
  - **Future swap:** Whisper (Voice), OpenCV/Marker (Photo)

### Layer B — State Bus (Shared Memory)
- **OSS Tool:** LangGraph
- Acts as the "Lego Baseplate" — every agent reads from and writes to this state
- Stores:
  - **Mastery Graph:** nodes (math concepts), edges (relationships), status (conquered/attempted/untouched), error log
  - **Conversation History:** full session turns for context

### Layer C — Logic Bricks (Agents)
- **Teacher (Router):** Classifies intent; routes to appropriate downstream agent; detects and logs gaps (FR-02, FR-04, FR-06)
- **Socratic (Practice):** Generates pedagogically scaffolded, grade-appropriate hints; enforces FR-01; formats responses to <3 sentences
- **Model Adapter:** LiteLLM — plug-and-play access to Gemini, Claude, or Llama (model-agnostic)
- **Verifier (Truth Engine):** SymPy — deterministic math solving; validates every AI-generated hint (FR-03); zero-AI dependency for math truth

## Non-Functional Requirements

| ID | Requirement | Target |
|----|-------------|--------|
| NFR-01 | **Response time:** Hint delivered within 3 seconds of student request | p95 < 3s |
| NFR-02 | **PDF extraction:** PDF parsed within 5 seconds | p95 < 5s |
| NFR-03 | **Hint bubble length:** AI response limited to <3 sentences | Enforced at agent level |
| NFR-04 | **Verifier coverage:** SymPy verification applied to 100% of hints for supported problem types | 100% |
| NFR-05 | **Model-agnostic:** Switching LLM provider requires config change only, no code change | Via LiteLLM |
| NFR-06 | **Mobile-responsive:** UI functional on tablets (students use iPads at school) | Core breakpoints |
| NFR-07 | **Session state:** Mastery Graph persists for minimum 30 days per user | Storage TBD |

## UX Requirements

### Micro-Interaction Design
- **Short Chat Bubbles:** AI responses limited to <3 sentences
- **Selection Buttons:** Pre-defined responses for common student intents:
  - "I'm stuck"
  - "Next step"
  - "Explain why"
  - "Check my answer"
- **Scratchpad View:** Split-screen — PDF/problem on left, Socratic chat on right

### Mastery Visualization
- A **Progress Map** (NOT a leaderboard or score) showing conquered mathematical nodes
- Nodes: math concepts the student has worked through
- Colors: green (conquered), yellow (attempted), grey (untouched)

### Cognitive Load Management
- **Progressive Disclosure:** Only the next logical step is revealed — never the full solution path
- **Validation Feedback:**
  - 🟢 Green Check: "Logic holds!"
  - 🟡 Yellow Spark: "Close! Check your sign in the last step."
- No negative or failure-oriented language

## Success Criteria

| Metric | Target | Measurement Method |
|--------|--------|--------------------|
| Socratic compliance rate | 100% of sessions — no raw answer given | Automated audit of response logs |
| Verifier coverage | 100% of hints verified for algebra/arithmetic | Log-based audit |
| PDF extraction success rate | >90% of typical student PDFs | Test suite with sample worksheets |
| Student session length | >5 minutes average (indicates engagement) | Session analytics |
| Hint-to-understanding ratio | Student solves problem within 5 hints on average | Session analytics |
| Error categorization accuracy | >80% of errors correctly categorized (spot check) | Manual review sample |

## Constraints & Assumptions

### Technical Constraints
- **SymPy coverage:** SymPy solves algebra, arithmetic, basic calculus, and some geometry — but NOT geometry proofs, word problems with ambiguous variables, or advanced statistics. Verifier is scoped to supported types only.
- **LangGraph state:** Graph state is in-memory for MVP; persistent storage (Redis/PostgreSQL) is a Phase 2 concern
- **LiteLLM:** Requires API key configuration per model provider; defaults to Claude for MVP

### Assumptions
- Students have access to a desktop or tablet browser
- PDFs are standard school worksheet format (not handwritten)
- Grade-level selection is one-time and can be updated by the student

### Timeline
- MVP target: Phase 1 complete within ~20 working days (5 milestones × ~4 days each)

## Out of Scope (MVP)

- Voice input (Whisper integration) — Phase 2
- Photo input of handwritten problems (OpenCV) — Phase 2
- Multi-student accounts / classroom management — Phase 3
- Teacher dashboard and reporting — Phase 3
- Curriculum alignment to specific school standards (Common Core, GCSE, etc.) — Phase 3
- Offline mode
- Mobile native apps (iOS/Android)
- Payments / subscription management

## Dependencies

### External
- **PyMuPDF or Marker-PDF:** OSS, no license concerns for MVP
- **LangGraph:** OSS (LangChain ecosystem), Apache 2.0
- **SymPy:** OSS, BSD license
- **LiteLLM:** OSS, MIT license
- **LLM API:** Claude (Anthropic) as default; key required

### Internal
- Project folder: `C:/Users/gilpa/Projects/AI TUTOR/Tutor`
- R&D Department tracking: this repo (ai-rd-department)

## Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| SymPy can't verify all problem types | High | Medium | Scope Verifier to algebra/arithmetic MVP; flag unsupported types gracefully with "I can check this one manually" |
| Hint ↔ Verifier format mismatch | Medium | High | Teacher Agent normalizes hint into SymPy-parseable expression before Verifier call |
| LangGraph cycle/loop bugs | Medium | High | Keep graph linear for MVP; add explicit cycle-break conditions |
| PDF extraction fails on real worksheets | Medium | Medium | Always offer manual paste fallback |
| Grade-level detection inaccurate from problem text | Low | Low | UI-based grade selector (student sets it once) |
| LLM generates pedagogically inappropriate response | Low | High | System-level FR-01 enforcement via output filter, not just prompt |

## Milestones

| # | Milestone | Key Deliverable | Estimate |
|---|-----------|-----------------|----------|
| 1 | Foundation & State Bus | Python scaffold + LangGraph schema + LiteLLM adapter + FastAPI skeleton | 3–4 days |
| 2 | I/O Layer + Verifier | PyMuPDF pipeline + SymPy Truth Engine + unit tests | 3–4 days |
| 3 | Teacher + Socratic Agents | All 4 FRs implemented + agent integration tests | 5–6 days |
| 4 | Frontend — Split-Screen UI | React/Next.js app with all UX requirements | 4–5 days |
| 5 | Integration & MVP Polish | End-to-end flow + Docker config + smoke tests | 3–4 days |
