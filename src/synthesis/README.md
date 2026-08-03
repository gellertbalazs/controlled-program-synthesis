# Synthesis component contract

## Purpose

- PROJECT INTERPRETATION — This directory documents proposal-generation
  responsibilities for the bounded reduction slice described by
  [`T006`](../../tasks/ready/T006-reduction-vertical-slice.md).
- SOURCE FACT — The implementation is the root
  [`cps_fixed_left_reduction_v0.pl`](../cps_fixed_left_reduction_v0.pl)
  candidate; this directory contains no synthesizer module.

## Owning task(s)

- SOURCE FACT — [`T006 — Reduction vertical slice`](../../tasks/ready/T006-reduction-vertical-slice.md)
  owns this component.

## Current state

- PROJECT INTERPRETATION — **IMPLEMENTED I1 candidate in the root module;
  authoritative progress and verdict remain in the T006 task record**.

## Approved plan

- SOURCE FACT — The owner-approved authority is the exact
  [`focused-exhaustion amended plan`](../../docs/plans/T006-fixed-left-reduction-vertical-slice-amended-plan.md)
  at SHA-256
  `81e36851686ab1b6e20f38e38ba2cad0a0e49b484b3c2e11dae7fee82c763d86`,
  incorporating the
  [original plan](../../docs/plans/T006-fixed-left-reduction-vertical-slice-plan.md).

## Inputs and outputs

- SOURCE FACT — The sole proposal API is
  `propose_fixed_left_reduction_v0(+Tokens,-ProposalResult)`. It returns one
  bounded deterministic template proposal or an explicit rejected,
  unsupported, or resource-exhausted status and audit.

## Trust boundary

- PROJECT INTERPRETATION — Every synthesized or backend-produced candidate is
  proposal data. Independent proof acceptance and Program-AST verification
  remain outside this component's authority.

## Allowed responsibilities

- PROJECT INTERPRETATION — The root candidate owns only fixed grammar
  preflight and one deterministic left-nested proposal. It has no acceptance,
  proof, execution, or backend authority.

## Explicit non-goals

- SOURCE FACT — No search, solver, equality-saturation backend, proof
  authority, optional dependency, process boundary, persistence mechanism,
  or alternate proposal is authorized.
- PROJECT INTERPRETATION — `src/synth` is not a coexisting component or alias,
  and `src/patterns` is outside the approved T006 product boundary.

## Entry criteria

- SOURCE FACT — T006 requires T002–T005 to be accepted.
- SOURCE FACT — T002–T005 and both exact T006 plan digests were authenticated
  before the current I1 claim.

## Required unit and integration evidence

- PROJECT INTERPRETATION — The approved matrix covers all proposal fields,
  bounds, malformed and unsupported inputs, determinism, immutability, trust
  exclusions, and accepted/non-accepted clean-process propagation. Exact I1
  and verification evidence remains in the T006 task.

## Handoff

- PROJECT INTERPRETATION — A completed T006 I1 must synchronize
  this contract with the [canonical component matrix](../README.md), rendering
  and verification contracts, and control records, then stop before T007.
