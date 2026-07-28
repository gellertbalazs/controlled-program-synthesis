# Verification component contract

## Purpose

- PROJECT INTERPRETATION — This directory reserves independent proof-record
  and Program-AST verification responsibilities for
  [`T004`](../../tasks/backlog/T004-proof-kernel-skeleton.md).
- PROJECT INTERPRETATION — [`T006`](../../tasks/backlog/T006-reduction-vertical-slice.md)
  may reuse this component only through a later owner-approved ExecPlan.
- SOURCE FACT — The directory contract is not a verifier.

## Owning task(s)

- SOURCE FACT — [`T004 — Proof-kernel skeleton`](../../tasks/backlog/T004-proof-kernel-skeleton.md)
  is the primary owner.
- PROJECT INTERPRETATION — T006 is a later reuse owner only for scope
  explicitly approved by its own ExecPlan.

## Current state

- PROJECT INTERPRETATION — **PENDING**. No T004 verifier or T006 reuse is
  implemented.

## Approved plan

- SOURCE FACT — **no approved ExecPlan yet**. Future task-specific T004 and,
  if reused, T006 ExecPlans are required implementation authorities.

## Inputs and outputs

- HYPOTHESIS — UNKNOWN. Proof-record forms, Program-AST forms, verification
  results, predicate names, algorithms, and resource envelopes remain
  unapproved until the applicable ExecPlan.

## Trust boundary

- PROJECT INTERPRETATION — Verification is an independent acceptance boundary:
  proposal, inference, synthesis, renderer, or backend output cannot
  self-authorize.

## Allowed responsibilities

- PROJECT INTERPRETATION — After plan approval, this component may own only
  the independent checking responsibilities expressly assigned by T004 or a
  later approved T006 reuse.

## Explicit non-goals

- SOURCE FACT — No verifier, proof checker, inference engine, renderer,
  synthesizer, backend trust, arbitrary meta-execution, or dynamic assertion
  is authorized now.
- PROJECT INTERPRETATION — `src/verify` is not a coexisting component or
  alias, and `src/proof` does not bypass the inference/verification split.

## Entry criteria

- SOURCE FACT — T004 requires T002 and T003 to be accepted.
- SOURCE FACT — T006 requires T002–T005 to be accepted.
- PROJECT INTERPRETATION — Owner approval of the applicable task-specific
  ExecPlan is required before product or test changes.

## Required unit and integration evidence

- PROJECT INTERPRETATION — The future T004 plan must name focused proof-rule,
  malformed-proof, inactive-premise, mutation, and outcome evidence plus
  independent replay/status-propagation integration evidence; any T006 reuse
  must add only evidence named by its later plan and backlog contract.
- SOURCE FACT — The applicable repository contracts are
  [`T004`](../../tasks/backlog/T004-proof-kernel-skeleton.md) and
  [`T006`](../../tasks/backlog/T006-reduction-vertical-slice.md); the complete
  repository unit, integration, and canonical gates must pass.

## Handoff

- PROJECT INTERPRETATION — A completed verification slice must synchronize
  this contract with the [canonical component matrix](../README.md), inference
  and any T006 peer contracts, and control records, then stop at its owning
  task boundary.
