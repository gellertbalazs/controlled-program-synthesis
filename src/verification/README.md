# Verification component contract

## Purpose

- SOURCE FACT — This directory implements the bounded, source-relative
  proof-record replay checker owned by
  [`T004`](../../tasks/done/T004-proof-kernel-skeleton.md).
- PROJECT INTERPRETATION — [`T006`](../../tasks/backlog/T006-reduction-vertical-slice.md)
  may reuse this component only through a later owner-approved ExecPlan.
- PROJECT INTERPRETATION — The checker is an independent acceptance boundary;
  it is not an inference engine or proof producer.

## Owning task(s)

- SOURCE FACT — [`T004 — Proof-kernel skeleton`](../../tasks/done/T004-proof-kernel-skeleton.md)
  is the primary owner.
- PROJECT INTERPRETATION — T006 is a later reuse owner only for scope
  explicitly approved by its own ExecPlan.

## Current state

- SOURCE FACT — The T004 checker is an implemented frozen candidate.
- PROJECT INTERPRETATION — This contract does not declare T004 accepted.
  Current progress, counters, eligibility, and verdict are authoritative only
  in the [`T004 task record`](../../tasks/done/T004-proof-kernel-skeleton.md).
- PROJECT INTERPRETATION — No T006 reuse is implemented or authorized by
  T004.

## Approved plans

- SOURCE FACT — T004 delivery is governed by the
  [`original approved plan`](../../docs/plans/T004-source-relative-identity-proof-replay-plan.md),
  [`fixture amendment`](../../docs/plans/T004-source-relative-identity-proof-replay-fixture-amendment-plan.md),
  and
  [`publication amendment`](../../docs/plans/T004-source-relative-identity-proof-replay-publication-amendment-plan.md).
- PROJECT INTERPRETATION — Any T006 reuse requires its own separately reviewed
  and explicitly approved plan.

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
  termination, or T006 reuse.
- PROJECT INTERPRETATION — `src/verify` is not a coexisting component or
  alias, and `src/proof` does not bypass the inference/verification split.

## Entry criteria

- SOURCE FACT — T004 entered delivery only after T002 and T003 acceptance and
  exact owner approval of its digest-bound plans.
- SOURCE FACT — T006 requires T002–T005 to be accepted.
- PROJECT INTERPRETATION — Any behavior or T006 reuse outside the frozen T004
  boundary requires a separately reviewed and explicitly approved plan.

## Required unit and integration evidence

- SOURCE FACT — The frozen T004 evidence covers accepted, malformed,
  unsupported, non-ground, attributed, cyclic, rejected, `UNKNOWN`, resource,
  priority, replay, trust/provenance/activation, determinism, input
  immutability, clean-process/status, and exclusion outcomes.
- PROJECT INTERPRETATION — Independent V1 and, only if reached, V2 must inspect
  the complete matrix and task ledger and run every approved verification
  gate. Any T006 reuse must add only evidence named by its later plan and
  [`T006 backlog contract`](../../tasks/backlog/T006-reduction-vertical-slice.md).

## Handoff

- PROJECT INTERPRETATION — This contract, the
  [canonical component matrix](../README.md), the inference contract, and
  control records must remain synchronized. T006 reuse and T005+ work do not
  activate automatically.
