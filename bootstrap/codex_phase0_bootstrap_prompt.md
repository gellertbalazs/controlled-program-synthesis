# Codex Phase 0 Bootstrap Prompt

Use this file as a one-time execution brief. Open the project root in VS Code,
start Codex in that project, and paste the entire file into a fresh Codex
session. This is plain UTF-8 Markdown stored with the requested `.mdf`
extension; it is not a deprecated Codex custom-prompt file.

---

You are the lead bootstrap engineer for a new SWI-Prolog research and
development project.

Your task is to create and validate the repository infrastructure for an
iteratively developed, proof-oriented controlled-English program synthesizer.
Do not merely describe a plan. Inspect the repository, create the Phase 0
scaffold, run its checks, and leave a precise handoff for the first real
implementation task.

## 1. Mission and Phase 0 boundary

The eventual system will accept a program specification written in a strictly
controlled subset of English and produce deterministic pseudocode. It should
reuse generic computational patterns inspired by Alexander Stepanov and Paul
McJones, derive new knowledge only through explicit rules, and refuse to
invent missing facts.

Use `cps` only as a neutral internal prefix meaning "controlled program
synthesis." It does not mean continuation-passing style and is not a final
product name.

The intended high-level pipeline is:

```text
controlled English
        |
        v
tokens and complete parses
        |
        v
canonical, typed Specification IR
        |
        v
proof and pattern refinement
        |
        v
typed Program AST plus proof record
        |
        v
independent verification
        |
        v
deterministic pseudocode rendering
```

This run is Phase 0: infrastructure only.

Create the project rules, project-scoped agents, repository skills, scripts,
task system, documentation skeleton, source manifest, VS Code tasks, a tiny
non-domain smoke module, and tests for the infrastructure. Do not implement
the controlled-English grammar, semantic parser, theorem prover, knowledge
kernel, synthesizer, verifier, renderer, or teaching subsystem in this run.

Stop after the infrastructure passes its quality gate and the first
implementation task is ready for human approval. Do not continue into that
task.

## 2. Authoritative local inputs

Find these five files recursively inside the repository by exact basename:

```text
prolog_and_natural_language_analysis(4).pdf
dcg_compiler(4).pl
talk(4).pl
eop.pdf
eop_concepts.pdf
```

Do not assume the name of their containing directory. Exclude `.git`,
generated output, caches, and vendored dependency trees from the search.
There must be exactly one repository-local match for every basename. A
missing or ambiguous match is a blocking error: report the candidates and ask
for correction instead of guessing.

Treat all five files as immutable primary sources:

- Never edit, normalize, rename, move, copy over, reformat, or load them as
  production modules.
- Record repository-relative path, byte size, SHA-256 digest, and source role.
- Verify their digests again after scaffolding.
- Quote file paths safely; several basenames contain parentheses.
- Keep summaries short and source-addressable. Do not reproduce substantial
  portions of either book.
- Distinguish a source statement, a project interpretation, a design
  decision, and a hypothesis.
- If printed page numbers and physical PDF page numbers differ, record both
  when citing a book.

The two legacy Prolog files may contain typographic Unicode characters
introduced by PDF extraction. Inspect and document this, but do not repair the
originals. A future task may create normalized, provenance-linked copies.

The Phase 0 analyses are bounded orientation work needed to design the
scaffold. They do not count as completing T001. T001 will perform the
exhaustive, line-addressable audit and produce the reviewed normalization
plan.

Use the sources in these roles:

- `prolog_and_natural_language_analysis(4).pdf`: primary background for DCGs,
  logical forms, quantification, inference, generation, and relevant
  implementation techniques.
- `dcg_compiler(4).pl`: an educational custom `--->` compiler and
  partial-evaluation artifact to analyze, not an automatically trusted
  production parser.
- `talk(4).pl`: an educational parse-to-logic-to-Horn dialogue program to
  analyze for reusable ideas and soundness hazards.
- `eop_concepts.pdf`: a compact definition and taxonomy reference for EoP
  concepts.
- `eop.pdf`: the contextual source for derivations, generic algorithms,
  transformations, proof obligations, and algorithm selection.

Do not claim that the exact phrase or formal unit "computational pattern" is
defined by either EoP source unless the local text supports that claim. In
this project, it is a project-level synthesis abstraction informed by EoP.

## 3. Environment and authorization constraints

Assume SWI-Prolog is installed and available from the VS Code terminal.
Confirm this with:

```text
swipl --version
```

Then record the actual version. Use portable SWI-Prolog entry points for
project checks.

Unless the user explicitly authorizes otherwise:

- Do not initialize Git.
- Do not commit, push, create branches, or modify remotes.
- Do not install packages or download dependencies.
- Do not use an LLM, OpenAI API, embedding service, vector database, or
  network service at runtime.
- Do not invent a license or copyright grant.
- Do not create secrets, credentials, telemetry, or external accounts.
- Preserve every unrelated existing file and every existing uncommitted
  change.
- Inspect an existing file before editing it. Merge conservatively and
  idempotently; never replace unrelated content.
- If an existing project convention conflicts materially with this brief,
  stop and explain the exact conflict.

Use only repository-local paths in generated project files. Prefer
cross-platform Prolog and JSON over shell-specific wrappers. Add a shell or
PowerShell wrapper only if the inspected environment genuinely needs one.

## 4. Bootstrap execution protocol

Follow this order:

1. Inspect the repository tree, the complete applicable instruction chain
   including `AGENTS.override.md` and `AGENTS.md`, `.codex` files, Git status
   if it is already a Git repository, and existing build/test conventions.
   A material conflict in a higher-precedence instruction is blocking.
2. Resolve the five primary sources and capture their initial hashes.
3. Verify SWI-Prolog.
4. In parallel, delegate two bounded, read-only analyses:
   - one analysis of the three NLP/Prolog sources;
   - one analysis of the two EoP sources.
5. Require each analyst to return concise findings with source locations,
   reusable ideas, hazards, and open questions. Wait for both.
   If subagent spawning is unavailable on the active Codex surface, perform
   the same two analyses sequentially and record that fallback in the handoff.
6. Synthesize their results before writing architecture and task documents.
7. Keep a single writer: only the lead agent edits repository files during
   this bootstrap.
8. Create or conservatively merge the scaffold described below.
9. Run all deterministic checks and fix bootstrap defects.
10. Recompute the five source hashes and compare them with the initial
    manifest.
11. Review the final diff or file set for accidental domain implementation,
    unsupported claims, secrets, and unrelated changes.
12. Report the outcome and stop.

Ask a question only when an answer is truly blocking. Otherwise make the
smallest reversible choice, label it, and continue.

The project-scoped agents and skills created during this run might require a
fresh Codex session before Codex discovers them. Do not pretend to use a newly
created agent in the same session if it is not actually available.

## 5. Required semantic guardrails

Document these as project invariants. They are requirements for later phases,
not features to implement now.

### 5.1 Source-relative soundness

Do not promise absolute "hallucination freedom." State the enforceable
boundary:

> The system may emit final pseudocode only when every used premise belongs
> to the active trusted knowledge base, every required obligation has an
> accepted proof or certificate, the generated Program AST passes independent
> verification, and the renderer adds no algorithmic content.

If that condition is not met, the result must be explicit, such as:

```text
PROVED
DISPROVED
UNKNOWN
AMBIGUOUS
CONTRADICTION
RESOURCE_LIMIT
UNSUPPORTED_INPUT
```

Do not use negation-as-failure to silently turn missing knowledge into
falsity.

### 5.2 Controlled input

- Require complete token consumption.
- Zero accepted meanings means `UNSUPPORTED_INPUT`.
- More than one distinct canonical meaning means `AMBIGUOUS`.
- Do not hide ambiguity with a first-parse cut.
- Do not silently extend the controlled language.
- Persist only validated, typed, canonical, ground IR.
- Represent object-language variables explicitly, for example the ground term
  `var(x)`;
  never persist unbound host-Prolog variables as semantic data.

### 5.3 Safe knowledge and execution

- Never pass user-derived terms directly to `assert/1`, `assertz/1`,
  `retract/1`, `call/1`, or other unrestricted meta-execution.
- Keep source facts separate from derived caches.
- Attach provenance, evidence kind, version, trust state, and activation state
  to every teachable law, model, pattern, and derivation.
- Treat newly proposed knowledge as quarantined or candidate knowledge until
  validation, counterexamples, review, and activation succeed.
- Bound proof search by explicit depth, inference, time, or table limits.
- Detect cycles and contradictions.
- Allow the renderer to consume only a verified Program AST. It must not
  invent a missing condition, loop, assignment, or operation.

## 6. EoP-informed computational pattern model

The central reusable unit is not a pasted code fragment. Document a
computational pattern as a parameterized, proof-carrying algorithm schema:

```prolog
pattern(
    Id,
    pattern{
        origin: Origin,
        evidence_kind: EvidenceKind,
        review_status: ReviewStatus,
        activation_status: ActivationStatus,
        trust_policy: TrustPolicy,
        intent: Intent,
        parameters: Parameters,
        requires: ConceptRequirements,
        associated_types: AssociatedTypeConstraints,
        operations: RequiredOperations,
        laws_used: LawsUsed,
        preconditions: ObjectConditions,
        ensures: Postcondition,
        effects: Effects,
        aliasing: AliasingConditions,
        ast_template: ProgramAst,
        invariants: Invariants,
        variant: TerminationMeasure,
        proof_schema: ProofSchema,
        cost: CostModel,
        alternatives: AlternativeIds,
        provenance: Provenance
    }
).
```

Document concepts separately:

```prolog
concept(
    Name,
    concept{
        parameters: Parameters,
        refines: ParentConcepts,
        signatures: RequiredOperations,
        associated_types: AssociatedTypes,
        axioms: SemanticLaws,
        definedness: DefinednessConditions,
        termination: TerminationRequirements,
        complexity: ComplexityRequirements
    }
).
```

The capitalized terms in both snippets are documentation metavariables, not
host-Prolog variables to persist. Every stored instance must be validated and
ground; object-language variables must use explicit ground constructors such
as `var(x)`.

The design notes must preserve these distinctions:

- concept requirements versus runtime preconditions on a particular object;
- host-Prolog unification versus object-language equality;
- operation availability versus definedness for a particular input;
- semantic correctness versus termination versus complexity;
- a concept definition versus a model or instance of that concept;
- a declared law versus tested evidence versus an accepted proof;
- applicability filtering versus cost-based ranking;
- fixed-order fold semantics versus reorderable associative reduction.

Do not infer associativity, commutativity, identity, exact arithmetic, or
aliasing safety from an operator name such as `+` or `*`.

Define the future selection order as:

```text
find candidate patterns
        |
        v
discharge concept and input requirements
        |
        v
instantiate and verify proof obligations
        |
        v
reject unsafe or unsupported candidates
        |
        v
rank verified candidates by requested cost/resource policy
```

At minimum, the knowledge architecture must reserve distinct locations for:

```text
concepts
axioms
models
associated types
computational bases
patterns
verified transformations
cost models
proof records
provenance and trust metadata
```

The teaching lifecycle must be documented as:

```text
propose -> parse -> type-check -> validate -> seek counterexamples
        -> review -> activate -> use -> version or retract
```

Candidate or test-only knowledge must never authorize final synthesis.
New trusted derived knowledge may enter the active closure only through
declared sound inference rules over active premises, with a replayable proof
tree or proof DAG. Generalizations suggested by examples remain candidates,
not derived truths.

## 7. Required repository scaffold

Adapt names only when an existing repository convention clearly requires it.
Do not create empty directories without a meaningful README or tracked file.
The resulting structure should contain the following logical components:

```text
AGENTS.md
PLANS.md
README.md
CONTRIBUTING.md
ROADMAP.md
STATUS.md
DECISIONS_NEEDED.md
.gitignore

.codex/
  README.md
  config.toml
  agents/
    cps_source_analyst.toml
    cps_pattern_analyst.toml
    cps_architect.toml
    cps_soundness_reviewer.toml

.agents/
  skills/
    cps-analyze-sources/
      SKILL.md
      references/source-citation-policy.md
    cps-plan-slice/
      SKILL.md
      references/plan-checklist.md
    cps-implement-slice/
      SKILL.md
      references/definition-of-done.md
    cps-verify-slice/
      SKILL.md
      references/review-checklist.md

.vscode/
  tasks.json

docs/
  architecture/
    overview.md
    safety-model.md
    computational-patterns.md
    knowledge-lifecycle.md
  decisions/
    README.md
    TEMPLATE.md
    ADR-0001-source-authority.md
    ADR-0002-ground-typed-object-language-ir.md
    ADR-0003-proof-carrying-computational-patterns.md
    ADR-0004-immutable-reference-materials.md
    ADR-0005-native-dcg-first.md
  reference/
    source-map.md
    source-integrity.md
    nlp-prolog-risk-map.md
    eop-orientation.md
  plans/
    README.md
    TEMPLATE.md
  glossary.md
  quality-gates.md
  ci.md

config/
  reference_manifest.json

tasks/
  README.md
  TEMPLATE.md
  ready/
    T001-source-audit-and-normalization-plan.md
  backlog/
    T002-knowledge-metamodel.md
    T003-spec-and-program-ir.md
    T004-proof-kernel-skeleton.md
    T005-controlled-english-v0.md
    T006-reduction-vertical-slice.md
    T007-teaching-lifecycle.md
  done/
    README.md

knowledge/
  README.md
  concepts/README.md
  axioms/README.md
  models/README.md
  bases/README.md
  patterns/README.md
  transformations/README.md
  costs/README.md
  proofs/README.md
  provenance/README.md

scripts/
  cps_checks.pl
  doctor.pl
  test.pl
  check.pl
  check_reference_integrity.pl
  check_source_text.pl

src/
  AGENTS.md
  README.md
  cps_bootstrap.pl
  cnl/README.md
  ir/README.md
  knowledge/README.md
  inference/README.md
  synthesis/README.md
  verification/README.md
  rendering/README.md
  dialogue/README.md

tests/
  AGENTS.md
  README.md
  bootstrap_tests.pl
```

If the five primary sources share a non-root directory, add or conservatively
merge an `AGENTS.md` in that directory that marks those exact files read-only.
Do not create a second copy of the sources under a new `references` directory.

Create `.github/workflows/ci.yml` only if the repository already uses GitHub
or has an unambiguous GitHub remote/convention. Otherwise, do not guess a CI
provider; document that CI should execute the canonical quality gate.

Do not create `.codex/prompts`, `~/.codex/prompts`, or slash-command custom
prompt infrastructure. Repository skills are the supported reusable workflow
mechanism. Do not activate repository hooks in Phase 0. A future optional
hook may call the stable quality gate after the user explicitly accepts its
trust and maintenance cost.

## 8. Codex project infrastructure requirements

### 8.1 Root and nested `AGENTS.md`

Keep the root file concise and operational. It must state:

- project purpose and current Phase 0 status;
- the rule for resolving the five sources;
- source immutability and citation rules;
- mandatory separation of source fact, interpretation, decision, and
  hypothesis;
- source-relative soundness and explicit `UNKNOWN`;
- one writing agent at a time;
- no arbitrary host-Prolog execution from user or knowledge data;
- the canonical doctor, test, and check commands;
- one backlog task per implementation session;
- PlUnit coverage and negative tests for every Prolog module;
- ADR updates for architectural changes;
- the definition of done;
- the ExecPlan rule below.

Include this policy in substance:

```text
For every non-trivial vertical slice or architectural change, create and
maintain an ExecPlan following PLANS.md. Domain implementation may start only
after the plan is explicitly approved by the user.
```

Nested `AGENTS.md` files must add only subtree-specific rules and must not
contradict the root.

### 8.2 `PLANS.md`

Make `PLANS.md` a self-contained standard for living execution plans. Require:

```text
Status: Draft | Approved | Implemented | Verified
Purpose and user-visible outcome
Source evidence
Scope and non-goals
Terminology
Interfaces and predicate contracts
Knowledge representation
Soundness and proof obligations
Milestones
Progress checklist
Validation commands
Acceptance tests
Decision log
Discoveries and surprises
Recovery or rollback notes
```

Plans must be updated while work proceeds, not reconstructed afterward.

### 8.3 `.codex/config.toml`

Create a minimal project configuration, unless an existing config requires a
safe merge:

```toml
[agents]
enabled = true
max_concurrent_threads_per_session = 4
```

Do not pin a model. Explain in `.codex/README.md` that project configuration
is honored only for a trusted project and is normally discovered in a fresh
session.

### 8.4 Project-scoped custom agents

Create four narrow, read-only specialists. Every TOML file must contain at
least `name`, `description`, `sandbox_mode = "read-only"`, and
`developer_instructions`. Do not pin models.

Their responsibilities are:

1. `cps_source_analyst`
   - Analyze the NLP book and legacy Prolog artifacts.
   - Return source-addressable facts, reusable mechanisms, hazards, and open
     questions.

2. `cps_pattern_analyst`
   - Analyze EoP concepts, laws, generic algorithms, transformations, and cost
     requirements.
   - Clearly label explicit source content versus project-derived patterns.

3. `cps_architect`
   - Review one proposed vertical slice, module boundaries, IR contracts,
     dependencies, and proof obligations.
   - Produce advice only; do not modify files.

4. `cps_soundness_reviewer`
   - Attempt to falsify a proposed change.
   - Check ambiguity, partiality, termination, provenance, explicit unknowns,
     unsafe meta-execution, and missing negative or countermodel tests.

The lead Codex session remains the only writer. Future sessions may run
read-only analyses in parallel, but must wait for them before editing.

### 8.5 Repository skills

Create four project-prefixed skills under `.agents/skills`. Each `SKILL.md`
must have valid YAML front matter with a unique `name` and a precise
trigger-oriented `description`. Keep the body focused and place longer
checklists in the named `references` file.

The skills form this gated workflow:

```text
$cps-analyze-sources
          |
          v
$cps-plan-slice -> Draft ExecPlan
          |
          v
explicit human approval
          |
          v
$cps-implement-slice
          |
          v
$cps-verify-slice
          |
          v
stop and report; do not take the next task
```

Every skill must specify:

- required inputs;
- allowed and forbidden changes;
- exact expected outputs;
- validation commands;
- stop conditions;
- how unresolved proof obligations are reported.

Wire the skills to the agents instead of leaving the agents decorative:

- `$cps-analyze-sources` delegates the two source families to
  `cps_source_analyst` and `cps_pattern_analyst` in parallel, then waits for
  both.
- `$cps-plan-slice` delegates a read-only plan review to `cps_architect`.
- `$cps-implement-slice` is executed by the lead writer only.
- `$cps-verify-slice` delegates adversarial review to
  `cps_soundness_reviewer`, waits for it, and preserves unresolved findings.

If a named custom agent has not been discovered in the active session, the
skill must report that fact and give the exact restart action; it must not
pretend that delegation occurred.

The implementation skill must refuse to start without an approved ExecPlan.
The verification skill must be read-oriented and adversarial; it must never
turn a failing obligation into an assumption.

## 9. Documentation requirements

Keep documents concise, useful, and cross-linked. Prefer small diagrams,
tables, contracts, and examples over vague prose.

### 9.1 Architecture

`docs/architecture/overview.md` must show the complete intended pipeline,
trust boundaries, module ownership, and the distinction between specification
IR, proof records, Program AST, and rendered text.

`safety-model.md` must list the invariants in Section 5 and state what the
system can and cannot guarantee.

`computational-patterns.md` must contain the schemas and distinctions in
Section 6, plus one illustrative candidate pattern. Label the example as
unimplemented and project-derived.

`knowledge-lifecycle.md` must describe teaching, validation, evidence classes,
activation, versioning, contradiction handling, and retraction.

Do not flatten provenance, evidence, review, activation, and trust into one
"status" enumeration. Document them as independent dimensions:

```text
origin:
  source_explicit | source_derived | project_derived

evidence_kind:
  declaration | proof_certificate | finite_exhaustive_check | tests_only

review_status:
  candidate | accepted | rejected | superseded

activation_status:
  quarantined | inactive | active

trust_policy:
  a named policy plus derivation and proof references
```

Only evidence that is accepted, active, and sufficient under the named trust
policy may authorize final synthesis.

### 9.2 Source notes

`config/reference_manifest.json` is the sole machine-readable source
manifest. Make it inert data with a documented schema and one complete object
per source: exact basename, repository-relative path, byte size, lowercase
SHA-256 digest, and source role. Reject duplicate keys, missing fields,
unexpected entries, absolute paths, and paths that escape the project.
`source-integrity.md` is only its human-readable projection; checks must never
parse Markdown or rewrite the canonical manifest. Record the bootstrap
timestamp in the document without making verification depend on that
timestamp. The source map must explain the role and authority of each file.

Keep Phase 0 reference notes bounded to inventory, page mapping, source roles,
and a concise risk/opportunity map. `eop-orientation.md` must introduce, but
not exhaustively catalog, these distinctions:

```text
concept
model or instance
operation
associated type
property or law
definedness condition
runtime precondition
postcondition
effect and aliasing condition
termination requirement
complexity requirement
refinement
computational pattern
evidence and provenance
```

State that future refinement must be a graph, including conjunction or
intersection, not a forced single-inheritance tree. Preserve source-specific
definitions; do not silently replace them with conventional algebraic
terminology.

The legacy Prolog risk map must record, with source locations:

- what is reusable from the DCG, logical-form, Horn-clause, query, and
  partial-evaluation ideas;
- why raw assertion, unrestricted calls, first-parse cuts, and
  negation-as-failure are unsuitable for the target trust boundary;
- visible encoding or extraction anomalies found by static reading;
- the deeper loadability, normalization, and porting work deferred to T001.

Do not create the exhaustive EoP concept catalog, refinement graph, pattern
catalog, coverage matrix, or normalization specification in Phase 0. Make
those explicit deliverables or subtasks of T001 and T002.

### 9.3 Proposed ADRs

Create the listed ADRs with status `Proposed`, not silently accepted:

1. Source authority and the boundary between explicit and derived knowledge.
2. Ground, typed object-language IR with explicit variables and equality.
3. Computational pattern as AST template plus contracts, proof schema, and
   cost model.
4. Immutable originals and provenance-linked normalized copies.
5. Native SWI-Prolog DCGs first; evaluate the educational custom DCG compiler
   later as an optional optimization or research artifact.

Each ADR must include context, decision proposal, consequences, rejected or
deferred alternatives, and the evidence still needed for approval.

### 9.4 README and handoff documents

The root README must honestly say that the repository is bootstrap-only and
contains no synthesizer yet. Include:

- project goal and non-goals;
- source roles;
- architecture overview;
- quick-start commands;
- exact skill invocation sequence;
- task and ExecPlan workflow;
- safety boundary;
- trust/restart note for `.codex`;
- current status and recommended next task.

Do not imply that a VS Code task is itself an autonomous agent workflow.

`STATUS.md` must summarize only verified current capabilities.
`DECISIONS_NEEDED.md` must list choices that need human approval.

## 10. Task system and initial backlog

Every task file must include:

```text
ID and status
goal and user-visible outcome
source evidence
dependencies
allowed files
forbidden or out-of-scope work
deliverables
acceptance criteria
verification commands
risks and proof obligations
decisions required
handoff and stop condition
```

Create exactly one Phase-0-created CPS task in `tasks/ready`. Preserve any
unrelated pre-existing task system and its ready tasks.

### T001 - Source audit and normalization plan

It may analyze encoding, operators, dependencies, unsafe constructs,
loadability, and a provenance-preserving normalization strategy. It must not
modify the five originals and must not yet port them into production.

T001 must begin with static analysis. Phase 0 must never consult or execute
either legacy Prolog file. If T001 later needs a loadability experiment, its
approved ExecPlan must isolate that experiment in a child SWI-Prolog process
using `-f none`, a strict timeout, captured output, a controlled working
directory, and no access to production state. A failed or side-effectful
experiment must not contaminate the main session.

T001 must own the exhaustive, line-addressable legacy audit and normalization
plan. T002 must own the detailed EoP knowledge taxonomy, concept catalog,
refinement graph, pattern catalog, object-language encoding rules, trust
model, and coverage matrix.

Create these dependent backlog tasks:

- T002 - Knowledge metamodel for concepts, models, laws, evidence, patterns,
  proofs, and costs.
- T003 - Typed Specification IR and Program AST design.
- T004 - Small proof-kernel skeleton with bounded inference and explicit
  outcomes.
- T005 - Controlled-English v0 for one tiny specification domain.
- T006 - One end-to-end reduction vertical slice.
- T007 - Teaching lifecycle with candidate quarantine and activation.

State dependencies explicitly. Keep T002 through T007 in backlog, not ready.
Do not create implementation code for them.

For T006, document this important future test:

- A fixed-order left fold does not require associativity when that order is
  part of the specification.
- Reassociation, tree reduction, or parallel reduction does require an
  accepted associativity law.

## 11. Deterministic scripts and VS Code tasks

Create portable, non-interactive SWI-Prolog entry points:

```text
swipl -q -s scripts/doctor.pl
swipl -q -s scripts/test.pl
swipl -q -s scripts/check.pl
```

Each executable entry point must use a proper `initialization(Main, main)`
entry and must halt deterministically with a meaningful exit code; none of
the commands may fall through to an interactive Prolog prompt.

Put reusable check predicates in the non-executable module
`scripts/cps_checks.pl`. The three executable entry points must call that
module rather than consult or invoke one another as scripts.

Required behavior:

- `doctor.pl`
  - reports the SWI-Prolog version;
  - locates all five source files exactly once;
  - confirms readability, byte sizes, hashes, and static text anomalies;
  - never consults or executes either legacy Prolog file;
  - uses a nonzero exit status for missing/ambiguous sources or an unusable
    project environment.

- `test.pl`
  - discovers `tests/**/*_tests.pl` recursively, sorts the paths
    lexicographically, then loads and runs them explicitly;
  - returns a nonzero exit status on any failure.

- `check_reference_integrity.pl`
  - verifies the current five files against
    `config/reference_manifest.json`;
  - treats any mismatch as a failure;
  - never rewrites the manifest during a check.

- `check_source_text.pl`
  - checks production Prolog and project metadata for accidental typographic
    punctuation or known extraction artifacts;
  - excludes the immutable primary sources and clearly documented prose where
    appropriate;
  - returns actionable file and line diagnostics.

- `check.pl`
  - is the single canonical quality gate;
  - composes environment checks, manifest integrity, production module
    load-checking, PlUnit tests, structural checks, and source-text checks;
  - exits nonzero if any required check fails.

The only Phase 0 source module may be a tiny `cps_bootstrap` module that
reports a machine-readable bootstrap stage. Its test exists solely to prove
that module loading and PlUnit wiring work. It must not contain parser,
inference, synthesis, or rendering logic.

Create `.vscode/tasks.json` with correctly quoted commands and at least:

```text
CPS: Doctor
CPS: Test
CPS: Check
```

Make `CPS: Check` the default build task. Do not hard-code an absolute
machine-specific path to `swipl`.

If a GitHub Actions workflow is justified by the existing repository, make it
run the same canonical command rather than duplicating quality logic.

## 12. Acceptance criteria

Phase 0 is complete only when all applicable statements below are true:

- Every required source basename resolves to exactly one repository-local
  file.
- Initial and final SHA-256 digests of all five sources match.
- `config/reference_manifest.json` is inert, schema-valid, machine-readable,
  and is the sole manifest consumed by integrity checks.
- Source paths containing parentheses are handled safely.
- The actual `swipl --version` command succeeds and is documented.
- `doctor.pl`, `test.pl`, and `check.pl` all exit with code zero.
- The tiny bootstrap module loads and its PlUnit test passes.
- `.vscode/tasks.json` is valid JSON.
- Every agent TOML has a unique name and all required fields.
- All specialist agents are read-only and no model is pinned.
- Every skill has valid front matter, a unique project-prefixed name, a
  focused workflow, validation commands, a stop condition, and the specified
  agent delegation where applicable.
- Root `AGENTS.md` explicitly requires `PLANS.md` for non-trivial work.
- No deprecated custom-prompt infrastructure or active hook was created.
- No primary source was modified, copied over, or treated as production code.
- No Phase 0 command consulted or executed either legacy Prolog source.
- No parser, prover, synthesizer, verifier, renderer, or teaching engine was
  prematurely implemented.
- No arbitrary user-controlled `assertz/1` or `call/1` path exists.
- No dependency, API, secret, remote service, Git initialization, commit, or
  push was introduced without authorization.
- Documentation labels source facts, interpretations, proposed decisions, and
  project-derived candidates accurately.
- Relative links used by the scaffold resolve.
- Exactly one Phase-0-created CPS implementation task is ready: T001;
  unrelated pre-existing tasks are preserved.
- The final status report contains no claim for a check that was not actually
  run.

If a check cannot run, do not call the bootstrap complete. Record the exact
command, output or error, likely cause, and smallest next action.

## 13. Final response format

After creating and validating the scaffold, return a concise handoff with:

1. the Phase 0 outcome;
2. the created or changed tree;
3. every validation command and its real result;
4. confirmation that all five final hashes match their initial values;
5. proposed decisions still awaiting human approval;
6. any conflict, limitation, or unverified claim;
7. the exact recommended next action:

```text
Start a fresh trusted Codex session, invoke $cps-analyze-sources for T001,
then use $cps-plan-slice to prepare its ExecPlan. Stop for human approval
before implementation.
```

Do not proceed to T001 in this run.
