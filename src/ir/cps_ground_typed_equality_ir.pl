:- module(cps_ground_typed_equality_ir,
          [ validate_ground_typed_equality_pair/4
          ]).

:- use_module('../cps_law_claim_authority',
              [ assess_law_claim_authority/2
              ]).

/** <module> Bounded ground typed equality proposal validation

This module validates one closed equality Specification proposal and one
distinct identity-shaped Program proposal.  It treats every proposal and
authority snapshot as data and returns an explicit accepted, rejected, or
unknown result.
*/

%! validate_ground_typed_equality_pair(
%!     +SpecificationProposal,
%!     +ProgramProposal,
%!     +AuthoritySnapshot,
%!     -Validation) is det.
%
%  Validate the two proposal terms without binding or executing either input.
%  Every input-mode invocation produces one finite ground Validation.
validate_ground_typed_equality_pair(Specification, Program, Authority,
                                    Validation) :-
    direct_status(Specification, Program, DirectStatus),
    finish_direct_status(DirectStatus, Specification, Program, Authority,
                         Validation),
    !.

finish_direct_status(rejected(Reason), _Specification, _Program, _Authority,
                     Validation) :-
    no_pair_audit(Audit),
    Validation =
        ground_typed_equality_validation(rejected(Reason), Audit).
finish_direct_status(ready, Specification, Program, Authority, Validation) :-
    structural_status(Specification, Program, StructuralStatus),
    finish_structural_status(StructuralStatus, Authority, Validation).

finish_structural_status(rejected(Reason), _Authority, Validation) :-
    no_pair_audit(Audit),
    Validation =
        ground_typed_equality_validation(rejected(Reason), Audit).
finish_structural_status(closed(SpecificationData, ProgramData), Authority,
                         Validation) :-
    pair_audit(SpecificationData, ProgramData, ProposalAudit),
    semantic_status(SpecificationData, ProgramData, SemanticStatus),
    finish_semantic_status(SemanticStatus, ProposalAudit, Authority,
                           Validation).

finish_semantic_status(rejected(Reason), ProposalAudit, _Authority,
                       Validation) :-
    Audit = ir_audit(ProposalAudit, authority(not_checked)),
    Validation =
        ground_typed_equality_validation(rejected(Reason), Audit).
finish_semantic_status(validated(ValidatedData), ProposalAudit, Authority,
                       Validation) :-
    assess_law_claim_authority(Authority, AuthorityAssessment),
    authority_status(AuthorityAssessment, ValidatedData, AuthorityStatus),
    finish_authority_status(
        AuthorityStatus, AuthorityAssessment, ProposalAudit, ValidatedData,
        Validation).

finish_authority_status(rejected(Reason), AuthorityAssessment, ProposalAudit,
                        _ValidatedData, Validation) :-
    Audit = ir_audit(ProposalAudit, authority(AuthorityAssessment)),
    Validation =
        ground_typed_equality_validation(rejected(Reason), Audit).
finish_authority_status(unknown(PremiseId, Missing), AuthorityAssessment,
                        ProposalAudit, _ValidatedData, Validation) :-
    Audit = ir_audit(ProposalAudit, authority(AuthorityAssessment)),
    Validation =
        ground_typed_equality_validation(
            unknown(missing_authority(PremiseId, Missing)),
            Audit).
finish_authority_status(accepted, AuthorityAssessment, ProposalAudit,
                        ValidatedData, Validation) :-
    validated_pair(ValidatedData, ValidatedPair),
    Audit = ir_audit(ProposalAudit, authority(AuthorityAssessment)),
    Validation =
        ground_typed_equality_validation(
            accepted(ValidatedPair),
            Audit).

no_pair_audit(
    ir_audit(proposal(no_pair), authority(not_checked))).

pair_audit(
    spec_data(SpecificationId, _, _, _,
              _, _, PremiseId),
    program_data(ProgramId, _, _, _,
                 _, _, _, _),
    proposal(pair(specification_id(SpecificationId),
                  program_id(ProgramId),
                  premise_id(PremiseId)))).

direct_status(Specification, _Program,
              rejected(non_ground_input(specification))) :-
    var(Specification),
    !.
direct_status(_Specification, Program,
              rejected(non_ground_input(program))) :-
    var(Program),
    !.
direct_status(Specification, Program, Status) :-
    root_kind(Specification, SpecificationKind),
    root_kind(Program, ProgramKind),
    direct_root_status(SpecificationKind, ProgramKind, Status).

direct_root_status(program, specification,
                   rejected(swapped_proposals)) :-
    !.
direct_root_status(forged, _ProgramKind,
                   rejected(forged_validated_input(specification))) :-
    !.
direct_root_status(_SpecificationKind, forged,
                   rejected(forged_validated_input(program))) :-
    !.
direct_root_status(specification, program, ready) :-
    !.
direct_root_status(specification, _ProgramKind,
                   rejected(malformed_shape(program, root))) :-
    !.
direct_root_status(_SpecificationKind, _ProgramKind,
                   rejected(malformed_shape(specification, root))).

root_kind(Term, atomic) :-
    atomic(Term),
    !.
root_kind(Term, Kind) :-
    functor(Term, Name, Arity),
    root_name_arity(Name, Arity, Kind).

root_name_arity(specification_proposal, 5, specification) :-
    !.
root_name_arity(program_proposal, 5, program) :-
    !.
root_name_arity(validated_specification, 5, forged) :-
    !.
root_name_arity(validated_program, 5, forged) :-
    !.
root_name_arity(validated_pair, 2, forged) :-
    !.
root_name_arity(ground_typed_equality_validation, 2, forged) :-
    !.
root_name_arity(_Name, _Arity, other).

structural_status(Specification, Program, Status) :-
    inspect_proposal_prefix(
        Specification, Program, PrefixStatus),
    finish_prefix_status(
        PrefixStatus, Specification, Program, Status).

finish_prefix_status(complete, Specification, Program, Status) :-
    complete_structural_status(Specification, Program, Status).
finish_prefix_status(
        exhausted(Input, SpecificationView, ProgramView),
        _Specification, _Program, Status) :-
    exhausted_prefix_status(
        Input, SpecificationView, ProgramView, Status).

complete_structural_status(Specification, Program, Status) :-
    proposal_cycle_status(Specification, SpecificationCycle),
    proposal_cycle_status(Program, ProgramCycle),
    proposal_variable_status(Specification, SpecificationVariable),
    proposal_variable_status(Program, ProgramVariable),
    specification_shape(Specification, SpecificationData,
                        SpecificationShape, SpecificationFragment),
    program_shape(Program, ProgramData, ProgramShape, ProgramFragment),
    proposal_resource_status(Specification, Program, ResourceStatus),
    choose_structural_status(
        SpecificationCycle, ProgramCycle,
        SpecificationVariable, ProgramVariable,
        SpecificationShape, ProgramShape,
        ResourceStatus,
        SpecificationFragment, ProgramFragment,
        SpecificationData, ProgramData,
        Status).

inspect_proposal_prefix(Specification, Program, Status) :-
    inspect_prefix_term(
        Specification, [], 0, SpecificationCells,
        SpecificationView, SpecificationStatus),
    continue_prefix_program(
        SpecificationStatus, SpecificationView, Program,
        SpecificationCells, Status).

continue_prefix_program(
        exhausted, SpecificationView, _Program, _Cells,
        exhausted(
            specification, SpecificationView, prefix_uninspected)) :-
    !.
continue_prefix_program(
        complete, SpecificationView, Program, Cells0, Status) :-
    inspect_prefix_term(
        Program, [], Cells0, _Cells,
        ProgramView, ProgramStatus),
    finish_prefix_program_status(
        ProgramStatus, SpecificationView, ProgramView, Status).

finish_prefix_program_status(
        exhausted, SpecificationView, ProgramView,
        exhausted(program, SpecificationView, ProgramView)) :-
    !.
finish_prefix_program_status(
        complete, _SpecificationView, _ProgramView, complete).

inspect_prefix_term(
        _Term, _Ancestors, Cells, Cells,
        prefix_uninspected, exhausted) :-
    Cells >= 512,
    !.
inspect_prefix_term(
        Term, Ancestors, Cells0, Cells, View, Status) :-
    Cells1 is Cells0 + 1,
    inspect_visited_prefix_term(
        Term, Ancestors, Cells1, Cells, View, Status).

inspect_visited_prefix_term(
        Term, _Ancestors, Cells, Cells,
        prefix_variable, complete) :-
    var(Term),
    !.
inspect_visited_prefix_term(
        Term, _Ancestors, Cells, Cells,
        prefix_atomic(Term), complete) :-
    atomic(Term),
    !.
inspect_visited_prefix_term(
        Term, Ancestors, Cells, Cells,
        prefix_cycle, complete) :-
    identity_member(Term, Ancestors),
    !.
inspect_visited_prefix_term(
        Term, Ancestors, Cells0, Cells,
        prefix_compound(Name, Arguments), Status) :-
    functor(Term, Name, Arity),
    inspect_prefix_arguments(
        1, Arity, Term, [Term|Ancestors], Cells0, Cells,
        Arguments, Status).

inspect_prefix_arguments(
        Index, Arity, _Term, _Ancestors, Cells, Cells, [], complete) :-
    Index > Arity,
    !.
inspect_prefix_arguments(
        Index, Arity, Term, Ancestors, Cells0, Cells,
        [ArgumentView|ArgumentViews], Status) :-
    arg(Index, Term, Argument),
    inspect_prefix_term(
        Argument, Ancestors, Cells0, Cells1,
        ArgumentView, ArgumentStatus),
    continue_prefix_arguments(
        ArgumentStatus, Index, Arity, Term, Ancestors,
        Cells1, Cells, ArgumentViews, Status).

continue_prefix_arguments(
        exhausted, Index, Arity, _Term, _Ancestors,
        Cells, Cells, ArgumentViews, exhausted) :-
    !,
    Remaining is Arity - Index,
    prefix_uninspected_arguments(Remaining, ArgumentViews).
continue_prefix_arguments(
        complete, Index, Arity, Term, Ancestors,
        Cells0, Cells, ArgumentViews, Status) :-
    NextIndex is Index + 1,
    inspect_prefix_arguments(
        NextIndex, Arity, Term, Ancestors, Cells0, Cells,
        ArgumentViews, Status).

prefix_uninspected_arguments(0, []) :-
    !.
prefix_uninspected_arguments(
        Count, [prefix_uninspected|Arguments]) :-
    NextCount is Count - 1,
    prefix_uninspected_arguments(NextCount, Arguments).

exhausted_prefix_status(
        _Input, SpecificationView, _ProgramView,
        rejected(cyclic_input(specification))) :-
    prefix_view_has_cycle(SpecificationView),
    !.
exhausted_prefix_status(
        _Input, _SpecificationView, ProgramView,
        rejected(cyclic_input(program))) :-
    prefix_view_has_cycle(ProgramView),
    !.
exhausted_prefix_status(
        _Input, SpecificationView, _ProgramView,
        rejected(non_ground_input(specification))) :-
    prefix_view_has_variable(SpecificationView),
    !.
exhausted_prefix_status(
        _Input, _SpecificationView, ProgramView,
        rejected(non_ground_input(program))) :-
    prefix_view_has_variable(ProgramView),
    !.
exhausted_prefix_status(
        _Input, SpecificationView, _ProgramView,
        rejected(malformed_shape(specification, Field))) :-
    prefix_specification_shape(SpecificationView, malformed(Field)),
    !.
exhausted_prefix_status(
        _Input, _SpecificationView, ProgramView,
        rejected(malformed_shape(program, Field))) :-
    prefix_program_shape(ProgramView, malformed(Field)),
    !.
exhausted_prefix_status(
        _Input, SpecificationView, _ProgramView,
        rejected(resource_limit_exceeded(specification, depth))) :-
    prefix_view_exceeds_depth(SpecificationView, 16),
    !.
exhausted_prefix_status(
        _Input, _SpecificationView, ProgramView,
        rejected(resource_limit_exceeded(program, depth))) :-
    prefix_view_exceeds_depth(ProgramView, 16),
    !.
exhausted_prefix_status(
        Input, _SpecificationView, _ProgramView,
        rejected(resource_limit_exceeded(Input, cells))).

prefix_view_has_cycle(prefix_cycle) :-
    !.
prefix_view_has_cycle(prefix_compound(_Name, Arguments)) :-
    prefix_arguments_have_cycle(Arguments).

prefix_arguments_have_cycle([Argument|_Arguments]) :-
    prefix_view_has_cycle(Argument),
    !.
prefix_arguments_have_cycle([_Argument|Arguments]) :-
    prefix_arguments_have_cycle(Arguments).

prefix_view_has_variable(prefix_variable) :-
    !.
prefix_view_has_variable(prefix_compound(_Name, Arguments)) :-
    prefix_arguments_have_variable(Arguments).

prefix_arguments_have_variable([Argument|_Arguments]) :-
    prefix_view_has_variable(Argument),
    !.
prefix_arguments_have_variable([_Argument|Arguments]) :-
    prefix_arguments_have_variable(Arguments).

prefix_specification_shape(View, Shape) :-
    prefix_default_specification(Default),
    prefix_overlay(View, Default, generic, SafeSpecification),
    specification_shape(
        SafeSpecification, _Data, Shape, _Fragment).

prefix_program_shape(View, Shape) :-
    prefix_default_program(Default),
    prefix_overlay(View, Default, generic, SafeProgram),
    program_shape(SafeProgram, _Data, Shape, _Fragment).

prefix_default_specification(
    specification_proposal(
        specification_id(prefix_specification),
        type_declarations([
            nominal_type(type_id(prefix_type))
        ]),
        binding(
            object_binder(
                binder_id(prefix_specification_binder),
                type_id(prefix_type)),
            equality(
                equality_id(prefix_equality),
                operands([
                    object_reference(
                        binder_id(prefix_specification_binder),
                        type_id(prefix_type)),
                    object_value(
                        atom_value(prefix_value),
                        type_id(prefix_type))
                ]))),
        definedness(
            definition_space_id(prefix_definition_space)),
        premises([premise_id(prefix_premise)]))).

prefix_default_program(
    program_proposal(
        program_id(prefix_program),
        signature(
            input(type_id(prefix_type)),
            output(type_id(prefix_type))),
        program_ast(
            object_binder(
                binder_id(prefix_program_binder),
                type_id(prefix_type)),
            object_reference(
                binder_id(prefix_program_binder),
                type_id(prefix_type))),
        definedness(
            definition_space_id(prefix_definition_space)),
        premises([premise_id(prefix_premise)]))).

prefix_overlay(prefix_uninspected, Default, _Context, Default) :-
    !.
prefix_overlay(prefix_variable, Default, _Context, Default) :-
    !.
prefix_overlay(prefix_cycle, Default, _Context, Default) :-
    !.
prefix_overlay(prefix_atomic(Value), _Default, _Context, Value) :-
    !.
prefix_overlay(
        prefix_compound(Name, ArgumentViews),
        Default, Context, Term) :-
    length(ArgumentViews, Arity),
    prefix_overlay_defaults(
        Name, Arity, Default, Context, DefaultArguments),
    prefix_overlay_arguments(
        ArgumentViews, DefaultArguments, Name, 1, Context,
        Arguments),
    compound_name_arguments(Term, Name, Arguments).

prefix_overlay_defaults(
        Name, Arity, Default, _Context, DefaultArguments) :-
    compound(Default),
    functor(Default, Name, Arity),
    !,
    compound_name_arguments(
        Default, Name, DefaultArguments).
prefix_overlay_defaults(
        '[|]', 2, _Default, list(ElementDefault),
        [ElementDefault, []]) :-
    !.
prefix_overlay_defaults(
        Name, Arity, _Default, _Context, DefaultArguments) :-
    prefix_observed_default(Name, Arity, ObservedDefault),
    !,
    compound_name_arguments(
        ObservedDefault, Name, DefaultArguments).
prefix_overlay_defaults(
        _Name, Arity, _Default, _Context, DefaultArguments) :-
    prefix_generic_defaults(Arity, DefaultArguments).

prefix_observed_default(
        equality, 1, equality(missing)).
prefix_observed_default(
        lambda, 2,
        lambda(
            object_binder(
                binder_id(prefix_binder), type_id(prefix_type)),
            prefix_body)).
prefix_observed_default(
        quantifier, 3,
        quantifier(
            forall,
            object_binder(
                binder_id(prefix_binder), type_id(prefix_type)),
            prefix_body)).
prefix_observed_default(
        nested_binder, 3,
        nested_binder(
            object_binder(
                binder_id(prefix_first_binder), type_id(prefix_type)),
            object_binder(
                binder_id(prefix_second_binder), type_id(prefix_type)),
            prefix_body)).
prefix_observed_default(
        operation_application, 2,
        operation_application(
            operation_id(prefix_operation), [])).

prefix_generic_defaults(0, []) :-
    !.
prefix_generic_defaults(Count, [prefix_safe|Defaults]) :-
    NextCount is Count - 1,
    prefix_generic_defaults(NextCount, Defaults).

prefix_overlay_arguments([], [], _Name, _Index, _Context, []).
prefix_overlay_arguments(
        [View|Views], [Default|Defaults],
        Name, Index, Context, [Argument|Arguments]) :-
    prefix_child_context(
        Name, Index, Context, ChildContext),
    prefix_overlay(
        View, Default, ChildContext, Argument),
    NextIndex is Index + 1,
    prefix_overlay_arguments(
        Views, Defaults, Name, NextIndex, Context, Arguments).

prefix_child_context(
        type_declarations, 1, _Context,
        list(nominal_type(type_id(prefix_type)))) :-
    !.
prefix_child_context(
        operands, 1, _Context,
        list(object_reference(
            binder_id(prefix_binder), type_id(prefix_type)))) :-
    !.
prefix_child_context(
        premises, 1, _Context,
        list(premise_id(prefix_premise))) :-
    !.
prefix_child_context(
        operation_application, 2, _Context,
        list(prefix_argument)) :-
    !.
prefix_child_context(
        '[|]', 2, list(ElementDefault),
        list(ElementDefault)) :-
    !.
prefix_child_context(
        _Name, _Index, _Context, generic).

prefix_view_exceeds_depth(View, Limit) :-
    prefix_view_depth_status(
        View, 1, Limit, exceeded).

prefix_view_depth_status(
        prefix_uninspected, _Depth, _Limit, clear) :-
    !.
prefix_view_depth_status(
        _View, Depth, Limit, exceeded) :-
    Depth > Limit,
    !.
prefix_view_depth_status(
        prefix_compound(_Name, Arguments), Depth, Limit, Status) :-
    !,
    NextDepth is Depth + 1,
    prefix_argument_depth_status(
        Arguments, NextDepth, Limit, Status).
prefix_view_depth_status(
        _View, _Depth, _Limit, clear).

prefix_argument_depth_status(
        [], _Depth, _Limit, clear) :-
    !.
prefix_argument_depth_status(
        [Argument|Arguments], Depth, Limit, Status) :-
    prefix_view_depth_status(
        Argument, Depth, Limit, ArgumentStatus),
    continue_prefix_depth_status(
        ArgumentStatus, Arguments, Depth, Limit, Status).

continue_prefix_depth_status(
        exceeded, _Arguments, _Depth, _Limit, exceeded) :-
    !.
continue_prefix_depth_status(
        clear, Arguments, Depth, Limit, Status) :-
    prefix_argument_depth_status(
        Arguments, Depth, Limit, Status).

choose_structural_status(cycle, _ProgramCycle,
                         _SpecificationVariable, _ProgramVariable,
                         _SpecificationShape, _ProgramShape,
                         _ResourceStatus,
                         _SpecificationFragment, _ProgramFragment,
                         _SpecificationData, _ProgramData,
                         rejected(cyclic_input(specification))) :-
    !.
choose_structural_status(_SpecificationCycle, cycle,
                         _SpecificationVariable, _ProgramVariable,
                         _SpecificationShape, _ProgramShape,
                         _ResourceStatus,
                         _SpecificationFragment, _ProgramFragment,
                         _SpecificationData, _ProgramData,
                         rejected(cyclic_input(program))) :-
    !.
choose_structural_status(_SpecificationCycle, _ProgramCycle,
                         variable, _ProgramVariable,
                         _SpecificationShape, _ProgramShape,
                         _ResourceStatus,
                         _SpecificationFragment, _ProgramFragment,
                         _SpecificationData, _ProgramData,
                         rejected(non_ground_input(specification))) :-
    !.
choose_structural_status(_SpecificationCycle, _ProgramCycle,
                         _SpecificationVariable, variable,
                         _SpecificationShape, _ProgramShape,
                         _ResourceStatus,
                         _SpecificationFragment, _ProgramFragment,
                         _SpecificationData, _ProgramData,
                         rejected(non_ground_input(program))) :-
    !.
choose_structural_status(_SpecificationCycle, _ProgramCycle,
                         _SpecificationVariable, _ProgramVariable,
                         malformed(Field), _ProgramShape,
                         _ResourceStatus,
                         _SpecificationFragment, _ProgramFragment,
                         _SpecificationData, _ProgramData,
                         rejected(malformed_shape(specification, Field))) :-
    !.
choose_structural_status(_SpecificationCycle, _ProgramCycle,
                         _SpecificationVariable, _ProgramVariable,
                         _SpecificationShape, malformed(Field),
                         _ResourceStatus,
                         _SpecificationFragment, _ProgramFragment,
                         _SpecificationData, _ProgramData,
                         rejected(malformed_shape(program, Field))) :-
    !.
choose_structural_status(_SpecificationCycle, _ProgramCycle,
                         _SpecificationVariable, _ProgramVariable,
                         _SpecificationShape, _ProgramShape,
                         exceeded(Input, Limit),
                         _SpecificationFragment, _ProgramFragment,
                         _SpecificationData, _ProgramData,
                         rejected(resource_limit_exceeded(Input, Limit))) :-
    !.
choose_structural_status(_SpecificationCycle, _ProgramCycle,
                         _SpecificationVariable, _ProgramVariable,
                         _SpecificationShape, _ProgramShape,
                         _ResourceStatus,
                         fragment(Construct), _ProgramFragment,
                         _SpecificationData, _ProgramData,
                         rejected(out_of_fragment(Construct))) :-
    !.
choose_structural_status(_SpecificationCycle, _ProgramCycle,
                         _SpecificationVariable, _ProgramVariable,
                         _SpecificationShape, _ProgramShape,
                         _ResourceStatus,
                         _SpecificationFragment, fragment(Construct),
                         _SpecificationData, _ProgramData,
                         rejected(out_of_fragment(Construct))) :-
    !.
choose_structural_status(_SpecificationCycle, _ProgramCycle,
                         _SpecificationVariable, _ProgramVariable,
                         _SpecificationShape, _ProgramShape,
                         _ResourceStatus,
                         _SpecificationFragment, _ProgramFragment,
                         SpecificationData, ProgramData,
                         closed(SpecificationData, ProgramData)).

proposal_cycle_status(Proposal, Status) :-
    scan_proposal_fields(cycle, Proposal, ScanStatus),
    cycle_scan_status(ScanStatus, Status).

cycle_scan_status(found, cycle) :-
    !.
cycle_scan_status(_ScanStatus, clear).

proposal_variable_status(Proposal, Status) :-
    scan_proposal_fields(variable, Proposal, ScanStatus),
    variable_scan_status(ScanStatus, Status).

variable_scan_status(found, variable) :-
    !.
variable_scan_status(_ScanStatus, clear).

scan_proposal_fields(Mode, Proposal, Status) :-
    scan_one_field(Mode, Proposal, 1, First),
    continue_field_scan(First, Mode, Proposal, 2, Second),
    continue_field_scan(Second, Mode, Proposal, 3, Third),
    continue_field_scan(Third, Mode, Proposal, 4, Fourth),
    continue_field_scan(Fourth, Mode, Proposal, 5, Status).

continue_field_scan(found, _Mode, _Proposal, _Index, found) :-
    !.
continue_field_scan(_Earlier, Mode, Proposal, Index, Status) :-
    scan_one_field(Mode, Proposal, Index, Status).

scan_one_field(Mode, Proposal, Index, Status) :-
    arg(Index, Proposal, Field),
    scan_priority_term(Mode, Field, [Proposal], 2, 0, _Cells, Status).

scan_priority_term(cycle, Term, Ancestors, Depth, Cells0, Cells, Status) :-
    scan_cycle_term(Term, Ancestors, Depth, Cells0, Cells, Status).
scan_priority_term(variable, Term, Ancestors, Depth, Cells0, Cells, Status) :-
    scan_variable_term(Term, Ancestors, Depth, Cells0, Cells, Status).

scan_cycle_term(Term, _Ancestors, _Depth, Cells0, Cells, clear) :-
    var(Term),
    !,
    priority_cell(Cells0, Cells, _).
scan_cycle_term(Term, _Ancestors, _Depth, Cells0, Cells, Status) :-
    atomic(Term),
    !,
    priority_cell(Cells0, Cells, Status).
scan_cycle_term(Term, Ancestors, _Depth, Cells, Cells, found) :-
    identity_member(Term, Ancestors),
    !.
scan_cycle_term(Term, Ancestors, Depth, Cells0, Cells, Status) :-
    priority_cell(Cells0, Cells1, CellStatus),
    continue_cycle_cell(
        CellStatus, Term, Ancestors, Depth, Cells1, Cells, Status).

continue_cycle_cell(bounded, _Term, _Ancestors, _Depth, Cells, Cells,
                    bounded) :-
    !.
continue_cycle_cell(_CellStatus, Term, Ancestors, Depth, Cells0, Cells,
                    Status) :-
    functor(Term, _Name, Arity),
    NextDepth is Depth + 1,
    scan_cycle_arguments(
        1, Arity, Term, [Term|Ancestors], NextDepth, Cells0, Cells,
        Status).

scan_cycle_arguments(Index, Arity, _Term, _Ancestors, _Depth,
                     Cells, Cells, clear) :-
    Index > Arity,
    !.
scan_cycle_arguments(Index, Arity, Term, Ancestors, Depth,
                     Cells0, Cells, Status) :-
    arg(Index, Term, Argument),
    scan_cycle_term(
        Argument, Ancestors, Depth, Cells0, Cells1, ArgumentStatus),
    continue_cycle_arguments(
        ArgumentStatus, Index, Arity, Term, Ancestors, Depth,
        Cells1, Cells, Status).

continue_cycle_arguments(found, _Index, _Arity, _Term, _Ancestors, _Depth,
                         Cells, Cells, found) :-
    !.
continue_cycle_arguments(bounded, _Index, _Arity, _Term, _Ancestors,
                         _Depth, Cells, Cells, bounded) :-
    !.
continue_cycle_arguments(_ArgumentStatus, Index, Arity, Term, Ancestors,
                         Depth, Cells0, Cells, Status) :-
    NextIndex is Index + 1,
    scan_cycle_arguments(
        NextIndex, Arity, Term, Ancestors, Depth, Cells0, Cells, Status).

scan_variable_term(Term, _Ancestors, _Depth, Cells0, Cells, found) :-
    var(Term),
    !,
    priority_cell(Cells0, Cells, _).
scan_variable_term(Term, _Ancestors, _Depth, Cells0, Cells, Status) :-
    atomic(Term),
    !,
    priority_cell(Cells0, Cells, Status).
scan_variable_term(Term, Ancestors, _Depth, Cells, Cells, clear) :-
    identity_member(Term, Ancestors),
    !.
scan_variable_term(Term, Ancestors, Depth, Cells0, Cells, Status) :-
    priority_cell(Cells0, Cells1, CellStatus),
    continue_variable_cell(
        CellStatus, Term, Ancestors, Depth, Cells1, Cells, Status).

continue_variable_cell(bounded, _Term, _Ancestors, _Depth, Cells, Cells,
                       bounded) :-
    !.
continue_variable_cell(_CellStatus, Term, Ancestors, Depth, Cells0, Cells,
                       Status) :-
    functor(Term, _Name, Arity),
    NextDepth is Depth + 1,
    scan_variable_arguments(
        1, Arity, Term, [Term|Ancestors], NextDepth, Cells0, Cells,
        Status).

scan_variable_arguments(Index, Arity, _Term, _Ancestors, _Depth,
                        Cells, Cells, clear) :-
    Index > Arity,
    !.
scan_variable_arguments(Index, Arity, Term, Ancestors, Depth,
                        Cells0, Cells, Status) :-
    arg(Index, Term, Argument),
    scan_variable_term(
        Argument, Ancestors, Depth, Cells0, Cells1, ArgumentStatus),
    continue_variable_arguments(
        ArgumentStatus, Index, Arity, Term, Ancestors, Depth,
        Cells1, Cells, Status).

continue_variable_arguments(found, _Index, _Arity, _Term, _Ancestors,
                            _Depth, Cells, Cells, found) :-
    !.
continue_variable_arguments(bounded, _Index, _Arity, _Term, _Ancestors,
                            _Depth, Cells, Cells, bounded) :-
    !.
continue_variable_arguments(_ArgumentStatus, Index, Arity, Term, Ancestors,
                            Depth, Cells0, Cells, Status) :-
    NextIndex is Index + 1,
    scan_variable_arguments(
        NextIndex, Arity, Term, Ancestors, Depth, Cells0, Cells, Status).

priority_cell(Cells0, Cells, Status) :-
    Cells1 is Cells0 + 1,
    priority_cell_result(Cells1, Cells, Status).

priority_cell_result(Cells1, Cells1, bounded) :-
    Cells1 > 513,
    !.
priority_cell_result(Cells1, Cells1, clear).

identity_member(Term, [Ancestor|_Rest]) :-
    Term == Ancestor,
    !.
identity_member(Term, [_Ancestor|Rest]) :-
    identity_member(Term, Rest).

specification_shape(Specification, Data, Shape, Fragment) :-
    Specification =
        specification_proposal(
            SpecificationIdTerm,
            TypeDeclarationsTerm,
            BindingTerm,
            DefinednessTerm,
            PremisesTerm),
    identifier_shape(
        SpecificationIdTerm, specification_id,
        SpecificationId, SpecificationIdStatus),
    type_declarations_shape(
        TypeDeclarationsTerm, TypeId, TypeStatus),
    binding_shape(
        BindingTerm, BinderId, BinderType, EqualityData,
        BinderStatus, EqualityStatus, EqualityFragment),
    definedness_shape(
        DefinednessTerm, DefinednessData, DefinednessStatus),
    premises_shape(
        PremisesTerm, PremiseId, PremisesStatus),
    first_specification_shape_error(
        SpecificationIdStatus, TypeStatus, BinderStatus, EqualityStatus,
        DefinednessStatus, PremisesStatus, Shape),
    fragment_status(EqualityFragment, Fragment),
    Data =
        spec_data(
            SpecificationId, TypeId, BinderId, BinderType,
            EqualityData, DefinednessData, PremiseId).

program_shape(Program, Data, Shape, Fragment) :-
    Program =
        program_proposal(
            ProgramIdTerm,
            SignatureTerm,
            ProgramAstTerm,
            DefinednessTerm,
            PremisesTerm),
    identifier_shape(
        ProgramIdTerm, program_id, ProgramId, ProgramIdStatus),
    signature_shape(
        SignatureTerm, InputType, OutputType, SignatureStatus),
    program_ast_shape(
        ProgramAstTerm, BinderId, BinderType, ExpressionData,
        BinderStatus, ProgramAstStatus, ProgramFragment),
    definedness_shape(
        DefinednessTerm, DefinednessData, DefinednessStatus),
    premises_shape(
        PremisesTerm, PremiseId, PremisesStatus),
    first_program_shape_error(
        ProgramIdStatus, SignatureStatus, BinderStatus, ProgramAstStatus,
        DefinednessStatus, PremisesStatus, Shape),
    fragment_status(ProgramFragment, Fragment),
    Data =
        program_data(
            ProgramId, InputType, OutputType, BinderId, BinderType,
            ExpressionData, DefinednessData, PremiseId).

fragment_status(none, none) :-
    !.
fragment_status(Construct, fragment(Construct)).

first_specification_shape_error(malformed(Field), _TypeStatus,
                                _BinderStatus, _EqualityStatus,
                                _DefinednessStatus, _PremisesStatus,
                                malformed(Field)) :-
    !.
first_specification_shape_error(_SpecificationIdStatus, malformed(Field),
                                _BinderStatus, _EqualityStatus,
                                _DefinednessStatus, _PremisesStatus,
                                malformed(Field)) :-
    !.
first_specification_shape_error(_SpecificationIdStatus, _TypeStatus,
                                malformed(Field), _EqualityStatus,
                                _DefinednessStatus, _PremisesStatus,
                                malformed(Field)) :-
    !.
first_specification_shape_error(_SpecificationIdStatus, _TypeStatus,
                                _BinderStatus, malformed(Field),
                                _DefinednessStatus, _PremisesStatus,
                                malformed(Field)) :-
    !.
first_specification_shape_error(_SpecificationIdStatus, _TypeStatus,
                                _BinderStatus, _EqualityStatus,
                                malformed(Field), _PremisesStatus,
                                malformed(Field)) :-
    !.
first_specification_shape_error(_SpecificationIdStatus, _TypeStatus,
                                _BinderStatus, _EqualityStatus,
                                _DefinednessStatus, malformed(Field),
                                malformed(Field)) :-
    !.
first_specification_shape_error(_SpecificationIdStatus, _TypeStatus,
                                _BinderStatus, _EqualityStatus,
                                _DefinednessStatus, _PremisesStatus,
                                ok).

first_program_shape_error(malformed(Field), _SignatureStatus,
                          _BinderStatus, _ProgramAstStatus,
                          _DefinednessStatus, _PremisesStatus,
                          malformed(Field)) :-
    !.
first_program_shape_error(_ProgramIdStatus, malformed(Field),
                          _BinderStatus, _ProgramAstStatus,
                          _DefinednessStatus, _PremisesStatus,
                          malformed(Field)) :-
    !.
first_program_shape_error(_ProgramIdStatus, _SignatureStatus,
                          malformed(Field), _ProgramAstStatus,
                          _DefinednessStatus, _PremisesStatus,
                          malformed(Field)) :-
    !.
first_program_shape_error(_ProgramIdStatus, _SignatureStatus,
                          _BinderStatus, malformed(Field),
                          _DefinednessStatus, _PremisesStatus,
                          malformed(Field)) :-
    !.
first_program_shape_error(_ProgramIdStatus, _SignatureStatus,
                          _BinderStatus, _ProgramAstStatus,
                          malformed(Field), _PremisesStatus,
                          malformed(Field)) :-
    !.
first_program_shape_error(_ProgramIdStatus, _SignatureStatus,
                          _BinderStatus, _ProgramAstStatus,
                          _DefinednessStatus, malformed(Field),
                          malformed(Field)) :-
    !.
first_program_shape_error(_ProgramIdStatus, _SignatureStatus,
                          _BinderStatus, _ProgramAstStatus,
                          _DefinednessStatus, _PremisesStatus,
                          ok).

identifier_shape(Term, ExpectedFunctor, Payload, Status) :-
    (   compound(Term),
        functor(Term, ExpectedFunctor, 1)
    ->  arg(1, Term, Payload),
        identifier_payload_shape(Payload, Status)
    ;   Payload = invalid,
        Status = malformed(identifier)
    ).

identifier_payload_shape(Payload, ok) :-
    atom(Payload),
    atom_length(Payload, Length),
    Length > 0,
    !.
identifier_payload_shape(_Payload, malformed(scalar)).

type_declarations_shape(Term, TypeId, Status) :-
    (   compound(Term),
        functor(Term, type_declarations, 1)
    ->  arg(1, Term, Declarations),
        collection_prefix(Declarations, Collection),
        type_declaration_collection(Collection, TypeId, Status)
    ;   TypeId = invalid,
        Status = malformed(type_declarations)
    ).

type_declaration_collection(one(NominalType), TypeId, Status) :-
    !,
    nominal_type_shape(NominalType, TypeId, Status).
type_declaration_collection(improper, invalid, malformed(collection)) :-
    !.
type_declaration_collection(
        over_limit(First, Second, Third, TailStatus),
        oversized,
        Status) :-
    !,
    nominal_type_shape(First, _FirstTypeId, FirstStatus),
    nominal_type_shape(Second, _SecondTypeId, SecondStatus),
    nominal_type_shape(Third, _ThirdTypeId, ThirdStatus),
    first_three_shape_status(
        FirstStatus, SecondStatus, ThirdStatus, ElementsStatus),
    over_limit_shape_status(ElementsStatus, TailStatus, Status).
type_declaration_collection(_Collection, invalid,
                            malformed(type_declarations)).

nominal_type_shape(Term, TypeId, Status) :-
    (   compound(Term),
        functor(Term, nominal_type, 1)
    ->  arg(1, Term, TypeIdTerm),
        identifier_shape(TypeIdTerm, type_id, TypeId, Status)
    ;   TypeId = invalid,
        Status = malformed(type_declarations)
    ).

binding_shape(Term, BinderId, BinderType, EqualityData,
              BinderStatus, EqualityStatus, Fragment) :-
    (   compound(Term),
        functor(Term, binding, 2)
    ->  arg(1, Term, BinderTerm),
        arg(2, Term, EqualityTerm),
        binder_shape(BinderTerm, BinderId, BinderType, BinderStatus),
        equality_shape(
            EqualityTerm, EqualityData, EqualityStatus, Fragment)
    ;   BinderId = invalid,
        BinderType = invalid,
        EqualityData = invalid,
        BinderStatus = malformed(binder),
        EqualityStatus = ok,
        Fragment = none
    ).

binder_shape(Term, BinderId, BinderType, Status) :-
    (   compound(Term),
        functor(Term, object_binder, 2)
    ->  arg(1, Term, BinderIdTerm),
        arg(2, Term, BinderTypeTerm),
        identifier_shape(
            BinderIdTerm, binder_id, BinderId, BinderIdStatus),
        identifier_shape(
            BinderTypeTerm, type_id, BinderType, BinderTypeStatus),
        first_two_shape_status(
            BinderIdStatus, BinderTypeStatus, Status)
    ;   BinderId = invalid,
        BinderType = invalid,
        Status = malformed(binder)
    ).

equality_shape(Term, missing, ok, none) :-
    compound(Term),
    functor(Term, equality, 1),
    arg(1, Term, EqualityState),
    structurally_equal(EqualityState, missing),
    !.
equality_shape(Term, Data, Status, none) :-
    compound(Term),
    functor(Term, equality, 2),
    !,
    arg(1, Term, EqualityIdTerm),
    arg(2, Term, OperandsTerm),
    identifier_shape(
        EqualityIdTerm, equality_id, EqualityId, EqualityIdStatus),
    operands_shape(OperandsTerm, OperandsData, OperandsStatus),
    first_two_shape_status(
        EqualityIdStatus, OperandsStatus, Status),
    equality_data(Status, EqualityId, OperandsData, Data).
equality_shape(Term, unsupported(Construct), Status, Construct) :-
    unsupported_shape(Term, Construct, UnsupportedStatus),
    unsupported_recognition_status(UnsupportedStatus, Status),
    !.
equality_shape(_Term, invalid, malformed(equality), none).

equality_data(ok, EqualityId, operands(Left, Right),
              equality_data(EqualityId, Left, Right)) :-
    !.
equality_data(_Status, _EqualityId, _Operands, invalid).

unsupported_recognition_status(ok, ok) :-
    !.
unsupported_recognition_status(malformed(Field), malformed(Field)).

operands_shape(Term, Data, Status) :-
    (   compound(Term),
        functor(Term, operands, 1)
    ->  arg(1, Term, Operands),
        collection_prefix(Operands, Collection),
        operand_collection(Collection, Data, Status)
    ;   Data = invalid,
        Status = malformed(operands)
    ).

operand_collection(two(LeftTerm, RightTerm), operands(Left, Right), Status) :-
    !,
    operand_shape(LeftTerm, Left, LeftStatus),
    operand_shape(RightTerm, Right, RightStatus),
    first_two_shape_status(LeftStatus, RightStatus, Status).
operand_collection(improper, invalid, malformed(collection)) :-
    !.
operand_collection(
        over_limit(FirstTerm, SecondTerm, ThirdTerm, TailStatus),
        oversized,
        Status) :-
    !,
    operand_shape(FirstTerm, _First, FirstStatus),
    operand_shape(SecondTerm, _Second, SecondStatus),
    operand_shape(ThirdTerm, _Third, ThirdStatus),
    first_three_shape_status(
        FirstStatus, SecondStatus, ThirdStatus, ElementsStatus),
    over_limit_shape_status(ElementsStatus, TailStatus, Status).
operand_collection(_Collection, invalid, malformed(operands)).

operand_shape(Term, reference(BinderId, TypeId), Status) :-
    compound(Term),
    functor(Term, object_reference, 2),
    !,
    arg(1, Term, BinderIdTerm),
    arg(2, Term, TypeIdTerm),
    identifier_shape(
        BinderIdTerm, binder_id, BinderId, BinderStatus),
    identifier_shape(
        TypeIdTerm, type_id, TypeId, TypeStatus),
    first_two_shape_status(BinderStatus, TypeStatus, Status).
operand_shape(Term, value(Value, TypeId), Status) :-
    compound(Term),
    functor(Term, object_value, 2),
    !,
    arg(1, Term, ValueTerm),
    arg(2, Term, TypeIdTerm),
    atom_value_shape(ValueTerm, Value, ValueStatus),
    identifier_shape(
        TypeIdTerm, type_id, TypeId, TypeStatus),
    first_two_shape_status(ValueStatus, TypeStatus, Status).
operand_shape(_Term, invalid, malformed(operands)).

atom_value_shape(Term, Value, Status) :-
    (   compound(Term),
        functor(Term, atom_value, 1)
    ->  arg(1, Term, Value),
        value_payload_shape(Value, Status)
    ;   Value = invalid,
        Status = malformed(operands)
    ).

value_payload_shape(Value, ok) :-
    atom(Value),
    atom_length(Value, Length),
    Length > 0,
    !.
value_payload_shape(_Value, malformed(scalar)).

definedness_shape(Term, missing, ok) :-
    compound(Term),
    functor(Term, definedness, 1),
    arg(1, Term, DefinednessState),
    structurally_equal(DefinednessState, missing),
    !.
definedness_shape(Term, defined(DefinitionSpaceId), Status) :-
    compound(Term),
    functor(Term, definedness, 1),
    !,
    arg(1, Term, DefinitionSpaceIdTerm),
    identifier_shape(
        DefinitionSpaceIdTerm, definition_space_id,
        DefinitionSpaceId, Status).
definedness_shape(_Term, invalid, malformed(definedness)).

premises_shape(Term, PremiseId, Status) :-
    (   compound(Term),
        functor(Term, premises, 1)
    ->  arg(1, Term, Premises),
        collection_prefix(Premises, Collection),
        premise_collection(Collection, PremiseId, Status)
    ;   PremiseId = invalid,
        Status = malformed(premises)
    ).

premise_collection(one(PremiseIdTerm), PremiseId, Status) :-
    !,
    identifier_shape(
        PremiseIdTerm, premise_id, PremiseId, Status).
premise_collection(improper, invalid, malformed(collection)) :-
    !.
premise_collection(
        over_limit(FirstTerm, SecondTerm, ThirdTerm, TailStatus),
        oversized,
        Status) :-
    !,
    identifier_shape(
        FirstTerm, premise_id, _FirstPremiseId, FirstStatus),
    identifier_shape(
        SecondTerm, premise_id, _SecondPremiseId, SecondStatus),
    identifier_shape(
        ThirdTerm, premise_id, _ThirdPremiseId, ThirdStatus),
    first_three_shape_status(
        FirstStatus, SecondStatus, ThirdStatus, ElementsStatus),
    over_limit_shape_status(ElementsStatus, TailStatus, Status).
premise_collection(_Collection, invalid, malformed(premises)).

signature_shape(Term, InputType, OutputType, Status) :-
    (   compound(Term),
        functor(Term, signature, 2)
    ->  arg(1, Term, InputTerm),
        arg(2, Term, OutputTerm),
        signature_endpoint_shape(
            InputTerm, input, InputType, InputStatus),
        signature_endpoint_shape(
            OutputTerm, output, OutputType, OutputStatus),
        first_two_shape_status(InputStatus, OutputStatus, Status)
    ;   InputType = invalid,
        OutputType = invalid,
        Status = malformed(signature)
    ).

signature_endpoint_shape(Term, Direction, TypeId, Status) :-
    (   compound(Term),
        functor(Term, Direction, 1)
    ->  arg(1, Term, TypeIdTerm),
        identifier_shape(TypeIdTerm, type_id, TypeId, Status)
    ;   TypeId = invalid,
        Status = malformed(signature)
    ).

program_ast_shape(Term, BinderId, BinderType, ExpressionData,
                  BinderStatus, ProgramAstStatus, Fragment) :-
    (   compound(Term),
        functor(Term, program_ast, 2)
    ->  arg(1, Term, BinderTerm),
        arg(2, Term, ExpressionTerm),
        binder_shape(BinderTerm, BinderId, BinderType, BinderStatus),
        program_expression_shape(
            ExpressionTerm, ExpressionData, ProgramAstStatus, Fragment)
    ;   BinderId = invalid,
        BinderType = invalid,
        ExpressionData = invalid,
        BinderStatus = malformed(program_ast),
        ProgramAstStatus = ok,
        Fragment = none
    ).

program_expression_shape(Term, reference(BinderId, TypeId), Status, none) :-
    compound(Term),
    functor(Term, object_reference, 2),
    !,
    operand_shape(Term, reference(BinderId, TypeId), Status).
program_expression_shape(Term, unsupported(Construct), Status, Construct) :-
    unsupported_shape(Term, Construct, UnsupportedStatus),
    unsupported_recognition_status(UnsupportedStatus, Status),
    !.
program_expression_shape(_Term, invalid, malformed(program_ast), none).

unsupported_shape(Term, lambda, Status) :-
    compound(Term),
    functor(Term, lambda, 2),
    !,
    arg(1, Term, BinderTerm),
    binder_shape(BinderTerm, _BinderId, _BinderType, Status).
unsupported_shape(Term, quantifier, Status) :-
    compound(Term),
    functor(Term, quantifier, 3),
    arg(1, Term, QuantifierKind),
    structurally_equal(QuantifierKind, forall),
    !,
    arg(2, Term, BinderTerm),
    binder_shape(BinderTerm, _BinderId, _BinderType, Status).
unsupported_shape(Term, nested_binder, Status) :-
    compound(Term),
    functor(Term, nested_binder, 3),
    !,
    arg(1, Term, FirstBinder),
    arg(2, Term, SecondBinder),
    binder_shape(
        FirstBinder, _FirstBinderId, _FirstBinderType, FirstStatus),
    binder_shape(
        SecondBinder, _SecondBinderId, _SecondBinderType, SecondStatus),
    first_two_shape_status(FirstStatus, SecondStatus, Status).
unsupported_shape(Term, operation_application, Status) :-
    compound(Term),
    functor(Term, operation_application, 2),
    !,
    arg(1, Term, OperationIdTerm),
    arg(2, Term, Arguments),
    identifier_shape(
        OperationIdTerm, operation_id, _OperationId, OperationStatus),
    collection_prefix(Arguments, Collection),
    unsupported_argument_collection(Collection, CollectionStatus),
    first_two_shape_status(
        OperationStatus, CollectionStatus, Status).
unsupported_shape(Term, raw_host_goal, ok) :-
    compound(Term),
    functor(Term, call, 1),
    !.
unsupported_shape(Term, raw_host_clause, ok) :-
    compound(Term),
    functor(Term, (:-), 2).

unsupported_argument_collection(improper, malformed(collection)) :-
    !.
unsupported_argument_collection(
        over_limit(_First, _Second, _Third, improper),
        malformed(collection)) :-
    !.
unsupported_argument_collection(_Collection, ok).

first_two_shape_status(malformed(Field), _Second, malformed(Field)) :-
    !.
first_two_shape_status(_First, malformed(Field), malformed(Field)) :-
    !.
first_two_shape_status(_First, _Second, ok).

first_three_shape_status(First, Second, Third, Status) :-
    first_two_shape_status(First, Second, FirstTwoStatus),
    first_two_shape_status(FirstTwoStatus, Third, Status).

over_limit_shape_status(malformed(Field), _TailStatus, malformed(Field)) :-
    !.
over_limit_shape_status(_ElementsStatus, improper, malformed(collection)) :-
    !.
over_limit_shape_status(_ElementsStatus, _TailStatus, ok).

collection_prefix(Term, zero) :-
    atomic(Term),
    Term = [],
    !.
collection_prefix(Term, improper) :-
    var(Term),
    !.
collection_prefix(Term, improper) :-
    atomic(Term),
    !.
collection_prefix(Term, Result) :-
    functor(Term, '[|]', 2),
    !,
    arg(1, Term, First),
    arg(2, Term, Tail1),
    collection_after_first(Tail1, First, Result).
collection_prefix(_Term, improper).

collection_after_first(Tail, First, one(First)) :-
    atomic(Tail),
    Tail = [],
    !.
collection_after_first(Tail, _First, improper) :-
    var(Tail),
    !.
collection_after_first(Tail, _First, improper) :-
    atomic(Tail),
    !.
collection_after_first(Tail, First, Result) :-
    functor(Tail, '[|]', 2),
    !,
    arg(1, Tail, Second),
    arg(2, Tail, Tail2),
    collection_after_second(Tail2, First, Second, Result).
collection_after_first(_Tail, _First, improper).

collection_after_second(Tail, First, Second, two(First, Second)) :-
    atomic(Tail),
    Tail = [],
    !.
collection_after_second(Tail, _First, _Second, improper) :-
    var(Tail),
    !.
collection_after_second(Tail, _First, _Second, improper) :-
    atomic(Tail),
    !.
collection_after_second(
        Tail,
        First,
        Second,
        over_limit(First, Second, Third, TailStatus)) :-
    functor(Tail, '[|]', 2),
    !,
    arg(1, Tail, Third),
    arg(2, Tail, Tail3),
    collection_after_third(Tail3, TailStatus).
collection_after_second(_Tail, _First, _Second, improper).

collection_after_third(Tail, closed) :-
    atomic(Tail),
    Tail = [],
    !.
collection_after_third(Tail, improper) :-
    var(Tail),
    !.
collection_after_third(Tail, improper) :-
    atomic(Tail),
    !.
collection_after_third(Tail, continued) :-
    functor(Tail, '[|]', 2),
    !.
collection_after_third(_Tail, improper).

proposal_resource_status(Specification, Program, Status) :-
    depth_status(Specification, 16, SpecificationDepth),
    depth_status(Program, 16, ProgramDepth),
    cell_status(Specification, Program, CellStatus),
    list_status(Specification, SpecificationList),
    list_status(Program, ProgramList),
    scalar_status(Specification, SpecificationScalar),
    scalar_status(Program, ProgramScalar),
    choose_resource_status(
        SpecificationDepth, ProgramDepth, CellStatus,
        SpecificationList, ProgramList,
        SpecificationScalar, ProgramScalar,
        Status).

choose_resource_status(exceeded, _ProgramDepth, _CellStatus,
                       _SpecificationList, _ProgramList,
                       _SpecificationScalar, _ProgramScalar,
                       exceeded(specification, depth)) :-
    !.
choose_resource_status(_SpecificationDepth, exceeded, _CellStatus,
                       _SpecificationList, _ProgramList,
                       _SpecificationScalar, _ProgramScalar,
                       exceeded(program, depth)) :-
    !.
choose_resource_status(_SpecificationDepth, _ProgramDepth,
                       exceeded(Input), _SpecificationList, _ProgramList,
                       _SpecificationScalar, _ProgramScalar,
                       exceeded(Input, cells)) :-
    !.
choose_resource_status(_SpecificationDepth, _ProgramDepth, _CellStatus,
                       exceeded, _ProgramList,
                       _SpecificationScalar, _ProgramScalar,
                       exceeded(specification, list)) :-
    !.
choose_resource_status(_SpecificationDepth, _ProgramDepth, _CellStatus,
                       _SpecificationList, exceeded,
                       _SpecificationScalar, _ProgramScalar,
                       exceeded(program, list)) :-
    !.
choose_resource_status(_SpecificationDepth, _ProgramDepth, _CellStatus,
                       _SpecificationList, _ProgramList,
                       exceeded(identifier), _ProgramScalar,
                       exceeded(specification, identifier_scalar)) :-
    !.
choose_resource_status(_SpecificationDepth, _ProgramDepth, _CellStatus,
                       _SpecificationList, _ProgramList,
                       exceeded(value), _ProgramScalar,
                       exceeded(specification, value_scalar)) :-
    !.
choose_resource_status(_SpecificationDepth, _ProgramDepth, _CellStatus,
                       _SpecificationList, _ProgramList,
                       _SpecificationScalar, exceeded(identifier),
                       exceeded(program, identifier_scalar)) :-
    !.
choose_resource_status(_SpecificationDepth, _ProgramDepth, _CellStatus,
                       _SpecificationList, _ProgramList,
                       _SpecificationScalar, exceeded(value),
                       exceeded(program, value_scalar)) :-
    !.
choose_resource_status(_SpecificationDepth, _ProgramDepth, _CellStatus,
                       _SpecificationList, _ProgramList,
                       _SpecificationScalar, _ProgramScalar,
                       clear).

depth_status(Term, Limit, Status) :-
    depth_scan(Term, [], 1, Limit, ScanStatus),
    depth_scan_status(ScanStatus, Status).

depth_scan_status(exceeded, exceeded) :-
    !.
depth_scan_status(_ScanStatus, clear).

depth_scan(_Term, _Ancestors, Depth, Limit, exceeded) :-
    Depth > Limit,
    !.
depth_scan(Term, _Ancestors, _Depth, _Limit, clear) :-
    var(Term),
    !.
depth_scan(Term, _Ancestors, _Depth, _Limit, clear) :-
    atomic(Term),
    !.
depth_scan(Term, Ancestors, _Depth, _Limit, clear) :-
    identity_member(Term, Ancestors),
    !.
depth_scan(Term, Ancestors, Depth, Limit, Status) :-
    functor(Term, _Name, Arity),
    NextDepth is Depth + 1,
    depth_scan_arguments(
        1, Arity, Term, [Term|Ancestors], NextDepth, Limit, Status).

depth_scan_arguments(Index, Arity, _Term, _Ancestors, _Depth, _Limit,
                     clear) :-
    Index > Arity,
    !.
depth_scan_arguments(Index, Arity, Term, Ancestors, Depth, Limit, Status) :-
    arg(Index, Term, Argument),
    depth_scan(Argument, Ancestors, Depth, Limit, ArgumentStatus),
    continue_depth_arguments(
        ArgumentStatus, Index, Arity, Term, Ancestors, Depth, Limit,
        Status).

continue_depth_arguments(exceeded, _Index, _Arity, _Term, _Ancestors,
                         _Depth, _Limit, exceeded) :-
    !.
continue_depth_arguments(_ArgumentStatus, Index, Arity, Term, Ancestors,
                         Depth, Limit, Status) :-
    NextIndex is Index + 1,
    depth_scan_arguments(
        NextIndex, Arity, Term, Ancestors, Depth, Limit, Status).

cell_status(Specification, Program, Status) :-
    cell_scan(Specification, [], 0, SpecificationCells,
              SpecificationStatus),
    continue_program_cells(
        SpecificationStatus, Program, SpecificationCells, Status).

continue_program_cells(exceeded, _Program, _Cells,
                       exceeded(specification)) :-
    !.
continue_program_cells(_SpecificationStatus, Program, Cells0, Status) :-
    cell_scan(Program, [], Cells0, _Cells, ProgramStatus),
    program_cell_status(ProgramStatus, Status).

program_cell_status(exceeded, exceeded(program)) :-
    !.
program_cell_status(_ProgramStatus, clear).

cell_scan(_Term, _Ancestors, Cells, Cells, exceeded) :-
    Cells >= 512,
    !.
cell_scan(Term, _Ancestors, Cells0, Cells, clear) :-
    var(Term),
    !,
    Cells is Cells0 + 1.
cell_scan(Term, _Ancestors, Cells0, Cells, clear) :-
    atomic(Term),
    !,
    Cells is Cells0 + 1.
cell_scan(Term, Ancestors, Cells, Cells, exceeded) :-
    identity_member(Term, Ancestors),
    !.
cell_scan(Term, Ancestors, Cells0, Cells, Status) :-
    Cells1 is Cells0 + 1,
    functor(Term, _Name, Arity),
    cell_scan_arguments(
        1, Arity, Term, [Term|Ancestors], Cells1, Cells, Status).

cell_scan_arguments(Index, Arity, _Term, _Ancestors,
                    Cells, Cells, clear) :-
    Index > Arity,
    !.
cell_scan_arguments(Index, Arity, Term, Ancestors,
                    Cells0, Cells, Status) :-
    arg(Index, Term, Argument),
    cell_scan(Argument, Ancestors, Cells0, Cells1, ArgumentStatus),
    continue_cell_arguments(
        ArgumentStatus, Index, Arity, Term, Ancestors,
        Cells1, Cells, Status).

continue_cell_arguments(exceeded, _Index, _Arity, _Term, _Ancestors,
                        Cells, Cells, exceeded) :-
    !.
continue_cell_arguments(_ArgumentStatus, Index, Arity, Term, Ancestors,
                        Cells0, Cells, Status) :-
    NextIndex is Index + 1,
    cell_scan_arguments(
        NextIndex, Arity, Term, Ancestors, Cells0, Cells, Status).

list_status(Term, Status) :-
    list_scan(Term, [], ScanStatus),
    list_scan_status(ScanStatus, Status).

list_scan_status(exceeded, exceeded) :-
    !.
list_scan_status(_ScanStatus, clear).

list_scan(Term, _Ancestors, clear) :-
    var(Term),
    !.
list_scan(Term, _Ancestors, clear) :-
    atomic(Term),
    !.
list_scan(Term, Ancestors, clear) :-
    identity_member(Term, Ancestors),
    !.
list_scan(Term, _Ancestors, exceeded) :-
    functor(Term, '[|]', 2),
    collection_prefix(Term, Collection),
    collection_over_limit(Collection),
    !.
list_scan(Term, Ancestors, Status) :-
    functor(Term, _Name, Arity),
    list_scan_arguments(1, Arity, Term, [Term|Ancestors], Status).

list_scan_arguments(Index, Arity, _Term, _Ancestors, clear) :-
    Index > Arity,
    !.
list_scan_arguments(Index, Arity, Term, Ancestors, Status) :-
    arg(Index, Term, Argument),
    list_scan(Argument, Ancestors, ArgumentStatus),
    continue_list_arguments(
        ArgumentStatus, Index, Arity, Term, Ancestors, Status).

continue_list_arguments(exceeded, _Index, _Arity, _Term, _Ancestors,
                        exceeded) :-
    !.
continue_list_arguments(_ArgumentStatus, Index, Arity, Term, Ancestors,
                        Status) :-
    NextIndex is Index + 1,
    list_scan_arguments(
        NextIndex, Arity, Term, Ancestors, Status).

collection_over_limit(over_limit(_First, _Second, _Third, _TailStatus)).

scalar_status(Term, Status) :-
    scalar_scan(Term, [], ScanStatus),
    scalar_scan_status(ScanStatus, Status).

scalar_scan_status(exceeded(Kind), exceeded(Kind)) :-
    !.
scalar_scan_status(_ScanStatus, clear).

scalar_scan(Term, _Ancestors, clear) :-
    var(Term),
    !.
scalar_scan(Term, _Ancestors, clear) :-
    atomic(Term),
    !.
scalar_scan(Term, Ancestors, clear) :-
    identity_member(Term, Ancestors),
    !.
scalar_scan(Term, _Ancestors, exceeded(value)) :-
    functor(Term, atom_value, 1),
    arg(1, Term, Payload),
    atom(Payload),
    atom_length(Payload, Length),
    Length > 128,
    !.
scalar_scan(Term, _Ancestors, exceeded(identifier)) :-
    identifier_wrapper(Term),
    arg(1, Term, Payload),
    atom(Payload),
    atom_length(Payload, Length),
    Length > 64,
    !.
scalar_scan(Term, Ancestors, Status) :-
    functor(Term, _Name, Arity),
    scalar_scan_arguments(
        1, Arity, Term, [Term|Ancestors], Status).

scalar_scan_arguments(Index, Arity, _Term, _Ancestors, clear) :-
    Index > Arity,
    !.
scalar_scan_arguments(Index, Arity, Term, Ancestors, Status) :-
    arg(Index, Term, Argument),
    scalar_scan(Argument, Ancestors, ArgumentStatus),
    continue_scalar_arguments(
        ArgumentStatus, Index, Arity, Term, Ancestors, Status).

continue_scalar_arguments(exceeded(Kind), _Index, _Arity, _Term, _Ancestors,
                          exceeded(Kind)) :-
    !.
continue_scalar_arguments(_ArgumentStatus, Index, Arity, Term, Ancestors,
                          Status) :-
    NextIndex is Index + 1,
    scalar_scan_arguments(
        NextIndex, Arity, Term, Ancestors, Status).

identifier_wrapper(Term) :-
    functor(Term, specification_id, 1),
    !.
identifier_wrapper(Term) :-
    functor(Term, program_id, 1),
    !.
identifier_wrapper(Term) :-
    functor(Term, type_id, 1),
    !.
identifier_wrapper(Term) :-
    functor(Term, binder_id, 1),
    !.
identifier_wrapper(Term) :-
    functor(Term, equality_id, 1),
    !.
identifier_wrapper(Term) :-
    functor(Term, definition_space_id, 1),
    !.
identifier_wrapper(Term) :-
    functor(Term, premise_id, 1),
    !.
identifier_wrapper(Term) :-
    functor(Term, operation_id, 1).

semantic_status(SpecificationData, ProgramData, Status) :-
    SpecificationData =
        spec_data(
            SpecificationId, SpecificationType, SpecificationBinder,
            SpecificationBinderType, EqualityData,
            SpecificationDefinedness, SpecificationPremise),
    ProgramData =
        program_data(
            ProgramId, ProgramInputType, ProgramOutputType,
            ProgramBinder, ProgramBinderType, ProgramExpression,
            ProgramDefinedness, ProgramPremise),
    equality_order_status(EqualityData, EqualityOrderStatus),
    missing_status(
        EqualityData, SpecificationDefinedness, ProgramDefinedness,
        MissingStatus),
    scope_status(
        EqualityData, SpecificationBinder,
        ProgramExpression, ProgramBinder, ScopeStatus),
    type_status(
        SpecificationType, SpecificationBinderType, EqualityData,
        ProgramInputType, ProgramOutputType,
        ProgramBinderType, ProgramExpression, TypeStatus),
    compatibility_status(
        SpecificationType, ProgramInputType,
        SpecificationDefinedness, ProgramDefinedness,
        SpecificationPremise, ProgramPremise,
        CompatibilityStatus),
    choose_semantic_status(
        EqualityOrderStatus, MissingStatus, ScopeStatus, TypeStatus,
        CompatibilityStatus,
        SpecificationId, SpecificationType, SpecificationBinder,
        EqualityData, SpecificationDefinedness, SpecificationPremise,
        ProgramId, ProgramInputType, ProgramBinder, ProgramExpression,
        ProgramDefinedness,
        Status).

choose_semantic_status(rejected(Reason), _MissingStatus, _ScopeStatus,
                       _TypeStatus, _CompatibilityStatus,
                       _SpecificationId, _SpecificationType,
                       _SpecificationBinder, _EqualityData,
                       _SpecificationDefinedness, _SpecificationPremise,
                       _ProgramId, _ProgramInputType, _ProgramBinder,
                       _ProgramExpression, _ProgramDefinedness,
                       rejected(Reason)) :-
    !.
choose_semantic_status(_EqualityOrderStatus, rejected(Reason), _ScopeStatus,
                       _TypeStatus, _CompatibilityStatus,
                       _SpecificationId, _SpecificationType,
                       _SpecificationBinder, _EqualityData,
                       _SpecificationDefinedness, _SpecificationPremise,
                       _ProgramId, _ProgramInputType, _ProgramBinder,
                       _ProgramExpression, _ProgramDefinedness,
                       rejected(Reason)) :-
    !.
choose_semantic_status(_EqualityOrderStatus, _MissingStatus,
                       rejected(Reason), _TypeStatus, _CompatibilityStatus,
                       _SpecificationId, _SpecificationType,
                       _SpecificationBinder, _EqualityData,
                       _SpecificationDefinedness, _SpecificationPremise,
                       _ProgramId, _ProgramInputType, _ProgramBinder,
                       _ProgramExpression, _ProgramDefinedness,
                       rejected(Reason)) :-
    !.
choose_semantic_status(_EqualityOrderStatus, _MissingStatus, _ScopeStatus,
                       rejected(Reason), _CompatibilityStatus,
                       _SpecificationId, _SpecificationType,
                       _SpecificationBinder, _EqualityData,
                       _SpecificationDefinedness, _SpecificationPremise,
                       _ProgramId, _ProgramInputType, _ProgramBinder,
                       _ProgramExpression, _ProgramDefinedness,
                       rejected(Reason)) :-
    !.
choose_semantic_status(_EqualityOrderStatus, _MissingStatus, _ScopeStatus,
                       _TypeStatus, rejected(Reason),
                       _SpecificationId, _SpecificationType,
                       _SpecificationBinder, _EqualityData,
                       _SpecificationDefinedness, _SpecificationPremise,
                       _ProgramId, _ProgramInputType, _ProgramBinder,
                       _ProgramExpression, _ProgramDefinedness,
                       rejected(Reason)) :-
    !.
choose_semantic_status(_EqualityOrderStatus, _MissingStatus, _ScopeStatus,
                       _TypeStatus, _CompatibilityStatus,
                       SpecificationId, SpecificationType,
                       SpecificationBinder, EqualityData,
                       defined(DefinitionSpaceId), SpecificationPremise,
                       ProgramId, ProgramInputType, ProgramBinder,
                       ProgramExpression, _ProgramDefinedness,
                       validated(
                           validated_data(
                               SpecificationId, SpecificationType,
                               SpecificationBinder, EqualityData,
                               DefinitionSpaceId, SpecificationPremise,
                               ProgramId, ProgramInputType, ProgramBinder,
                               ProgramExpression))).

equality_order_status(
    equality_data(_EqualityId, value(_Value, _ValueType),
                  reference(_BinderId, _ReferenceType)),
    rejected(noncanonical_input(specification, operand_order))) :-
    !.
equality_order_status(_EqualityData, clear).

missing_status(missing, _SpecificationDefinedness, _ProgramDefinedness,
               rejected(missing_equality)) :-
    !.
missing_status(_EqualityData, missing, _ProgramDefinedness,
               rejected(missing_definedness(specification))) :-
    !.
missing_status(_EqualityData, _SpecificationDefinedness, missing,
               rejected(missing_definedness(program))) :-
    !.
missing_status(_EqualityData, _SpecificationDefinedness,
               _ProgramDefinedness, clear).

scope_status(
    equality_data(
        _EqualityId,
        reference(FirstBinderId, _FirstType),
        reference(SecondBinderId, _SecondType)),
    SpecificationBinder, _ProgramExpression, _ProgramBinder, Status) :-
    !,
    two_reference_scope_status(
        SpecificationBinder, FirstBinderId, SecondBinderId, Status).
scope_status(
    equality_data(_EqualityId, value(_FirstValue, _FirstType),
                  value(_SecondValue, _SecondType)),
    _SpecificationBinder, _ProgramExpression, _ProgramBinder,
    rejected(ill_scoped(
        missing_object_reference(specification)))) :-
    !.
scope_status(
    equality_data(_EqualityId,
                  reference(SpecificationReference, _ReferenceType),
                  value(_Value, _ValueType)),
    SpecificationBinder,
    reference(ProgramReference, _ProgramReferenceType),
    ProgramBinder,
    Status) :-
    !,
    one_reference_scope_status(
        specification, SpecificationBinder, SpecificationReference,
        SpecificationStatus),
    one_reference_scope_status(
        program, ProgramBinder, ProgramReference, ProgramStatus),
    first_scope_status(SpecificationStatus, ProgramStatus, Status).
scope_status(_EqualityData, _SpecificationBinder, _ProgramExpression,
             _ProgramBinder, clear).

two_reference_scope_status(Expected, First, _Second,
                           rejected(ill_scoped(
                               free_object_reference(
                                   specification,
                                   binder_id(Expected),
                                   binder_id(First))))) :-
    not_structurally_equal(Expected, First),
    !.
two_reference_scope_status(Expected, _First, Second,
                           rejected(ill_scoped(
                               free_object_reference(
                                   specification,
                                   binder_id(Expected),
                                   binder_id(Second))))) :-
    not_structurally_equal(Expected, Second),
    !.
two_reference_scope_status(Expected, _First, _Second,
                           rejected(ill_scoped(
                               duplicate_object_reference(
                                   specification,
                                   binder_id(Expected))))).

one_reference_scope_status(_Input, Expected, Actual, clear) :-
    structurally_equal(Expected, Actual),
    !.
one_reference_scope_status(Input, Expected, Actual,
                           rejected(ill_scoped(
                               free_object_reference(
                                   Input,
                                   binder_id(Expected),
                                   binder_id(Actual))))).

first_scope_status(rejected(Reason), _ProgramStatus, rejected(Reason)) :-
    !.
first_scope_status(_SpecificationStatus, rejected(Reason),
                   rejected(Reason)) :-
    !.
first_scope_status(_SpecificationStatus, _ProgramStatus, clear).

type_status(SpecificationType, SpecificationBinderType, EqualityData,
            ProgramInputType, ProgramOutputType,
            ProgramBinderType, ProgramExpression, Status) :-
    binder_type_status(
        specification, SpecificationType, SpecificationBinderType,
        SpecificationBinderStatus),
    binder_type_status(
        program, ProgramInputType, ProgramOutputType,
        ProgramOutputStatus),
    binder_type_status(
        program, ProgramInputType, ProgramBinderType,
        ProgramBinderStatus),
    equality_reference_type_status(
        SpecificationType, EqualityData, SpecificationReferenceStatus),
    program_reference_type_status(
        ProgramInputType, ProgramExpression, ProgramReferenceStatus),
    equality_operand_type_status(
        SpecificationType, EqualityData, EqualityOperandStatus),
    first_type_status(
        SpecificationBinderStatus, ProgramOutputStatus,
        ProgramBinderStatus, SpecificationReferenceStatus,
        ProgramReferenceStatus, EqualityOperandStatus,
        Status).

binder_type_status(_Input, Expected, Actual, clear) :-
    structurally_equal(Expected, Actual),
    !.
binder_type_status(Input, Expected, Actual,
                   rejected(ill_typed(
                       binder_type_mismatch(
                           Input,
                           type_id(Expected),
                           type_id(Actual))))).

equality_reference_type_status(
    Expected,
    equality_data(_EqualityId,
                  reference(_BinderId, Actual),
                  _Right),
    Status) :-
    !,
    reference_type_result(
        specification, Expected, Actual, Status).
equality_reference_type_status(_Expected, _EqualityData, clear).

program_reference_type_status(
    Expected, reference(_BinderId, Actual), Status) :-
    !,
    reference_type_result(program, Expected, Actual, Status).
program_reference_type_status(_Expected, _Expression, clear).

reference_type_result(_Input, Expected, Actual, clear) :-
    structurally_equal(Expected, Actual),
    !.
reference_type_result(Input, Expected, Actual,
                      rejected(ill_typed(
                          reference_type_mismatch(
                              Input,
                              type_id(Expected),
                              type_id(Actual))))).

equality_operand_type_status(
    Declared,
    equality_data(
        _EqualityId,
        reference(_BinderId, LeftType),
        value(_Value, RightType)),
    Status) :-
    !,
    equality_operand_type_result(
        Declared, LeftType, RightType, Status).
equality_operand_type_status(_Declared, _EqualityData, clear).

equality_operand_type_result(Declared, Left, Right, clear) :-
    structurally_equal(Declared, Left),
    structurally_equal(Declared, Right),
    !.
equality_operand_type_result(
    Declared, Left, Right,
    rejected(ill_typed(
        equality_operand_type_mismatch(
            type_id(Declared),
            type_id(Left),
            type_id(Right))))).

first_type_status(rejected(Reason), _ProgramOutputStatus,
                  _ProgramBinderStatus, _SpecificationReferenceStatus,
                  _ProgramReferenceStatus, _EqualityOperandStatus,
                  rejected(Reason)) :-
    !.
first_type_status(_SpecificationBinderStatus, rejected(Reason),
                  _ProgramBinderStatus, _SpecificationReferenceStatus,
                  _ProgramReferenceStatus, _EqualityOperandStatus,
                  rejected(Reason)) :-
    !.
first_type_status(_SpecificationBinderStatus, _ProgramOutputStatus,
                  rejected(Reason), _SpecificationReferenceStatus,
                  _ProgramReferenceStatus, _EqualityOperandStatus,
                  rejected(Reason)) :-
    !.
first_type_status(_SpecificationBinderStatus, _ProgramOutputStatus,
                  _ProgramBinderStatus, rejected(Reason),
                  _ProgramReferenceStatus, _EqualityOperandStatus,
                  rejected(Reason)) :-
    !.
first_type_status(_SpecificationBinderStatus, _ProgramOutputStatus,
                  _ProgramBinderStatus, _SpecificationReferenceStatus,
                  rejected(Reason), _EqualityOperandStatus,
                  rejected(Reason)) :-
    !.
first_type_status(_SpecificationBinderStatus, _ProgramOutputStatus,
                  _ProgramBinderStatus, _SpecificationReferenceStatus,
                  _ProgramReferenceStatus, rejected(Reason),
                  rejected(Reason)) :-
    !.
first_type_status(_SpecificationBinderStatus, _ProgramOutputStatus,
                  _ProgramBinderStatus, _SpecificationReferenceStatus,
                  _ProgramReferenceStatus, _EqualityOperandStatus,
                  clear).

compatibility_status(SpecificationType, ProgramType,
                     SpecificationDefinedness, ProgramDefinedness,
                     SpecificationPremise, ProgramPremise, Status) :-
    compatibility_type_status(
        SpecificationType, ProgramType, TypeStatus),
    compatibility_definedness_status(
        SpecificationDefinedness, ProgramDefinedness, DefinednessStatus),
    compatibility_premise_status(
        SpecificationPremise, ProgramPremise, PremiseStatus),
    first_compatibility_status(
        TypeStatus, DefinednessStatus, PremiseStatus, Status).

compatibility_type_status(Expected, Actual, clear) :-
    structurally_equal(Expected, Actual),
    !.
compatibility_type_status(Expected, Actual,
                          rejected(incompatible(
                              type,
                              type_id(Expected),
                              type_id(Actual)))).

compatibility_definedness_status(
    defined(Expected), defined(Actual), clear) :-
    structurally_equal(Expected, Actual),
    !.
compatibility_definedness_status(
    defined(Expected), defined(Actual),
    rejected(incompatible(
        definition_space,
        definition_space_id(Expected),
        definition_space_id(Actual)))) :-
    !.
compatibility_definedness_status(
    _SpecificationDefinedness, _ProgramDefinedness, clear).

compatibility_premise_status(Expected, Actual, clear) :-
    structurally_equal(Expected, Actual),
    !.
compatibility_premise_status(Expected, Actual,
                             rejected(incompatible(
                                 premise,
                                 premise_id(Expected),
                                 premise_id(Actual)))).

first_compatibility_status(rejected(Reason), _DefinednessStatus,
                           _PremiseStatus, rejected(Reason)) :-
    !.
first_compatibility_status(_TypeStatus, rejected(Reason),
                           _PremiseStatus, rejected(Reason)) :-
    !.
first_compatibility_status(_TypeStatus, _DefinednessStatus,
                           rejected(Reason), rejected(Reason)) :-
    !.
first_compatibility_status(_TypeStatus, _DefinednessStatus,
                           _PremiseStatus, clear).

structurally_equal(Left, Right) :-
    compare(=, Left, Right).

not_structurally_equal(Left, Right) :-
    compare(Order, Left, Right),
    different_order(Order).

different_order(<).
different_order(>).

authority_status(
    authority_assessment(Status, Audit),
    ValidatedData,
    AuthorityStatus) :-
    preclosure_audit_status(Audit, Preclosure),
    finish_authority_audit_status(
        Preclosure, Status, Audit, ValidatedData, AuthorityStatus).

preclosure_audit_status(
    audit(no_claim, no_policy, used([]), provenance([])),
    preclosure) :-
    !.
preclosure_audit_status(_Audit, closed).

finish_authority_audit_status(preclosure, Status, _Audit, _ValidatedData,
                              AuthorityStatus) :-
    !,
    preclosure_authority_status(Status, AuthorityStatus).
finish_authority_audit_status(
    closed, Status,
    audit(_ClaimId, _PolicyId, used(Items), provenance(_Provenance)),
    ValidatedData, AuthorityStatus) :-
    !,
    scope_identifiers(Items, EqualityIds, DefinitionSpaceIds, PremiseIds),
    expected_authority_scope(
        ValidatedData,
        ExpectedEqualityId, ExpectedDefinitionSpaceId, ExpectedPremiseId),
    authority_scope_status(
        EqualityIds, DefinitionSpaceIds, PremiseIds,
        ExpectedEqualityId, ExpectedDefinitionSpaceId, ExpectedPremiseId,
        ScopeStatus),
    finish_closed_authority_status(
        ScopeStatus, Status, ExpectedPremiseId, AuthorityStatus).
finish_authority_audit_status(
    closed, _Status, _Audit, _ValidatedData,
    rejected(malformed_shape(authority, root))).

preclosure_authority_status(rejected(non_ground_input),
                            rejected(non_ground_input(authority))) :-
    !.
preclosure_authority_status(rejected(cyclic_input),
                            rejected(cyclic_input(authority))) :-
    !.
preclosure_authority_status(rejected(resource_limit_exceeded),
                            rejected(resource_limit_exceeded(
                                authority, t002))) :-
    !.
preclosure_authority_status(_Status,
                            rejected(malformed_shape(authority, root))).

scope_identifiers([], [], [], []).
scope_identifiers([Item|Items], EqualityIds, DefinitionSpaceIds,
                  PremiseIds) :-
    scope_item(Item, EqualityHead, DefinitionSpaceHead, PremiseHead),
    scope_identifiers(
        Items, EqualityTail, DefinitionSpaceTail, PremiseTail),
    optional_scope_item(EqualityHead, EqualityTail, EqualityIds),
    optional_scope_item(
        DefinitionSpaceHead, DefinitionSpaceTail, DefinitionSpaceIds),
    optional_scope_item(PremiseHead, PremiseTail, PremiseIds).

scope_item(Item, present(Item), absent, absent) :-
    compound(Item),
    functor(Item, equality_id, 1),
    !.
scope_item(Item, absent, present(Item), absent) :-
    compound(Item),
    functor(Item, definition_space_id, 1),
    !.
scope_item(Item, absent, absent, present(Item)) :-
    compound(Item),
    functor(Item, premise_id, 1),
    !.
scope_item(_Item, absent, absent, absent).

optional_scope_item(present(Item), Tail, [Item|Tail]) :-
    !.
optional_scope_item(absent, Tail, Tail).

expected_authority_scope(
    validated_data(
        _SpecificationId, _SpecificationType, _SpecificationBinder,
        equality_data(EqualityId, _Left, _Right),
        DefinitionSpaceId, PremiseId,
        _ProgramId, _ProgramType, _ProgramBinder, _ProgramExpression),
    equality_id(EqualityId),
    definition_space_id(DefinitionSpaceId),
    premise_id(PremiseId)).

authority_scope_status(
    EqualityIds, DefinitionSpaceIds, PremiseIds,
    ExpectedEqualityId, ExpectedDefinitionSpaceId, ExpectedPremiseId,
    clear) :-
    structurally_equal(EqualityIds, [ExpectedEqualityId]),
    structurally_equal(DefinitionSpaceIds, [ExpectedDefinitionSpaceId]),
    structurally_equal(PremiseIds, [ExpectedPremiseId]),
    !.
authority_scope_status(
    EqualityIds, DefinitionSpaceIds, PremiseIds,
    ExpectedEqualityId, ExpectedDefinitionSpaceId, ExpectedPremiseId,
    rejected(
        authority_scope_mismatch(
            expected(
                ExpectedEqualityId,
                ExpectedDefinitionSpaceId,
                ExpectedPremiseId),
            found(
                EqualityIds,
                DefinitionSpaceIds,
                PremiseIds)))).

finish_closed_authority_status(rejected(Reason), _Status, _PremiseId,
                               rejected(Reason)) :-
    !.
finish_closed_authority_status(clear, accepted, _PremiseId, accepted) :-
    !.
finish_closed_authority_status(
    clear, rejected(inactive_premise(Id)), _PremiseId,
    rejected(inactive_premise(Id))) :-
    !.
finish_closed_authority_status(
    clear, rejected(untrusted_premise(Id)), _PremiseId,
    rejected(untrusted_premise(Id))) :-
    !.
finish_closed_authority_status(
    clear, rejected(Reason), _PremiseId,
    rejected(authority_rejected(Reason))) :-
    !.
finish_closed_authority_status(
    clear, unknown(Missing), PremiseId,
    unknown(PremiseId, Missing)) :-
    !.
finish_closed_authority_status(
    clear, _Status, _PremiseId,
    rejected(malformed_shape(authority, root))).

validated_pair(
    validated_data(
        SpecificationId, TypeId, SpecificationBinder,
        equality_data(
            EqualityId,
            reference(SpecificationReference, ReferenceType),
            value(Value, ValueType)),
        DefinitionSpaceId, PremiseId,
        ProgramId, ProgramType, ProgramBinder,
        reference(ProgramReference, ProgramReferenceType)),
    validated_pair(
        validated_specification(
            specification_id(SpecificationId),
            nominal_type(type_id(TypeId)),
            scoped_equality(
                object_binder(
                    binder_id(SpecificationBinder), type_id(TypeId)),
                equality_relation(
                    equality_id(EqualityId),
                    object_reference(
                        binder_id(SpecificationReference),
                        type_id(ReferenceType)),
                    object_value(
                        atom_value(Value),
                        type_id(ValueType)))),
            definition_space_id(DefinitionSpaceId),
            premise_id(PremiseId)),
        validated_program(
            program_id(ProgramId),
            program_signature(
                type_id(ProgramType), type_id(ProgramType)),
            scoped_program(
                object_binder(
                    binder_id(ProgramBinder), type_id(ProgramType)),
                object_reference(
                    binder_id(ProgramReference),
                    type_id(ProgramReferenceType))),
            definition_space_id(DefinitionSpaceId),
            premise_id(PremiseId)))).
