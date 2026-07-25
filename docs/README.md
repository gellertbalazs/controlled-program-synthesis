# Controlled Program Synthesis Documentation

This repository is in an infrastructure-only bootstrap state. It does not yet
contain a parser, prover, synthesizer, verifier, renderer, or teaching engine.

The intended product accepts a deliberately controlled specification language,
constructs a ground typed specification representation, searches for a ground
Program AST, and authorizes rendered output only after independent checking.
Untrusted models, solvers, evaluators, and search engines may eventually propose
candidates; none is a default trust root.

- [Architecture](architecture/README.md)
- [Decision records](decisions/README.md)
- [Evaluation](evaluation/README.md)
- [Source evidence](reference/README.md)
- [Knowledge representation](../knowledge/README.md)
- [Production source layout](../src/README.md)
- [Test layout](../tests/README.md)

The only implemented product behavior is the machine-readable Phase 0 stage
reported by `src/cps_bootstrap.pl`.
