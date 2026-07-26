# Architecture

Only the Phase 0 stage query exists. The intended architecture is:

```text
controlled English
  -> complete parse forest
  -> canonical ground typed Specification IR
  -> bounded proposal and search
  -> Program AST plus proof record
  -> independent deterministic acceptance
  -> content-free deterministic rendering
```

Specification IR records the requested behavior. A proof record records why a
candidate follows. The Program AST is the accepted, language-neutral program;
rendered text is only its deterministic projection.

Development, proposal/search, and trusted acceptance are separate planes.
Proposal components may return candidates but cannot authorize output. Every
process boundary requires a versioned representation, finite resource bounds,
and explicit failure statuses. The future trusted computing base is limited to
the parsers and deterministic checkers required to validate premises, proof
obligations, the final Program AST, and rendering.

No grammar, proof kernel, knowledge engine, synthesizer, verifier, renderer,
or teaching lifecycle is implemented yet.
