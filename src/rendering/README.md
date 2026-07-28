# Rendering component contract

## Purpose

- PROJECT INTERPRETATION — This directory reserves deterministic,
  content-free rendering responsibilities for the bounded reduction slice
  described by [`T006`](../../tasks/backlog/T006-reduction-vertical-slice.md).
- SOURCE FACT — The directory contract is not a renderer.

## Owning task(s)

- SOURCE FACT — [`T006 — Reduction vertical slice`](../../tasks/backlog/T006-reduction-vertical-slice.md)
  owns this component.

## Current state

- PROJECT INTERPRETATION — **PENDING**. No T006 rendering behavior is
  implemented.

## Approved plan

- SOURCE FACT — **no approved ExecPlan yet**. A future task-specific T006
  ExecPlan is the required implementation authority.

## Inputs and outputs

- HYPOTHESIS — UNKNOWN. Accepted Program-AST inputs, rendered outputs, target
  syntax, predicate names, and error forms remain unapproved until the T006
  ExecPlan.

## Trust boundary

- PROJECT INTERPRETATION — Rendering must be content-free: it may expose only
  independently accepted structure and may not introduce, infer, repair, or
  authorize semantics.

## Allowed responsibilities

- PROJECT INTERPRETATION — After plan approval, this component may own only
  the deterministic rendering responsibilities expressly assigned by the
  bounded T006 slice.

## Explicit non-goals

- SOURCE FACT — No renderer, semantic optimizer, code generator, target
  runtime, serializer, or backend is authorized now.
- PROJECT INTERPRETATION — `src/render` is not a coexisting component or
  alias.

## Entry criteria

- SOURCE FACT — T006 requires T002–T005 to be accepted.
- PROJECT INTERPRETATION — Owner approval of a task-specific T006 ExecPlan is
  required before product or test changes.

## Required unit and integration evidence

- PROJECT INTERPRETATION — The future T006 ExecPlan must name deterministic
  renderer, malformed-input, and content-freedom unit evidence plus the full
  accepted and rejected end-to-end integration evidence required by the
  [`T006 backlog contract`](../../tasks/backlog/T006-reduction-vertical-slice.md);
  the complete repository unit, integration, and canonical gates must pass.

## Handoff

- PROJECT INTERPRETATION — A completed T006 rendering slice must synchronize
  this contract with the [canonical component matrix](../README.md), synthesis
  and verification contracts, and control records, then stop before T007.
