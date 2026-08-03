# Verification component contract

## Purpose

- SOURCE FACT — This directory implements the bounded, source-relative
  proof-record replay checker owned by
  [`T004`](../../tasks/done/T004-proof-kernel-skeleton.md).
- PROJECT INTERPRETATION — [`T006`](../../tasks/ready/T006-reduction-vertical-slice.md)
  uses a separate private reduction checker in the root T006 module and does
  not reuse or extend this identity checker.
- PROJECT INTERPRETATION — The checker is an independent acceptance boundary;
  it is not an inference engine or proof producer.

## Owning task(s)

- SOURCE FACT — [`T004 — Proof-kernel skeleton`](../../tasks/done/T004-proof-kernel-skeleton.md)
  is the primary owner.
- PROJECT INTERPRETATION — T006 owns no predicate or behavior in this
  directory.

## Current state

- SOURCE FACT — The T004 checker is an implemented frozen candidate.
- PROJECT INTERPRETATION — This contract does not declare T004 accepted.
  Current progress, counters, eligibility, and verdict are authoritative only
  in the [`T004 task record`](../../tasks/done/T004-proof-kernel-skeleton.md).
- PROJECT INTERPRETATION — T006's approved reduction replay remains distinct
  from T004 identity replay and imports no T004 code.

## Approved plans

- SOURCE FACT — T004 delivery is governed by the
  [`original approved plan`](../../docs/plans/T004-source-relative-identity-proof-replay-plan.md),
  [`fixture amendment`](../../docs/plans/T004-source-relative-identity-proof-replay-fixture-amendment-plan.md),
  and
  [`publication amendment`](../../docs/plans/T004-source-relative-identity-proof-replay-publication-amendment-plan.md).
- SOURCE FACT — T006 is governed separately by its
  [`original plan`](../../docs/plans/T006-fixed-left-reduction-vertical-slice-plan.md)
  and
  [`focused-exhaustion amendment`](../../docs/plans/T006-fixed-left-reduction-vertical-slice-amended-plan.md).

## Inputs and outputs

- SOURCE FACT — The implemented T004 public predicate is check_source_relative_identity_proof/5.
- SOURCE FACT — Its four proposal inputs are `SpecificationProposal`,
  `ProgramProposal`, `AuthoritySnapshot`, and `ProofProposal`; its sole output
  is one deterministic ground acyclic `proof_replay(Status,Audit)` result.
- SOURCE FACT — The exact status families are `accepted(CheckedProof)`,
  `rejected(Reason)`, `unsupported(Feature)`, `unknown(Missing)`, and
  `resource_exhausted(Resource)`.
- PROJECT INTERPRETATION — Acceptance is exact local replay. Rejection is
  inspected invalid or negative evidence; unsupported identifies a
  well-shaped outside-fragment tag; unknown preserves insufficient evidence;
  resource exhaustion means the next bounded observation was not made.

## Trust boundary

- SOURCE FACT — Acceptance requires fresh T003 validation with its nested T002
  assessment, every used premise active and trusted, all applicable
  accepted obligations, exact authority scope and ordered references, and an
  independently checked Program AST.
- PROJECT INTERPRETATION — Specification, Program, authority, proof, inference,
  synthesis, renderer, and backend outputs remain proposals and cannot
  self-authorize or replace the checked result.

## Allowed responsibilities

- SOURCE FACT — The sole T004 rule is
  `source_relative_identity_replay_v1`: one rule, one supplied/root step, and
  no dependency child.
- SOURCE FACT — The frozen maxima are dependency depth one, structural depth 16,
  step/dependency/reference list lengths one/zero/two, 64 Unicode scalars per
  new proof or step identifier, and 128 inspected proof cells.
- PROJECT INTERPRETATION — The checker may own only the exact replay,
  fail-closed status, audit, trust, provenance, activation, and bounded
  resource responsibilities in the approved plans.

## Explicit non-goals

- SOURCE FACT — The checker performs no proof search or construction,
  inference, rendering, synthesis, Program execution, arbitrary meta-execution,
  dynamic assertion, filesystem/network authority, or backend trust.
- PROJECT INTERPRETATION — It proves no equality truth, Specification
  satisfaction, Program correctness, completeness, cost, effects,
  termination, or T006 reduction conclusion.
- PROJECT INTERPRETATION — `src/verify` is not a coexisting component or
  alias, and `src/proof` does not bypass the inference/verification split.

## Entry criteria

- SOURCE FACT — T004 entered delivery only after T002 and T003 acceptance and
  exact owner approval of its digest-bound plans.
- SOURCE FACT — T006 requires T002–T005 to be accepted.
- PROJECT INTERPRETATION — T006's separately approved root module leaves the
  frozen T004 boundary and every T004 byte unchanged.

## Required unit and integration evidence

- SOURCE FACT — The frozen T004 evidence covers accepted, malformed,
  unsupported, non-ground, attributed, cyclic, rejected, `UNKNOWN`, resource,
  priority, replay, trust/provenance/activation, determinism, input
  immutability, clean-process/status, and exclusion outcomes.
- PROJECT INTERPRETATION — Independent V1 and, only if reached, V2 must inspect
  the complete matrix and task ledger and run every approved verification
  gate. T006 reduction evidence is governed only by its own approved plans and
  [`T006 task`](../../tasks/ready/T006-reduction-vertical-slice.md).

## Handoff

- PROJECT INTERPRETATION — This contract, the
  [canonical component matrix](../README.md), the inference contract, and
  control records must remain synchronized. T006 does not alter this component
  or activate any successor automatically.
