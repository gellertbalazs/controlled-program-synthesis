# Synthesis component contract

## Purpose

- PROJECT INTERPRETATION — This directory reserves proposal-generation
  responsibilities for the bounded reduction slice described by
  [`T006`](../../tasks/backlog/T006-reduction-vertical-slice.md).
- SOURCE FACT — The directory contract is not a synthesizer.

## Owning task(s)

- SOURCE FACT — [`T006 — Reduction vertical slice`](../../tasks/backlog/T006-reduction-vertical-slice.md)
  owns this component.

## Current state

- PROJECT INTERPRETATION — **PENDING**. No T006 synthesis behavior is
  implemented.

## Approved plan

- SOURCE FACT — **no approved ExecPlan yet**. A future task-specific T006
  ExecPlan is the required implementation authority.

## Inputs and outputs

- HYPOTHESIS — UNKNOWN. Proposal inputs, candidate representations,
  algorithms, predicate names, backend interfaces, and resource envelopes
  remain unapproved until the T006 ExecPlan.

## Trust boundary

- PROJECT INTERPRETATION — Every synthesized or backend-produced candidate is
  proposal data. Independent proof acceptance and Program-AST verification
  remain outside this component's authority.

## Allowed responsibilities

- PROJECT INTERPRETATION — After plan approval, this component may own only
  the proposal-generation responsibilities expressly assigned by the bounded
  T006 slice.

## Explicit non-goals

- SOURCE FACT — No synthesizer, solver, equality-saturation backend, proof
  authority, optional dependency, process boundary, or persistence mechanism
  is authorized now.
- PROJECT INTERPRETATION — `src/synth` is not a coexisting component or alias,
  and `src/patterns` is not a product boundary before an approved T006 plan.

## Entry criteria

- SOURCE FACT — T006 requires T002–T005 to be accepted.
- PROJECT INTERPRETATION — Owner approval of a task-specific T006 ExecPlan is
  required before product or test changes.

## Required unit and integration evidence

- PROJECT INTERPRETATION — The future T006 ExecPlan must name proposal,
  law/definedness, resource, rejection, and missing-law unit evidence plus the
  accepted and source-relative-failure integration evidence required by the
  [`T006 backlog contract`](../../tasks/backlog/T006-reduction-vertical-slice.md);
  the complete repository unit, integration, and canonical gates must pass.

## Handoff

- PROJECT INTERPRETATION — A completed T006 synthesis slice must synchronize
  this contract with the [canonical component matrix](../README.md), rendering
  and verification contracts, and control records, then stop before T007.
