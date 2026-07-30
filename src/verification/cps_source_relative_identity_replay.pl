:- module(cps_source_relative_identity_replay,
          [ check_source_relative_identity_proof/5
          ]).

:- use_module('../ir/cps_ground_typed_equality_ir',
              [ validate_ground_typed_equality_pair/4
              ]).

/** <module> Bounded source-relative identity proof replay

This module checks one supplied proof proposal against one fresh accepted T003
pair. It constructs no proof, executes no Program, and gives no claim beyond
the exact local source-relative identity conclusion.
*/

%! check_source_relative_identity_proof(
%!     +SpecificationProposal,
%!     +ProgramProposal,
%!     +AuthoritySnapshot,
%!     +ProofProposal,
%!     -Result) is det.
%
%  Replay one bounded proof proposal without binding or executing any input.
%  Every input-mode invocation returns one finite ground Result.
check_source_relative_identity_proof(
        Specification, Program, Authority, Proof, Result) :-
    direct_proof_status(Proof, DirectStatus),
    finish_direct_proof_status(
        DirectStatus, Specification, Program, Authority, Proof, Result),
    !.

direct_proof_status(Proof, rejected(non_ground_input(proof))) :-
    var(Proof),
    !.
direct_proof_status(Proof, rejected(forged_accepted_form(proof))) :-
    forged_proof_root(Proof),
    !.
direct_proof_status(Proof, ready) :-
    compound(Proof),
    compound_name_arity(Proof, proof_proposal, 5),
    !.
direct_proof_status(_Proof, rejected(malformed_shape(proof, root))).

forged_proof_root(Proof) :-
    compound(Proof),
    compound_name_arity(Proof, Name, Arity),
    forged_proof_name_arity(Name, Arity).

forged_proof_name_arity(checked_proof, 5).
forged_proof_name_arity(proof_replay, 2).
forged_proof_name_arity(proof_audit, 3).

finish_direct_proof_status(
        rejected(Reason), _Specification, _Program, _Authority, _Proof,
        Result) :-
    preclosure_result(rejected(Reason), Result).
finish_direct_proof_status(
        ready, Specification, Program, Authority, Proof, Result) :-
    bounded_proof_status(Proof, StructuralStatus),
    finish_bounded_proof_status(
        StructuralStatus,
        Specification, Program, Authority, Proof, Result).

finish_bounded_proof_status(
        rejected(Reason),
        _Specification, _Program, _Authority, _Proof, Result) :-
    preclosure_result(rejected(Reason), Result).
finish_bounded_proof_status(
        resource(Resource),
        _Specification, _Program, _Authority, _Proof, Result) :-
    preclosure_result(resource_exhausted(proof(Resource)), Result).
finish_bounded_proof_status(
        closed,
        Specification, Program, Authority, Proof, Result) :-
    closed_proof_status(Proof, ClosedStatus),
    finish_closed_proof_status(
        ClosedStatus,
        Specification, Program, Authority, Proof, Result).

preclosure_result(
    Status,
    proof_replay(
        Status,
        proof_audit(
            proposal(no_proof),
            predecessor(not_checked),
            replay(not_checked)))).

closed_proof_status(Proof, unsupported(format_version)) :-
    Proof =
        proof_proposal(
            proof_format(Format), _ProofId, _Theory, _Steps, _RootStep),
    Format \== source_relative_identity_replay_v1,
    !.
closed_proof_status(Proof, unsupported(theory)) :-
    Proof =
        proof_proposal(
            _Format, _ProofId, theory(Theory), _Steps, _RootStep),
    Theory \== source_relative_identity_v1,
    !.
closed_proof_status(Proof, unsupported(rule)) :-
    proof_step_data(
        Proof, proof_step,
        _StepId, rule(Rule), _Dependencies, _References, _Conclusion),
    Rule \== source_relative_identity_replay_v1,
    !.
closed_proof_status(Proof, unsupported(conclusion_constructor)) :-
    proof_conclusion(Proof, Conclusion),
    compound_name_arity(Conclusion, Constructor, 4),
    Constructor \== source_relative_identity_replay,
    !.
closed_proof_status(Proof, unknown(Missing)) :-
    proof_step_data(
        Proof, proof_hole,
        StepId, no_rule, _Dependencies, no_references, _Conclusion),
    Missing = unchecked_evidence(proof_hole, StepId),
    !.
closed_proof_status(Proof, unknown(Missing)) :-
    proof_step_data(
        Proof, trusted_step,
        StepId, no_rule, _Dependencies, no_references, _Conclusion),
    Missing = unchecked_evidence(trusted_step, StepId),
    !.
closed_proof_status(_Proof, predecessor_required).

finish_closed_proof_status(
        unsupported(Feature),
        _Specification, _Program, _Authority, Proof, Result) :-
    closed_local_result(
        Proof,
        unsupported(Feature),
        unsupported(Feature),
        Result).
finish_closed_proof_status(
        unknown(Missing),
        _Specification, _Program, _Authority, Proof, Result) :-
    closed_local_result(
        Proof,
        unknown(Missing),
        unknown(Missing),
        Result).
finish_closed_proof_status(
        predecessor_required,
        Specification, Program, Authority, Proof, Result) :-
    validate_ground_typed_equality_pair(
        Specification, Program, Authority, Predecessor),
    finish_predecessor_result(Predecessor, Proof, Result).

closed_local_result(
        Proof, Status, ReplayDetail,
        proof_replay(
            Status,
            proof_audit(
                Proposal,
                predecessor(not_checked),
                replay(ReplayDetail)))) :-
    proof_proposal_descriptor(Proof, Proposal).

finish_predecessor_result(
        Predecessor, Proof,
        proof_replay(
            resource_exhausted(predecessor(t003, Input, Limit)),
            Audit)) :-
    Predecessor =
        ground_typed_equality_validation(
            rejected(resource_limit_exceeded(Input, Limit)),
            _PredecessorAudit),
    !,
    predecessor_audit(Proof, Predecessor, not_checked, Audit).
finish_predecessor_result(
        Predecessor, Proof,
        proof_replay(unknown(predecessor(t003, Missing)), Audit)) :-
    Predecessor =
        ground_typed_equality_validation(
            unknown(Missing), _PredecessorAudit),
    !,
    predecessor_audit(Proof, Predecessor, not_checked, Audit).
finish_predecessor_result(
        Predecessor, Proof,
        proof_replay(rejected(predecessor(t003, Reason)), Audit)) :-
    Predecessor =
        ground_typed_equality_validation(
            rejected(Reason), _PredecessorAudit),
    !,
    predecessor_audit(Proof, Predecessor, not_checked, Audit).
finish_predecessor_result(Predecessor, Proof, Result) :-
    accepted_predecessor_data(
        Predecessor,
        ProgramId, EqualityId, DefinitionSpaceId, PremiseId),
    replay_status(
        Proof,
        ProgramId, EqualityId, DefinitionSpaceId, PremiseId,
        ReplayStatus),
    finish_replay_status(
        ReplayStatus, Predecessor, Proof, Result).

accepted_predecessor_data(
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
    ProgramId, EqualityId, DefinitionSpaceId, PremiseId).

replay_status(
        Proof,
        ProgramId, EqualityId, DefinitionSpaceId, PremiseId,
        Status) :-
    proof_step_data(
        Proof, proof_step,
        StepId, Rule, Dependencies, References, Conclusion),
    Proof =
        proof_proposal(
            ProofFormat, ProofId, Theory, _Steps, RootStep),
    expected_references(
        ProgramId, EqualityId, DefinitionSpaceId, PremiseId,
        ExpectedReferences),
    expected_conclusion(
        ProgramId, EqualityId, DefinitionSpaceId, PremiseId,
        ExpectedConclusion),
    replay_mismatch(
        RootStep, StepId,
        References, ExpectedReferences,
        Conclusion, ExpectedConclusion,
        Mismatch),
    replay_mismatch_status(
        Mismatch,
        ProofFormat, ProofId, Theory,
        StepId, Rule, Dependencies,
        ExpectedReferences, ExpectedConclusion,
        Status).

replay_mismatch(
        RootStep, StepId,
        _References, _ExpectedReferences,
        _Conclusion, _ExpectedConclusion,
        root_step_mismatch) :-
    RootStep \== root_step(StepId),
    !.
replay_mismatch(
        _RootStep, _StepId,
        References, _ExpectedReferences,
        _Conclusion, _ExpectedConclusion,
        reference_order_mismatch) :-
    \+ ordered_reference_constructors(References),
    !.
replay_mismatch(
        _RootStep, _StepId,
        [AuthorityScope, _ProgramReference],
        [ExpectedAuthorityScope, _ExpectedProgramReference],
        _Conclusion, _ExpectedConclusion,
        authority_scope_mismatch) :-
    AuthorityScope \== ExpectedAuthorityScope,
    !.
replay_mismatch(
        _RootStep, _StepId,
        [_AuthorityScope, ProgramReference],
        [_ExpectedAuthorityScope, ExpectedProgramReference],
        _Conclusion, _ExpectedConclusion,
        program_reference_mismatch) :-
    ProgramReference \== ExpectedProgramReference,
    !.
replay_mismatch(
        _RootStep, _StepId,
        _References, _ExpectedReferences,
        Conclusion, ExpectedConclusion,
        conclusion_mismatch) :-
    Conclusion \== ExpectedConclusion,
    !.
replay_mismatch(
        _RootStep, _StepId,
        _References, _ExpectedReferences,
        _Conclusion, _ExpectedConclusion,
        exact).

ordered_reference_constructors(
    [ authority_scope(_EqualityId, _DefinitionSpaceId, _PremiseId),
      program_ast(_ProgramId)
    ]).

replay_mismatch_status(
        exact,
        ProofFormat, ProofId, Theory,
        StepId, Rule, Dependencies,
        ExpectedReferences, ExpectedConclusion,
        accepted(CheckedProof, ReplayDetail)) :-
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
                external_references(ExpectedReferences),
                conclusion(ExpectedConclusion))),
    ReplayDetail =
        checked(
            StepId,
            Rule,
            external_references(ExpectedReferences),
            conclusion(ExpectedConclusion)).
replay_mismatch_status(
        Reason,
        _ProofFormat, _ProofId, _Theory,
        _StepId, _Rule, _Dependencies,
        _ExpectedReferences, _ExpectedConclusion,
        rejected(Reason)) :-
    Reason \== exact.

finish_replay_status(
        rejected(Reason), Predecessor, Proof,
        proof_replay(rejected(Reason), Audit)) :-
    predecessor_audit(
        Proof, Predecessor, rejected(Reason), Audit).
finish_replay_status(
        accepted(CheckedProof, ReplayDetail), Predecessor, Proof,
        proof_replay(accepted(CheckedProof), Audit)) :-
    predecessor_audit(
        Proof, Predecessor, ReplayDetail, Audit).

predecessor_audit(
        Proof, Predecessor, ReplayDetail,
        proof_audit(
            Proposal,
            predecessor(Predecessor),
            replay(ReplayDetail))) :-
    proof_proposal_descriptor(Proof, Proposal).

proof_proposal_descriptor(
    proof_proposal(
        _Format, ProofId, _Theory, _Steps, RootStep),
    proposal(ProofId, RootStep)).

proof_conclusion(Proof, Conclusion) :-
    proof_step_data(
        Proof, _Kind,
        _StepId, _Rule, _Dependencies, _References, Conclusion).

proof_step_data(
    proof_proposal(
        _Format, _ProofId, _Theory,
        steps([
            proof_step(
                StepId, Rule, Dependencies,
                external_references(References),
                conclusion(Conclusion))
        ]),
        _RootStep),
    proof_step,
    StepId, Rule, Dependencies, References, Conclusion) :-
    !.
proof_step_data(
    proof_proposal(
        _Format, _ProofId, _Theory,
        steps([
            proof_hole(
                StepId, Dependencies, conclusion(Conclusion))
        ]),
        _RootStep),
    proof_hole,
    StepId, no_rule, Dependencies, no_references, Conclusion) :-
    !.
proof_step_data(
    proof_proposal(
        _Format, _ProofId, _Theory,
        steps([
            trusted_step(
                StepId, Dependencies, conclusion(Conclusion))
        ]),
        _RootStep),
    trusted_step,
    StepId, no_rule, Dependencies, no_references, Conclusion).

expected_references(
    ProgramId, EqualityId, DefinitionSpaceId, PremiseId,
    [ authority_scope(
          equality_id(EqualityId),
          definition_space_id(DefinitionSpaceId),
          premise_id(PremiseId)),
      program_ast(program_id(ProgramId))
    ]).

expected_conclusion(
    ProgramId, EqualityId, DefinitionSpaceId, PremiseId,
    source_relative_identity_replay(
        program_id(ProgramId),
        equality_id(EqualityId),
        definition_space_id(DefinitionSpaceId),
        premise_id(PremiseId))).

bounded_proof_status(Proof, Status) :-
    scan_proof(
        Proof, 1, [], scan_state(0, none),
        State, Control),
    final_scan_status(State, Control, Status).

final_scan_status(
        scan_state(_Cells, cycle),
        _Control,
        rejected(cyclic_input(proof))) :-
    !.
final_scan_status(
        scan_state(_Cells, non_ground),
        _Control,
        rejected(non_ground_input(proof))) :-
    !.
final_scan_status(
        scan_state(_Cells, malformed(Field)),
        _Control,
        rejected(malformed_shape(proof, Field))) :-
    !.
final_scan_status(
        scan_state(_Cells, none),
        stop(Resource),
        resource(Resource)) :-
    !.
final_scan_status(
        scan_state(_Cells, none),
        continue,
        closed).

scan_proof(Proof, Depth, Ancestors, State0, State, Control) :-
    expected_header(
        Proof, proof_proposal, 5, root,
        Depth, Ancestors, State0,
        State1, Valid, HeaderControl),
    (   HeaderControl = stop(_Resource)
    ->  State = State1,
        Control = HeaderControl
    ;   Valid == false
    ->  State = State1,
        Control = continue
    ;   arg(1, Proof, Format),
        NextDepth is Depth + 1,
        scan_tag_wrapper(
            Format, proof_format, format,
            NextDepth, [Proof|Ancestors], State1,
            State2, FormatControl),
        continue_proof_after_format(
            FormatControl, Proof, NextDepth, [Proof|Ancestors],
            State2, State, Control)
    ).

continue_proof_after_format(
        stop(Resource), _Proof, _Depth, _Ancestors,
        State, State, stop(Resource)) :-
    !.
continue_proof_after_format(
        continue, Proof, Depth, Ancestors,
        State0, State, Control) :-
    arg(2, Proof, ProofId),
    scan_new_identifier_wrapper(
        ProofId, proof_id, proof_id,
        Depth, Ancestors, State0, State1, ProofIdControl),
    continue_proof_after_id(
        ProofIdControl, Proof, Depth, Ancestors,
        State1, State, Control).

continue_proof_after_id(
        stop(Resource), _Proof, _Depth, _Ancestors,
        State, State, stop(Resource)) :-
    !.
continue_proof_after_id(
        continue, Proof, Depth, Ancestors,
        State0, State, Control) :-
    arg(3, Proof, Theory),
    scan_tag_wrapper(
        Theory, theory, theory,
        Depth, Ancestors, State0, State1, TheoryControl),
    continue_proof_after_theory(
        TheoryControl, Proof, Depth, Ancestors,
        State1, State, Control).

continue_proof_after_theory(
        stop(Resource), _Proof, _Depth, _Ancestors,
        State, State, stop(Resource)) :-
    !.
continue_proof_after_theory(
        continue, Proof, Depth, Ancestors,
        State0, State, Control) :-
    arg(4, Proof, Steps),
    scan_steps_wrapper(
        Steps, Depth, Ancestors, State0, State1, StepsControl),
    continue_proof_after_steps(
        StepsControl, Proof, Depth, Ancestors,
        State1, State, Control).

continue_proof_after_steps(
        stop(Resource), _Proof, _Depth, _Ancestors,
        State, State, stop(Resource)) :-
    !.
continue_proof_after_steps(
        continue, Proof, Depth, Ancestors,
        State0, State, Control) :-
    arg(5, Proof, RootStep),
    scan_root_step_wrapper(
        RootStep, Depth, Ancestors, State0, State, Control).

scan_root_step_wrapper(
        Term, Depth, Ancestors, State0, State, Control) :-
    expected_header(
        Term, root_step, 1, root_step,
        Depth, Ancestors, State0,
        State1, Valid, HeaderControl),
    (   HeaderControl = stop(_Resource)
    ->  State = State1,
        Control = HeaderControl
    ;   Valid == false
    ->  State = State1,
        Control = continue
    ;   arg(1, Term, StepIdentifier),
        NextDepth is Depth + 1,
        scan_step_identifier_wrapper(
            StepIdentifier, step_id, root_step,
            NextDepth, [Term|Ancestors], State1, State, Control)
    ).

scan_tag_wrapper(
        Term, Wrapper, Field,
        Depth, Ancestors, State0, State, Control) :-
    expected_header(
        Term, Wrapper, 1, Field,
        Depth, Ancestors, State0,
        State1, Valid, HeaderControl),
    (   HeaderControl = stop(_Resource)
    ->  State = State1,
        Control = HeaderControl
    ;   Valid == false
    ->  State = State1,
        Control = continue
    ;   arg(1, Term, Payload),
        NextDepth is Depth + 1,
        scan_atom_payload(
            Payload, Field, unlimited,
            NextDepth, [Term|Ancestors], State1, State, Control)
    ).

scan_new_identifier_wrapper(
        Term, Wrapper, Field,
        Depth, Ancestors, State0, State, Control) :-
    expected_header(
        Term, Wrapper, 1, Field,
        Depth, Ancestors, State0,
        State1, Valid, HeaderControl),
    (   HeaderControl = stop(_Resource)
    ->  State = State1,
        Control = HeaderControl
    ;   Valid == false
    ->  State = State1,
        Control = continue
    ;   arg(1, Term, Payload),
        NextDepth is Depth + 1,
        scan_atom_payload(
            Payload, Field, bounded_identifier,
            NextDepth, [Term|Ancestors], State1, State, Control)
    ).

scan_step_identifier_wrapper(
        Term, Wrapper, Field,
        Depth, Ancestors, State0, State, Control) :-
    scan_new_identifier_wrapper(
        Term, Wrapper, Field,
        Depth, Ancestors, State0, State, Control).

scan_existing_identifier_wrapper(
        Term, Wrapper, Field,
        Depth, Ancestors, State0, State, Control) :-
    expected_header(
        Term, Wrapper, 1, Field,
        Depth, Ancestors, State0,
        State1, Valid, HeaderControl),
    (   HeaderControl = stop(_Resource)
    ->  State = State1,
        Control = HeaderControl
    ;   Valid == false
    ->  State = State1,
        Control = continue
    ;   arg(1, Term, Payload),
        NextDepth is Depth + 1,
        scan_atom_payload(
            Payload, Field, unlimited,
            NextDepth, [Term|Ancestors], State1, State, Control)
    ).

scan_atom_payload(
        Term, Field, Limit,
        Depth, Ancestors, State0, State, Control) :-
    enter_node(
        Term, Depth, Ancestors, State0,
        State1, Kind, NodeControl),
    (   NodeControl = stop(_Resource)
    ->  State = State1,
        Control = NodeControl
    ;   atom(Term),
        Term \== ''
    ->  scan_atom_limit(
            Limit, Term, State1, State, Control)
    ;   record_malformed(Field, State1, State2),
        generic_descend(
            Kind, Term, Depth, Ancestors,
            State2, State, Control)
    ).

scan_atom_limit(unlimited, _Term, State, State, continue).
scan_atom_limit(bounded_identifier, Term, State, State, Control) :-
    atom_length(Term, Length),
    (   Length > 64
    ->  Control = stop(identifier_scalars)
    ;   Control = continue
    ).

scan_steps_wrapper(
        Term, Depth, Ancestors, State0, State, Control) :-
    expected_header(
        Term, steps, 1, steps,
        Depth, Ancestors, State0,
        State1, Valid, HeaderControl),
    (   HeaderControl = stop(_Resource)
    ->  State = State1,
        Control = HeaderControl
    ;   Valid == false
    ->  State = State1,
        Control = continue
    ;   arg(1, Term, List),
        NextDepth is Depth + 1,
        scan_steps_list(
            List, 0, NextDepth, [Term|Ancestors],
            State1, State, Control)
    ).

scan_steps_list(
        List, Count, Depth, Ancestors,
        State0, State, Control) :-
    enter_node(
        List, Depth, Ancestors, State0,
        State1, Kind, NodeControl),
    (   NodeControl = stop(_Resource)
    ->  State = State1,
        Control = NodeControl
    ;   List == []
    ->  finish_exact_list(
            Count, 1, steps, State1, State, Control)
    ;   List = [Head|Tail]
    ->  scan_steps_cons(
            Count, Head, Tail, List,
            Depth, Ancestors, State1, State, Control)
    ;   record_malformed(steps, State1, State2),
        generic_descend(
            Kind, List, Depth, Ancestors,
            State2, State, Control)
    ).

scan_steps_cons(
        Count, _Head, _Tail, _List,
        _Depth, _Ancestors, State, State, stop(steps)) :-
    Count >= 1,
    !.
scan_steps_cons(
        Count, Head, Tail, List,
        Depth, Ancestors, State0, State, Control) :-
    NextDepth is Depth + 1,
    scan_step(
        Head, NextDepth, [List|Ancestors],
        State0, State1, HeadControl),
    (   HeadControl = stop(_Resource)
    ->  State = State1,
        Control = HeadControl
    ;   NextCount is Count + 1,
        scan_steps_list(
            Tail, NextCount, NextDepth, [List|Ancestors],
            State1, State, Control)
    ).

scan_step(Term, Depth, Ancestors, State0, State, Control) :-
    enter_node(
        Term, Depth, Ancestors, State0,
        State1, Kind, NodeControl),
    (   NodeControl = stop(_Resource)
    ->  State = State1,
        Control = NodeControl
    ;   Kind = compound(proof_step, 5)
    ->  scan_proof_step_arguments(
            Term, Depth, Ancestors, State1, State, Control)
    ;   Kind = compound(proof_hole, 3)
    ->  scan_incomplete_step_arguments(
            Term, Depth, Ancestors, State1, State, Control)
    ;   Kind = compound(trusted_step, 3)
    ->  scan_incomplete_step_arguments(
            Term, Depth, Ancestors, State1, State, Control)
    ;   record_malformed(step, State1, State2),
        generic_descend(
            Kind, Term, Depth, Ancestors,
            State2, State, Control)
    ).

scan_proof_step_arguments(
        Term, Depth, Ancestors, State0, State, Control) :-
    NextDepth is Depth + 1,
    arg(1, Term, StepId),
    scan_step_identifier_wrapper(
        StepId, step_id, step_id,
        NextDepth, [Term|Ancestors], State0, State1, StepIdControl),
    (   StepIdControl = stop(_Resource)
    ->  State = State1,
        Control = StepIdControl
    ;   arg(2, Term, Rule),
        scan_tag_wrapper(
            Rule, rule, step,
            NextDepth, [Term|Ancestors], State1, State2, RuleControl),
        continue_step_after_rule(
            RuleControl, Term, NextDepth, [Term|Ancestors],
            State2, State, Control)
    ).

continue_step_after_rule(
        stop(Resource), _Term, _Depth, _Ancestors,
        State, State, stop(Resource)) :-
    !.
continue_step_after_rule(
        continue, Term, Depth, Ancestors,
        State0, State, Control) :-
    arg(3, Term, Dependencies),
    scan_dependencies_wrapper(
        Dependencies, Depth, Ancestors,
        State0, State1, DependenciesControl),
    continue_step_after_dependencies(
        DependenciesControl, Term, Depth, Ancestors,
        State1, State, Control).

continue_step_after_dependencies(
        stop(Resource), _Term, _Depth, _Ancestors,
        State, State, stop(Resource)) :-
    !.
continue_step_after_dependencies(
        continue, Term, Depth, Ancestors,
        State0, State, Control) :-
    arg(4, Term, References),
    scan_references_wrapper(
        References, Depth, Ancestors,
        State0, State1, ReferencesControl),
    continue_step_after_references(
        ReferencesControl, Term, Depth, Ancestors,
        State1, State, Control).

continue_step_after_references(
        stop(Resource), _Term, _Depth, _Ancestors,
        State, State, stop(Resource)) :-
    !.
continue_step_after_references(
        continue, Term, Depth, Ancestors,
        State0, State, Control) :-
    arg(5, Term, Conclusion),
    scan_conclusion_wrapper(
        Conclusion, Depth, Ancestors,
        State0, State, Control).

scan_incomplete_step_arguments(
        Term, Depth, Ancestors, State0, State, Control) :-
    NextDepth is Depth + 1,
    arg(1, Term, StepId),
    scan_step_identifier_wrapper(
        StepId, step_id, step_id,
        NextDepth, [Term|Ancestors], State0, State1, StepIdControl),
    (   StepIdControl = stop(_Resource)
    ->  State = State1,
        Control = StepIdControl
    ;   arg(2, Term, Dependencies),
        scan_dependencies_wrapper(
            Dependencies, NextDepth, [Term|Ancestors],
            State1, State2, DependenciesControl),
        continue_incomplete_after_dependencies(
            DependenciesControl, Term, NextDepth, [Term|Ancestors],
            State2, State, Control)
    ).

continue_incomplete_after_dependencies(
        stop(Resource), _Term, _Depth, _Ancestors,
        State, State, stop(Resource)) :-
    !.
continue_incomplete_after_dependencies(
        continue, Term, Depth, Ancestors,
        State0, State, Control) :-
    arg(3, Term, Conclusion),
    scan_conclusion_wrapper(
        Conclusion, Depth, Ancestors,
        State0, State, Control).

scan_dependencies_wrapper(
        Term, Depth, Ancestors, State0, State, Control) :-
    expected_header(
        Term, dependencies, 1, dependencies,
        Depth, Ancestors, State0,
        State1, Valid, HeaderControl),
    (   HeaderControl = stop(_Resource)
    ->  State = State1,
        Control = HeaderControl
    ;   Valid == false
    ->  State = State1,
        Control = continue
    ;   arg(1, Term, List),
        NextDepth is Depth + 1,
        scan_dependencies_list(
            List, NextDepth, [Term|Ancestors],
            State1, State, Control)
    ).

scan_dependencies_list(
        List, Depth, Ancestors, State0, State, Control) :-
    enter_node(
        List, Depth, Ancestors, State0,
        State1, Kind, NodeControl),
    (   NodeControl = stop(_Resource)
    ->  State = State1,
        Control = NodeControl
    ;   List == []
    ->  State = State1,
        Control = continue
    ;   List = [_Head|_Tail]
    ->  State = State1,
        Control = stop(dependency_depth)
    ;   record_malformed(dependencies, State1, State2),
        generic_descend(
            Kind, List, Depth, Ancestors,
            State2, State, Control)
    ).

scan_references_wrapper(
        Term, Depth, Ancestors, State0, State, Control) :-
    expected_header(
        Term, external_references, 1, external_references,
        Depth, Ancestors, State0,
        State1, Valid, HeaderControl),
    (   HeaderControl = stop(_Resource)
    ->  State = State1,
        Control = HeaderControl
    ;   Valid == false
    ->  State = State1,
        Control = continue
    ;   arg(1, Term, List),
        NextDepth is Depth + 1,
        scan_references_list(
            List, 0, NextDepth, [Term|Ancestors],
            State1, State, Control)
    ).

scan_references_list(
        List, Count, Depth, Ancestors,
        State0, State, Control) :-
    enter_node(
        List, Depth, Ancestors, State0,
        State1, Kind, NodeControl),
    (   NodeControl = stop(_Resource)
    ->  State = State1,
        Control = NodeControl
    ;   List == []
    ->  finish_exact_list(
            Count, 2, external_references,
            State1, State, Control)
    ;   List = [Head|Tail]
    ->  scan_references_cons(
            Count, Head, Tail, List,
            Depth, Ancestors, State1, State, Control)
    ;   record_malformed(external_references, State1, State2),
        generic_descend(
            Kind, List, Depth, Ancestors,
            State2, State, Control)
    ).

scan_references_cons(
        Count, _Head, _Tail, _List,
        _Depth, _Ancestors, State, State,
        stop(external_references)) :-
    Count >= 2,
    !.
scan_references_cons(
        Count, Head, Tail, List,
        Depth, Ancestors, State0, State, Control) :-
    NextDepth is Depth + 1,
    scan_reference(
        Head, NextDepth, [List|Ancestors],
        State0, State1, HeadControl),
    (   HeadControl = stop(_Resource)
    ->  State = State1,
        Control = HeadControl
    ;   NextCount is Count + 1,
        scan_references_list(
            Tail, NextCount, NextDepth, [List|Ancestors],
            State1, State, Control)
    ).

scan_reference(Term, Depth, Ancestors, State0, State, Control) :-
    enter_node(
        Term, Depth, Ancestors, State0,
        State1, Kind, NodeControl),
    (   NodeControl = stop(_Resource)
    ->  State = State1,
        Control = NodeControl
    ;   Kind = compound(authority_scope, 3)
    ->  scan_authority_scope_arguments(
            Term, Depth, Ancestors, State1, State, Control)
    ;   Kind = compound(program_ast, 1)
    ->  scan_program_reference_argument(
            Term, Depth, Ancestors, State1, State, Control)
    ;   malformed_reference_field(Kind, Field),
        record_malformed(Field, State1, State2),
        generic_descend(
            Kind, Term, Depth, Ancestors,
            State2, State, Control)
    ).

malformed_reference_field(
        compound(authority_scope, _Arity), authority_scope) :-
    !.
malformed_reference_field(
        compound(program_ast, _Arity), program_ast) :-
    !.
malformed_reference_field(_Kind, external_references).

scan_authority_scope_arguments(
        Term, Depth, Ancestors, State0, State, Control) :-
    NextDepth is Depth + 1,
    arg(1, Term, EqualityId),
    scan_existing_identifier_wrapper(
        EqualityId, equality_id, authority_scope,
        NextDepth, [Term|Ancestors], State0, State1, EqualityControl),
    continue_authority_after_equality(
        EqualityControl, Term, NextDepth, [Term|Ancestors],
        State1, State, Control).

continue_authority_after_equality(
        stop(Resource), _Term, _Depth, _Ancestors,
        State, State, stop(Resource)) :-
    !.
continue_authority_after_equality(
        continue, Term, Depth, Ancestors,
        State0, State, Control) :-
    arg(2, Term, DefinitionSpaceId),
    scan_existing_identifier_wrapper(
        DefinitionSpaceId, definition_space_id, authority_scope,
        Depth, Ancestors, State0, State1, DefinitionControl),
    continue_authority_after_definition(
        DefinitionControl, Term, Depth, Ancestors,
        State1, State, Control).

continue_authority_after_definition(
        stop(Resource), _Term, _Depth, _Ancestors,
        State, State, stop(Resource)) :-
    !.
continue_authority_after_definition(
        continue, Term, Depth, Ancestors,
        State0, State, Control) :-
    arg(3, Term, PremiseId),
    scan_existing_identifier_wrapper(
        PremiseId, premise_id, authority_scope,
        Depth, Ancestors, State0, State, Control).

scan_program_reference_argument(
        Term, Depth, Ancestors, State0, State, Control) :-
    arg(1, Term, ProgramId),
    NextDepth is Depth + 1,
    scan_existing_identifier_wrapper(
        ProgramId, program_id, program_ast,
        NextDepth, [Term|Ancestors], State0, State, Control).

scan_conclusion_wrapper(
        Term, Depth, Ancestors, State0, State, Control) :-
    expected_header(
        Term, conclusion, 1, conclusion,
        Depth, Ancestors, State0,
        State1, Valid, HeaderControl),
    (   HeaderControl = stop(_Resource)
    ->  State = State1,
        Control = HeaderControl
    ;   Valid == false
    ->  State = State1,
        Control = continue
    ;   arg(1, Term, Conclusion),
        NextDepth is Depth + 1,
        scan_conclusion(
            Conclusion, NextDepth, [Term|Ancestors],
            State1, State, Control)
    ).

scan_conclusion(
        Term, Depth, Ancestors, State0, State, Control) :-
    enter_node(
        Term, Depth, Ancestors, State0,
        State1, Kind, NodeControl),
    (   NodeControl = stop(_Resource)
    ->  State = State1,
        Control = NodeControl
    ;   Kind = compound(source_relative_identity_replay, 4)
    ->  scan_local_conclusion_arguments(
            Term, Depth, Ancestors, State1, State, Control)
    ;   Kind = compound(_OtherConstructor, 4)
    ->  generic_descend(
            Kind, Term, Depth, Ancestors,
            State1, State, Control)
    ;   record_malformed(conclusion, State1, State2),
        generic_descend(
            Kind, Term, Depth, Ancestors,
            State2, State, Control)
    ).

scan_local_conclusion_arguments(
        Term, Depth, Ancestors, State0, State, Control) :-
    NextDepth is Depth + 1,
    arg(1, Term, ProgramId),
    scan_existing_identifier_wrapper(
        ProgramId, program_id, conclusion,
        NextDepth, [Term|Ancestors], State0, State1, ProgramControl),
    continue_conclusion_after_program(
        ProgramControl, Term, NextDepth, [Term|Ancestors],
        State1, State, Control).

continue_conclusion_after_program(
        stop(Resource), _Term, _Depth, _Ancestors,
        State, State, stop(Resource)) :-
    !.
continue_conclusion_after_program(
        continue, Term, Depth, Ancestors,
        State0, State, Control) :-
    arg(2, Term, EqualityId),
    scan_existing_identifier_wrapper(
        EqualityId, equality_id, conclusion,
        Depth, Ancestors, State0, State1, EqualityControl),
    continue_conclusion_after_equality(
        EqualityControl, Term, Depth, Ancestors,
        State1, State, Control).

continue_conclusion_after_equality(
        stop(Resource), _Term, _Depth, _Ancestors,
        State, State, stop(Resource)) :-
    !.
continue_conclusion_after_equality(
        continue, Term, Depth, Ancestors,
        State0, State, Control) :-
    arg(3, Term, DefinitionSpaceId),
    scan_existing_identifier_wrapper(
        DefinitionSpaceId, definition_space_id, conclusion,
        Depth, Ancestors, State0, State1, DefinitionControl),
    continue_conclusion_after_definition(
        DefinitionControl, Term, Depth, Ancestors,
        State1, State, Control).

continue_conclusion_after_definition(
        stop(Resource), _Term, _Depth, _Ancestors,
        State, State, stop(Resource)) :-
    !.
continue_conclusion_after_definition(
        continue, Term, Depth, Ancestors,
        State0, State, Control) :-
    arg(4, Term, PremiseId),
    scan_existing_identifier_wrapper(
        PremiseId, premise_id, conclusion,
        Depth, Ancestors, State0, State, Control).

finish_exact_list(
        Count, Expected, _Field,
        State, State, continue) :-
    Count =:= Expected,
    !.
finish_exact_list(
        _Count, _Expected, Field,
        State0, State, continue) :-
    record_malformed(Field, State0, State).

expected_header(
        Term, ExpectedName, ExpectedArity, Field,
        Depth, Ancestors, State0,
        State, Valid, Control) :-
    enter_node(
        Term, Depth, Ancestors, State0,
        State1, Kind, NodeControl),
    (   NodeControl = stop(_Resource)
    ->  State = State1,
        Valid = false,
        Control = NodeControl
    ;   Kind = compound(ExpectedName, ExpectedArity)
    ->  State = State1,
        Valid = true,
        Control = continue
    ;   record_malformed(Field, State1, State2),
        generic_descend(
            Kind, Term, Depth, Ancestors,
            State2, State, Control),
        Valid = false
    ).

enter_node(
        _Term, _Depth, _Ancestors,
        scan_state(128, Issue),
        scan_state(128, Issue),
        uninspected,
        stop(cells)) :-
    !.
enter_node(
        _Term, Depth, _Ancestors,
        scan_state(Cells0, Issue),
        scan_state(Cells, Issue),
        uninspected,
        stop(structural_depth)) :-
    Cells is Cells0 + 1,
    Depth > 16,
    !.
enter_node(
        Term, _Depth, Ancestors,
        scan_state(Cells0, _Issue),
        scan_state(Cells, cycle),
        cycle,
        stop(none)) :-
    Cells is Cells0 + 1,
    identity_member(Term, Ancestors),
    !.
enter_node(
        Term, _Depth, _Ancestors,
        scan_state(Cells0, Issue0),
        scan_state(Cells, Issue),
        variable,
        continue) :-
    Cells is Cells0 + 1,
    var(Term),
    !,
    record_non_ground_issue(Issue0, Issue).
enter_node(
        Term, _Depth, _Ancestors,
        scan_state(Cells0, Issue),
        scan_state(Cells, Issue),
        atomic,
        continue) :-
    Cells is Cells0 + 1,
    atomic(Term),
    !.
enter_node(
        Term, _Depth, _Ancestors,
        scan_state(Cells0, Issue),
        scan_state(Cells, Issue),
        compound(Name, Arity),
        continue) :-
    Cells is Cells0 + 1,
    compound_name_arity(Term, Name, Arity).

record_non_ground_issue(cycle, cycle) :-
    !.
record_non_ground_issue(_Issue, non_ground).

record_malformed(_Field, scan_state(Cells, cycle),
                 scan_state(Cells, cycle)) :-
    !.
record_malformed(_Field, scan_state(Cells, non_ground),
                 scan_state(Cells, non_ground)) :-
    !.
record_malformed(_Field, scan_state(Cells, malformed(Existing)),
                 scan_state(Cells, malformed(Existing))) :-
    !.
record_malformed(Field, scan_state(Cells, none),
                 scan_state(Cells, malformed(Field))).

generic_descend(
        compound(_Name, Arity), Term, Depth, Ancestors,
        State0, State, Control) :-
    !,
    NextDepth is Depth + 1,
    scan_generic_arguments(
        1, Arity, Term, NextDepth, [Term|Ancestors],
        State0, State, Control).
generic_descend(
        _Kind, _Term, _Depth, _Ancestors,
        State, State, continue).

scan_generic_arguments(
        Index, Arity, _Term, _Depth, _Ancestors,
        State, State, continue) :-
    Index > Arity,
    !.
scan_generic_arguments(
        Index, Arity, Term, Depth, Ancestors,
        State0, State, Control) :-
    arg(Index, Term, Argument),
    scan_generic_term(
        Argument, Depth, Ancestors,
        State0, State1, ArgumentControl),
    (   ArgumentControl = stop(_Resource)
    ->  State = State1,
        Control = ArgumentControl
    ;   NextIndex is Index + 1,
        scan_generic_arguments(
            NextIndex, Arity, Term, Depth, Ancestors,
            State1, State, Control)
    ).

scan_generic_term(
        Term, Depth, Ancestors, State0, State, Control) :-
    enter_node(
        Term, Depth, Ancestors, State0,
        State1, Kind, NodeControl),
    (   NodeControl = stop(_Resource)
    ->  State = State1,
        Control = NodeControl
    ;   generic_descend(
            Kind, Term, Depth, Ancestors,
            State1, State, Control)
    ).

identity_member(Term, [Ancestor|_Ancestors]) :-
    Term == Ancestor,
    !.
identity_member(Term, [_Ancestor|Ancestors]) :-
    identity_member(Term, Ancestors).
