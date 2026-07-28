# Inference component contract

## Purpose

- PROJECT INTERPRETATION — This directory reserves bounded inference
  responsibilities for the proof-kernel skeleton described by
  [`T004`](../../tasks/backlog/T004-proof-kernel-skeleton.md).
- SOURCE FACT — The directory contract is not an inference engine.

## Owning task(s)

- SOURCE FACT — [`T004 — Proof-kernel skeleton`](../../tasks/backlog/T004-proof-kernel-skeleton.md)
  owns this component.

## Current state

- PROJECT INTERPRETATION — **PENDING**. No T004 inference behavior is
  implemented.

## Approved plan

- SOURCE FACT — **no approved ExecPlan yet**. A future task-specific T004
  ExecPlan is the required implementation authority.

## Inputs and outputs

- HYPOTHESIS — UNKNOWN. Proof-record forms, rule representations, result
  terms, predicate names, and resource envelopes remain unapproved until the
  T004 ExecPlan.

## Trust boundary

- PROJECT INTERPRETATION — Proposal or backend output cannot confer
  acceptance. Any later inference must remain bounded and subordinate to
  independent verification over active trusted premises and accepted
  obligations.

## Allowed responsibilities

- PROJECT INTERPRETATION — After plan approval, this component may own only
  the bounded inference responsibilities expressly assigned by T004 and that
  plan.

## Explicit non-goals

- SOURCE FACT — No theorem prover, proof kernel, backend trust, arbitrary
  meta-execution, dynamic assertion, or hidden acceptance step is authorized
  now.
- PROJECT INTERPRETATION — `src/proof` cannot bypass the canonical
  inference/verification split.

## Entry criteria

- SOURCE FACT — T004 requires T002 and T003 to be accepted.
- PROJECT INTERPRETATION — Owner approval of a task-specific T004 ExecPlan is
  required before product or test changes.

## Required unit and integration evidence

- PROJECT INTERPRETATION — The future T004 ExecPlan must name focused
  rule/outcome and malformed-proof unit evidence plus independent replay and
  status-propagation integration evidence required by the
  [`T004 backlog contract`](../../tasks/backlog/T004-proof-kernel-skeleton.md);
  the complete repository unit, integration, and canonical gates must pass.

## Handoff

- PROJECT INTERPRETATION — A completed T004 inference slice must synchronize
  this contract with the [canonical component matrix](../README.md), the
  verification contract, and control records, then stop before T005.
