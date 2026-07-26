# Controlled Program Synthesis

This is a bootstrap-only SWI-Prolog project for a proof-oriented
controlled-English program synthesizer. It does not yet contain a grammar,
semantic parser, knowledge kernel, prover, synthesizer, verifier, renderer, or
teaching engine.

## Intended product

The intended product will translate a strictly controlled subset of English
into deterministic pseudocode through typed intermediate representations,
explicit proof obligations, independent verification, and a renderer that
adds no algorithmic content.

```text
controlled English -> complete parses -> typed Specification IR
-> proof and pattern refinement -> verified Program AST
-> deterministic pseudocode
```

Optional solvers, proof assistants, and AI systems are untrusted proposal
sources unless a later task qualifies their exact versions, representations,
resource bounds, and independently checked evidence.

## Safety boundary

Final output may eventually be emitted only when every used premise is active
and trusted, every obligation is accepted, the Program AST passes independent
verification, and rendering adds no semantic content. Missing or insufficient
evidence must produce an explicit status such as `UNKNOWN`, `AMBIGUOUS`,
`RESOURCE_LIMIT`, or `UNSUPPORTED_INPUT`.

User or knowledge data must never become an arbitrary Prolog goal, clause, or
database mutation. The project makes no claim of absolute hallucination
freedom; its intended guarantee is relative to its explicit source fragment,
premises, rules, and trusted checkers.

## Current verified product state

Phase 0 exposes one non-domain predicate,
`cps_bootstrap:bootstrap_stage/1`, which deterministically reports `phase0`.
No synthesis claim is made.

```sh
swipl -f none -q -s src/cps_bootstrap.pl -g "cps_bootstrap:bootstrap_stage(S),write_canonical(S),nl,halt"
```

Five research inputs inform future work: one NLP/Prolog text, two legacy
Prolog artifacts treated only as inert evidence, and two *Elements of
Programming* references. They are not production modules or published source.

## Navigation

- [Product architecture](docs/architecture/README.md)
- [Safety and decision policy](docs/decisions/README.md)
- [Evaluation boundary](docs/evaluation/README.md)
- [Reference roles](docs/reference/README.md)
- [Knowledge areas](knowledge/README.md)
- [Source layout](src/README.md)
- [Test layout](tests/README.md)
- [Future benchmark corpus](benchmarks/README.md)

No license or copyright grant has been added.
