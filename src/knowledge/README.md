# Knowledge component contract

## Purpose

- SOURCE FACT — This directory carries the accepted T002 knowledge-boundary
  contract whose implementation remains the repository-root
  [`cps_law_claim_authority.pl`](../cps_law_claim_authority.pl).
- PROJECT INTERPRETATION — This directory also reserves the knowledge side of
  the future [`T007 teaching lifecycle`](../../tasks/backlog/T007-teaching-lifecycle.md);
  the README does not implement that lifecycle.

## Owning task(s)

- SOURCE FACT — T002 owns the accepted law-claim-authority contract under its
  [`frozen approved plan`](../../docs/plans/T002-source-addressed-law-claim-authority-plan.md).
- SOURCE FACT — [`T007 — Teaching lifecycle`](../../tasks/backlog/T007-teaching-lifecycle.md)
  owns any future knowledge-lifecycle behavior in this directory.

## Current state

- SOURCE FACT — **DONE** for the accepted T002 root-module boundary.
- PROJECT INTERPRETATION — **PENDING** for T007 behavior in this directory.

## Approved plan

- SOURCE FACT — The
  [`T002 frozen approved plan`](../../docs/plans/T002-source-addressed-law-claim-authority-plan.md)
  applies only to its accepted root-module slice.
- SOURCE FACT — **no approved ExecPlan yet** for T007 lifecycle behavior.

## Inputs and outputs

- SOURCE FACT — The exact accepted T002 input, result, audit, and provenance
  contract is bounded by the frozen T002 plan and root module; this README
  does not broaden it.
- HYPOTHESIS — UNKNOWN. T007 lifecycle inputs, outputs, persistence, and
  transition representations remain unapproved until a T007 ExecPlan.

## Trust boundary

- SOURCE FACT — T002 normalization evidence is syntactic only; identifiers,
  payloads, sources, positions, and shared provenance do not independently
  confer truth, equality, activation, trust, applicability, or authority.
- PROJECT INTERPRETATION — Future T007 candidates must remain quarantined
  from accepted and activated knowledge until separately authorized.

## Allowed responsibilities

- PROJECT INTERPRETATION — This component may document the accepted T002
  boundary and, only after later plan approval, own the T007 knowledge
  responsibilities explicitly assigned by that plan.

## Explicit non-goals

- SOURCE FACT — This directory contains no duplicate authority engine,
  lifecycle engine, storage layer, serializer, database, process protocol, or
  implicit activation mechanism.

## Entry criteria

- SOURCE FACT — The T002 boundary is accepted under its frozen plan.
- SOURCE FACT — T007 requires T002 and T006 to be accepted.
- PROJECT INTERPRETATION — Owner approval of a task-specific T007 ExecPlan is
  required before any lifecycle product or test change.

## Required unit and integration evidence

- SOURCE FACT — The accepted T002 evidence belongs to the frozen root module
  and its existing focused and clean-process tests; this directory claims no
  additional executable coverage.
- PROJECT INTERPRETATION — The future T007 ExecPlan must name transition,
  illegal-transition, provenance, and end-to-end lifecycle evidence required
  by the [`T007 backlog contract`](../../tasks/backlog/T007-teaching-lifecycle.md);
  the complete repository unit, integration, and canonical gates must pass.

## Handoff

- PROJECT INTERPRETATION — Any completed T007 knowledge slice must preserve
  the accepted T002 boundary, synchronize this contract with the
  [canonical component matrix](../README.md), dialogue contract, and control
  records, then stop before T008.
