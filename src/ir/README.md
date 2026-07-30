# Intermediate-representation component contract

## Purpose

- SOURCE FACT — This component implements one bounded validation boundary for
  a closed typed-equality Specification proposal and a distinct
  identity-shaped Program AST proposal.
- SOURCE FACT — The accepted public module is
  [`cps_ground_typed_equality_ir.pl`](cps_ground_typed_equality_ir.pl), owned
  by [`T003`](../../tasks/done/T003-spec-and-program-ir.md).

## Current state and plan

- SOURCE FACT — **DONE**. T003 V1 accepted the frozen option-1 candidate after
  the GOV-004 acceptance-harness repair passed without changing candidate
  bytes.
- SOURCE FACT — The frozen authority is the
  [owner-approved option-1 plan](../../docs/plans/T003-ground-typed-equality-ir-option-1-plan.md).

## Public boundary

- SOURCE FACT — `validate_ground_typed_equality_pair/4` accepts a
  Specification proposal, Program proposal, and T002 authority snapshot as
  data and deterministically returns one finite ground
  `ground_typed_equality_validation(Status, Audit)` result.
- SOURCE FACT — `Status` explicitly distinguishes accepted, rejected, and
  `unknown` outcomes, including malformed, unsupported, semantic, authority,
  and bounded resource reasons.
- SOURCE FACT — The validator does not bind, execute, assert, retract, or
  otherwise mutate either proposal.

## Trust boundary

- SOURCE FACT — Specification and Program proposals are structurally,
  finitely, and independently inspected before semantic compatibility and
  T002 authority assessment.
- SOURCE FACT — Only fresh validated data may appear in an accepted result;
  caller-supplied accepted-looking terms confer no authority.
- PROJECT INTERPRETATION — Acceptance establishes the approved structural,
  typing, scope, compatibility, and source-relative authority contract. It
  does not prove equality truth, prove Program satisfaction, execute a
  Program, or authorize rendering.

## Bounds and determinism

- SOURCE FACT — The option-1 contract uses one canonical preorder
  depth-first left-to-right Specification-before-Program observation counter.
  Visits 1-512 are inspectable; before visit 513 the applicable Specification
  or Program cell-resource result is returned without inspecting later data.
- SOURCE FACT — Identifier, scalar, list, depth, cell, and inherited T002
  limits are explicit and fail closed. Every public input-mode call has one
  ground acyclic result.

## Verification evidence

- SOURCE FACT — The focused T003 inventory contains 44 named tests, including
  the independent visit-position model and positions 512, 513, and 520.
- SOURCE FACT — The repaired canonical gate passed infrastructure 34/34,
  repository unit 112/112, and integration 15/15 with zero failures, errors,
  or skips.
- SOURCE FACT — T003-DL-001 through T003-DL-003 are closed and retained as
  regressions. GOV-004-DL-001 was a control-plane fixture defect and changed
  no product byte.

## Explicit non-goals

- SOURCE FACT — This component is not a parser, theorem prover, proof kernel,
  synthesizer, executor, serializer, code generator, or renderer.
- SOURCE FACT — T004 proof-kernel work requires its own source analysis,
  frozen owner-approved ExecPlan, and independently tested implementation.
