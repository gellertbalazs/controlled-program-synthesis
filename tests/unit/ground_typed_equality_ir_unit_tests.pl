:- begin_tests(cps_ground_typed_equality_ir).

:- use_module('../../src/ir/cps_ground_typed_equality_ir').
:- use_module(library(readutil)).

canonical_pair(Specification, Program, Authority, Expected) :-
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
    Shared = provenance_id(eop_concepts_p9),
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
    Provenances = [provenance(Shared, Evidence)],
    Authority =
        authority_snapshot(
            Policy,
            Claim,
            Records,
            Premises,
            Obligations,
            Contradictions,
            Provenances),
    Used = [
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
    AuthorityAudit =
        audit(
            claim_id(partial_associativity),
            policy_id(source_policy),
            used(Used),
            provenance([provenance(Shared, Evidence)])),
    AuthorityAssessment =
        authority_assessment(accepted, AuthorityAudit),
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
    ValidatedProgram =
        validated_program(
            program_id(identity_program),
            program_signature(
                type_id(element), type_id(element)),
            scoped_program(
                object_binder(
                    binder_id(program_object), type_id(element)),
                object_reference(
                    binder_id(program_object), type_id(element))),
            definition_space_id(adjacent_defined),
            premise_id(adjacent_applications)),
    Audit =
        ir_audit(
            proposal(
                pair(
                    specification_id(spec_main),
                    program_id(identity_program),
                    premise_id(adjacent_applications))),
            authority(AuthorityAssessment)),
    Expected =
        ground_typed_equality_validation(
            accepted(
                validated_pair(
                    ValidatedSpecification,
                    ValidatedProgram)),
            Audit).

scope_variants(free_specification, Specification, Program, Authority,
               Expected) :-
    canonical_pair(Specification0, Program, Authority, _),
    Specification0 =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(
                Binder,
                equality(
                    EqualityId,
                    operands([_Reference, Value]))),
            Definedness,
            Premises),
    Reference =
        object_reference(
            binder_id(free_spec_object), type_id(element)),
    Specification =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(
                Binder,
                equality(
                    EqualityId,
                    operands([Reference, Value]))),
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(
                ill_scoped(
                    free_object_reference(
                        specification,
                        binder_id(spec_object),
                        binder_id(free_spec_object)))),
            ir_audit(
                proposal(
                    pair(
                        specification_id(spec_main),
                        program_id(identity_program),
                        premise_id(adjacent_applications))),
                authority(not_checked))).

scope_variants(duplicate_specification, Specification, Program, Authority,
               Expected) :-
    canonical_pair(Specification0, Program, Authority, _),
    Specification0 =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(
                Binder,
                equality(EqualityId, operands([Reference, _Value]))),
            Definedness,
            Premises),
    Specification =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(
                Binder,
                equality(
                    EqualityId,
                    operands([Reference, Reference]))),
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(
                ill_scoped(
                    duplicate_object_reference(
                        specification,
                        binder_id(spec_object)))),
            ir_audit(
                proposal(
                    pair(
                        specification_id(spec_main),
                        program_id(identity_program),
                        premise_id(adjacent_applications))),
                authority(not_checked))).

scope_variants(two_values, Specification, Program, Authority, Expected) :-
    canonical_pair(Specification0, Program, Authority, _),
    Specification0 =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(
                Binder,
                equality(EqualityId, operands([_Reference, Value]))),
            Definedness,
            Premises),
    Specification =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(
                Binder,
                equality(EqualityId, operands([Value, Value]))),
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(
                ill_scoped(
                    missing_object_reference(specification))),
            ir_audit(
                proposal(
                    pair(
                        specification_id(spec_main),
                        program_id(identity_program),
                        premise_id(adjacent_applications))),
                authority(not_checked))).

scope_variants(free_program, Specification, Program, Authority, Expected) :-
    canonical_pair(Specification, Program0, Authority, _),
    Program0 =
        program_proposal(
            ProgramId,
            Signature,
            program_ast(Binder, _Reference),
            Definedness,
            Premises),
    Program =
        program_proposal(
            ProgramId,
            Signature,
            program_ast(
                Binder,
                object_reference(
                    binder_id(free_program_object),
                    type_id(element))),
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(
                ill_scoped(
                    free_object_reference(
                        program,
                        binder_id(program_object),
                        binder_id(free_program_object)))),
            ir_audit(
                proposal(
                    pair(
                        specification_id(spec_main),
                        program_id(identity_program),
                        premise_id(adjacent_applications))),
                authority(not_checked))).

type_variants(specification_binder, Specification, Program, Authority,
              Expected) :-
    canonical_pair(Specification0, Program, Authority, _),
    Specification0 =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(
                object_binder(BinderId, _BinderType),
                Equality),
            Definedness,
            Premises),
    Specification =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(
                object_binder(BinderId, type_id(other)),
                Equality),
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(
                ill_typed(
                    binder_type_mismatch(
                        specification,
                        type_id(element),
                        type_id(other)))),
            ir_audit(
                proposal(
                    pair(
                        specification_id(spec_main),
                        program_id(identity_program),
                        premise_id(adjacent_applications))),
                authority(not_checked))).

type_variants(program_binder, Specification, Program, Authority, Expected) :-
    canonical_pair(Specification, Program0, Authority, _),
    Program0 =
        program_proposal(
            ProgramId,
            Signature,
            program_ast(
                object_binder(BinderId, _BinderType),
                Reference),
            Definedness,
            Premises),
    Program =
        program_proposal(
            ProgramId,
            Signature,
            program_ast(
                object_binder(BinderId, type_id(other)),
                Reference),
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(
                ill_typed(
                    binder_type_mismatch(
                        program,
                        type_id(element),
                        type_id(other)))),
            ir_audit(
                proposal(
                    pair(
                        specification_id(spec_main),
                        program_id(identity_program),
                        premise_id(adjacent_applications))),
                authority(not_checked))).

type_variants(program_reference, Specification, Program, Authority,
              Expected) :-
    canonical_pair(Specification, Program0, Authority, _),
    Program0 =
        program_proposal(
            ProgramId,
            Signature,
            program_ast(Binder, object_reference(ReferenceId, _)),
            Definedness,
            Premises),
    Program =
        program_proposal(
            ProgramId,
            Signature,
            program_ast(
                Binder,
                object_reference(ReferenceId, type_id(other))),
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(
                ill_typed(
                    reference_type_mismatch(
                        program,
                        type_id(element),
                        type_id(other)))),
            ir_audit(
                proposal(
                    pair(
                        specification_id(spec_main),
                        program_id(identity_program),
                        premise_id(adjacent_applications))),
                authority(not_checked))).

type_variants(equality_value, Specification, Program, Authority, Expected) :-
    canonical_pair(Specification0, Program, Authority, _),
    Specification0 =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(
                Binder,
                equality(
                    EqualityId,
                    operands([
                        object_reference(ReferenceId, ReferenceType),
                        object_value(Value, _ValueType)
                    ]))),
            Definedness,
            Premises),
    Specification =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(
                Binder,
                equality(
                    EqualityId,
                    operands([
                        object_reference(ReferenceId, ReferenceType),
                        object_value(Value, type_id(other))
                    ]))),
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(
                ill_typed(
                    equality_operand_type_mismatch(
                        type_id(element),
                        type_id(element),
                        type_id(other)))),
            ir_audit(
                proposal(
                    pair(
                        specification_id(spec_main),
                        program_id(identity_program),
                        premise_id(adjacent_applications))),
                authority(not_checked))).

type_variants(cross_proposal, Specification, Program, Authority, Expected) :-
    canonical_pair(Specification, Program0, Authority, _),
    Program0 =
        program_proposal(
            ProgramId,
            _Signature,
            program_ast(
                object_binder(BinderId, _),
                object_reference(ReferenceId, _)),
            Definedness,
            Premises),
    Program =
        program_proposal(
            ProgramId,
            signature(
                input(type_id(other)),
                output(type_id(other))),
            program_ast(
                object_binder(BinderId, type_id(other)),
                object_reference(ReferenceId, type_id(other))),
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(
                incompatible(
                    type,
                    type_id(element),
                    type_id(other))),
            ir_audit(
                proposal(
                    pair(
                        specification_id(spec_main),
                        program_id(identity_program),
                        premise_id(adjacent_applications))),
                authority(not_checked))).

type_variants(definition_space, Specification, Program, Authority,
              Expected) :-
    canonical_pair(Specification, Program0, Authority, _),
    Program0 =
        program_proposal(
            ProgramId,
            Signature,
            ProgramAst,
            _Definedness,
            Premises),
    Program =
        program_proposal(
            ProgramId,
            Signature,
            ProgramAst,
            definedness(definition_space_id(other_space)),
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(
                incompatible(
                    definition_space,
                    definition_space_id(adjacent_defined),
                    definition_space_id(other_space))),
            ir_audit(
                proposal(
                    pair(
                        specification_id(spec_main),
                        program_id(identity_program),
                        premise_id(adjacent_applications))),
                authority(not_checked))).

type_variants(premise, Specification, Program, Authority, Expected) :-
    canonical_pair(Specification, Program0, Authority, _),
    Program0 =
        program_proposal(
            ProgramId,
            Signature,
            ProgramAst,
            Definedness,
            _Premises),
    Program =
        program_proposal(
            ProgramId,
            Signature,
            ProgramAst,
            Definedness,
            premises([premise_id(other_premise)])),
    Expected =
        ground_typed_equality_validation(
            rejected(
                incompatible(
                    premise,
                    premise_id(adjacent_applications),
                    premise_id(other_premise))),
            ir_audit(
                proposal(
                    pair(
                        specification_id(spec_main),
                        program_id(identity_program),
                        premise_id(adjacent_applications))),
                authority(not_checked))).

shape_variants(missing_equality, Specification, Program, Authority,
               Expected) :-
    canonical_pair(Specification0, Program, Authority, _),
    Specification0 =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(Binder, _Equality),
            Definedness,
            Premises),
    Specification =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(Binder, equality(missing)),
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(missing_equality),
            ir_audit(
                proposal(
                    pair(
                        specification_id(spec_main),
                        program_id(identity_program),
                        premise_id(adjacent_applications))),
                authority(not_checked))).

shape_variants(missing_specification_definedness, Specification, Program,
               Authority, Expected) :-
    canonical_pair(Specification0, Program, Authority, _),
    Specification0 =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            Binding,
            _Definedness,
            Premises),
    Specification =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            Binding,
            definedness(missing),
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(missing_definedness(specification)),
            ir_audit(
                proposal(
                    pair(
                        specification_id(spec_main),
                        program_id(identity_program),
                        premise_id(adjacent_applications))),
                authority(not_checked))).

shape_variants(missing_program_definedness, Specification, Program,
               Authority, Expected) :-
    canonical_pair(Specification, Program0, Authority, _),
    Program0 =
        program_proposal(
            ProgramId,
            Signature,
            ProgramAst,
            _Definedness,
            Premises),
    Program =
        program_proposal(
            ProgramId,
            Signature,
            ProgramAst,
            definedness(missing),
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(missing_definedness(program)),
            ir_audit(
                proposal(
                    pair(
                        specification_id(spec_main),
                        program_id(identity_program),
                        premise_id(adjacent_applications))),
                authority(not_checked))).

shape_variants(type_declarations, Specification, Program, Authority,
               Expected) :-
    canonical_pair(Specification0, Program, Authority, _),
    Specification0 =
        specification_proposal(
            SpecificationId,
            _TypeDeclarations,
            Binding,
            Definedness,
            Premises),
    Specification =
        specification_proposal(
            SpecificationId,
            not_type_declarations([]),
            Binding,
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(malformed_shape(specification, type_declarations)),
            ir_audit(proposal(no_pair), authority(not_checked))).

shape_variants(binder, Specification, Program, Authority, Expected) :-
    canonical_pair(Specification0, Program, Authority, _),
    Specification0 =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(_Binder, Equality),
            Definedness,
            Premises),
    Specification =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(not_a_binder, Equality),
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(malformed_shape(specification, binder)),
            ir_audit(proposal(no_pair), authority(not_checked))).

shape_variants(equality, Specification, Program, Authority, Expected) :-
    canonical_pair(Specification0, Program, Authority, _),
    Specification0 =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(Binder, _Equality),
            Definedness,
            Premises),
    Specification =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(Binder, equality(not_an_equality)),
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(malformed_shape(specification, equality)),
            ir_audit(proposal(no_pair), authority(not_checked))).

shape_variants(operands, Specification, Program, Authority, Expected) :-
    canonical_pair(Specification0, Program, Authority, _),
    Specification0 =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(
                Binder,
                equality(EqualityId, operands([Reference, _Value]))),
            Definedness,
            Premises),
    Specification =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(
                Binder,
                equality(EqualityId, operands([Reference]))),
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(malformed_shape(specification, operands)),
            ir_audit(proposal(no_pair), authority(not_checked))).

shape_variants(program_signature, Specification, Program, Authority,
               Expected) :-
    canonical_pair(Specification, Program0, Authority, _),
    Program0 =
        program_proposal(
            ProgramId,
            _Signature,
            ProgramAst,
            Definedness,
            Premises),
    Program =
        program_proposal(
            ProgramId,
            signature(not_input, not_output),
            ProgramAst,
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(malformed_shape(program, signature)),
            ir_audit(proposal(no_pair), authority(not_checked))).

shape_variants(program_ast, Specification, Program, Authority, Expected) :-
    canonical_pair(Specification, Program0, Authority, _),
    Program0 =
        program_proposal(
            ProgramId,
            Signature,
            _ProgramAst,
            Definedness,
            Premises),
    Program =
        program_proposal(
            ProgramId,
            Signature,
            program_ast(not_a_binder, not_a_reference),
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(malformed_shape(program, binder)),
            ir_audit(proposal(no_pair), authority(not_checked))).

shape_variants(wrong_identifier_scalar, Specification, Program, Authority,
               Expected) :-
    canonical_pair(Specification0, Program, Authority, _),
    Specification0 =
        specification_proposal(
            _SpecificationId,
            TypeDeclarations,
            Binding,
            Definedness,
            Premises),
    Specification =
        specification_proposal(
            specification_id(17),
            TypeDeclarations,
            Binding,
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(malformed_shape(specification, scalar)),
            ir_audit(proposal(no_pair), authority(not_checked))).

shape_variants(wrong_value_scalar, Specification, Program, Authority,
               Expected) :-
    canonical_pair(Specification0, Program, Authority, _),
    Specification0 =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(
                Binder,
                equality(
                    EqualityId,
                    operands([Reference, object_value(_, ValueType)]))),
            Definedness,
            Premises),
    Specification =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(
                Binder,
                equality(
                    EqualityId,
                    operands([
                        Reference,
                        object_value(atom_value(17), ValueType)
                    ]))),
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(malformed_shape(specification, scalar)),
            ir_audit(proposal(no_pair), authority(not_checked))).

shape_variants(improper_types, Specification, Program, Authority,
               Expected) :-
    canonical_pair(Specification0, Program, Authority, _),
    Specification0 =
        specification_proposal(
            SpecificationId,
            type_declarations([Type]),
            Binding,
            Definedness,
            Premises),
    Types = [Type|not_a_list],
    Specification =
        specification_proposal(
            SpecificationId,
            type_declarations(Types),
            Binding,
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(malformed_shape(specification, collection)),
            ir_audit(proposal(no_pair), authority(not_checked))).

shape_variants(improper_program_premises, Specification, Program, Authority,
               Expected) :-
    canonical_pair(Specification, Program0, Authority, _),
    Program0 =
        program_proposal(
            ProgramId,
            Signature,
            ProgramAst,
            Definedness,
            premises([Premise])),
    Premises = [Premise|not_a_list],
    Program =
        program_proposal(
            ProgramId,
            Signature,
            ProgramAst,
            Definedness,
            premises(Premises)),
    Expected =
        ground_typed_equality_validation(
            rejected(malformed_shape(program, collection)),
            ir_audit(proposal(no_pair), authority(not_checked))).

shape_variants(over_limit_malformed_types, Specification, Program, Authority,
               Expected) :-
    canonical_pair(Specification0, Program, Authority, _),
    Specification0 =
        specification_proposal(
            SpecificationId,
            type_declarations([Type]),
            Binding,
            Definedness,
            Premises),
    Specification =
        specification_proposal(
            SpecificationId,
            type_declarations([
                Type,
                Type,
                not_a_type_declaration
            ]),
            Binding,
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(malformed_shape(specification, type_declarations)),
            ir_audit(proposal(no_pair), authority(not_checked))).

shape_variants(over_limit_malformed_operands, Specification, Program,
               Authority, Expected) :-
    canonical_pair(Specification0, Program, Authority, _),
    Specification0 =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(
                Binder,
                equality(
                    EqualityId,
                    operands([Reference, Value]))),
            Definedness,
            Premises),
    Specification =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(
                Binder,
                equality(
                    EqualityId,
                    operands([
                        Reference,
                        Value,
                        not_an_operand
                    ]))),
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(malformed_shape(specification, operands)),
            ir_audit(proposal(no_pair), authority(not_checked))).

shape_variants(over_limit_malformed_premises, Specification, Program,
               Authority, Expected) :-
    canonical_pair(Specification0, Program, Authority, _),
    Specification0 =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            Binding,
            Definedness,
            premises([Premise])),
    Specification =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            Binding,
            Definedness,
            premises([
                Premise,
                Premise,
                not_a_premise
            ])),
    Expected =
        ground_typed_equality_validation(
            rejected(malformed_shape(specification, identifier)),
            ir_audit(proposal(no_pair), authority(not_checked))).

shape_variants(over_limit_improper_types, Specification, Program, Authority,
               Expected) :-
    canonical_pair(Specification0, Program, Authority, _),
    Specification0 =
        specification_proposal(
            SpecificationId,
            type_declarations([Type]),
            Binding,
            Definedness,
            Premises),
    Types = [Type, Type, Type|not_a_list],
    Specification =
        specification_proposal(
            SpecificationId,
            type_declarations(Types),
            Binding,
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(malformed_shape(specification, collection)),
            ir_audit(proposal(no_pair), authority(not_checked))).

shape_variants(over_limit_improper_operands, Specification, Program,
               Authority, Expected) :-
    canonical_pair(Specification0, Program, Authority, _),
    Specification0 =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(
                Binder,
                equality(
                    EqualityId,
                    operands([Reference, Value]))),
            Definedness,
            Premises),
    Operands = [Reference, Value, Reference|not_a_list],
    Specification =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(
                Binder,
                equality(EqualityId, operands(Operands))),
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(malformed_shape(specification, collection)),
            ir_audit(proposal(no_pair), authority(not_checked))).

shape_variants(over_limit_improper_premises, Specification, Program,
               Authority, Expected) :-
    canonical_pair(Specification0, Program, Authority, _),
    Specification0 =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            Binding,
            Definedness,
            premises([Premise])),
    Premises = [Premise, Premise, Premise|not_a_list],
    Specification =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            Binding,
            Definedness,
            premises(Premises)),
    Expected =
        ground_typed_equality_validation(
            rejected(malformed_shape(specification, collection)),
            ir_audit(proposal(no_pair), authority(not_checked))).

shape_variants(nested_specification_variable, Specification, Program,
               Authority, Expected) :-
    canonical_pair(Specification0, Program, Authority, _),
    Specification0 =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(
                Binder,
                equality(
                    EqualityId,
                    operands([_Reference, Value]))),
            Definedness,
            Premises),
    Specification =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(
                Binder,
                equality(
                    EqualityId,
                    operands([
                        object_reference(
                            binder_id(spec_object), _Variable),
                        Value
                    ]))),
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(non_ground_input(specification)),
            ir_audit(proposal(no_pair), authority(not_checked))).

shape_variants(nested_program_variable, Specification, Program, Authority,
               Expected) :-
    canonical_pair(Specification, Program0, Authority, _),
    Program0 =
        program_proposal(
            ProgramId,
            Signature,
            program_ast(Binder, _Reference),
            Definedness,
            Premises),
    Program =
        program_proposal(
            ProgramId,
            Signature,
            program_ast(
                Binder,
                object_reference(
                    binder_id(program_object), _Variable)),
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(non_ground_input(program)),
            ir_audit(proposal(no_pair), authority(not_checked))).

shape_variants(variable_type_collection, Specification, Program, Authority,
               Expected) :-
    canonical_pair(Specification0, Program, Authority, _),
    Specification0 =
        specification_proposal(
            SpecificationId,
            _TypeDeclarations,
            Binding,
            Definedness,
            Premises),
    Specification =
        specification_proposal(
            SpecificationId,
            type_declarations(_Variable),
            Binding,
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(non_ground_input(specification)),
            ir_audit(proposal(no_pair), authority(not_checked))).

shape_variants(variable_collection_tail, Specification, Program, Authority,
               Expected) :-
    canonical_pair(Specification0, Program, Authority, _),
    Specification0 =
        specification_proposal(
            SpecificationId,
            type_declarations([NominalType]),
            Binding,
            Definedness,
            Premises),
    TypeDeclarations = [NominalType|_Variable],
    Specification =
        specification_proposal(
            SpecificationId,
            type_declarations(TypeDeclarations),
            Binding,
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(non_ground_input(specification)),
            ir_audit(proposal(no_pair), authority(not_checked))).

shape_variants(variable_equality_state, Specification, Program, Authority,
               Expected) :-
    canonical_pair(Specification0, Program, Authority, _),
    Specification0 =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(Binder, _Equality),
            Definedness,
            Premises),
    Specification =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(Binder, equality(_Variable)),
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(non_ground_input(specification)),
            ir_audit(proposal(no_pair), authority(not_checked))).

shape_variants(variable_definedness_state, Specification, Program,
               Authority, Expected) :-
    canonical_pair(Specification0, Program, Authority, _),
    Specification0 =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            Binding,
            _Definedness,
            Premises),
    Specification =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            Binding,
            definedness(_Variable),
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(non_ground_input(specification)),
            ir_audit(proposal(no_pair), authority(not_checked))).

shape_variants(variable_quantifier_kind, Specification, Program, Authority,
               Expected) :-
    canonical_pair(Specification0, Program, Authority, _),
    Specification0 =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(Binder, _Equality),
            Definedness,
            Premises),
    Specification =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(
                Binder,
                quantifier(
                    _Variable,
                    object_binder(
                        binder_id(quantified_object), type_id(element)),
                    object_reference(
                        binder_id(quantified_object), type_id(element)))),
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(non_ground_input(specification)),
            ir_audit(proposal(no_pair), authority(not_checked))).

shape_variants(variable_fixed_field(specification, Index),
               Specification, Program, Authority, Expected) :-
    canonical_pair(Specification0, Program, Authority, _),
    compound_name_arguments(
        Specification0, specification_proposal, Fields0),
    BeforeCount is Index - 1,
    length(Before, BeforeCount),
    append(Before, [_OldField|After], Fields0),
    append(Before, [_Variable|After], Fields),
    compound_name_arguments(
        Specification, specification_proposal, Fields),
    Expected =
        ground_typed_equality_validation(
            rejected(non_ground_input(specification)),
            ir_audit(proposal(no_pair), authority(not_checked))),
    !.

shape_variants(variable_fixed_field(program, Index),
               Specification, Program, Authority, Expected) :-
    canonical_pair(Specification, Program0, Authority, _),
    compound_name_arguments(Program0, program_proposal, Fields0),
    BeforeCount is Index - 1,
    length(Before, BeforeCount),
    append(Before, [_OldField|After], Fields0),
    append(Before, [_Variable|After], Fields),
    compound_name_arguments(Program, program_proposal, Fields),
    Expected =
        ground_typed_equality_validation(
            rejected(non_ground_input(program)),
            ir_audit(proposal(no_pair), authority(not_checked))),
    !.

shape_variants(cyclic_fixed_field(specification, Index),
               Specification, Program, Authority, Expected) :-
    canonical_pair(Specification0, Program, Authority, _),
    compound_name_arguments(
        Specification0, specification_proposal, Fields0),
    BeforeCount is Index - 1,
    length(Before, BeforeCount),
    append(Before, [_OldField|After], Fields0),
    Cycle = cycle(Cycle),
    append(Before, [Cycle|After], Fields),
    compound_name_arguments(
        Specification, specification_proposal, Fields),
    Expected =
        ground_typed_equality_validation(
            rejected(cyclic_input(specification)),
            ir_audit(proposal(no_pair), authority(not_checked))),
    !.

shape_variants(cyclic_fixed_field(program, Index),
               Specification, Program, Authority, Expected) :-
    canonical_pair(Specification, Program0, Authority, _),
    compound_name_arguments(Program0, program_proposal, Fields0),
    BeforeCount is Index - 1,
    length(Before, BeforeCount),
    append(Before, [_OldField|After], Fields0),
    Cycle = cycle(Cycle),
    append(Before, [Cycle|After], Fields),
    compound_name_arguments(Program, program_proposal, Fields),
    Expected =
        ground_typed_equality_validation(
            rejected(cyclic_input(program)),
            ir_audit(proposal(no_pair), authority(not_checked))),
    !.

shape_variants(malformed_fixed_field(specification, Index),
               Specification, Program, Authority, Expected) :-
    canonical_pair(Specification0, Program, Authority, _),
    memberchk(
        Index-Field,
        [ 1-identifier,
          2-type_declarations,
          3-binder,
          4-definedness,
          5-premises
        ]),
    compound_name_arguments(
        Specification0, specification_proposal, Fields0),
    BeforeCount is Index - 1,
    length(Before, BeforeCount),
    append(Before, [_OldField|After], Fields0),
    append(Before, [malformed_fixed_field|After], Fields),
    compound_name_arguments(
        Specification, specification_proposal, Fields),
    Expected =
        ground_typed_equality_validation(
            rejected(malformed_shape(specification, Field)),
            ir_audit(proposal(no_pair), authority(not_checked))),
    !.

shape_variants(malformed_fixed_field(program, Index),
               Specification, Program, Authority, Expected) :-
    canonical_pair(Specification, Program0, Authority, _),
    memberchk(
        Index-Field,
        [ 1-identifier,
          2-signature,
          3-program_ast,
          4-definedness,
          5-premises
        ]),
    compound_name_arguments(Program0, program_proposal, Fields0),
    BeforeCount is Index - 1,
    length(Before, BeforeCount),
    append(Before, [_OldField|After], Fields0),
    append(Before, [malformed_fixed_field|After], Fields),
    compound_name_arguments(Program, program_proposal, Fields),
    Expected =
        ground_typed_equality_validation(
            rejected(malformed_shape(program, Field)),
            ir_audit(proposal(no_pair), authority(not_checked))),
    !.

shape_variants(attributed_specification, Specification, Program, Authority,
               Expected) :-
    canonical_pair(Specification0, Program, Authority, _),
    put_attr(Variable, cps_ground_typed_equality_ir, marker),
    Specification0 =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(
                Binder,
                equality(
                    EqualityId,
                    operands([_Reference, Value]))),
            Definedness,
            Premises),
    Specification =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(
                Binder,
                equality(
                    EqualityId,
                    operands([
                        object_reference(
                            binder_id(spec_object), Variable),
                        Value
                    ]))),
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(non_ground_input(specification)),
            ir_audit(proposal(no_pair), authority(not_checked))).

shape_variants(direct_cycle, Specification, Program, Authority, Expected) :-
    canonical_pair(Specification0, Program, Authority, _),
    Specification0 =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(
                Binder,
                equality(EqualityId, operands([Reference, Value]))),
            Definedness,
            Premises),
    Operands = [Reference, Value|Operands],
    Specification =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(
                Binder,
                equality(EqualityId, operands(Operands))),
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(cyclic_input(specification)),
            ir_audit(proposal(no_pair), authority(not_checked))).

shape_variants(indirect_cycle, Specification, Program, Authority, Expected) :-
    canonical_pair(Specification0, Program, Authority, _),
    Left = loop(Right),
    Right = loop(Left),
    Specification0 =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(Binder, _Equality),
            Definedness,
            Premises),
    Specification =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(Binder, call(Left)),
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(cyclic_input(specification)),
            ir_audit(proposal(no_pair), authority(not_checked))).

shape_variants(swapped, Program, Specification, Authority, Expected) :-
    canonical_pair(Specification, Program, Authority, _),
    Expected =
        ground_typed_equality_validation(
            rejected(swapped_proposals),
            ir_audit(proposal(no_pair), authority(not_checked))).

shape_variants(forged_specification, Forged, Program, Authority, Expected) :-
    canonical_pair(_Specification, Program, Authority, _),
    Forged =
        validated_specification(
            specification_id(forged),
            nominal_type(type_id(element)),
            scoped_equality(
                object_binder(binder_id(forged), type_id(element)),
                equality_relation(
                    equality_id(forged),
                    object_reference(
                        binder_id(forged), type_id(element)),
                    object_value(
                        atom_value(forged), type_id(element)))),
            definition_space_id(forged),
            premise_id(forged)),
    Expected =
        ground_typed_equality_validation(
            rejected(forged_validated_input(specification)),
            ir_audit(proposal(no_pair), authority(not_checked))).

shape_variants(forged_program, Specification, Forged, Authority, Expected) :-
    canonical_pair(Specification, _Program, Authority, _),
    Forged =
        validated_program(
            program_id(forged),
            program_signature(type_id(element), type_id(element)),
            scoped_program(
                object_binder(binder_id(forged), type_id(element)),
                object_reference(
                    binder_id(forged), type_id(element))),
            definition_space_id(forged),
            premise_id(forged)),
    Expected =
        ground_typed_equality_validation(
            rejected(forged_validated_input(program)),
            ir_audit(proposal(no_pair), authority(not_checked))).

shape_variants(noncanonical_operands, Specification, Program, Authority,
               Expected) :-
    canonical_pair(Specification0, Program, Authority, _),
    Specification0 =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(
                Binder,
                equality(
                    EqualityId,
                    operands([Reference, Value]))),
            Definedness,
            Premises),
    Specification =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(
                Binder,
                equality(
                    EqualityId,
                    operands([Value, Reference]))),
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(
                noncanonical_input(
                    specification, operand_order)),
            ir_audit(
                proposal(
                    pair(
                        specification_id(spec_main),
                        program_id(identity_program),
                        premise_id(adjacent_applications))),
                authority(not_checked))).

unsupported_variants(lambda, Specification, Program, Authority, Expected) :-
    canonical_pair(Specification0, Program, Authority, _),
    Specification0 =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(Binder, _Equality),
            Definedness,
            Premises),
    Unsupported =
        lambda(
            object_binder(
                binder_id(lambda_object), type_id(element)),
            object_reference(
                binder_id(lambda_object), type_id(element))),
    Specification =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(Binder, Unsupported),
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(out_of_fragment(lambda)),
            ir_audit(proposal(no_pair), authority(not_checked))).

unsupported_variants(quantifier, Specification, Program, Authority,
                     Expected) :-
    canonical_pair(Specification0, Program, Authority, _),
    Specification0 =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(Binder, _Equality),
            Definedness,
            Premises),
    Unsupported =
        quantifier(
            forall,
            object_binder(
                binder_id(quantified_object), type_id(element)),
            object_reference(
                binder_id(quantified_object), type_id(element))),
    Specification =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(Binder, Unsupported),
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(out_of_fragment(quantifier)),
            ir_audit(proposal(no_pair), authority(not_checked))).

unsupported_variants(nested_binder, Specification, Program, Authority,
                     Expected) :-
    canonical_pair(Specification0, Program, Authority, _),
    Specification0 =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(Binder, _Equality),
            Definedness,
            Premises),
    Unsupported =
        nested_binder(
            object_binder(
                binder_id(outer_object), type_id(element)),
            object_binder(
                binder_id(inner_object), type_id(element)),
            object_reference(
                binder_id(inner_object), type_id(element))),
    Specification =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(Binder, Unsupported),
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(out_of_fragment(nested_binder)),
            ir_audit(proposal(no_pair), authority(not_checked))).

unsupported_variants(operation_application, Specification, Program,
                     Authority, Expected) :-
    canonical_pair(Specification0, Program, Authority, _),
    Specification0 =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(Binder, _Equality),
            Definedness,
            Premises),
    Unsupported =
        operation_application(
            operation_id(binary_operation),
            [left_operand, right_operand]),
    Specification =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(Binder, Unsupported),
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(out_of_fragment(operation_application)),
            ir_audit(proposal(no_pair), authority(not_checked))).

unsupported_variants(over_limit_improper_operation_application,
                     Specification, Program, Authority, Expected) :-
    canonical_pair(Specification0, Program, Authority, _),
    Specification0 =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(Binder, _Equality),
            Definedness,
            Premises),
    Arguments = [left_operand, middle_operand, right_operand|not_a_list],
    Unsupported =
        operation_application(
            operation_id(binary_operation),
            Arguments),
    Specification =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(Binder, Unsupported),
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(malformed_shape(specification, collection)),
            ir_audit(proposal(no_pair), authority(not_checked))).

unsupported_variants(raw_host_goal, Specification, Program, Authority,
                     Expected) :-
    canonical_pair(Specification0, Program, Authority, _),
    Specification0 =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(Binder, _Equality),
            Definedness,
            Premises),
    Unsupported = call(throw(must_not_execute)),
    Specification =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(Binder, Unsupported),
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(out_of_fragment(raw_host_goal)),
            ir_audit(proposal(no_pair), authority(not_checked))).

unsupported_variants(raw_host_clause, Specification, Program, Authority,
                     Expected) :-
    canonical_pair(Specification0, Program, Authority, _),
    Specification0 =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(Binder, _Equality),
            Definedness,
            Premises),
    Unsupported = (forged_head :- throw(must_not_execute)),
    Specification =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(Binder, Unsupported),
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(out_of_fragment(raw_host_clause)),
            ir_audit(proposal(no_pair), authority(not_checked))).

authority_variants(inactive, Specification, Program, Authority, Expected) :-
    canonical_pair(Specification, Program, Authority0, Expected0),
    Authority0 =
        authority_snapshot(
            Policy,
            Claim,
            Records,
            [premise(PremiseId, _Activation, Trust, ProvenanceId)],
            Obligations,
            Contradictions,
            Provenances),
    Premise =
        premise(
            PremiseId,
            inactive(ProvenanceId),
            Trust,
            ProvenanceId),
    Authority =
        authority_snapshot(
            Policy,
            Claim,
            Records,
            [Premise],
            Obligations,
            Contradictions,
            Provenances),
    Expected0 =
        ground_typed_equality_validation(
            accepted(_),
            ir_audit(ProposalAudit,
                     authority(authority_assessment(accepted, Audit)))),
    Assessment =
        authority_assessment(
            rejected(inactive_premise(PremiseId)),
            Audit),
    Expected =
        ground_typed_equality_validation(
            rejected(inactive_premise(PremiseId)),
            ir_audit(ProposalAudit, authority(Assessment))).

authority_variants(missing_activation, Specification, Program, Authority,
                   Expected) :-
    canonical_pair(Specification, Program, Authority0, Expected0),
    Authority0 =
        authority_snapshot(
            Policy,
            Claim,
            Records,
            [premise(PremiseId, _Activation, Trust, ProvenanceId)],
            Obligations,
            Contradictions,
            Provenances),
    Premise =
        premise(
            PremiseId,
            missing,
            Trust,
            ProvenanceId),
    Authority =
        authority_snapshot(
            Policy,
            Claim,
            Records,
            [Premise],
            Obligations,
            Contradictions,
            Provenances),
    Missing = [missing(premise_activation, PremiseId)],
    Expected0 =
        ground_typed_equality_validation(
            accepted(_),
            ir_audit(ProposalAudit,
                     authority(authority_assessment(accepted, Audit)))),
    Assessment = authority_assessment(unknown(Missing), Audit),
    Expected =
        ground_typed_equality_validation(
            unknown(
                missing_authority(
                    premise_id(adjacent_applications),
                    Missing)),
            ir_audit(ProposalAudit, authority(Assessment))).

authority_variants(untrusted, Specification, Program, Authority, Expected) :-
    canonical_pair(Specification, Program, Authority0, Expected0),
    Authority0 =
        authority_snapshot(
            Policy,
            Claim,
            Records,
            [premise(PremiseId, Activation, _Trust, ProvenanceId)],
            Obligations,
            Contradictions,
            Provenances),
    Premise =
        premise(
            PremiseId,
            Activation,
            untrusted(policy_id(source_policy), ProvenanceId),
            ProvenanceId),
    Authority =
        authority_snapshot(
            Policy,
            Claim,
            Records,
            [Premise],
            Obligations,
            Contradictions,
            Provenances),
    Expected0 =
        ground_typed_equality_validation(
            accepted(_),
            ir_audit(ProposalAudit,
                     authority(authority_assessment(accepted, Audit)))),
    Assessment =
        authority_assessment(
            rejected(untrusted_premise(PremiseId)),
            Audit),
    Expected =
        ground_typed_equality_validation(
            rejected(untrusted_premise(PremiseId)),
            ir_audit(ProposalAudit, authority(Assessment))).

authority_variants(explicit_contradiction, Specification, Program, Authority,
                   Expected) :-
    canonical_pair(Specification, Program, Authority0, Expected0),
    Authority0 =
        authority_snapshot(
            Policy,
            Claim,
            Records,
            Premises,
            Obligations,
            [contradiction(Id, ClaimId, _State, ProvenanceId)],
            Provenances),
    Contradiction =
        contradiction(
            Id,
            ClaimId,
            explicit(ProvenanceId),
            ProvenanceId),
    Authority =
        authority_snapshot(
            Policy,
            Claim,
            Records,
            Premises,
            Obligations,
            [Contradiction],
            Provenances),
    Expected0 =
        ground_typed_equality_validation(
            accepted(_),
            ir_audit(ProposalAudit,
                     authority(authority_assessment(accepted, Audit)))),
    T002Reason = explicit_contradiction(Id),
    Assessment =
        authority_assessment(rejected(T002Reason), Audit),
    Expected =
        ground_typed_equality_validation(
            rejected(authority_rejected(T002Reason)),
            ir_audit(ProposalAudit, authority(Assessment))).

authority_variants(nonground, Specification, Program, _Authority, Expected) :-
    canonical_pair(Specification, Program, _CanonicalAuthority, Expected0),
    PreAudit =
        audit(no_claim, no_policy, used([]), provenance([])),
    Assessment =
        authority_assessment(rejected(non_ground_input), PreAudit),
    Expected0 =
        ground_typed_equality_validation(
            accepted(_),
            ir_audit(ProposalAudit, authority(_))),
    Expected =
        ground_typed_equality_validation(
            rejected(non_ground_input(authority)),
            ir_audit(ProposalAudit, authority(Assessment))).

authority_variants(cyclic, Specification, Program, Authority, Expected) :-
    canonical_pair(Specification, Program, Authority0, Expected0),
    Authority0 =
        authority_snapshot(
            _Policy,
            Claim,
            Records,
            Premises,
            Obligations,
            Contradictions,
            Provenances),
    Authority =
        authority_snapshot(
            Authority,
            Claim,
            Records,
            Premises,
            Obligations,
            Contradictions,
            Provenances),
    PreAudit =
        audit(no_claim, no_policy, used([]), provenance([])),
    Assessment =
        authority_assessment(rejected(cyclic_input), PreAudit),
    Expected0 =
        ground_typed_equality_validation(
            accepted(_),
            ir_audit(ProposalAudit, authority(_))),
    Expected =
        ground_typed_equality_validation(
            rejected(cyclic_input(authority)),
            ir_audit(ProposalAudit, authority(Assessment))).

authority_variants(malformed, Specification, Program, malformed_authority,
                   Expected) :-
    canonical_pair(Specification, Program, _Authority, Expected0),
    PreAudit =
        audit(no_claim, no_policy, used([]), provenance([])),
    Assessment =
        authority_assessment(rejected(malformed_shape), PreAudit),
    Expected0 =
        ground_typed_equality_validation(
            accepted(_),
            ir_audit(ProposalAudit, authority(_))),
    Expected =
        ground_typed_equality_validation(
            rejected(malformed_shape(authority, root)),
            ir_audit(ProposalAudit, authority(Assessment))).

authority_variants(resource, Specification, Program, Authority, Expected) :-
    canonical_pair(Specification, Program, Authority0, Expected0),
    boundary_terms(identifier_65, LongId),
    Authority0 =
        authority_snapshot(
            policy(policy_id(_), PolicyKind, ProvenanceId),
            Claim,
            Records,
            Premises,
            Obligations,
            Contradictions,
            Provenances),
    Authority =
        authority_snapshot(
            policy(policy_id(LongId), PolicyKind, ProvenanceId),
            Claim,
            Records,
            Premises,
            Obligations,
            Contradictions,
            Provenances),
    PreAudit =
        audit(no_claim, no_policy, used([]), provenance([])),
    Assessment =
        authority_assessment(
            rejected(resource_limit_exceeded),
            PreAudit),
    Expected0 =
        ground_typed_equality_validation(
            accepted(_),
            ir_audit(ProposalAudit, authority(_))),
    Expected =
        ground_typed_equality_validation(
            rejected(resource_limit_exceeded(authority, t002)),
            ir_audit(ProposalAudit, authority(Assessment))).

authority_variants(resource_beyond, Specification, Program, Authority,
                   Expected) :-
    canonical_pair(Specification, Program, Authority0, Expected0),
    boundary_terms(identifier_65, Identifier65),
    atom_concat(Identifier65, i, Identifier66),
    Authority0 =
        authority_snapshot(
            policy(policy_id(_), PolicyKind, ProvenanceId),
            Claim,
            Records,
            Premises,
            Obligations,
            Contradictions,
            Provenances),
    Authority =
        authority_snapshot(
            policy(policy_id(Identifier66), PolicyKind, ProvenanceId),
            Claim,
            Records,
            Premises,
            Obligations,
            Contradictions,
            Provenances),
    PreAudit =
        audit(no_claim, no_policy, used([]), provenance([])),
    Assessment =
        authority_assessment(
            rejected(resource_limit_exceeded),
            PreAudit),
    Expected0 =
        ground_typed_equality_validation(
            accepted(_),
            ir_audit(ProposalAudit, authority(_))),
    Expected =
        ground_typed_equality_validation(
            rejected(resource_limit_exceeded(authority, t002)),
            ir_audit(ProposalAudit, authority(Assessment))).

authority_variants(resource_with_priority(Priority),
                   Specification, Program, Authority, Expected) :-
    canonical_pair(Specification, Program, Authority0, Expected0),
    boundary_terms(identifier_65, LongId),
    Authority0 =
        authority_snapshot(
            policy(policy_id(_), PolicyKind, ProvenanceId),
            _Claim,
            Records,
            Premises,
            Obligations,
            Contradictions,
            Provenances),
    (   Priority == nonground
    ->  PriorityClaim = _Variable,
        T002Reason = non_ground_input,
        IrReason = non_ground_input(authority)
    ;   Priority == cyclic
    ->  PriorityClaim = cycle(PriorityClaim),
        T002Reason = cyclic_input,
        IrReason = cyclic_input(authority)
    ;   Priority == malformed
    ->  PriorityClaim = malformed_claim,
        T002Reason = malformed_shape,
        IrReason = malformed_shape(authority, root)
    ),
    Authority =
        authority_snapshot(
            policy(policy_id(LongId), PolicyKind, ProvenanceId),
            PriorityClaim,
            Records,
            Premises,
            Obligations,
            Contradictions,
            Provenances),
    PreAudit =
        audit(no_claim, no_policy, used([]), provenance([])),
    Assessment =
        authority_assessment(rejected(T002Reason), PreAudit),
    Expected0 =
        ground_typed_equality_validation(
            accepted(_),
            ir_audit(ProposalAudit, authority(_))),
    Expected =
        ground_typed_equality_validation(
            rejected(IrReason),
            ir_audit(ProposalAudit, authority(Assessment))).

authority_variants(resource_before_status(Status),
                   Specification, Program, Authority, Expected) :-
    (   Status == inactive
    ->  authority_variants(
            inactive, Specification, Program, Authority0, _)
    ;   Status == unknown
    ->  authority_variants(
            missing_activation, Specification, Program, Authority0, _)
    ),
    boundary_terms(identifier_65, LongId),
    Authority0 =
        authority_snapshot(
            policy(policy_id(_), PolicyKind, ProvenanceId),
            Claim,
            Records,
            Premises,
            Obligations,
            Contradictions,
            Provenances),
    Authority =
        authority_snapshot(
            policy(policy_id(LongId), PolicyKind, ProvenanceId),
            Claim,
            Records,
            Premises,
            Obligations,
            Contradictions,
            Provenances),
    PreAudit =
        audit(no_claim, no_policy, used([]), provenance([])),
    Assessment =
        authority_assessment(
            rejected(resource_limit_exceeded),
            PreAudit),
    ProposalAudit =
        proposal(
            pair(
                specification_id(spec_main),
                program_id(identity_program),
                premise_id(adjacent_applications))),
    Expected =
        ground_typed_equality_validation(
            rejected(resource_limit_exceeded(authority, t002)),
            ir_audit(ProposalAudit, authority(Assessment))).

authority_variants(scope_equality, Specification, Program, Authority,
                   Expected) :-
    canonical_pair(Specification0, Program, Authority, Expected0),
    Specification0 =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(
                Binder,
                equality(
                    _EqualityId,
                    Operands)),
            Definedness,
            Premises),
    Specification =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(
                Binder,
                equality(
                    equality_id(other_equality),
                    Operands)),
            Definedness,
            Premises),
    Expected0 =
        ground_typed_equality_validation(
            accepted(_),
            ir_audit(ProposalAudit,
                     authority(Assessment))),
    Expected =
        ground_typed_equality_validation(
            rejected(
                authority_scope_mismatch(
                    expected(
                        equality_id(other_equality),
                        definition_space_id(adjacent_defined),
                        premise_id(adjacent_applications)),
                    found(
                        [equality_id(represented_equal)],
                        [definition_space_id(adjacent_defined)],
                        [premise_id(adjacent_applications)]))),
            ir_audit(ProposalAudit, authority(Assessment))).

authority_variants(scope_definition_space, Specification, Program, Authority,
                   Expected) :-
    canonical_pair(Specification0, Program0, Authority, Expected0),
    Specification0 =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            Binding,
            _SpecDefinedness,
            SpecPremises),
    Program0 =
        program_proposal(
            ProgramId,
            Signature,
            ProgramAst,
            _ProgramDefinedness,
            ProgramPremises),
    Definition = definedness(definition_space_id(other_space)),
    Specification =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            Binding,
            Definition,
            SpecPremises),
    Program =
        program_proposal(
            ProgramId,
            Signature,
            ProgramAst,
            Definition,
            ProgramPremises),
    Expected0 =
        ground_typed_equality_validation(
            accepted(_),
            ir_audit(ProposalAudit,
                     authority(Assessment))),
    Expected =
        ground_typed_equality_validation(
            rejected(
                authority_scope_mismatch(
                    expected(
                        equality_id(represented_equal),
                        definition_space_id(other_space),
                        premise_id(adjacent_applications)),
                    found(
                        [equality_id(represented_equal)],
                        [definition_space_id(adjacent_defined)],
                        [premise_id(adjacent_applications)]))),
            ir_audit(ProposalAudit, authority(Assessment))).

authority_variants(scope_premise, Specification, Program, Authority,
                   Expected) :-
    canonical_pair(Specification0, Program0, Authority, Expected0),
    Specification0 =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            Binding,
            Definedness,
            _SpecPremises),
    Program0 =
        program_proposal(
            ProgramId,
            Signature,
            ProgramAst,
            ProgramDefinedness,
            _ProgramPremises),
    Premises = premises([premise_id(other_premise)]),
    Specification =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            Binding,
            Definedness,
            Premises),
    Program =
        program_proposal(
            ProgramId,
            Signature,
            ProgramAst,
            ProgramDefinedness,
            Premises),
    Expected0 =
        ground_typed_equality_validation(
            accepted(_),
            ir_audit(_CanonicalProposalAudit,
                     authority(Assessment))),
    ProposalAudit =
        proposal(
            pair(
                SpecificationId,
                ProgramId,
                premise_id(other_premise))),
    Expected =
        ground_typed_equality_validation(
            rejected(
                authority_scope_mismatch(
                    expected(
                        equality_id(represented_equal),
                        definition_space_id(adjacent_defined),
                        premise_id(other_premise)),
                    found(
                        [equality_id(represented_equal)],
                        [definition_space_id(adjacent_defined)],
                        [premise_id(adjacent_applications)]))),
            ir_audit(ProposalAudit, authority(Assessment))).

boundary_terms(identifier_64, Identifier) :-
    atom_concat(
        'iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii',
        'iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii',
        Identifier).

boundary_terms(identifier_65, Identifier) :-
    boundary_terms(identifier_64, Identifier64),
    atom_concat(Identifier64, i, Identifier).

boundary_terms(identifier_1, i).

boundary_terms(identifier_66, Identifier) :-
    boundary_terms(identifier_65, Identifier65),
    atom_concat(Identifier65, i, Identifier).

boundary_terms(value_128, Value) :-
    atom_concat(
        'vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv',
        'vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv',
        Value).

boundary_terms(value_129, Value) :-
    boundary_terms(value_128, Value128),
    atom_concat(Value128, v, Value).

boundary_terms(value_1, v).

boundary_terms(value_130, Value) :-
    boundary_terms(value_129, Value129),
    atom_concat(Value129, v, Value).

boundary_terms(goal_chain(Count), Term) :-
    boundary_terms(goal_chain(Count, leaf), Term).

boundary_terms(goal_chain(Count, Tail), Term) :-
    (   Count =:= 0
    ->  Term = Tail
    ;   Next is Count - 1,
        Term = wrapper(Inner),
        boundary_terms(goal_chain(Next, Tail), Inner)
    ).

boundary_terms(payload_cells(Count), Cells) :-
    (   Count =:= 0
    ->  Cells = []
    ;   Next is Count - 1,
        Cells = [cell|Rest],
        boundary_terms(payload_cells(Next), Rest)
    ).

boundary_terms(payload_arity(Arity), Payload) :-
    boundary_terms(payload_cells(Arity), Arguments),
    compound_name_arguments(Payload, payload, Arguments).

boundary_terms(payload_arity(Arity, Last), Payload) :-
    PrefixArity is Arity - 1,
    boundary_terms(payload_cells(PrefixArity), Prefix),
    append(Prefix, [Last], Arguments),
    compound_name_arguments(Payload, payload, Arguments).

boundary_terms(identifier_64_pair, Specification, Program, Authority,
               Expected) :-
    canonical_pair(Specification0, Program, Authority, Expected0),
    boundary_terms(identifier_64, Identifier),
    Specification0 =
        specification_proposal(
            _SpecificationId,
            TypeDeclarations,
            Binding,
            Definedness,
            Premises),
    Specification =
        specification_proposal(
            specification_id(Identifier),
            TypeDeclarations,
            Binding,
            Definedness,
            Premises),
    Expected0 =
        ground_typed_equality_validation(
            accepted(
                validated_pair(
                    validated_specification(
                        _OldSpecificationId,
                        NominalType,
                        ScopedEquality,
                        DefinitionSpaceId,
                        PremiseId),
                    ValidatedProgram)),
            ir_audit(
                proposal(
                    pair(
                        _OldAuditSpecificationId,
                        AuditProgramId,
                        AuditPremiseId)),
                authority(AuthorityAssessment))),
    Expected =
        ground_typed_equality_validation(
            accepted(
                validated_pair(
                    validated_specification(
                        specification_id(Identifier),
                        NominalType,
                        ScopedEquality,
                        DefinitionSpaceId,
                        PremiseId),
                    ValidatedProgram)),
            ir_audit(
                proposal(
                    pair(
                        specification_id(Identifier),
                        AuditProgramId,
                        AuditPremiseId)),
                authority(AuthorityAssessment))).

boundary_terms(identifier_65_pair, Specification, Program, Authority,
               Expected) :-
    canonical_pair(Specification0, Program, Authority, _),
    boundary_terms(identifier_65, Identifier),
    Specification0 =
        specification_proposal(
            _SpecificationId,
            TypeDeclarations,
            Binding,
            Definedness,
            Premises),
    Specification =
        specification_proposal(
            specification_id(Identifier),
            TypeDeclarations,
            Binding,
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(
                resource_limit_exceeded(
                    specification, identifier_scalar)),
            ir_audit(proposal(no_pair), authority(not_checked))).

boundary_terms(identifier_1_pair, Specification, Program, Authority,
               Expected) :-
    canonical_pair(Specification0, Program, Authority, Expected0),
    boundary_terms(identifier_1, Identifier),
    Specification0 =
        specification_proposal(
            _SpecificationId,
            TypeDeclarations,
            Binding,
            Definedness,
            Premises),
    Specification =
        specification_proposal(
            specification_id(Identifier),
            TypeDeclarations,
            Binding,
            Definedness,
            Premises),
    Expected0 =
        ground_typed_equality_validation(
            accepted(
                validated_pair(
                    validated_specification(
                        _OldSpecificationId,
                        NominalType,
                        ScopedEquality,
                        DefinitionSpaceId,
                        PremiseId),
                    ValidatedProgram)),
            ir_audit(
                proposal(
                    pair(
                        _OldAuditSpecificationId,
                        AuditProgramId,
                        AuditPremiseId)),
                authority(AuthorityAssessment))),
    Expected =
        ground_typed_equality_validation(
            accepted(
                validated_pair(
                    validated_specification(
                        specification_id(Identifier),
                        NominalType,
                        ScopedEquality,
                        DefinitionSpaceId,
                        PremiseId),
                    ValidatedProgram)),
            ir_audit(
                proposal(
                    pair(
                        specification_id(Identifier),
                        AuditProgramId,
                        AuditPremiseId)),
                authority(AuthorityAssessment))).

boundary_terms(identifier_66_pair, Specification, Program, Authority,
               Expected) :-
    canonical_pair(Specification0, Program, Authority, _),
    boundary_terms(identifier_66, Identifier),
    Specification0 =
        specification_proposal(
            _SpecificationId,
            TypeDeclarations,
            Binding,
            Definedness,
            Premises),
    Specification =
        specification_proposal(
            specification_id(Identifier),
            TypeDeclarations,
            Binding,
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(
                resource_limit_exceeded(
                    specification, identifier_scalar)),
            ir_audit(proposal(no_pair), authority(not_checked))).

boundary_terms(value_128_pair, Specification, Program, Authority,
               Expected) :-
    canonical_pair(Specification0, Program, Authority, Expected0),
    boundary_terms(value_128, Value),
    Specification0 =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(
                Binder,
                equality(
                    EqualityId,
                    operands([
                        Reference,
                        object_value(_OldValue, ValueType)
                    ]))),
            Definedness,
            Premises),
    Specification =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(
                Binder,
                equality(
                    EqualityId,
                    operands([
                        Reference,
                        object_value(atom_value(Value), ValueType)
                    ]))),
            Definedness,
            Premises),
    Expected0 =
        ground_typed_equality_validation(
            accepted(
                validated_pair(
                    validated_specification(
                        ValidatedSpecificationId,
                        NominalType,
                        scoped_equality(
                            ValidatedBinder,
                            equality_relation(
                                ValidatedEqualityId,
                                ValidatedReference,
                                object_value(
                                    _OldAtomValue,
                                    ValidatedValueType))),
                        DefinitionSpaceId,
                        PremiseId),
                    ValidatedProgram)),
            Audit),
    Expected =
        ground_typed_equality_validation(
            accepted(
                validated_pair(
                    validated_specification(
                        ValidatedSpecificationId,
                        NominalType,
                        scoped_equality(
                            ValidatedBinder,
                            equality_relation(
                                ValidatedEqualityId,
                                ValidatedReference,
                                object_value(
                                    atom_value(Value),
                                    ValidatedValueType))),
                        DefinitionSpaceId,
                        PremiseId),
                    ValidatedProgram)),
            Audit).

boundary_terms(value_129_pair, Specification, Program, Authority,
               Expected) :-
    canonical_pair(Specification0, Program, Authority, _),
    boundary_terms(value_129, Value),
    Specification0 =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(
                Binder,
                equality(
                    EqualityId,
                    operands([
                        Reference,
                        object_value(_OldValue, ValueType)
                    ]))),
            Definedness,
            Premises),
    Specification =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(
                Binder,
                equality(
                    EqualityId,
                    operands([
                        Reference,
                        object_value(atom_value(Value), ValueType)
                    ]))),
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(
                resource_limit_exceeded(
                    specification, value_scalar)),
            ir_audit(proposal(no_pair), authority(not_checked))).

boundary_terms(value_1_pair, Specification, Program, Authority, Expected) :-
    canonical_pair(Specification0, Program, Authority, Expected0),
    boundary_terms(value_1, Value),
    Specification0 =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(
                Binder,
                equality(
                    EqualityId,
                    operands([
                        Reference,
                        object_value(_OldValue, ValueType)
                    ]))),
            Definedness,
            Premises),
    Specification =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(
                Binder,
                equality(
                    EqualityId,
                    operands([
                        Reference,
                        object_value(atom_value(Value), ValueType)
                    ]))),
            Definedness,
            Premises),
    Expected0 =
        ground_typed_equality_validation(
            accepted(
                validated_pair(
                    validated_specification(
                        ValidatedSpecificationId,
                        NominalType,
                        scoped_equality(
                            ValidatedBinder,
                            equality_relation(
                                ValidatedEqualityId,
                                ValidatedReference,
                                object_value(
                                    _OldAtomValue,
                                    ValidatedValueType))),
                        DefinitionSpaceId,
                        PremiseId),
                    ValidatedProgram)),
            Audit),
    Expected =
        ground_typed_equality_validation(
            accepted(
                validated_pair(
                    validated_specification(
                        ValidatedSpecificationId,
                        NominalType,
                        scoped_equality(
                            ValidatedBinder,
                            equality_relation(
                                ValidatedEqualityId,
                                ValidatedReference,
                                object_value(
                                    atom_value(Value),
                                    ValidatedValueType))),
                        DefinitionSpaceId,
                        PremiseId),
                    ValidatedProgram)),
            Audit).

boundary_terms(value_130_pair, Specification, Program, Authority,
               Expected) :-
    canonical_pair(Specification0, Program, Authority, _),
    boundary_terms(value_130, Value),
    Specification0 =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(
                Binder,
                equality(
                    EqualityId,
                    operands([
                        Reference,
                        object_value(_OldValue, ValueType)
                    ]))),
            Definedness,
            Premises),
    Specification =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(
                Binder,
                equality(
                    EqualityId,
                    operands([
                        Reference,
                        object_value(atom_value(Value), ValueType)
                    ]))),
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(
                resource_limit_exceeded(
                    specification, value_scalar)),
            ir_audit(proposal(no_pair), authority(not_checked))).

boundary_terms(depth_16, Specification, Program, Authority, Expected) :-
    canonical_pair(Specification0, Program, Authority, _),
    boundary_terms(goal_chain(12), Goal),
    Specification0 =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(Binder, _Equality),
            Definedness,
            Premises),
    Specification =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(Binder, call(Goal)),
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(out_of_fragment(raw_host_goal)),
            ir_audit(proposal(no_pair), authority(not_checked))).

boundary_terms(depth_17, Specification, Program, Authority, Expected) :-
    canonical_pair(Specification0, Program, Authority, _),
    boundary_terms(goal_chain(13), Goal),
    Specification0 =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(Binder, _Equality),
            Definedness,
            Premises),
    Specification =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(Binder, call(Goal)),
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(resource_limit_exceeded(specification, depth)),
            ir_audit(proposal(no_pair), authority(not_checked))).

boundary_terms(cells_512, Specification, Program, Authority, Expected) :-
    canonical_pair(Specification0, Program, Authority, _),
    boundary_terms(payload_arity(458), Goal),
    Specification0 =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(Binder, _Equality),
            Definedness,
            Premises),
    Specification =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(Binder, call(Goal)),
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(out_of_fragment(raw_host_goal)),
            ir_audit(proposal(no_pair), authority(not_checked))).

boundary_terms(cells_513, Specification, Program, Authority, Expected) :-
    canonical_pair(Specification0, Program, Authority, _),
    boundary_terms(payload_arity(459), Goal),
    Specification0 =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(Binder, _Equality),
            Definedness,
            Premises),
    Specification =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(Binder, call(Goal)),
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(resource_limit_exceeded(program, cells)),
            ir_audit(proposal(no_pair), authority(not_checked))).

boundary_terms(list_2, Specification, Program, Authority, Expected) :-
    canonical_pair(Specification0, Program, Authority, _),
    Specification0 =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(Binder, _Equality),
            Definedness,
            Premises),
    Specification =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(
                Binder,
                operation_application(
                    operation_id(binary_operation),
                    [left, right])),
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(out_of_fragment(operation_application)),
            ir_audit(proposal(no_pair), authority(not_checked))).

boundary_terms(list_3, Specification, Program, Authority, Expected) :-
    canonical_pair(Specification0, Program, Authority, _),
    Specification0 =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(Binder, _Equality),
            Definedness,
            Premises),
    Specification =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(
                Binder,
                operation_application(
                    operation_id(binary_operation),
                    [left, middle, right])),
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(resource_limit_exceeded(specification, list)),
            ir_audit(proposal(no_pair), authority(not_checked))).

boundary_terms(list_3_types, Specification, Program, Authority, Expected) :-
    canonical_pair(Specification0, Program, Authority, _),
    Specification0 =
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
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(resource_limit_exceeded(specification, list)),
            ir_audit(proposal(no_pair), authority(not_checked))).

boundary_terms(list_3_operands, Specification, Program, Authority,
               Expected) :-
    canonical_pair(Specification0, Program, Authority, _),
    Specification0 =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(
                Binder,
                equality(
                    EqualityId,
                    operands([Reference, Value]))),
            Definedness,
            Premises),
    Specification =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(
                Binder,
                equality(
                    EqualityId,
                    operands([Reference, Value, Reference]))),
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(resource_limit_exceeded(specification, list)),
            ir_audit(proposal(no_pair), authority(not_checked))).

boundary_terms(list_3_premises, Specification, Program, Authority,
               Expected) :-
    canonical_pair(Specification0, Program, Authority, _),
    Specification0 =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            Binding,
            Definedness,
            premises([Premise])),
    Specification =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            Binding,
            Definedness,
            premises([Premise, Premise, Premise])),
    Expected =
        ground_typed_equality_validation(
            rejected(resource_limit_exceeded(specification, list)),
            ir_audit(proposal(no_pair), authority(not_checked))).

boundary_terms(depth_20, Specification, Program, Authority, Expected) :-
    canonical_pair(Specification0, Program, Authority, _),
    boundary_terms(goal_chain(20), Goal),
    Specification0 =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(Binder, _Equality),
            Definedness,
            Premises),
    Specification =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(Binder, call(Goal)),
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(resource_limit_exceeded(specification, depth)),
            ir_audit(proposal(no_pair), authority(not_checked))).

boundary_terms(cells_beyond, Specification, Program, Authority, Expected) :-
    canonical_pair(Specification0, Program, Authority, _),
    boundary_terms(payload_arity(600), Goal),
    Specification0 =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(Binder, _Equality),
            Definedness,
            Premises),
    Specification =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(Binder, call(Goal)),
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(resource_limit_exceeded(specification, cells)),
            ir_audit(proposal(no_pair), authority(not_checked))).

boundary_terms(list_4, Specification, Program, Authority, Expected) :-
    canonical_pair(Specification0, Program, Authority, _),
    Specification0 =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(Binder, _Equality),
            Definedness,
            Premises),
    Specification =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(
                Binder,
                operation_application(
                    operation_id(binary_operation),
                    [first, second, third, fourth])),
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(resource_limit_exceeded(specification, list)),
            ir_audit(proposal(no_pair), authority(not_checked))).

boundary_terms(program_identifier_65_pair,
               Specification, Program, Authority, Expected) :-
    canonical_pair(Specification, Program0, Authority, _),
    boundary_terms(identifier_65, Identifier),
    Program0 =
        program_proposal(
            _ProgramId,
            Signature,
            ProgramAst,
            Definedness,
            Premises),
    Program =
        program_proposal(
            program_id(Identifier),
            Signature,
            ProgramAst,
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(
                resource_limit_exceeded(
                    program, identifier_scalar)),
            ir_audit(proposal(no_pair), authority(not_checked))).

boundary_terms(program_identifier_66_pair,
               Specification, Program, Authority, Expected) :-
    canonical_pair(Specification, Program0, Authority, _),
    boundary_terms(identifier_66, Identifier),
    Program0 =
        program_proposal(
            _ProgramId,
            Signature,
            ProgramAst,
            Definedness,
            Premises),
    Program =
        program_proposal(
            program_id(Identifier),
            Signature,
            ProgramAst,
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(
                resource_limit_exceeded(
                    program, identifier_scalar)),
            ir_audit(proposal(no_pair), authority(not_checked))).

boundary_terms(program_depth_20,
               Specification, Program, Authority, Expected) :-
    canonical_pair(Specification, Program0, Authority, _),
    boundary_terms(goal_chain(20), Goal),
    Program0 =
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
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(resource_limit_exceeded(program, depth)),
            ir_audit(proposal(no_pair), authority(not_checked))).

boundary_terms(program_cells_beyond,
               Specification, Program, Authority, Expected) :-
    canonical_pair(Specification, Program0, Authority, _),
    boundary_terms(payload_arity(600), Goal),
    Program0 =
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
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(resource_limit_exceeded(program, cells)),
            ir_audit(proposal(no_pair), authority(not_checked))).

boundary_terms(program_list_3,
               Specification, Program, Authority, Expected) :-
    canonical_pair(Specification, Program0, Authority, _),
    Program0 =
        program_proposal(
            ProgramId,
            Signature,
            ProgramAst,
            Definedness,
            premises([Premise])),
    Program =
        program_proposal(
            ProgramId,
            Signature,
            ProgramAst,
            Definedness,
            premises([Premise, Premise, Premise])),
    Expected =
        ground_typed_equality_validation(
            rejected(resource_limit_exceeded(program, list)),
            ir_audit(proposal(no_pair), authority(not_checked))).

boundary_terms(resource_priority(spec_identifier_program_depth),
               Specification, Program, Authority, Expected) :-
    boundary_terms(
        identifier_65_pair,
        Specification, _CanonicalProgram, Authority, _),
    boundary_terms(
        program_depth_20,
        _CanonicalSpecification, Program, Authority, Expected).

boundary_terms(resource_priority(spec_list_program_depth),
               Specification, Program, Authority, Expected) :-
    boundary_terms(
        list_3_types,
        Specification, _CanonicalProgram, Authority, _),
    boundary_terms(
        program_depth_20,
        _CanonicalSpecification, Program, Authority, Expected).

boundary_terms(resource_priority(spec_value_program_list),
               Specification, Program, Authority, Expected) :-
    boundary_terms(
        value_129_pair,
        Specification, _CanonicalProgram, Authority, _),
    boundary_terms(
        program_list_3,
        _CanonicalSpecification, Program, Authority, Expected).

boundary_terms(resource_priority(spec_identifier_program_identifier),
               Specification, Program, Authority, Expected) :-
    boundary_terms(
        identifier_65_pair,
        Specification, _CanonicalProgram, Authority, Expected),
    boundary_terms(
        program_identifier_65_pair,
        _CanonicalSpecification, Program, Authority, _).

boundary_terms(resource_priority(spec_depth_program_depth),
               Specification, Program, Authority, Expected) :-
    boundary_terms(
        depth_17,
        Specification, _CanonicalProgram, Authority, Expected),
    boundary_terms(
        program_depth_20,
        _CanonicalSpecification, Program, Authority, _).

boundary_terms(deep_variable(specification, ChainLength),
               Specification, Program, Authority, Expected) :-
    canonical_pair(Specification0, Program, Authority, _),
    boundary_terms(goal_chain(ChainLength, _Variable), Goal),
    Specification0 =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(Binder, _Equality),
            Definedness,
            Premises),
    Specification =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(Binder, call(Goal)),
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(non_ground_input(specification)),
            ir_audit(proposal(no_pair), authority(not_checked))).

boundary_terms(deep_variable(program, ChainLength),
               Specification, Program, Authority, Expected) :-
    canonical_pair(Specification, Program0, Authority, _),
    boundary_terms(goal_chain(ChainLength, _Variable), Goal),
    Program0 =
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
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(non_ground_input(program)),
            ir_audit(proposal(no_pair), authority(not_checked))).

boundary_terms(deep_cycle(specification, ChainLength),
               Specification, Program, Authority, Expected) :-
    canonical_pair(Specification0, Program, Authority, _),
    Cycle = cycle(Cycle),
    boundary_terms(goal_chain(ChainLength, Cycle), Goal),
    Specification0 =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(Binder, _Equality),
            Definedness,
            Premises),
    Specification =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(Binder, call(Goal)),
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(cyclic_input(specification)),
            ir_audit(proposal(no_pair), authority(not_checked))).

boundary_terms(deep_cycle(program, ChainLength),
               Specification, Program, Authority, Expected) :-
    canonical_pair(Specification, Program0, Authority, _),
    Cycle = cycle(Cycle),
    boundary_terms(goal_chain(ChainLength, Cycle), Goal),
    Program0 =
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
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(cyclic_input(program)),
            ir_audit(proposal(no_pair), authority(not_checked))).

boundary_terms(cell_priority(Input, Priority),
               Specification, Program, Authority, Expected) :-
    (   Priority == variable
    ->  Last = _Variable,
        PriorityReason = non_ground_input(Input)
    ;   Priority == cyclic
    ->  Last = cycle(Last),
        PriorityReason = cyclic_input(Input)
    ),
    boundary_terms(payload_arity(459, Last), Goal),
    canonical_pair(Specification0, Program0, Authority, _),
    (   Input == specification
    ->  Specification0 =
            specification_proposal(
                SpecificationId,
                TypeDeclarations,
                binding(Binder, _Equality),
                Definedness,
                Premises),
        Specification =
            specification_proposal(
                SpecificationId,
                TypeDeclarations,
                binding(Binder, call(Goal)),
                Definedness,
                Premises),
        Program = Program0
    ;   Input == program
    ->  Program0 =
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
                Premises),
        Specification = Specification0
    ),
    (   Input == program
    ->  ExpectedReason =
            resource_limit_exceeded(program, cells)
    ;   ExpectedReason = PriorityReason
    ),
    Expected =
        ground_typed_equality_validation(
            rejected(ExpectedReason),
            ir_audit(proposal(no_pair), authority(not_checked))).

boundary_terms(list_priority(Input, Priority),
               Specification, Program, Authority, Expected) :-
    (   Priority == variable
    ->  Last = _Variable,
        PriorityReason = non_ground_input(Input)
    ;   Priority == cyclic
    ->  Last = cycle(Last),
        PriorityReason = cyclic_input(Input)
    ),
    canonical_pair(Specification0, Program0, Authority, _),
    (   Input == specification
    ->  Specification0 =
            specification_proposal(
                SpecificationId,
                type_declarations([Type]),
                Binding,
                Definedness,
                Premises),
        Specification =
            specification_proposal(
                SpecificationId,
                type_declarations([Type, Type, Type, Last]),
                Binding,
                Definedness,
                Premises),
        Program = Program0
    ;   Input == program
    ->  Program0 =
            program_proposal(
                ProgramId,
                Signature,
                ProgramAst,
                Definedness,
                premises([Premise])),
        Program =
            program_proposal(
                ProgramId,
                Signature,
                ProgramAst,
                Definedness,
                premises([Premise, Premise, Premise, Last])),
        Specification = Specification0
    ),
    Expected =
        ground_typed_equality_validation(
            rejected(PriorityReason),
            ir_audit(proposal(no_pair), authority(not_checked))).

boundary_terms(resource_before_program_outcome(Resource, Outcome),
               Specification, Program, Authority, Expected) :-
    (   Resource == identifier_scalar
    ->  boundary_terms(
            identifier_65_pair,
            Specification, Program0, Authority0, ResourceExpected)
    ;   Resource == value_scalar
    ->  boundary_terms(
            value_129_pair,
            Specification, Program0, Authority0, ResourceExpected)
    ;   Resource == list
    ->  boundary_terms(
            list_3_types,
            Specification, Program0, Authority0, ResourceExpected)
    ;   Resource == depth
    ->  boundary_terms(
            depth_17,
            Specification, Program0, Authority0, ResourceExpected)
    ;   Resource == cells
    ->  boundary_terms(
            cells_beyond,
            Specification, Program0, Authority0, ResourceExpected)
    ),
    Program0 =
        program_proposal(
            ProgramId,
            Signature,
            ProgramAst,
            Definedness,
            Premises),
    (   Outcome == variable
    ->  Program =
            program_proposal(
                ProgramId, Signature, ProgramAst,
                Definedness, _Variable),
        Authority = Authority0,
        PriorityExpected =
            ground_typed_equality_validation(
                rejected(non_ground_input(program)),
                ir_audit(proposal(no_pair), authority(not_checked))),
        resource_before_program_expected(
            Resource, ResourceExpected, PriorityExpected, Expected)
    ;   Outcome == cyclic
    ->  Cycle = cycle(Cycle),
        Program =
            program_proposal(
                ProgramId, Signature, ProgramAst,
                Definedness, Cycle),
        Authority = Authority0,
        PriorityExpected =
            ground_typed_equality_validation(
                rejected(cyclic_input(program)),
                ir_audit(proposal(no_pair), authority(not_checked))),
        resource_before_program_expected(
            Resource, ResourceExpected, PriorityExpected, Expected)
    ;   Outcome == malformed
    ->  Program =
            program_proposal(
                ProgramId, malformed_signature, ProgramAst,
                Definedness, Premises),
        Authority = Authority0,
        PriorityExpected =
            ground_typed_equality_validation(
                rejected(malformed_shape(program, signature)),
                ir_audit(proposal(no_pair), authority(not_checked))),
        resource_before_program_expected(
            Resource, ResourceExpected, PriorityExpected, Expected)
    ;   Outcome == unsupported
    ->  ProgramAst = program_ast(Binder, _Expression),
        Program =
            program_proposal(
                ProgramId, Signature,
                program_ast(Binder, call(leaf)),
                Definedness, Premises),
        Authority = Authority0,
        Expected = ResourceExpected
    ;   Outcome == semantic
    ->  Program =
            program_proposal(
                ProgramId, Signature, ProgramAst,
                definedness(missing), Premises),
        Authority = Authority0,
        Expected = ResourceExpected
    ;   Outcome == inactive
    ->  authority_variants(
            inactive, _CanonicalSpecification, _CanonicalProgram,
            Authority, _InactiveExpected),
        Program = Program0,
        Expected = ResourceExpected
    ;   Outcome == unknown
    ->  authority_variants(
            missing_activation,
            _CanonicalSpecification, _CanonicalProgram,
            Authority, _UnknownExpected),
        Program = Program0,
        Expected = ResourceExpected
    ;   Outcome == untrusted
    ->  authority_variants(
            untrusted, _CanonicalSpecification, _CanonicalProgram,
            Authority, _UntrustedExpected),
        Program = Program0,
        Expected = ResourceExpected
    ).

boundary_terms(program_resource_before_specification_outcome(
                   Resource, Outcome),
               Specification, Program, Authority, Expected) :-
    (   Resource == identifier_scalar
    ->  boundary_terms(
            program_identifier_65_pair,
            Specification0, Program, Authority, ResourceExpected)
    ;   Resource == list
    ->  boundary_terms(
            program_list_3,
            Specification0, Program, Authority, ResourceExpected)
    ;   Resource == depth
    ->  boundary_terms(
            program_depth_20,
            Specification0, Program, Authority, ResourceExpected)
    ;   Resource == cells
    ->  boundary_terms(
            program_cells_beyond,
            Specification0, Program, Authority, ResourceExpected)
    ),
    Specification0 =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            Binding,
            Definedness,
            Premises),
    (   Outcome == variable
    ->  Specification =
            specification_proposal(
                SpecificationId, TypeDeclarations, Binding,
                Definedness, _Variable),
        Expected =
            ground_typed_equality_validation(
                rejected(non_ground_input(specification)),
                ir_audit(proposal(no_pair), authority(not_checked)))
    ;   Outcome == cyclic
    ->  Cycle = cycle(Cycle),
        Specification =
            specification_proposal(
                SpecificationId, TypeDeclarations, Binding,
                Definedness, Cycle),
        Expected =
            ground_typed_equality_validation(
                rejected(cyclic_input(specification)),
                ir_audit(proposal(no_pair), authority(not_checked)))
    ;   Outcome == malformed
    ->  Specification =
            specification_proposal(
                SpecificationId, malformed_type_declarations, Binding,
                Definedness, Premises),
        Expected =
            ground_typed_equality_validation(
                rejected(
                    malformed_shape(
                        specification, type_declarations)),
                ir_audit(proposal(no_pair), authority(not_checked)))
    ;   Outcome == unsupported
    ->  Binding = binding(Binder, _Equality),
        Specification =
            specification_proposal(
                SpecificationId, TypeDeclarations,
                binding(Binder, call(leaf)),
                Definedness, Premises),
        Expected = ResourceExpected
    ;   Outcome == semantic
    ->  Specification =
            specification_proposal(
                SpecificationId, TypeDeclarations, Binding,
                definedness(missing), Premises),
        Expected = ResourceExpected
    ).

boundary_terms(resource_before_authority_scope_mismatch,
               Specification, Program, Authority, Expected) :-
    boundary_terms(
        identifier_65_pair,
        Specification0, Program, Authority, Expected),
    Specification0 =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(
                Binder,
                equality(_EqualityId, Operands)),
            Definedness,
            Premises),
    Specification =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(
                Binder,
                equality(equality_id(other_equality), Operands)),
            Definedness,
            Premises).

boundary_terms(early_excess_late_program_variable, Specification, Program,
               Authority, Expected) :-
    boundary_terms(identifier_65_pair, Specification, Program0, Authority, _),
    Program0 =
        program_proposal(
            ProgramId,
            Signature,
            program_ast(Binder, _Reference),
            Definedness,
            Premises),
    Program =
        program_proposal(
            ProgramId,
            Signature,
            program_ast(
                Binder,
                object_reference(
                    binder_id(program_object), _Variable)),
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(non_ground_input(program)),
            ir_audit(proposal(no_pair), authority(not_checked))).

boundary_terms(early_excess_late_program_shape, Specification, Program,
               Authority, Expected) :-
    boundary_terms(identifier_65_pair, Specification, Program0, Authority, _),
    Program0 =
        program_proposal(
            ProgramId,
            _Signature,
            ProgramAst,
            Definedness,
            Premises),
    Program =
        program_proposal(
            ProgramId,
            signature(not_input, not_output),
            ProgramAst,
            Definedness,
            Premises),
    Expected =
        ground_typed_equality_validation(
            rejected(malformed_shape(program, signature)),
            ir_audit(proposal(no_pair), authority(not_checked))).

resource_before_program_expected(
    cells, ResourceExpected, _PriorityExpected, ResourceExpected) :-
    !.
resource_before_program_expected(
    _Resource, _ResourceExpected, PriorityExpected, PriorityExpected).

fixture_pair_visits(Specification, Program, Visits) :-
    fixture_term_visits(
        Specification, specification, [], [], 0, SpecificationCells,
        Visits, ProgramVisits),
    fixture_term_visits(
        Program, program, [], [], SpecificationCells, _PairCells,
        ProgramVisits, []).

fixture_term_visits(Term, Input, Path, Ancestors, Cells0, Cells,
                    [fixture_visit(Input, Path, Kind, Cell)|Visits0],
                    Visits) :-
    Cell is Cells0 + 1,
    fixture_term_kind(Term, Ancestors, Kind),
    fixture_kind_visits(
        Kind, Term, Input, Path, Ancestors, Cell, Cells,
        Visits0, Visits).

fixture_term_kind(Term, _Ancestors, attributed_variable) :-
    attvar(Term),
    !.
fixture_term_kind(Term, _Ancestors, variable) :-
    var(Term),
    !.
fixture_term_kind(Term, _Ancestors, atomic) :-
    atomic(Term),
    !.
fixture_term_kind(Term, Ancestors, ancestor_back_edge) :-
    fixture_identity_member(Term, Ancestors),
    !.
fixture_term_kind(Term, _Ancestors, compound(Arity)) :-
    functor(Term, _Name, Arity).

fixture_kind_visits(attributed_variable, _Term, _Input, _Path, _Ancestors,
                    Cells, Cells, Visits, Visits) :-
    !.
fixture_kind_visits(variable, _Term, _Input, _Path, _Ancestors,
                    Cells, Cells, Visits, Visits) :-
    !.
fixture_kind_visits(atomic, _Term, _Input, _Path, _Ancestors,
                    Cells, Cells, Visits, Visits) :-
    !.
fixture_kind_visits(ancestor_back_edge, _Term, _Input, _Path, _Ancestors,
                    Cells, Cells, Visits, Visits) :-
    !.
fixture_kind_visits(compound(Arity), Term, Input, Path, Ancestors,
                    Cells0, Cells, Visits0, Visits) :-
    fixture_argument_visits(
        1, Arity, Term, Input, Path, [Term|Ancestors],
        Cells0, Cells, Visits0, Visits).

fixture_argument_visits(Index, Arity, _Term, _Input, _Path, _Ancestors,
                        Cells, Cells, Visits, Visits) :-
    Index > Arity,
    !.
fixture_argument_visits(Index, Arity, Term, Input, Path, Ancestors,
                        Cells0, Cells, Visits0, Visits) :-
    arg(Index, Term, Argument),
    append(Path, [Index], ArgumentPath),
    fixture_term_visits(
        Argument, Input, ArgumentPath, Ancestors, Cells0, Cells1,
        Visits0, Visits1),
    NextIndex is Index + 1,
    fixture_argument_visits(
        NextIndex, Arity, Term, Input, Path, Ancestors,
        Cells1, Cells, Visits1, Visits).

fixture_identity_member(Term, [Ancestor|_Rest]) :-
    Term == Ancestor,
    !.
fixture_identity_member(Term, [_Ancestor|Rest]) :-
    fixture_identity_member(Term, Rest).

fixture_visit_position(Specification, Program, Input, Path, Position) :-
    fixture_pair_visits(Specification, Program, Visits),
    memberchk(fixture_visit(Input, Path, _Kind, Position), Visits).

fixture_visit_input(Specification, Program, Position, Input) :-
    fixture_pair_visits(Specification, Program, Visits),
    memberchk(fixture_visit(Input, _Path, _Kind, Position), Visits).

shared_case_exhaustion_input(
    Position, _Specification, _Program, Input, Input) :-
    Position =< 512,
    !.
shared_case_exhaustion_input(
    _Position, Specification, Program, _Input, ExhaustionInput) :-
    fixture_visit_input(
        Specification, Program, 513, ExhaustionInput).

shared_replace_field(1, Replacement, [_Old|Fields],
                     [Replacement|Fields]) :-
    !.
shared_replace_field(Index, Replacement, [Field|Fields],
                     [Field|Replaced]) :-
    NextIndex is Index - 1,
    shared_replace_field(NextIndex, Replacement, Fields, Replaced).

shared_padded_specification(Arity, Specification0, Specification) :-
    boundary_terms(payload_arity(Arity), Payload),
    Specification0 =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(Binder, _Equality),
            Definedness,
            Premises),
    Specification =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(Binder, call(Payload)),
            Definedness,
            Premises).

shared_program_variable_field(1, Marker, program_id(Marker), [1]).
shared_program_variable_field(
    2, Marker,
    signature(
        input(type_id(Marker)),
        output(type_id(element))),
    [1, 1, 1]).
shared_program_variable_field(
    3, Marker,
    program_ast(
        object_binder(
            binder_id(program_object), type_id(element)),
        object_reference(
            binder_id(program_object), type_id(Marker))),
    [2, 2, 1]).
shared_program_variable_field(
    4, Marker,
    definedness(definition_space_id(Marker)),
    [1, 1]).
shared_program_variable_field(
    5, Marker,
    premises([premise_id(Marker)]),
    [1, 1, 1]).

shared_program_cycle_field(1, Marker, Marker, [1]) :-
    Marker = program_id(Marker).
shared_program_cycle_field(
    2, Marker, Marker, [2, 1]) :-
    Marker =
        signature(
            input(type_id(element)),
            output(Marker)).
shared_program_cycle_field(
    3, Marker, Marker, [2, 2]) :-
    Marker =
        program_ast(
            object_binder(
                binder_id(program_object), type_id(element)),
            object_reference(
                binder_id(program_object), Marker)).
shared_program_cycle_field(4, Marker, Marker, [1]) :-
    Marker = definedness(Marker).
shared_program_cycle_field(
    5, Marker, premises(List), [1, 2]) :-
    List = [premise_id(adjacent_applications)|List],
    Marker = List.

shared_program_field_marker(
    Index, variable, _Original, Field, Suffix, Marker) :-
    shared_program_variable_field(Index, Marker, Field, Suffix).
shared_program_field_marker(
    Index, attributed, _Original, Field, Suffix, Marker) :-
    shared_program_variable_field(Index, Marker, Field, Suffix),
    put_attr(
        Marker, cps_ground_typed_equality_ir, shared_prefix_marker).
shared_program_field_marker(
    Index, cyclic, _Original, Field, Suffix, Marker) :-
    shared_program_cycle_field(Index, Marker, Field, Suffix).
shared_program_field_marker(
    _Index, malformed, _Original, malformed_shared_prefix, [], Marker) :-
    Marker = malformed_shared_prefix.

shared_program_field_name(1, identifier).
shared_program_field_name(2, signature).
shared_program_field_name(3, program_ast).
shared_program_field_name(4, definedness).
shared_program_field_name(5, premises).

shared_program_field_case(Arity, Index, MarkerKind,
                          Specification, Program, Authority,
                          TargetPath, Marker) :-
    canonical_pair(Specification0, Program0, Authority, _),
    shared_padded_specification(Arity, Specification0, Specification),
    compound_name_arguments(Program0, program_proposal, Fields0),
    nth1(Index, Fields0, OriginalField),
    shared_program_field_marker(
        Index, MarkerKind, OriginalField, Field, Suffix, Marker),
    shared_replace_field(Index, Field, Fields0, Fields),
    compound_name_arguments(Program, program_proposal, Fields),
    TargetPath = [Index|Suffix].

shared_positioned_program_field(
    Position, Index, MarkerKind,
    Specification, Program, Authority, Expected, TargetPath, Marker) :-
    shared_program_field_case(
        1, Index, MarkerKind,
        BaseSpecification, BaseProgram, _BaseAuthority,
        BaseTargetPath, _BaseMarker),
    fixture_visit_position(
        BaseSpecification, BaseProgram, program, BaseTargetPath,
        BasePosition),
    Arity is Position - BasePosition + 1,
    Arity > 0,
    shared_program_field_case(
        Arity, Index, MarkerKind,
        Specification, Program, Authority, TargetPath, Marker),
    fixture_visit_position(
        Specification, Program, program, TargetPath, Position),
    shared_case_exhaustion_input(
        Position, Specification, Program, program, ExhaustionInput),
    shared_program_field_name(Index, FieldName),
    shared_prefix_expected(
        Position, program, ExhaustionInput,
        MarkerKind, FieldName, Expected).

shared_specification_variable_field(
    4, Marker,
    definedness(definition_space_id(Marker)),
    [1, 1]).
shared_specification_variable_field(
    5, Marker,
    premises([premise_id(Marker)]),
    [1, 1, 1]).

shared_specification_cycle_field(4, Marker, Marker, [1]) :-
    Marker = definedness(Marker).
shared_specification_cycle_field(
    5, Marker, premises(List), [1, 2]) :-
    List = [premise_id(adjacent_applications)|List],
    Marker = List.

shared_specification_field_marker(
    Index, variable, _Original, Field, Suffix, Marker) :-
    shared_specification_variable_field(
        Index, Marker, Field, Suffix).
shared_specification_field_marker(
    Index, attributed, _Original, Field, Suffix, Marker) :-
    shared_specification_variable_field(
        Index, Marker, Field, Suffix),
    put_attr(
        Marker, cps_ground_typed_equality_ir, shared_prefix_marker).
shared_specification_field_marker(
    Index, cyclic, _Original, Field, Suffix, Marker) :-
    shared_specification_cycle_field(Index, Marker, Field, Suffix).
shared_specification_field_marker(
    _Index, malformed, _Original, malformed_shared_prefix, [], Marker) :-
    Marker = malformed_shared_prefix.

shared_specification_field_name(4, definedness).
shared_specification_field_name(5, premises).

shared_specification_field_case(
    Arity, Index, MarkerKind,
    Specification, Program, Authority, TargetPath, Marker) :-
    canonical_pair(Specification0, Program, Authority, _),
    shared_padded_specification(Arity, Specification0, Padded),
    compound_name_arguments(
        Padded, specification_proposal, Fields0),
    nth1(Index, Fields0, OriginalField),
    shared_specification_field_marker(
        Index, MarkerKind, OriginalField, Field, Suffix, Marker),
    shared_replace_field(Index, Field, Fields0, Fields),
    compound_name_arguments(
        Specification, specification_proposal, Fields),
    TargetPath = [Index|Suffix].

shared_positioned_specification_field(
    Position, Index, MarkerKind,
    Specification, Program, Authority, Expected, TargetPath, Marker) :-
    shared_specification_field_case(
        1, Index, MarkerKind,
        BaseSpecification, BaseProgram, _BaseAuthority,
        BaseTargetPath, _BaseMarker),
    fixture_visit_position(
        BaseSpecification, BaseProgram, specification, BaseTargetPath,
        BasePosition),
    Arity is Position - BasePosition + 1,
    Arity > 0,
    shared_specification_field_case(
        Arity, Index, MarkerKind,
        Specification, Program, Authority, TargetPath, Marker),
    fixture_visit_position(
        Specification, Program, specification, TargetPath, Position),
    shared_case_exhaustion_input(
        Position, Specification, Program,
        specification, ExhaustionInput),
    shared_specification_field_name(Index, FieldName),
    shared_prefix_expected(
        Position, specification, ExhaustionInput,
        MarkerKind, FieldName, Expected).

shared_expression_marker(variable, Marker, []) :-
    var(Marker).
shared_expression_marker(attributed, Marker, []) :-
    put_attr(
        Marker, cps_ground_typed_equality_ir, shared_prefix_marker).
shared_expression_marker(cyclic, Marker, [1]) :-
    Marker = cycle(Marker).

shared_specification_expression_case(
    Arity, MarkerKind,
    Specification, Program, Authority, TargetPath, Marker) :-
    shared_expression_marker(MarkerKind, Marker, Suffix),
    boundary_terms(payload_arity(Arity, Marker), Payload),
    canonical_pair(Specification0, Program, Authority, _),
    Specification0 =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(Binder, _Equality),
            Definedness,
            Premises),
    Specification =
        specification_proposal(
            SpecificationId,
            TypeDeclarations,
            binding(Binder, call(Payload)),
            Definedness,
            Premises),
    append([3, 2, 1, Arity], Suffix, TargetPath).

shared_positioned_specification_expression(
    Position, MarkerKind,
    Specification, Program, Authority, Expected, TargetPath, Marker) :-
    shared_specification_expression_case(
        1, MarkerKind,
        BaseSpecification, BaseProgram, _BaseAuthority,
        BaseTargetPath, _BaseMarker),
    fixture_visit_position(
        BaseSpecification, BaseProgram, specification, BaseTargetPath,
        BasePosition),
    Arity is Position - BasePosition + 1,
    Arity > 0,
    shared_specification_expression_case(
        Arity, MarkerKind,
        Specification, Program, Authority, TargetPath, Marker),
    fixture_visit_position(
        Specification, Program, specification, TargetPath, Position),
    shared_case_exhaustion_input(
        Position, Specification, Program,
        specification, ExhaustionInput),
    shared_prefix_expected(
        Position, specification, ExhaustionInput,
        MarkerKind, expression, Expected).

shared_prefix_expected(
    Position, Input, ExhaustionInput, MarkerKind, FieldName,
    ground_typed_equality_validation(
        rejected(Reason),
        ir_audit(proposal(no_pair), authority(not_checked)))) :-
    (   Position =< 512
    ->  shared_prefix_reason(
            Input, MarkerKind, FieldName, Reason)
    ;   Reason = resource_limit_exceeded(ExhaustionInput, cells)
    ).

shared_program_boundary_case(
    Arity, Specification, Program, Authority, [1, 1]) :-
    canonical_pair(Specification0, Program, Authority, _),
    shared_padded_specification(
        Arity, Specification0, Specification).

shared_positioned_program_boundary(
    Position, Specification, Program, Authority, TargetPath) :-
    shared_program_boundary_case(
        1, BaseSpecification, BaseProgram, _BaseAuthority,
        BaseTargetPath),
    fixture_visit_position(
        BaseSpecification, BaseProgram, program, BaseTargetPath,
        BasePosition),
    Arity is Position - BasePosition + 1,
    Arity > 0,
    shared_program_boundary_case(
        Arity, Specification, Program, Authority, TargetPath),
    fixture_visit_position(
        Specification, Program, program, TargetPath, Position).

shared_prefix_reason(Input, variable, _Field,
                     non_ground_input(Input)).
shared_prefix_reason(Input, attributed, _Field,
                     non_ground_input(Input)).
shared_prefix_reason(Input, cyclic, _Field,
                     cyclic_input(Input)).
shared_prefix_reason(Input, malformed, Field,
                     malformed_shape(Input, Field)).

shared_marker_preserved(variable, Marker) :-
    var(Marker).
shared_marker_preserved(attributed, Marker) :-
    var(Marker),
    get_attr(
        Marker, cps_ground_typed_equality_ir, shared_prefix_marker).
shared_marker_preserved(cyclic, Marker) :-
    cyclic_term(Marker).
shared_marker_preserved(malformed, Marker) :-
    Marker == malformed_shared_prefix.

shared_assert_prefix_case(
    Input, Position, TargetPath, MarkerKind, Marker,
    Specification, Program, Authority, Expected) :-
    fixture_visit_position(
        Specification, Program, Input, TargetPath, ActualPosition),
    assertion(ActualPosition =:= Position),
    term_variables(
        Specification-Program-Authority, VariablesBefore),
    findall(
        Validation,
        validate_ground_typed_equality_pair(
            Specification, Program, Authority, Validation),
        Solutions),
    term_variables(
        Specification-Program-Authority, VariablesAfter),
    assertion(Solutions == [Expected]),
    assertion(ground(Solutions)),
    assertion(acyclic_term(Solutions)),
    assertion(VariablesAfter == VariablesBefore),
    shared_marker_preserved(MarkerKind, Marker).

shared_later_outcome(accepted, Program, Authority, Program, Authority) :-
    canonical_pair(
        _Specification, _CanonicalProgram, Authority, _).
shared_later_outcome(unsupported, Program0, Authority, Program, Authority) :-
    canonical_pair(
        _Specification, _CanonicalProgram, Authority, _),
    Program0 =
        program_proposal(
            ProgramId, Signature,
            program_ast(Binder, _Expression),
            Definedness, Premises),
    Program =
        program_proposal(
            ProgramId, Signature,
            program_ast(Binder, call(leaf)),
            Definedness, Premises).
shared_later_outcome(semantic, Program0, Authority, Program, Authority) :-
    canonical_pair(
        _Specification, _CanonicalProgram, Authority, _),
    Program0 =
        program_proposal(
            ProgramId, Signature, ProgramAst, _Definedness, Premises),
    Program =
        program_proposal(
            ProgramId, Signature, ProgramAst,
            definedness(missing), Premises).
shared_later_outcome(inactive, Program, Authority, Program, Authority) :-
    authority_variants(
        inactive, _Specification, _CanonicalProgram, Authority, _).
shared_later_outcome(unknown, Program, Authority, Program, Authority) :-
    authority_variants(
        missing_activation,
        _Specification, _CanonicalProgram, Authority, _).
shared_later_outcome(rejected, Program, Authority, Program, Authority) :-
    authority_variants(
        untrusted, _Specification, _CanonicalProgram, Authority, _).
shared_later_outcome(nonground_authority, Program, Authority,
                     Program, Authority) :-
    var(Authority).

test(canonical_active_trusted_pair_round_trip_is_exact) :-
    canonical_pair(Specification, Program, Authority, Expected),
    validate_ground_typed_equality_pair(
        Specification, Program, Authority, Validation),
    assertion(Validation == Expected).

test(proposal_and_validated_shapes_are_distinct) :-
    canonical_pair(Specification, Program, Authority, Expected),
    validate_ground_typed_equality_pair(
        Specification, Program, Authority, Validation),
    assertion(Validation == Expected),
    functor(Specification, specification_proposal, 5),
    functor(Program, program_proposal, 5),
    Validation =
        ground_typed_equality_validation(
            accepted(validated_pair(ValidatedSpecification,
                                    ValidatedProgram)),
            _),
    functor(ValidatedSpecification, validated_specification, 5),
    functor(ValidatedProgram, validated_program, 5),
    assertion(Specification \== ValidatedSpecification),
    assertion(Program \== ValidatedProgram).

test(public_call_has_one_ground_solution) :-
    canonical_pair(Specification, Program, Authority, Expected),
    findall(
        Validation,
        validate_ground_typed_equality_pair(
            Specification, Program, Authority, Validation),
        Solutions),
    assertion(Solutions == [Expected]),
    assertion(ground(Solutions)),
    assertion(acyclic_term(Solutions)),
    forall(
        member(
            Case,
            [ deep_variable(specification, 20),
              deep_variable(program, 20),
              deep_cycle(specification, 20),
              deep_cycle(program, 20),
              cells_beyond,
              program_cells_beyond
            ]),
        ( boundary_terms(
              Case,
              CaseSpecification, CaseProgram, Authority, CaseExpected),
          findall(
              CaseValidation,
              validate_ground_typed_equality_pair(
                  CaseSpecification, CaseProgram, Authority,
                  CaseValidation),
              CaseSolutions),
          assertion(CaseSolutions == [CaseExpected]),
          assertion(ground(CaseSolutions)),
          assertion(acyclic_term(CaseSolutions))
        )).

test(result_and_audit_shapes_are_exact) :-
    canonical_pair(Specification, Program, Authority, Accepted),
    validate_ground_typed_equality_pair(
        Specification, Program, Authority, AcceptedActual),
    assertion(AcceptedActual == Accepted),
    shape_variants(
        type_declarations, MalformedSpecification, Program,
        Authority, MalformedExpected),
    validate_ground_typed_equality_pair(
        MalformedSpecification, Program, Authority, MalformedActual),
    assertion(MalformedActual == MalformedExpected),
    shape_variants(
        missing_equality, MissingSpecification, Program,
        Authority, MissingExpected),
    validate_ground_typed_equality_pair(
        MissingSpecification, Program, Authority, MissingActual),
    assertion(MissingActual == MissingExpected).

test(free_specification_reference_is_rejected) :-
    scope_variants(
        free_specification, Specification, Program, Authority, Expected),
    validate_ground_typed_equality_pair(
        Specification, Program, Authority, Actual),
    assertion(Actual == Expected).

test(duplicate_specification_reference_is_rejected) :-
    scope_variants(
        duplicate_specification, Specification, Program, Authority,
        Expected),
    validate_ground_typed_equality_pair(
        Specification, Program, Authority, Actual),
    assertion(Actual == Expected),
    scope_variants(
        two_values, TwoValueSpecification, Program, Authority,
        TwoValueExpected),
    validate_ground_typed_equality_pair(
        TwoValueSpecification, Program, Authority, TwoValueActual),
    assertion(TwoValueActual == TwoValueExpected).

test(free_program_reference_is_rejected) :-
    scope_variants(
        free_program, Specification, Program, Authority, Expected),
    validate_ground_typed_equality_pair(
        Specification, Program, Authority, Actual),
    assertion(Actual == Expected).

test(binder_type_mismatch_is_rejected) :-
    type_variants(
        specification_binder, Specification, Program, Authority,
        Expected),
    validate_ground_typed_equality_pair(
        Specification, Program, Authority, Actual),
    assertion(Actual == Expected),
    type_variants(
        program_binder, CanonicalSpecification, BadProgram,
        Authority, ProgramExpected),
    validate_ground_typed_equality_pair(
        CanonicalSpecification, BadProgram, Authority, ProgramActual),
    assertion(ProgramActual == ProgramExpected).

test(equality_operand_type_mismatch_is_rejected) :-
    type_variants(
        equality_value, Specification, Program, Authority, Expected),
    validate_ground_typed_equality_pair(
        Specification, Program, Authority, Actual),
    assertion(Actual == Expected),
    type_variants(
        program_reference, CanonicalSpecification, BadProgram,
        Authority, ReferenceExpected),
    validate_ground_typed_equality_pair(
        CanonicalSpecification, BadProgram, Authority, ReferenceActual),
    assertion(ReferenceActual == ReferenceExpected).

test(missing_equality_is_rejected) :-
    shape_variants(
        missing_equality, Specification, Program, Authority, Expected),
    validate_ground_typed_equality_pair(
        Specification, Program, Authority, Actual),
    assertion(Actual == Expected).

test(missing_specification_definedness_is_rejected) :-
    shape_variants(
        missing_specification_definedness,
        Specification, Program, Authority, Expected),
    validate_ground_typed_equality_pair(
        Specification, Program, Authority, Actual),
    assertion(Actual == Expected).

test(missing_program_definedness_is_rejected) :-
    shape_variants(
        missing_program_definedness,
        Specification, Program, Authority, Expected),
    validate_ground_typed_equality_pair(
        Specification, Program, Authority, Actual),
    assertion(Actual == Expected).

test(specification_program_type_mismatch_is_rejected) :-
    type_variants(
        cross_proposal, Specification, Program, Authority, Expected),
    validate_ground_typed_equality_pair(
        Specification, Program, Authority, Actual),
    assertion(Actual == Expected).

test(definition_space_mismatch_is_rejected) :-
    type_variants(
        definition_space, Specification, Program, Authority, Expected),
    validate_ground_typed_equality_pair(
        Specification, Program, Authority, Actual),
    assertion(Actual == Expected).

test(premise_mismatch_is_rejected) :-
    type_variants(
        premise, Specification, Program, Authority, Expected),
    validate_ground_typed_equality_pair(
        Specification, Program, Authority, Actual),
    assertion(Actual == Expected).

test(malformed_roots_are_rejected) :-
    canonical_pair(Specification, Program, Authority, _),
    validate_ground_typed_equality_pair(
        not_a_specification, Program, Authority, WrongSpecification),
    assertion(
        WrongSpecification ==
        ground_typed_equality_validation(
            rejected(malformed_shape(specification, root)),
            ir_audit(proposal(no_pair), authority(not_checked)))),
    validate_ground_typed_equality_pair(
        Specification, not_a_program, Authority, WrongProgram),
    assertion(
        WrongProgram ==
        ground_typed_equality_validation(
            rejected(malformed_shape(program, root)),
            ir_audit(proposal(no_pair), authority(not_checked)))),
    shape_variants(
        forged_program,
        Specification, ForgedProgram, Authority, ForgedProgramExpected),
    validate_ground_typed_equality_pair(
        wrong_specification, ForgedProgram, Authority,
        ForgedBeforeWrongRoot),
    assertion(ForgedBeforeWrongRoot == ForgedProgramExpected),
    shape_variants(
        forged_specification,
        ForgedSpecification, Program, Authority,
        ForgedSpecificationExpected),
    validate_ground_typed_equality_pair(
        ForgedSpecification, wrong_program, Authority,
        ForgedSpecificationBeforeWrongRoot),
    assertion(
        ForgedSpecificationBeforeWrongRoot ==
        ForgedSpecificationExpected),
    validate_ground_typed_equality_pair(
        VariableSpecification, ForgedProgram, Authority,
        VariableBeforeForged),
    assertion(
        VariableBeforeForged ==
        ground_typed_equality_validation(
            rejected(non_ground_input(specification)),
            ir_audit(proposal(no_pair), authority(not_checked)))),
    assertion(var(VariableSpecification)),
    validate_ground_typed_equality_pair(
        ForgedSpecification, VariableProgram, Authority,
        ProgramVariableBeforeForged),
    assertion(
        ProgramVariableBeforeForged ==
        ground_typed_equality_validation(
            rejected(non_ground_input(program)),
            ir_audit(proposal(no_pair), authority(not_checked)))),
    assertion(var(VariableProgram)).

test(malformed_nested_fields_are_rejected) :-
    shape_variants(
        type_declarations, Specification, Program, Authority, Expected),
    validate_ground_typed_equality_pair(
        Specification, Program, Authority, Actual),
    assertion(Actual == Expected),
    shape_variants(
        binder, BinderSpecification, Program, Authority, BinderExpected),
    validate_ground_typed_equality_pair(
        BinderSpecification, Program, Authority, BinderActual),
    assertion(BinderActual == BinderExpected),
    shape_variants(
        equality, EqualitySpecification, Program, Authority,
        EqualityExpected),
    validate_ground_typed_equality_pair(
        EqualitySpecification, Program, Authority, EqualityActual),
    assertion(EqualityActual == EqualityExpected),
    shape_variants(
        operands, OperandsSpecification, Program, Authority,
        OperandsExpected),
    validate_ground_typed_equality_pair(
        OperandsSpecification, Program, Authority, OperandsActual),
    assertion(OperandsActual == OperandsExpected),
    shape_variants(
        program_signature, CanonicalSpecification, SignatureProgram,
        Authority, SignatureExpected),
    validate_ground_typed_equality_pair(
        CanonicalSpecification, SignatureProgram, Authority,
        SignatureActual),
    assertion(SignatureActual == SignatureExpected),
    shape_variants(
        program_ast, CanonicalSpecification, AstProgram,
        Authority, AstExpected),
    validate_ground_typed_equality_pair(
        CanonicalSpecification, AstProgram, Authority, AstActual),
    assertion(AstActual == AstExpected),
    shape_variants(
        over_limit_malformed_types,
        MalformedTypesSpecification, Program, Authority,
        MalformedTypesExpected),
    validate_ground_typed_equality_pair(
        MalformedTypesSpecification, Program, Authority,
        MalformedTypesActual),
    assertion(MalformedTypesActual == MalformedTypesExpected),
    shape_variants(
        over_limit_malformed_operands,
        MalformedOperandsSpecification, Program, Authority,
        MalformedOperandsExpected),
    validate_ground_typed_equality_pair(
        MalformedOperandsSpecification, Program, Authority,
        MalformedOperandsActual),
    assertion(MalformedOperandsActual == MalformedOperandsExpected),
    shape_variants(
        over_limit_malformed_premises,
        MalformedPremisesSpecification, Program, Authority,
        MalformedPremisesExpected),
    validate_ground_typed_equality_pair(
        MalformedPremisesSpecification, Program, Authority,
        MalformedPremisesActual),
    assertion(MalformedPremisesActual == MalformedPremisesExpected),
    forall(
        between(1, 5, SpecificationFieldIndex),
        ( shape_variants(
              malformed_fixed_field(
                  specification, SpecificationFieldIndex),
              FixedMalformedSpecification, Program, Authority,
              FixedMalformedSpecificationExpected),
          validate_ground_typed_equality_pair(
              FixedMalformedSpecification, Program, Authority,
              FixedMalformedSpecificationActual),
          assertion(
              FixedMalformedSpecificationActual ==
              FixedMalformedSpecificationExpected)
        )),
    forall(
        between(1, 5, ProgramFieldIndex),
        ( shape_variants(
              malformed_fixed_field(program, ProgramFieldIndex),
              CanonicalSpecification, FixedMalformedProgram, Authority,
              FixedMalformedProgramExpected),
          validate_ground_typed_equality_pair(
              CanonicalSpecification, FixedMalformedProgram, Authority,
              FixedMalformedProgramActual),
          assertion(
              FixedMalformedProgramActual ==
              FixedMalformedProgramExpected)
        )),
    shape_variants(
        malformed_fixed_field(specification, 5),
        EarlierMalformedSpecification, _CanonicalProgram, Authority,
        EarlierMalformedExpected),
    shape_variants(
        malformed_fixed_field(program, 1),
        _CanonicalSpecification, LaterMalformedProgram, Authority,
        _LaterMalformedExpected),
    validate_ground_typed_equality_pair(
        EarlierMalformedSpecification, LaterMalformedProgram, Authority,
        BothMalformedActual),
    assertion(BothMalformedActual == EarlierMalformedExpected).

test(wrong_scalar_kinds_are_rejected) :-
    shape_variants(
        wrong_identifier_scalar,
        Specification, Program, Authority, Expected),
    validate_ground_typed_equality_pair(
        Specification, Program, Authority, Actual),
    assertion(Actual == Expected),
    shape_variants(
        wrong_value_scalar,
        ValueSpecification, Program, Authority, ValueExpected),
    validate_ground_typed_equality_pair(
        ValueSpecification, Program, Authority, ValueActual),
    assertion(ValueActual == ValueExpected).

test(improper_collections_are_rejected) :-
    shape_variants(
        improper_types, Specification, Program, Authority, Expected),
    validate_ground_typed_equality_pair(
        Specification, Program, Authority, Actual),
    assertion(Actual == Expected),
    shape_variants(
        improper_program_premises,
        CanonicalSpecification, BadProgram, Authority, ProgramExpected),
    validate_ground_typed_equality_pair(
        CanonicalSpecification, BadProgram, Authority, ProgramActual),
    assertion(ProgramActual == ProgramExpected),
    shape_variants(
        over_limit_improper_types,
        ImproperTypesSpecification, Program, Authority,
        ImproperTypesExpected),
    validate_ground_typed_equality_pair(
        ImproperTypesSpecification, Program, Authority,
        ImproperTypesActual),
    assertion(ImproperTypesActual == ImproperTypesExpected),
    shape_variants(
        over_limit_improper_operands,
        ImproperOperandsSpecification, Program, Authority,
        ImproperOperandsExpected),
    validate_ground_typed_equality_pair(
        ImproperOperandsSpecification, Program, Authority,
        ImproperOperandsActual),
    assertion(ImproperOperandsActual == ImproperOperandsExpected),
    shape_variants(
        over_limit_improper_premises,
        ImproperPremisesSpecification, Program, Authority,
        ImproperPremisesExpected),
    validate_ground_typed_equality_pair(
        ImproperPremisesSpecification, Program, Authority,
        ImproperPremisesActual),
    assertion(ImproperPremisesActual == ImproperPremisesExpected),
    unsupported_variants(
        over_limit_improper_operation_application,
        ImproperOperationSpecification, Program, Authority,
        ImproperOperationExpected),
    validate_ground_typed_equality_pair(
        ImproperOperationSpecification, Program, Authority,
        ImproperOperationActual),
    assertion(ImproperOperationActual == ImproperOperationExpected).

test(nested_host_variables_are_rejected) :-
    shape_variants(
        nested_specification_variable,
        Specification, Program, Authority, Expected),
    validate_ground_typed_equality_pair(
        Specification, Program, Authority, Actual),
    assertion(Actual == Expected),
    shape_variants(
        nested_program_variable,
        CanonicalSpecification, BadProgram, Authority, ProgramExpected),
    validate_ground_typed_equality_pair(
        CanonicalSpecification, BadProgram, Authority, ProgramActual),
    assertion(ProgramActual == ProgramExpected),
    shape_variants(
        variable_type_collection,
        CollectionSpecification, Program, Authority, CollectionExpected),
    CollectionSpecification =
        specification_proposal(
            _, type_declarations(CollectionVariable), _, _, _),
    validate_ground_typed_equality_pair(
        CollectionSpecification, Program, Authority, CollectionActual),
    assertion(CollectionActual == CollectionExpected),
    assertion(var(CollectionVariable)),
    shape_variants(
        variable_collection_tail,
        TailSpecification, Program, Authority, TailExpected),
    TailSpecification =
        specification_proposal(
            _, type_declarations([_|TailVariable]), _, _, _),
    validate_ground_typed_equality_pair(
        TailSpecification, Program, Authority, TailActual),
    assertion(TailActual == TailExpected),
    assertion(var(TailVariable)),
    shape_variants(
        variable_equality_state,
        EqualitySpecification, Program, Authority, EqualityExpected),
    EqualitySpecification =
        specification_proposal(
            _, _, binding(_, equality(EqualityVariable)), _, _),
    validate_ground_typed_equality_pair(
        EqualitySpecification, Program, Authority, EqualityActual),
    assertion(EqualityActual == EqualityExpected),
    assertion(var(EqualityVariable)),
    shape_variants(
        variable_definedness_state,
        DefinednessSpecification, Program, Authority,
        DefinednessExpected),
    DefinednessSpecification =
        specification_proposal(
            _, _, _, definedness(DefinednessVariable), _),
    validate_ground_typed_equality_pair(
        DefinednessSpecification, Program, Authority,
        DefinednessActual),
    assertion(DefinednessActual == DefinednessExpected),
    assertion(var(DefinednessVariable)),
    shape_variants(
        variable_quantifier_kind,
        QuantifierSpecification, Program, Authority, QuantifierExpected),
    QuantifierSpecification =
        specification_proposal(
            _, _, binding(_, quantifier(QuantifierVariable, _, _)), _, _),
    validate_ground_typed_equality_pair(
        QuantifierSpecification, Program, Authority, QuantifierActual),
    assertion(QuantifierActual == QuantifierExpected),
    assertion(var(QuantifierVariable)),
    forall(
        between(1, 5, SpecificationFieldIndex),
        ( shape_variants(
              variable_fixed_field(
                  specification, SpecificationFieldIndex),
              FixedVariableSpecification, Program, Authority,
              FixedVariableSpecificationExpected),
          term_variables(
              FixedVariableSpecification-Program-Authority,
              SpecificationVariablesBefore),
          validate_ground_typed_equality_pair(
              FixedVariableSpecification, Program, Authority,
              FixedVariableSpecificationActual),
          term_variables(
              FixedVariableSpecification-Program-Authority,
              SpecificationVariablesAfter),
          assertion(
              FixedVariableSpecificationActual ==
              FixedVariableSpecificationExpected),
          assertion(
              SpecificationVariablesAfter ==
              SpecificationVariablesBefore)
        )),
    forall(
        between(1, 5, ProgramFieldIndex),
        ( shape_variants(
              variable_fixed_field(program, ProgramFieldIndex),
              CanonicalSpecification, FixedVariableProgram, Authority,
              FixedVariableProgramExpected),
          term_variables(
              CanonicalSpecification-FixedVariableProgram-Authority,
              ProgramVariablesBefore),
          validate_ground_typed_equality_pair(
              CanonicalSpecification, FixedVariableProgram, Authority,
              FixedVariableProgramActual),
          term_variables(
              CanonicalSpecification-FixedVariableProgram-Authority,
              ProgramVariablesAfter),
          assertion(
              FixedVariableProgramActual ==
              FixedVariableProgramExpected),
          assertion(ProgramVariablesAfter == ProgramVariablesBefore)
        )),
    forall(
        ( member(DeepInput, [specification, program]),
          member(ChainLength, [13, 14, 20])
        ),
        ( boundary_terms(
              deep_variable(DeepInput, ChainLength),
              DeepSpecification, DeepProgram, Authority, DeepExpected),
          term_variables(
              DeepSpecification-DeepProgram-Authority,
              DeepVariablesBefore),
          validate_ground_typed_equality_pair(
              DeepSpecification, DeepProgram, Authority, DeepActual),
          term_variables(
              DeepSpecification-DeepProgram-Authority,
              DeepVariablesAfter),
          assertion(DeepActual == DeepExpected),
          assertion(DeepVariablesBefore \== []),
          assertion(DeepVariablesAfter == DeepVariablesBefore)
        )),
    forall(
        ( member(CellInput, [specification, program]),
          member(PriorityKind, [variable])
        ),
        ( boundary_terms(
              cell_priority(CellInput, PriorityKind),
              CellSpecification, CellProgram, Authority, CellExpected),
          term_variables(
              CellSpecification-CellProgram-Authority,
              CellVariablesBefore),
          validate_ground_typed_equality_pair(
              CellSpecification, CellProgram, Authority, CellActual),
          term_variables(
              CellSpecification-CellProgram-Authority,
              CellVariablesAfter),
          assertion(CellActual == CellExpected),
          assertion(CellVariablesBefore \== []),
          assertion(CellVariablesAfter == CellVariablesBefore)
        )),
    forall(
        member(ListInput, [specification, program]),
        ( boundary_terms(
              list_priority(ListInput, variable),
              ListSpecification, ListProgram, Authority, ListExpected),
          term_variables(
              ListSpecification-ListProgram-Authority,
              ListVariablesBefore),
          validate_ground_typed_equality_pair(
              ListSpecification, ListProgram, Authority, ListActual),
          term_variables(
              ListSpecification-ListProgram-Authority,
              ListVariablesAfter),
          assertion(ListActual == ListExpected),
          assertion(ListVariablesBefore \== []),
          assertion(ListVariablesAfter == ListVariablesBefore)
        )),
    shape_variants(
        variable_fixed_field(specification, 5),
        SpecificationVariable, _CanonicalProgram, Authority,
        SpecificationVariableExpected),
    shape_variants(
        variable_fixed_field(program, 5),
        _CanonicalSpecification, ProgramVariable, Authority,
        _ProgramVariableExpected),
    validate_ground_typed_equality_pair(
        SpecificationVariable, ProgramVariable, Authority,
        BothVariableActual),
    assertion(BothVariableActual == SpecificationVariableExpected),
    shape_variants(
        malformed_fixed_field(specification, 2),
        MalformedSpecification, _Program, Authority,
        _MalformedSpecificationExpected),
    validate_ground_typed_equality_pair(
        MalformedSpecification, ProgramVariable, Authority,
        VariableBeforeMalformedActual),
    assertion(
        VariableBeforeMalformedActual ==
        ground_typed_equality_validation(
            rejected(non_ground_input(program)),
            ir_audit(proposal(no_pair), authority(not_checked)))).

test(attributed_variables_are_rejected) :-
    shape_variants(
        attributed_specification,
        Specification, Program, Authority, Expected),
    validate_ground_typed_equality_pair(
        Specification, Program, Authority, Actual),
    assertion(Actual == Expected),
    canonical_pair(
        CanonicalSpecification, CanonicalProgram, Authority, _),
    put_attr(
        AttributedSpecification,
        cps_ground_typed_equality_ir,
        outer_specification),
    validate_ground_typed_equality_pair(
        AttributedSpecification, CanonicalProgram, Authority,
        OuterSpecificationActual),
    assertion(
        OuterSpecificationActual ==
        ground_typed_equality_validation(
            rejected(non_ground_input(specification)),
            ir_audit(proposal(no_pair), authority(not_checked)))),
    assertion(var(AttributedSpecification)),
    put_attr(
        AttributedProgram,
        cps_ground_typed_equality_ir,
        outer_program),
    validate_ground_typed_equality_pair(
        CanonicalSpecification, AttributedProgram, Authority,
        OuterProgramActual),
    assertion(
        OuterProgramActual ==
        ground_typed_equality_validation(
            rejected(non_ground_input(program)),
            ir_audit(proposal(no_pair), authority(not_checked)))),
    assertion(var(AttributedProgram)),
    forall(
        member(AttributedInput, [specification, program]),
        ( boundary_terms(
              deep_variable(AttributedInput, 20),
              DeepSpecification, DeepProgram, Authority, DeepExpected),
          term_variables(
              DeepSpecification-DeepProgram-Authority,
              [DeepVariable]),
          put_attr(
              DeepVariable,
              cps_ground_typed_equality_ir,
              deep_variable),
          validate_ground_typed_equality_pair(
              DeepSpecification, DeepProgram, Authority, DeepActual),
          assertion(DeepActual == DeepExpected),
          assertion(var(DeepVariable)),
          assertion(
              get_attr(
                  DeepVariable,
                  cps_ground_typed_equality_ir,
                  deep_variable))
        )).

test(direct_cycles_are_rejected) :-
    shape_variants(
        direct_cycle, Specification, Program, Authority, Expected),
    validate_ground_typed_equality_pair(
        Specification, Program, Authority, Actual),
    assertion(Actual == Expected),
    forall(
        between(1, 5, SpecificationFieldIndex),
        ( shape_variants(
              cyclic_fixed_field(
                  specification, SpecificationFieldIndex),
              FixedCycleSpecification, Program, Authority,
              FixedCycleSpecificationExpected),
          validate_ground_typed_equality_pair(
              FixedCycleSpecification, Program, Authority,
              FixedCycleSpecificationActual),
          assertion(
              FixedCycleSpecificationActual ==
              FixedCycleSpecificationExpected),
          assertion(cyclic_term(FixedCycleSpecification))
        )),
    forall(
        between(1, 5, ProgramFieldIndex),
        ( shape_variants(
              cyclic_fixed_field(program, ProgramFieldIndex),
              CanonicalSpecification, FixedCycleProgram, Authority,
              FixedCycleProgramExpected),
          validate_ground_typed_equality_pair(
              CanonicalSpecification, FixedCycleProgram, Authority,
              FixedCycleProgramActual),
          assertion(
              FixedCycleProgramActual ==
              FixedCycleProgramExpected),
          assertion(cyclic_term(FixedCycleProgram))
        )),
    forall(
        ( member(DeepInput, [specification, program]),
          member(ChainLength, [13, 14, 20])
        ),
        ( boundary_terms(
              deep_cycle(DeepInput, ChainLength),
              DeepSpecification, DeepProgram, Authority, DeepExpected),
          validate_ground_typed_equality_pair(
              DeepSpecification, DeepProgram, Authority, DeepActual),
          assertion(DeepActual == DeepExpected),
          assertion(
              ( cyclic_term(DeepSpecification)
              ; cyclic_term(DeepProgram)
              ))
        )),
    forall(
        ( member(CellInput, [specification, program]),
          member(PriorityKind, [cyclic])
        ),
        ( boundary_terms(
              cell_priority(CellInput, PriorityKind),
              CellSpecification, CellProgram, Authority, CellExpected),
          validate_ground_typed_equality_pair(
              CellSpecification, CellProgram, Authority, CellActual),
          assertion(CellActual == CellExpected)
        )),
    forall(
        member(ListInput, [specification, program]),
        ( boundary_terms(
              list_priority(ListInput, cyclic),
              ListSpecification, ListProgram, Authority, ListExpected),
          validate_ground_typed_equality_pair(
              ListSpecification, ListProgram, Authority, ListActual),
          assertion(ListActual == ListExpected)
        )),
    shape_variants(
        cyclic_fixed_field(specification, 5),
        CycleSpecification, _CanonicalProgram, Authority,
        CycleSpecificationExpected),
    shape_variants(
        variable_fixed_field(program, 5),
        _CanonicalSpecification, VariableProgram, Authority,
        _VariableProgramExpected),
    validate_ground_typed_equality_pair(
        CycleSpecification, VariableProgram, Authority,
        CycleBeforeVariableActual),
    assertion(CycleBeforeVariableActual == CycleSpecificationExpected),
    shape_variants(
        variable_fixed_field(specification, 5),
        VariableSpecification, _Program, Authority,
        _VariableSpecificationExpected),
    shape_variants(
        cyclic_fixed_field(program, 5),
        _Specification, CycleProgram, Authority, CycleProgramExpected),
    validate_ground_typed_equality_pair(
        VariableSpecification, CycleProgram, Authority,
        ProgramCycleBeforeVariableActual),
    assertion(
        ProgramCycleBeforeVariableActual == CycleProgramExpected).

test(indirect_cycles_are_rejected) :-
    shape_variants(
        indirect_cycle, Specification, Program, Authority, Expected),
    validate_ground_typed_equality_pair(
        Specification, Program, Authority, Actual),
    assertion(Actual == Expected).

test(swapped_proposals_are_rejected) :-
    shape_variants(
        swapped, Specification, Program, Authority, Expected),
    validate_ground_typed_equality_pair(
        Specification, Program, Authority, Actual),
    assertion(Actual == Expected).

test(forged_validated_inputs_are_rejected) :-
    shape_variants(
        forged_specification,
        ForgedSpecification, Program, Authority, SpecificationExpected),
    validate_ground_typed_equality_pair(
        ForgedSpecification, Program, Authority, SpecificationActual),
    assertion(SpecificationActual == SpecificationExpected),
    shape_variants(
        forged_program,
        Specification, ForgedProgram, Authority, ProgramExpected),
    validate_ground_typed_equality_pair(
        Specification, ForgedProgram, Authority, ProgramActual),
    assertion(ProgramActual == ProgramExpected).

test(inactive_premise_is_rejected) :-
    authority_variants(
        inactive, Specification, Program, Authority, Expected),
    validate_ground_typed_equality_pair(
        Specification, Program, Authority, Actual),
    assertion(Actual == Expected).

test(missing_activation_is_unknown) :-
    authority_variants(
        missing_activation,
        Specification, Program, Authority, Expected),
    validate_ground_typed_equality_pair(
        Specification, Program, Authority, Actual),
    assertion(Actual == Expected).

test(lambda_is_out_of_fragment) :-
    unsupported_variants(
        lambda, Specification, Program, Authority, Expected),
    validate_ground_typed_equality_pair(
        Specification, Program, Authority, Actual),
    assertion(Actual == Expected).

test(quantifier_is_out_of_fragment) :-
    unsupported_variants(
        quantifier, Specification, Program, Authority, Expected),
    validate_ground_typed_equality_pair(
        Specification, Program, Authority, Actual),
    assertion(Actual == Expected).

test(nested_binder_is_out_of_fragment) :-
    unsupported_variants(
        nested_binder, Specification, Program, Authority, Expected),
    validate_ground_typed_equality_pair(
        Specification, Program, Authority, Actual),
    assertion(Actual == Expected).

test(operation_application_is_out_of_fragment) :-
    unsupported_variants(
        operation_application,
        Specification, Program, Authority, Expected),
    validate_ground_typed_equality_pair(
        Specification, Program, Authority, Actual),
    assertion(Actual == Expected).

test(raw_host_goal_is_out_of_fragment) :-
    unsupported_variants(
        raw_host_goal, Specification, Program, Authority, Expected),
    validate_ground_typed_equality_pair(
        Specification, Program, Authority, Actual),
    assertion(Actual == Expected).

test(raw_host_clause_is_out_of_fragment) :-
    unsupported_variants(
        raw_host_clause, Specification, Program, Authority, Expected),
    validate_ground_typed_equality_pair(
        Specification, Program, Authority, Actual),
    assertion(Actual == Expected).

test(canonical_operand_order_is_required) :-
    shape_variants(
        noncanonical_operands,
        Specification, Program, Authority, Expected),
    validate_ground_typed_equality_pair(
        Specification, Program, Authority, Actual),
    assertion(Actual == Expected).

test(authority_must_match_equality_definition_space_and_premise) :-
    authority_variants(
        scope_equality,
        EqualitySpecification, Program, Authority, EqualityExpected),
    validate_ground_typed_equality_pair(
        EqualitySpecification, Program, Authority, EqualityActual),
    assertion(EqualityActual == EqualityExpected),
    authority_variants(
        scope_definition_space,
        SpaceSpecification, SpaceProgram, Authority, SpaceExpected),
    validate_ground_typed_equality_pair(
        SpaceSpecification, SpaceProgram, Authority, SpaceActual),
    assertion(SpaceActual == SpaceExpected),
    authority_variants(
        scope_premise,
        PremiseSpecification, PremiseProgram, Authority, PremiseExpected),
    validate_ground_typed_equality_pair(
        PremiseSpecification, PremiseProgram, Authority, PremiseActual),
    assertion(PremiseActual == PremiseExpected).

test(depth_node_list_and_scalar_bounds_are_exact) :-
    boundary_terms(
        identifier_1_pair,
        Identifier1Specification, Program, Authority,
        Identifier1Expected),
    validate_ground_typed_equality_pair(
        Identifier1Specification, Program, Authority,
        Identifier1Actual),
    assertion(Identifier1Actual == Identifier1Expected),
    boundary_terms(
        identifier_64_pair,
        Identifier64Specification, Program, Authority,
        Identifier64Expected),
    validate_ground_typed_equality_pair(
        Identifier64Specification, Program, Authority,
        Identifier64Actual),
    assertion(Identifier64Actual == Identifier64Expected),
    boundary_terms(
        identifier_65_pair,
        Identifier65Specification, Program, Authority,
        Identifier65Expected),
    validate_ground_typed_equality_pair(
        Identifier65Specification, Program, Authority,
        Identifier65Actual),
    assertion(Identifier65Actual == Identifier65Expected),
    boundary_terms(
        identifier_66_pair,
        Identifier66Specification, Program, Authority,
        Identifier66Expected),
    validate_ground_typed_equality_pair(
        Identifier66Specification, Program, Authority,
        Identifier66Actual),
    assertion(Identifier66Actual == Identifier66Expected),
    boundary_terms(
        value_1_pair,
        Value1Specification, Program, Authority, Value1Expected),
    validate_ground_typed_equality_pair(
        Value1Specification, Program, Authority, Value1Actual),
    assertion(Value1Actual == Value1Expected),
    boundary_terms(
        value_128_pair,
        Value128Specification, Program, Authority, Value128Expected),
    validate_ground_typed_equality_pair(
        Value128Specification, Program, Authority, Value128Actual),
    assertion(Value128Actual == Value128Expected),
    boundary_terms(
        value_129_pair,
        Value129Specification, Program, Authority, Value129Expected),
    validate_ground_typed_equality_pair(
        Value129Specification, Program, Authority, Value129Actual),
    assertion(Value129Actual == Value129Expected),
    boundary_terms(
        value_130_pair,
        Value130Specification, Program, Authority, Value130Expected),
    validate_ground_typed_equality_pair(
        Value130Specification, Program, Authority, Value130Actual),
    assertion(Value130Actual == Value130Expected),
    boundary_terms(
        depth_16,
        Depth16Specification, Program, Authority, Depth16Expected),
    validate_ground_typed_equality_pair(
        Depth16Specification, Program, Authority, Depth16Actual),
    assertion(Depth16Actual == Depth16Expected),
    boundary_terms(
        depth_17,
        Depth17Specification, Program, Authority, Depth17Expected),
    validate_ground_typed_equality_pair(
        Depth17Specification, Program, Authority, Depth17Actual),
    assertion(Depth17Actual == Depth17Expected),
    boundary_terms(
        depth_20,
        Depth20Specification, Program, Authority, Depth20Expected),
    validate_ground_typed_equality_pair(
        Depth20Specification, Program, Authority, Depth20Actual),
    assertion(Depth20Actual == Depth20Expected),
    boundary_terms(
        cells_512,
        Cells512Specification, Program, Authority, Cells512Expected),
    validate_ground_typed_equality_pair(
        Cells512Specification, Program, Authority, Cells512Actual),
    assertion(Cells512Actual == Cells512Expected),
    boundary_terms(
        cells_513,
        Cells513Specification, Program, Authority, Cells513Expected),
    validate_ground_typed_equality_pair(
        Cells513Specification, Program, Authority, Cells513Actual),
    assertion(Cells513Actual == Cells513Expected),
    boundary_terms(
        cells_beyond,
        CellsBeyondSpecification, Program, Authority,
        CellsBeyondExpected),
    validate_ground_typed_equality_pair(
        CellsBeyondSpecification, Program, Authority,
        CellsBeyondActual),
    assertion(CellsBeyondActual == CellsBeyondExpected),
    boundary_terms(
        list_2,
        List2Specification, Program, Authority, List2Expected),
    validate_ground_typed_equality_pair(
        List2Specification, Program, Authority, List2Actual),
    assertion(List2Actual == List2Expected),
    boundary_terms(
        list_3,
        List3Specification, Program, Authority, List3Expected),
    validate_ground_typed_equality_pair(
        List3Specification, Program, Authority, List3Actual),
    assertion(List3Actual == List3Expected),
    boundary_terms(
        list_4,
        List4Specification, Program, Authority, List4Expected),
    validate_ground_typed_equality_pair(
        List4Specification, Program, Authority, List4Actual),
    assertion(List4Actual == List4Expected),
    boundary_terms(
        list_3_types,
        List3TypesSpecification, Program, Authority, List3TypesExpected),
    validate_ground_typed_equality_pair(
        List3TypesSpecification, Program, Authority, List3TypesActual),
    assertion(List3TypesActual == List3TypesExpected),
    boundary_terms(
        list_3_operands,
        List3OperandsSpecification, Program, Authority,
        List3OperandsExpected),
    validate_ground_typed_equality_pair(
        List3OperandsSpecification, Program, Authority,
        List3OperandsActual),
    assertion(List3OperandsActual == List3OperandsExpected),
    boundary_terms(
        list_3_premises,
        List3PremisesSpecification, Program, Authority,
        List3PremisesExpected),
    validate_ground_typed_equality_pair(
        List3PremisesSpecification, Program, Authority,
        List3PremisesActual),
    assertion(List3PremisesActual == List3PremisesExpected),
    boundary_terms(
        program_identifier_65_pair,
        Specification, ProgramIdentifier65, Authority,
        ProgramIdentifier65Expected),
    validate_ground_typed_equality_pair(
        Specification, ProgramIdentifier65, Authority,
        ProgramIdentifier65Actual),
    assertion(
        ProgramIdentifier65Actual == ProgramIdentifier65Expected),
    boundary_terms(
        program_identifier_66_pair,
        Specification, ProgramIdentifier66, Authority,
        ProgramIdentifier66Expected),
    validate_ground_typed_equality_pair(
        Specification, ProgramIdentifier66, Authority,
        ProgramIdentifier66Actual),
    assertion(
        ProgramIdentifier66Actual == ProgramIdentifier66Expected),
    boundary_terms(
        program_depth_20,
        Specification, ProgramDepth20, Authority,
        ProgramDepth20Expected),
    validate_ground_typed_equality_pair(
        Specification, ProgramDepth20, Authority,
        ProgramDepth20Actual),
    assertion(ProgramDepth20Actual == ProgramDepth20Expected),
    boundary_terms(
        program_cells_beyond,
        Specification, ProgramCellsBeyond, Authority,
        ProgramCellsBeyondExpected),
    validate_ground_typed_equality_pair(
        Specification, ProgramCellsBeyond, Authority,
        ProgramCellsBeyondActual),
    assertion(
        ProgramCellsBeyondActual == ProgramCellsBeyondExpected),
    boundary_terms(
        program_list_3,
        Specification, ProgramList3, Authority, ProgramList3Expected),
    validate_ground_typed_equality_pair(
        Specification, ProgramList3, Authority, ProgramList3Actual),
    assertion(ProgramList3Actual == ProgramList3Expected),
    forall(
        member(
            ResourcePriorityCase,
            [ spec_identifier_program_depth,
              spec_list_program_depth,
              spec_value_program_list,
              spec_identifier_program_identifier,
              spec_depth_program_depth
            ]),
        ( boundary_terms(
              resource_priority(ResourcePriorityCase),
              PrioritySpecification, PriorityProgram, Authority,
              PriorityExpected),
          validate_ground_typed_equality_pair(
              PrioritySpecification, PriorityProgram, Authority,
              PriorityActual),
          assertion(PriorityActual == PriorityExpected)
        )).

test(input_terms_are_unchanged) :-
    canonical_pair(Specification, Program, Authority, Expected),
    SpecificationBefore = Specification,
    ProgramBefore = Program,
    AuthorityBefore = Authority,
    validate_ground_typed_equality_pair(
        Specification, Program, Authority, Actual),
    assertion(Actual == Expected),
    assertion(Specification == SpecificationBefore),
    assertion(Program == ProgramBefore),
    assertion(Authority == AuthorityBefore),
    boundary_terms(
        deep_variable(specification, 20),
        DeepSpecification, DeepProgram, Authority, DeepExpected),
    term_variables(
        DeepSpecification-DeepProgram-Authority,
        DeepVariablesBefore),
    validate_ground_typed_equality_pair(
        DeepSpecification, DeepProgram, Authority, DeepActual),
    term_variables(
        DeepSpecification-DeepProgram-Authority,
        DeepVariablesAfter),
    assertion(DeepActual == DeepExpected),
    assertion(DeepVariablesAfter == DeepVariablesBefore),
    boundary_terms(
        deep_cycle(program, 20),
        CyclicSpecification, CyclicProgram, Authority, CyclicExpected),
    assertion(cyclic_term(CyclicProgram)),
    validate_ground_typed_equality_pair(
        CyclicSpecification, CyclicProgram, Authority, CyclicActual),
    assertion(CyclicActual == CyclicExpected),
    assertion(cyclic_term(CyclicProgram)).

test(module_has_no_dynamic_or_meta_predicates) :-
    module_property(
        cps_ground_typed_equality_ir,
        exports(Exports)),
    assertion(
        Exports ==
        [validate_ground_typed_equality_pair/4]),
    findall(
        Name/Arity,
        ( current_predicate(
              cps_ground_typed_equality_ir:Head),
          functor(Head, Name, Arity),
          \+ predicate_property(
                 cps_ground_typed_equality_ir:Head,
                 imported_from(_)),
          ( predicate_property(
                cps_ground_typed_equality_ir:Head,
                dynamic)
          ; predicate_property(
                cps_ground_typed_equality_ir:Head,
                meta_predicate(_))
          )
        ),
        ForbiddenProperties),
    assertion(ForbiddenProperties == []),
    source_file(
        cps_ground_typed_equality_ir:
            validate_ground_typed_equality_pair(_, _, _, _),
        SourceFile),
    read_file_to_string(SourceFile, SourceText, []),
    assertion(\+ sub_string(SourceText, _, _, _, "call(")),
    assertion(\+ sub_string(SourceText, _, _, _, "once(")),
    assertion(\+ sub_string(SourceText, _, _, _, "maplist(")),
    assertion(\+ sub_string(SourceText, _, _, _, "assert(")),
    assertion(\+ sub_string(SourceText, _, _, _, "asserta(")),
    assertion(\+ sub_string(SourceText, _, _, _, "assertz(")),
    assertion(\+ sub_string(SourceText, _, _, _, "retract(")).

test(results_are_call_order_and_test_order_independent) :-
    canonical_pair(Specification, Program, Authority, AcceptedExpected),
    shape_variants(
        missing_equality,
        MissingSpecification, Program, Authority, MissingExpected),
    validate_ground_typed_equality_pair(
        Specification, Program, Authority, AcceptedFirst),
    validate_ground_typed_equality_pair(
        MissingSpecification, Program, Authority, MissingSecond),
    validate_ground_typed_equality_pair(
        MissingSpecification, Program, Authority, MissingFirst),
    validate_ground_typed_equality_pair(
        Specification, Program, Authority, AcceptedSecond),
    assertion(AcceptedFirst == AcceptedExpected),
    assertion(AcceptedSecond == AcceptedExpected),
    assertion(MissingFirst == MissingExpected),
    assertion(MissingSecond == MissingExpected),
    boundary_terms(
        deep_variable(specification, 20),
        DeepVariableSpecification, DeepVariableProgram, Authority,
        DeepVariableExpected),
    boundary_terms(
        deep_cycle(program, 20),
        DeepCycleSpecification, DeepCycleProgram, Authority,
        DeepCycleExpected),
    validate_ground_typed_equality_pair(
        DeepVariableSpecification, DeepVariableProgram, Authority,
        DeepVariableFirst),
    validate_ground_typed_equality_pair(
        DeepCycleSpecification, DeepCycleProgram, Authority,
        DeepCycleSecond),
    validate_ground_typed_equality_pair(
        DeepCycleSpecification, DeepCycleProgram, Authority,
        DeepCycleFirst),
    validate_ground_typed_equality_pair(
        DeepVariableSpecification, DeepVariableProgram, Authority,
        DeepVariableSecond),
    assertion(DeepVariableFirst == DeepVariableExpected),
    assertion(DeepVariableSecond == DeepVariableExpected),
    assertion(DeepCycleFirst == DeepCycleExpected),
    assertion(DeepCycleSecond == DeepCycleExpected).

test(result_is_working_directory_independent) :-
    canonical_pair(Specification, Program, Authority, Expected),
    validate_ground_typed_equality_pair(
        Specification, Program, Authority, RootResult),
    working_directory(OriginalDirectory, OriginalDirectory),
    setup_call_cleanup(
        working_directory(_, '/tmp'),
        validate_ground_typed_equality_pair(
            Specification, Program, Authority, OtherDirectoryResult),
        working_directory(_, OriginalDirectory)),
    assertion(RootResult == Expected),
    assertion(OtherDirectoryResult == Expected).

test(result_is_asserted_state_independent) :-
    canonical_pair(Specification, Program, Authority, Expected),
    validate_ground_typed_equality_pair(
        Specification, Program, Authority, Baseline),
    setup_call_cleanup(
        assertz(user:cps_ir_unrelated_state(marker)),
        validate_ground_typed_equality_pair(
            Specification, Program, Authority, WithState),
        retractall(user:cps_ir_unrelated_state(_))),
    assertion(Baseline == Expected),
    assertion(WithState == Expected).

test(t002_status_mapping_and_audit_retention_are_exact) :-
    authority_variants(
        untrusted, Specification, Program, UntrustedAuthority,
        UntrustedExpected),
    validate_ground_typed_equality_pair(
        Specification, Program, UntrustedAuthority, UntrustedActual),
    assertion(UntrustedActual == UntrustedExpected),
    authority_variants(
        explicit_contradiction,
        Specification, Program, ContradictionAuthority,
        ContradictionExpected),
    validate_ground_typed_equality_pair(
        Specification, Program, ContradictionAuthority,
        ContradictionActual),
    assertion(ContradictionActual == ContradictionExpected),
    authority_variants(
        nonground, Specification, Program, NongroundAuthority,
        NongroundExpected),
    validate_ground_typed_equality_pair(
        Specification, Program, NongroundAuthority, NongroundActual),
    assertion(NongroundActual == NongroundExpected),
    assertion(var(NongroundAuthority)),
    authority_variants(
        cyclic, Specification, Program, CyclicAuthority, CyclicExpected),
    validate_ground_typed_equality_pair(
        Specification, Program, CyclicAuthority, CyclicActual),
    assertion(CyclicActual == CyclicExpected),
    authority_variants(
        malformed, Specification, Program, MalformedAuthority,
        MalformedExpected),
    validate_ground_typed_equality_pair(
        Specification, Program, MalformedAuthority, MalformedActual),
    assertion(MalformedActual == MalformedExpected),
    authority_variants(
        resource, Specification, Program, ResourceAuthority,
        ResourceExpected),
    validate_ground_typed_equality_pair(
        Specification, Program, ResourceAuthority, ResourceActual),
    assertion(ResourceActual == ResourceExpected),
    authority_variants(
        resource_beyond,
        Specification, Program, ResourceBeyondAuthority,
        ResourceBeyondExpected),
    validate_ground_typed_equality_pair(
        Specification, Program, ResourceBeyondAuthority,
        ResourceBeyondActual),
    assertion(ResourceBeyondActual == ResourceBeyondExpected),
    forall(
        member(Priority, [nonground, cyclic, malformed]),
        ( authority_variants(
              resource_with_priority(Priority),
              Specification, Program, PriorityAuthority,
              PriorityExpected),
          term_variables(PriorityAuthority, PriorityVariablesBefore),
          validate_ground_typed_equality_pair(
              Specification, Program, PriorityAuthority,
              PriorityActual),
          term_variables(PriorityAuthority, PriorityVariablesAfter),
          assertion(PriorityActual == PriorityExpected),
          assertion(
              PriorityVariablesAfter == PriorityVariablesBefore)
        )),
    forall(
        member(LaterStatus, [inactive, unknown]),
        ( authority_variants(
              resource_before_status(LaterStatus),
              Specification, Program, StatusAuthority,
              StatusExpected),
          validate_ground_typed_equality_pair(
              Specification, Program, StatusAuthority, StatusActual),
          assertion(StatusActual == StatusExpected)
        )).

test(early_resource_excess_does_not_mask_fixed_field_errors) :-
    boundary_terms(
        early_excess_late_program_variable,
        Specification, Program, Authority, VariableExpected),
    validate_ground_typed_equality_pair(
        Specification, Program, Authority, VariableActual),
    assertion(VariableActual == VariableExpected),
    boundary_terms(
        early_excess_late_program_shape,
        ShapeSpecification, ShapeProgram, Authority, ShapeExpected),
    validate_ground_typed_equality_pair(
        ShapeSpecification, ShapeProgram, Authority, ShapeActual),
    assertion(ShapeActual == ShapeExpected),
    forall(
        ( member(
              Resource,
              [identifier_scalar, value_scalar, list, depth, cells]),
          member(
              LaterOutcome,
              [ variable,
                cyclic,
                malformed,
                unsupported,
                semantic,
                inactive,
                unknown,
                untrusted
              ])
        ),
        ( boundary_terms(
              resource_before_program_outcome(
                  Resource, LaterOutcome),
              ResourceSpecification, OutcomeProgram, OutcomeAuthority,
              OutcomeExpected),
          term_variables(
              ResourceSpecification-OutcomeProgram-OutcomeAuthority,
              OutcomeVariablesBefore),
          validate_ground_typed_equality_pair(
              ResourceSpecification, OutcomeProgram, OutcomeAuthority,
              OutcomeActual),
          term_variables(
              ResourceSpecification-OutcomeProgram-OutcomeAuthority,
              OutcomeVariablesAfter),
          assertion(OutcomeActual == OutcomeExpected),
          assertion(OutcomeVariablesAfter == OutcomeVariablesBefore)
        )),
    forall(
        ( member(
              ProgramResource,
              [identifier_scalar, list, depth, cells]),
          member(
              EarlierOutcome,
              [variable, cyclic, malformed, unsupported, semantic])
        ),
        ( boundary_terms(
              program_resource_before_specification_outcome(
                  ProgramResource, EarlierOutcome),
              OutcomeSpecification, ResourceProgram, ResourceAuthority,
              ResourceOutcomeExpected),
          term_variables(
              OutcomeSpecification-ResourceProgram-ResourceAuthority,
              ResourceVariablesBefore),
          validate_ground_typed_equality_pair(
              OutcomeSpecification, ResourceProgram, ResourceAuthority,
              ResourceOutcomeActual),
          term_variables(
              OutcomeSpecification-ResourceProgram-ResourceAuthority,
              ResourceVariablesAfter),
          assertion(ResourceOutcomeActual == ResourceOutcomeExpected),
          assertion(ResourceVariablesAfter == ResourceVariablesBefore)
        )),
    boundary_terms(
        resource_before_authority_scope_mismatch,
        ScopeResourceSpecification, ScopeResourceProgram,
        ScopeResourceAuthority, ScopeResourceExpected),
    validate_ground_typed_equality_pair(
        ScopeResourceSpecification, ScopeResourceProgram,
        ScopeResourceAuthority, ScopeResourceActual),
    assertion(ScopeResourceActual == ScopeResourceExpected).

test(shared_cell_prefix_contract_is_exact) :-
    forall(
        ( member(Position, [512, 513, 520]),
          between(1, 5, ProgramField),
          member(MarkerKind, [variable, attributed, cyclic, malformed])
        ),
        ( shared_positioned_program_field(
              Position, ProgramField, MarkerKind,
              Specification, Program, Authority, Expected,
              TargetPath, Marker),
          shared_assert_prefix_case(
              program, Position, TargetPath, MarkerKind, Marker,
              Specification, Program, Authority, Expected)
        )),
    forall(
        ( member(Position, [512, 513, 520]),
          member(SpecificationField, [4, 5]),
          member(MarkerKind, [variable, attributed, cyclic, malformed])
        ),
        ( shared_positioned_specification_field(
              Position, SpecificationField, MarkerKind,
              Specification, Program, Authority, Expected,
              TargetPath, Marker),
          shared_assert_prefix_case(
              specification, Position, TargetPath, MarkerKind, Marker,
              Specification, Program, Authority, Expected)
        )),
    forall(
        ( member(Position, [512, 513, 520]),
          member(MarkerKind, [variable, attributed, cyclic])
        ),
        ( shared_positioned_specification_expression(
              Position, MarkerKind,
              Specification, Program, Authority, Expected,
              TargetPath, Marker),
          shared_assert_prefix_case(
              specification, Position, TargetPath, MarkerKind, Marker,
              Specification, Program, Authority, Expected)
        )),
    shared_positioned_program_boundary(
        513, ResourceSpecification, Program0,
        _CanonicalAuthority, _ResourcePath),
    ResourceExpected =
        ground_typed_equality_validation(
            rejected(resource_limit_exceeded(program, cells)),
            ir_audit(proposal(no_pair), authority(not_checked))),
    forall(
        member(
            LaterOutcome,
            [ accepted,
              unsupported,
              semantic,
              inactive,
              unknown,
              rejected,
              nonground_authority
            ]),
        ( shared_later_outcome(
              LaterOutcome, Program0, LaterAuthority,
              LaterProgram, LaterAuthority),
          term_variables(
              ResourceSpecification-LaterProgram-LaterAuthority,
              LaterVariablesBefore),
          findall(
              LaterValidation,
              validate_ground_typed_equality_pair(
                  ResourceSpecification, LaterProgram, LaterAuthority,
                  LaterValidation),
              LaterSolutions),
          term_variables(
              ResourceSpecification-LaterProgram-LaterAuthority,
              LaterVariablesAfter),
          assertion(LaterSolutions == [ResourceExpected]),
          assertion(LaterVariablesAfter == LaterVariablesBefore)
        )).

:- end_tests(cps_ground_typed_equality_ir).
