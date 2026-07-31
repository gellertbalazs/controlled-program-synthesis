:- begin_tests(cps_fixed_left_reduction_v0).

:- use_module('../../src/cps_fixed_left_reduction_v0').
:- use_module('../../src/cps_law_claim_authority',
              [ assess_law_claim_authority/2
              ]).
:- use_module(library(readutil)).

:- dynamic ambient_marker/1.

attr_unify_hook(preserved, _Other).

one_tokens(
    [ specification, reduce_spec,
      program, reduce_program,
      reduces, sequence, alpha,
      as, item,
      from, left,
      using, operation, combine,
      in, definition_space, combine_space,
      using, premise, combine_premise
    ]).

two_tokens(
    [ specification, reduce_spec,
      program, reduce_program,
      reduces, sequence, alpha, then, beta,
      as, item,
      from, left,
      using, operation, combine,
      in, definition_space, combine_space,
      using, premise, combine_premise
    ]).

three_tokens(
    [ specification, reduce_spec,
      program, reduce_program,
      reduces, sequence, alpha, then, beta, then, gamma,
      as, item,
      from, left,
      using, operation, combine,
      in, definition_space, combine_space,
      using, premise, combine_premise
    ]).

empty_tokens(
    [ specification, reduce_spec,
      program, reduce_program,
      reduces, sequence,
      as, item,
      from, left,
      using, operation, combine,
      in, definition_space, combine_space,
      using, premise, combine_premise
    ]).

four_tokens(
    [ specification, reduce_spec,
      program, reduce_program,
      reduces, sequence, alpha, then, beta, then, gamma, then, delta,
      as, item,
      from, left,
      using, operation, combine,
      in, definition_space, combine_space,
      using, premise, combine_premise
    ]).

tokens_for_values([alpha], Tokens) :-
    one_tokens(Tokens).
tokens_for_values([alpha, beta], Tokens) :-
    two_tokens(Tokens).
tokens_for_values([alpha, beta, gamma], Tokens) :-
    three_tokens(Tokens).

replace_nth1(1, [_Old|Tail], Value, [Value|Tail]) :-
    !.
replace_nth1(Index, [Head|Tail], Value, [Head|Replaced]) :-
    Index > 1,
    Next is Index - 1,
    replace_nth1(Next, Tail, Value, Replaced).

atom_of_length(Length, Atom) :-
    length(Characters, Length),
    maplist(=(a), Characters),
    atom_chars(Atom, Characters).

canonical_evidence(
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
                established(negative_cases))))).

canonical_authority(Authority) :-
    reduction_authority(item, combine_space, combine_premise, Authority).

reduction_authority(Type, DefinitionSpace, Premise, Authority) :-
    Provenance = provenance_id(eop_concepts_p9),
    canonical_evidence(Evidence),
    Policy =
        policy(
            policy_id(source_policy),
            source_relative_law_v1,
            Provenance),
    Semantics =
        semantics(
            signature(signature_id(Type)),
            definedness(definition_space_id(DefinitionSpace)),
            law(
                law_id(combine_fixed_left),
                equality(equality_id(structural))),
            termination(termination_id(remaining_values)),
            cost(cost_id(n_minus_one)),
            effects(effects_id(pure_fresh)),
            provenance(Provenance)),
    Claim =
        claim(
            claim_id(combine_fixed_left),
            Semantics,
            uses([premise_id(Premise)]),
            requires([obligation_id(each_application_defined)]),
            conflicts([contradiction_id(no_undefined_application)]),
            current(Provenance)),
    Records =
        semantic_records(
            signature(
                signature_id(Type),
                descriptor(binary_same_type_combine),
                accepted(Provenance),
                Provenance),
            definition_space(
                definition_space_id(DefinitionSpace),
                signature_id(Type),
                descriptor(one_to_three_ground_values),
                accepted(Provenance),
                Provenance),
            law(
                law_id(combine_fixed_left),
                signature_id(Type),
                definition_space_id(DefinitionSpace),
                equality_id(structural),
                descriptor(fixed_left_construction),
                accepted(Provenance),
                Provenance),
            equality_relation(
                equality_id(structural),
                signature_id(Type),
                definition_space_id(DefinitionSpace),
                relation(structural_term_identity),
                accepted(Provenance),
                Provenance),
            termination(
                termination_id(remaining_values),
                law_id(combine_fixed_left),
                measure(remaining_values),
                accepted(Provenance),
                Provenance),
            cost(
                cost_id(n_minus_one),
                law_id(combine_fixed_left),
                operation_count(n_minus_one),
                accepted(Provenance),
                Provenance),
            effects(
                effects_id(pure_fresh),
                law_id(combine_fixed_left),
                conditions(pure_fresh_construction),
                accepted(Provenance),
                Provenance)),
    Premises =
        [ premise(
              premise_id(Premise),
              active(Provenance),
              trusted(policy_id(source_policy), Provenance),
              Provenance)
        ],
    Obligations =
        [ obligation(
              obligation_id(each_application_defined),
              law_id(combine_fixed_left),
              applicable(Provenance),
              accepted(Provenance),
              Provenance)
        ],
    Contradictions =
        [ contradiction(
              contradiction_id(no_undefined_application),
              claim_id(combine_fixed_left),
              cleared(Provenance),
              Provenance)
        ],
    Authority =
        authority_snapshot(
            Policy,
            Claim,
            Records,
            Premises,
            Obligations,
            Contradictions,
            [provenance(Provenance, Evidence)]).

authority_variant(missing_activation, Authority) :-
    canonical_authority(Original),
    Original =
        authority_snapshot(
            Policy, Claim, Records,
            [premise(Id, _Activation, Trust, Provenance)],
            Obligations, Contradictions, Provenances),
    Authority =
        authority_snapshot(
            Policy, Claim, Records,
            [premise(Id, missing, Trust, Provenance)],
            Obligations, Contradictions, Provenances).
authority_variant(inactive, Authority) :-
    canonical_authority(Original),
    Original =
        authority_snapshot(
            Policy, Claim, Records,
            [premise(Id, _Activation, Trust, Provenance)],
            Obligations, Contradictions, Provenances),
    Authority =
        authority_snapshot(
            Policy, Claim, Records,
            [premise(Id, inactive(Provenance), Trust, Provenance)],
            Obligations, Contradictions, Provenances).
authority_variant(untrusted, Authority) :-
    canonical_authority(Original),
    Original =
        authority_snapshot(
            Policy, Claim, Records,
            [premise(Id, Activation, _Trust, Provenance)],
            Obligations, Contradictions, Provenances),
    Authority =
        authority_snapshot(
            Policy, Claim, Records,
            [ premise(
                  Id, Activation,
                  untrusted(policy_id(source_policy), Provenance),
                  Provenance)
            ],
            Obligations, Contradictions, Provenances).
authority_variant(explicit_contradiction, Authority) :-
    canonical_authority(Original),
    Original =
        authority_snapshot(
            Policy, Claim, Records, Premises, Obligations,
            [contradiction(Id, ClaimId, _State, Provenance)],
            Provenances),
    Authority =
        authority_snapshot(
            Policy, Claim, Records, Premises, Obligations,
            [contradiction(Id, ClaimId, explicit(Provenance), Provenance)],
            Provenances).
authority_variant(rejected_obligation, Authority) :-
    canonical_authority(Original),
    Original =
        authority_snapshot(
            Policy, Claim, Records, Premises,
            [obligation(Id, Law, Applicability, _Disposition, Provenance)],
            Contradictions, Provenances),
    Authority =
        authority_snapshot(
            Policy, Claim, Records, Premises,
            [ obligation(
                  Id, Law, Applicability, rejected(Provenance), Provenance)
            ],
            Contradictions, Provenances).
authority_variant(resource, Authority) :-
    canonical_authority(Original),
    atom_of_length(65, Long),
    Original =
        authority_snapshot(
            policy(_PolicyId, Kind, Provenance),
            Claim, Records, Premises, Obligations,
            Contradictions, Provenances),
    Authority =
        authority_snapshot(
            policy(policy_id(Long), Kind, Provenance),
            Claim, Records, Premises, Obligations,
            Contradictions, Provenances).

scope_authority_variant(signature_id, Authority) :-
    reduction_authority(other_type, combine_space, combine_premise, Authority).
scope_authority_variant(definition_space_id, Authority) :-
    reduction_authority(item, other_space, combine_premise, Authority).
scope_authority_variant(premise_ids, Authority) :-
    reduction_authority(item, combine_space, other_premise, Authority).
scope_authority_variant(Field, Authority) :-
    member(
        Field-Replacement,
        [ signature_descriptor-other_signature_descriptor,
          definition_descriptor-other_definition_descriptor,
          law_descriptor-other_law_descriptor,
          equality_relation-other_equality_relation,
          termination_measure-other_termination_measure,
          cost_operation_count-other_cost_count,
          effects_conditions-other_effects_conditions
        ]),
    canonical_authority(Original),
    replace_authority_record_token(Field, Replacement, Original, Authority).

replace_authority_record_token(Field, Replacement, Original, Authority) :-
    Original =
        authority_snapshot(
            Policy, Claim,
            semantic_records(Signature0, Definition0, Law0, Equality0,
                             Termination0, Cost0, Effects0),
            Premises, Obligations, Contradictions, Provenances),
    replace_semantic_record(
        Field, Replacement,
        Signature0, Definition0, Law0, Equality0,
        Termination0, Cost0, Effects0,
        Signature, Definition, Law, Equality,
        Termination, Cost, Effects),
    Authority =
        authority_snapshot(
            Policy, Claim,
            semantic_records(Signature, Definition, Law, Equality,
                             Termination, Cost, Effects),
            Premises, Obligations, Contradictions, Provenances).

replace_semantic_record(
        signature_descriptor, Replacement,
        signature(Id, descriptor(_), Disposition, Provenance),
        Definition, Law, Equality, Termination, Cost, Effects,
        signature(Id, descriptor(Replacement), Disposition, Provenance),
        Definition, Law, Equality, Termination, Cost, Effects).
replace_semantic_record(
        definition_descriptor, Replacement,
        Signature,
        definition_space(Id, SignatureId, descriptor(_), Disposition,
                         Provenance),
        Law, Equality, Termination, Cost, Effects,
        Signature,
        definition_space(Id, SignatureId, descriptor(Replacement),
                         Disposition, Provenance),
        Law, Equality, Termination, Cost, Effects).
replace_semantic_record(
        law_descriptor, Replacement,
        Signature, Definition,
        law(Id, SignatureId, DefinitionId, EqualityId, descriptor(_),
            Disposition, Provenance),
        Equality, Termination, Cost, Effects,
        Signature, Definition,
        law(Id, SignatureId, DefinitionId, EqualityId,
            descriptor(Replacement), Disposition, Provenance),
        Equality, Termination, Cost, Effects).
replace_semantic_record(
        equality_relation, Replacement,
        Signature, Definition, Law,
        equality_relation(Id, SignatureId, DefinitionId, relation(_),
                          Disposition, Provenance),
        Termination, Cost, Effects,
        Signature, Definition, Law,
        equality_relation(Id, SignatureId, DefinitionId,
                          relation(Replacement), Disposition, Provenance),
        Termination, Cost, Effects).
replace_semantic_record(
        termination_measure, Replacement,
        Signature, Definition, Law, Equality,
        termination(Id, LawId, measure(_), Disposition, Provenance),
        Cost, Effects,
        Signature, Definition, Law, Equality,
        termination(Id, LawId, measure(Replacement), Disposition, Provenance),
        Cost, Effects).
replace_semantic_record(
        cost_operation_count, Replacement,
        Signature, Definition, Law, Equality, Termination,
        cost(Id, LawId, operation_count(_), Disposition, Provenance),
        Effects,
        Signature, Definition, Law, Equality, Termination,
        cost(Id, LawId, operation_count(Replacement), Disposition, Provenance),
        Effects).
replace_semantic_record(
        effects_conditions, Replacement,
        Signature, Definition, Law, Equality, Termination, Cost,
        effects(Id, LawId, conditions(_), Disposition, Provenance),
        Signature, Definition, Law, Equality, Termination, Cost,
        effects(Id, LawId, conditions(Replacement), Disposition, Provenance)).

expected_candidate(Values, Candidate) :-
    expected_expression(Values, Expression),
    expected_steps(Values, Steps),
    length(Values, Count),
    Applications is Count - 1,
    Specification =
        reduction_specification_v0(
            specification_id(reduce_spec),
            program_id(reduce_program),
            type_id(item),
            values(ValueTerms),
            operation_id(combine),
            order(left),
            definition_space_id(combine_space),
            premise_id(combine_premise)),
    maplist(wrap_atom_value, Values, ValueTerms),
    Program =
        reduction_program_v0(
            program_id(reduce_program),
            signature(input(sequence(type_id(item))), output(type_id(item))),
            expression(Expression),
            definition_space_id(combine_space),
            premise_id(combine_premise)),
    Scope =
        [ specification_id(reduce_spec),
          program_id(reduce_program),
          operation_id(combine),
          definition_space_id(combine_space),
          premise_id(combine_premise)
        ],
    Proof =
        fixed_left_reduction_proof_v0(
            theory(source_relative_fixed_left_v0),
            scope_references(Scope),
            steps(Steps),
            root(step_id(Count)),
            conclusion(
                fixed_left_reduction(
                    Expression,
                    operation_applications(Applications)))),
    Candidate = reduction_candidate_v0(Specification, Program, Proof).

wrap_atom_value(Value, atom_value(Value)).

expected_expression([Value|Values], Expression) :-
    Leaf = value(atom_value(Value), type_id(item)),
    expected_expression_tail(Values, Leaf, Expression).

expected_expression_tail([], Expression, Expression).
expected_expression_tail([Value|Values], Accumulator, Expression) :-
    Next =
        apply(
            operation_id(combine),
            Accumulator,
            value(atom_value(Value), type_id(item)),
            type_id(item)),
    expected_expression_tail(Values, Next, Expression).

expected_steps([Value|Values], Steps) :-
    Leaf = value(atom_value(Value), type_id(item)),
    Base =
        proof_step(
            step_id(1),
            fixed_left_base,
            dependencies([]),
            source(index(1), atom_value(Value)),
            conclusion(prefix(Leaf), operation_applications(0))),
    expected_extension_steps(Values, 2, Leaf, [Base], Steps).

expected_extension_steps([], _Index, _Expression, Steps, Steps).
expected_extension_steps([Value|Values], Index, Previous, Steps0, Steps) :-
    PreviousIndex is Index - 1,
    Applications is Index - 1,
    Expression =
        apply(
            operation_id(combine),
            Previous,
            value(atom_value(Value), type_id(item)),
            type_id(item)),
    Step =
        proof_step(
            step_id(Index),
            fixed_left_extend,
            dependencies([step_id(PreviousIndex)]),
            source(index(Index), atom_value(Value)),
            conclusion(
                prefix(Expression),
                operation_applications(Applications))),
    append(Steps0, [Step], Steps1),
    Next is Index + 1,
    expected_extension_steps(Values, Next, Expression, Steps1, Steps).

expected_render([Value], [Value]).
expected_render([First, Second|Values], Rendered) :-
    render_application([First], Second, FirstRendered),
    expected_render_tail(Values, FirstRendered, Rendered).

expected_render_tail([], Rendered, Rendered).
expected_render_tail([Value|Values], Accumulator, Rendered) :-
    render_application(Accumulator, Value, Next),
    expected_render_tail(Values, Next, Rendered).

render_application(Left, Right, Rendered) :-
    append([combine, '('|Left], [',', Right, ')'], Rendered).

expected_cost(Values, TokenCells, CandidateCells, Cost) :-
    length(Values, Count),
    Applications is Count - 1,
    AstNodes is Count * 2 - 1,
    RenderTokens is Count * 5 - 4,
    maplist(atom_length, Values, Lengths),
    sum_list(Lengths, ValueScalars),
    RenderScalars is ValueScalars + 10 * Applications,
    Cost =
        reduction_cost(
            source_values(Count),
            operation_applications(Applications),
            token_inspections(TokenCells),
            candidate_inspections(CandidateCells),
            ast_nodes(AstNodes),
            proof_steps(Count),
            render_tokens(RenderTokens),
            render_scalars(RenderScalars)).

proposal(Tokens, Result) :-
    cps_fixed_left_reduction_v0:propose_fixed_left_reduction_v0(
        Tokens, Result).

validation(Tokens, Candidate, Authority, Result) :-
    cps_fixed_left_reduction_v0:verify_fixed_left_reduction_v0(
        Tokens, Candidate, Authority, Result).

one_proposal(Tokens, Result) :-
    findall(Observed, proposal(Tokens, Observed), Results),
    Results = [Result],
    call_cleanup(proposal(Tokens, Deterministic), Det = true),
    Det == true,
    Deterministic == Result.

one_validation(Tokens, Candidate, Authority, Result) :-
    findall(
        Observed,
        validation(Tokens, Candidate, Authority, Observed),
        Results),
    Results = [Result],
    call_cleanup(
        validation(Tokens, Candidate, Authority, Deterministic),
        Det = true),
    Det == true,
    Deterministic == Result.

proposed_candidate(Tokens, Candidate) :-
    one_proposal(
        Tokens,
        reduction_proposal_result(proposed(Candidate), _Audit)).

accepted_validation(Tokens, Candidate, Authority, Bundle, Audit) :-
    one_validation(
        Tokens, Candidate, Authority,
        reduction_validation(accepted(Bundle), Audit)).

validation_status(Tokens, Candidate, Authority, Status, Audit) :-
    one_validation(
        Tokens, Candidate, Authority,
        reduction_validation(Status, Audit)).

candidate_parts(
    reduction_candidate_v0(Specification, Program, Proof),
    Specification, Program, Proof).

replace_candidate_specification(
        reduction_candidate_v0(_Old, Program, Proof), Specification,
        reduction_candidate_v0(Specification, Program, Proof)).

replace_candidate_program(
        reduction_candidate_v0(Specification, _Old, Proof), Program,
        reduction_candidate_v0(Specification, Program, Proof)).

replace_candidate_proof(
        reduction_candidate_v0(Specification, Program, _Old), Proof,
        reduction_candidate_v0(Specification, Program, Proof)).

assert_ground_acyclic(Term) :-
    assertion(ground(Term)),
    assertion(acyclic_term(Term)).

test(proposer_builds_exact_singleton_pair_and_triple_left_candidates) :-
    forall(
        member(Values, [[alpha], [alpha, beta], [alpha, beta, gamma]]),
        ( tokens_for_values(Values, Tokens),
          expected_candidate(Values, ExpectedCandidate),
          one_proposal(Tokens, Result),
          Result =
              reduction_proposal_result(
                  proposed(Candidate),
                  proposal_audit(
                      checked(tokens(TokenCount), cells(TokenCells),
                              depth(TokenDepth)),
                      complete(_Sentence),
                      candidate_count(1))),
          assertion(Candidate == ExpectedCandidate),
          length(Tokens, TokenCount),
          assertion(TokenCells =:= TokenCount * 2 + 1),
          assertion(TokenDepth =:= TokenCount + 1),
          assert_ground_acyclic(Result)
        )).

test(verifier_independently_accepts_and_renders_all_three_sizes) :-
    canonical_authority(Authority),
    forall(
        member(Values, [[alpha], [alpha, beta], [alpha, beta, gamma]]),
        ( tokens_for_values(Values, Tokens),
          expected_candidate(Values, ExpectedCandidate),
          proposed_candidate(Tokens, Candidate),
          assertion(Candidate == ExpectedCandidate),
          accepted_validation(Tokens, Candidate, Authority, Bundle, Audit),
          expected_render(Values, Rendered),
          Bundle =
              checked_reduction_v0(
                  Specification, Program, Proof,
                  authority_audit(AuthorityAudit),
                  Cost,
                  rendered_tokens(Rendered)),
          candidate_parts(Candidate, Specification, Program, Proof),
          Audit =
              reduction_audit(
                  checked(
                      tokens(tokens(_), cells(TokenCells), depth(_)),
                      candidate(cells(CandidateCells), depth(_))),
                  complete(_),
                  authority_assessment(accepted, AuthorityAudit),
                  checked(Specification),
                  checked(Program),
                  checked(Proof),
                  checked(Cost),
                  checked(rendered_tokens(Rendered))),
          expected_cost(Values, TokenCells, CandidateCells, Cost),
          assert_ground_acyclic(Bundle),
          assert_ground_acyclic(Audit)
        )).

test(proposal_output_never_supplies_acceptance_without_fresh_authority) :-
    three_tokens(Tokens),
    proposed_candidate(Tokens, Candidate),
    authority_variant(missing_activation, MissingAuthority),
    validation_status(
        Tokens, Candidate, MissingAuthority,
        unknown(authority(t002, _Missing)), MissingAudit),
    MissingAudit = reduction_audit(_, _, authority_assessment(unknown(_), _),
                                   not_run, not_run, not_run, not_run,
                                   not_run),
    authority_variant(inactive, RejectedAuthority),
    validation_status(
        Tokens, Candidate, RejectedAuthority,
        rejected(authority(t002, inactive_premise(
            premise_id(combine_premise)))), RejectedAudit),
    RejectedAudit = reduction_audit(_, _, authority_assessment(rejected(_), _),
                                    not_run, not_run, not_run, not_run,
                                    not_run).

test(exact_t002_snapshot_is_fresh_accepted_authority) :-
    canonical_authority(Authority),
    findall(
        Assessment,
        assess_law_claim_authority(Authority, Assessment),
        Assessments),
    Assessments = [Assessment],
    Assessment =
        authority_assessment(
            accepted,
            audit(
                claim_id(combine_fixed_left),
                policy_id(source_policy),
                used([
                    claim_id(combine_fixed_left),
                    policy_id(source_policy),
                    signature_id(item),
                    definition_space_id(combine_space),
                    law_id(combine_fixed_left),
                    equality_id(structural),
                    termination_id(remaining_values),
                    cost_id(n_minus_one),
                    effects_id(pure_fresh),
                    premise_id(combine_premise),
                    obligation_id(each_application_defined),
                    contradiction_id(no_undefined_application)
                ]),
                provenance([provenance(provenance_id(eop_concepts_p9), _)]))),
    assert_ground_acyclic(Assessment).

test(token_root_priority_rejects_variable_forged_and_wrong_roots) :-
    Variable = _,
    one_proposal(
        Variable,
        reduction_proposal_result(
            rejected(non_ground_input(tokens)),
            proposal_audit(not_completed, not_run, candidate_count(0)))),
    assertion(var(Variable)),
    Forged =
        reduction_validation(
            accepted(forged),
            reduction_audit(forged, forged, forged, forged,
                            forged, forged, forged, forged)),
    one_proposal(
        Forged,
        reduction_proposal_result(
            rejected(forged_accepted_form(tokens)), _)),
    one_proposal(
        not_a_token_list,
        reduction_proposal_result(
            rejected(malformed_shape(tokens, root)), _)).

test(token_attributes_open_tails_cycles_and_improper_lists_are_explicit) :-
    put_attr(Attributed, plunit_cps_fixed_left_reduction_v0, preserved),
    one_proposal(
        Attributed,
        reduction_proposal_result(
            rejected(non_ground_input(tokens)), _)),
    get_attr(
        Attributed, plunit_cps_fixed_left_reduction_v0, preserved),
    del_attr(Attributed, plunit_cps_fixed_left_reduction_v0),
    Open = [specification|Tail],
    one_proposal(
        Open,
        reduction_proposal_result(
            rejected(non_ground_input(tokens)), _)),
    assertion(var(Tail)),
    Cycle = [specification|Cycle],
    one_proposal(
        Cycle,
        reduction_proposal_result(
            rejected(cyclic_input(tokens)), _)),
    assertion(cyclic_term(Cycle)),
    Improper = [specification|improper_tail],
    one_proposal(
        Improper,
        reduction_proposal_result(
            rejected(malformed_shape(tokens, list)), _)).

test(non_atom_token_is_malformed_without_inspecting_authority) :-
    one_tokens(Base),
    replace_nth1(7, Base, nested(alpha), Tokens),
    one_proposal(
        Tokens,
        reduction_proposal_result(
            rejected(malformed_shape(tokens, token(7))), _)),
    Candidate = _,
    Authority = _,
    validation_status(
        Tokens, Candidate, Authority,
        rejected(malformed_shape(tokens, token(7))), _),
    assertion(var(Candidate)),
    assertion(var(Authority)).

test(token_count_cells_and_depth_boundaries_are_closed_and_prioritized) :-
    four_tokens(Maximum),
    one_proposal(
        Maximum,
        reduction_proposal_result(
            resource_exhausted(
                source_values(max(3), observed_at_least(4))),
            proposal_audit(
                checked(tokens(26), cells(53), depth(27)),
                source_value_limit(max(3), observed_at_least(4)),
                candidate_count(0)))),
    length(MaximumPlusOne, 27),
    maplist(=(a), MaximumPlusOne),
    one_proposal(
        MaximumPlusOne,
        reduction_proposal_result(
            resource_exhausted(
                tokens(count(max(26), observed_at_least(27)))), _)),
    length(Farther, 80),
    maplist(=(a), Farther),
    one_proposal(
        Farther,
        reduction_proposal_result(
            resource_exhausted(
                tokens(count(max(26), observed_at_least(27)))), _)),
    assertion(
        cps_fixed_left_reduction_v0:select_token_resource(
            26, 53, 27, none)),
    assertion(
        cps_fixed_left_reduction_v0:select_token_resource(
            27, 54, 28,
            tokens(count(max(26), observed_at_least(27))))),
    assertion(
        cps_fixed_left_reduction_v0:select_token_resource(
            26, 54, 28,
            tokens(cells(max(53), observed_at_least(54))))),
    assertion(
        cps_fixed_left_reduction_v0:select_token_resource(
            26, 53, 28,
            tokens(depth(max(27), observed_at_least(28))))).

scalar_slot_position(specification_id, 2).
scalar_slot_position(program_id, 4).
scalar_slot_position(value(1), 7).
scalar_slot_position(value(2), 9).
scalar_slot_position(value(3), 11).
scalar_slot_position(type_id, 13).
scalar_slot_position(definition_space_id, 21).
scalar_slot_position(premise_id, 24).

test(every_dynamic_scalar_accepts_64_and_resources_at_65_and_farther) :-
    three_tokens(Base),
    forall(
        scalar_slot_position(Slot, Position),
        ( atom_of_length(64, Maximum),
          replace_nth1(Position, Base, Maximum, AtMaximum),
          one_proposal(
              AtMaximum,
              reduction_proposal_result(proposed(_), _)),
          forall(
              member(Length, [65, 117]),
              ( atom_of_length(Length, Over),
                replace_nth1(Position, Base, Over, OverLimit),
                one_proposal(
                    OverLimit,
                    reduction_proposal_result(
                        resource_exhausted(
                            token_scalar(
                                Slot, max(64), observed_at_least(65))),
                        _))
              ))
        )).

test(every_dynamic_scalar_rejects_case_punctuation_and_keywords) :-
    three_tokens(Base),
    forall(
        scalar_slot_position(Slot, Position),
        forall(
            member(Invalid, ['Upper', '_leading', then]),
            ( replace_nth1(Position, Base, Invalid, Tokens),
              one_proposal(
                  Tokens,
                  reduction_proposal_result(
                      rejected(malformed_scalar(Slot)), _))
            ))).

test(exact_fixed_syntax_rejects_incomplete_leading_trailing_and_wrong_words) :-
    one_tokens(Base),
    Base = [_|Incomplete],
    append([leading], Base, Leading),
    append(Base, [trailing], Trailing),
    replace_nth1(5, Base, transforms, WrongKeyword),
    forall(
        member(Tokens, [[], [specification], Leading, Trailing,
                        WrongKeyword]),
        one_proposal(
            Tokens,
            reduction_proposal_result(
                rejected(malformed_shape(tokens, syntax)), _))),
    one_proposal(
        Incomplete,
        reduction_proposal_result(
            rejected(malformed_scalar(specification_id)), _)).

test(recognized_empty_order_operation_and_feature_exclusions_are_unsupported) :-
    empty_tokens(Empty),
    one_proposal(
        Empty,
        reduction_proposal_result(
            unsupported(empty_reduction), _)),
    three_tokens(Base),
    replace_nth1(15, Base, right, Right),
    one_proposal(
        Right,
        reduction_proposal_result(unsupported(order(right)), _)),
    replace_nth1(18, Base, add, OtherOperation),
    one_proposal(
        OtherOperation,
        reduction_proposal_result(unsupported(operation(add)), _)),
    forall(
        member(Feature, [identity, balanced, parallel, mutable, lambda,
                         quantified, executable, backend]),
        ( replace_nth1(15, Base, Feature, Tokens),
          one_proposal(
              Tokens,
              reduction_proposal_result(
                  unsupported(feature(Feature)), _))
        )).

test(token_nonacceptance_outranks_candidate_and_authority_observations) :-
    three_tokens(Base),
    replace_nth1(5, Base, malformed, BadTokens),
    Candidate = _,
    Authority = _,
    validation_status(
        BadTokens, Candidate, Authority,
        rejected(malformed_shape(tokens, syntax)), Audit),
    assertion(var(Candidate)),
    assertion(var(Authority)),
    Audit = reduction_audit(_, _, not_run, not_run, not_run, not_run,
                            not_run, not_run),
    empty_tokens(Empty),
    validation_status(
        Empty, Candidate, Authority,
        unsupported(empty_reduction), _),
    four_tokens(Four),
    validation_status(
        Four, Candidate, Authority,
        resource_exhausted(
            source_values(max(3), observed_at_least(4))), _).

unary_chain(0, leaf) :-
    !.
unary_chain(Depth, chain(Rest)) :-
    Depth > 0,
    Next is Depth - 1,
    unary_chain(Next, Rest).

wide_candidate(ArgumentCount, Candidate) :-
    length(Arguments, ArgumentCount),
    maplist(=(cell), Arguments),
    compound_name_arguments(Wide, payload, Arguments),
    Candidate = reduction_candidate_v0(Wide, program, proof).

deep_candidate(ChainDepth, Candidate) :-
    unary_chain(ChainDepth, Deep),
    Candidate = reduction_candidate_v0(Deep, program, proof).

test(candidate_root_priority_is_after_tokens_and_before_authority) :-
    three_tokens(Tokens),
    Authority = _,
    CandidateVariable = _,
    validation_status(
        Tokens, CandidateVariable, Authority,
        rejected(non_ground_input(candidate)), _),
    assertion(var(CandidateVariable)),
    assertion(var(Authority)),
    Forged =
        checked_reduction_v0(
            specification, program, proof, authority_audit(forged),
            cost, rendered_tokens([forged])),
    validation_status(
        Tokens, Forged, Authority,
        rejected(forged_accepted_form(candidate)), _),
    validation_status(
        Tokens, not_a_candidate, Authority,
        rejected(malformed_shape(candidate, root)), _),
    assertion(var(Authority)).

test(candidate_variables_attributes_cycles_and_improper_lists_are_preserved) :-
    three_tokens(Tokens),
    canonical_authority(Authority),
    expected_candidate([alpha, beta, gamma], Base),
    candidate_parts(Base, Specification, Program, Proof),
    NonGround = reduction_candidate_v0(Variable, Program, Proof),
    validation_status(
        Tokens, NonGround, Authority,
        rejected(non_ground_input(candidate)), _),
    assertion(var(Variable)),
    put_attr(Attributed, plunit_cps_fixed_left_reduction_v0, preserved),
    WithAttribute =
        reduction_candidate_v0(Attributed, Program, Proof),
    validation_status(
        Tokens, WithAttribute, Authority,
        rejected(non_ground_input(candidate)), _),
    get_attr(
        Attributed, plunit_cps_fixed_left_reduction_v0, preserved),
    del_attr(Attributed, plunit_cps_fixed_left_reduction_v0),
    Cyclic = reduction_candidate_v0(Cyclic, Program, Proof),
    validation_status(
        Tokens, Cyclic, Authority,
        rejected(cyclic_input(candidate)), _),
    assertion(cyclic_term(Cyclic)),
    Specification =
        reduction_specification_v0(A, B, C, values(_), E, F, G, H),
    ImproperSpecification =
        reduction_specification_v0(
            A, B, C, values([atom_value(alpha)|improper]), E, F, G, H),
    Improper =
        reduction_candidate_v0(ImproperSpecification, Program, Proof),
    validation_status(
        Tokens, Improper, Authority,
        rejected(malformed_shape(candidate, values)), _).

test(candidate_cell_and_depth_maxima_plus_one_and_farther_are_exact) :-
    wide_candidate(508, AtCellMaximum),
    assertion(
        cps_fixed_left_reduction_v0:candidate_preflight(
            AtCellMaximum, checked(512, 3))),
    wide_candidate(509, OverCellMaximum),
    assertion(
        cps_fixed_left_reduction_v0:candidate_preflight(
            OverCellMaximum,
            resource(candidate(cells(max(512), observed_at_least(513)))))),
    wide_candidate(700, FarOverCells),
    assertion(
        cps_fixed_left_reduction_v0:candidate_preflight(
            FarOverCells,
            resource(candidate(cells(max(512), observed_at_least(513)))))),
    deep_candidate(30, AtDepthMaximum),
    assertion(
        cps_fixed_left_reduction_v0:candidate_preflight(
            AtDepthMaximum, checked(_, 32))),
    deep_candidate(31, OverDepthMaximum),
    assertion(
        cps_fixed_left_reduction_v0:candidate_preflight(
            OverDepthMaximum,
            resource(candidate(depth(max(32), observed_at_least(33)))))),
    deep_candidate(80, FarOverDepth),
    assertion(
        cps_fixed_left_reduction_v0:candidate_preflight(
            FarOverDepth,
            resource(candidate(depth(max(32), observed_at_least(33)))))).

candidate_list_variant(values, Candidate) :-
    expected_candidate([alpha, beta, gamma], Original),
    candidate_parts(Original, Specification0, Program, Proof),
    Specification0 =
        reduction_specification_v0(
            S, G, T, values(_), Operation, Order, D, P),
    Specification =
        reduction_specification_v0(
            S, G, T,
            values([atom_value(alpha), atom_value(beta), atom_value(gamma),
                    atom_value(delta)]),
            Operation, Order, D, P),
    Candidate = reduction_candidate_v0(Specification, Program, Proof).
candidate_list_variant(steps, Candidate) :-
    expected_candidate([alpha, beta, gamma], Original),
    candidate_parts(Original, Specification, Program, Proof0),
    Proof0 =
        fixed_left_reduction_proof_v0(
            Theory, Scope, steps([One, Two, Three]), Root, Conclusion),
    Proof =
        fixed_left_reduction_proof_v0(
            Theory, Scope, steps([One, Two, Three, Three]), Root,
            Conclusion),
    Candidate = reduction_candidate_v0(Specification, Program, Proof).
candidate_list_variant(dependencies, Candidate) :-
    expected_candidate([alpha, beta, gamma], Original),
    candidate_parts(Original, Specification, Program, Proof0),
    Proof0 =
        fixed_left_reduction_proof_v0(
            Theory, Scope, steps([One, Two0, Three]), Root, Conclusion),
    Two0 =
        proof_step(Id, Rule, dependencies([Dependency]), Source,
                   StepConclusion),
    Two =
        proof_step(
            Id, Rule, dependencies([Dependency, Dependency]), Source,
            StepConclusion),
    Proof =
        fixed_left_reduction_proof_v0(
            Theory, Scope, steps([One, Two, Three]), Root, Conclusion),
    Candidate = reduction_candidate_v0(Specification, Program, Proof).
candidate_list_variant(scope_references, Candidate) :-
    expected_candidate([alpha, beta, gamma], Original),
    candidate_parts(Original, Specification, Program, Proof0),
    Proof0 =
        fixed_left_reduction_proof_v0(
            Theory, scope_references(References), Steps, Root, Conclusion),
    append(References, [extra_reference], Over),
    Proof =
        fixed_left_reduction_proof_v0(
            Theory, scope_references(Over), Steps, Root, Conclusion),
    Candidate = reduction_candidate_v0(Specification, Program, Proof).

test(every_candidate_list_limit_resources_before_authority) :-
    three_tokens(Tokens),
    Authority = _,
    forall(
        member(
            List-Maximum,
            [ values-3,
              steps-3,
              dependencies-1,
              scope_references-5
            ]),
        ( candidate_list_variant(List, Candidate),
          Observed is Maximum + 1,
          validation_status(
              Tokens, Candidate, Authority,
              resource_exhausted(
                  candidate_list(
                      List, max(Maximum), observed_at_least(Observed))), _)
        )),
    assertion(var(Authority)).

program_resource_variant(ast_nodes, Candidate) :-
    expected_candidate([alpha, beta, gamma], Original),
    candidate_parts(Original, Specification, Program0, Proof),
    Program0 =
        reduction_program_v0(Id, Signature, expression(Expression0), D, P),
    Expression =
        apply(
            operation_id(combine), Expression0,
            value(atom_value(delta), type_id(item)), type_id(item)),
    Program =
        reduction_program_v0(Id, Signature, expression(Expression), D, P),
    Candidate = reduction_candidate_v0(Specification, Program, Proof).
program_resource_variant(ast_depth, Candidate) :-
    expected_candidate([alpha, beta, gamma], Original),
    candidate_parts(Original, Specification, Program0, Proof),
    Program0 =
        reduction_program_v0(Id, Signature, expression(_Expression0), D, P),
    Expression = deep(deep(deep(leaf))),
    Program =
        reduction_program_v0(Id, Signature, expression(Expression), D, P),
    Candidate = reduction_candidate_v0(Specification, Program, Proof).

test(program_ast_node_and_depth_resources_are_separate) :-
    three_tokens(Tokens),
    canonical_authority(Authority),
    program_resource_variant(ast_nodes, NodesCandidate),
    validation_status(
        Tokens, NodesCandidate, Authority,
        resource_exhausted(
            program_ast(nodes(max(5), observed_at_least(6)))), _),
    program_resource_variant(ast_depth, DepthCandidate),
    validation_status(
        Tokens, DepthCandidate, Authority,
        resource_exhausted(
            program_ast(depth(max(3), observed_at_least(4)))), _).

candidate_scalar_variant(Slot, Value, Candidate) :-
    expected_candidate([alpha, beta, gamma], Original),
    candidate_parts(Original, Specification0, Program0, Proof0),
    candidate_scalar_replacement(
        Slot, Value, Specification0, Program0, Proof0,
        Specification, Program, Proof),
    Candidate = reduction_candidate_v0(Specification, Program, Proof).

candidate_scalar_replacement(
        specification_id, Value,
        reduction_specification_v0(_, G, T, Values, O, R, D, P),
        Program, Proof,
        reduction_specification_v0(
            specification_id(Value), G, T, Values, O, R, D, P),
        Program, Proof).
candidate_scalar_replacement(
        program_id, Value,
        Specification,
        reduction_program_v0(_, Signature, Expression, D, P),
        Proof,
        Specification,
        reduction_program_v0(
            program_id(Value), Signature, Expression, D, P),
        Proof).
candidate_scalar_replacement(
        type_id, Value,
        reduction_specification_v0(S, G, _, Values, O, R, D, P),
        Program, Proof,
        reduction_specification_v0(
            S, G, type_id(Value), Values, O, R, D, P),
        Program, Proof).
candidate_scalar_replacement(
        value(1), Value,
        reduction_specification_v0(
            S, G, T, values([_|Tail]), O, R, D, P),
        Program, Proof,
        reduction_specification_v0(
            S, G, T, values([atom_value(Value)|Tail]), O, R, D, P),
        Program, Proof).
candidate_scalar_replacement(
        definition_space_id, Value,
        reduction_specification_v0(S, G, T, Values, O, R, _, P),
        Program, Proof,
        reduction_specification_v0(
            S, G, T, Values, O, R, definition_space_id(Value), P),
        Program, Proof).
candidate_scalar_replacement(
        premise_id, Value,
        reduction_specification_v0(S, G, T, Values, O, R, D, _),
        Program, Proof,
        reduction_specification_v0(
            S, G, T, Values, O, R, D, premise_id(Value)),
        Program, Proof).

candidate_scalar_slot(specification_id).
candidate_scalar_slot(program_id).
candidate_scalar_slot(type_id).
candidate_scalar_slot(value(1)).
candidate_scalar_slot(definition_space_id).
candidate_scalar_slot(premise_id).

test(candidate_scalar_max_plus_one_and_malformed_are_fail_closed) :-
    three_tokens(Tokens),
    canonical_authority(Authority),
    atom_of_length(65, Long),
    forall(
        candidate_scalar_slot(Slot),
        ( candidate_scalar_variant(Slot, Long, ResourceCandidate),
          validation_status(
              Tokens, ResourceCandidate, Authority,
              resource_exhausted(
                  candidate_scalar(
                      Slot, max(64), observed_at_least(65))), _),
          candidate_scalar_variant(Slot, 'Upper', MalformedCandidate),
          validation_status(
              Tokens, MalformedCandidate, Authority,
              rejected(malformed_scalar(candidate(Slot))), _)
        )).

specification_variant(
        specification_id,
        reduction_specification_v0(_, G, T, V, O, R, D, P),
        reduction_specification_v0(
            specification_id(other_spec), G, T, V, O, R, D, P)).
specification_variant(
        program_id,
        reduction_specification_v0(S, _, T, V, O, R, D, P),
        reduction_specification_v0(
            S, program_id(other_program), T, V, O, R, D, P)).
specification_variant(
        type_id,
        reduction_specification_v0(S, G, _, V, O, R, D, P),
        reduction_specification_v0(
            S, G, type_id(other_type), V, O, R, D, P)).
specification_variant(
        values,
        reduction_specification_v0(S, G, T, _, O, R, D, P),
        reduction_specification_v0(
            S, G, T,
            values([atom_value(alpha), atom_value(gamma), atom_value(beta)]),
            O, R, D, P)).
specification_variant(
        operation_id,
        reduction_specification_v0(S, G, T, V, _, R, D, P),
        reduction_specification_v0(
            S, G, T, V, operation_id(other_operation), R, D, P)).
specification_variant(
        order,
        reduction_specification_v0(S, G, T, V, O, _, D, P),
        reduction_specification_v0(S, G, T, V, O, order(right), D, P)).
specification_variant(
        definition_space_id,
        reduction_specification_v0(S, G, T, V, O, R, _, P),
        reduction_specification_v0(
            S, G, T, V, O, R, definition_space_id(other_space), P)).
specification_variant(
        premise_id,
        reduction_specification_v0(S, G, T, V, O, R, D, _),
        reduction_specification_v0(
            S, G, T, V, O, R, D, premise_id(other_premise))).

test(every_specification_field_is_independently_rebuilt) :-
    three_tokens(Tokens),
    canonical_authority(Authority),
    expected_candidate([alpha, beta, gamma], Original),
    candidate_parts(Original, Specification0, _Program, _Proof),
    forall(
        specification_variant(Field, Specification0, Specification),
        ( replace_candidate_specification(
              Original, Specification, Candidate),
          validation_status(
              Tokens, Candidate, Authority,
              rejected(specification_mismatch(Field)), Audit),
          Audit = reduction_audit(_, _, authority_assessment(accepted, _),
                                  rejected(Field), not_run, not_run,
                                  not_run, not_run)
        )).

program_variant(
        program_id,
        reduction_program_v0(_, Signature, Expression, D, P),
        reduction_program_v0(
            program_id(other_program), Signature, Expression, D, P)).
program_variant(
        signature,
        reduction_program_v0(Id, _, Expression, D, P),
        reduction_program_v0(
            Id,
            signature(input(sequence(type_id(other))),
                      output(type_id(other))),
            Expression, D, P)).
program_variant(
        expression,
        reduction_program_v0(Id, Signature, _, D, P),
        reduction_program_v0(
            Id, Signature,
            expression(
                apply(
                    operation_id(combine),
                    value(atom_value(alpha), type_id(item)),
                    apply(
                        operation_id(combine),
                        value(atom_value(beta), type_id(item)),
                        value(atom_value(gamma), type_id(item)),
                        type_id(item)),
                    type_id(item))),
            D, P)).
program_variant(
        expression,
        reduction_program_v0(Id, Signature, _, D, P),
        reduction_program_v0(
            Id, Signature,
            expression(
                apply(
                    operation_id(other_operation),
                    apply(
                        operation_id(combine),
                        value(atom_value(alpha), type_id(item)),
                        value(atom_value(beta), type_id(item)),
                        type_id(item)),
                    value(atom_value(gamma), type_id(item)),
                    type_id(item))),
            D, P)).
program_variant(
        expression,
        reduction_program_v0(Id, Signature, _, D, P),
        reduction_program_v0(
            Id, Signature,
            expression(value(atom_value(alpha), type_id(item))),
            D, P)).
program_variant(
        definition_space_id,
        reduction_program_v0(Id, Signature, Expression, _, P),
        reduction_program_v0(
            Id, Signature, Expression,
            definition_space_id(other_space), P)).
program_variant(
        premise_id,
        reduction_program_v0(Id, Signature, Expression, D, _),
        reduction_program_v0(
            Id, Signature, Expression, D, premise_id(other_premise))).

single_program_expression_variant(Program, Variant) :-
    program_variant(expression, Program, Variant),
    !.

test(program_ast_and_every_program_field_are_independently_rebuilt) :-
    three_tokens(Tokens),
    canonical_authority(Authority),
    expected_candidate([alpha, beta, gamma], Original),
    candidate_parts(Original, _Specification, Program0, _Proof),
    forall(
        program_variant(Field, Program0, Program),
        ( replace_candidate_program(Original, Program, Candidate),
          validation_status(
              Tokens, Candidate, Authority,
              rejected(program_mismatch(Field)), Audit),
          Audit = reduction_audit(_, _, authority_assessment(accepted, _),
                                  checked(_), rejected(Field), not_run,
                                  not_run, not_run)
        )).

proof_variant(scope_references,
        fixed_left_reduction_proof_v0(
            Theory, scope_references([_|Tail]), Steps, Root, Conclusion),
        fixed_left_reduction_proof_v0(
            Theory, scope_references([wrong_reference|Tail]), Steps,
            Root, Conclusion)).
proof_variant(steps,
        fixed_left_reduction_proof_v0(
            Theory, Scope, steps([One, Two, Three]), Root, Conclusion),
        fixed_left_reduction_proof_v0(
            Theory, Scope, steps([One, Three, Two]), Root, Conclusion)).
proof_variant(dependencies,
        fixed_left_reduction_proof_v0(
            Theory, Scope, steps([One, Two0, Three]), Root, Conclusion),
        fixed_left_reduction_proof_v0(
            Theory, Scope, steps([One, Two, Three]), Root, Conclusion)) :-
    Two0 =
        proof_step(Id, Rule, dependencies(_), Source, StepConclusion),
    Two =
        proof_step(
            Id, Rule, dependencies([step_id(99)]), Source,
            StepConclusion).
proof_variant(source_index,
        fixed_left_reduction_proof_v0(
            Theory, Scope, steps([One, Two0, Three]), Root, Conclusion),
        fixed_left_reduction_proof_v0(
            Theory, Scope, steps([One, Two, Three]), Root, Conclusion)) :-
    Two0 =
        proof_step(Id, Rule, Dependencies,
                   source(_Index, Value), StepConclusion),
    Two =
        proof_step(
            Id, Rule, Dependencies, source(index(3), Value),
            StepConclusion).
proof_variant(source_value,
        fixed_left_reduction_proof_v0(
            Theory, Scope, steps([One, Two0, Three]), Root, Conclusion),
        fixed_left_reduction_proof_v0(
            Theory, Scope, steps([One, Two, Three]), Root, Conclusion)) :-
    Two0 =
        proof_step(Id, Rule, Dependencies,
                   source(Index, _Value), StepConclusion),
    Two =
        proof_step(
            Id, Rule, Dependencies,
            source(Index, atom_value(wrong_value)),
            StepConclusion).
proof_variant(step_conclusion,
        fixed_left_reduction_proof_v0(
            Theory, Scope, steps([One, Two0, Three]), Root, Conclusion),
        fixed_left_reduction_proof_v0(
            Theory, Scope, steps([One, Two, Three]), Root, Conclusion)) :-
    Two0 =
        proof_step(Id, Rule, Dependencies, Source, _StepConclusion),
    Two =
        proof_step(
            Id, Rule, Dependencies, Source,
            conclusion(prefix(wrong), operation_applications(99))).
proof_variant(root,
        fixed_left_reduction_proof_v0(
            Theory, Scope, Steps, _Root, Conclusion),
        fixed_left_reduction_proof_v0(
            Theory, Scope, Steps, root(step_id(2)), Conclusion)).
proof_variant(conclusion,
        fixed_left_reduction_proof_v0(
            Theory, Scope, Steps, Root, _Conclusion),
        fixed_left_reduction_proof_v0(
            Theory, Scope, Steps, Root,
            conclusion(fixed_left_reduction(
                wrong_expression, operation_applications(99))))).

test(proof_replay_checks_every_reference_step_dependency_root_and_conclusion) :-
    three_tokens(Tokens),
    canonical_authority(Authority),
    expected_candidate([alpha, beta, gamma], Original),
    candidate_parts(Original, _Specification, _Program, Proof0),
    forall(
        proof_variant(Field, Proof0, Proof),
        ( replace_candidate_proof(Original, Proof, Candidate),
          validation_status(
              Tokens, Candidate, Authority,
              rejected(proof_mismatch(Field)), Audit),
          Audit = reduction_audit(_, _, authority_assessment(accepted, _),
                                  checked(_), checked(_), rejected(Field),
                                  not_run, not_run)
        )).

proof_rule_variant(Rule, Candidate) :-
    expected_candidate([alpha, beta, gamma], Original),
    candidate_parts(Original, Specification, Program, Proof0),
    Proof0 =
        fixed_left_reduction_proof_v0(
            Theory, Scope, steps([One, Two0, Three]), Root, Conclusion),
    Two0 = proof_step(Id, _OldRule, Dependencies, Source, StepConclusion),
    Two = proof_step(Id, Rule, Dependencies, Source, StepConclusion),
    Proof =
        fixed_left_reduction_proof_v0(
            Theory, Scope, steps([One, Two, Three]), Root, Conclusion),
    Candidate = reduction_candidate_v0(Specification, Program, Proof).

test(proof_format_theory_and_rule_are_unsupported_before_authority) :-
    three_tokens(Tokens),
    expected_candidate([alpha, beta, gamma], Original),
    Authority = _,
    replace_candidate_proof(Original, not_a_proof, BadFormat),
    validation_status(
        Tokens, BadFormat, Authority,
        unsupported(proof_format), _),
    candidate_parts(Original, Specification, Program, Proof0),
    Proof0 =
        fixed_left_reduction_proof_v0(
            _Theory, Scope, Steps, Root, Conclusion),
    WrongTheory =
        fixed_left_reduction_proof_v0(
            theory(other_theory), Scope, Steps, Root, Conclusion),
    TheoryCandidate =
        reduction_candidate_v0(Specification, Program, WrongTheory),
    validation_status(
        Tokens, TheoryCandidate, Authority,
        unsupported(theory), _),
    proof_rule_variant(other_rule, RuleCandidate),
    validation_status(
        Tokens, RuleCandidate, Authority,
        unsupported(rule), _),
    assertion(var(Authority)).

test(hole_and_trusted_step_are_unknown_only_after_program_check) :-
    three_tokens(Tokens),
    canonical_authority(Authority),
    forall(
        member(Kind-Rule, [hole-hole, trusted_step-trusted_step]),
        ( proof_rule_variant(Rule, Candidate),
          validation_status(
              Tokens, Candidate, Authority,
              unknown(unchecked_evidence(Kind, step_id(2))), Audit),
          Audit = reduction_audit(_, _, authority_assessment(accepted, _),
                                  checked(_), checked(_), unknown(_),
                                  not_run, not_run)
        )),
    expected_candidate([alpha, beta, gamma], Original),
    candidate_parts(Original, _Specification, Program0, _Proof),
    single_program_expression_variant(Program0, WrongProgram),
    proof_rule_variant(hole, HoleCandidate0),
    replace_candidate_program(HoleCandidate0, WrongProgram, HoleCandidate),
    validation_status(
        Tokens, HoleCandidate, Authority,
        rejected(program_mismatch(expression)), _).

test(t002_resource_rejection_unknown_and_rejection_priority_map_exactly) :-
    three_tokens(Tokens),
    expected_candidate([alpha, beta, gamma], Candidate),
    authority_variant(resource, ResourceAuthority),
    validation_status(
        Tokens, Candidate, ResourceAuthority,
        resource_exhausted(
            predecessor(t002, resource_limit_exceeded)), ResourceAudit),
    ResourceAudit =
        reduction_audit(_, _,
                        authority_assessment(
                            rejected(resource_limit_exceeded), _),
                        not_run, not_run, not_run, not_run, not_run),
    authority_variant(missing_activation, UnknownAuthority),
    validation_status(
        Tokens, Candidate, UnknownAuthority,
        unknown(authority(t002, Missing)), _),
    member(
        missing(premise_activation, premise_id(combine_premise)), Missing),
    forall(
        member(Variant, [inactive, untrusted, explicit_contradiction,
                         rejected_obligation]),
        ( authority_variant(Variant, RejectedAuthority),
          validation_status(
              Tokens, Candidate, RejectedAuthority,
              rejected(authority(t002, _Reason)), _)
        )).

test(every_exact_authority_projection_field_is_checked_after_t002_acceptance) :-
    three_tokens(Tokens),
    expected_candidate([alpha, beta, gamma], Candidate),
    forall(
        scope_authority_variant(Field, Authority),
        ( assess_law_claim_authority(
              Authority, authority_assessment(accepted, _)),
          validation_status(
              Tokens, Candidate, Authority,
              rejected(authority_scope_mismatch(Field)), Audit),
          Audit = reduction_audit(_, _, authority_assessment(accepted, _),
                                  not_run, not_run, not_run, not_run,
                                  not_run)
        )).

replace_positions([], _Value, Tokens, Tokens).
replace_positions([Position|Positions], Value, Tokens0, Tokens) :-
    replace_nth1(Position, Tokens0, Value, Tokens1),
    replace_positions(Positions, Value, Tokens1, Tokens).

test(all_scalar_and_render_maxima_accept_with_exact_costs) :-
    three_tokens(Base),
    atom_of_length(64, Maximum),
    replace_positions([2, 4, 7, 9, 11, 13, 21, 24],
                      Maximum, Base, Tokens),
    reduction_authority(Maximum, Maximum, Maximum, Authority),
    proposed_candidate(Tokens, Candidate),
    accepted_validation(Tokens, Candidate, Authority, Bundle, _Audit),
    Bundle =
        checked_reduction_v0(
            _Specification, _Program, _Proof, _AuthorityAudit,
            reduction_cost(
                source_values(3),
                operation_applications(2),
                token_inspections(49),
                candidate_inspections(_),
                ast_nodes(5),
                proof_steps(3),
                render_tokens(11),
                render_scalars(212)),
            rendered_tokens(Rendered)),
    length(Rendered, 11),
    assertion(
        cps_fixed_left_reduction_v0:select_render_resource(
            11, 212, none)),
    assertion(
        cps_fixed_left_reduction_v0:select_render_resource(
            12, 212,
            render_tokens(max(11), observed_at_least(12)))),
    assertion(
        cps_fixed_left_reduction_v0:select_render_resource(
            11, 213,
            render_scalars(max(212), observed_at_least(213)))),
    assertion(
        cps_fixed_left_reduction_v0:select_render_resource(
            50, 1000,
            render_tokens(max(11), observed_at_least(12)))).

test(nested_candidate_formats_fail_closed_before_authority) :-
    three_tokens(Tokens),
    expected_candidate([alpha, beta, gamma], Original),
    Authority = _,
    replace_candidate_specification(Original, bad_specification, BadSpec),
    validation_status(
        Tokens, BadSpec, Authority,
        rejected(malformed_shape(candidate, specification)), _),
    replace_candidate_program(Original, bad_program, BadProgram),
    validation_status(
        Tokens, BadProgram, Authority,
        rejected(malformed_shape(candidate, program)), _),
    assertion(var(Authority)).

test(rejection_priority_is_resource_then_authority_then_spec_program_proof) :-
    three_tokens(Tokens),
    expected_candidate([alpha, beta, gamma], Original),
    candidate_parts(Original, Specification0, Program0, _Proof0),
    specification_variant(values, Specification0, WrongSpecification),
    single_program_expression_variant(Program0, WrongProgram),
    proof_rule_variant(hole, HoleCandidate0),
    replace_candidate_specification(
        HoleCandidate0, WrongSpecification, WithWrongSpecification0),
    replace_candidate_program(
        WithWrongSpecification0, WrongProgram, AllWrong),
    authority_variant(resource, ResourceAuthority),
    validation_status(
        Tokens, AllWrong, ResourceAuthority,
        resource_exhausted(
            predecessor(t002, resource_limit_exceeded)), _),
    scope_authority_variant(signature_id, ScopeAuthority),
    validation_status(
        Tokens, AllWrong, ScopeAuthority,
        rejected(authority_scope_mismatch(signature_id)), _),
    canonical_authority(Authority),
    validation_status(
        Tokens, AllWrong, Authority,
        rejected(specification_mismatch(values)), _),
    replace_candidate_specification(
        AllWrong, Specification0, ProgramAndProofWrong),
    validation_status(
        Tokens, ProgramAndProofWrong, Authority,
        rejected(program_mismatch(expression)), _),
    replace_candidate_program(
        ProgramAndProofWrong, Program0, OnlyProofWrong),
    validation_status(
        Tokens, OnlyProofWrong, Authority,
        unknown(unchecked_evidence(hole, step_id(2))), _).

test(right_reassociated_reordered_duplicated_and_omitted_programs_never_accept) :-
    three_tokens(Tokens),
    canonical_authority(Authority),
    expected_candidate([alpha, beta, gamma], Original),
    candidate_parts(Original, _Specification, Program0, _Proof),
    Program0 =
        reduction_program_v0(Id, Signature, _Expression, D, P),
    LeafA = value(atom_value(alpha), type_id(item)),
    LeafB = value(atom_value(beta), type_id(item)),
    LeafC = value(atom_value(gamma), type_id(item)),
    LeftAB = apply(operation_id(combine), LeafA, LeafB, type_id(item)),
    Variants = [
        apply(operation_id(combine), LeafA,
              apply(operation_id(combine), LeafB, LeafC, type_id(item)),
              type_id(item)),
        apply(operation_id(combine),
              apply(operation_id(combine), LeafB, LeafA, type_id(item)),
              LeafC, type_id(item)),
        apply(operation_id(combine), LeftAB, LeafB, type_id(item)),
        LeftAB
    ],
    forall(
        member(Expression, Variants),
        ( Program =
              reduction_program_v0(
                  Id, Signature, expression(Expression), D, P),
          replace_candidate_program(Original, Program, Candidate),
          validation_status(
              Tokens, Candidate, Authority,
              rejected(program_mismatch(expression)), Audit),
          Audit = reduction_audit(_, _, _, _, _, not_run, not_run,
                                  not_run)
        )).

test(every_nonacceptance_path_is_explicitly_unrendered) :-
    three_tokens(Tokens),
    expected_candidate([alpha, beta, gamma], Candidate),
    canonical_authority(Authority),
    authority_variant(inactive, RejectedAuthority),
    authority_variant(missing_activation, UnknownAuthority),
    proof_rule_variant(other_rule, UnsupportedCandidate),
    candidate_list_variant(values, ResourceCandidate),
    replace_candidate_program(Candidate, bad_program, MalformedCandidate),
    Cases = [
        Candidate-RejectedAuthority,
        Candidate-UnknownAuthority,
        UnsupportedCandidate-Authority,
        ResourceCandidate-Authority,
        MalformedCandidate-Authority
    ],
    forall(
        member(CaseCandidate-CaseAuthority, Cases),
        ( one_validation(
              Tokens, CaseCandidate, CaseAuthority,
              reduction_validation(Status, Audit)),
          assertion(Status \= accepted(_)),
          Audit = reduction_audit(_, _, _, _, _, _, _, Render),
          assertion(Render == not_run),
          assert_ground_acyclic(Status)
        )).

test(all_public_results_are_one_ground_acyclic_solution) :-
    one_tokens(One),
    three_tokens(Three),
    empty_tokens(Empty),
    four_tokens(Four),
    canonical_authority(Authority),
    expected_candidate([alpha, beta, gamma], Candidate),
    authority_variant(inactive, RejectedAuthority),
    authority_variant(missing_activation, UnknownAuthority),
    Cases = [
        Three-Candidate-Authority,
        Three-Candidate-RejectedAuthority,
        Three-Candidate-UnknownAuthority,
        Empty-Candidate-Authority,
        Four-Candidate-Authority,
        One-bad_candidate-Authority
    ],
    forall(
        member(Tokens-CaseCandidate-CaseAuthority, Cases),
        ( one_validation(
              Tokens, CaseCandidate, CaseAuthority, Result),
          assert_ground_acyclic(Result)
        )),
    forall(
        member(Tokens, [One, Three, Empty, Four, [malformed]]),
        ( one_proposal(Tokens, Result),
          assert_ground_acyclic(Result)
        )).

test(all_inputs_preserve_identity_sharing_variables_attributes_and_cycles) :-
    three_tokens(Tokens),
    canonical_authority(Authority),
    Shared = _,
    Candidate = reduction_candidate_v0(shared(Shared), shared(Shared), proof),
    BeforeTokens = Tokens,
    BeforeCandidate = Candidate,
    BeforeAuthority = Authority,
    one_validation(Tokens, Candidate, Authority, _),
    assertion(Tokens == BeforeTokens),
    assertion(Candidate == BeforeCandidate),
    assertion(Authority == BeforeAuthority),
    assertion(var(Shared)),
    CyclicCandidate = reduction_candidate_v0(CyclicCandidate, program, proof),
    one_validation(Tokens, CyclicCandidate, Authority, _),
    assertion(cyclic_term(CyclicCandidate)),
    put_attr(Attributed, plunit_cps_fixed_left_reduction_v0, preserved),
    AttributedCandidate =
        reduction_candidate_v0(Attributed, program, proof),
    one_validation(Tokens, AttributedCandidate, Authority, _),
    get_attr(
        Attributed, plunit_cps_fixed_left_reduction_v0, preserved),
    del_attr(Attributed, plunit_cps_fixed_left_reduction_v0).

test(repeated_call_order_directory_and_unrelated_state_do_not_change_results) :-
    three_tokens(Tokens),
    one_tokens(OtherTokens),
    expected_candidate([alpha, beta, gamma], Candidate),
    canonical_authority(Authority),
    one_validation(Tokens, Candidate, Authority, First),
    proposed_candidate(OtherTokens, OtherCandidate),
    one_validation(OtherTokens, OtherCandidate, Authority, _),
    one_validation(Tokens, Candidate, Authority, Second),
    assertion(First == Second),
    setup_call_cleanup(
        assertz(ambient_marker(unrelated)),
        setup_call_cleanup(
            working_directory(Original, '/private/tmp'),
            one_validation(Tokens, Candidate, Authority, Third),
            working_directory(_, Original)),
        retractall(ambient_marker(_))),
    assertion(Third == First).

test(module_exports_only_the_two_approved_predicates) :-
    module_property(cps_fixed_left_reduction_v0, exports(Exports)),
    assertion(
        Exports ==
            [ propose_fixed_left_reduction_v0/2,
              verify_fixed_left_reduction_v0/4
            ]).

test(source_has_only_t002_dependency_and_no_execution_mutation_or_backend) :-
    source_file(
        cps_fixed_left_reduction_v0:propose_fixed_left_reduction_v0(_, _),
        File),
    read_file_to_string(File, Source, []),
    Forbidden = [
        "call(",
        "once(",
        "assert(",
        "assertz(",
        "retract(",
        "retractall(",
        "consult(",
        "process_create(",
        "open(",
        "tcp_",
        "http_",
        "foldl(",
        "phrase_from_file",
        "dcg_compiler.pl",
        "talk.pl",
        "cps_ground_typed_equality_ir",
        "cps_source_relative_identity_replay",
        "cps_controlled_english_v0"
    ],
    forall(
        member(Fragment, Forbidden),
        assertion(\+ sub_string(Source, _, _, _, Fragment))),
    assertion(
        sub_string(Source, _, _, _,
                   ":- use_module(cps_law_claim_authority")),
    findall(
        Imported,
        ( sub_string(Source, _, _, _, ":- use_module("),
          Imported = t002_only
        ),
        Imports),
    assertion(Imports == [t002_only]).

:- end_tests(cps_fixed_left_reduction_v0).
