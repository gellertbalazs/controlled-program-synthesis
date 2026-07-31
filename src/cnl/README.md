# Controlled language component contract

## Purpose

- PROJECT INTERPRETATION — This directory owns the bounded controlled-English
  v0 boundary described by
  [`T005`](../../tasks/ready/T005-controlled-english-v0.md).
- SOURCE FACT — [`cps_controlled_english_v0.pl`](cps_controlled_english_v0.pl)
  parses one fixed pre-tokenized equality fragment into fresh T003
  Specification proposals.

## Owning task(s)

- SOURCE FACT — [`T005 — Controlled English v0`](../../tasks/ready/T005-controlled-english-v0.md)
  owns this component.

## Current state

- PROJECT INTERPRETATION — **IMPLEMENTED bounded contract; authoritative
  progress and verdict are in the T005 task record**. This component contract
  does not duplicate time-sensitive workflow state.

## Approved plan

- SOURCE FACT — The owner-approved delivery authority is the exact
  [`T005 rejected-V1 amendment ExecPlan`](../../docs/plans/T005-controlled-english-v0-rejected-v1-amendment-plan.md)
  at SHA-256
  `ab239fc3261a590d5f30436f0d35f0196b4927376efece492cc821444b162316`,
  incorporating the
  [original plan](../../docs/plans/T005-controlled-english-v0-plan.md) and
  [first amendment](../../docs/plans/T005-controlled-english-v0-amended-plan.md).

## Inputs and outputs

- SOURCE FACT — The sole public predicate is
  `validate_controlled_english_v0(+Tokens,+ProgramProposal,+AuthoritySnapshot,-Validation)`.
  `Tokens` is a ground acyclic list of exact lowercase atom tokens in the
  approved 20/22-token fragment; the 24-token form is only the bounded
  alternative sentinel.
- SOURCE FACT — `Validation` is
  `controlled_english_validation(Status,controlled_english_audit(Preflight,Parse,Candidates))`.
  Status is explicitly accepted, rejected, unsupported, `unknown`,
  resource-exhausted, or ambiguous.

## Trust boundary

- PROJECT INTERPRETATION — Parse output remains proposal data. Acceptance
  requires a fresh T003 check of every distinct proposal with the original
  Program proposal and authority snapshot; supplied accepted-looking terms
  and audits confer no authority.
- PROJECT INTERPRETATION — T005 acceptance establishes only a bounded
  validated Specification representation. It establishes no equality truth,
  proof, synthesis result, Program execution, or rendering authority.

## Allowed responsibilities

- PROJECT INTERPRETATION — The component may preflight the finite token
  structure, apply fixed native DCG clauses, enumerate and deduplicate all
  complete proposals, call T003 freshly, and classify the exact approved
  result lattice.

## Explicit non-goals

- SOURCE FACT — Tokenization, broad English, legacy compiler execution,
  inference, proof, synthesis, Program execution, persistence, network
  access, and rendering are outside T005.
- PROJECT INTERPRETATION — `src/ce` is not a coexisting component or alias.

## Entry criteria

- SOURCE FACT — T003, the relevant T004 validation contracts, ADR-0005, and
  the exact amended T005 plan were approved before the current delivery key.

## Required unit and integration evidence

- PROJECT INTERPRETATION — T005 requires the complete bounded unit interaction
  matrix, dedicated clean-process T005-to-T003 accepted/rejected/`UNKNOWN`/
  resource/ambiguity propagation, one frozen-candidate unit gate, and the
  finite independent acceptance gates recorded by the owning task.

## Handoff

- PROJECT INTERPRETATION — A completed T005 slice must synchronize this
  contract with the [canonical component matrix](../README.md) and control
  records, preserve explicit failure outcomes, and stop before T006.
