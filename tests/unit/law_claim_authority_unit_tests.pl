:- begin_tests(cps_law_claim_authority).

:- use_module('../../src/cps_law_claim_authority').

accepted_eop_law(Snapshot, Expected) :-
    Evidence = evidence(
        at(source('eop_concepts.pdf',
                  'references/eop_concepts.pdf',
                  243726,
                  '401346f1e3d75b790cf0229dab174773a4eb854880e6e7c05f6cc924a4afac19'),
           pages(9, 9, 9, 9),
           raw_utf8([112, 97, 114, 116, 105, 97, 108])),
        claim(source_fact, eop_semantics,
              facets(established(binary_operation),
                     established(partial_associativity),
                     established(adjacent_definedness),
                     established(partial_associativity_law),
                     established(well_founded_measure),
                     established(operation_count),
                     established(effect_conditions),
                     established(alias_conditions),
                     established(physical_and_printed_page),
                     established(negative_cases)))),
    Shared = provenance_id(eop_concepts_p9),
    Policy = policy(policy_id(source_policy),
                    source_relative_law_v1,
                    Shared),
    Semantics = semantics(
        signature(signature_id(binary_op)),
        definedness(definition_space_id(adjacent_defined)),
        law(law_id(partial_assoc),
            equality(equality_id(represented_equal))),
        termination(termination_id(structural_descent)),
        cost(cost_id(operation_count)),
        effects(effects_id(read_write_alias)),
        provenance(Shared)),
    Claim = claim(
        claim_id(partial_associativity),
        Semantics,
        uses([premise_id(adjacent_applications)]),
        requires([obligation_id(both_parenthesizations_defined)]),
        conflicts([contradiction_id(no_counterexample)]),
        current(Shared)),
    Records = semantic_records(
        signature(signature_id(binary_op),
                  descriptor(binary_operation),
                  accepted(Shared),
                  Shared),
        definition_space(definition_space_id(adjacent_defined),
                         signature_id(binary_op),
                         descriptor(adjacent_applications),
                         accepted(Shared),
                         Shared),
        law(law_id(partial_assoc),
            signature_id(binary_op),
            definition_space_id(adjacent_defined),
            equality_id(represented_equal),
            descriptor(partial_associativity),
            accepted(Shared),
            Shared),
        equality_relation(equality_id(represented_equal),
                          signature_id(binary_op),
                          definition_space_id(adjacent_defined),
                          relation(represented_value_equality),
                          accepted(Shared),
                          Shared),
        termination(termination_id(structural_descent),
                    law_id(partial_assoc),
                    measure(smaller_structure),
                    accepted(Shared),
                    Shared),
        cost(cost_id(operation_count),
             law_id(partial_assoc),
             operation_count(primitive_applications),
             accepted(Shared),
             Shared),
        effects(effects_id(read_write_alias),
                law_id(partial_assoc),
                conditions(explicit_read_write_alias_overlap),
                accepted(Shared),
                Shared)),
    Premises = [
        premise(premise_id(adjacent_applications),
                active(Shared),
                trusted(policy_id(source_policy), Shared),
                Shared)
    ],
    Obligations = [
        obligation(obligation_id(both_parenthesizations_defined),
                   law_id(partial_assoc),
                   applicable(Shared),
                   accepted(Shared),
                   Shared)
    ],
    Contradictions = [
        contradiction(contradiction_id(no_counterexample),
                      claim_id(partial_associativity),
                      cleared(Shared),
                      Shared)
    ],
    Provenances = [provenance(Shared, Evidence)],
    Snapshot = authority_snapshot(
        Policy, Claim, Records, Premises, Obligations, Contradictions,
        Provenances),
    Items = [
        claim_id(partial_associativity),
        policy_id(source_policy),
        signature_id(binary_op),
        definition_space_id(adjacent_defined),
        law_id(partial_assoc),
        equality_id(represented_equal),
        termination_id(structural_descent),
        cost_id(operation_count),
        effects_id(read_write_alias),
        premise_id(adjacent_applications),
        obligation_id(both_parenthesizations_defined),
        contradiction_id(no_counterexample)
    ],
    Audit = audit(
        claim_id(partial_associativity),
        policy_id(source_policy),
        used(Items),
        provenance([provenance(Shared, Evidence)])),
    Expected = authority_assessment(accepted, Audit).

premise_variants(Kind, Snapshot, Expected) :-
    accepted_eop_law(
        authority_snapshot(Policy, Claim0, Records, _Premises0,
                           Obligations, Contradictions, Provenances),
        authority_assessment(accepted, Audit)),
    Claim0 = claim(ClaimId, Semantics, uses(_), Requires, Conflicts,
                   Lifecycle),
    Shared = provenance_id(eop_concepts_p9),
    (   Kind == inactive
    ->  Ids = [premise_id(adjacent_applications)],
        Premises = [
            premise(premise_id(adjacent_applications),
                    inactive(Shared),
                    trusted(policy_id(source_policy), Shared),
                    Shared)
        ],
        Expected = authority_assessment(
            rejected(inactive_premise(premise_id(adjacent_applications))),
            Audit)
    ;   Kind == untrusted
    ->  Ids = [premise_id(adjacent_applications)],
        Premises = [
            premise(premise_id(adjacent_applications),
                    active(Shared),
                    untrusted(policy_id(source_policy), Shared),
                    Shared)
        ],
        Expected = authority_assessment(
            rejected(untrusted_premise(premise_id(adjacent_applications))),
            Audit)
    ;   Kind == missing_activation
    ->  Ids = [premise_id(adjacent_applications)],
        Premises = [
            premise(premise_id(adjacent_applications),
                    missing,
                    trusted(policy_id(source_policy), Shared),
                    Shared)
        ],
        Expected = authority_assessment(
            unknown([missing(premise_activation,
                             premise_id(adjacent_applications))]),
            Audit)
    ;   Kind == missing_trust
    ->  Ids = [premise_id(adjacent_applications)],
        Premises = [
            premise(premise_id(adjacent_applications),
                    active(Shared),
                    missing,
                    Shared)
        ],
        Expected = authority_assessment(
            unknown([missing(premise_trust(policy_id(source_policy)),
                             premise_id(adjacent_applications))]),
            Audit)
    ;   Kind == cross_policy
    ->  Ids = [premise_id(adjacent_applications)],
        Premises = [
            premise(premise_id(adjacent_applications),
                    active(Shared),
                    trusted(policy_id(other_policy), Shared),
                    Shared)
        ],
        Expected = authority_assessment(
            rejected(reference_mismatch(
                policy,
                policy_id(source_policy),
                policy_id(other_policy))),
            audit(no_claim, no_policy, used([]), provenance([])))
    ;   Kind == duplicate
    ->  Ids = [premise_id(adjacent_applications),
               premise_id(adjacent_applications)],
        Premises = [
            premise(premise_id(adjacent_applications),
                    active(Shared),
                    trusted(policy_id(source_policy), Shared),
                    Shared)
        ],
        Expected = authority_assessment(
            rejected(duplicate_identifier(
                premise, premise_id(adjacent_applications))),
            audit(no_claim, no_policy, used([]), provenance([])))
    ;   Kind == dangling
    ->  Ids = [premise_id(absent_premise)],
        Premises = [],
        Expected = authority_assessment(
            rejected(dangling_reference(
                premise, premise_id(absent_premise))),
            audit(no_claim, no_policy, used([]), provenance([])))
    ;   Kind == extra
    ->  Ids = [],
        Premises = [
            premise(premise_id(extra_premise),
                    active(Shared),
                    trusted(policy_id(source_policy), Shared),
                    Shared)
        ],
        Expected = authority_assessment(
            rejected(extra_record(premise, premise_id(extra_premise))),
            audit(no_claim, no_policy, used([]), provenance([])))
    ),
    Claim = claim(ClaimId, Semantics, uses(Ids), Requires, Conflicts,
                  Lifecycle),
    Snapshot = authority_snapshot(
        Policy, Claim, Records, Premises, Obligations, Contradictions,
        Provenances).

obligation_variants(Kind, Snapshot, Expected) :-
    accepted_eop_law(
        authority_snapshot(Policy, Claim, Records, Premises, _Obligations0,
                           Contradictions, Provenances),
        authority_assessment(accepted, Audit)),
    Shared = provenance_id(eop_concepts_p9),
    (   Kind == rejected
    ->  Applicability = applicable(Shared),
        Disposition = rejected(Shared),
        Expected = authority_assessment(
            rejected(rejected_obligation(
                obligation_id(both_parenthesizations_defined))),
            Audit)
    ;   Kind == missing_disposition
    ->  Applicability = applicable(Shared),
        Disposition = missing,
        Expected = authority_assessment(
            unknown([missing(obligation_disposition,
                             obligation_id(
                                 both_parenthesizations_defined))]),
            Audit)
    ;   Kind == missing_applicability
    ->  Applicability = missing,
        Disposition = missing,
        Expected = authority_assessment(
            unknown([missing(obligation_applicability,
                             obligation_id(
                                 both_parenthesizations_defined)),
                     missing(obligation_disposition,
                             obligation_id(
                                 both_parenthesizations_defined))]),
            Audit)
    ;   Kind == not_applicable
    ->  Applicability = not_applicable(Shared),
        Disposition = not_applicable,
        Expected = authority_assessment(accepted, Audit)
    ),
    Obligations = [
        obligation(obligation_id(both_parenthesizations_defined),
                   law_id(partial_assoc),
                   Applicability,
                   Disposition,
                   Shared)
    ],
    Snapshot = authority_snapshot(
        Policy, Claim, Records, Premises, Obligations, Contradictions,
        Provenances).

contradiction_variants(Kind, Snapshot, Expected) :-
    accepted_eop_law(
        authority_snapshot(Policy, Claim0, Records, Premises, Obligations,
                           _Contradictions0, Provenances),
        authority_assessment(accepted, Audit)),
    Claim0 = claim(ClaimId, Semantics, Uses, Requires, Conflicts, Lifecycle0),
    Shared = provenance_id(eop_concepts_p9),
    (   Kind == explicit
    ->  State = explicit(Shared),
        Lifecycle = Lifecycle0,
        Expected = authority_assessment(
            rejected(explicit_contradiction(
                contradiction_id(no_counterexample))),
            Audit)
    ;   Kind == unresolved
    ->  State = unresolved,
        Lifecycle = Lifecycle0,
        Expected = authority_assessment(
            unknown([missing(contradiction_resolution,
                             contradiction_id(no_counterexample))]),
            Audit)
    ;   Kind == cleared
    ->  State = cleared(Shared),
        Lifecycle = Lifecycle0,
        Expected = authority_assessment(accepted, Audit)
    ;   Kind == retracted
    ->  State = cleared(Shared),
        Lifecycle = retracted(Shared),
        Expected = authority_assessment(
            rejected(retracted_claim(
                claim_id(partial_associativity))),
            Audit)
    ),
    Claim = claim(ClaimId, Semantics, Uses, Requires, Conflicts, Lifecycle),
    Contradictions = [
        contradiction(contradiction_id(no_counterexample),
                      claim_id(partial_associativity),
                      State,
                      Shared)
    ],
    Snapshot = authority_snapshot(
        Policy, Claim, Records, Premises, Obligations, Contradictions,
        Provenances).

provenance_variants(Kind, Snapshot, Expected) :-
    accepted_eop_law(
        authority_snapshot(Policy, Claim, Records, Premises, Obligations,
                           Contradictions, Provenances0),
        authority_assessment(accepted, Audit0)),
    Shared = provenance_id(eop_concepts_p9),
    Provenances0 = [provenance(Shared, AcceptedEvidence)],
    (   Kind == invalid
    ->  Evidence = evidence(
            at(source('dcg_compiler.pl',
                      'references/dcg_compiler.pl',
                      6743,
                      'ce0851db9749c748b4bf194af539da5cf53174c1a2873b07b2a60aa883b11c2f'),
               lines(207, 207),
               raw_utf8([99, 97, 108, 108])),
            claim(source_fact, host_goal_execution,
                  facets(not_applicable, not_applicable, not_applicable,
                         not_applicable, not_applicable, not_applicable,
                         not_applicable, not_applicable,
                         established(exact_line),
                         established(reject_meta_execution)))),
        Provenances = [provenance(Shared, Evidence)],
        Expected = authority_assessment(
            rejected(invalid_provenance(
                Shared, host_goal_execution)),
            audit(no_claim, no_policy, used([]), provenance([])))
    ;   Kind == unknown
    ->  Evidence = evidence(
            at(source('eop_concepts.pdf',
                      'references/eop_concepts.pdf',
                      243726,
                      '401346f1e3d75b790cf0229dab174773a4eb854880e6e7c05f6cc924a4afac19'),
               pages(9, 9, 9, 9),
               raw_utf8([117, 110, 107, 110, 111, 119, 110])),
            claim(source_fact, eop_semantics,
                  facets(established(binary_operation),
                         established(partial_associativity),
                         established(adjacent_definedness),
                         unknown(law_requires_proof),
                         established(well_founded_measure),
                         established(operation_count),
                         established(effect_conditions),
                         established(alias_conditions),
                         established(physical_and_printed_page),
                         established(negative_cases)))),
        Provenances = [provenance(Shared, Evidence)],
        Audit0 = audit(C, P, Used, _),
        Audit = audit(C, P, Used,
                      provenance([provenance(Shared, Evidence)])),
        Expected = authority_assessment(
            unknown([missing_t001(
                Shared,
                [unknown(laws, law_requires_proof)])]),
            Audit)
    ;   Kind == missing
    ->  Provenances = [],
        Expected = authority_assessment(
            rejected(dangling_reference(provenance, Shared)),
            audit(no_claim, no_policy, used([]), provenance([])))
    ;   Kind == duplicate
    ->  Provenances = [provenance(Shared, AcceptedEvidence),
                       provenance(Shared, AcceptedEvidence)],
        Expected = authority_assessment(
            rejected(duplicate_identifier(provenance, Shared)),
            audit(no_claim, no_policy, used([]), provenance([])))
    ;   Kind == extra
    ->  Extra = provenance_id(extra_source),
        Provenances = [provenance(Shared, AcceptedEvidence),
                       provenance(Extra, AcceptedEvidence)],
        Expected = authority_assessment(
            rejected(extra_record(provenance, Extra)),
            audit(no_claim, no_policy, used([]), provenance([])))
    ),
    Snapshot = authority_snapshot(
        Policy, Claim, Records, Premises, Obligations, Contradictions,
        Provenances).

boundary_snapshots(Kind, Snapshot) :-
    accepted_eop_law(
        authority_snapshot(Policy0, Claim0, Records0, Premises0,
                           Obligations, Contradictions0, Provenances),
        _),
    Shared = provenance_id(eop_concepts_p9),
    (   Kind == eight_premises
    ->  Ids = [premise_id(p1), premise_id(p2), premise_id(p3),
               premise_id(p4), premise_id(p5), premise_id(p6),
               premise_id(p7), premise_id(p8)],
        Premises = [
            premise(premise_id(p1), active(Shared),
                    trusted(policy_id(source_policy), Shared), Shared),
            premise(premise_id(p2), active(Shared),
                    trusted(policy_id(source_policy), Shared), Shared),
            premise(premise_id(p3), active(Shared),
                    trusted(policy_id(source_policy), Shared), Shared),
            premise(premise_id(p4), active(Shared),
                    trusted(policy_id(source_policy), Shared), Shared),
            premise(premise_id(p5), active(Shared),
                    trusted(policy_id(source_policy), Shared), Shared),
            premise(premise_id(p6), active(Shared),
                    trusted(policy_id(source_policy), Shared), Shared),
            premise(premise_id(p7), active(Shared),
                    trusted(policy_id(source_policy), Shared), Shared),
            premise(premise_id(p8), active(Shared),
                    trusted(policy_id(source_policy), Shared), Shared)
        ],
        Claim0 = claim(C, S, uses(_), R, F, L),
        Claim = claim(C, S, uses(Ids), R, F, L),
        Policy = Policy0,
        Records = Records0,
        Contradictions = Contradictions0
    ;   Kind == nine_premises
    ->  boundary_snapshots(
            eight_premises,
            authority_snapshot(Policy, Claim8, Records, Premises8,
                               Obligations, Contradictions, Provenances)),
        Claim8 = claim(C, S, uses(Ids8), R, F, L),
        append(Ids8, [premise_id(p9)], Ids),
        append(Premises8,
               [premise(premise_id(p9), active(Shared),
                        trusted(policy_id(source_policy), Shared), Shared)],
               Premises),
        Claim = claim(C, S, uses(Ids), R, F, L)
    ;   Kind == identifier_64
    ->  length(Codes64, 64),
        maplist(=(105), Codes64),
        atom_codes(Id64, Codes64),
        Claim0 = claim(claim_id(_), S, U, R, F, L),
        Claim = claim(claim_id(Id64), S, U, R, F, L),
        Contradictions = [
            contradiction(contradiction_id(no_counterexample),
                          claim_id(Id64), cleared(Shared), Shared)
        ],
        Policy = Policy0,
        Records = Records0,
        Premises = Premises0
    ;   Kind == identifier_65
    ->  length(Codes65, 65),
        maplist(=(105), Codes65),
        atom_codes(Id65, Codes65),
        Claim0 = claim(claim_id(_), S, U, R, F, L),
        Claim = claim(claim_id(Id65), S, U, R, F, L),
        Contradictions = [
            contradiction(contradiction_id(no_counterexample),
                          claim_id(Id65), cleared(Shared), Shared)
        ],
        Policy = Policy0,
        Records = Records0,
        Premises = Premises0
    ;   Kind == descriptor_128
    ->  length(Codes128, 128),
        maplist(=(100), Codes128),
        atom_codes(Token128, Codes128),
        Records0 = semantic_records(
            signature(SId, descriptor(_), Disp, Prov),
            D, Law, Equality, Termination, Cost, Effects),
        Records = semantic_records(
            signature(SId, descriptor(Token128), Disp, Prov),
            D, Law, Equality, Termination, Cost, Effects),
        Policy = Policy0,
        Claim = Claim0,
        Premises = Premises0,
        Contradictions = Contradictions0
    ;   Kind == descriptor_129
    ->  length(Codes129, 129),
        maplist(=(100), Codes129),
        atom_codes(Token129, Codes129),
        Records0 = semantic_records(
            signature(SId, descriptor(_), Disp, Prov),
            D, Law, Equality, Termination, Cost, Effects),
        Records = semantic_records(
            signature(SId, descriptor(Token129), Disp, Prov),
            D, Law, Equality, Termination, Cost, Effects),
        Policy = Policy0,
        Claim = Claim0,
        Premises = Premises0,
        Contradictions = Contradictions0
    ;   Kind == equality_mismatch
    ->  Records0 = semantic_records(
            Signature, Definition,
            law(LId, SId, DId, _EqualityId, Descriptor, Disp, Prov),
            Equality, Termination, Cost, Effects),
        Records = semantic_records(
            Signature, Definition,
            law(LId, SId, DId, equality_id(other_equality),
                Descriptor, Disp, Prov),
            Equality, Termination, Cost, Effects),
        Policy = Policy0,
        Claim = Claim0,
        Premises = Premises0,
        Contradictions = Contradictions0
    ;   Kind == oversized_early_late_variable
    ->  length(Codes, 750001),
        maplist(=(120), Codes),
        atom_codes(Huge, Codes),
        Policy = policy(policy_id(Huge), source_relative_law_v1, Shared),
        Claim = Claim0,
        Records = Records0,
        Premises = Premises0,
        Contradictions = Contradictions0
    ),
    Snapshot = authority_snapshot(
        Policy, Claim, Records, Premises, Obligations, Contradictions,
        Provenances).

nested_wrappers(Count, Term, Nested) :-
    (   Count =:= 0
    ->  Nested = Term
    ;   Next is Count - 1,
        Nested = nested(Tail),
        nested_wrappers(Next, Term, Tail)
    ).

cyclic_wrappers_at_limit(Count, Cyclic) :-
    Cyclic = cycle_link(Tail),
    cyclic_wrapper_tail(Count, Cyclic, Tail).

cyclic_wrapper_tail(0, Cyclic, Cyclic) :-
    !.
cyclic_wrapper_tail(Count, Cyclic, nested(Tail)) :-
    Count > 0,
    Next is Count - 1,
    cyclic_wrapper_tail(Next, Cyclic, Tail).

cyclic_list(Cells, List) :-
    cyclic_list_tail(Cells, List, List).

cyclic_list_tail(0, Root, Root) :-
    !.
cyclic_list_tail(Cells, Root, [item|Tail]) :-
    Cells > 0,
    Next is Cells - 1,
    cyclic_list_tail(Next, Root, Tail).

typed_identifier_functor(policy_id).
typed_identifier_functor(claim_id).
typed_identifier_functor(signature_id).
typed_identifier_functor(definition_space_id).
typed_identifier_functor(law_id).
typed_identifier_functor(equality_id).
typed_identifier_functor(termination_id).
typed_identifier_functor(cost_id).
typed_identifier_functor(effects_id).
typed_identifier_functor(premise_id).
typed_identifier_functor(obligation_id).
typed_identifier_functor(contradiction_id).
typed_identifier_functor(provenance_id).

descriptor_functor(descriptor).
descriptor_functor(relation).
descriptor_functor(measure).
descriptor_functor(operation_count).
descriptor_functor(conditions).

t002_child_index(Term, 1) :-
    % provenance/2 argument 2 is the opaque T001 input and remains under the
    % sole T001 validator rather than the closed T002 field inventory.
    functor(Term, provenance, 2).
t002_child_index(Term, Index) :-
    functor(Term, Name, Arity),
    \+ (Name == provenance, Arity =:= 2),
    between(1, Arity, Index).

child_path(Prefix, Index, Path) :-
    append(Prefix, [Index], Path).

closed_scalar_path(Snapshot, Path, Maximum) :-
    closed_scalar_path(Snapshot, [], Path, Maximum).

closed_scalar_path(Term, Prefix, Path, Maximum) :-
    compound(Term),
    functor(Term, Name, Arity),
    (   Arity =:= 1,
        typed_identifier_functor(Name),
        child_path(Prefix, 1, Path),
        Maximum = 64
    ;   Arity =:= 1,
        descriptor_functor(Name),
        child_path(Prefix, 1, Path),
        Maximum = 128
    ;   Name == policy,
        Arity =:= 3,
        child_path(Prefix, 2, Path),
        Maximum = 128
    ;   t002_child_index(Term, Index),
        arg(Index, Term, Child),
        child_path(Prefix, Index, ChildPrefix),
        closed_scalar_path(Child, ChildPrefix, Path, Maximum)
    ).

closed_constructor_path(Snapshot, Path) :-
    closed_constructor_path(Snapshot, [], Path),
    Path \== [].

closed_constructor_path(Term, Prefix, Path) :-
    compound(Term),
    (   Term \= [_|_],
        Path = Prefix
    ;   t002_child_index(Term, Index),
        arg(Index, Term, Child),
        child_path(Prefix, Index, ChildPrefix),
        closed_constructor_path(Child, ChildPrefix, Path)
    ).

term_at_path(Term, [], Term).
term_at_path(Term, [Index|Tail], Found) :-
    arg(Index, Term, Child),
    term_at_path(Child, Tail, Found).

replace_at_path(_, [], Replacement, Replacement).
replace_at_path(Term, [Target|Tail], Replacement, Rebuilt) :-
    functor(Term, Name, Arity),
    functor(Rebuilt, Name, Arity),
    rebuild_arguments(
        1, Arity, Target, Tail, Term, Replacement, Rebuilt).

rebuild_arguments(Index, Arity, _, _, _, _, _) :-
    Index > Arity,
    !.
rebuild_arguments(
    Index, Arity, Target, Tail, Term, Replacement, Rebuilt) :-
    Index =< Arity,
    arg(Index, Term, SourceArgument),
    arg(Index, Rebuilt, RebuiltArgument),
    (   Index =:= Target
    ->  replace_at_path(
            SourceArgument, Tail, Replacement, RebuiltArgument)
    ;   RebuiltArgument = SourceArgument
    ),
    Next is Index + 1,
    rebuild_arguments(
        Next, Arity, Target, Tail, Term, Replacement, Rebuilt).

renamed_constructor(Term, Renamed) :-
    functor(Term, _, Arity),
    functor(Renamed, invalid_t002_constructor, Arity),
    retain_arguments(1, Arity, Term, Renamed).

retain_arguments(Index, Arity, _, _) :-
    Index > Arity,
    !.
retain_arguments(Index, Arity, Term, Retained) :-
    Index =< Arity,
    arg(Index, Term, Argument),
    arg(Index, Retained, Argument),
    Next is Index + 1,
    retain_arguments(Next, Arity, Term, Retained).

oversized_atom(Maximum, Atom) :-
    Length is Maximum + 1,
    length(Codes, Length),
    fill_codes(Codes, 120),
    atom_codes(Atom, Codes).

fill_codes([], _).
fill_codes([Code|Tail], Code) :-
    fill_codes(Tail, Code).

assert_scalar_priority([], _, _, _).
assert_scalar_priority(
    [Path-Maximum|Tail], Snapshot, Atom65, Atom129) :-
    replace_at_path(Snapshot, Path, _Variable, VariableSnapshot),
    replace_at_path(Snapshot, Path, 42, MalformedSnapshot),
    Cyclic = cycle(Cyclic),
    replace_at_path(Snapshot, Path, Cyclic, CyclicSnapshot),
    (   Maximum =:= 64
    ->  Oversized = Atom65
    ;   Oversized = Atom129
    ),
    replace_at_path(Snapshot, Path, Oversized, ResourceSnapshot),
    assess_law_claim_authority(VariableSnapshot, VariableResult),
    assess_law_claim_authority(MalformedSnapshot, MalformedResult),
    assess_law_claim_authority(CyclicSnapshot, CyclicResult),
    assess_law_claim_authority(ResourceSnapshot, ResourceResult),
    preclosure_result(non_ground_input, ExpectedVariable),
    preclosure_result(malformed_shape, ExpectedMalformed),
    preclosure_result(cyclic_input, ExpectedCyclic),
    preclosure_result(resource_limit_exceeded, ExpectedResource),
    assertion(VariableResult == ExpectedVariable),
    assertion(MalformedResult == ExpectedMalformed),
    assertion(CyclicResult == ExpectedCyclic),
    assertion(ResourceResult == ExpectedResource),
    assert_scalar_priority(Tail, Snapshot, Atom65, Atom129).

assert_constructor_priority([], _).
assert_constructor_priority([Path|Tail], Snapshot) :-
    term_at_path(Snapshot, Path, Constructor),
    renamed_constructor(Constructor, Renamed),
    replace_at_path(Snapshot, Path, _Variable, VariableSnapshot),
    replace_at_path(Snapshot, Path, Renamed, MalformedSnapshot),
    Cyclic = cycle(Cyclic),
    replace_at_path(Snapshot, Path, Cyclic, CyclicSnapshot),
    assess_law_claim_authority(VariableSnapshot, VariableResult),
    assess_law_claim_authority(MalformedSnapshot, MalformedResult),
    assess_law_claim_authority(CyclicSnapshot, CyclicResult),
    preclosure_result(non_ground_input, ExpectedVariable),
    preclosure_result(malformed_shape, ExpectedMalformed),
    preclosure_result(cyclic_input, ExpectedCyclic),
    assertion(VariableResult == ExpectedVariable),
    assertion(MalformedResult == ExpectedMalformed),
    assertion(CyclicResult == ExpectedCyclic),
    assert_constructor_priority(Tail, Snapshot).

preclosure_result(
    Reason,
    authority_assessment(
        rejected(Reason),
        audit(no_claim, no_policy, used([]), provenance([])))).

missing_boundary_snapshot(ProvenanceKind, Snapshot) :-
    accepted_eop_law(
        authority_snapshot(
            Policy,
            claim(ClaimId, Semantics, _, _, _, _),
            semantic_records(
                signature(SignatureId, SignatureDescriptor, _,
                          SignatureProv),
                definition_space(
                    DefinitionId, DefinitionSignatureId,
                    DefinitionDescriptor, _, DefinitionProv),
                law(LawId, LawSignatureId, LawDefinitionId,
                    LawEqualityId, LawDescriptor, _, LawProv),
                equality_relation(
                    EqualityId, EqualitySignatureId,
                    EqualityDefinitionId, EqualityRelation, _,
                    EqualityProv),
                termination(
                    TerminationId, TerminationLawId,
                    TerminationMeasure, _, TerminationProv),
                cost(CostId, CostLawId, CostOperation, _, CostProv),
                effects(
                    EffectsId, EffectsLawId, EffectsConditions, _,
                    EffectsProv)),
            _, _, _, AcceptedProvenances),
        _),
    Shared = provenance_id(eop_concepts_p9),
    Claim = claim(
        ClaimId, Semantics,
        uses([premise_id(p1), premise_id(p2), premise_id(p3),
              premise_id(p4), premise_id(p5), premise_id(p6),
              premise_id(p7), premise_id(p8)]),
        requires([obligation_id(o1), obligation_id(o2),
                  obligation_id(o3), obligation_id(o4),
                  obligation_id(o5), obligation_id(o6),
                  obligation_id(o7), obligation_id(o8)]),
        conflicts([contradiction_id(c1), contradiction_id(c2),
                   contradiction_id(c3), contradiction_id(c4),
                   contradiction_id(c5), contradiction_id(c6),
                   contradiction_id(c7), contradiction_id(c8)]),
        missing),
    Records = semantic_records(
        signature(
            SignatureId, SignatureDescriptor, missing, SignatureProv),
        definition_space(
            DefinitionId, DefinitionSignatureId, DefinitionDescriptor,
            missing, DefinitionProv),
        law(
            LawId, LawSignatureId, LawDefinitionId, LawEqualityId,
            LawDescriptor, missing, LawProv),
        equality_relation(
            EqualityId, EqualitySignatureId, EqualityDefinitionId,
            EqualityRelation, missing, EqualityProv),
        termination(
            TerminationId, TerminationLawId, TerminationMeasure,
            missing, TerminationProv),
        cost(
            CostId, CostLawId, CostOperation, missing, CostProv),
        effects(
            EffectsId, EffectsLawId, EffectsConditions, missing,
            EffectsProv)),
    Premises = [
        premise(premise_id(p1), missing, missing, Shared),
        premise(premise_id(p2), missing, missing, Shared),
        premise(premise_id(p3), missing, missing, Shared),
        premise(premise_id(p4), missing, missing, Shared),
        premise(premise_id(p5), missing, missing, Shared),
        premise(premise_id(p6), missing, missing, Shared),
        premise(premise_id(p7), missing, missing, Shared),
        premise(premise_id(p8), missing, missing, Shared)
    ],
    Obligations = [
        obligation(obligation_id(o1), LawId, missing, missing, Shared),
        obligation(obligation_id(o2), LawId, missing, missing, Shared),
        obligation(obligation_id(o3), LawId, missing, missing, Shared),
        obligation(obligation_id(o4), LawId, missing, missing, Shared),
        obligation(obligation_id(o5), LawId, missing, missing, Shared),
        obligation(obligation_id(o6), LawId, missing, missing, Shared),
        obligation(obligation_id(o7), LawId, missing, missing, Shared),
        obligation(obligation_id(o8), LawId, missing, missing, Shared)
    ],
    Contradictions = [
        contradiction(contradiction_id(c1), ClaimId, unresolved, Shared),
        contradiction(contradiction_id(c2), ClaimId, unresolved, Shared),
        contradiction(contradiction_id(c3), ClaimId, unresolved, Shared),
        contradiction(contradiction_id(c4), ClaimId, unresolved, Shared),
        contradiction(contradiction_id(c5), ClaimId, unresolved, Shared),
        contradiction(contradiction_id(c6), ClaimId, unresolved, Shared),
        contradiction(contradiction_id(c7), ClaimId, unresolved, Shared),
        contradiction(contradiction_id(c8), ClaimId, unresolved, Shared)
    ],
    missing_boundary_provenances(
        ProvenanceKind, AcceptedProvenances, Provenances),
    Snapshot = authority_snapshot(
        Policy, Claim, Records, Premises, Obligations, Contradictions,
        Provenances).

missing_boundary_provenances(accepted, Provenances, Provenances).
missing_boundary_provenances(unknown, _, [provenance(Shared, Evidence)]) :-
    provenance_variants(
        unknown,
        authority_snapshot(_, _, _, _, _, _,
                           [provenance(Shared, Evidence)]),
        _).

semantic_missing([
    missing(signature, signature_id(binary_op)),
    missing(definedness, definition_space_id(adjacent_defined)),
    missing(law, law_id(partial_assoc)),
    missing(equality, equality_id(represented_equal)),
    missing(termination, termination_id(structural_descent)),
    missing(cost, cost_id(operation_count)),
    missing(effects, effects_id(read_write_alias))
]).

premise_missing([
    missing(premise_activation, premise_id(p1)),
    missing(premise_trust(policy_id(source_policy)), premise_id(p1)),
    missing(premise_activation, premise_id(p2)),
    missing(premise_trust(policy_id(source_policy)), premise_id(p2)),
    missing(premise_activation, premise_id(p3)),
    missing(premise_trust(policy_id(source_policy)), premise_id(p3)),
    missing(premise_activation, premise_id(p4)),
    missing(premise_trust(policy_id(source_policy)), premise_id(p4)),
    missing(premise_activation, premise_id(p5)),
    missing(premise_trust(policy_id(source_policy)), premise_id(p5)),
    missing(premise_activation, premise_id(p6)),
    missing(premise_trust(policy_id(source_policy)), premise_id(p6)),
    missing(premise_activation, premise_id(p7)),
    missing(premise_trust(policy_id(source_policy)), premise_id(p7)),
    missing(premise_activation, premise_id(p8)),
    missing(premise_trust(policy_id(source_policy)), premise_id(p8))
]).

obligation_missing([
    missing(obligation_applicability, obligation_id(o1)),
    missing(obligation_disposition, obligation_id(o1)),
    missing(obligation_applicability, obligation_id(o2)),
    missing(obligation_disposition, obligation_id(o2)),
    missing(obligation_applicability, obligation_id(o3)),
    missing(obligation_disposition, obligation_id(o3)),
    missing(obligation_applicability, obligation_id(o4)),
    missing(obligation_disposition, obligation_id(o4)),
    missing(obligation_applicability, obligation_id(o5)),
    missing(obligation_disposition, obligation_id(o5)),
    missing(obligation_applicability, obligation_id(o6)),
    missing(obligation_disposition, obligation_id(o6)),
    missing(obligation_applicability, obligation_id(o7)),
    missing(obligation_disposition, obligation_id(o7)),
    missing(obligation_applicability, obligation_id(o8)),
    missing(obligation_disposition, obligation_id(o8))
]).

contradiction_missing([
    missing(contradiction_resolution, contradiction_id(c1)),
    missing(contradiction_resolution, contradiction_id(c2)),
    missing(contradiction_resolution, contradiction_id(c3)),
    missing(contradiction_resolution, contradiction_id(c4)),
    missing(contradiction_resolution, contradiction_id(c5)),
    missing(contradiction_resolution, contradiction_id(c6)),
    missing(contradiction_resolution, contradiction_id(c7)),
    missing(contradiction_resolution, contradiction_id(c8))
]).

missing_boundary_expected(ProvenanceKind, Missing) :-
    semantic_missing(SemanticMissing),
    missing_boundary_provenance_reason(
        ProvenanceKind, ProvenanceMissing),
    premise_missing(PremiseMissing),
    obligation_missing(ObligationMissing),
    contradiction_missing(ContradictionMissing),
    append(SemanticMissing, ProvenanceMissing, First),
    append(
        First,
        [missing(lifecycle, claim_id(partial_associativity))],
        Second),
    append(Second, PremiseMissing, Third),
    append(Third, ObligationMissing, Fourth),
    append(Fourth, ContradictionMissing, Missing).

missing_boundary_provenance_reason(accepted, []).
missing_boundary_provenance_reason(
    unknown,
    [missing_t001(
        provenance_id(eop_concepts_p9),
        [unknown(laws, law_requires_proof)])]).

test(fully_supported_claim_is_accepted) :-
    accepted_eop_law(Snapshot, Expected),
    assess_law_claim_authority(Snapshot, Result),
    assertion(Result == Expected).

test(eop_concepts_provenance_is_first_class) :-
    accepted_eop_law(Snapshot, Expected),
    assess_law_claim_authority(Snapshot, Result),
    assertion(Result == Expected),
    Result = authority_assessment(
        accepted,
        audit(_, _, _, provenance([provenance(
            provenance_id(eop_concepts_p9),
            evidence(at(source('eop_concepts.pdf', _, _, _),
                        pages(9, 9, 9, 9), _), _))]))).

test(not_applicable_and_cleared_are_accepted) :-
    obligation_variants(not_applicable, NotApplicable, ExpectedNA),
    contradiction_variants(cleared, Cleared, ExpectedCleared),
    assess_law_claim_authority(NotApplicable, NAResult),
    assess_law_claim_authority(Cleared, ClearedResult),
    assertion(NAResult == ExpectedNA),
    assertion(ClearedResult == ExpectedCleared).

test(explicit_contradiction_is_rejected) :-
    contradiction_variants(explicit, Snapshot, Expected),
    assess_law_claim_authority(Snapshot, Result),
    assertion(Result == Expected).

test(outer_non_ground_is_rejected) :-
    assess_law_claim_authority(
        _Snapshot,
        Result),
    assertion(Result == authority_assessment(
        rejected(non_ground_input),
        audit(no_claim, no_policy, used([]), provenance([])))).

test(nested_non_ground_is_rejected) :-
    accepted_eop_law(
        authority_snapshot(Policy, Claim, Records0, Premises, Obligations,
                           Contradictions, Provenances),
        _),
    Records0 = semantic_records(
        signature(Id, descriptor(_), Disposition, Prov),
        D, L, E, T, C, F),
    Records = semantic_records(
        signature(Id, descriptor(nested(_Variable)), Disposition, Prov),
        D, L, E, T, C, F),
    Snapshot = authority_snapshot(
        Policy, Claim, Records, Premises, Obligations, Contradictions,
        Provenances),
    assess_law_claim_authority(Snapshot, Result),
    assertion(Result == authority_assessment(
        rejected(non_ground_input),
        audit(no_claim, no_policy, used([]), provenance([])))).

test(cyclic_input_is_rejected) :-
    accepted_eop_law(
        authority_snapshot(Policy, Claim, Records, _Premises, Obligations,
                           Contradictions, Provenances),
        _),
    CyclicPremises = [
        premise(premise_id(adjacent_applications),
                active(provenance_id(eop_concepts_p9)),
                trusted(policy_id(source_policy),
                        provenance_id(eop_concepts_p9)),
                provenance_id(eop_concepts_p9))
        | CyclicPremises
    ],
    Snapshot = authority_snapshot(
        Policy, Claim, Records, CyclicPremises, Obligations, Contradictions,
        Provenances),
    assess_law_claim_authority(Snapshot, Result),
    assertion(Result == authority_assessment(
        rejected(cyclic_input),
        audit(no_claim, no_policy, used([]), provenance([])))).

test(malformed_shape_is_rejected) :-
    assess_law_claim_authority(not_a_snapshot, Outer),
    accepted_eop_law(
        authority_snapshot(_Policy, Claim, Records, Premises, Obligations,
                           Contradictions, Provenances),
        _),
    Nested = authority_snapshot(
        not_a_policy, Claim, Records, Premises, Obligations, Contradictions,
        Provenances),
    assess_law_claim_authority(Nested, Inner),
    PreAudit = audit(no_claim, no_policy, used([]), provenance([])),
    assertion(Outer == authority_assessment(
        rejected(malformed_shape), PreAudit)),
    assertion(Inner == authority_assessment(
        rejected(malformed_shape), PreAudit)).

test(duplicate_precedes_dangling_and_both_reject) :-
    premise_variants(duplicate, Duplicate, ExpectedDuplicate),
    premise_variants(dangling, Dangling, ExpectedDangling),
    assess_law_claim_authority(Duplicate, DuplicateResult),
    assess_law_claim_authority(Dangling, DanglingResult),
    assertion(DuplicateResult == ExpectedDuplicate),
    assertion(DanglingResult == ExpectedDangling).

test(collection_depth_and_node_bounds_are_exact) :-
    boundary_snapshots(eight_premises, Eight),
    boundary_snapshots(nine_premises, Nine),
    assess_law_claim_authority(Eight, EightResult),
    assess_law_claim_authority(Nine, NineResult),
    EightResult = authority_assessment(accepted, _),
    PreAudit = audit(no_claim, no_policy, used([]), provenance([])),
    assertion(NineResult == authority_assessment(
        rejected(resource_limit_exceeded),
        PreAudit)),
    accepted_eop_law(
        authority_snapshot(
            policy(PolicyId, _Kind, PolicyProv),
            Claim, Records, Premises, Obligations, Contradictions,
            [provenance(ProvenanceId,
                        evidence(at(Source, Span, raw_utf8(_)),
                                 claim(Label, Class,
                                       facets(_SignatureFacet,
                                              ConceptsFacet,
                                              DefinednessFacet,
                                              LawsFacet,
                                              TerminationFacet,
                                              CostFacet,
                                              EffectsFacet,
                                              AliasingFacet,
                                              ProvenanceFacet,
                                              TestFacet))))]),
        _),
    nested_wrappers(31, leaf, Depth32Kind),
    nested_wrappers(32, leaf, Depth33Kind),
    Depth32 = authority_snapshot(
        policy(PolicyId, Depth32Kind, PolicyProv),
        Claim, Records, Premises, Obligations, Contradictions,
        [provenance(ProvenanceId,
                    evidence(at(Source, Span, raw_utf8([97])),
                             claim(Label, Class,
                                   facets(established(binary_operation),
                                          ConceptsFacet,
                                          DefinednessFacet,
                                          LawsFacet,
                                          TerminationFacet,
                                          CostFacet,
                                          EffectsFacet,
                                          AliasingFacet,
                                          ProvenanceFacet,
                                          TestFacet))))]),
    Depth33 = authority_snapshot(
        policy(PolicyId, Depth33Kind, PolicyProv),
        Claim, Records, Premises, Obligations, Contradictions,
        [provenance(ProvenanceId,
                    evidence(at(Source, Span, raw_utf8([97])),
                             claim(Label, Class,
                                   facets(established(binary_operation),
                                          ConceptsFacet,
                                          DefinednessFacet,
                                          LawsFacet,
                                          TerminationFacet,
                                          CostFacet,
                                          EffectsFacet,
                                          AliasingFacet,
                                          ProvenanceFacet,
                                          TestFacet))))]),
    cyclic_wrappers_at_limit(30, BoundaryCycle),
    replace_at_path(Depth33, [1, 2], BoundaryCycle, CyclicDepth),
    replace_at_path(
        Depth33, [2, 1, 1], _LateVariable, DepthThenVariable),
    replace_at_path(
        Depth33, [2, 1, 1], 42, DepthThenMalformed),
    LateCycle = cycle(LateCycle),
    replace_at_path(
        Depth33, [2, 1, 1], LateCycle, DepthThenCycle),
    assess_law_claim_authority(Depth32, Depth32Result),
    assess_law_claim_authority(Depth33, Depth33Result),
    assess_law_claim_authority(CyclicDepth, CyclicDepthResult),
    assess_law_claim_authority(
        DepthThenVariable, DepthThenVariableResult),
    assess_law_claim_authority(
        DepthThenMalformed, DepthThenMalformedResult),
    assess_law_claim_authority(
        DepthThenCycle, DepthThenCycleResult),
    assertion(Depth32Result == authority_assessment(
        rejected(malformed_shape), PreAudit)),
    assertion(Depth33Result == authority_assessment(
        rejected(resource_limit_exceeded), PreAudit)),
    assertion(CyclicDepthResult == authority_assessment(
        rejected(cyclic_input), PreAudit)),
    assertion(DepthThenVariableResult == authority_assessment(
        rejected(non_ground_input), PreAudit)),
    assertion(DepthThenMalformedResult == authority_assessment(
        rejected(malformed_shape), PreAudit)),
    assertion(DepthThenCycleResult == authority_assessment(
        rejected(cyclic_input), PreAudit)),
    accepted_eop_law(LongListBase, _),
    length(Raw4096, 4096),
    fill_codes(Raw4096, 97),
    replace_at_path(
        LongListBase, [7, 1, 2, 1, 3, 1], Raw4096,
        LongListBoundary),
    assess_law_claim_authority(LongListBoundary, LongListResult),
    LongListResult = authority_assessment(accepted, _),
    cyclic_list(100, LongTailCycle),
    replace_at_path(
        LongListBase, [4], LongTailCycle, LongCycleSnapshot),
    assess_law_claim_authority(LongCycleSnapshot, LongCycleResult),
    assertion(LongCycleResult == authority_assessment(
        rejected(cyclic_input), PreAudit)),
    boundary_snapshots(oversized_early_late_variable, Node750001),
    assess_law_claim_authority(Node750001, Node750001Result),
    assertion(Node750001Result == authority_assessment(
        rejected(resource_limit_exceeded), PreAudit)).

test(identifier_and_descriptor_scalar_bounds_are_exact) :-
    boundary_snapshots(identifier_64, Id64),
    boundary_snapshots(identifier_65, Id65),
    boundary_snapshots(descriptor_128, Descriptor128),
    boundary_snapshots(descriptor_129, Descriptor129),
    assess_law_claim_authority(Id64, Id64Result),
    assess_law_claim_authority(Id65, Id65Result),
    assess_law_claim_authority(Descriptor128, Descriptor128Result),
    assess_law_claim_authority(Descriptor129, Descriptor129Result),
    Id64Result = authority_assessment(accepted, _),
    Descriptor128Result = authority_assessment(accepted, _),
    PreAudit = audit(no_claim, no_policy, used([]), provenance([])),
    assertion(Id65Result == authority_assessment(
        rejected(resource_limit_exceeded), PreAudit)),
    assertion(Descriptor129Result == authority_assessment(
        rejected(resource_limit_exceeded), PreAudit)).

test(result_shape_and_all_audits_are_exact) :-
    accepted_eop_law(Accepted, AcceptedExpected),
    contradiction_variants(explicit, Rejected, RejectedExpected),
    obligation_variants(missing_disposition, Unknown, UnknownExpected),
    assess_law_claim_authority(Accepted, AcceptedResult),
    assess_law_claim_authority(Rejected, RejectedResult),
    assess_law_claim_authority(Unknown, UnknownResult),
    assess_law_claim_authority(wrong_shape, PreClosure),
    assertion(AcceptedResult == AcceptedExpected),
    assertion(RejectedResult == RejectedExpected),
    assertion(UnknownResult == UnknownExpected),
    assertion(PreClosure == authority_assessment(
        rejected(malformed_shape),
        audit(no_claim, no_policy, used([]), provenance([])))).

test(equality_reference_mismatch_is_rejected) :-
    boundary_snapshots(equality_mismatch, Snapshot),
    assess_law_claim_authority(Snapshot, Result),
    assertion(Result == authority_assessment(
        rejected(equality_mismatch(
            equality_id(represented_equal),
            equality_id(other_equality))),
        audit(no_claim, no_policy, used([]), provenance([])))).

test(cross_policy_trust_is_reference_mismatch) :-
    premise_variants(cross_policy, Snapshot, Expected),
    assess_law_claim_authority(Snapshot, Result),
    assertion(Result == Expected).

test(inactive_premise_is_rejected) :-
    premise_variants(inactive, Snapshot, Expected),
    assess_law_claim_authority(Snapshot, Result),
    assertion(Result == Expected).

test(untrusted_premise_is_rejected) :-
    premise_variants(untrusted, Snapshot, Expected),
    assess_law_claim_authority(Snapshot, Result),
    assertion(Result == Expected).

test(rejected_obligation_is_rejected) :-
    obligation_variants(rejected, Snapshot, Expected),
    assess_law_claim_authority(Snapshot, Result),
    assertion(Result == Expected).

test(missing_obligation_is_unknown) :-
    obligation_variants(missing_disposition, Snapshot, Expected),
    assess_law_claim_authority(Snapshot, Result),
    assertion(Result == Expected).

test(invalid_and_missing_provenance_are_rejected) :-
    provenance_variants(invalid, Invalid, ExpectedInvalid),
    provenance_variants(missing, Missing, ExpectedMissing),
    assess_law_claim_authority(Invalid, InvalidResult),
    assess_law_claim_authority(Missing, MissingResult),
    assertion(InvalidResult == ExpectedInvalid),
    assertion(MissingResult == ExpectedMissing).

test(unresolved_contradiction_is_unknown) :-
    contradiction_variants(unresolved, Snapshot, Expected),
    assess_law_claim_authority(Snapshot, Result),
    assertion(Result == Expected).

test(retracted_claim_is_rejected) :-
    contradiction_variants(retracted, Snapshot, Expected),
    assess_law_claim_authority(Snapshot, Result),
    assertion(Result == Expected).

test(used_identifiers_and_provenance_are_retained) :-
    accepted_eop_law(Snapshot, Expected),
    assess_law_claim_authority(Snapshot, Result),
    assertion(Result == Expected),
    Result = authority_assessment(
        accepted,
        audit(claim_id(partial_associativity),
              policy_id(source_policy),
              used([claim_id(partial_associativity),
                    policy_id(source_policy),
                    signature_id(binary_op),
                    definition_space_id(adjacent_defined),
                    law_id(partial_assoc),
                    equality_id(represented_equal),
                    termination_id(structural_descent),
                    cost_id(operation_count),
                    effects_id(read_write_alias),
                    premise_id(adjacent_applications),
                    obligation_id(both_parenthesizations_defined),
                    contradiction_id(no_counterexample)]),
              provenance([provenance(
                  provenance_id(eop_concepts_p9), _)]))).

test(public_call_has_one_solution) :-
    accepted_eop_law(Snapshot, Expected),
    findall(Result, assess_law_claim_authority(Snapshot, Result), Results),
    findall(Malformed,
            assess_law_claim_authority(wrong_shape, Malformed),
            MalformedResults),
    assertion(Results == [Expected]),
    assertion(MalformedResults == [authority_assessment(
        rejected(malformed_shape),
        audit(no_claim, no_policy, used([]), provenance([])))]).

test(result_is_call_order_independent) :-
    accepted_eop_law(Snapshot, Expected),
    contradiction_variants(explicit, Rejected, ExpectedRejected),
    assess_law_claim_authority(Snapshot, First),
    assess_law_claim_authority(Rejected, Middle),
    assess_law_claim_authority(Snapshot, Last),
    assertion(First == Expected),
    assertion(Middle == ExpectedRejected),
    assertion(Last == First).

test(result_is_working_directory_independent) :-
    accepted_eop_law(Snapshot, Expected),
    assess_law_claim_authority(Snapshot, RootResult),
    working_directory(Original, Original),
    setup_call_cleanup(
        working_directory(_, '/tmp'),
        assess_law_claim_authority(Snapshot, OtherResult),
        working_directory(_, Original)),
    assertion(RootResult == Expected),
    assertion(OtherResult == RootResult).

test(result_is_asserted_state_independent) :-
    accepted_eop_law(Snapshot, Expected),
    assess_law_claim_authority(Snapshot, First),
    premise_variants(extra, Unrelated, _),
    assess_law_claim_authority(Unrelated, _),
    assess_law_claim_authority(Snapshot, Last),
    assertion(First == Expected),
    assertion(Last == First).

test(module_has_no_dynamic_or_meta_predicates) :-
    module_property(cps_law_claim_authority, exports(Exports)),
    assertion(Exports == [assess_law_claim_authority/2]),
    findall(Name/Arity,
            ( current_predicate(cps_law_claim_authority:Name/Arity),
              functor(Head, Name, Arity),
              \+ predicate_property(cps_law_claim_authority:Head,
                                    imported_from(_)),
              predicate_property(cps_law_claim_authority:Head, dynamic)
            ),
            Dynamic),
    findall(Name/Arity,
            ( current_predicate(cps_law_claim_authority:Name/Arity),
              functor(Head, Name, Arity),
              \+ predicate_property(cps_law_claim_authority:Head,
                                    imported_from(_)),
              predicate_property(cps_law_claim_authority:Head,
                                  meta_predicate(_))
            ),
            Meta),
    assertion(Dynamic == []),
    assertion(Meta == []).

test(shared_references_confer_no_authority) :-
    accepted_eop_law(
        authority_snapshot(Policy, Claim, Records0, Premises, Obligations,
                           Contradictions, Provenances),
        authority_assessment(accepted, Audit)),
    Records0 = semantic_records(
        signature(SId, Descriptor, _Accepted, Prov),
        D, L, E, T, C, F),
    Records = semantic_records(
        signature(SId, Descriptor, missing, Prov),
        D, L, E, T, C, F),
    Snapshot = authority_snapshot(
        Policy, Claim, Records, Premises, Obligations, Contradictions,
        Provenances),
    assess_law_claim_authority(Snapshot, Result),
    assertion(Result == authority_assessment(
        unknown([missing(signature, signature_id(binary_op))]),
        Audit)).

test(missing_signature_evidence_is_unknown) :-
    accepted_eop_law(
        authority_snapshot(Policy, Claim, Records0, Premises, Obligations,
                           Contradictions, Provenances),
        authority_assessment(accepted, Audit)),
    Records0 = semantic_records(
        signature(SId, Descriptor, _Accepted, Prov),
        D, L, E, T, C, F),
    Records = semantic_records(
        signature(SId, Descriptor, missing, Prov),
        D, L, E, T, C, F),
    Snapshot = authority_snapshot(
        Policy, Claim, Records, Premises, Obligations, Contradictions,
        Provenances),
    assess_law_claim_authority(Snapshot, Result),
    assertion(Result == authority_assessment(
        unknown([missing(signature, signature_id(binary_op))]),
        Audit)).

test(missing_definedness_evidence_is_unknown) :-
    accepted_eop_law(
        authority_snapshot(Policy, Claim, Records0, Premises, Obligations,
                           Contradictions, Provenances),
        authority_assessment(accepted, Audit)),
    Records0 = semantic_records(
        S,
        definition_space(DId, SId, Descriptor, _Accepted, Prov),
        L, E, T, C, F),
    Records = semantic_records(
        S,
        definition_space(DId, SId, Descriptor, missing, Prov),
        L, E, T, C, F),
    Snapshot = authority_snapshot(
        Policy, Claim, Records, Premises, Obligations, Contradictions,
        Provenances),
    assess_law_claim_authority(Snapshot, Result),
    assertion(Result == authority_assessment(
        unknown([missing(definedness,
                         definition_space_id(adjacent_defined))]),
        Audit)).

test(explicit_rejection_precedes_unknown) :-
    contradiction_variants(
        explicit,
        authority_snapshot(Policy, Claim, Records0, Premises, Obligations,
                           Contradictions, Provenances),
        authority_assessment(rejected(Reason), Audit)),
    Records0 = semantic_records(
        signature(SId, Descriptor, _Accepted, Prov),
        D, L, E, T, C, F),
    Records = semantic_records(
        signature(SId, Descriptor, missing, Prov),
        D, L, E, T, C, F),
    Snapshot = authority_snapshot(
        Policy, Claim, Records, Premises, Obligations, Contradictions,
        Provenances),
    assess_law_claim_authority(Snapshot, Result),
    assertion(Result == authority_assessment(rejected(Reason), Audit)).

test(resource_limit_does_not_mask_late_fixed_field) :-
    boundary_snapshots(
        oversized_early_late_variable,
        OversizedSnapshot),
    OversizedSnapshot = authority_snapshot(
        Policy, GroundClaim, GroundRecords, Premises,
        Obligations, Contradictions, Provenances),
    findall(
        ScalarPath-Maximum,
        closed_scalar_path(
            OversizedSnapshot, ScalarPath, Maximum),
        ScalarInventory),
    sort(ScalarInventory, UniqueScalarInventory),
    length(ScalarInventory, 68),
    length(UniqueScalarInventory, 68),
    assertion(memberchk([1, 2]-128, ScalarInventory)),
    assertion(memberchk([3, 1, 2, 1]-128, ScalarInventory)),
    findall(
        ConstructorPath,
        closed_constructor_path(
            OversizedSnapshot, ConstructorPath),
        ConstructorInventory),
    sort(ConstructorInventory, UniqueConstructorInventory),
    length(ConstructorInventory, 106),
    length(UniqueConstructorInventory, 106),
    oversized_atom(64, Atom65),
    oversized_atom(128, Atom129),
    assert_scalar_priority(
        ScalarInventory, OversizedSnapshot, Atom65, Atom129),
    assert_constructor_priority(
        ConstructorInventory, OversizedSnapshot),
    VariableSnapshot = authority_snapshot(
        Policy, _LateFixedVariable, GroundRecords, Premises, Obligations,
        Contradictions, Provenances),
    GroundClaim = claim(
        ClaimId, _Semantics, Uses, Requires, Conflicts, Lifecycle),
    MalformedClaim = claim(
        ClaimId, not_semantics, Uses, Requires, Conflicts, Lifecycle),
    MalformedSnapshot = authority_snapshot(
        Policy, MalformedClaim, GroundRecords, Premises, Obligations,
        Contradictions, Provenances),
    GroundRecords = semantic_records(
        _Signature, Definition, Law, Equality, Termination, Cost, Effects),
    VariableRecordSnapshot = authority_snapshot(
        Policy, GroundClaim,
        semantic_records(_LateRecord, Definition, Law, Equality,
                         Termination, Cost, Effects),
        Premises, Obligations, Contradictions, Provenances),
    MalformedRecordSnapshot = authority_snapshot(
        Policy, GroundClaim,
        semantic_records(not_signature, Definition, Law, Equality,
                         Termination, Cost, Effects),
        Premises, Obligations, Contradictions, Provenances),
    MalformedPremiseSnapshot = authority_snapshot(
        Policy, GroundClaim, GroundRecords, [not_premise], Obligations,
        Contradictions, Provenances),
    MalformedObligationSnapshot = authority_snapshot(
        Policy, GroundClaim, GroundRecords, Premises, [not_obligation],
        Contradictions, Provenances),
    MalformedContradictionSnapshot = authority_snapshot(
        Policy, GroundClaim, GroundRecords, Premises, Obligations,
        [not_contradiction], Provenances),
    MalformedProvenanceSnapshot = authority_snapshot(
        Policy, GroundClaim, GroundRecords, Premises, Obligations,
        Contradictions, [not_provenance]),
    Premises = [Premise],
    CyclicPremises = [Premise|CyclicPremises],
    CyclicSnapshot = authority_snapshot(
        Policy, GroundClaim, GroundRecords, CyclicPremises, Obligations,
        Contradictions, Provenances),
    assess_law_claim_authority(VariableSnapshot, VariableResult),
    assess_law_claim_authority(MalformedSnapshot, MalformedResult),
    assess_law_claim_authority(
        VariableRecordSnapshot, VariableRecordResult),
    assess_law_claim_authority(
        MalformedRecordSnapshot, MalformedRecordResult),
    assess_law_claim_authority(
        MalformedPremiseSnapshot, MalformedPremiseResult),
    assess_law_claim_authority(
        MalformedObligationSnapshot, MalformedObligationResult),
    assess_law_claim_authority(
        MalformedContradictionSnapshot, MalformedContradictionResult),
    assess_law_claim_authority(
        MalformedProvenanceSnapshot, MalformedProvenanceResult),
    assess_law_claim_authority(CyclicSnapshot, CyclicResult),
    PreAudit = audit(no_claim, no_policy, used([]), provenance([])),
    assertion(VariableResult == authority_assessment(
        rejected(non_ground_input),
        PreAudit)),
    assertion(MalformedResult == authority_assessment(
        rejected(malformed_shape),
        PreAudit)),
    assertion(VariableRecordResult == authority_assessment(
        rejected(non_ground_input),
        PreAudit)),
    assertion(MalformedRecordResult == authority_assessment(
        rejected(malformed_shape),
        PreAudit)),
    assertion(MalformedPremiseResult == authority_assessment(
        rejected(malformed_shape),
        PreAudit)),
    assertion(MalformedObligationResult == authority_assessment(
        rejected(malformed_shape),
        PreAudit)),
    assertion(MalformedContradictionResult == authority_assessment(
        rejected(malformed_shape),
        PreAudit)),
    assertion(MalformedProvenanceResult == authority_assessment(
        rejected(malformed_shape),
        PreAudit)),
    assertion(CyclicResult == authority_assessment(
        rejected(cyclic_input),
        PreAudit)).

test(t001_result_mapping_is_exact) :-
    accepted_eop_law(Accepted, ExpectedAccepted),
    provenance_variants(unknown, Unknown, ExpectedUnknown),
    provenance_variants(invalid, Rejected, ExpectedRejected),
    assess_law_claim_authority(Accepted, AcceptedResult),
    assess_law_claim_authority(Unknown, UnknownResult),
    assess_law_claim_authority(Rejected, RejectedResult),
    assertion(AcceptedResult == ExpectedAccepted),
    assertion(UnknownResult == ExpectedUnknown),
    assertion(RejectedResult == ExpectedRejected).

test(missing_activation_and_trust_are_unknown) :-
    premise_variants(missing_activation, Activation, ExpectedActivation),
    premise_variants(missing_trust, Trust, ExpectedTrust),
    assess_law_claim_authority(Activation, ActivationResult),
    assess_law_claim_authority(Trust, TrustResult),
    assertion(ActivationResult == ExpectedActivation),
    assertion(TrustResult == ExpectedTrust).

test(missing_equality_evidence_is_unknown) :-
    accepted_eop_law(
        authority_snapshot(Policy, Claim, Records0, Premises, Obligations,
                           Contradictions, Provenances),
        authority_assessment(accepted, Audit)),
    Records0 = semantic_records(
        S, D, L,
        equality_relation(EId, SId, DId, Relation, _Accepted, Prov),
        T, C, F),
    Records = semantic_records(
        S, D, L,
        equality_relation(EId, SId, DId, Relation, missing, Prov),
        T, C, F),
    Snapshot = authority_snapshot(
        Policy, Claim, Records, Premises, Obligations, Contradictions,
        Provenances),
    assess_law_claim_authority(Snapshot, Result),
    assertion(Result == authority_assessment(
        unknown([missing(equality, equality_id(represented_equal))]),
        Audit)).

test(multiple_missing_evidence_is_canonical) :-
    provenance_variants(
        unknown,
        authority_snapshot(Policy, Claim0, Records0, _Premises0,
                           _Obligations0, _Contradictions0, Provenances),
        authority_assessment(unknown(_), Audit)),
    Shared = provenance_id(eop_concepts_p9),
    Claim0 = claim(ClaimId, Semantics, Uses, Requires, Conflicts, _),
    Claim = claim(ClaimId, Semantics, Uses, Requires, Conflicts, missing),
    Records0 = semantic_records(
        signature(SId, SDescriptor, _SAccepted, SProv),
        D,
        L,
        equality_relation(EId, ESId, EDId, Relation, _EAccepted, EProv),
        T, C, F),
    Records = semantic_records(
        signature(SId, SDescriptor, missing, SProv),
        D,
        L,
        equality_relation(EId, ESId, EDId, Relation, missing, EProv),
        T, C, F),
    Premises = [
        premise(premise_id(adjacent_applications),
                missing, missing, Shared)
    ],
    Obligations = [
        obligation(obligation_id(both_parenthesizations_defined),
                   law_id(partial_assoc),
                   missing, missing, Shared)
    ],
    Contradictions = [
        contradiction(contradiction_id(no_counterexample),
                      claim_id(partial_associativity),
                      unresolved, Shared)
    ],
    Snapshot = authority_snapshot(
        Policy, Claim, Records, Premises, Obligations, Contradictions,
        Provenances),
    Missing = [
        missing(signature, signature_id(binary_op)),
        missing(equality, equality_id(represented_equal)),
        missing_t001(
            Shared,
            [unknown(laws, law_requires_proof)]),
        missing(lifecycle, claim_id(partial_associativity)),
        missing(premise_activation,
                premise_id(adjacent_applications)),
        missing(premise_trust(policy_id(source_policy)),
                premise_id(adjacent_applications)),
        missing(obligation_applicability,
                obligation_id(both_parenthesizations_defined)),
        missing(obligation_disposition,
                obligation_id(both_parenthesizations_defined)),
        missing(contradiction_resolution,
                contradiction_id(no_counterexample))
    ],
    assess_law_claim_authority(Snapshot, Result),
    assertion(Result == authority_assessment(unknown(Missing), Audit)),
    missing_boundary_snapshot(accepted, Boundary48),
    missing_boundary_expected(accepted, Expected48),
    length(Expected48, 48),
    assess_law_claim_authority(Boundary48, Boundary48Result),
    Boundary48Result = authority_assessment(
        unknown(Actual48),
        audit(claim_id(partial_associativity),
              policy_id(source_policy),
              used(BoundaryUsed),
              provenance(BoundaryProvenance))),
    length(BoundaryUsed, 33),
    assertion(Actual48 == Expected48),
    assertion(ground(BoundaryProvenance)),
    missing_boundary_snapshot(unknown, Boundary49),
    missing_boundary_expected(unknown, Expected49),
    length(Expected49, 49),
    assess_law_claim_authority(Boundary49, Boundary49Result),
    preclosure_result(resource_limit_exceeded, ExpectedBoundary49),
    assertion(Boundary49Result == ExpectedBoundary49).

:- end_tests(cps_law_claim_authority).
