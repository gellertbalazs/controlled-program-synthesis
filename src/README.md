# Canonical source component matrix

- SOURCE FACT — This file is the authoritative inventory and ownership matrix
  for repository-root Prolog modules and canonical component directories under
  `src/`.
- PROJECT INTERPRETATION — A reserved directory contract records ownership,
  entry gates, and proof expectations; it does not establish implemented
  behavior.
- PROJECT INTERPRETATION — An empty or similarly named workspace directory is
  not a component.
- PROJECT INTERPRETATION — A future plan may add or split a component only
  with owner approval and synchronized updates to this matrix, the affected
  component README, and the control records.

## Root Prolog modules

| Evidence | Component | Owning task | Current state | Purpose | Trust or representation boundary | Dependency or entry gate | Plan maturity |
|---|---|---|---|---|---|---|---|
| SOURCE FACT | [`cps_bootstrap.pl`](cps_bootstrap.pl) | Phase 0 infrastructure | DONE | Reports the implemented Phase 0 bootstrap stage. | Infrastructure only; it defines no domain representation or acceptance authority. | Phase 0 infrastructure acceptance. | **no approved ExecPlan yet**; the accepted Phase 0 infrastructure predates a task-specific domain plan. |
| SOURCE FACT | [`cps_reference_normalization.pl`](cps_reference_normalization.pl) | T001 | DONE | Provides the accepted bounded source-normalization boundary. | Acceptance is syntactic only and does not establish semantic truth, behavioral equality, or legacy runtime behavior. | T001 accepted after its owner-approved frozen plan and verification. | [`T001 frozen approved plan`](../docs/plans/T001-source-audit-and-normalization-plan.md). |
| SOURCE FACT | [`cps_law_claim_authority.pl`](cps_law_claim_authority.pl) | T002 | DONE | Provides the accepted bounded, one-hop law-claim-authority boundary. | T001 normalization supplies syntactic provenance validation only; the T002 boundary separately enforces its accepted source-relative authority contract. | T001 and the owner-approved T002 slice are accepted. | [`T002 frozen approved plan`](../docs/plans/T002-source-addressed-law-claim-authority-plan.md). |
| SOURCE FACT | [`cps_fixed_left_reduction_v0.pl`](cps_fixed_left_reduction_v0.pl) | [`T006`](../tasks/ready/T006-reduction-vertical-slice.md) | IMPLEMENTED I1 candidate; authoritative progress and verdict in T006 task | Proposes one bounded fixed-left reduction candidate and independently verifies its Specification, Program AST, proof, costs, authority, and content-free render. | Proposal output never self-authorizes. Acceptance requires fresh exact T002 authority, independent reconstruction, complete proof replay, and rendering only from a checked AST. | T002 is the sole production import; T003–T005 remain accepted read-only prerequisites and are not imported or relabeled as reduction evidence. | [`Original plan`](../docs/plans/T006-fixed-left-reduction-vertical-slice-plan.md) and [`focused-exhaustion amendment`](../docs/plans/T006-fixed-left-reduction-vertical-slice-amended-plan.md). |

## Canonical component directories

| Evidence | Component | Owning task(s) | Current state | Purpose | Trust or representation boundary | Dependency or entry gate | Plan maturity |
|---|---|---|---|---|---|---|---|
| SOURCE FACT | [`ir/`](ir/README.md) | [`T003`](../tasks/done/T003-spec-and-program-ir.md) | DONE | Provides the accepted bounded validator for one ground typed equality Specification proposal and one distinct Program AST proposal. | Proposal terms remain distinct from fresh accepted data; structural validation, Program-AST checks, and T002 authority assessment are independent and fail closed. Acceptance proves neither equality truth nor program correctness. | T001/T002 accepted; T003 option-1 plan and V1 accepted; canonical gate passed with unit 112/112 and integration 15/15. | [`T003 frozen approved option-1 plan`](../docs/plans/T003-ground-typed-equality-ir-option-1-plan.md). |
| SOURCE FACT | [`inference/`](inference/README.md) | [`T004`](../tasks/done/T004-proof-kernel-skeleton.md) | RESERVED; no T004 public API | T004 checker is implemented in verification; inference remains reserved. | Proposal or backend output cannot self-authorize, and T004 assigns no inference predicate to this directory. | T002 and T003 are accepted; volatile T004 progress, counters, eligibility, and verdict remain in the owning task record. | [`Original approved plan`](../docs/plans/T004-source-relative-identity-proof-replay-plan.md), [`fixture amendment`](../docs/plans/T004-source-relative-identity-proof-replay-fixture-amendment-plan.md), and [`publication amendment`](../docs/plans/T004-source-relative-identity-proof-replay-publication-amendment-plan.md). |
| SOURCE FACT | [`verification/`](verification/README.md) | [`T004`](../tasks/done/T004-proof-kernel-skeleton.md); T006 uses a separate root boundary | IMPLEMENTED frozen T004 candidate; verdict in T004 task | Implements the sole T004 source-relative identity proof replay checker over four proposal inputs and an explicit result/audit envelope. | Acceptance requires fresh trusted predecessor evidence, accepted obligations, and an independently checked Program AST; no proposal or backend output self-authorizes. | T004 depends on accepted T002/T003 contracts. T006 neither imports nor extends this identity checker; its distinct reduction replay is private to the root T006 module. | [`Original approved plan`](../docs/plans/T004-source-relative-identity-proof-replay-plan.md), [`fixture amendment`](../docs/plans/T004-source-relative-identity-proof-replay-fixture-amendment-plan.md), and [`publication amendment`](../docs/plans/T004-source-relative-identity-proof-replay-publication-amendment-plan.md). |
| SOURCE FACT | [`cnl/`](cnl/README.md) | [`T005`](../tasks/ready/T005-controlled-english-v0.md) | IMPLEMENTED bounded contract; authoritative status in T005 task | Implements one fixed bounded pre-tokenized equality fragment and fresh T003 proposal validation. | Parsing remains a proposal boundary; acceptance proves only the bounded validated Specification representation and supplies no proof, Program execution, synthesis, or rendering authority. | T003, the relevant T004 validation contracts, ADR-0005, and the exact T005 plans are approved; the task record is the sole status authority. | [`Original plan`](../docs/plans/T005-controlled-english-v0-plan.md), [`first amendment`](../docs/plans/T005-controlled-english-v0-amended-plan.md), and [`rejected-V1 amendment`](../docs/plans/T005-controlled-english-v0-rejected-v1-amendment-plan.md). |
| PROJECT INTERPRETATION | [`synthesis/`](synthesis/README.md) | [`T006`](../tasks/ready/T006-reduction-vertical-slice.md) | T006 proposal responsibility implemented in the root I1 candidate; no module in this directory | Documents the one deterministic bounded reduction proposal. | The proposal remains untrusted and cannot be its own proof or acceptance evidence. | T002–T005 are accepted; the exact digest-bound T006 plans govern the root candidate. | [`Original plan`](../docs/plans/T006-fixed-left-reduction-vertical-slice-plan.md) and [`focused-exhaustion amendment`](../docs/plans/T006-fixed-left-reduction-vertical-slice-amended-plan.md). |
| PROJECT INTERPRETATION | [`rendering/`](rendering/README.md) | [`T006`](../tasks/ready/T006-reduction-vertical-slice.md) | T006 rendering responsibility implemented privately in the root I1 candidate; no module in this directory | Documents deterministic, content-free rendering of only an independently checked Program AST. | Rendering exposes accepted structure but cannot choose, repair, execute, or authorize semantics. | T002–T005 are accepted; the exact digest-bound T006 plans govern the root candidate. | [`Original plan`](../docs/plans/T006-fixed-left-reduction-vertical-slice-plan.md) and [`focused-exhaustion amendment`](../docs/plans/T006-fixed-left-reduction-vertical-slice-amended-plan.md). |
| PROJECT INTERPRETATION | [`dialogue/`](dialogue/README.md) | [`T007`](../tasks/backlog/T007-teaching-lifecycle.md) | PENDING | Reserves the teaching-lifecycle interaction component. | Candidate teaching remains separate from review, activation, trust, and retirement. | T002 and T006 accepted; implementation requires an owner-approved T007 ExecPlan. | **no approved ExecPlan yet**. |
| SOURCE FACT | [`knowledge/`](knowledge/README.md) | T002 accepted contracts; [`T007`](../tasks/backlog/T007-teaching-lifecycle.md) | DONE for the accepted T002 contract; PENDING for T007 behavior | Carries the accepted T002 knowledge-boundary contract and reserves T007 knowledge-lifecycle responsibilities. | The accepted T002 scope remains in the root authority module; no T007 lifecycle, storage, or mutation behavior is implemented here. | T002 is accepted; T007 behavior additionally requires T006 acceptance and an owner-approved T007 ExecPlan. | [`T002 frozen approved plan`](../docs/plans/T002-source-addressed-law-claim-authority-plan.md); **no approved ExecPlan yet** for T007 behavior. |

## Directory exclusions

- SOURCE FACT — T008 has no permanent `src` directory. Its
  [`backlog task`](../tasks/backlog/T008-synthesis-technology-qualification.md)
  requires its own approved ExecPlan to name any future component.
- PROJECT INTERPRETATION — The removed workspace-only aliases `ce`,
  `patterns`, `proof`, `render`, `synth`, and `verify` confer no architectural
  meaning.
- PROJECT INTERPRETATION — `ce` does not coexist with `cnl`; `render` does
  not coexist with `rendering`; `synth` does not coexist with `synthesis`;
  `verify` does not coexist with `verification`; `proof` does not bypass the
  `inference`/`verification` split; and the owner-approved T006 plans keep
  `patterns` outside the product boundary.
