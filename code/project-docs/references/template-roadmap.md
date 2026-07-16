# ROADMAP.md — what gets built, in what order

Phases are scope fences, not just a schedule. A later-phase feature is **out of
scope until its trigger fires**, and the trigger is written down. Building ahead
of a trigger is over-engineering (see `DECISIONS.md`). For the *why* behind each
fence, follow the `D#` references into `DECISIONS.md`.

Current phase: see [`STATUS.md`](STATUS.md).

---

## Phase 0 — {NAME}  {STATUS_EMOJI}

- {DELIVERABLE}

## Phase 1 — {NAME}  ⬅ next

{BUILD_ORDER_BULLETS}

**Exit / success criterion:** {SUCCESS_CRITERION}

## Phase 2 — {NAME} (deferred; trigger-gated)  🔒

**Trigger:** {TRIGGER_CONDITION}

- {DEFERRED_ITEM}

## Non-goals (explicit)

| Item | Trigger to reconsider |
|------|----------------------|
| {NON_GOAL} | {TRIGGER} |
