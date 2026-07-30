# Inference component contract

## Purpose

- SOURCE FACT — T004 assigns no inference predicate to this directory.
- PROJECT INTERPRETATION — This directory remains reserved and
  non-authoritative for any future bounded inference responsibilities.
- SOURCE FACT — The T004 checker is instead implemented under
  [`verification`](../verification/README.md) as
  `check_source_relative_identity_proof/5`.
- SOURCE FACT — The directory contract is not an inference engine.

## Owning task(s)

- SOURCE FACT — [`T004 — Proof-kernel skeleton`](../../tasks/done/T004-proof-kernel-skeleton.md)
  owns this component.

## Current state

- SOURCE FACT — T004 adds no inference public API or implementation here.
- PROJECT INTERPRETATION — The frozen verification-side candidate is
  implemented but is not described as accepted here. Current progress,
  counters, eligibility, and verdict are authoritative only in the
  [`T004 task record`](../../tasks/done/T004-proof-kernel-skeleton.md).

## Approved plans

- SOURCE FACT — T004 delivery is governed by the
  [`original approved plan`](../../docs/plans/T004-source-relative-identity-proof-replay-plan.md),
  [`fixture amendment`](../../docs/plans/T004-source-relative-identity-proof-replay-fixture-amendment-plan.md),
  and
  [`publication amendment`](../../docs/plans/T004-source-relative-identity-proof-replay-publication-amendment-plan.md).
- PROJECT INTERPRETATION — Those plans allocate the public checker to
  verification and allocate no inference predicate to this directory.

## Inputs and outputs

- SOURCE FACT — This directory defines no T004 input, output, predicate, rule,
  proof-record, or result term.
- SOURCE FACT — The verification-side predicate
  `check_source_relative_identity_proof/5` consumes four proposal inputs and
  returns an explicit ground proof-replay result and audit.

## Trust boundary

- PROJECT INTERPRETATION — Proposal or backend output cannot confer
  acceptance or self-authorize. Any future inference must remain bounded and
  subordinate to independent verification over active and trusted premises,
  accepted obligations, and independently checked Program AST data.

## Allowed responsibilities

- PROJECT INTERPRETATION — The current T004 allocation is reservation only.
  Any future inference responsibility requires its own owner-approved plan and
  synchronized component contracts.

## Explicit non-goals

- SOURCE FACT — This directory implements no proof search, proof construction,
  theorem proving, backend trust, arbitrary meta-execution, dynamic assertion,
  or hidden acceptance step.
- PROJECT INTERPRETATION — The verification-side checker proves no equality
  truth, Specification satisfaction, Program correctness, completeness,
  Program execution, backend authority, or T006 reuse.
- PROJECT INTERPRETATION — `src/proof` cannot bypass the canonical
  inference/verification split.

## Entry criteria

- SOURCE FACT — T004 entered delivery only after T002 and T003 acceptance and
  exact owner approval of its digest-bound plans.
- PROJECT INTERPRETATION — Any change to the inference allocation requires a
  separately reviewed and explicitly approved plan.

## Required unit and integration evidence

- SOURCE FACT — The T004 verification candidate retains the focused
  rule/outcome, malformed-proof, replay, trust, resource, determinism,
  immutability, and clean-process evidence required by the approved plans and
  [`T004 ready contract`](../../tasks/done/T004-proof-kernel-skeleton.md).
- PROJECT INTERPRETATION — This reservation adds no duplicate inference test
  surface.

## Handoff

- PROJECT INTERPRETATION — This contract, the
  [canonical component matrix](../README.md), the verification contract, and
  control records must remain synchronized. T005 does not activate
  automatically.
