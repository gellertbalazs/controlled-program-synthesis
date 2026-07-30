# Controlled language component contract

## Purpose

- PROJECT INTERPRETATION — This directory reserves the controlled-language
  boundary described by [`T005`](../../tasks/ready/T005-controlled-english-v0.md).
- SOURCE FACT — The directory contract is not a grammar, parser, or semantic
  implementation.

## Owning task(s)

- SOURCE FACT — [`T005 — Controlled English v0`](../../tasks/ready/T005-controlled-english-v0.md)
  owns this component.

## Current state

- PROJECT INTERPRETATION — **PENDING**. The reserved contract exists; T005
  behavior does not.

## Approved plan

- SOURCE FACT — **no approved ExecPlan yet**. A future task-specific T005
  ExecPlan is the required implementation authority.

## Inputs and outputs

- HYPOTHESIS — UNKNOWN. Input terms, output terms, predicate names, data
  formats, and ambiguity policy remain unapproved until the T005 ExecPlan.

## Trust boundary

- PROJECT INTERPRETATION — Any future parse is proposal data and cannot by
  itself establish a validated Specification IR, a proof, or program
  authority.

## Allowed responsibilities

- PROJECT INTERPRETATION — After plan approval, this component may assume only
  the controlled-language responsibilities explicitly bounded by T005 and
  that plan.

## Explicit non-goals

- SOURCE FACT — No controlled-English fragment, grammar, parser, semantic
  normalization, legacy execution, or synthesis behavior is authorized now.
- PROJECT INTERPRETATION — `src/ce` is not a coexisting component or alias.

## Entry criteria

- SOURCE FACT — T005 requires T003 and the relevant T004 validation contracts
  to be accepted.
- PROJECT INTERPRETATION — Owner approval of a task-specific T005 ExecPlan is
  required before product or test changes.

## Required unit and integration evidence

- PROJECT INTERPRETATION — The future T005 ExecPlan must name focused unit
  evidence and the text-to-Specification-IR integration evidence required by
  the [`T005 planning contract`](../../tasks/ready/T005-controlled-english-v0.md);
  the complete repository unit, integration, and canonical gates must pass.

## Handoff

- PROJECT INTERPRETATION — A completed T005 slice must synchronize this
  contract with the [canonical component matrix](../README.md) and control
  records, preserve explicit failure outcomes, and stop before T006.
