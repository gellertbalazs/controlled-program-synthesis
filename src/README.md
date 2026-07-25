# Production Source

Phase 0 contains one tiny SWI-Prolog module that reports the
infrastructure-only bootstrap stage. It contains no parser, prover,
synthesizer, verifier, renderer, or teaching logic.

The remaining subdirectories describe intended ownership boundaries:
[controlled language](cnl/README.md), [representations](ir/README.md),
[knowledge](knowledge/README.md), [inference](inference/README.md),
[synthesis](synthesis/README.md), [verification](verification/README.md),
[rendering](rendering/README.md), and [dialogue](dialogue/README.md).
