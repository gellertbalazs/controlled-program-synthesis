# Controlled Program Synthesis

This repository is a bootstrap-only SWI-Prolog project for a proof-oriented
controlled-English program synthesizer. It does not yet contain a grammar,
semantic parser, knowledge kernel, prover, synthesizer, verifier, renderer, or
teaching engine.

## Goal

The intended product will translate a strictly controlled subset of English
into deterministic pseudocode through typed intermediate representations,
explicit proof obligations, independent verification, and a renderer that adds
no algorithmic content.

The intended pipeline is:

```text
controlled English -> complete parses -> typed Specification IR
-> proof and pattern refinement -> verified Program AST
-> deterministic pseudocode
```

Runtime use of an LLM or network service is not part of the product baseline.
Optional solvers or proof assistants are proposal or checking backends only
after separate qualification and approval.

## Safety Boundary

Final pseudocode may be emitted only when every premise is active and trusted,
every required obligation has an accepted proof or certificate, the Program
AST passes independent verification, and rendering adds no algorithmic
content. Otherwise the system must return an explicit status such as
`UNKNOWN`, `AMBIGUOUS`, `CONTRADICTION`, `RESOURCE_LIMIT`, or
`UNSUPPORTED_INPUT`.

Missing knowledge is not falsity. User-derived data must never become an
arbitrary Prolog goal, clause, or database mutation.

## Current Verified Product State

Phase 0 exposes one non-domain predicate,
`cps_bootstrap:bootstrap_stage/1`, which reports that the repository contains
infrastructure only. No synthesis claim is made.

From a clean clone with SWI-Prolog installed, the tracked smoke module can be
queried with:

```sh
swipl -f none -q -s src/cps_bootstrap.pl -g "cps_bootstrap:bootstrap_stage(S),write_canonical(S),nl,halt"
```

The full local quality gate is intentionally not published as product source.

## Source Roles

The local evidence set contains an NLP/Prolog reference, two educational
legacy Prolog artifacts, the contextual *Elements of Programming* text, and a
compact EoP concept reference. The originals are immutable local evidence and
are not production modules. See [references](references/README.md).

## Navigation

- [Product architecture](docs/architecture/README.md)
- [Safety and decisions](docs/decisions/README.md)
- [Evaluation boundary](docs/evaluation/README.md)
- [Reference roles](docs/reference/README.md)
- [Knowledge areas](knowledge/README.md)
- [Source layout](src/README.md)
- [Test layout](tests/README.md)
- [Future benchmark corpus](benchmarks/README.md)

## License

No license or copyright grant has been added.
