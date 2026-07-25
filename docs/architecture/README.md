# Architecture

The intended architecture separates controlled input, ground internal
representations, untrusted proposal mechanisms, and a small trusted acceptance
path. Phase 0 implements only the bootstrap-stage marker; the remaining material
describes the planned product boundary.

Stable safety rules:

- user text never becomes an arbitrary Prolog goal;
- final code is rendered from a checked ground Program AST;
- unsupported, undefined, incomplete, timed-out, or exhausted work is not
  silently accepted;
- external tools and language models may propose evidence but are not proof
  authorities by default;
- immutable sources remain evidence, not runtime dependencies.

The intended pipeline is controlled text to a ground typed Specification IR,
untrusted candidate search, independent bounded checking, a checked ground
Program AST, and deterministic rendering. The product trust boundary and
detailed working design remain proposals until later tasks implement and
verify them.
