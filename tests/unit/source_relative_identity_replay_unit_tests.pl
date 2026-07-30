:- begin_tests(cps_source_relative_identity_replay).

:- use_module(
       '../../src/verification/cps_source_relative_identity_replay').
:- use_module('../../src/ir/cps_ground_typed_equality_ir', []).
:- use_module(library(readutil)).

canonical_inputs(Specification, Program, Authority) :-
    Specification =
        specification_proposal(
            specification_id(spec_main),
            type_declarations([nominal_type(type_id(element))]),
            binding(
                object_binder(binder_id(spec_object), type_id(element)),
                equality(
                    equality_id(represented_equal),
                    operands([
                        object_reference(
                            binder_id(spec_object), type_id(element)),
                        object_value(
                            atom_value(value), type_id(element))
                    ]))),
            definedness(definition_space_id(adjacent_defined)),
            premises([premise_id(adjacent_applications)])),
    Program =
        program_proposal(
            program_id(identity_program),
            signature(
                input(type_id(element)),
                output(type_id(element))),
            program_ast(
                object_binder(
                    binder_id(program_object), type_id(element)),
                object_reference(
                    binder_id(program_object), type_id(element))),
            definedness(definition_space_id(adjacent_defined)),
            premises([premise_id(adjacent_applications)])),
    Shared = provenance_id(eop_concepts_p9),
    Evidence =
        evidence(
            at(
                source(
                    'eop_concepts.pdf',
                    'references/eop_concepts.pdf',
                    243726,
                    '401346f1e3d75b790cf0229dab174773a4eb854880e6e7c05f6cc924a4afac19'),
                pages(9, 9, 9, 9),
                raw_utf8([112, 97, 114, 116, 105, 97, 108])),
            claim(
                source_fact,
                eop_semantics,
                facets(
                    established(binary_operation),
                    established(partial_associativity),
                    established(adjacent_definedness),
                    established(partial_associativity_law),
                    established(well_founded_measure),
                    established(operation_count),
                    established(effect_conditions),
                    established(alias_conditions),
                    established(physical_and_printed_page),
                    established(negative_cases)))),
    Policy =
        policy(
            policy_id(source_policy),
            source_relative_law_v1,
            Shared),
    Semantics =
        semantics(
            signature(signature_id(binary_op)),
            definedness(definition_space_id(adjacent_defined)),
            law(
                law_id(partial_assoc),
                equality(equality_id(represented_equal))),
            termination(termination_id(structural_descent)),
            cost(cost_id(operation_count)),
            effects(effects_id(read_write_alias)),
            provenance(Shared)),
    Claim =
        claim(
            claim_id(partial_associativity),
            Semantics,
            uses([premise_id(adjacent_applications)]),
            requires([obligation_id(both_parenthesizations_defined)]),
            conflicts([contradiction_id(no_counterexample)]),
            current(Shared)),
    Records =
        semantic_records(
            signature(
                signature_id(binary_op),
                descriptor(binary_operation),
                accepted(Shared),
                Shared),
            definition_space(
                definition_space_id(adjacent_defined),
                signature_id(binary_op),
                descriptor(adjacent_applications),
                accepted(Shared),
                Shared),
            law(
                law_id(partial_assoc),
                signature_id(binary_op),
                definition_space_id(adjacent_defined),
                equality_id(represented_equal),
                descriptor(partial_associativity),
                accepted(Shared),
                Shared),
            equality_relation(
                equality_id(represented_equal),
                signature_id(binary_op),
                definition_space_id(adjacent_defined),
                relation(represented_value_equality),
                accepted(Shared),
                Shared),
            termination(
                termination_id(structural_descent),
                law_id(partial_assoc),
                measure(smaller_structure),
                accepted(Shared),
                Shared),
            cost(
                cost_id(operation_count),
                law_id(partial_assoc),
                operation_count(primitive_applications),
                accepted(Shared),
                Shared),
            effects(
                effects_id(read_write_alias),
                law_id(partial_assoc),
                conditions(explicit_read_write_alias_overlap),
                accepted(Shared),
                Shared)),
    Premises = [
        premise(
            premise_id(adjacent_applications),
            active(Shared),
            trusted(policy_id(source_policy), Shared),
            Shared)
    ],
    Obligations = [
        obligation(
            obligation_id(both_parenthesizations_defined),
            law_id(partial_assoc),
            applicable(Shared),
            accepted(Shared),
            Shared)
    ],
    Contradictions = [
        contradiction(
            contradiction_id(no_counterexample),
            claim_id(partial_associativity),
            cleared(Shared),
            Shared)
    ],
    Authority =
        authority_snapshot(
            Policy,
            Claim,
            Records,
            Premises,
            Obligations,
            Contradictions,
            [provenance(Shared, Evidence)]).

canonical_conclusion(
    source_relative_identity_replay(
        program_id(identity_program),
        equality_id(represented_equal),
        definition_space_id(adjacent_defined),
        premise_id(adjacent_applications))).

canonical_references([
    authority_scope(
        equality_id(represented_equal),
        definition_space_id(adjacent_defined),
        premise_id(adjacent_applications)),
    program_ast(program_id(identity_program))
]).

canonical_proof(Proof) :-
    canonical_conclusion(Conclusion),
    canonical_references(References),
    Proof =
        proof_proposal(
            proof_format(source_relative_identity_replay_v1),
            proof_id(proof_main),
            theory(source_relative_identity_v1),
            steps([
                proof_step(
                    step_id(step_main),
                    rule(source_relative_identity_replay_v1),
                    dependencies([]),
                    external_references(References),
                    conclusion(Conclusion))
            ]),
            root_step(step_id(step_main))).

canonical_case(Specification, Program, Authority, Proof, Predecessor) :-
    canonical_inputs(Specification, Program, Authority),
    canonical_proof(Proof),
    predecessor_result(
        Specification, Program, Authority, Predecessor).

predecessor_result(Specification, Program, Authority, Predecessor) :-
    cps_ground_typed_equality_ir:validate_ground_typed_equality_pair(
        Specification, Program, Authority, Predecessor).

proposal_descriptor(
    proof_proposal(
        _Format,
        ProofId,
        _Theory,
        _Steps,
        RootStep),
    proposal(ProofId, RootStep)).

no_proof_audit(
    proof_audit(
        proposal(no_proof),
        predecessor(not_checked),
        replay(not_checked))).

local_preclosure_expected(Status, proof_replay(Status, Audit)) :-
    no_proof_audit(Audit).

local_closed_expected(Proof, Status, Detail,
                      proof_replay(Status, Audit)) :-
    proposal_descriptor(Proof, Proposal),
    Audit =
        proof_audit(
            Proposal,
            predecessor(not_checked),
            replay(Detail)).

predecessor_expected(Proof, Predecessor,
                     proof_replay(Status, Audit)) :-
    proposal_descriptor(Proof, Proposal),
    mapped_predecessor_status(Predecessor, Status),
    Audit =
        proof_audit(
            Proposal,
            predecessor(Predecessor),
            replay(not_checked)).

mapped_predecessor_status(
    ground_typed_equality_validation(
        rejected(resource_limit_exceeded(Input, Limit)),
        _Audit),
    resource_exhausted(predecessor(t003, Input, Limit))) :-
    !.
mapped_predecessor_status(
    ground_typed_equality_validation(unknown(Missing), _Audit),
    unknown(predecessor(t003, Missing))) :-
    !.
mapped_predecessor_status(
    ground_typed_equality_validation(rejected(Reason), _Audit),
    rejected(predecessor(t003, Reason))).

accepted_expected(Proof, Predecessor,
                  proof_replay(accepted(CheckedProof), Audit)) :-
    Predecessor =
        ground_typed_equality_validation(
            accepted(
                validated_pair(
                    validated_specification(
                        _SpecificationId,
                        _SpecificationType,
                        scoped_equality(
                            _SpecificationBinder,
                            equality_relation(
                                equality_id(EqualityId),
                                _Left,
                                _Right)),
                        definition_space_id(DefinitionSpaceId),
                        premise_id(PremiseId)),
                    validated_program(
                        program_id(ProgramId),
                        _ProgramSignature,
                        _ScopedProgram,
                        definition_space_id(DefinitionSpaceId),
                        premise_id(PremiseId)))),
            ir_audit(
                _ProposalAudit,
                authority(authority_assessment(accepted, _AuthorityAudit)))),
    Proof =
        proof_proposal(
            ProofFormat,
            ProofId,
            Theory,
            steps([
                proof_step(
                    StepId,
                    Rule,
                    Dependencies,
                    external_references(References),
                    conclusion(Conclusion))
            ]),
            root_step(StepId)),
    CheckedProof =
        checked_proof(
            ProofFormat,
            ProofId,
            Theory,
            root_step(StepId),
            checked_step(
                StepId,
                Rule,
                Dependencies,
                external_references(References),
                conclusion(Conclusion))),
    ExpectedReferences = [
        authority_scope(
            equality_id(EqualityId),
            definition_space_id(DefinitionSpaceId),
            premise_id(PremiseId)),
        program_ast(program_id(ProgramId))
    ],
    ExpectedConclusion =
        source_relative_identity_replay(
            program_id(ProgramId),
            equality_id(EqualityId),
            definition_space_id(DefinitionSpaceId),
            premise_id(PremiseId)),
    References == ExpectedReferences,
    Conclusion == ExpectedConclusion,
    proposal_descriptor(Proof, Proposal),
    Audit =
        proof_audit(
            Proposal,
            predecessor(Predecessor),
            replay(
                checked(
                    StepId,
                    Rule,
                    external_references(ExpectedReferences),
                    conclusion(ExpectedConclusion)))).

accepted_mismatch_expected(Proof, Predecessor, Reason,
                           proof_replay(rejected(Reason), Audit)) :-
    proposal_descriptor(Proof, Proposal),
    Audit =
        proof_audit(
            Proposal,
            predecessor(Predecessor),
            replay(rejected(Reason))).

assert_public_result(Specification, Program, Authority, Proof, Expected) :-
    findall(
        Result,
        check_source_relative_identity_proof(
            Specification, Program, Authority, Proof, Result),
        Results),
    assertion(Results == [Expected]),
    assertion(ground(Results)),
    assertion(acyclic_term(Results)).

proof_parts(Proof, Format, ProofId, Theory, Step, RootStep) :-
    Proof =
        proof_proposal(
            Format,
            ProofId,
            Theory,
            steps([Step]),
            RootStep).

step_parts(Step, StepId, Rule, Dependencies, References, Conclusion) :-
    Step =
        proof_step(
            StepId,
            Rule,
            Dependencies,
            external_references(References),
            conclusion(Conclusion)).

malformed_case(format, Proof, format) :-
    canonical_proof(Original),
    proof_parts(Original, _Format, ProofId, Theory, Step, RootStep),
    Proof =
        proof_proposal(
            proof_format(source_relative_identity_replay_v1, extra),
            ProofId, Theory, steps([Step]), RootStep).
malformed_case(proof_id, Proof, proof_id) :-
    canonical_proof(Original),
    proof_parts(Original, Format, _ProofId, Theory, Step, RootStep),
    Proof =
        proof_proposal(
            Format, proof_id(42), Theory, steps([Step]), RootStep).
malformed_case(theory, Proof, theory) :-
    canonical_proof(Original),
    proof_parts(Original, Format, ProofId, _Theory, Step, RootStep),
    Proof =
        proof_proposal(
            Format, ProofId, theory(42), steps([Step]), RootStep).
malformed_case(steps, Proof, steps) :-
    canonical_proof(Original),
    proof_parts(Original, Format, ProofId, Theory, Step, RootStep),
    Proof =
        proof_proposal(
            Format, ProofId, Theory, steps([Step|improper]), RootStep).
malformed_case(step, Proof, step) :-
    canonical_proof(Original),
    proof_parts(Original, Format, ProofId, Theory, _Step, RootStep),
    Proof =
        proof_proposal(
            Format, ProofId, Theory, steps([not_a_step]), RootStep).
malformed_case(step_id, Proof, step_id) :-
    canonical_proof(Original),
    proof_parts(Original, Format, ProofId, Theory, Step0, RootStep),
    step_parts(
        Step0, _StepId, Rule, Dependencies, References, Conclusion),
    Step =
        proof_step(
            step_id(42), Rule, Dependencies,
            external_references(References), conclusion(Conclusion)),
    Proof =
        proof_proposal(
            Format, ProofId, Theory, steps([Step]), RootStep).
malformed_case(dependencies, Proof, dependencies) :-
    canonical_proof(Original),
    proof_parts(Original, Format, ProofId, Theory, Step0, RootStep),
    step_parts(Step0, StepId, Rule, _Dependencies, References, Conclusion),
    Step =
        proof_step(
            StepId, Rule, dependencies(not_a_list),
            external_references(References), conclusion(Conclusion)),
    Proof =
        proof_proposal(
            Format, ProofId, Theory, steps([Step]), RootStep).
malformed_case(external_references, Proof, external_references) :-
    canonical_proof(Original),
    proof_parts(Original, Format, ProofId, Theory, Step0, RootStep),
    step_parts(Step0, StepId, Rule, Dependencies, _References, Conclusion),
    Step =
        proof_step(
            StepId, Rule, Dependencies,
            external_references(not_a_list), conclusion(Conclusion)),
    Proof =
        proof_proposal(
            Format, ProofId, Theory, steps([Step]), RootStep).
malformed_case(authority_scope, Proof, authority_scope) :-
    canonical_proof(Original),
    proof_parts(Original, Format, ProofId, Theory, Step0, RootStep),
    step_parts(
        Step0, StepId, Rule, Dependencies, [_Scope, ProgramReference],
        Conclusion),
    References = [
        authority_scope(
            equality_id(represented_equal),
            definition_space_id(adjacent_defined)),
        ProgramReference
    ],
    Step =
        proof_step(
            StepId, Rule, Dependencies,
            external_references(References), conclusion(Conclusion)),
    Proof =
        proof_proposal(
            Format, ProofId, Theory, steps([Step]), RootStep).
malformed_case(program_ast, Proof, program_ast) :-
    canonical_proof(Original),
    proof_parts(Original, Format, ProofId, Theory, Step0, RootStep),
    step_parts(
        Step0, StepId, Rule, Dependencies, [Scope, _ProgramReference],
        Conclusion),
    References = [Scope, program_ast(identity_program)],
    Step =
        proof_step(
            StepId, Rule, Dependencies,
            external_references(References), conclusion(Conclusion)),
    Proof =
        proof_proposal(
            Format, ProofId, Theory, steps([Step]), RootStep).
malformed_case(conclusion, Proof, conclusion) :-
    canonical_proof(Original),
    proof_parts(Original, Format, ProofId, Theory, Step0, RootStep),
    step_parts(Step0, StepId, Rule, Dependencies, References, _Conclusion),
    Step =
        proof_step(
            StepId, Rule, Dependencies,
            external_references(References), conclusion(not_a_conclusion)),
    Proof =
        proof_proposal(
            Format, ProofId, Theory, steps([Step]), RootStep).
malformed_case(root_step, Proof, root_step) :-
    canonical_proof(Original),
    proof_parts(Original, Format, ProofId, Theory, Step, _RootStep),
    Proof =
        proof_proposal(
            Format, ProofId, Theory, steps([Step]),
            root_step(not_a_step_id)).

replace_step(Original, Step, Proof) :-
    proof_parts(Original, Format, ProofId, Theory, _OldStep, RootStep),
    Proof =
        proof_proposal(
            Format, ProofId, Theory, steps([Step]), RootStep).

proof_with_format(Tag, Proof) :-
    canonical_proof(Original),
    proof_parts(Original, _Format, ProofId, Theory, Step, RootStep),
    Proof =
        proof_proposal(
            proof_format(Tag), ProofId, Theory, steps([Step]), RootStep).

proof_with_theory(Tag, Proof) :-
    canonical_proof(Original),
    proof_parts(Original, Format, ProofId, _Theory, Step, RootStep),
    Proof =
        proof_proposal(
            Format, ProofId, theory(Tag), steps([Step]), RootStep).

proof_with_rule(Tag, Proof) :-
    canonical_proof(Original),
    proof_parts(Original, _Format, _ProofId, _Theory, Step0, _RootStep),
    step_parts(
        Step0, StepId, _Rule, Dependencies, References, Conclusion),
    Step =
        proof_step(
            StepId, rule(Tag), Dependencies,
            external_references(References), conclusion(Conclusion)),
    replace_step(Original, Step, Proof).

proof_with_conclusion(Conclusion, Proof) :-
    canonical_proof(Original),
    proof_parts(Original, _Format, _ProofId, _Theory, Step0, _RootStep),
    step_parts(
        Step0, StepId, Rule, Dependencies, References, _OldConclusion),
    Step =
        proof_step(
            StepId, Rule, Dependencies,
            external_references(References), conclusion(Conclusion)),
    replace_step(Original, Step, Proof).

proof_with_references(References, Proof) :-
    canonical_proof(Original),
    proof_parts(Original, _Format, _ProofId, _Theory, Step0, _RootStep),
    step_parts(
        Step0, StepId, Rule, Dependencies, _OldReferences, Conclusion),
    Step =
        proof_step(
            StepId, Rule, Dependencies,
            external_references(References), conclusion(Conclusion)),
    replace_step(Original, Step, Proof).

proof_with_root_step(RootStep, Proof) :-
    canonical_proof(Original),
    proof_parts(Original, Format, ProofId, Theory, Step, _OldRootStep),
    Proof =
        proof_proposal(
            Format, ProofId, Theory, steps([Step]), root_step(RootStep)).

proof_with_proof_id(Id, Proof) :-
    canonical_proof(Original),
    proof_parts(Original, Format, _ProofId, Theory, Step, RootStep),
    Proof =
        proof_proposal(
            Format, proof_id(Id), Theory, steps([Step]), RootStep).

proof_with_step_id(Id, Proof) :-
    canonical_proof(Original),
    proof_parts(Original, Format, ProofId, Theory, Step0, _RootStep),
    step_parts(
        Step0, _StepId, Rule, Dependencies, References, Conclusion),
    Step =
        proof_step(
            step_id(Id), Rule, Dependencies,
            external_references(References), conclusion(Conclusion)),
    Proof =
        proof_proposal(
            Format, ProofId, Theory, steps([Step]),
            root_step(step_id(Id))).

proof_with_steps(Steps, Proof) :-
    canonical_proof(Original),
    proof_parts(Original, Format, ProofId, Theory, _Step, RootStep),
    Proof =
        proof_proposal(
            Format, ProofId, Theory, steps(Steps), RootStep).

proof_with_dependencies(DependencyList, Proof) :-
    canonical_proof(Original),
    proof_parts(Original, _Format, _ProofId, _Theory, Step0, _RootStep),
    step_parts(
        Step0, StepId, Rule, _Dependencies, References, Conclusion),
    Step =
        proof_step(
            StepId, Rule, dependencies(DependencyList),
            external_references(References), conclusion(Conclusion)),
    replace_step(Original, Step, Proof).

hole_proof(Kind, Proof, Missing) :-
    canonical_proof(Original),
    proof_parts(Original, Format, ProofId, Theory, Step0, RootStep),
    step_parts(
        Step0, StepId, _Rule, _Dependencies, _References, Conclusion),
    compound_name_arguments(
        Step,
        Kind,
        [StepId, dependencies([]), conclusion(Conclusion)]),
    Proof =
        proof_proposal(
            Format, ProofId, Theory, steps([Step]), RootStep),
    Missing = unchecked_evidence(Kind, StepId).

same_atoms(0, []) :-
    !.
same_atoms(Count, [pad|Rest]) :-
    Next is Count - 1,
    same_atoms(Next, Rest).

padding_term(Arity, Padding) :-
    same_atoms(Arity, Arguments),
    compound_name_arguments(Padding, padding, Arguments).

chain(1, leaf) :-
    !.
chain(Count, wrapper(Inner)) :-
    Next is Count - 1,
    chain(Next, Inner).

proof_with_alternate_payload(Payload, Proof) :-
    proof_with_conclusion(
        other_conclusion(alpha, beta, gamma, Payload),
        Proof).

long_identifier(Length, Identifier) :-
    long_identifier_codes(Length, Codes),
    atom_codes(Identifier, Codes).

long_identifier_codes(0, []) :-
    !.
long_identifier_codes(Length, [105|Codes]) :-
    Next is Length - 1,
    long_identifier_codes(Next, Codes).

fixture_cells(Term, Cells) :-
    fixture_cells(Term, [], Cells).

fixture_cells(Term, _Ancestors, 1) :-
    var(Term),
    !.
fixture_cells(Term, _Ancestors, 1) :-
    atomic(Term),
    !.
fixture_cells(Term, Ancestors, 1) :-
    identity_member(Term, Ancestors),
    !.
fixture_cells(Term, Ancestors, Cells) :-
    compound_name_arguments(Term, _Name, Arguments),
    fixture_argument_cells(Arguments, [Term|Ancestors], 1, Cells).

fixture_argument_cells([], _Ancestors, Cells, Cells).
fixture_argument_cells([Argument|Arguments], Ancestors, Cells0, Cells) :-
    fixture_cells(Argument, Ancestors, ArgumentCells),
    Cells1 is Cells0 + ArgumentCells,
    fixture_argument_cells(Arguments, Ancestors, Cells1, Cells).

fixture_depth(Term, Depth) :-
    fixture_depth(Term, [], Depth).

fixture_depth(Term, _Ancestors, 1) :-
    var(Term),
    !.
fixture_depth(Term, _Ancestors, 1) :-
    atomic(Term),
    !.
fixture_depth(Term, Ancestors, 1) :-
    identity_member(Term, Ancestors),
    !.
fixture_depth(Term, Ancestors, Depth) :-
    compound_name_arguments(Term, _Name, Arguments),
    fixture_argument_depth(Arguments, [Term|Ancestors], 0, Maximum),
    Depth is Maximum + 1.

fixture_argument_depth([], _Ancestors, Maximum, Maximum).
fixture_argument_depth([Argument|Arguments], Ancestors, Maximum0, Maximum) :-
    fixture_depth(Argument, Ancestors, ArgumentDepth),
    Maximum1 is max(Maximum0, ArgumentDepth),
    fixture_argument_depth(Arguments, Ancestors, Maximum1, Maximum).

identity_member(Term, [Ancestor|_Ancestors]) :-
    Term == Ancestor,
    !.
identity_member(Term, [_Ancestor|Ancestors]) :-
    identity_member(Term, Ancestors).

padding_with_marker(Index, Arity, Marker, Padding) :-
    padding_arguments(1, Index, Arity, Marker, Arguments),
    compound_name_arguments(Padding, padding, Arguments).

padding_arguments(Current, _Index, Arity, _Marker, []) :-
    Current > Arity,
    !.
padding_arguments(Current, Index, Arity, Marker, [Value|Values]) :-
    (   Current =:= Index
    ->  Value = Marker
    ;   Value = pad
    ),
    Next is Current + 1,
    padding_arguments(Next, Index, Arity, Marker, Values).

local_case(variable_root, Proof, Expected) :-
    local_preclosure_expected(rejected(non_ground_input(proof)), Expected),
    var(Proof).
local_case(attributed_root, Proof, Expected) :-
    put_attr(Proof, user, marker),
    local_preclosure_expected(rejected(non_ground_input(proof)), Expected).
local_case(forged_checked, checked_proof(a, b, c, d, e), Expected) :-
    local_preclosure_expected(
        rejected(forged_accepted_form(proof)), Expected).
local_case(forged_result, proof_replay(accepted(fake), fake), Expected) :-
    local_preclosure_expected(
        rejected(forged_accepted_form(proof)), Expected).
local_case(forged_audit, proof_audit(a, b, c), Expected) :-
    local_preclosure_expected(
        rejected(forged_accepted_form(proof)), Expected).
local_case(wrong_root, not_a_proof, Expected) :-
    local_preclosure_expected(
        rejected(malformed_shape(proof, root)), Expected).
local_case(cyclic_nested, Proof, Expected) :-
    Cycle = wrapper(Cycle),
    proof_with_alternate_payload(Cycle, Proof),
    local_preclosure_expected(rejected(cyclic_input(proof)), Expected).
local_case(non_ground_nested, Proof, Expected) :-
    proof_with_alternate_payload(_Variable, Proof),
    local_preclosure_expected(rejected(non_ground_input(proof)), Expected).
local_case(malformed(Field), Proof, Expected) :-
    malformed_case(Field, Proof, Field),
    local_preclosure_expected(
        rejected(malformed_shape(proof, Field)), Expected).
local_case(resource_steps, Proof, Expected) :-
    canonical_proof(Original),
    proof_parts(Original, _Format, _ProofId, _Theory, Step, _RootStep),
    proof_with_steps([Step, Step], Proof),
    local_preclosure_expected(
        resource_exhausted(proof(steps)), Expected).
local_case(resource_dependencies, Proof, Expected) :-
    proof_with_dependencies([step_id(child)], Proof),
    local_preclosure_expected(
        resource_exhausted(proof(dependency_depth)), Expected).
local_case(resource_references, Proof, Expected) :-
    canonical_references([First, Second]),
    proof_with_references([First, Second, Second], Proof),
    local_preclosure_expected(
        resource_exhausted(proof(external_references)), Expected).
local_case(resource_identifier, Proof, Expected) :-
    long_identifier(65, Identifier),
    proof_with_proof_id(Identifier, Proof),
    local_preclosure_expected(
        resource_exhausted(proof(identifier_scalars)), Expected).
local_case(resource_depth, Proof, Expected) :-
    chain(11, Payload),
    proof_with_alternate_payload(Payload, Proof),
    local_preclosure_expected(
        resource_exhausted(proof(structural_depth)), Expected).
local_case(resource_cells, Proof, Expected) :-
    padding_term(89, Padding),
    proof_with_alternate_payload(Padding, Proof),
    local_preclosure_expected(
        resource_exhausted(proof(cells)), Expected).
local_case(unsupported_format, Proof, Expected) :-
    proof_with_format(other_format, Proof),
    local_closed_expected(
        Proof,
        unsupported(format_version),
        unsupported(format_version),
        Expected).
local_case(unsupported_theory, Proof, Expected) :-
    proof_with_theory(other_theory, Proof),
    local_closed_expected(
        Proof, unsupported(theory), unsupported(theory), Expected).
local_case(unsupported_rule, Proof, Expected) :-
    proof_with_rule(other_rule, Proof),
    local_closed_expected(
        Proof, unsupported(rule), unsupported(rule), Expected).
local_case(unsupported_conclusion, Proof, Expected) :-
    proof_with_conclusion(other_conclusion(a, b, c, d), Proof),
    local_closed_expected(
        Proof,
        unsupported(conclusion_constructor),
        unsupported(conclusion_constructor),
        Expected).
local_case(proof_hole, Proof, Expected) :-
    hole_proof(proof_hole, Proof, Missing),
    local_closed_expected(
        Proof, unknown(Missing), unknown(Missing), Expected).
local_case(trusted_step, Proof, Expected) :-
    hole_proof(trusted_step, Proof, Missing),
    local_closed_expected(
        Proof, unknown(Missing), unknown(Missing), Expected).

authority_with_premise_state(Activation, Trust, Authority) :-
    canonical_inputs(_Specification, _Program, Original),
    Original =
        authority_snapshot(
            Policy,
            Claim,
            Records,
            [premise(PremiseId, _OldActivation, _OldTrust, ProvenanceId)],
            Obligations,
            Contradictions,
            Provenances),
    Authority =
        authority_snapshot(
            Policy,
            Claim,
            Records,
            [premise(PremiseId, Activation, Trust, ProvenanceId)],
            Obligations,
            Contradictions,
            Provenances).

authority_with_obligation(Applicability, Disposition, Authority) :-
    canonical_inputs(_Specification, _Program, Original),
    Original =
        authority_snapshot(
            Policy,
            Claim,
            Records,
            Premises,
            [obligation(Id, LawId, _OldApplicability, _OldDisposition,
                        ProvenanceId)],
            Contradictions,
            Provenances),
    Authority =
        authority_snapshot(
            Policy,
            Claim,
            Records,
            Premises,
            [obligation(Id, LawId, Applicability, Disposition,
                        ProvenanceId)],
            Contradictions,
            Provenances).

authority_with_contradiction(State, Authority) :-
    canonical_inputs(_Specification, _Program, Original),
    Original =
        authority_snapshot(
            Policy,
            Claim,
            Records,
            Premises,
            Obligations,
            [contradiction(Id, ClaimId, _OldState, ProvenanceId)],
            Provenances),
    Authority =
        authority_snapshot(
            Policy,
            Claim,
            Records,
            Premises,
            Obligations,
            [contradiction(Id, ClaimId, State, ProvenanceId)],
            Provenances).

authority_with_lifecycle(Lifecycle, Authority) :-
    canonical_inputs(_Specification, _Program, Original),
    Original =
        authority_snapshot(
            Policy,
            claim(ClaimId, Semantics, Uses, Requires, Conflicts, _Lifecycle),
            Records,
            Premises,
            Obligations,
            Contradictions,
            Provenances),
    Authority =
        authority_snapshot(
            Policy,
            claim(ClaimId, Semantics, Uses, Requires, Conflicts, Lifecycle),
            Records,
            Premises,
            Obligations,
            Contradictions,
            Provenances).

predecessor_variant(accepted, Specification, Program, Authority) :-
    canonical_inputs(Specification, Program, Authority).
predecessor_variant(rejected_specification,
                    not_a_specification, Program, Authority) :-
    canonical_inputs(_Specification, Program, Authority).
predecessor_variant(inactive_premise, Specification, Program, Authority) :-
    canonical_inputs(Specification, Program, CanonicalAuthority),
    CanonicalAuthority =
        authority_snapshot(
            policy(_PolicyId, _PolicyKind, Shared),
            _Claim, _Records, _Premises, _Obligations,
            _Contradictions, _Provenances),
    authority_with_premise_state(
        inactive(Shared),
        trusted(policy_id(source_policy), Shared),
        Authority).
predecessor_variant(untrusted_premise, Specification, Program, Authority) :-
    canonical_inputs(Specification, Program, CanonicalAuthority),
    CanonicalAuthority =
        authority_snapshot(
            policy(_PolicyId, _PolicyKind, Shared),
            _Claim, _Records, _Premises, _Obligations,
            _Contradictions, _Provenances),
    authority_with_premise_state(
        active(Shared),
        untrusted(policy_id(source_policy), Shared),
        Authority).
predecessor_variant(rejected_obligation,
                    Specification, Program, Authority) :-
    canonical_inputs(Specification, Program, CanonicalAuthority),
    CanonicalAuthority =
        authority_snapshot(
            policy(_PolicyId, _PolicyKind, Shared),
            _Claim, _Records, _Premises, _Obligations,
            _Contradictions, _Provenances),
    authority_with_obligation(
        applicable(Shared), rejected(Shared), Authority).
predecessor_variant(explicit_contradiction,
                    Specification, Program, Authority) :-
    canonical_inputs(Specification, Program, CanonicalAuthority),
    CanonicalAuthority =
        authority_snapshot(
            policy(_PolicyId, _PolicyKind, Shared),
            _Claim, _Records, _Premises, _Obligations,
            _Contradictions, _Provenances),
    authority_with_contradiction(explicit(Shared), Authority).
predecessor_variant(retracted_claim, Specification, Program, Authority) :-
    canonical_inputs(Specification, Program, CanonicalAuthority),
    CanonicalAuthority =
        authority_snapshot(
            policy(_PolicyId, _PolicyKind, Shared),
            _Claim, _Records, _Premises, _Obligations,
            _Contradictions, _Provenances),
    authority_with_lifecycle(retracted(Shared), Authority).
predecessor_variant(unknown_activation,
                    Specification, Program, Authority) :-
    canonical_inputs(Specification, Program, CanonicalAuthority),
    CanonicalAuthority =
        authority_snapshot(
            policy(_PolicyId, _PolicyKind, Shared),
            _Claim, _Records, _Premises, _Obligations,
            _Contradictions, _Provenances),
    authority_with_premise_state(
        missing,
        trusted(policy_id(source_policy), Shared),
        Authority).
predecessor_variant(unknown_trust,
                    Specification, Program, Authority) :-
    canonical_inputs(Specification, Program, CanonicalAuthority),
    CanonicalAuthority =
        authority_snapshot(
            policy(_PolicyId, _PolicyKind, Shared),
            _Claim, _Records, _Premises, _Obligations,
            _Contradictions, _Provenances),
    authority_with_premise_state(active(Shared), missing, Authority).
predecessor_variant(unknown_obligation_applicability,
                    Specification, Program, Authority) :-
    canonical_inputs(Specification, Program, CanonicalAuthority),
    CanonicalAuthority =
        authority_snapshot(
            policy(_PolicyId, _PolicyKind, Shared),
            _Claim, _Records, _Premises, _Obligations,
            _Contradictions, _Provenances),
    authority_with_obligation(missing, accepted(Shared), Authority).
predecessor_variant(unknown_obligation_disposition,
                    Specification, Program, Authority) :-
    canonical_inputs(Specification, Program, CanonicalAuthority),
    CanonicalAuthority =
        authority_snapshot(
            policy(_PolicyId, _PolicyKind, Shared),
            _Claim, _Records, _Premises, _Obligations,
            _Contradictions, _Provenances),
    authority_with_obligation(applicable(Shared), missing, Authority).
predecessor_variant(unknown_contradiction,
                    Specification, Program, Authority) :-
    canonical_inputs(Specification, Program, CanonicalAuthority),
    CanonicalAuthority =
        authority_snapshot(
            policy(_PolicyId, _PolicyKind, _Shared),
            _Claim, _Records, _Premises, _Obligations,
            _Contradictions, _Provenances),
    authority_with_contradiction(unresolved, Authority).
predecessor_variant(forged_authority,
                    Specification, Program,
                    authority_assessment(accepted, audit(fake))) :-
    canonical_inputs(Specification, Program, _Authority).
predecessor_variant(resource_specification_identifier,
                    Specification, Program, Authority) :-
    canonical_inputs(Original, Program, Authority),
    long_identifier(65, Identifier),
    Original =
        specification_proposal(
            _SpecificationId, Types, Binding, Definedness, Premises),
    Specification =
        specification_proposal(
            specification_id(Identifier),
            Types, Binding, Definedness, Premises).
predecessor_variant(resource_specification_value,
                    Specification, Program, Authority) :-
    canonical_inputs(Original, Program, Authority),
    long_value(129, Value),
    Original =
        specification_proposal(
            SpecificationId,
            Types,
            binding(
                Binder,
                equality(
                    EqualityId,
                    operands([Reference, _OldValue]))),
            Definedness,
            Premises),
    Specification =
        specification_proposal(
            SpecificationId,
            Types,
            binding(
                Binder,
                equality(
                    EqualityId,
                    operands([
                        Reference,
                        object_value(atom_value(Value), type_id(element))
                    ]))),
            Definedness,
            Premises).
predecessor_variant(resource_specification_depth,
                    Specification, Program, Authority) :-
    canonical_inputs(Original, Program, Authority),
    chain(20, Goal),
    Original =
        specification_proposal(
            SpecificationId, Types, binding(Binder, _Equality),
            Definedness, Premises),
    Specification =
        specification_proposal(
            SpecificationId, Types, binding(Binder, call(Goal)),
            Definedness, Premises).
predecessor_variant(resource_specification_cells,
                    Specification, Program, Authority) :-
    canonical_inputs(Original, Program, Authority),
    padding_term(600, Goal),
    Original =
        specification_proposal(
            SpecificationId, Types, binding(Binder, _Equality),
            Definedness, Premises),
    Specification =
        specification_proposal(
            SpecificationId, Types, binding(Binder, call(Goal)),
            Definedness, Premises).
predecessor_variant(resource_specification_list,
                    Specification, Program, Authority) :-
    canonical_inputs(Original, Program, Authority),
    Original =
        specification_proposal(
            SpecificationId,
            type_declarations([Type]),
            Binding,
            Definedness,
            Premises),
    Specification =
        specification_proposal(
            SpecificationId,
            type_declarations([Type, Type, Type]),
            Binding,
            Definedness,
            Premises).
predecessor_variant(resource_program_identifier,
                    Specification, Program, Authority) :-
    canonical_inputs(Specification, Original, Authority),
    long_identifier(65, Identifier),
    Original =
        program_proposal(
            _ProgramId, Signature, ProgramAst, Definedness, Premises),
    Program =
        program_proposal(
            program_id(Identifier),
            Signature, ProgramAst, Definedness, Premises).
predecessor_variant(resource_program_depth,
                    Specification, Program, Authority) :-
    canonical_inputs(Specification, Original, Authority),
    chain(20, Goal),
    Original =
        program_proposal(
            ProgramId,
            Signature,
            program_ast(Binder, _Expression),
            Definedness,
            Premises),
    Program =
        program_proposal(
            ProgramId,
            Signature,
            program_ast(Binder, call(Goal)),
            Definedness,
            Premises).
predecessor_variant(resource_program_cells,
                    Specification, Program, Authority) :-
    canonical_inputs(Specification, Original, Authority),
    padding_term(600, Goal),
    Original =
        program_proposal(
            ProgramId,
            Signature,
            program_ast(Binder, _Expression),
            Definedness,
            Premises),
    Program =
        program_proposal(
            ProgramId,
            Signature,
            program_ast(Binder, call(Goal)),
            Definedness,
            Premises).
predecessor_variant(resource_program_list,
                    Specification, Program, Authority) :-
    canonical_inputs(Specification, Original, Authority),
    Original =
        program_proposal(
            ProgramId, Signature, ProgramAst, Definedness,
            premises([Premise])),
    Program =
        program_proposal(
            ProgramId, Signature, ProgramAst, Definedness,
            premises([Premise, Premise, Premise])).
predecessor_variant(resource_authority,
                    Specification, Program, Authority) :-
    canonical_inputs(Specification, Program, Original),
    long_identifier(65, Identifier),
    Original =
        authority_snapshot(
            policy(_PolicyId, Kind, ProvenanceId),
            Claim, Records, Premises, Obligations,
            Contradictions, Provenances),
    Authority =
        authority_snapshot(
            policy(policy_id(Identifier), Kind, ProvenanceId),
            Claim, Records, Premises, Obligations,
            Contradictions, Provenances).

long_value(Length, Value) :-
    long_value_codes(Length, Codes),
    atom_codes(Value, Codes).

long_value_codes(0, []) :-
    !.
long_value_codes(Length, [118|Codes]) :-
    Next is Length - 1,
    long_value_codes(Next, Codes).

nonaccepting_predecessor(Name, Specification, Program, Authority,
                         Predecessor) :-
    predecessor_variant(Name, Specification, Program, Authority),
    Name \== accepted,
    predecessor_result(
        Specification, Program, Authority, Predecessor),
    Predecessor =
        ground_typed_equality_validation(Status, _Audit),
    Status \= accepted(_).

replay_variant(exact, Proof, exact) :-
    canonical_proof(Proof).
replay_variant(root_step, Proof, root_step_mismatch) :-
    proof_with_root_step(step_id(other_step), Proof).
replay_variant(reference_order, Proof, reference_order_mismatch) :-
    canonical_references([Scope, ProgramReference]),
    proof_with_references([ProgramReference, Scope], Proof).
replay_variant(authority_equality, Proof, authority_scope_mismatch) :-
    canonical_references([_Scope, ProgramReference]),
    References = [
        authority_scope(
            equality_id(other_equality),
            definition_space_id(adjacent_defined),
            premise_id(adjacent_applications)),
        ProgramReference
    ],
    proof_with_references(References, Proof).
replay_variant(authority_definition_space,
               Proof, authority_scope_mismatch) :-
    canonical_references([_Scope, ProgramReference]),
    References = [
        authority_scope(
            equality_id(represented_equal),
            definition_space_id(other_space),
            premise_id(adjacent_applications)),
        ProgramReference
    ],
    proof_with_references(References, Proof).
replay_variant(authority_premise, Proof, authority_scope_mismatch) :-
    canonical_references([_Scope, ProgramReference]),
    References = [
        authority_scope(
            equality_id(represented_equal),
            definition_space_id(adjacent_defined),
            premise_id(other_premise)),
        ProgramReference
    ],
    proof_with_references(References, Proof).
replay_variant(program_reference, Proof, program_reference_mismatch) :-
    canonical_references([Scope, _ProgramReference]),
    proof_with_references(
        [Scope, program_ast(program_id(other_program))],
        Proof).
replay_variant(conclusion_program, Proof, conclusion_mismatch) :-
    proof_with_conclusion(
        source_relative_identity_replay(
            program_id(other_program),
            equality_id(represented_equal),
            definition_space_id(adjacent_defined),
            premise_id(adjacent_applications)),
        Proof).
replay_variant(conclusion_equality, Proof, conclusion_mismatch) :-
    proof_with_conclusion(
        source_relative_identity_replay(
            program_id(identity_program),
            equality_id(other_equality),
            definition_space_id(adjacent_defined),
            premise_id(adjacent_applications)),
        Proof).
replay_variant(conclusion_definition_space, Proof, conclusion_mismatch) :-
    proof_with_conclusion(
        source_relative_identity_replay(
            program_id(identity_program),
            equality_id(represented_equal),
            definition_space_id(other_space),
            premise_id(adjacent_applications)),
        Proof).
replay_variant(conclusion_premise, Proof, conclusion_mismatch) :-
    proof_with_conclusion(
        source_relative_identity_replay(
            program_id(identity_program),
            equality_id(represented_equal),
            definition_space_id(adjacent_defined),
            premise_id(other_premise)),
        Proof).

test(canonical_one_rule_replay_is_exact) :-
    canonical_case(
        Specification, Program, Authority, Proof, Predecessor),
    accepted_expected(Proof, Predecessor, Expected),
    assert_public_result(
        Specification, Program, Authority, Proof, Expected).

test(every_local_nonacceptance_precedes_every_predecessor_class) :-
    forall(
        ( local_case(_LocalName, Proof, Expected),
          predecessor_variant(
              _PredecessorName, Specification, Program, Authority)
        ),
        assert_public_result(
            Specification, Program, Authority, Proof, Expected)).

test(every_malformed_field_uses_the_closed_vocabulary) :-
    canonical_inputs(Specification, Program, Authority),
    forall(
        malformed_case(_Case, Proof, Field),
        ( local_preclosure_expected(
              rejected(malformed_shape(proof, Field)), Expected),
          assert_public_result(
              Specification, Program, Authority, Proof, Expected)
        )).

test(every_nonaccepting_predecessor_maps_exactly_and_retains_audit) :-
    canonical_proof(Proof),
    forall(
        nonaccepting_predecessor(
            _Name, Specification, Program, Authority, Predecessor),
        ( predecessor_expected(Proof, Predecessor, Expected),
          assert_public_result(
              Specification, Program, Authority, Proof, Expected)
        )).

test(nonaccepting_predecessors_precede_every_replay_mismatch) :-
    forall(
        ( nonaccepting_predecessor(
              _PredecessorName,
              Specification, Program, Authority, Predecessor),
          replay_variant(ReplayName, Proof, _Reason),
          ReplayName \== exact
        ),
        ( predecessor_expected(Proof, Predecessor, Expected),
          assert_public_result(
              Specification, Program, Authority, Proof, Expected)
        )).

test(accepted_predecessor_checks_every_replay_field_in_order) :-
    canonical_inputs(Specification, Program, Authority),
    predecessor_result(
        Specification, Program, Authority, Predecessor),
    forall(
        replay_variant(Name, Proof, Reason),
        ( (   Name == exact
          ->  accepted_expected(Proof, Predecessor, Expected)
          ;   accepted_mismatch_expected(
                  Proof, Predecessor, Reason, Expected)
          ),
          assert_public_result(
              Specification, Program, Authority, Proof, Expected)
        )).

test(unsupported_priority_is_format_theory_rule_conclusion) :-
    canonical_inputs(Specification, Program, Authority),
    proof_with_format(other_format, Proof0),
    Proof0 =
        proof_proposal(
            Format, ProofId, _Theory, steps([Step0]), RootStep),
    step_parts(
        Step0, StepId, _Rule, Dependencies, References, _Conclusion),
    Step =
        proof_step(
            StepId, rule(other_rule), Dependencies,
            external_references(References),
            conclusion(other_conclusion(a, b, c, d))),
    Proof =
        proof_proposal(
            Format, ProofId, theory(other_theory),
            steps([Step]), RootStep),
    local_closed_expected(
        Proof,
        unsupported(format_version),
        unsupported(format_version),
        Expected),
    assert_public_result(
        Specification, Program, Authority, Proof, Expected).

test(local_numeric_boundaries_are_exact) :-
    canonical_case(
        Specification, Program, Authority, _Proof, Predecessor),
    forall(
        member(Length, [1, 64]),
        ( long_identifier(Length, Identifier),
          proof_with_proof_id(Identifier, ProofIdProof),
          accepted_expected(ProofIdProof, Predecessor, ProofIdExpected),
          assert_public_result(
              Specification, Program, Authority,
              ProofIdProof, ProofIdExpected),
          proof_with_step_id(Identifier, StepIdProof),
          accepted_expected(StepIdProof, Predecessor, StepIdExpected),
          assert_public_result(
              Specification, Program, Authority,
              StepIdProof, StepIdExpected)
        )),
    forall(
        member(Length, [65, 66]),
        ( long_identifier(Length, Identifier),
          proof_with_proof_id(Identifier, ProofIdProof),
          local_preclosure_expected(
              resource_exhausted(proof(identifier_scalars)),
              ProofIdExpected),
          assert_public_result(
              Specification, Program, Authority,
              ProofIdProof, ProofIdExpected),
          proof_with_step_id(Identifier, StepIdProof),
          local_preclosure_expected(
              resource_exhausted(proof(identifier_scalars)),
              StepIdExpected),
          assert_public_result(
              Specification, Program, Authority,
              StepIdProof, StepIdExpected)
        )),
    canonical_proof(CanonicalProof),
    proof_parts(
        CanonicalProof, _Format, _ProofId, _Theory, Step, _RootStep),
    proof_with_steps([], NoStepProof),
    local_preclosure_expected(
        rejected(malformed_shape(proof, steps)), NoStepExpected),
    assert_public_result(
        Specification, Program, Authority, NoStepProof, NoStepExpected),
    forall(
        member(Steps, [[Step, Step], [Step, Step, Step]]),
        ( proof_with_steps(Steps, StepsProof),
          local_preclosure_expected(
              resource_exhausted(proof(steps)), StepsExpected),
          assert_public_result(
              Specification, Program, Authority,
              StepsProof, StepsExpected)
        )),
    forall(
        member(Dependencies, [[step_id(child)], [step_id(a), step_id(b)]]),
        ( proof_with_dependencies(Dependencies, DependencyProof),
          local_preclosure_expected(
              resource_exhausted(proof(dependency_depth)),
              DependencyExpected),
          assert_public_result(
              Specification, Program, Authority,
              DependencyProof, DependencyExpected)
        )),
    canonical_references([FirstReference, SecondReference]),
    proof_with_references([FirstReference], ShortReferencesProof),
    local_preclosure_expected(
        rejected(malformed_shape(proof, external_references)),
        ShortReferencesExpected),
    assert_public_result(
        Specification, Program, Authority,
        ShortReferencesProof, ShortReferencesExpected),
    forall(
        member(
            References,
            [ [FirstReference, SecondReference, SecondReference],
              [FirstReference, SecondReference,
               SecondReference, SecondReference]
            ]),
        ( proof_with_references(References, ReferenceProof),
          local_preclosure_expected(
              resource_exhausted(proof(external_references)),
              ReferenceExpected),
          assert_public_result(
              Specification, Program, Authority,
              ReferenceProof, ReferenceExpected)
        )).

test(structural_depth_and_cell_boundaries_are_exact) :-
    canonical_inputs(Specification, Program, Authority),
    chain(10, Depth16Payload),
    proof_with_alternate_payload(Depth16Payload, Depth16Proof),
    fixture_depth(Depth16Proof, 16),
    local_closed_expected(
        Depth16Proof,
        unsupported(conclusion_constructor),
        unsupported(conclusion_constructor),
        Depth16Expected),
    assert_public_result(
        Specification, Program, Authority,
        Depth16Proof, Depth16Expected),
    forall(
        member(Depth-PayloadLength, [17-11, 18-12]),
        ( chain(PayloadLength, Payload),
          proof_with_alternate_payload(Payload, Proof),
          fixture_depth(Proof, Depth),
          local_preclosure_expected(
              resource_exhausted(proof(structural_depth)), Expected),
          assert_public_result(
              Specification, Program, Authority, Proof, Expected)
        )),
    forall(
        member(Cells-Arity, [128-88, 129-89, 144-104]),
        ( padding_term(Arity, Padding),
          proof_with_alternate_payload(Padding, Proof),
          fixture_cells(Proof, Cells),
          (   Cells =:= 128
          ->  local_closed_expected(
                  Proof,
                  unsupported(conclusion_constructor),
                  unsupported(conclusion_constructor),
                  Expected)
          ;   local_preclosure_expected(
                  resource_exhausted(proof(cells)), Expected)
          ),
          assert_public_result(
              Specification, Program, Authority, Proof, Expected)
        )).

test(bounded_prefix_priority_uses_only_inspected_evidence) :-
    canonical_inputs(Specification, Program, Authority),
    padding_with_marker(92, 110, _LastInspected, Padding128),
    proof_with_alternate_payload(Padding128, Proof128),
    local_preclosure_expected(
        rejected(non_ground_input(proof)), Expected128),
    assert_public_result(
        Specification, Program, Authority, Proof128, Expected128),
    padding_with_marker(93, 110, _FirstUninspected, Padding129),
    proof_with_alternate_payload(Padding129, Proof129),
    local_preclosure_expected(
        resource_exhausted(proof(cells)), Expected129),
    assert_public_result(
        Specification, Program, Authority, Proof129, Expected129),
    padding_with_marker(100, 110, _FartherUninspected, Padding140),
    proof_with_alternate_payload(Padding140, Proof140),
    local_preclosure_expected(
        resource_exhausted(proof(cells)), Expected140),
    assert_public_result(
        Specification, Program, Authority, Proof140, Expected140),
    Cycle128 = wrapper(Cycle128),
    padding_with_marker(91, 110, Cycle128, CyclePadding128),
    proof_with_alternate_payload(CyclePadding128, CycleProof128),
    local_preclosure_expected(
        rejected(cyclic_input(proof)), CycleExpected128),
    assert_public_result(
        Specification, Program, Authority,
        CycleProof128, CycleExpected128),
    Cycle129 = wrapper(Cycle129),
    padding_with_marker(92, 110, Cycle129, CyclePadding129),
    proof_with_alternate_payload(CyclePadding129, CycleProof129),
    local_preclosure_expected(
        resource_exhausted(proof(cells)), CycleExpected129),
    assert_public_result(
        Specification, Program, Authority,
        CycleProof129, CycleExpected129),
    malformed_case(proof_id, EarlyMalformed, proof_id),
    EarlyMalformed =
        proof_proposal(
            Format, BadProofId, Theory, steps([Step0]), RootStep),
    step_parts(
        Step0, StepId, Rule, Dependencies, References, _Conclusion),
    padding_term(100, LargePadding),
    Step =
        proof_step(
            StepId, Rule, Dependencies,
            external_references(References),
            conclusion(other_conclusion(a, b, c, LargePadding))),
    MalformedWithLaterExhaustion =
        proof_proposal(
            Format, BadProofId, Theory, steps([Step]), RootStep),
    local_preclosure_expected(
        rejected(malformed_shape(proof, proof_id)),
        MalformedExpected),
    assert_public_result(
        Specification, Program, Authority,
        MalformedWithLaterExhaustion, MalformedExpected).

test(cycle_precedes_nested_variable_and_malformed_evidence) :-
    canonical_inputs(Specification, Program, Authority),
    Cycle = wrapper(Cycle),
    proof_with_alternate_payload(Variable, VariableProof),
    VariableProof =
        proof_proposal(
            Format, ProofId, Theory, steps([Step0]), RootStep),
    step_parts(
        Step0, StepId, Rule, Dependencies, References, _Conclusion),
    Step =
        proof_step(
            StepId, Rule, Dependencies,
            external_references(References),
            conclusion(other_conclusion(Variable, Cycle, c, d))),
    Proof =
        proof_proposal(
            Format, ProofId, Theory, steps([Step]), RootStep),
    local_preclosure_expected(rejected(cyclic_input(proof)), Expected),
    assert_public_result(
        Specification, Program, Authority, Proof, Expected).

test(every_input_mode_is_finite_and_input_preserving) :-
    canonical_inputs(Specification, Program, Authority),
    canonical_proof(Proof),
    check_source_relative_identity_proof(
        VariableSpecification, Program, Authority, Proof,
        SpecificationResult),
    assertion(var(VariableSpecification)),
    assertion(ground(SpecificationResult)),
    check_source_relative_identity_proof(
        Specification, VariableProgram, Authority, Proof,
        ProgramResult),
    assertion(var(VariableProgram)),
    assertion(ground(ProgramResult)),
    check_source_relative_identity_proof(
        Specification, Program, VariableAuthority, Proof,
        AuthorityResult),
    assertion(var(VariableAuthority)),
    assertion(ground(AuthorityResult)),
    check_source_relative_identity_proof(
        Specification, Program, Authority, VariableProof,
        ProofResult),
    assertion(var(VariableProof)),
    assertion(ground(ProofResult)),
    put_attr(AttributedProof, user, preserved),
    get_attr(AttributedProof, user, preserved),
    check_source_relative_identity_proof(
        Specification, Program, Authority, AttributedProof,
        AttributedResult),
    assertion(var(AttributedProof)),
    assertion(get_attr(AttributedProof, user, preserved)),
    assertion(ground(AttributedResult)),
    SharedProof =
        proof_proposal(
            proof_format(source_relative_identity_replay_v1),
            proof_id(Shared),
            theory(source_relative_identity_v1),
            steps([]),
            root_step(step_id(Shared))),
    check_source_relative_identity_proof(
        Specification, Program, Authority, SharedProof, SharedResult),
    SharedProof =
        proof_proposal(
            _Format, proof_id(SharedAfter), _Theory, _Steps,
            root_step(step_id(SharedRootAfter))),
    assertion(Shared == SharedAfter),
    assertion(SharedAfter == SharedRootAfter),
    assertion(var(Shared)),
    assertion(ground(SharedResult)),
    CyclicProof =
        proof_proposal(
            proof_format(source_relative_identity_replay_v1),
            proof_id(cyclic_proof),
            theory(source_relative_identity_v1),
            steps(CyclicProof),
            root_step(step_id(step_main))),
    assertion(cyclic_term(CyclicProof)),
    check_source_relative_identity_proof(
        Specification, Program, Authority, CyclicProof, CyclicResult),
    assertion(cyclic_term(CyclicProof)),
    assertion(ground(CyclicResult)),
    assertion(acyclic_term(CyclicResult)).

test(results_are_repeated_call_order_directory_and_state_independent) :-
    canonical_case(
        Specification, Program, Authority, Proof, Predecessor),
    accepted_expected(Proof, Predecessor, Expected),
    check_source_relative_identity_proof(
        Specification, Program, Authority, Proof, First),
    local_case(proof_hole, HoleProof, HoleExpected),
    check_source_relative_identity_proof(
        Specification, Program, Authority, HoleProof, HoleFirst),
    check_source_relative_identity_proof(
        Specification, Program, Authority, HoleProof, HoleSecond),
    check_source_relative_identity_proof(
        Specification, Program, Authority, Proof, Second),
    assertion(First == Expected),
    assertion(Second == Expected),
    assertion(HoleFirst == HoleExpected),
    assertion(HoleSecond == HoleExpected),
    working_directory(OriginalDirectory, OriginalDirectory),
    setup_call_cleanup(
        working_directory(_, '/tmp'),
        check_source_relative_identity_proof(
            Specification, Program, Authority, Proof, OtherDirectory),
        working_directory(_, OriginalDirectory)),
    assertion(OtherDirectory == Expected),
    setup_call_cleanup(
        assertz(user:unrelated_t004_state(marker)),
        check_source_relative_identity_proof(
            Specification, Program, Authority, Proof, WithState),
        retractall(user:unrelated_t004_state(_))),
    assertion(WithState == Expected).

test(module_boundary_has_one_export_one_predecessor_and_no_meta_state) :-
    module_property(
        cps_source_relative_identity_replay,
        exports(Exports)),
    assertion(
        Exports ==
        [check_source_relative_identity_proof/5]),
    findall(
        Name/Arity,
        ( current_predicate(
              cps_source_relative_identity_replay:Head),
          functor(Head, Name, Arity),
          \+ predicate_property(
                 cps_source_relative_identity_replay:Head,
                 imported_from(_)),
          ( predicate_property(
                cps_source_relative_identity_replay:Head,
                dynamic)
          ; predicate_property(
                cps_source_relative_identity_replay:Head,
                meta_predicate(_))
          )
        ),
        ForbiddenProperties),
    assertion(ForbiddenProperties == []),
    source_file(
        cps_source_relative_identity_replay:
            check_source_relative_identity_proof(_, _, _, _, _),
        SourceFile),
    read_file_to_string(SourceFile, SourceText, []),
    assertion(
        \+ sub_string(
               SourceText, _, _, _, "cps_law_claim_authority")),
    forall(
        member(
            Forbidden,
            [ "call(",
              "once(",
              "maplist(",
              "assert(",
              "asserta(",
              "assertz(",
              "retract(",
              "retractall(",
              "clause(",
              "dynamic ",
              "term_expansion"
            ]),
        assertion(\+ sub_string(SourceText, _, _, _, Forbidden))),
    findall(
        Offset,
        sub_string(
            SourceText, Offset, _, _,
            "validate_ground_typed_equality_pair("),
        CallOffsets),
    assertion(CallOffsets = [_SingleCall]).

test(accepted_checked_proof_makes_only_the_local_claim) :-
    canonical_case(
        Specification, Program, Authority, Proof, Predecessor),
    accepted_expected(Proof, Predecessor, Expected),
    check_source_relative_identity_proof(
        Specification, Program, Authority, Proof, Result),
    assertion(Result == Expected),
    Result = proof_replay(accepted(CheckedProof), _Audit),
    CheckedProof =
        checked_proof(
            proof_format(source_relative_identity_replay_v1),
            proof_id(proof_main),
            theory(source_relative_identity_v1),
            root_step(step_id(step_main)),
            checked_step(
                step_id(step_main),
                rule(source_relative_identity_replay_v1),
                dependencies([]),
                external_references(_),
                conclusion(
                    source_relative_identity_replay(
                        program_id(identity_program),
                        equality_id(represented_equal),
                        definition_space_id(adjacent_defined),
                        premise_id(adjacent_applications))))),
    assertion(
        \+ sub_term(
               specification_satisfied(_), Result)),
    assertion(
        \+ sub_term(
               program_correct(_), Result)).

:- end_tests(cps_source_relative_identity_replay).
