:- begin_tests(cps_controlled_english_v0).

:- use_module('../../src/cnl/cps_controlled_english_v0').
:- use_module('../../src/ir/cps_ground_typed_equality_ir',
              [ validate_ground_typed_equality_pair/4
              ]).
:- use_module('../../src/cps_law_claim_authority',
              [ assess_law_claim_authority/2
              ]).
:- use_module(library(readutil)).

:- dynamic ambient_marker/1.

attr_unify_hook(preserved, _Other).

base_tokens(
    [ specification, spec_main,
      binds, spec_object,
      as, element,
      and, requires,
      equality, represented_equal,
      for, spec_object,
      equals, value,
      in, definition_space, adjacent_defined,
      using, premise, adjacent_applications
    ]).

two_value_tokens(First, Second,
    [ specification, spec_main,
      binds, spec_object,
      as, element,
      and, requires,
      equality, represented_equal,
      for, spec_object,
      equals, First, or, Second,
      in, definition_space, adjacent_defined,
      using, premise, adjacent_applications
    ]).

three_value_tokens(First, Second, Third,
    [ specification, spec_main,
      binds, spec_object,
      as, element,
      and, requires,
      equality, represented_equal,
      for, spec_object,
      equals, First, or, Second, or, Third,
      in, definition_space, adjacent_defined,
      using, premise, adjacent_applications
    ]).

four_value_tokens(First, Second, Third, Fourth,
    [ specification, spec_main,
      binds, spec_object,
      as, element,
      and, requires,
      equality, represented_equal,
      for, spec_object,
      equals, First, or, Second, or, Third, or, Fourth,
      in, definition_space, adjacent_defined,
      using, premise, adjacent_applications
    ]).

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

proposal(SpecificationId, BinderId, TypeId, EqualityId, ReferenceId, Value,
         DefinitionSpaceId, PremiseId,
         specification_proposal(
             specification_id(SpecificationId),
             type_declarations([nominal_type(type_id(TypeId))]),
             binding(
                 object_binder(binder_id(BinderId), type_id(TypeId)),
                 equality(
                     equality_id(EqualityId),
                     operands([
                         object_reference(
                             binder_id(ReferenceId), type_id(TypeId)),
                         object_value(
                             atom_value(Value), type_id(TypeId))
                     ]))),
             definedness(definition_space_id(DefinitionSpaceId)),
             premises([premise_id(PremiseId)]))).

base_proposal(Proposal) :-
    proposal(spec_main, spec_object, element, represented_equal, spec_object,
             value, adjacent_defined, adjacent_applications, Proposal).

proposal_for_tokens(Tokens, Proposal) :-
    nth1(2, Tokens, SpecificationId),
    nth1(4, Tokens, BinderId),
    nth1(6, Tokens, TypeId),
    nth1(10, Tokens, EqualityId),
    nth1(12, Tokens, ReferenceId),
    nth1(14, Tokens, Value),
    (   nth1(15, Tokens, or)
    ->  nth1(19, Tokens, DefinitionSpaceId),
        nth1(22, Tokens, PremiseId)
    ;   nth1(17, Tokens, DefinitionSpaceId),
        nth1(20, Tokens, PremiseId)
    ),
    proposal(SpecificationId, BinderId, TypeId, EqualityId, ReferenceId,
             Value, DefinitionSpaceId, PremiseId, Proposal).

two_value_proposals(Tokens, Proposals) :-
    nth1(2, Tokens, SpecificationId),
    nth1(4, Tokens, BinderId),
    nth1(6, Tokens, TypeId),
    nth1(10, Tokens, EqualityId),
    nth1(12, Tokens, ReferenceId),
    nth1(14, Tokens, FirstValue),
    nth1(16, Tokens, SecondValue),
    nth1(19, Tokens, DefinitionSpaceId),
    nth1(22, Tokens, PremiseId),
    proposal(
        SpecificationId, BinderId, TypeId, EqualityId, ReferenceId,
        FirstValue, DefinitionSpaceId, PremiseId, FirstProposal),
    proposal(
        SpecificationId, BinderId, TypeId, EqualityId, ReferenceId,
        SecondValue, DefinitionSpaceId, PremiseId, SecondProposal),
    sort([FirstProposal, SecondProposal], Proposals).

proposal_candidate(Program, Authority, Proposal,
                   candidate(Proposal, Validation)) :-
    validate_ground_typed_equality_pair(
        Proposal, Program, Authority, Validation).

expected_two_value_result(Tokens, Program, Authority, Expected) :-
    two_value_proposals(Tokens, Proposals),
    maplist(
        proposal_candidate(Program, Authority),
        Proposals, Candidates0),
    sort(Candidates0, Candidates),
    cps_controlled_english_v0:classify_candidate_validations(
        Candidates, Status),
    Expected =
        controlled_english_validation(
            Status,
            controlled_english_audit(
                checked(tokens(22), cells(45), depth(23)),
                complete(Proposals),
                Candidates)).

numeric_boundary_atom(_Maximum, minimum, Atom) :-
    atom_of_length(1, Atom).
numeric_boundary_atom(Maximum, maximum, Atom) :-
    atom_of_length(Maximum, Atom).
numeric_boundary_atom(Maximum, maximum_plus_one, Atom) :-
    Length is Maximum + 1,
    atom_of_length(Length, Atom).
numeric_boundary_atom(Maximum, farther, Atom) :-
    Length is Maximum + 52,
    atom_of_length(Length, Atom).

accepted_numeric_boundary(minimum).
accepted_numeric_boundary(maximum).

scalar_boundary_resource(value, 128, value_scalar(value, 128)).
scalar_boundary_resource(
    Slot, 64, identifier_scalar(Slot, 64)) :-
    Slot \== value.

canonical_program(
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
        premises([premise_id(adjacent_applications)]))).

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
    Shared = provenance_id(eop_concepts_p9),
    canonical_evidence(Evidence),
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

canonical_context(Program, Authority) :-
    canonical_program(Program),
    canonical_authority(Authority).

semantic_record_missing(
    signature,
    semantic_records(
        signature(Id, Descriptor, _Disposition, Provenance),
        Definition, Law, Equality, Termination, Cost, Effects),
    semantic_records(
        signature(Id, Descriptor, missing, Provenance),
        Definition, Law, Equality, Termination, Cost, Effects)).
semantic_record_missing(
    definedness,
    semantic_records(
        Signature,
        definition_space(Id, SignatureId, Descriptor, _Disposition,
                         Provenance),
        Law, Equality, Termination, Cost, Effects),
    semantic_records(
        Signature,
        definition_space(Id, SignatureId, Descriptor, missing, Provenance),
        Law, Equality, Termination, Cost, Effects)).
semantic_record_missing(
    law,
    semantic_records(
        Signature, Definition,
        law(Id, SignatureId, DefinitionId, EqualityId, Descriptor,
            _Disposition, Provenance),
        Equality, Termination, Cost, Effects),
    semantic_records(
        Signature, Definition,
        law(Id, SignatureId, DefinitionId, EqualityId, Descriptor,
            missing, Provenance),
        Equality, Termination, Cost, Effects)).
semantic_record_missing(
    equality,
    semantic_records(
        Signature, Definition, Law,
        equality_relation(Id, SignatureId, DefinitionId, Relation,
                          _Disposition, Provenance),
        Termination, Cost, Effects),
    semantic_records(
        Signature, Definition, Law,
        equality_relation(Id, SignatureId, DefinitionId, Relation,
                          missing, Provenance),
        Termination, Cost, Effects)).
semantic_record_missing(
    termination,
    semantic_records(
        Signature, Definition, Law, Equality,
        termination(Id, LawId, Measure, _Disposition, Provenance),
        Cost, Effects),
    semantic_records(
        Signature, Definition, Law, Equality,
        termination(Id, LawId, Measure, missing, Provenance),
        Cost, Effects)).
semantic_record_missing(
    cost,
    semantic_records(
        Signature, Definition, Law, Equality, Termination,
        cost(Id, LawId, Operation, _Disposition, Provenance),
        Effects),
    semantic_records(
        Signature, Definition, Law, Equality, Termination,
        cost(Id, LawId, Operation, missing, Provenance),
        Effects)).
semantic_record_missing(
    effects,
    semantic_records(
        Signature, Definition, Law, Equality, Termination, Cost,
        effects(Id, LawId, Conditions, _Disposition, Provenance)),
    semantic_records(
        Signature, Definition, Law, Equality, Termination, Cost,
        effects(Id, LawId, Conditions, missing, Provenance))).

authority_semantic_missing(Type, Authority) :-
    canonical_authority(
        authority_snapshot(
            Policy, Claim, Records0, Premises, Obligations,
            Contradictions, Provenances)),
    semantic_record_missing(Type, Records0, Records),
    Authority =
        authority_snapshot(
            Policy, Claim, Records, Premises, Obligations,
            Contradictions, Provenances).

evidence_with_unknown_law(
    evidence(
        at(Source, Pages, Raw),
        claim(
            Label, Topic,
            facets(
                Signature, Associativity, Definedness, _Law,
                Termination, Cost, Effects, Aliasing, PageIdentity,
                NegativeCases))),
    evidence(
        at(Source, Pages, Raw),
        claim(
            Label, Topic,
            facets(
                Signature, Associativity, Definedness,
                unknown(law_requires_proof),
                Termination, Cost, Effects, Aliasing, PageIdentity,
                NegativeCases)))).

authority_t001_missing(Authority) :-
    canonical_authority(
        authority_snapshot(
            Policy, Claim, Records, Premises, Obligations,
            Contradictions, [provenance(Id, Evidence0)])),
    evidence_with_unknown_law(Evidence0, Evidence),
    Authority =
        authority_snapshot(
            Policy, Claim, Records, Premises, Obligations,
            Contradictions, [provenance(Id, Evidence)]).

authority_lifecycle_missing(Authority) :-
    canonical_authority(
        authority_snapshot(
            Policy,
            claim(Id, Semantics, Uses, Requires, Conflicts, _Lifecycle),
            Records, Premises, Obligations, Contradictions, Provenances)),
    Authority =
        authority_snapshot(
            Policy,
            claim(Id, Semantics, Uses, Requires, Conflicts, missing),
            Records, Premises, Obligations, Contradictions, Provenances).

authority_premise_trust_missing(Authority) :-
    canonical_authority(
        authority_snapshot(
            Policy, Claim, Records,
            [premise(Id, Activation, _Trust, Provenance)],
            Obligations, Contradictions, Provenances)),
    Authority =
        authority_snapshot(
            Policy, Claim, Records,
            [premise(Id, Activation, missing, Provenance)],
            Obligations, Contradictions, Provenances).

authority_obligation_variant(ApplicabilityValue, DispositionValue,
                             Authority) :-
    canonical_authority(
        authority_snapshot(
            Policy, Claim, Records, Premises,
            [obligation(Id, LawId, _Applicability, _Disposition,
                        Provenance)],
            Contradictions, Provenances)),
    call(ApplicabilityValue, Provenance, Applicability),
    call(DispositionValue, Provenance, Disposition),
    Authority =
        authority_snapshot(
            Policy, Claim, Records, Premises,
            [obligation(Id, LawId, Applicability, Disposition,
                        Provenance)],
            Contradictions, Provenances).

same_value(Value, _Provenance, Value).
accepted_value(Provenance, accepted(Provenance)).
rejected_value(Provenance, rejected(Provenance)).

authority_contradiction_unresolved(Authority) :-
    canonical_authority(
        authority_snapshot(
            Policy, Claim, Records, Premises, Obligations,
            [contradiction(Id, ClaimId, _Resolution, Provenance)],
            Provenances)),
    Authority =
        authority_snapshot(
            Policy, Claim, Records, Premises, Obligations,
            [contradiction(Id, ClaimId, unresolved, Provenance)],
            Provenances).

authority_unknown_case(
    signature,
    missing(signature, signature_id(binary_op)),
    Authority) :-
    authority_semantic_missing(signature, Authority).
authority_unknown_case(
    definedness,
    missing(definedness, definition_space_id(adjacent_defined)),
    Authority) :-
    authority_semantic_missing(definedness, Authority).
authority_unknown_case(
    law,
    missing(law, law_id(partial_assoc)),
    Authority) :-
    authority_semantic_missing(law, Authority).
authority_unknown_case(
    equality,
    missing(equality, equality_id(represented_equal)),
    Authority) :-
    authority_semantic_missing(equality, Authority).
authority_unknown_case(
    termination,
    missing(termination, termination_id(structural_descent)),
    Authority) :-
    authority_semantic_missing(termination, Authority).
authority_unknown_case(
    cost,
    missing(cost, cost_id(operation_count)),
    Authority) :-
    authority_semantic_missing(cost, Authority).
authority_unknown_case(
    effects,
    missing(effects, effects_id(read_write_alias)),
    Authority) :-
    authority_semantic_missing(effects, Authority).
authority_unknown_case(
    t001,
    missing_t001(
        provenance_id(eop_concepts_p9),
        [unknown(laws, law_requires_proof)]),
    Authority) :-
    authority_t001_missing(Authority).
authority_unknown_case(
    lifecycle,
    missing(lifecycle, claim_id(partial_associativity)),
    Authority) :-
    authority_lifecycle_missing(Authority).
authority_unknown_case(
    premise_activation,
    missing(
        premise_activation, premise_id(adjacent_applications)),
    Authority) :-
    authority_variant(missing_activation, Authority).
authority_unknown_case(
    premise_trust,
    missing(
        premise_trust(policy_id(source_policy)),
        premise_id(adjacent_applications)),
    Authority) :-
    authority_premise_trust_missing(Authority).
authority_unknown_case(
    obligation_applicability,
    missing(
        obligation_applicability,
        obligation_id(both_parenthesizations_defined)),
    Authority) :-
    authority_obligation_variant(
        same_value(missing), accepted_value, Authority).
authority_unknown_case(
    obligation_disposition,
    missing(
        obligation_disposition,
        obligation_id(both_parenthesizations_defined)),
    Authority) :-
    authority_obligation_variant(
        same_value(applicable(provenance_id(eop_concepts_p9))),
        same_value(missing), Authority).
authority_unknown_case(
    contradiction_resolution,
    missing(
        contradiction_resolution,
        contradiction_id(no_counterexample)),
    Authority) :-
    authority_contradiction_unresolved(Authority).

authority_unknown_row(
    obligation_applicability,
    [ missing(
          obligation_applicability,
          obligation_id(both_parenthesizations_defined)),
      missing(
          obligation_disposition,
          obligation_id(both_parenthesizations_defined))
    ],
    Authority) :-
    authority_obligation_variant(
        same_value(missing), same_value(missing), Authority).
authority_unknown_row(Class, [Missing], Authority) :-
    authority_unknown_case(Class, Missing, Authority),
    Class \== obligation_applicability.

authority_rejected_obligation(Authority) :-
    authority_obligation_variant(
        same_value(applicable(provenance_id(eop_concepts_p9))),
        rejected_value, Authority).

authority_duplicate_provenance(Authority) :-
    canonical_authority(
        authority_snapshot(
            Policy, Claim, Records, Premises, Obligations,
            Contradictions, [Provenance])),
    Authority =
        authority_snapshot(
            Policy, Claim, Records, Premises, Obligations,
            Contradictions, [Provenance, Provenance]).

boundary_id(Prefix, Number, Id) :-
    format(atom(Atom), '~w~d', [Prefix, Number]),
    (   Prefix == p
    ->  Id = premise_id(Atom)
    ;   Prefix == o
    ->  Id = obligation_id(Atom)
    ;   Id = contradiction_id(Atom)
    ).

boundary_obligation(
        LawId, SupplementalProvenances, CanonicalProvenance,
        Number, Obligation) :-
    boundary_id(o, Number, Id),
    boundary_record_provenance(
        Number, SupplementalProvenances, CanonicalProvenance,
        RecordProvenance),
    Obligation =
        obligation(Id, LawId, missing, missing, RecordProvenance).

boundary_contradiction(ClaimId, Provenance, Number, Contradiction) :-
    boundary_id(c, Number, Id),
    Contradiction = contradiction(Id, ClaimId, unresolved, Provenance).

boundary_record_provenance(
        Number, SupplementalProvenances, _CanonicalProvenance,
        Provenance) :-
    nth1(Number, SupplementalProvenances, Provenance),
    !.
boundary_record_provenance(
        _Number, _SupplementalProvenances, CanonicalProvenance,
        CanonicalProvenance).

boundary_unknown_provenance(
        Evidence0, Number, ProvenanceId,
        provenance(ProvenanceId, Evidence)) :-
    format(atom(Atom), 'boundary_provenance_~d', [Number]),
    ProvenanceId = provenance_id(Atom),
    evidence_with_unknown_law(Evidence0, Evidence).

boundary_t001_missing(ProvenanceId,
                      missing_t001(
                          ProvenanceId,
                          [unknown(laws, law_requires_proof)])).

boundary_semantic_missing([
    missing(signature, signature_id(binary_op)),
    missing(definedness, definition_space_id(adjacent_defined)),
    missing(law, law_id(partial_assoc)),
    missing(equality, equality_id(represented_equal)),
    missing(termination, termination_id(structural_descent)),
    missing(cost, cost_id(operation_count)),
    missing(effects, effects_id(read_write_alias))
]).

authority_missing_boundary(ProvenanceKind, Authority, Missing) :-
    canonical_authority(
        authority_snapshot(
            policy(PolicyId, PolicyKind, _PolicyProvenance),
            claim(
                ClaimId,
                semantics(
                    SignatureSemantics, DefinitionSemantics,
                    LawSemantics, TerminationSemantics,
                    CostSemantics, EffectsSemantics,
                    provenance(_ClaimProvenance)),
                _Uses, _Requires, _Conflicts, _Lifecycle),
            semantic_records(
                signature(SignatureId, SignatureDescriptor, _,
                          _SignatureProvenance),
                definition_space(
                    DefinitionId, DefinitionSignatureId,
                    DefinitionDescriptor, _, _DefinitionProvenance),
                law(LawId, LawSignatureId, LawDefinitionId, LawEqualityId,
                    LawDescriptor, _, _LawProvenance),
                equality_relation(
                    EqualityId, EqualitySignatureId, EqualityDefinitionId,
                    EqualityRelation, _, _EqualityProvenance),
                termination(
                    TerminationId, TerminationLawId, TerminationMeasure, _,
                    _TerminationProvenance),
                cost(CostId, CostLawId, CostOperation, _, _CostProvenance),
                effects(
                    EffectsId, EffectsLawId, EffectsConditions, _,
                    _EffectsProvenance)),
            [premise(PremiseId, _Activation, _Trust, _PremiseProvenance)],
            _Obligations, _Contradictions,
            [provenance(ProvenanceId, Evidence0)])),
    numlist(1, 15, ProvenanceNumbers),
    maplist(
        boundary_unknown_provenance(Evidence0),
        ProvenanceNumbers, SupplementalProvenanceIds,
        SupplementalProvenanceRecords),
    SupplementalProvenanceIds =
        [ ClaimProvenance,
          LifecycleProvenance,
          PolicyProvenance,
          SignatureProvenance,
          DefinitionProvenance,
          LawProvenance,
          EqualityProvenance,
          TerminationProvenance,
          CostProvenance,
          EffectsProvenance,
          PremiseProvenance,
          ObligationProvenance1,
          ObligationProvenance2,
          ObligationProvenance3,
          ObligationProvenance4
        ],
    Policy = policy(PolicyId, PolicyKind, PolicyProvenance),
    Semantics =
        semantics(
            SignatureSemantics, DefinitionSemantics,
            LawSemantics, TerminationSemantics,
            CostSemantics, EffectsSemantics,
            provenance(ClaimProvenance)),
    numlist(1, 8, Numbers),
    maplist(boundary_id(o), Numbers, ObligationIds),
    maplist(boundary_id(c), Numbers, ContradictionIds),
    Claim =
        claim(
            ClaimId, Semantics, uses([PremiseId]),
            requires(ObligationIds), conflicts(ContradictionIds),
            current(LifecycleProvenance)),
    Records =
        semantic_records(
            signature(SignatureId, SignatureDescriptor, missing,
                      SignatureProvenance),
            definition_space(
                DefinitionId, DefinitionSignatureId, DefinitionDescriptor,
                missing, DefinitionProvenance),
            law(
                LawId, LawSignatureId, LawDefinitionId, LawEqualityId,
                LawDescriptor, missing, LawProvenance),
            equality_relation(
                EqualityId, EqualitySignatureId, EqualityDefinitionId,
                EqualityRelation, missing, EqualityProvenance),
            termination(
                TerminationId, TerminationLawId, TerminationMeasure,
                missing, TerminationProvenance),
            cost(
                CostId, CostLawId, CostOperation, missing, CostProvenance),
            effects(
                EffectsId, EffectsLawId, EffectsConditions, missing,
                EffectsProvenance)),
    Premises = [
        premise(PremiseId, missing, missing, PremiseProvenance)
    ],
    SupplementalObligationProvenances = [
        ObligationProvenance1,
        ObligationProvenance2,
        ObligationProvenance3,
        ObligationProvenance4
    ],
    maplist(
        boundary_obligation(
            LawId, SupplementalObligationProvenances, ProvenanceId),
        Numbers, Obligations),
    maplist(
        boundary_contradiction(ClaimId, ProvenanceId),
        Numbers, Contradictions),
    (   ProvenanceKind == accepted
    ->  Evidence = Evidence0,
        CanonicalProvenanceMissing = []
    ;   evidence_with_unknown_law(Evidence0, Evidence),
        CanonicalProvenanceMissing = [
            missing_t001(
                provenance_id(eop_concepts_p9),
                [unknown(laws, law_requires_proof)])
        ]
    ),
    append(
        SupplementalProvenanceRecords,
        [provenance(ProvenanceId, Evidence)],
        Provenances),
    maplist(
        boundary_t001_missing,
        SupplementalProvenanceIds, SupplementalProvenanceMissing),
    append(
        SupplementalProvenanceMissing,
        CanonicalProvenanceMissing, ProvenanceMissing),
    Authority =
        authority_snapshot(
            Policy, Claim, Records, Premises, Obligations,
            Contradictions, Provenances),
    boundary_semantic_missing(SemanticMissing),
    append(SemanticMissing, ProvenanceMissing, First),
    Second = First,
    PremiseMissing = [
        missing(premise_activation, PremiseId),
        missing(premise_trust(policy_id(source_policy)), PremiseId)
    ],
    findall(
        ObligationItem,
        ( member(Number, Numbers),
          boundary_id(o, Number, ObligationId),
          member(
              ObligationItem,
              [ missing(obligation_applicability, ObligationId),
                missing(obligation_disposition, ObligationId)
              ])
        ),
        ObligationMissing),
    findall(
        ContradictionMissing,
        ( member(Number, Numbers),
          boundary_id(c, Number, ContradictionId),
          ContradictionMissing =
              missing(contradiction_resolution, ContradictionId)
        ),
        ContradictionMissing),
    append(Second, PremiseMissing, Third),
    append(Third, ObligationMissing, Fourth),
    append(Fourth, ContradictionMissing, Missing).

expected_single_status(
        ground_typed_equality_validation(
            accepted(validated_pair(ValidatedSpecification, _Program)),
            _Audit),
        accepted(ValidatedSpecification)) :-
    !.
expected_single_status(
        ground_typed_equality_validation(
            rejected(resource_limit_exceeded(Input, Limit)),
            _Audit),
        resource_exhausted(
            candidate_predecessors([
                predecessor(t003, Input, Limit)
            ]))) :-
    !.
expected_single_status(
        ground_typed_equality_validation(unknown(Missing), _Audit),
        unknown(
            candidate_predecessors([
                predecessor(t003, Missing)
            ]))) :-
    !.
expected_single_status(
        ground_typed_equality_validation(rejected(Reason), _Audit),
        rejected(predecessor(t003, Reason))) :-
    !.
expected_single_status(
        _Other,
        unknown(internal_invariant(predecessor_result_shape))).

expected_base_result(Tokens, Program, Authority, Expected) :-
    proposal_for_tokens(Tokens, Proposal),
    validate_ground_typed_equality_pair(
        Proposal, Program, Authority, T003Validation),
    expected_single_status(T003Validation, Status),
    length(Tokens, Count),
    Cells is Count * 2 + 1,
    Depth is Count + 1,
    Expected =
        controlled_english_validation(
            Status,
            controlled_english_audit(
                checked(tokens(Count), cells(Cells), depth(Depth)),
                complete([Proposal]),
                [candidate(Proposal, T003Validation)])).

validation(Tokens, Program, Authority, Validation) :-
    cps_controlled_english_v0:validate_controlled_english_v0(
        Tokens, Program, Authority, Validation).

one_validation(Tokens, Program, Authority, Validation) :-
    findall(
        Result,
        validation(Tokens, Program, Authority, Result),
        Results),
    Results = [Validation],
    call_cleanup(
        validation(Tokens, Program, Authority, DeterministicValidation),
        Deterministic = true),
    Deterministic == true,
    DeterministicValidation == Validation.

empty_audit(Preflight, Parse, Status,
            controlled_english_validation(
                Status,
                controlled_english_audit(Preflight, Parse, []))).

assert_inputs_identical(BeforeTokens, BeforeProgram, BeforeAuthority,
                        Tokens, Program, Authority) :-
    assertion(Tokens == BeforeTokens),
    assertion(Program == BeforeProgram),
    assertion(Authority == BeforeAuthority).

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
            [premise(
                 Id, Activation,
                 untrusted(policy_id(source_policy), Provenance),
                 Provenance)],
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
            [contradiction(
                 Id, ClaimId, explicit(Provenance), Provenance)],
            Provenances).
authority_variant(resource, Authority) :-
    canonical_authority(Original),
    atom_of_length(65, LongId),
    Original =
        authority_snapshot(
            policy(policy_id(_), Kind, Provenance),
            Claim, Records, Premises, Obligations,
            Contradictions, Provenances),
    Authority =
        authority_snapshot(
            policy(policy_id(LongId), Kind, Provenance),
            Claim, Records, Premises, Obligations,
            Contradictions, Provenances).

program_variant(wrong_root, malformed_program).
program_variant(type_mismatch,
    program_proposal(
        program_id(identity_program),
        signature(input(type_id(other)), output(type_id(other))),
        program_ast(
            object_binder(binder_id(program_object), type_id(other)),
            object_reference(binder_id(program_object), type_id(other))),
        definedness(definition_space_id(adjacent_defined)),
        premises([premise_id(adjacent_applications)]))).
program_variant(definition_mismatch,
    program_proposal(
        program_id(identity_program),
        signature(input(type_id(element)), output(type_id(element))),
        program_ast(
            object_binder(binder_id(program_object), type_id(element)),
            object_reference(binder_id(program_object), type_id(element))),
        definedness(definition_space_id(other_space)),
        premises([premise_id(adjacent_applications)]))).
program_variant(premise_mismatch,
    program_proposal(
        program_id(identity_program),
        signature(input(type_id(element)), output(type_id(element))),
        program_ast(
            object_binder(binder_id(program_object), type_id(element)),
            object_reference(binder_id(program_object), type_id(element))),
        definedness(definition_space_id(adjacent_defined)),
        premises([premise_id(other_premise)]))).
program_variant(free_reference,
    program_proposal(
        program_id(identity_program),
        signature(input(type_id(element)), output(type_id(element))),
        program_ast(
            object_binder(binder_id(program_object), type_id(element)),
            object_reference(binder_id(free_object), type_id(element))),
        definedness(definition_space_id(adjacent_defined)),
        premises([premise_id(adjacent_applications)]))).

test(base_sentence_accepts_exact_fresh_t003_result) :-
    base_tokens(Tokens),
    canonical_context(Program, Authority),
    expected_base_result(Tokens, Program, Authority, Expected),
    one_validation(Tokens, Program, Authority, Actual),
    assertion(Actual == Expected),
    Actual =
        controlled_english_validation(
            accepted(ValidatedSpecification),
            Audit),
    ValidatedSpecification =
        validated_specification(
            specification_id(spec_main),
            nominal_type(type_id(element)),
            scoped_equality(
                object_binder(
                    binder_id(spec_object), type_id(element)),
                equality_relation(
                    equality_id(represented_equal),
                    object_reference(
                        binder_id(spec_object), type_id(element)),
                    object_value(
                        atom_value(value), type_id(element)))),
            definition_space_id(adjacent_defined),
            premise_id(adjacent_applications)),
    Audit =
        controlled_english_audit(
            checked(tokens(20), cells(41), depth(21)),
            complete([Proposal]),
            [candidate(
                 Proposal,
                 ground_typed_equality_validation(
                     accepted(validated_pair(_, _)),
                     ir_audit(
                         proposal(
                             pair(
                                 specification_id(spec_main),
                                 program_id(identity_program),
                                 premise_id(adjacent_applications))),
                         authority(
                             authority_assessment(accepted, _)))))]),
    base_proposal(Proposal).

test(two_equivalent_complete_readings_are_deduplicated_before_t003) :-
    two_value_tokens(value, value, Tokens),
    base_proposal(Proposal),
    canonical_context(Program, Authority),
    validate_ground_typed_equality_pair(
        Proposal, Program, Authority, T003Validation),
    T003Validation =
        ground_typed_equality_validation(
            accepted(validated_pair(ValidatedSpecification, _)), _),
    Expected =
        controlled_english_validation(
            accepted(ValidatedSpecification),
            controlled_english_audit(
                checked(tokens(22), cells(45), depth(23)),
                complete([Proposal]),
                [candidate(Proposal, T003Validation)])),
    one_validation(Tokens, Program, Authority, Actual),
    assertion(Actual == Expected).

test(two_distinct_complete_readings_are_not_first_parse_cut) :-
    two_value_tokens(alpha, beta, Tokens),
    proposal(spec_main, spec_object, element, represented_equal, spec_object,
             alpha, adjacent_defined, adjacent_applications, AlphaProposal),
    proposal(spec_main, spec_object, element, represented_equal, spec_object,
             beta, adjacent_defined, adjacent_applications, BetaProposal),
    canonical_context(Program, Authority),
    validate_ground_typed_equality_pair(
        AlphaProposal, Program, Authority, AlphaValidation),
    validate_ground_typed_equality_pair(
        BetaProposal, Program, Authority, BetaValidation),
    AlphaValidation =
        ground_typed_equality_validation(
            accepted(validated_pair(AlphaSpecification, _)), _),
    BetaValidation =
        ground_typed_equality_validation(
            accepted(validated_pair(BetaSpecification, _)), _),
    sort([AlphaProposal, BetaProposal], Proposals),
    sort(
        [ candidate(AlphaProposal, AlphaValidation),
          candidate(BetaProposal, BetaValidation)
        ],
        Candidates),
    sort([AlphaSpecification, BetaSpecification], Specifications),
    Expected =
        controlled_english_validation(
            ambiguous(distinct_validated_specifications(Specifications)),
            controlled_english_audit(
                checked(tokens(22), cells(45), depth(23)),
                complete(Proposals),
                Candidates)),
    one_validation(Tokens, Program, Authority, Actual),
    assertion(Actual == Expected).

test(all_payload_fields_are_projected_without_coercion) :-
    base_tokens(Base),
    canonical_context(Program, Authority),
    forall(
        member(
            Position-Value,
            [ 2-spec_other,
              4-binder_other,
              6-type_other,
              10-equality_other,
              12-reference_other,
              14-value_other,
              17-space_other,
              20-premise_other
            ]),
        ( replace_nth1(Position, Base, Value, Tokens),
          proposal_for_tokens(Tokens, Proposal),
          validate_ground_typed_equality_pair(
              Proposal, Program, Authority, Direct),
          expected_single_status(Direct, ExpectedStatus),
          Expected =
              controlled_english_validation(
                  ExpectedStatus,
                  controlled_english_audit(
                      checked(tokens(20), cells(41), depth(21)),
                      complete([Proposal]),
                      [candidate(Proposal, Direct)])),
          one_validation(Tokens, Program, Authority, Actual),
          assertion(Actual == Expected)
        )).

test(matching_repeated_reference_can_vary_and_mismatch_is_rejected) :-
    base_tokens(Base),
    replace_nth1(4, Base, other_object, BinderTokens),
    replace_nth1(12, BinderTokens, other_object, MatchingTokens),
    canonical_context(Program, Authority),
    expected_base_result(MatchingTokens, Program, Authority, MatchingExpected),
    one_validation(MatchingTokens, Program, Authority, MatchingActual),
    assertion(MatchingActual == MatchingExpected),
    replace_nth1(12, BinderTokens, free_object, MismatchingTokens),
    expected_base_result(
        MismatchingTokens, Program, Authority, MismatchExpected),
    one_validation(
        MismatchingTokens, Program, Authority, MismatchActual),
    assertion(MismatchActual == MismatchExpected),
    MismatchActual =
        controlled_english_validation(
            rejected(
                predecessor(
                    t003,
                    ill_scoped(
                        free_object_reference(
                            specification,
                            binder_id(other_object),
                            binder_id(free_object))))),
            _).

test(root_non_ground_is_rejected_without_binding) :-
    canonical_context(Program, Authority),
    Tokens = _,
    empty_audit(
        not_completed, not_run,
        rejected(non_ground_input(tokens)), Expected),
    validation(Tokens, Program, Authority, Actual),
    assertion(Actual == Expected),
    assertion(var(Tokens)).

test(attributed_root_is_rejected_and_attribute_is_preserved) :-
    canonical_context(Program, Authority),
    put_attr(Tokens, plunit_cps_controlled_english_v0, preserved),
    empty_audit(
        not_completed, not_run,
        rejected(non_ground_input(tokens)), Expected),
    validation(Tokens, Program, Authority, Actual),
    assertion(Actual == Expected),
    get_attr(Tokens, plunit_cps_controlled_english_v0, preserved),
    del_attr(Tokens, plunit_cps_controlled_english_v0).

test(cyclic_root_is_rejected_without_traversal_escape) :-
    canonical_context(Program, Authority),
    Tokens = [specification|Tokens],
    empty_audit(
        not_completed, not_run,
        rejected(cyclic_input(tokens)), Expected),
    one_validation(Tokens, Program, Authority, Actual),
    assertion(Actual == Expected),
    assertion(cyclic_term(Tokens)).

test(wrong_root_is_rejected_before_program_or_authority_inspection) :-
    Program = _,
    Authority = _,
    empty_audit(
        not_completed, not_run,
        rejected(malformed_shape(tokens, root)), Expected),
    validation(not_a_list, Program, Authority, Actual),
    assertion(Actual == Expected),
    assertion(var(Program)),
    assertion(var(Authority)).

test(every_accepted_looking_root_is_rejected_as_forged) :-
    canonical_context(Program, Authority),
    forall(
        member(
            Forged,
            [ controlled_english_validation(accepted(forged), forged),
              controlled_english_audit(checked, complete, forged),
              ground_typed_equality_validation(accepted(forged), forged),
              validated_pair(forged, forged),
              validated_specification(a, b, c, d, e)
            ]),
        ( empty_audit(
              not_completed, not_run,
              rejected(forged_accepted_input(tokens)), Expected),
          one_validation(Forged, Program, Authority, Actual),
          assertion(Actual == Expected)
        )).

test(non_atom_token_is_rejected_at_every_base_position) :-
    base_tokens(Base),
    canonical_context(Program, Authority),
    forall(
        between(1, 20, Position),
        ( replace_nth1(Position, Base, compound(token), Tokens),
          empty_audit(
              not_completed, not_run,
              rejected(malformed_shape(tokens, token(Position))), Expected),
          one_validation(Tokens, Program, Authority, Actual),
          assertion(Actual == Expected)
        )).

test(non_atom_token_is_rejected_at_every_maximum_position) :-
    three_value_tokens(alpha, beta, gamma, Maximum),
    canonical_context(Program, Authority),
    forall(
        between(1, 24, Position),
        ( replace_nth1(Position, Maximum, compound(token), Tokens),
          empty_audit(
              not_completed, not_run,
              rejected(malformed_shape(tokens, token(Position))), Expected),
          one_validation(Tokens, Program, Authority, Actual),
          assertion(Actual == Expected)
        )).

test(non_ground_head_is_rejected_at_every_maximum_position_without_binding) :-
    three_value_tokens(alpha, beta, gamma, Maximum),
    canonical_context(Program, Authority),
    forall(
        between(1, 24, Position),
        ( replace_nth1(Position, Maximum, Variable, Tokens),
          empty_audit(
              not_completed, not_run,
              rejected(non_ground_input(tokens)), Expected),
          validation(Tokens, Program, Authority, Actual),
          assertion(Actual == Expected),
          assertion(var(Variable))
        )).

test(cyclic_head_is_rejected_at_every_inspected_maximum_position) :-
    three_value_tokens(alpha, beta, gamma, Maximum),
    canonical_context(Program, Authority),
    forall(
        between(1, 23, Position),
        ( Cycle = cycle(Cycle),
          replace_nth1(Position, Maximum, Cycle, Tokens),
          empty_audit(
              not_completed, not_run,
              rejected(cyclic_input(tokens)), Expected),
          one_validation(Tokens, Program, Authority, Actual),
          assertion(Actual == Expected)
        )).

test(cyclic_head_beyond_the_inspection_boundary_is_malformed) :-
    three_value_tokens(alpha, beta, gamma, Maximum),
    canonical_context(Program, Authority),
    Cycle = cycle(Cycle),
    replace_nth1(24, Maximum, Cycle, Tokens),
    empty_audit(
        not_completed, not_run,
        rejected(malformed_shape(tokens, token(24))), Expected),
    one_validation(Tokens, Program, Authority, Actual),
    assertion(Actual == Expected).

test(number_string_and_nested_token_forms_fail_closed) :-
    base_tokens(Base),
    canonical_context(Program, Authority),
    forall(
        member(Position-Bad, [1-42, 7-"and", 20-[premise]]),
        ( replace_nth1(Position, Base, Bad, Tokens),
          empty_audit(
              not_completed, not_run,
              rejected(malformed_shape(tokens, token(Position))), Expected),
          one_validation(Tokens, Program, Authority, Actual),
          assertion(Actual == Expected)
        )).

test(open_and_improper_list_tails_have_closed_priority) :-
    canonical_context(Program, Authority),
    Open = [specification, spec_main|OpenTail],
    empty_audit(
        not_completed, not_run,
        rejected(non_ground_input(tokens)), OpenExpected),
    validation(Open, Program, Authority, OpenActual),
    assertion(OpenActual == OpenExpected),
    assertion(var(OpenTail)),
    Improper = [specification, spec_main|not_a_list],
    empty_audit(
        not_completed, not_run,
        rejected(malformed_shape(tokens, list)), ImproperExpected),
    one_validation(Improper, Program, Authority, ImproperActual),
    assertion(ImproperActual == ImproperExpected).

test(cycle_and_variable_inside_last_inspected_prefix_are_observed) :-
    canonical_context(Program, Authority),
    base_tokens(Base),
    replace_nth1(20, Base, Variable, VariableTokens),
    empty_audit(
        not_completed, not_run,
        rejected(non_ground_input(tokens)), VariableExpected),
    validation(VariableTokens, Program, Authority, VariableActual),
    assertion(VariableActual == VariableExpected),
    assertion(var(Variable)),
    Cycle = cyclic(Cycle),
    replace_nth1(20, Base, Cycle, CyclicTokens),
    empty_audit(
        not_completed, not_run,
        rejected(cyclic_input(tokens)), CyclicExpected),
    one_validation(CyclicTokens, Program, Authority, CyclicActual),
    assertion(CyclicActual == CyclicExpected).

test(first_uninspected_content_cannot_override_token_count_limit) :-
    length(Prefix, 24),
    maplist(=(a), Prefix),
    append(Prefix, [Uninspected], Tokens),
    canonical_context(Program, Authority),
    empty_audit(
        limit(tokens(count(24))), not_run,
        resource_exhausted(tokens(count(24))), Expected),
    validation(Tokens, Program, Authority, Actual),
    assertion(Actual == Expected),
    assertion(var(Uninspected)).

identifier_slot(2, specification_id).
identifier_slot(4, binder_id).
identifier_slot(6, type_id).
identifier_slot(10, equality_id).
identifier_slot(12, reference_id).
identifier_slot(17, definition_space_id).
identifier_slot(20, premise_id).

test(identifier_minimum_and_maximum_are_not_local_resource_failures) :-
    base_tokens(Base),
    canonical_context(Program, Authority),
    atom_of_length(64, Maximum),
    forall(
        ( identifier_slot(Position, _Slot),
          member(Value, [a, Maximum])
        ),
        ( replace_nth1(Position, Base, Value, Tokens),
          expected_base_result(Tokens, Program, Authority, Expected),
          one_validation(Tokens, Program, Authority, Actual),
          assertion(Actual == Expected),
          Actual =
              controlled_english_validation(
                  _,
                  controlled_english_audit(
                      checked(tokens(20), cells(41), depth(21)),
                      complete([_]),
                      [_]))
        )).

test(identifier_maximum_plus_one_and_farther_fail_at_exact_slot) :-
    base_tokens(Base),
    canonical_context(Program, Authority),
    atom_of_length(65, PlusOne),
    atom_of_length(96, Farther),
    forall(
        ( identifier_slot(Position, Slot),
          member(Value, [PlusOne, Farther])
        ),
        ( replace_nth1(Position, Base, Value, Tokens),
          Resource = identifier_scalar(Slot, 64),
          empty_audit(
              limit(Resource), not_run,
              resource_exhausted(Resource), Expected),
          one_validation(Tokens, Program, Authority, Actual),
          assertion(Actual == Expected)
        )).

test(value_minimum_and_maximum_are_accepted_by_local_boundary) :-
    base_tokens(Base),
    canonical_context(Program, Authority),
    atom_of_length(128, Maximum),
    forall(
        member(Value, [a, Maximum]),
        ( replace_nth1(14, Base, Value, Tokens),
          expected_base_result(Tokens, Program, Authority, Expected),
          one_validation(Tokens, Program, Authority, Actual),
          assertion(Actual == Expected)
        )).

test(value_maximum_plus_one_and_farther_are_exact_resources) :-
    base_tokens(Base),
    canonical_context(Program, Authority),
    atom_of_length(129, PlusOne),
    atom_of_length(180, Farther),
    Resource = value_scalar(value, 128),
    forall(
        member(Value, [PlusOne, Farther]),
        ( replace_nth1(14, Base, Value, Tokens),
          empty_audit(
              limit(Resource), not_run,
              resource_exhausted(Resource), Expected),
          one_validation(Tokens, Program, Authority, Actual),
          assertion(Actual == Expected)
        )).

test(every_scalar_slot_rejects_each_lexical_class) :-
    base_tokens(Base),
    canonical_context(Program, Authority),
    forall(
        ( ( identifier_slot(Position, Slot)
          ; Position = 14,
            Slot = value
          ),
          member(Invalid, ['', 'Upper', '1leading', 'bad-hyphen'])
        ),
        ( replace_nth1(Position, Base, Invalid, Tokens),
          empty_audit(
              checked(tokens(20), cells(41), depth(21)),
              no_complete_parse,
              rejected(malformed_scalar(Slot)),
              Expected),
          one_validation(Tokens, Program, Authority, Actual),
          assertion(Actual == Expected)
        )).

test(every_keyword_is_reserved_in_every_scalar_slot) :-
    base_tokens(Base),
    canonical_context(Program, Authority),
    Keywords = [
        specification, binds, as, and, requires, equality, for, equals,
        in, definition_space, using, premise, or
    ],
    forall(
        ( ( identifier_slot(Position, Slot)
          ; Position = 14,
            Slot = value
          ),
          member(Keyword, Keywords)
        ),
        ( replace_nth1(Position, Base, Keyword, Tokens),
          empty_audit(
              checked(tokens(20), cells(41), depth(21)),
              no_complete_parse,
              rejected(malformed_scalar(Slot)),
              Expected),
          one_validation(Tokens, Program, Authority, Actual),
          assertion(Actual == Expected)
        )).

test(two_value_form_validates_both_values_and_shifted_scalar_slots) :-
    two_value_tokens(alpha, beta, Base),
    canonical_context(Program, Authority),
    forall(
        member(
            Position-Slot,
            [ 14-value,
              16-value,
              19-definition_space_id,
              22-premise_id
            ]),
        ( replace_nth1(Position, Base, 'Bad', Tokens),
          empty_audit(
              checked(tokens(22), cells(45), depth(23)),
              no_complete_parse,
              rejected(malformed_scalar(Slot)),
              Expected),
          one_validation(Tokens, Program, Authority, Actual),
          assertion(Actual == Expected)
        )).

test(two_value_shifted_scalar_numeric_boundaries_are_exact) :-
    two_value_tokens(alpha, beta, Base),
    canonical_context(Program, Authority),
    forall(
        ( member(
              Position-Slot-Maximum,
              [ 14-value-128,
                16-value-128,
                19-definition_space_id-64,
                22-premise_id-64
              ]),
          member(
              Boundary,
              [minimum, maximum, maximum_plus_one, farther]),
          numeric_boundary_atom(Maximum, Boundary, Scalar)
        ),
        ( replace_nth1(Position, Base, Scalar, Tokens),
          one_validation(Tokens, Program, Authority, Actual),
          (   accepted_numeric_boundary(Boundary)
          ->  expected_two_value_result(
                  Tokens, Program, Authority, Expected)
          ;   scalar_boundary_resource(Slot, Maximum, Resource),
              empty_audit(
                  limit(Resource), not_run,
                  resource_exhausted(Resource), Expected)
          ),
          assertion(Actual == Expected)
        )).

test(sentinel_shifted_scalar_numeric_boundaries_are_exact) :-
    three_value_tokens(alpha, beta, gamma, Base),
    Program = _,
    Authority = _,
    forall(
        ( member(
              Position-Slot-Maximum,
              [ 14-value-128,
                16-value-128,
                18-value-128,
                21-definition_space_id-64,
                24-premise_id-64
              ]),
          member(
              Boundary,
              [minimum, maximum, maximum_plus_one, farther]),
          numeric_boundary_atom(Maximum, Boundary, Scalar)
        ),
        ( replace_nth1(Position, Base, Scalar, Tokens),
          one_validation(Tokens, Program, Authority, Actual),
          (   accepted_numeric_boundary(Boundary)
          ->  Expected =
                  controlled_english_validation(
                      resource_exhausted(parse_alternatives(2)),
                      controlled_english_audit(
                          checked(tokens(24), cells(49), depth(25)),
                          alternative_limit(
                              max(2), observed_at_least(3)),
                          []))
          ;   scalar_boundary_resource(Slot, Maximum, Resource),
              empty_audit(
                  limit(Resource), not_run,
                  resource_exhausted(Resource), Expected)
          ),
          assertion(Actual == Expected),
          assertion(var(Program)),
          assertion(var(Authority))
        )).

unsupported_token(call, executable_token).
unsupported_token(assert, executable_token).
unsupported_token(assertz, executable_token).
unsupported_token(retract, executable_token).
unsupported_token(clause, executable_token).
unsupported_token(consult, executable_token).
unsupported_token(use_module, executable_token).
unsupported_token(':-', executable_token).
unsupported_token('?-', executable_token).
unsupported_token(who, question).
unsupported_token(what, question).
unsupported_token(when, question).
unsupported_token(where, question).
unsupported_token(why, question).
unsupported_token(how, question).
unsupported_token(does, question).
unsupported_token(is, question).
unsupported_token('?', question).
unsupported_token(not, negation).
unsupported_token(no, negation).
unsupported_token(all, quantifier).
unsupported_token(every, quantifier).
unsupported_token(some, quantifier).
unsupported_token(each, quantifier).
unsupported_token(that, relative_clause).
unsupported_token(which, relative_clause).
unsupported_token('Specification', case_policy).
unsupported_token('Binds', case_policy).
unsupported_token('As', case_policy).
unsupported_token('And', case_policy).
unsupported_token('Requires', case_policy).
unsupported_token('Equality', case_policy).
unsupported_token('For', case_policy).
unsupported_token('Equals', case_policy).
unsupported_token('In', case_policy).
unsupported_token('Definition_space', case_policy).
unsupported_token('Using', case_policy).
unsupported_token('Premise', case_policy).
unsupported_token('Or', case_policy).
unsupported_token(spec, synonym).
unsupported_token(bind, synonym).
unsupported_token(type, synonym).
unsupported_token(equals_to, synonym).
unsupported_token(definition, synonym).
unsupported_token(uses, synonym).
unsupported_token('.', punctuation).
unsupported_token(',', punctuation).
unsupported_token(';', punctuation).
unsupported_token(':', punctuation).
unsupported_token('!', punctuation).
unsupported_token(if, reserved_feature(if)).
unsupported_token(then, reserved_feature(then)).
unsupported_token(else, reserved_feature(else)).
unsupported_token(lambda, reserved_feature(lambda)).
unsupported_token(apply, reserved_feature(apply)).
unsupported_token(rule, reserved_feature(rule)).
unsupported_token(proof, reserved_feature(proof)).
unsupported_token(synthesize, reserved_feature(synthesize)).
unsupported_token(render, reserved_feature(render)).

test(every_closed_unsupported_token_maps_exactly) :-
    base_tokens(Base),
    canonical_context(Program, Authority),
    forall(
        unsupported_token(Token, Feature),
        ( replace_nth1(1, Base, Token, Tokens),
          empty_audit(
              checked(tokens(20), cells(41), depth(21)),
              no_complete_parse,
              unsupported(Feature),
              Expected),
          one_validation(Tokens, Program, Authority, Actual),
          assertion(Actual == Expected)
        )).

test(repeated_fragment_markers_have_closed_feature_results) :-
    base_tokens(Base),
    canonical_context(Program, Authority),
    forall(
        member(
            Token-Feature,
            [ binds-multiple_binding,
              as-multiple_type,
              premise-multiple_premise,
              and-conjunction,
              also-conjunction
            ]),
        ( replace_nth1(1, Base, Token, Tokens),
          empty_audit(
              checked(tokens(20), cells(41), depth(21)),
              no_complete_parse,
              unsupported(Feature),
              Expected),
          one_validation(Tokens, Program, Authority, Actual),
          assertion(Actual == Expected)
        )).

test(leftmost_unsupported_token_wins_before_category_order) :-
    base_tokens(Base),
    canonical_context(Program, Authority),
    replace_nth1(1, Base, what, First),
    replace_nth1(3, First, call, Tokens),
    empty_audit(
        checked(tokens(20), cells(41), depth(21)),
        no_complete_parse,
        unsupported(question),
        Expected),
    one_validation(Tokens, Program, Authority, Actual),
    assertion(Actual == Expected).

test(malformed_scalar_has_priority_over_unsupported_token) :-
    base_tokens(Base),
    canonical_context(Program, Authority),
    replace_nth1(1, Base, call, First),
    replace_nth1(2, First, 'Bad', Tokens),
    empty_audit(
        checked(tokens(20), cells(41), depth(21)),
        no_complete_parse,
        rejected(malformed_scalar(specification_id)),
        Expected),
    one_validation(Tokens, Program, Authority, Actual),
    assertion(Actual == Expected).

test(incomplete_leading_trailing_and_unknown_syntax_fail_explicitly) :-
    base_tokens(Base),
    canonical_context(Program, Authority),
    Base = [_|Incomplete],
    append([leading], Base, Leading),
    append(Base, [trailing], Trailing),
    replace_nth1(1, Base, unknown_word, Unknown),
    forall(
        member(Tokens, [[], [specification], Incomplete, Leading, Trailing,
                        Unknown]),
        ( length(Tokens, Count),
          Cells is Count * 2 + 1,
          Depth is Count + 1,
          empty_audit(
              checked(tokens(Count), cells(Cells), depth(Depth)),
              no_complete_parse,
              rejected(malformed_syntax(no_complete_parse)),
              Expected),
          one_validation(Tokens, Program, Authority, Actual),
          assertion(Actual == Expected)
        )).

test(third_alternative_sentinel_stops_before_t003) :-
    three_value_tokens(alpha, beta, gamma, Tokens),
    Program = _,
    Authority = _,
    Expected =
        controlled_english_validation(
            resource_exhausted(parse_alternatives(2)),
            controlled_english_audit(
                checked(tokens(24), cells(49), depth(25)),
                alternative_limit(max(2), observed_at_least(3)),
                [])),
    validation(Tokens, Program, Authority, Actual),
    assertion(Actual == Expected),
    assertion(var(Program)),
    assertion(var(Authority)).

test(fourth_alternative_is_stopped_by_token_count_before_parsing) :-
    four_value_tokens(alpha, beta, gamma, delta, Tokens),
    canonical_context(Program, Authority),
    empty_audit(
        limit(tokens(count(24))), not_run,
        resource_exhausted(tokens(count(24))), Expected),
    one_validation(Tokens, Program, Authority, Actual),
    assertion(Actual == Expected).

test(preflight_resource_selector_covers_exact_maxima_and_ties) :-
    assertion(
        cps_controlled_english_v0:select_local_resource(
            24, 49, 25, none)),
    assertion(
        cps_controlled_english_v0:select_local_resource(
            25, 50, 26, tokens(count(24)))),
    assertion(
        cps_controlled_english_v0:select_local_resource(
            24, 50, 26, tokens(cells(49)))),
    assertion(
        cps_controlled_english_v0:select_local_resource(
            24, 49, 26, tokens(depth(25)))).

test(program_field_rejections_are_exact_fresh_t003_results) :-
    base_tokens(Tokens),
    canonical_authority(Authority),
    forall(
        member(
            Variant,
            [ wrong_root,
              type_mismatch,
              definition_mismatch,
              premise_mismatch,
              free_reference
            ]),
        ( program_variant(Variant, Program),
          expected_base_result(Tokens, Program, Authority, Expected),
          one_validation(Tokens, Program, Authority, Actual),
          assertion(Actual == Expected),
          Actual =
              controlled_english_validation(
                  rejected(predecessor(t003, _)),
                  controlled_english_audit(
                      checked(tokens(20), cells(41), depth(21)),
                      complete([_]),
                      [candidate(
                           _,
                           ground_typed_equality_validation(
                               rejected(_), _))]))
        )).

test(authority_activation_trust_contradiction_unknown_and_resource_propagate) :-
    base_tokens(Tokens),
    canonical_program(Program),
    forall(
        member(
            Variant,
            [ inactive,
              untrusted,
              explicit_contradiction,
              missing_activation,
              resource
            ]),
        ( authority_variant(Variant, Authority),
          expected_base_result(Tokens, Program, Authority, Expected),
          one_validation(Tokens, Program, Authority, Actual),
          assertion(Actual == Expected)
        )).

test(predecessor_resource_is_lifted_to_candidate_resource) :-
    base_tokens(Tokens),
    canonical_program(Program),
    authority_variant(resource, Authority),
    one_validation(Tokens, Program, Authority, Actual),
    Actual =
        controlled_english_validation(
            resource_exhausted(
                candidate_predecessors([
                    predecessor(t003, authority, t002)
                ])),
            controlled_english_audit(
                checked(tokens(20), cells(41), depth(21)),
                complete([_]),
                [candidate(
                     _,
                     ground_typed_equality_validation(
                         rejected(
                             resource_limit_exceeded(authority, t002)),
                         _))])).

test(predecessor_unknown_is_lifted_with_full_missing_evidence) :-
    base_tokens(Tokens),
    canonical_program(Program),
    authority_variant(missing_activation, Authority),
    one_validation(Tokens, Program, Authority, Actual),
    Actual =
        controlled_english_validation(
            unknown(
                candidate_predecessors([
                    predecessor(
                        t003,
                        missing_authority(
                            premise_id(adjacent_applications),
                            [missing(
                                 premise_activation,
                                 premise_id(adjacent_applications))]))
                ])),
            controlled_english_audit(
                checked(tokens(20), cells(41), depth(21)),
                complete([_]),
                [candidate(
                     _,
                     ground_typed_equality_validation(
                         unknown(missing_authority(_, _)),
                         _))])).

test(every_reachable_t002_unknown_class_is_preserved_exactly) :-
    base_tokens(Tokens),
    base_proposal(Proposal),
    canonical_program(Program),
    forall(
        authority_unknown_row(_Class, Missing, Authority),
        ( copy_term(Authority, BeforeAuthority),
          findall(
              Assessment,
              assess_law_claim_authority(Authority, Assessment),
              Assessments),
          Assessments = [T002],
          T002 =
              authority_assessment(
                  unknown(Missing),
                  audit(
                      claim_id(partial_associativity),
                      policy_id(source_policy),
                      used(_),
                      provenance(_))),
          ground(T002),
          assertion(Authority == BeforeAuthority),
          validate_ground_typed_equality_pair(
              Proposal, Program, Authority, T003),
          T003 =
              ground_typed_equality_validation(
                  unknown(
                      missing_authority(
                          premise_id(adjacent_applications), Missing)),
                  ir_audit(_ProposalAudit, authority(T002))),
          expected_base_result(
              Tokens, Program, Authority, ExpectedT005),
          one_validation(Tokens, Program, Authority, ActualT005),
          assertion(ActualT005 == ExpectedT005),
          ActualT005 =
              controlled_english_validation(
                  unknown(
                      candidate_predecessors([
                          predecessor(
                              t003,
                              missing_authority(
                                  premise_id(adjacent_applications),
                                  Missing))
                      ])),
                  controlled_english_audit(
                      checked(tokens(20), cells(41), depth(21)),
                      complete([Proposal]),
                      [candidate(Proposal, T003)]))
        )).

test(rejected_obligation_propagates_exactly_and_outranks_unknown) :-
    base_tokens(Tokens),
    base_proposal(Proposal),
    canonical_program(Program),
    authority_rejected_obligation(RejectedAuthority),
    RejectedAuthority =
        authority_snapshot(
            Policy, Claim, Records,
            [premise(Id, _Activation, Trust, Provenance)],
            Obligations, Contradictions, Provenances),
    Authority =
        authority_snapshot(
            Policy, Claim, Records,
            [premise(Id, missing, Trust, Provenance)],
            Obligations, Contradictions, Provenances),
    assess_law_claim_authority(Authority, T002),
    T002 =
        authority_assessment(
            rejected(
                rejected_obligation(
                    obligation_id(both_parenthesizations_defined))),
            _),
    validate_ground_typed_equality_pair(
        Proposal, Program, Authority, T003),
    T003 =
        ground_typed_equality_validation(
            rejected(
                authority_rejected(
                    rejected_obligation(
                        obligation_id(
                            both_parenthesizations_defined)))),
            ir_audit(_ProposalAudit, authority(T002))),
    expected_base_result(Tokens, Program, Authority, ExpectedT005),
    one_validation(Tokens, Program, Authority, ActualT005),
    assertion(ActualT005 == ExpectedT005),
    ActualT005 =
        controlled_english_validation(
            rejected(
                predecessor(
                    t003,
                    authority_rejected(
                        rejected_obligation(
                            obligation_id(
                                both_parenthesizations_defined))))),
            controlled_english_audit(
                checked(tokens(20), cells(41), depth(21)),
                complete([Proposal]),
                [candidate(Proposal, T003)])).

test(duplicate_provenance_rejects_without_promotion) :-
    base_tokens(Tokens),
    base_proposal(Proposal),
    canonical_program(Program),
    authority_duplicate_provenance(Authority),
    assess_law_claim_authority(Authority, T002),
    T002 =
        authority_assessment(
            rejected(
                duplicate_identifier(
                    provenance, provenance_id(eop_concepts_p9))),
            audit(no_claim, no_policy, used([]), provenance([]))),
    validate_ground_typed_equality_pair(
        Proposal, Program, Authority, T003),
    T003 =
        ground_typed_equality_validation(
            rejected(malformed_shape(authority, root)),
            ir_audit(_ProposalAudit, authority(T002))),
    expected_base_result(Tokens, Program, Authority, ExpectedT005),
    one_validation(Tokens, Program, Authority, ActualT005),
    assertion(ActualT005 == ExpectedT005).

test(maximum_unknown_and_maximum_plus_one_resource_are_exact) :-
    base_tokens(Tokens),
    base_proposal(Proposal),
    canonical_program(Program),
    authority_missing_boundary(accepted, Authority48, Missing48),
    length(Missing48, 48),
    assess_law_claim_authority(Authority48, T00248),
    assertion(
        T00248 =
            authority_assessment(unknown(Missing48), _)),
    validate_ground_typed_equality_pair(
        Proposal, Program, Authority48, T00348),
    T00348 =
        ground_typed_equality_validation(
            unknown(
                missing_authority(
                    premise_id(adjacent_applications),
                    Missing48)),
            ir_audit(_ProposalAudit48, authority(T00248))),
    expected_base_result(
        Tokens, Program, Authority48, ExpectedT00548),
    one_validation(Tokens, Program, Authority48, ActualT00548),
    assertion(ActualT00548 == ExpectedT00548),
    ActualT00548 =
        controlled_english_validation(
            unknown(
                candidate_predecessors([
                    predecessor(
                        t003,
                        missing_authority(
                            premise_id(adjacent_applications),
                            Missing48))
                ])),
            controlled_english_audit(
                checked(tokens(20), cells(41), depth(21)),
                complete([Proposal]),
                [candidate(Proposal, T00348)])),
    authority_missing_boundary(unknown, Authority49, Missing49),
    length(Missing49, 49),
    assess_law_claim_authority(Authority49, T00249),
    assertion(
        T00249 ==
            authority_assessment(
                rejected(resource_limit_exceeded),
                audit(no_claim, no_policy, used([]), provenance([])))),
    validate_ground_typed_equality_pair(
        Proposal, Program, Authority49, T00349),
    T00349 =
        ground_typed_equality_validation(
            rejected(resource_limit_exceeded(authority, t002)),
            ir_audit(_ProposalAudit49, authority(T00249))),
    expected_base_result(
        Tokens, Program, Authority49, ExpectedT00549),
    one_validation(Tokens, Program, Authority49, ActualT00549),
    assertion(ActualT00549 == ExpectedT00549),
    ActualT00549 =
        controlled_english_validation(
            resource_exhausted(
                candidate_predecessors([
                    predecessor(t003, authority, t002)
                ])),
            controlled_english_audit(
                checked(tokens(20), cells(41), depth(21)),
                complete([Proposal]),
                [candidate(Proposal, T00349)])).

test(non_ground_cyclic_and_malformed_predecessor_inputs_are_not_bound) :-
    base_tokens(Tokens),
    base_proposal(Proposal),
    canonical_context(CanonicalProgram, CanonicalAuthority),
    ProgramVariable = _,
    validate_ground_typed_equality_pair(
        Proposal, ProgramVariable, CanonicalAuthority, ProgramDirect),
    expected_single_status(ProgramDirect, ProgramStatus),
    one_validation(
        Tokens, ProgramVariable, CanonicalAuthority, ProgramActual),
    ProgramActual = controlled_english_validation(ProgramStatus, _),
    assertion(var(ProgramVariable)),
    AuthorityVariable = _,
    validate_ground_typed_equality_pair(
        Proposal, CanonicalProgram, AuthorityVariable, AuthorityDirect),
    expected_single_status(AuthorityDirect, AuthorityStatus),
    one_validation(
        Tokens, CanonicalProgram, AuthorityVariable, AuthorityActual),
    AuthorityActual = controlled_english_validation(AuthorityStatus, _),
    assertion(var(AuthorityVariable)),
    CyclicAuthority =
        authority_snapshot(
            CyclicAuthority, bad, bad, bad, bad, bad, bad),
    validate_ground_typed_equality_pair(
        Proposal, CanonicalProgram, CyclicAuthority, CyclicDirect),
    expected_single_status(CyclicDirect, CyclicStatus),
    one_validation(
        Tokens, CanonicalProgram, CyclicAuthority, CyclicActual),
    CyclicActual = controlled_english_validation(CyclicStatus, _),
    assertion(cyclic_term(CyclicAuthority)).

test(forged_or_swapped_predecessor_inputs_never_supply_authority) :-
    base_tokens(Tokens),
    canonical_context(Program, Authority),
    forall(
        member(
            ForgedProgram-ForgedAuthority,
            [ validated_program(a, b, c, d, e)-Authority,
              validated_pair(forged, forged)-Authority,
              Program-ground_typed_equality_validation(
                          accepted(forged), forged),
              Program-controlled_english_validation(
                          accepted(forged), forged),
              Authority-Program
            ]),
        ( expected_base_result(
              Tokens, ForgedProgram, ForgedAuthority, Expected),
          one_validation(
              Tokens, ForgedProgram, ForgedAuthority, Actual),
          assertion(Actual == Expected),
          Actual =
              controlled_english_validation(
                  rejected(predecessor(t003, _)), _)
        )).

accepted_fixture(
    Specification,
    ground_typed_equality_validation(
        accepted(
            validated_pair(
                Specification,
                validated_program(program, signature, scope, space, premise))),
        audit(accepted))).

rejected_fixture(
    Reason,
    ground_typed_equality_validation(
        rejected(Reason),
        audit(rejected(Reason)))).

resource_fixture(
    Input, Limit,
    ground_typed_equality_validation(
        rejected(resource_limit_exceeded(Input, Limit)),
        audit(resource(Input, Limit)))).

unknown_fixture(
    Missing,
    ground_typed_equality_validation(
        unknown(Missing),
        audit(unknown(Missing)))).

test(private_classifier_resource_dominates_every_other_candidate_class) :-
    resource_fixture(authority, t002, Resource),
    unknown_fixture(missing(a), Unknown),
    rejected_fixture(bad_program, Rejected),
    accepted_fixture(specification(a), Accepted),
    Candidates = [
        candidate(p4, Accepted),
        candidate(p1, Resource),
        candidate(p3, Rejected),
        candidate(p2, Unknown)
    ],
    cps_controlled_english_v0:classify_candidate_validations(
        Candidates, Status),
    assertion(
        Status ==
        resource_exhausted(
            candidate_predecessors([
                predecessor(t003, authority, t002)
            ]))).

test(private_classifier_sorts_and_deduplicates_resources) :-
    resource_fixture(program, depth, ProgramResource),
    resource_fixture(authority, t002, AuthorityResource),
    Candidates = [
        candidate(p3, ProgramResource),
        candidate(p1, AuthorityResource),
        candidate(p2, ProgramResource)
    ],
    cps_controlled_english_v0:classify_candidate_validations(
        Candidates, Status),
    sort(
        [ predecessor(t003, program, depth),
          predecessor(t003, authority, t002)
        ],
        Sorted),
    assertion(
        Status ==
        resource_exhausted(candidate_predecessors(Sorted))).

test(private_classifier_unknown_dominates_rejected_and_accepted) :-
    unknown_fixture(missing(b), UnknownB),
    unknown_fixture(missing(a), UnknownA),
    rejected_fixture(rejected_reason, Rejected),
    accepted_fixture(specification(a), Accepted),
    Candidates = [
        candidate(p4, Accepted),
        candidate(p1, UnknownB),
        candidate(p3, Rejected),
        candidate(p2, UnknownA)
    ],
    cps_controlled_english_v0:classify_candidate_validations(
        Candidates, Status),
    sort(
        [ predecessor(t003, missing(a)),
          predecessor(t003, missing(b))
        ],
        Sorted),
    assertion(
        Status == unknown(candidate_predecessors(Sorted))).

test(private_classifier_identical_rejections_reject_once) :-
    rejected_fixture(same_reason, RejectedA),
    rejected_fixture(same_reason, RejectedB),
    cps_controlled_english_v0:classify_candidate_validations(
        [candidate(p2, RejectedB), candidate(p1, RejectedA)],
        Status),
    assertion(Status == rejected(predecessor(t003, same_reason))).

test(private_classifier_distinct_rejections_are_ambiguous) :-
    rejected_fixture(reason_b, RejectedB),
    rejected_fixture(reason_a, RejectedA),
    cps_controlled_english_v0:classify_candidate_validations(
        [candidate(p2, RejectedB), candidate(p1, RejectedA)],
        Status),
    sort(
        [ predecessor(t003, reason_a),
          predecessor(t003, reason_b)
        ],
        Sorted),
    assertion(Status == ambiguous(distinct_rejections(Sorted))).

test(private_classifier_identical_acceptance_converges) :-
    accepted_fixture(specification(same), AcceptedA),
    accepted_fixture(specification(same), AcceptedB),
    cps_controlled_english_v0:classify_candidate_validations(
        [candidate(p2, AcceptedB), candidate(p1, AcceptedA)],
        Status),
    assertion(Status == accepted(specification(same))).

test(private_classifier_distinct_acceptance_is_ambiguous) :-
    accepted_fixture(specification(b), AcceptedB),
    accepted_fixture(specification(a), AcceptedA),
    cps_controlled_english_v0:classify_candidate_validations(
        [candidate(p2, AcceptedB), candidate(p1, AcceptedA)],
        Status),
    assertion(
        Status ==
        ambiguous(
            distinct_validated_specifications([
                specification(a),
                specification(b)
            ]))).

test(private_classifier_accepted_rejected_mix_is_ambiguous) :-
    accepted_fixture(specification(a), Accepted),
    rejected_fixture(reason_a, Rejected),
    cps_controlled_english_v0:classify_candidate_validations(
        [candidate(p2, Rejected), candidate(p1, Accepted)],
        Status),
    sort(
        [ accepted(specification(a)),
          rejected(predecessor(t003, reason_a))
        ],
        Sorted),
    assertion(Status == ambiguous(mixed_candidate_outcomes(Sorted))).

test(private_classifier_unrecognized_trusted_result_fails_unknown) :-
    accepted_fixture(specification(a), Accepted),
    cps_controlled_english_v0:classify_candidate_validations(
        [ candidate(p1, Accepted),
          candidate(p2, unrecognized_predecessor_result)
        ],
        Status),
    assertion(
        Status ==
        unknown(internal_invariant(predecessor_result_shape))).

test(candidate_priority_is_independent_of_candidate_input_order) :-
    accepted_fixture(specification(a), Accepted),
    rejected_fixture(reason_a, Rejected),
    First = [candidate(p2, Rejected), candidate(p1, Accepted)],
    reverse(First, Second),
    cps_controlled_english_v0:classify_candidate_validations(
        First, FirstStatus),
    cps_controlled_english_v0:classify_candidate_validations(
        Second, SecondStatus),
    assertion(FirstStatus == SecondStatus).

goal_chain(0, leaf) :-
    !.
goal_chain(Depth, chain(Rest)) :-
    Depth > 0,
    Next is Depth - 1,
    goal_chain(Next, Rest).

program_resource(identifier_scalar, Program) :-
    canonical_program(Original),
    atom_of_length(65, Identifier),
    Original =
        program_proposal(
            _ProgramId, Signature, Ast, Definedness, Premises),
    Program =
        program_proposal(
            program_id(Identifier), Signature, Ast, Definedness, Premises).
program_resource(list, Program) :-
    canonical_program(Original),
    Original =
        program_proposal(
            ProgramId, Signature, Ast, Definedness,
            premises([Premise])),
    Program =
        program_proposal(
            ProgramId, Signature, Ast, Definedness,
            premises([Premise, Premise, Premise])).
program_resource(depth, Program) :-
    canonical_program(Original),
    goal_chain(20, Deep),
    Original =
        program_proposal(
            ProgramId, Signature,
            program_ast(Binder, _Expression),
            Definedness, Premises),
    Program =
        program_proposal(
            ProgramId, Signature,
            program_ast(Binder, call(Deep)),
            Definedness, Premises).
program_resource(cells, Program) :-
    canonical_program(Original),
    length(Arguments, 600),
    maplist(=(cell), Arguments),
    compound_name_arguments(Wide, payload, Arguments),
    Original =
        program_proposal(
            ProgramId, Signature,
            program_ast(Binder, _Expression),
            Definedness, Premises),
    Program =
        program_proposal(
            ProgramId, Signature,
            program_ast(Binder, call(Wide)),
            Definedness, Premises).

test(every_reachable_inherited_program_resource_is_lifted_exactly) :-
    base_tokens(Tokens),
    canonical_authority(Authority),
    forall(
        member(Limit, [identifier_scalar, list, depth, cells]),
        ( program_resource(Limit, Program),
          expected_base_result(Tokens, Program, Authority, Expected),
          one_validation(Tokens, Program, Authority, Actual),
          assertion(Actual == Expected),
          Actual =
              controlled_english_validation(
                  resource_exhausted(
                      candidate_predecessors([
                          predecessor(t003, program, Limit)
                      ])),
                  _)
        )).

test(local_token_resource_dominates_all_predecessor_outcomes) :-
    length(Tokens, 25),
    maplist(=(a), Tokens),
    canonical_context(AcceptedProgram, AcceptedAuthority),
    program_variant(wrong_root, RejectedProgram),
    authority_variant(missing_activation, UnknownAuthority),
    authority_variant(resource, ResourceAuthority),
    Contexts = [
        AcceptedProgram-AcceptedAuthority,
        RejectedProgram-AcceptedAuthority,
        AcceptedProgram-UnknownAuthority,
        AcceptedProgram-ResourceAuthority
    ],
    empty_audit(
        limit(tokens(count(24))), not_run,
        resource_exhausted(tokens(count(24))), Expected),
    forall(
        member(Program-Authority, Contexts),
        ( one_validation(Tokens, Program, Authority, Actual),
          assertion(Actual == Expected)
        )).

test(parse_sentinel_dominates_all_predecessor_outcomes) :-
    three_value_tokens(alpha, beta, gamma, Tokens),
    canonical_context(AcceptedProgram, AcceptedAuthority),
    program_variant(wrong_root, RejectedProgram),
    authority_variant(missing_activation, UnknownAuthority),
    authority_variant(resource, ResourceAuthority),
    Contexts = [
        AcceptedProgram-AcceptedAuthority,
        RejectedProgram-AcceptedAuthority,
        AcceptedProgram-UnknownAuthority,
        AcceptedProgram-ResourceAuthority
    ],
    Expected =
        controlled_english_validation(
            resource_exhausted(parse_alternatives(2)),
            controlled_english_audit(
                checked(tokens(24), cells(49), depth(25)),
                alternative_limit(max(2), observed_at_least(3)),
                [])),
    forall(
        member(Program-Authority, Contexts),
        ( one_validation(Tokens, Program, Authority, Actual),
          assertion(Actual == Expected)
        )).

test(every_public_result_is_one_ground_acyclic_solution) :-
    base_tokens(Base),
    two_value_tokens(alpha, beta, Ambiguous),
    three_value_tokens(alpha, beta, gamma, Sentinel),
    replace_nth1(1, Base, call, Unsupported),
    replace_nth1(2, Base, 'Bad', Malformed),
    length(OverLimit, 25),
    maplist(=(a), OverLimit),
    canonical_context(Program, Authority),
    authority_variant(missing_activation, UnknownAuthority),
    authority_variant(resource, ResourceAuthority),
    program_variant(wrong_root, RejectedProgram),
    Cases = [
        Base-Program-Authority,
        Ambiguous-Program-Authority,
        Sentinel-Program-Authority,
        Unsupported-Program-Authority,
        Malformed-Program-Authority,
        OverLimit-Program-Authority,
        Base-RejectedProgram-Authority,
        Base-Program-UnknownAuthority,
        Base-Program-ResourceAuthority
    ],
    forall(
        member(Tokens-CaseProgram-CaseAuthority, Cases),
        ( one_validation(
              Tokens, CaseProgram, CaseAuthority, Validation),
          assertion(ground(Validation)),
          assertion(acyclic_term(Validation))
        )).

test(all_inputs_preserve_identity_sharing_variables_attributes_and_cycles) :-
    base_tokens(Tokens),
    Shared = _,
    Program = program_with_sharing(Shared, Shared),
    canonical_authority(Authority),
    BeforeTokens = Tokens,
    BeforeProgram = Program,
    BeforeAuthority = Authority,
    one_validation(Tokens, Program, Authority, _),
    assert_inputs_identical(
        BeforeTokens, BeforeProgram, BeforeAuthority,
        Tokens, Program, Authority),
    assertion(var(Shared)),
    put_attr(Attributed, plunit_cps_controlled_english_v0, preserved),
    ProgramWithAttribute = program_with_attribute(Attributed),
    one_validation(Tokens, ProgramWithAttribute, Authority, _),
    get_attr(
        Attributed, plunit_cps_controlled_english_v0, preserved),
    del_attr(Attributed, plunit_cps_controlled_english_v0),
    CyclicProgram = program_cycle(CyclicProgram),
    one_validation(Tokens, CyclicProgram, Authority, _),
    assertion(cyclic_term(CyclicProgram)).

test(repeated_and_call_order_results_are_identical) :-
    base_tokens(Tokens),
    two_value_tokens(alpha, beta, OtherTokens),
    canonical_context(Program, Authority),
    one_validation(Tokens, Program, Authority, First),
    one_validation(OtherTokens, Program, Authority, _),
    one_validation(Tokens, Program, Authority, Second),
    assertion(First == Second).

test(current_directory_and_unrelated_asserted_state_do_not_change_result) :-
    base_tokens(Tokens),
    canonical_context(Program, Authority),
    one_validation(Tokens, Program, Authority, Expected),
    setup_call_cleanup(
        assertz(ambient_marker(unrelated)),
        setup_call_cleanup(
            working_directory(Original, '/private/tmp'),
            one_validation(Tokens, Program, Authority, Actual),
            working_directory(_, Original)),
        retractall(ambient_marker(_))),
    assertion(Actual == Expected).

test(module_exports_only_the_approved_public_predicate) :-
    module_property(
        cps_controlled_english_v0,
        exports(Exports)),
    assertion(
        Exports == [validate_controlled_english_v0/4]).

test(source_contains_no_dynamic_meta_or_legacy_execution_boundary) :-
    source_file(
        cps_controlled_english_v0:validate_controlled_english_v0(_, _, _, _),
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
        "phrase_from_file",
        "use_module('../../references",
        "use_module('../references"
    ],
    forall(
        member(Fragment, Forbidden),
        assertion(\+ sub_string(Source, _, _, _, Fragment))).

term_depth(Term, 1) :-
    atomic(Term),
    !.
term_depth(Term, Depth) :-
    compound_name_arguments(Term, _Name, Arguments),
    maplist(term_depth, Arguments, Depths),
    max_list([0|Depths], ChildDepth),
    Depth is ChildDepth + 1.

test(generated_specification_has_the_frozen_depth_nine) :-
    base_proposal(Proposal),
    term_depth(Proposal, Depth),
    assertion(Depth == 9).

:- end_tests(cps_controlled_english_v0).
