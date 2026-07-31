:- module(cps_controlled_english_v0,
          [ validate_controlled_english_v0/4
          ]).

:- use_module('../ir/cps_ground_typed_equality_ir',
              [ validate_ground_typed_equality_pair/4
              ]).

/** <module> Bounded controlled-English equality validation

This module recognizes one fixed pre-tokenized equality sentence.  It treats
tokens, Program proposals, and authority snapshots only as data, enumerates
every complete fixed-grammar reading, and delegates each distinct proposal to
the accepted T003 validation boundary.
*/

%! validate_controlled_english_v0(
%!     +Tokens,
%!     +ProgramProposal,
%!     +AuthoritySnapshot,
%!     -Validation) is det.
%
%  Return one finite ground validation without binding or executing any input.
validate_controlled_english_v0(Tokens, Program, Authority, Validation) :-
    classify_token_input(Tokens, Program, Authority, Validation),
    !.

classify_token_input(Tokens, Program, Authority, Validation) :-
    direct_token_status(Tokens, Direct),
    continue_direct_token_status(
        Direct, Tokens, Program, Authority, Validation).

direct_token_status(Tokens, direct(non_ground_input(tokens))) :-
    var(Tokens),
    !.
direct_token_status(Tokens, direct(forged_accepted_input(tokens))) :-
    nonvar(Tokens),
    forged_token_root(Tokens),
    !.
direct_token_status([], inspect) :-
    !.
direct_token_status(Tokens, inspect) :-
    nonvar(Tokens),
    Tokens = [_Head|_Tail],
    !.
direct_token_status(_Tokens, direct(malformed_shape(tokens, root))).

forged_token_root(Term) :-
    compound(Term),
    functor(Term, Name, Arity),
    forged_token_functor(Name, Arity).

forged_token_functor(controlled_english_validation, 2).
forged_token_functor(controlled_english_audit, 3).
forged_token_functor(ground_typed_equality_validation, 2).
forged_token_functor(validated_pair, 2).
forged_token_functor(validated_specification, 5).

continue_direct_token_status(
        direct(Reason), _Tokens, _Program, _Authority, Validation) :-
    direct_failure(Reason, Validation).
continue_direct_token_status(
        inspect, Tokens, Program, Authority, Validation) :-
    token_preflight(Tokens, Preflight),
    continue_token_preflight(
        Preflight, Tokens, Program, Authority, Validation).

direct_failure(
        Reason,
        controlled_english_validation(
            rejected(Reason),
            controlled_english_audit(
                not_completed, not_run, []))).

token_preflight(Tokens, Preflight) :-
    bounded_priority_scan(
        cycle, Tokens, [], 1, 0, _CycleCells, CycleStatus),
    continue_cycle_scan(CycleStatus, Tokens, Preflight).

continue_cycle_scan(found, _Tokens, failed(cyclic_input(tokens))) :-
    !.
continue_cycle_scan(_CycleStatus, Tokens, Preflight) :-
    bounded_priority_scan(
        variable, Tokens, [], 1, 0, _VariableCells, VariableStatus),
    continue_variable_scan(VariableStatus, Tokens, Preflight).

continue_variable_scan(found, _Tokens, failed(non_ground_input(tokens))) :-
    !.
continue_variable_scan(_VariableStatus, Tokens, Preflight) :-
    inspect_list_shape(Tokens, [], 1, 0, 0, Preflight).

bounded_priority_scan(
        _Mode, _Term, _Ancestors, Depth, Cells, Cells, bounded(depth)) :-
    Depth > 25,
    !.
bounded_priority_scan(
        _Mode, _Term, _Ancestors, _Depth, Cells, Cells, bounded(cells)) :-
    Cells >= 49,
    !.
bounded_priority_scan(
        cycle, Term, Ancestors, _Depth, Cells, Cells, found) :-
    identity_member(Term, Ancestors),
    !.
bounded_priority_scan(
        variable, Term, _Ancestors, _Depth, Cells0, Cells, found) :-
    var(Term),
    !,
    Cells is Cells0 + 1.
bounded_priority_scan(
        cycle, Term, _Ancestors, _Depth, Cells0, Cells, clear) :-
    var(Term),
    !,
    Cells is Cells0 + 1.
bounded_priority_scan(
        _Mode, Term, _Ancestors, _Depth, Cells0, Cells, clear) :-
    atomic(Term),
    !,
    Cells is Cells0 + 1.
bounded_priority_scan(
        Mode, Term, Ancestors, Depth, Cells0, Cells, Status) :-
    Cells1 is Cells0 + 1,
    functor(Term, _Name, Arity),
    NextDepth is Depth + 1,
    bounded_priority_arguments(
        1, Arity, Mode, Term, [Term|Ancestors], NextDepth,
        Cells1, Cells, Status).

bounded_priority_arguments(
        Index, Arity, _Mode, _Term, _Ancestors, _Depth,
        Cells, Cells, clear) :-
    Index > Arity,
    !.
bounded_priority_arguments(
        Index, Arity, Mode, Term, Ancestors, Depth,
        Cells0, Cells, Status) :-
    arg(Index, Term, Argument),
    bounded_priority_scan(
        Mode, Argument, Ancestors, Depth, Cells0, Cells1,
        ArgumentStatus),
    continue_priority_arguments(
        ArgumentStatus, Index, Arity, Mode, Term, Ancestors, Depth,
        Cells1, Cells, Status).

continue_priority_arguments(
        found, _Index, _Arity, _Mode, _Term, _Ancestors, _Depth,
        Cells, Cells, found) :-
    !.
continue_priority_arguments(
        bounded(Resource), _Index, _Arity, _Mode, _Term, _Ancestors, _Depth,
        Cells, Cells, bounded(Resource)) :-
    !.
continue_priority_arguments(
        clear, Index, Arity, Mode, Term, Ancestors, Depth,
        Cells0, Cells, Status) :-
    NextIndex is Index + 1,
    bounded_priority_arguments(
        NextIndex, Arity, Mode, Term, Ancestors, Depth,
        Cells0, Cells, Status).

identity_member(Term, [Head|_Tail]) :-
    Term == Head,
    !.
identity_member(Term, [_Head|Tail]) :-
    identity_member(Term, Tail).

inspect_list_shape(
        _Term, _Ancestors, Depth, Count, Cells, Outcome) :-
    Depth > 25,
    !,
    local_preflight_outcome(
        Count, Cells, Depth, tokens(depth(25)), Outcome).
inspect_list_shape(
        _Term, _Ancestors, Depth, Count, Cells, Outcome) :-
    Cells >= 49,
    !,
    local_preflight_outcome(
        Count, Cells, Depth, tokens(cells(49)), Outcome).
inspect_list_shape(
        Term, Ancestors, _Depth, _Count, _Cells,
        failed(cyclic_input(tokens))) :-
    identity_member(Term, Ancestors),
    !.
inspect_list_shape(
        Term, _Ancestors, _Depth, _Count, _Cells,
        failed(non_ground_input(tokens))) :-
    var(Term),
    !.
inspect_list_shape(
        [], _Ancestors, Depth, Count, Cells0,
        checked(Count, Cells, Depth)) :-
    !,
    Cells is Cells0 + 1.
inspect_list_shape(
        Term, Ancestors, Depth, Count0, Cells0, Outcome) :-
    Term = [Head|Tail],
    !,
    Cells1 is Cells0 + 1,
    Count is Count0 + 1,
    inspect_counted_list_cell(
        Count, Head, Tail, Term, Ancestors, Depth, Cells1, Outcome).
inspect_list_shape(
        _Term, _Ancestors, _Depth, _Count, _Cells,
        failed(malformed_shape(tokens, list))).

inspect_counted_list_cell(
        Count, _Head, _Tail, _Term, _Ancestors, Depth, Cells,
        Outcome) :-
    Count > 24,
    !,
    local_preflight_outcome(
        Count, Cells, Depth, tokens(count(24)), Outcome).
inspect_counted_list_cell(
        Count, Head, Tail, Term, Ancestors, Depth, Cells0, Outcome) :-
    NextDepth is Depth + 1,
    inspect_token_shape(
        Head, [Term|Ancestors], NextDepth, Count, Cells0,
        Cells, TokenStatus),
    continue_token_shape(
        TokenStatus, Tail, Term, Ancestors, NextDepth, Count, Cells,
        Outcome).

inspect_token_shape(
        _Token, _Ancestors, Depth, _Position, Cells, Cells,
        resource(tokens(depth(25)))) :-
    Depth > 25,
    !.
inspect_token_shape(
        _Token, _Ancestors, _Depth, _Position, Cells, Cells,
        resource(tokens(cells(49)))) :-
    Cells >= 49,
    !.
inspect_token_shape(
        Token, Ancestors, _Depth, _Position, Cells, Cells, cycle) :-
    identity_member(Token, Ancestors),
    !.
inspect_token_shape(
        Token, _Ancestors, _Depth, _Position, Cells0, Cells, variable) :-
    var(Token),
    !,
    Cells is Cells0 + 1.
inspect_token_shape(
        Token, _Ancestors, _Depth, _Position, Cells0, Cells, clear) :-
    atom(Token),
    !,
    Cells is Cells0 + 1.
inspect_token_shape(
        Token, _Ancestors, _Depth, Position, Cells0, Cells,
        malformed(Position)) :-
    atomic(Token),
    !,
    Cells is Cells0 + 1.
inspect_token_shape(
        _Token, _Ancestors, _Depth, Position, Cells0, Cells,
        malformed(Position)) :-
    Cells is Cells0 + 1.

continue_token_shape(
        cycle, _Tail, _Term, _Ancestors, _Depth, _Count, _Cells,
        failed(cyclic_input(tokens))) :-
    !.
continue_token_shape(
        variable, _Tail, _Term, _Ancestors, _Depth, _Count, _Cells,
        failed(non_ground_input(tokens))) :-
    !.
continue_token_shape(
        malformed(Position), _Tail, _Term, _Ancestors, _Depth, _Count,
        _Cells,
        failed(malformed_shape(tokens, token(Position)))) :-
    !.
continue_token_shape(
        resource(Resource), _Tail, _Term, _Ancestors, Depth, Count, Cells,
        Outcome) :-
    !,
    local_preflight_outcome(Count, Cells, Depth, Resource, Outcome).
continue_token_shape(
        clear, Tail, Term, Ancestors, Depth, Count, Cells, Outcome) :-
    inspect_list_shape(
        Tail, [Term|Ancestors], Depth, Count, Cells, Outcome).

local_preflight_outcome(Count, Cells, Depth, _Observed, Outcome) :-
    select_local_resource(Count, Cells, Depth, Resource),
    select_preflight_outcome(Resource, Count, Cells, Depth, Outcome).

select_preflight_outcome(
        none, Count, Cells, Depth, checked(Count, Cells, Depth)).
select_preflight_outcome(
        Resource, _Count, _Cells, _Depth, resource(Resource)) :-
    Resource \== none.

select_local_resource(Count, _Cells, _Depth, tokens(count(24))) :-
    Count > 24,
    !.
select_local_resource(_Count, Cells, _Depth, tokens(cells(49))) :-
    Cells > 49,
    !.
select_local_resource(_Count, _Cells, Depth, tokens(depth(25))) :-
    Depth > 25,
    !.
select_local_resource(_Count, _Cells, _Depth, none).

continue_token_preflight(
        failed(Reason), _Tokens, _Program, _Authority, Validation) :-
    direct_failure(Reason, Validation).
continue_token_preflight(
        resource(Resource), _Tokens, _Program, _Authority,
        controlled_english_validation(
            resource_exhausted(Resource),
            controlled_english_audit(
                limit(Resource), not_run, []))).
continue_token_preflight(
        checked(Count, Cells, Depth), Tokens, Program, Authority,
        Validation) :-
    checked_preflight_status(Tokens, Count, CheckedStatus),
    finish_checked_preflight(
        CheckedStatus, Tokens, Program, Authority,
        Count, Cells, Depth, Validation).

checked_preflight_status(Tokens, Count, Status) :-
    scalar_resource_status(Tokens, Count, ResourceStatus),
    continue_scalar_resource_status(
        ResourceStatus, Tokens, Count, Status).

continue_scalar_resource_status(
        resource(Resource), _Tokens, _Count, resource(Resource)) :-
    !.
continue_scalar_resource_status(
        clear, Tokens, Count, Status) :-
    malformed_scalar_status(Tokens, Count, MalformedStatus),
    continue_malformed_scalar_status(
        MalformedStatus, Tokens, Status).

continue_malformed_scalar_status(
        malformed(Slot), _Tokens,
        rejected(malformed_scalar(Slot))) :-
    !.
continue_malformed_scalar_status(clear, Tokens, Status) :-
    unsupported_status(Tokens, UnsupportedStatus),
    continue_unsupported_status(UnsupportedStatus, Status).

continue_unsupported_status(
        unsupported(Feature), unsupported(Feature)) :-
    !.
continue_unsupported_status(clear, parse).

finish_checked_preflight(
        resource(Resource), _Tokens, _Program, _Authority,
        _Count, _Cells, _Depth,
        controlled_english_validation(
            resource_exhausted(Resource),
            controlled_english_audit(
                limit(Resource), not_run, []))).
finish_checked_preflight(
        rejected(Reason), _Tokens, _Program, _Authority,
        Count, Cells, Depth,
        controlled_english_validation(
            rejected(Reason),
            controlled_english_audit(
                checked(tokens(Count), cells(Cells), depth(Depth)),
                no_complete_parse,
                []))).
finish_checked_preflight(
        unsupported(Feature), _Tokens, _Program, _Authority,
        Count, Cells, Depth,
        controlled_english_validation(
            unsupported(Feature),
            controlled_english_audit(
                checked(tokens(Count), cells(Cells), depth(Depth)),
                no_complete_parse,
                []))).
finish_checked_preflight(
        parse, Tokens, Program, Authority, Count, Cells, Depth,
        Validation) :-
    complete_readings(Tokens, Readings),
    finish_complete_readings(
        Readings, Program, Authority, Count, Cells, Depth, Validation).

scalar_layout(
    20,
    [ identifier(2, specification_id),
      identifier(4, binder_id),
      identifier(6, type_id),
      identifier(10, equality_id),
      identifier(12, reference_id),
      identifier(17, definition_space_id),
      identifier(20, premise_id)
    ],
    [value(14)]).
scalar_layout(
    22,
    [ identifier(2, specification_id),
      identifier(4, binder_id),
      identifier(6, type_id),
      identifier(10, equality_id),
      identifier(12, reference_id),
      identifier(19, definition_space_id),
      identifier(22, premise_id)
    ],
    [value(14), value(16)]).
scalar_layout(
    24,
    [ identifier(2, specification_id),
      identifier(4, binder_id),
      identifier(6, type_id),
      identifier(10, equality_id),
      identifier(12, reference_id),
      identifier(21, definition_space_id),
      identifier(24, premise_id)
    ],
    [value(14), value(16), value(18)]).

scalar_resource_status(Tokens, Count, Status) :-
    (   scalar_layout(Count, Identifiers, Values)
    ->  first_identifier_resource(Tokens, Identifiers, IdentifierStatus),
        continue_identifier_resource(
            IdentifierStatus, Tokens, Values, Status)
    ;   Status = clear
    ).

first_identifier_resource(
        _Tokens, [], clear).
first_identifier_resource(
        Tokens, [identifier(Position, Slot)|Rest], Status) :-
    nth1(Position, Tokens, Atom),
    atom_length(Atom, Length),
    (   Length > 64
    ->  Status = resource(identifier_scalar(Slot, 64))
    ;   first_identifier_resource(Tokens, Rest, Status)
    ).

continue_identifier_resource(
        resource(Resource), _Tokens, _Values, resource(Resource)) :-
    !.
continue_identifier_resource(
        clear, Tokens, Values, Status) :-
    first_value_resource(Tokens, Values, Status).

first_value_resource(_Tokens, [], clear).
first_value_resource(Tokens, [value(Position)|Rest], Status) :-
    nth1(Position, Tokens, Atom),
    atom_length(Atom, Length),
    (   Length > 128
    ->  Status = resource(value_scalar(value, 128))
    ;   first_value_resource(Tokens, Rest, Status)
    ).

malformed_scalar_status(Tokens, Count, Status) :-
    (   scalar_layout(Count, Identifiers, Values)
    ->  first_malformed_identifier(Tokens, Identifiers, IdentifierStatus),
        continue_malformed_identifier(
            IdentifierStatus, Tokens, Values, Status)
    ;   Status = clear
    ).

first_malformed_identifier(_Tokens, [], clear).
first_malformed_identifier(
        Tokens, [identifier(Position, Slot)|Rest], Status) :-
    nth1(Position, Tokens, Atom),
    (   valid_scalar_atom(Atom)
    ->  first_malformed_identifier(Tokens, Rest, Status)
    ;   Status = malformed(Slot)
    ).

continue_malformed_identifier(
        malformed(Slot), _Tokens, _Values, malformed(Slot)) :-
    !.
continue_malformed_identifier(
        clear, Tokens, Values, Status) :-
    first_malformed_value(Tokens, Values, Status).

first_malformed_value(_Tokens, [], clear).
first_malformed_value(Tokens, [value(Position)|Rest], Status) :-
    nth1(Position, Tokens, Atom),
    (   valid_scalar_atom(Atom)
    ->  first_malformed_value(Tokens, Rest, Status)
    ;   Status = malformed(value)
    ).

valid_scalar_atom(Atom) :-
    atom_codes(Atom, [First|Rest]),
    ascii_lower(First),
    ascii_scalar_tail_codes(Rest),
    \+ keyword(Atom).

ascii_scalar_tail_codes([]).
ascii_scalar_tail_codes([Code|Codes]) :-
    ascii_scalar_tail(Code),
    ascii_scalar_tail_codes(Codes).

ascii_lower(Code) :-
    Code >= 0'a,
    Code =< 0'z.

ascii_scalar_tail(Code) :-
    (   ascii_lower(Code)
    ;   Code >= 0'0,
        Code =< 0'9
    ;   Code =:= 0'_
    ).

keyword(specification).
keyword(binds).
keyword(as).
keyword(and).
keyword(requires).
keyword(equality).
keyword(for).
keyword(equals).
keyword(in).
keyword(definition_space).
keyword(using).
keyword(premise).
keyword(or).

unsupported_status(Tokens, Status) :-
    unsupported_status_at(Tokens, Tokens, Status).

unsupported_status_at([], _All, clear).
unsupported_status_at([Token|Rest], All, Status) :-
    token_unsupported_feature(Token, All, FeatureStatus),
    (   FeatureStatus = unsupported(_)
    ->  Status = FeatureStatus
    ;   unsupported_status_at(Rest, All, Status)
    ).

token_unsupported_feature(Token, _Tokens, unsupported(executable_token)) :-
    executable_token(Token),
    !.
token_unsupported_feature(Token, _Tokens, unsupported(question)) :-
    question_token(Token),
    !.
token_unsupported_feature(Token, _Tokens, unsupported(negation)) :-
    negation_token(Token),
    !.
token_unsupported_feature(Token, _Tokens, unsupported(quantifier)) :-
    quantifier_token(Token),
    !.
token_unsupported_feature(Token, _Tokens, unsupported(relative_clause)) :-
    relative_token(Token),
    !.
token_unsupported_feature(binds, Tokens, unsupported(multiple_binding)) :-
    token_occurrences(binds, Tokens, Count),
    Count > 1,
    !.
token_unsupported_feature(as, Tokens, unsupported(multiple_type)) :-
    token_occurrences(as, Tokens, Count),
    Count > 1,
    !.
token_unsupported_feature(
        premise, Tokens, unsupported(multiple_premise)) :-
    token_occurrences(premise, Tokens, Count),
    Count > 1,
    !.
token_unsupported_feature(and, Tokens, unsupported(conjunction)) :-
    token_occurrences(and, Tokens, Count),
    Count > 1,
    !.
token_unsupported_feature(also, _Tokens, unsupported(conjunction)) :-
    !.
token_unsupported_feature(Token, _Tokens, unsupported(case_policy)) :-
    ascii_keyword_case(Token),
    !.
token_unsupported_feature(Token, _Tokens, unsupported(synonym)) :-
    synonym_token(Token),
    !.
token_unsupported_feature(Token, _Tokens, unsupported(punctuation)) :-
    punctuation_token(Token),
    !.
token_unsupported_feature(
        Token, _Tokens, unsupported(reserved_feature(Token))) :-
    reserved_feature_token(Token),
    !.
token_unsupported_feature(_Token, _Tokens, clear).

executable_token(call).
executable_token(assert).
executable_token(assertz).
executable_token(retract).
executable_token(clause).
executable_token(consult).
executable_token(use_module).
executable_token(':-').
executable_token('?-').

question_token(who).
question_token(what).
question_token(when).
question_token(where).
question_token(why).
question_token(how).
question_token(does).
question_token(is).
question_token('?').

negation_token(not).
negation_token(no).

quantifier_token(all).
quantifier_token(every).
quantifier_token(some).
quantifier_token(each).

relative_token(that).
relative_token(which).

synonym_token(spec).
synonym_token(bind).
synonym_token(type).
synonym_token(equals_to).
synonym_token(definition).
synonym_token(uses).

punctuation_token('.').
punctuation_token(',').
punctuation_token(';').
punctuation_token(':').
punctuation_token('!').

reserved_feature_token(if).
reserved_feature_token(then).
reserved_feature_token(else).
reserved_feature_token(lambda).
reserved_feature_token(apply).
reserved_feature_token(rule).
reserved_feature_token(proof).
reserved_feature_token(synthesize).
reserved_feature_token(render).

ascii_keyword_case(Token) :-
    atom_codes(Token, Codes),
    Codes \== [],
    ascii_letter_or_underscore_codes(Codes),
    downcase_atom(Token, Lower),
    Token \== Lower,
    keyword(Lower).

ascii_letter_or_underscore_codes([]).
ascii_letter_or_underscore_codes([Code|Codes]) :-
    ascii_letter_or_underscore(Code),
    ascii_letter_or_underscore_codes(Codes).

ascii_letter_or_underscore(Code) :-
    (   Code >= 0'A,
        Code =< 0'Z
    ;   Code >= 0'a,
        Code =< 0'z
    ;   Code =:= 0'_
    ).

token_occurrences(_Token, [], 0).
token_occurrences(Token, [Head|Tail], Count) :-
    token_occurrences(Token, Tail, TailCount),
    (   Token == Head
    ->  Count is TailCount + 1
    ;   Count = TailCount
    ).

complete_readings(Tokens, Readings) :-
    findall(Reading, phrase(controlled_sentence(Reading), Tokens), Readings).

controlled_sentence(
        proposal(
            SpecificationId, BinderId, TypeId, EqualityId, ReferenceId,
            Value, DefinitionSpaceId, PremiseId)) -->
    [ specification, SpecificationId,
      binds, BinderId,
      as, TypeId,
      and, requires,
      equality, EqualityId,
      for, ReferenceId,
      equals, Value,
      in, definition_space, DefinitionSpaceId,
      using, premise, PremiseId
    ].
controlled_sentence(
        proposal(
            SpecificationId, BinderId, TypeId, EqualityId, ReferenceId,
            FirstValue, DefinitionSpaceId, PremiseId)) -->
    [ specification, SpecificationId,
      binds, BinderId,
      as, TypeId,
      and, requires,
      equality, EqualityId,
      for, ReferenceId,
      equals, FirstValue, or, _SecondValue,
      in, definition_space, DefinitionSpaceId,
      using, premise, PremiseId
    ].
controlled_sentence(
        proposal(
            SpecificationId, BinderId, TypeId, EqualityId, ReferenceId,
            SecondValue, DefinitionSpaceId, PremiseId)) -->
    [ specification, SpecificationId,
      binds, BinderId,
      as, TypeId,
      and, requires,
      equality, EqualityId,
      for, ReferenceId,
      equals, _FirstValue, or, SecondValue,
      in, definition_space, DefinitionSpaceId,
      using, premise, PremiseId
    ].
controlled_sentence(alternative_limit) -->
    [ specification, _SpecificationId,
      binds, _BinderId,
      as, _TypeId,
      and, requires,
      equality, _EqualityId,
      for, _ReferenceId,
      equals, _FirstValue, or, _SecondValue, or, _ThirdValue,
      in, definition_space, _DefinitionSpaceId,
      using, premise, _PremiseId
    ].

finish_complete_readings(
        [], _Program, _Authority, Count, Cells, Depth,
        controlled_english_validation(
            rejected(malformed_syntax(no_complete_parse)),
            controlled_english_audit(
                checked(tokens(Count), cells(Cells), depth(Depth)),
                no_complete_parse,
                []))).
finish_complete_readings(
        Readings, _Program, _Authority, Count, Cells, Depth, Validation) :-
    readings_have_alternative_limit(Readings),
    !,
    Validation =
        controlled_english_validation(
            resource_exhausted(parse_alternatives(2)),
            controlled_english_audit(
                checked(tokens(Count), cells(Cells), depth(Depth)),
                alternative_limit(max(2), observed_at_least(3)),
                [])).
finish_complete_readings(
        Readings, Program, Authority, Count, Cells, Depth,
        controlled_english_validation(
            Status,
            controlled_english_audit(
                checked(tokens(Count), cells(Cells), depth(Depth)),
                complete(Proposals),
                Candidates))) :-
    readings_to_proposals(Readings, RawProposals),
    sort(RawProposals, Proposals),
    validate_proposals(Proposals, Program, Authority, RawCandidates),
    sort(RawCandidates, Candidates),
    classify_candidate_validations(Candidates, Status).

readings_have_alternative_limit([alternative_limit|_Rest]) :-
    !.
readings_have_alternative_limit([_Reading|Rest]) :-
    readings_have_alternative_limit(Rest).

readings_to_proposals([], []).
readings_to_proposals(
        [ proposal(
              SpecificationId, BinderId, TypeId, EqualityId, ReferenceId,
              Value, DefinitionSpaceId, PremiseId)
        | Readings
        ],
        [Proposal|Proposals]) :-
    Proposal =
        specification_proposal(
            specification_id(SpecificationId),
            type_declarations([nominal_type(type_id(TypeId))]),
            binding(
                object_binder(
                    binder_id(BinderId), type_id(TypeId)),
                equality(
                    equality_id(EqualityId),
                    operands([
                        object_reference(
                            binder_id(ReferenceId), type_id(TypeId)),
                        object_value(
                            atom_value(Value), type_id(TypeId))
                    ]))),
            definedness(definition_space_id(DefinitionSpaceId)),
            premises([premise_id(PremiseId)])),
    readings_to_proposals(Readings, Proposals).

validate_proposals([], _Program, _Authority, []).
validate_proposals(
        [Proposal|Proposals], Program, Authority,
        [candidate(Proposal, T003Validation)|Candidates]) :-
    validate_ground_typed_equality_pair(
        Proposal, Program, Authority, T003Validation),
    validate_proposals(Proposals, Program, Authority, Candidates).

classify_candidate_validations(Candidates, Status) :-
    candidate_observations(
        Candidates,
        observations([], [], [], [], [], clear),
        Observations),
    choose_candidate_status(Observations, Status).

candidate_observations([], Observations, Observations).
candidate_observations(
        [candidate(_Proposal, Validation)|Candidates],
        Observations0, Observations) :-
    observe_predecessor_validation(
        Validation, Observations0, Observations1),
    candidate_observations(Candidates, Observations1, Observations).

observe_predecessor_validation(
        ground_typed_equality_validation(
            rejected(resource_limit_exceeded(Input, Limit)), _Audit),
        observations(Resources0, Unknowns, Accepted, Rejected, Outcomes,
                     Invariant),
        observations([predecessor(t003, Input, Limit)|Resources0],
                     Unknowns, Accepted, Rejected, Outcomes, Invariant)) :-
    !.
observe_predecessor_validation(
        ground_typed_equality_validation(unknown(Missing), _Audit),
        observations(Resources, Unknowns0, Accepted, Rejected, Outcomes,
                     Invariant),
        observations(Resources, [predecessor(t003, Missing)|Unknowns0],
                     Accepted, Rejected, Outcomes, Invariant)) :-
    !.
observe_predecessor_validation(
        ground_typed_equality_validation(
            accepted(validated_pair(ValidatedSpecification, _Program)),
            _Audit),
        observations(Resources, Unknowns, Accepted0, Rejected, Outcomes0,
                     Invariant),
        observations(Resources, Unknowns,
                     [ValidatedSpecification|Accepted0],
                     Rejected,
                     [accepted(ValidatedSpecification)|Outcomes0],
                     Invariant)) :-
    !.
observe_predecessor_validation(
        ground_typed_equality_validation(rejected(Reason), _Audit),
        observations(Resources, Unknowns, Accepted, Rejected0, Outcomes0,
                     Invariant),
        observations(Resources, Unknowns, Accepted,
                     [predecessor(t003, Reason)|Rejected0],
                     [rejected(predecessor(t003, Reason))|Outcomes0],
                     Invariant)) :-
    !.
observe_predecessor_validation(
        _Validation,
        observations(Resources, Unknowns, Accepted, Rejected, Outcomes,
                     _Invariant),
        observations(Resources, Unknowns, Accepted, Rejected, Outcomes,
                     invariant)).

choose_candidate_status(
        observations(Resources0, Unknowns0, Accepted0, Rejected0, Outcomes0,
                     Invariant),
        Status) :-
    sort(Resources0, Resources),
    sort(Unknowns0, Unknowns),
    sort(Accepted0, Accepted),
    sort(Rejected0, Rejected),
    sort(Outcomes0, Outcomes),
    choose_sorted_candidate_status(
        Resources, Unknowns, Accepted, Rejected, Outcomes, Invariant,
        Status).

choose_sorted_candidate_status(
        Resources, _Unknowns, _Accepted, _Rejected, _Outcomes,
        _Invariant,
        resource_exhausted(candidate_predecessors(Resources))) :-
    Resources = [_|_],
    !.
choose_sorted_candidate_status(
        [], _Unknowns, _Accepted, _Rejected, _Outcomes, invariant,
        unknown(internal_invariant(predecessor_result_shape))) :-
    !.
choose_sorted_candidate_status(
        [], Unknowns, _Accepted, _Rejected, _Outcomes, clear,
        unknown(candidate_predecessors(Unknowns))) :-
    Unknowns = [_|_],
    !.
choose_sorted_candidate_status(
        [], [], [_|_], [_|_], Outcomes, clear,
        ambiguous(mixed_candidate_outcomes(Outcomes))) :-
    !.
choose_sorted_candidate_status(
        [], [], [Only], [], _Outcomes, clear, accepted(Only)) :-
    !.
choose_sorted_candidate_status(
        [], [], [First, Second|Rest], [], _Outcomes, clear,
        ambiguous(
            distinct_validated_specifications([First, Second|Rest]))) :-
    !.
choose_sorted_candidate_status(
        [], [], [], [Only], _Outcomes, clear, rejected(Only)) :-
    !.
choose_sorted_candidate_status(
        [], [], [], [First, Second|Rest], _Outcomes, clear,
        ambiguous(distinct_rejections([First, Second|Rest]))) :-
    !.
choose_sorted_candidate_status(
        [], [], [], [], _Outcomes, _Invariant,
        unknown(internal_invariant(predecessor_result_shape))).
