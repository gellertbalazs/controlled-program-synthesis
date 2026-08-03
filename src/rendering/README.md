# Rendering component contract

## Purpose

- PROJECT INTERPRETATION — This directory documents deterministic,
  content-free rendering responsibilities for the bounded reduction slice
  described by [`T006`](../../tasks/ready/T006-reduction-vertical-slice.md).
- SOURCE FACT — Rendering is private to the root
  [`cps_fixed_left_reduction_v0.pl`](../cps_fixed_left_reduction_v0.pl)
  candidate; this directory contains no renderer module.

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

- SOURCE FACT — Rendering is not a public predicate. Successful verification
  returns `rendered_tokens(Rendered)` inside the checked bundle; singleton
  values render directly and each checked application renders canonical
  `combine`, parentheses, and comma tokens.

## Trust boundary

- PROJECT INTERPRETATION — Rendering must be content-free: it may expose only
  independently accepted structure and may not introduce, infer, repair, or
  authorize semantics.

## Allowed responsibilities

- PROJECT INTERPRETATION — The private renderer may traverse only the
  independently rebuilt accepted Program AST, enforce exact render bounds,
  and construct the canonical token list.

## Explicit non-goals

- SOURCE FACT — No semantic optimizer, code generator, target runtime,
  serializer, alternate syntax, escaping policy, or backend is authorized.
- PROJECT INTERPRETATION — `src/render` is not a coexisting component or
  alias.

## Entry criteria

- SOURCE FACT — T006 requires T002–T005 to be accepted.
- SOURCE FACT — T002–T005 and both exact T006 plan digests were authenticated
  before the current I1 claim.

## Required unit and integration evidence

- PROJECT INTERPRETATION — The approved matrix covers exact accepted output,
  render token/scalar boundaries, malformed and non-accepting upstream paths,
  determinism, immutability, and clean-process propagation. Exact evidence
  remains in the T006 task.

## Handoff

- PROJECT INTERPRETATION — A completed T006 I1 must synchronize
  this contract with the [canonical component matrix](../README.md), synthesis
  and verification contracts, and control records, then stop before T007.
