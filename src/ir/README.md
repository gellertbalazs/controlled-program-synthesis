# Intermediate-representation component contract

## Purpose

- PROJECT INTERPRETATION — This directory reserves the canonical
  Specification IR and distinct Program AST boundary described by
  [`T003`](../../tasks/backlog/T003-spec-and-program-ir.md).
- SOURCE FACT — The directory contract is not an implemented representation.

## Owning task(s)

- SOURCE FACT — [`T003 — Specification IR and Program AST`](../../tasks/backlog/T003-spec-and-program-ir.md)
  owns this component.

## Current state

- PROJECT INTERPRETATION — **PENDING**. T003 source analysis, planning, and
  implementation have not begun.

## Approved plan

- SOURCE FACT — **no approved ExecPlan yet**. A future task-specific T003
  ExecPlan is the required implementation authority.

## Inputs and outputs

- HYPOTHESIS — UNKNOWN. Term shapes, binders, equality representation,
  validation envelopes, predicate names, and interchange formats remain
  unapproved until the T003 ExecPlan.

## Trust boundary

- PROJECT INTERPRETATION — Proposed specifications and programs must remain
  distinct from independently validated, ground representations; host
  unification cannot silently define object-language binding or equality.

## Allowed responsibilities

- PROJECT INTERPRETATION — After plan approval, this component may own only
  the representation and validation responsibilities expressly bounded by
  T003 and that plan.

## Explicit non-goals

- SOURCE FACT — No IR schema, Program AST, parser, solver backend, code
  generator, serializer, or host-goal representation is authorized now.

## Entry criteria

- SOURCE FACT — T003 requires T002 to be accepted.
- PROJECT INTERPRETATION — Owner approval of a task-specific T003 ExecPlan is
  required before product or test changes.

## Required unit and integration evidence

- PROJECT INTERPRETATION — The future T003 ExecPlan must name focused schema,
  scope, type, malformed-input, and boundary unit evidence plus the
  specification-to-Program-AST integration evidence required by the
  [`T003 backlog contract`](../../tasks/backlog/T003-spec-and-program-ir.md);
  the complete repository unit, integration, and canonical gates must pass.

## Handoff

- PROJECT INTERPRETATION — A completed T003 slice must synchronize this
  contract with the [canonical component matrix](../README.md) and control
  records, preserve proposal/acceptance separation, and stop before T004.
