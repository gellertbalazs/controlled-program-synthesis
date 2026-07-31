:- module(cps_fixed_left_reduction_v0,
          [ propose_fixed_left_reduction_v0/2,
            verify_fixed_left_reduction_v0/4
          ]).

:- use_module(cps_law_claim_authority,
              [ assess_law_claim_authority/2
              ]).

/** <module> Bounded fixed-left reduction proposal and checking

This module implements one closed, nonempty, one-to-three-value fixed-left
`combine` construction.  Proposal data never authorizes acceptance.  The
checker reparses the token input, asks T002 for fresh source-relative
authority, independently reconstructs every accepted artifact, and renders
only that checked Program AST.
*/

%!  propose_fixed_left_reduction_v0(+Tokens, -ProposalResult) is det.
%
%   Build exactly one inert candidate for the approved token sentence, or
%   return one explicit fail-closed status.  Tokens are never bound or run.
propose_fixed_left_reduction_v0(Tokens, Result) :-
    token_analysis(Tokens, TokenOutcome),
    proposal_from_token_outcome(TokenOutcome, Result),
    !.

%!  verify_fixed_left_reduction_v0(
%!      +Tokens, +Candidate, +AuthoritySnapshot, -Validation) is det.
%
%   Independently check the exact bounded candidate against fresh T002
%   authority.  No input is bound, mutated, executed, or rendered on failure.
verify_fixed_left_reduction_v0(Tokens, Candidate, Authority, Validation) :-
    token_analysis(Tokens, TokenOutcome),
    validation_from_token_outcome(
        TokenOutcome, Candidate, Authority, Validation),
    !.

% Token closure and syntax

token_analysis(Tokens, Outcome) :-
    token_direct_status(Tokens, Direct),
    continue_token_direct(Direct, Tokens, Outcome).

token_direct_status(Tokens, direct(rejected(non_ground_input(tokens)))) :-
    var(Tokens),
    !.
token_direct_status(Tokens, direct(rejected(forged_accepted_form(tokens)))) :-
    nonvar(Tokens),
    forged_token_root(Tokens),
    !.
token_direct_status([], inspect) :-
    !.
token_direct_status(Tokens, inspect) :-
    nonvar(Tokens),
    Tokens = [_Head|_Tail],
    !.
token_direct_status(_Tokens, direct(rejected(malformed_shape(tokens, root)))).

forged_token_root(Term) :-
    compound(Term),
    functor(Term, Name, Arity),
    forged_result_functor(Name, Arity).

forged_result_functor(reduction_proposal_result, 2).
forged_result_functor(proposal_audit, 3).
forged_result_functor(reduction_validation, 2).
forged_result_functor(reduction_audit, 8).
forged_result_functor(checked_reduction_v0, 6).

continue_token_direct(direct(Status), _Tokens,
        token_outcome(
            Status,
            token_preflight(not_completed),
            syntax(not_run),
            no_sentence)) :-
    !.
continue_token_direct(inspect, Tokens, Outcome) :-
    inspect_token_list(Tokens, [], 0, Preflight),
    continue_token_preflight(Preflight, Tokens, Outcome).

inspect_token_list(Term, Ancestors, _Count,
        failed(rejected(cyclic_input(tokens)))) :-
    identity_member(Term, Ancestors),
    !.
inspect_token_list(Term, _Ancestors, _Count,
        failed(rejected(non_ground_input(tokens)))) :-
    var(Term),
    !.
inspect_token_list([], _Ancestors, Count,
        checked(Count, Cells, Depth)) :-
    !,
    Cells is Count * 2 + 1,
    Depth is Count + 1.
inspect_token_list(Term, Ancestors, Count0, Outcome) :-
    Term = [Head|Tail],
    !,
    Count is Count0 + 1,
    (   Count > 26
    ->  Outcome =
            resource(
                tokens(count(max(26), observed_at_least(27))))
    ;   token_cell_status(Head, Count, HeadStatus),
        continue_token_cell(
            HeadStatus, Tail, Term, Ancestors, Count, Outcome)
    ).
inspect_token_list(_Term, _Ancestors, _Count,
        failed(rejected(malformed_shape(tokens, list)))).

token_cell_status(Token, _Position, variable) :-
    var(Token),
    !.
token_cell_status(Token, _Position, clear) :-
    atom(Token),
    !.
token_cell_status(_Token, Position, malformed(Position)).

continue_token_cell(variable, _Tail, _Term, _Ancestors, _Count,
        failed(rejected(non_ground_input(tokens)))) :-
    !.
continue_token_cell(malformed(Position), _Tail, _Term, _Ancestors, _Count,
        failed(rejected(malformed_shape(tokens, token(Position))))) :-
    !.
continue_token_cell(clear, Tail, Term, Ancestors, Count, Outcome) :-
    inspect_token_list(Tail, [Term|Ancestors], Count, Outcome).

identity_member(Term, [Head|_Tail]) :-
    Term == Head,
    !.
identity_member(Term, [_Head|Tail]) :-
    identity_member(Term, Tail).

continue_token_preflight(failed(Status), _Tokens,
        token_outcome(
            Status,
            token_preflight(not_completed),
            syntax(not_run),
            no_sentence)) :-
    !.
continue_token_preflight(resource(Resource), _Tokens,
        token_outcome(
            resource_exhausted(Resource),
            token_preflight(limit(Resource)),
            syntax(not_run),
            no_sentence)) :-
    !.
continue_token_preflight(checked(Count, Cells, Depth), Tokens, Outcome) :-
    select_token_resource(Count, Cells, Depth, Resource),
    continue_selected_token_resource(
        Resource, Tokens, Count, Cells, Depth, Outcome).

select_token_resource(Count, _Cells, _Depth,
        tokens(count(max(26), observed_at_least(27)))) :-
    Count > 26,
    !.
select_token_resource(_Count, Cells, _Depth,
        tokens(cells(max(53), observed_at_least(54)))) :-
    Cells > 53,
    !.
select_token_resource(_Count, _Cells, Depth,
        tokens(depth(max(27), observed_at_least(28)))) :-
    Depth > 27,
    !.
select_token_resource(_Count, _Cells, _Depth, none).

continue_selected_token_resource(
        Resource, _Tokens, _Count, _Cells, _Depth,
        token_outcome(
            resource_exhausted(Resource),
            token_preflight(limit(Resource)),
            syntax(not_run),
            no_sentence)) :-
    Resource \== none,
    !.
continue_selected_token_resource(
        none, Tokens, Count, Cells, Depth, Outcome) :-
    scalar_layout_status(Tokens, Count, ScalarStatus),
    continue_scalar_layout_status(
        ScalarStatus, Tokens, Count, Cells, Depth, Outcome).

scalar_layout_status(Tokens, Count, Status) :-
    (   scalar_layout(Count, Entries)
    ->  scalar_entries_status(Entries, Tokens, Status)
    ;   Status = clear
    ).

scalar_layout(19,
    [ specification_id-2,
      program_id-4,
      type_id-8,
      definition_space_id-16,
      premise_id-19
    ]).
scalar_layout(20,
    [ specification_id-2,
      program_id-4,
      value(1)-7,
      type_id-9,
      definition_space_id-17,
      premise_id-20
    ]).
scalar_layout(22,
    [ specification_id-2,
      program_id-4,
      value(1)-7,
      value(2)-9,
      type_id-11,
      definition_space_id-19,
      premise_id-22
    ]).
scalar_layout(24,
    [ specification_id-2,
      program_id-4,
      value(1)-7,
      value(2)-9,
      value(3)-11,
      type_id-13,
      definition_space_id-21,
      premise_id-24
    ]).
scalar_layout(26,
    [ specification_id-2,
      program_id-4,
      value(1)-7,
      value(2)-9,
      value(3)-11,
      value(4)-13,
      type_id-15,
      definition_space_id-23,
      premise_id-26
    ]).

scalar_entries_status([], _Tokens, clear).
scalar_entries_status([Slot-Position|Entries], Tokens, Status) :-
    nth1(Position, Tokens, Token),
    scalar_token_status(Token, ScalarStatus),
    continue_scalar_entry(
        ScalarStatus, Slot, Entries, Tokens, Status).

continue_scalar_entry(resource, Slot, _Entries, _Tokens,
        resource(
            token_scalar(Slot, max(64), observed_at_least(65)))) :-
    !.
continue_scalar_entry(malformed, Slot, _Entries, _Tokens,
        rejected(malformed_scalar(Slot))) :-
    !.
continue_scalar_entry(clear, _Slot, Entries, Tokens, Status) :-
    scalar_entries_status(Entries, Tokens, Status).

scalar_token_status(Token, resource) :-
    atom(Token),
    atom_length(Token, Length),
    Length > 64,
    !.
scalar_token_status(Token, clear) :-
    approved_scalar(Token),
    !.
scalar_token_status(_Token, malformed).

approved_scalar(Token) :-
    atom(Token),
    atom_codes(Token, [First|Rest]),
    ascii_lower(First),
    ascii_scalar_tail(Rest),
    \+ reserved_token(Token).

ascii_scalar_tail([]).
ascii_scalar_tail([Code|Codes]) :-
    (   ascii_lower(Code)
    ;   Code >= 0'0,
        Code =< 0'9
    ;   Code =:= 0'_
    ),
    ascii_scalar_tail(Codes).

ascii_lower(Code) :-
    Code >= 0'a,
    Code =< 0'z.

reserved_token(specification).
reserved_token(program).
reserved_token(reduces).
reserved_token(sequence).
reserved_token(then).
reserved_token(as).
reserved_token(from).
reserved_token(left).
reserved_token(using).
reserved_token(operation).
reserved_token(combine).
reserved_token(in).
reserved_token(definition_space).
reserved_token(premise).
reserved_token(identity).
reserved_token(right).
reserved_token(reassociated).
reserved_token(balanced).
reserved_token(parallel).
reserved_token(mutable).
reserved_token(lambda).
reserved_token(quantified).
reserved_token(executable).
reserved_token(backend).

continue_scalar_layout_status(
        resource(Resource), _Tokens, _Count, _Cells, _Depth,
        token_outcome(
            resource_exhausted(Resource),
            token_preflight(limit(Resource)),
            syntax(not_run),
            no_sentence)) :-
    !.
continue_scalar_layout_status(
        rejected(Reason), _Tokens, Count, Cells, Depth,
        token_outcome(
            rejected(Reason),
            token_preflight(checked(Count, Cells, Depth)),
            syntax(no_complete_parse),
            no_sentence)) :-
    !.
continue_scalar_layout_status(
        clear, Tokens, Count, Cells, Depth, Outcome) :-
    syntax_status(Tokens, SyntaxStatus),
    finish_syntax_status(
        SyntaxStatus, Count, Cells, Depth, Outcome).

syntax_status(Tokens, Status) :-
    (   sentence_schema(Tokens, Sentence)
    ->  classify_sentence(Sentence, Status)
    ;   Status = rejected(malformed_shape(tokens, syntax))
    ).

sentence_schema(
    [ specification, S, program, G, reduces, sequence,
      as, T, from, Order, using, operation, Operation,
      in, definition_space, D, using, premise, P
    ],
    sentence(S, G, [], T, Order, Operation, D, P)).
sentence_schema(
    [ specification, S, program, G, reduces, sequence, V1,
      as, T, from, Order, using, operation, Operation,
      in, definition_space, D, using, premise, P
    ],
    sentence(S, G, [V1], T, Order, Operation, D, P)).
sentence_schema(
    [ specification, S, program, G, reduces, sequence, V1, then, V2,
      as, T, from, Order, using, operation, Operation,
      in, definition_space, D, using, premise, P
    ],
    sentence(S, G, [V1, V2], T, Order, Operation, D, P)).
sentence_schema(
    [ specification, S, program, G, reduces, sequence,
      V1, then, V2, then, V3,
      as, T, from, Order, using, operation, Operation,
      in, definition_space, D, using, premise, P
    ],
    sentence(S, G, [V1, V2, V3], T, Order, Operation, D, P)).
sentence_schema(
    [ specification, S, program, G, reduces, sequence,
      V1, then, V2, then, V3, then, V4,
      as, T, from, Order, using, operation, Operation,
      in, definition_space, D, using, premise, P
    ],
    sentence(S, G, [V1, V2, V3, V4], T, Order, Operation, D, P)).

classify_sentence(sentence(_, _, _, _, Order, _, _, _),
        unsupported(feature(Order))) :-
    unsupported_feature(Order),
    !.
classify_sentence(sentence(_, _, _, _, Order, _, _, _),
        unsupported(order(Order))) :-
    Order \== left,
    !.
classify_sentence(sentence(_, _, _, _, left, Operation, _, _),
        unsupported(operation(Operation))) :-
    Operation \== combine,
    !.
classify_sentence(sentence(_, _, [], _, left, combine, _, _),
        unsupported(empty_reduction)) :-
    !.
classify_sentence(sentence(_, _, Values, _, left, combine, _, _),
        resource(
            source_values(max(3), observed_at_least(4)))) :-
    Values = [_, _, _, _],
    !.
classify_sentence(Sentence, accepted(Sentence)).

unsupported_feature(identity).
unsupported_feature(balanced).
unsupported_feature(parallel).
unsupported_feature(mutable).
unsupported_feature(lambda).
unsupported_feature(quantified).
unsupported_feature(executable).
unsupported_feature(backend).

finish_syntax_status(
        rejected(Reason), Count, Cells, Depth,
        token_outcome(
            rejected(Reason),
            token_preflight(checked(Count, Cells, Depth)),
            syntax(no_complete_parse),
            no_sentence)) :-
    !.
finish_syntax_status(
        unsupported(Class), Count, Cells, Depth,
        token_outcome(
            unsupported(Class),
            token_preflight(checked(Count, Cells, Depth)),
            syntax(recognized(Class)),
            no_sentence)) :-
    !.
finish_syntax_status(
        resource(Resource), Count, Cells, Depth,
        token_outcome(
            resource_exhausted(Resource),
            token_preflight(checked(Count, Cells, Depth)),
            syntax(source_value_limit(max(3), observed_at_least(4))),
            no_sentence)) :-
    !.
finish_syntax_status(
        accepted(Sentence), Count, Cells, Depth,
        token_outcome(
            continue,
            token_preflight(checked(Count, Cells, Depth)),
            syntax(complete(Sentence)),
            Sentence)).

% Proposal plane: these constructors are not used by the checker.

proposal_from_token_outcome(
        token_outcome(continue, token_preflight(Preflight),
                      syntax(complete(Sentence)), Sentence),
        reduction_proposal_result(
            proposed(Candidate),
            proposal_audit(
                ProposalPreflight,
                complete(SentenceAudit),
                candidate_count(1)))) :-
    proposal_preflight_audit(Preflight, ProposalPreflight),
    proposal_sentence_audit(Sentence, SentenceAudit),
    proposal_candidate(Sentence, Candidate),
    !.
proposal_from_token_outcome(
        token_outcome(Status, token_preflight(Preflight),
                      syntax(Syntax), _Sentence),
        reduction_proposal_result(
            Status,
            proposal_audit(ProposalPreflight, Syntax,
                           candidate_count(0)))) :-
    Status \== continue,
    proposal_preflight_audit(Preflight, ProposalPreflight).

proposal_preflight_audit(
        checked(Count, Cells, Depth),
        checked(tokens(Count), cells(Cells), depth(Depth))) :-
    !.
proposal_preflight_audit(Other, Other).

proposal_sentence_audit(
        sentence(S, G, Values, T, _Order, _Operation, D, P),
        reduction_sentence(
            specification_id(S), program_id(G), type_id(T),
            values(ValueTerms), definition_space_id(D), premise_id(P))) :-
    proposal_value_terms(Values, ValueTerms).

proposal_value_terms([], []).
proposal_value_terms([Value|Values],
        [atom_value(Value)|ValueTerms]) :-
    proposal_value_terms(Values, ValueTerms).

proposal_candidate(
        sentence(S, G, Values, T, left, combine, D, P),
        reduction_candidate_v0(Specification, Program, Proof)) :-
    proposal_specification(S, G, Values, T, D, P, Specification),
    proposal_program(G, Values, T, D, P, Program, Expression),
    proposal_proof(S, G, Values, T, D, P, Expression, Proof).

proposal_specification(S, G, Values, T, D, P,
        reduction_specification_v0(
            specification_id(S),
            program_id(G),
            type_id(T),
            values(ValueTerms),
            operation_id(combine),
            order(left),
            definition_space_id(D),
            premise_id(P))) :-
    proposal_value_terms(Values, ValueTerms).

proposal_program(G, Values, T, D, P,
        reduction_program_v0(
            program_id(G),
            signature(input(sequence(type_id(T))), output(type_id(T))),
            expression(Expression),
            definition_space_id(D),
            premise_id(P)),
        Expression) :-
    proposal_expression(Values, T, Expression).

proposal_expression([Value|Values], T, Expression) :-
    Leaf = value(atom_value(Value), type_id(T)),
    proposal_expression_tail(Values, T, Leaf, Expression).

proposal_expression_tail([], _T, Expression, Expression).
proposal_expression_tail([Value|Values], T, Accumulator, Expression) :-
    Next =
        apply(
            operation_id(combine),
            Accumulator,
            value(atom_value(Value), type_id(T)),
            type_id(T)),
    proposal_expression_tail(Values, T, Next, Expression).

proposal_proof(S, G, Values, T, D, P, Expression,
        fixed_left_reduction_proof_v0(
            theory(source_relative_fixed_left_v0),
            scope_references([
                specification_id(S),
                program_id(G),
                operation_id(combine),
                definition_space_id(D),
                premise_id(P)
            ]),
            steps(Steps),
            root(step_id(Count)),
            conclusion(
                fixed_left_reduction(
                    Expression,
                    operation_applications(Applications))))) :-
    length(Values, Count),
    Applications is Count - 1,
    proposal_steps(Values, T, Steps).

proposal_steps([Value|Values], T, Steps) :-
    Leaf = value(atom_value(Value), type_id(T)),
    Base =
        proof_step(
            step_id(1),
            fixed_left_base,
            dependencies([]),
            source(index(1), atom_value(Value)),
            conclusion(prefix(Leaf), operation_applications(0))),
    proposal_extension_steps(Values, T, 2, Leaf, [Base], Steps).

proposal_extension_steps([], _T, _Index, _Expression, Steps, Steps).
proposal_extension_steps(
        [Value|Values], T, Index, Previous, Steps0, Steps) :-
    PreviousIndex is Index - 1,
    Applications is Index - 1,
    Expression =
        apply(
            operation_id(combine),
            Previous,
            value(atom_value(Value), type_id(T)),
            type_id(T)),
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
    NextIndex is Index + 1,
    proposal_extension_steps(
        Values, T, NextIndex, Expression, Steps1, Steps).

% Checker input closure

validation_from_token_outcome(
        token_outcome(Status, token_preflight(TokenPreflight),
                      syntax(Syntax), _Sentence),
        _Candidate, _Authority,
        reduction_validation(
            Status,
            reduction_audit(
                ValidationPreflight, Syntax,
                not_run, not_run, not_run, not_run, not_run, not_run))) :-
    Status \== continue,
    validation_token_preflight(
        TokenPreflight, ValidationPreflight),
    !.
validation_from_token_outcome(
        token_outcome(continue, token_preflight(TokenPreflight),
                      syntax(complete(Sentence)), Sentence),
        Candidate, Authority, Validation) :-
    candidate_direct_status(Candidate, Direct),
    continue_candidate_direct(
        Direct, TokenPreflight, Sentence, Candidate, Authority, Validation).

validation_token_preflight(not_completed, not_completed).
validation_token_preflight(limit(Resource), limit(Resource)).
validation_token_preflight(checked(Count, Cells, Depth),
        checked(
            tokens(tokens(Count), cells(Cells), depth(Depth)),
            candidate(not_run))).

candidate_direct_status(Candidate,
        direct(rejected(non_ground_input(candidate)))) :-
    var(Candidate),
    !.
candidate_direct_status(Candidate,
        direct(rejected(forged_accepted_form(candidate)))) :-
    nonvar(Candidate),
    forged_candidate_root(Candidate),
    !.
candidate_direct_status(Candidate, inspect) :-
    nonvar(Candidate),
    functor(Candidate, reduction_candidate_v0, 3),
    !.
candidate_direct_status(_Candidate,
        direct(rejected(malformed_shape(candidate, root)))).

forged_candidate_root(Term) :-
    compound(Term),
    functor(Term, Name, Arity),
    forged_candidate_functor(Name, Arity).

forged_candidate_functor(reduction_validation, 2).
forged_candidate_functor(reduction_audit, 8).
forged_candidate_functor(checked_reduction_v0, 6).
forged_candidate_functor(reduction_proposal_result, 2).

continue_candidate_direct(
        direct(Status), TokenPreflight, Sentence,
        _Candidate, _Authority,
        reduction_validation(
            Status,
            reduction_audit(
                checked(
                    tokens(TokenAudit),
                    candidate(not_completed)),
                complete(SentenceAudit),
                not_run, not_run, not_run, not_run, not_run, not_run))) :-
    token_audit_term(TokenPreflight, TokenAudit),
    checker_sentence_audit(Sentence, SentenceAudit),
    !.
continue_candidate_direct(
        inspect, TokenPreflight, Sentence, Candidate, Authority,
        Validation) :-
    candidate_preflight(Candidate, CandidatePreflight),
    continue_candidate_preflight(
        CandidatePreflight, TokenPreflight, Sentence,
        Candidate, Authority, Validation).

token_audit_term(
        checked(Count, Cells, Depth),
        tokens(tokens(Count), cells(Cells), depth(Depth))).

candidate_preflight(Candidate, Outcome) :-
    bounded_candidate_scan(
        cycle, Candidate, [], 1, 0, 0,
        _CycleCells, _CycleDepth, CycleStatus),
    continue_candidate_cycle(CycleStatus, Candidate, Outcome).

continue_candidate_cycle(found, _Candidate,
        failed(rejected(cyclic_input(candidate)))) :-
    !.
continue_candidate_cycle(_CycleStatus, Candidate, Outcome) :-
    bounded_candidate_scan(
        variable, Candidate, [], 1, 0, 0,
        Cells, Depth, VariableStatus),
    finish_candidate_variable(
        VariableStatus, Cells, Depth, Outcome).

finish_candidate_variable(found, _Cells, _Depth,
        failed(rejected(non_ground_input(candidate)))) :-
    !.
finish_candidate_variable(bounded(Resource), _Cells, _Depth,
        resource(Resource)) :-
    !.
finish_candidate_variable(clear, Cells, Depth, checked(Cells, Depth)).

bounded_candidate_scan(
        _Mode, _Term, _Ancestors, Depth, Cells, MaximumDepth,
        Cells, MaximumDepth, bounded(Resource)) :-
    Depth > 32,
    !,
    Resource = candidate(depth(max(32), observed_at_least(33))).
bounded_candidate_scan(
        _Mode, _Term, _Ancestors, _Depth, Cells, MaximumDepth,
        Cells, MaximumDepth, bounded(Resource)) :-
    Cells >= 512,
    !,
    Resource = candidate(cells(max(512), observed_at_least(513))).
bounded_candidate_scan(
        cycle, Term, Ancestors, _Depth, Cells, MaximumDepth,
        Cells, MaximumDepth, found) :-
    identity_member(Term, Ancestors),
    !.
bounded_candidate_scan(
        variable, Term, _Ancestors, Depth, Cells0, MaximumDepth0,
        Cells, MaximumDepth, found) :-
    var(Term),
    !,
    Cells is Cells0 + 1,
    maximum_number(MaximumDepth0, Depth, MaximumDepth).
bounded_candidate_scan(
        cycle, Term, _Ancestors, Depth, Cells0, MaximumDepth0,
        Cells, MaximumDepth, clear) :-
    var(Term),
    !,
    Cells is Cells0 + 1,
    maximum_number(MaximumDepth0, Depth, MaximumDepth).
bounded_candidate_scan(
        _Mode, Term, _Ancestors, Depth, Cells0, MaximumDepth0,
        Cells, MaximumDepth, clear) :-
    atomic(Term),
    !,
    Cells is Cells0 + 1,
    maximum_number(MaximumDepth0, Depth, MaximumDepth).
bounded_candidate_scan(
        Mode, Term, Ancestors, Depth, Cells0, MaximumDepth0,
        Cells, MaximumDepth, Status) :-
    Cells1 is Cells0 + 1,
    maximum_number(MaximumDepth0, Depth, MaximumDepth1),
    functor(Term, _Name, Arity),
    NextDepth is Depth + 1,
    bounded_candidate_arguments(
        1, Arity, Mode, Term, [Term|Ancestors], NextDepth,
        Cells1, MaximumDepth1, Cells, MaximumDepth, Status).

bounded_candidate_arguments(
        Index, Arity, _Mode, _Term, _Ancestors, _Depth,
        Cells, MaximumDepth, Cells, MaximumDepth, clear) :-
    Index > Arity,
    !.
bounded_candidate_arguments(
        Index, Arity, Mode, Term, Ancestors, Depth,
        Cells0, MaximumDepth0, Cells, MaximumDepth, Status) :-
    arg(Index, Term, Argument),
    bounded_candidate_scan(
        Mode, Argument, Ancestors, Depth, Cells0, MaximumDepth0,
        Cells1, MaximumDepth1, ArgumentStatus),
    continue_candidate_arguments(
        ArgumentStatus, Index, Arity, Mode, Term, Ancestors, Depth,
        Cells1, MaximumDepth1, Cells, MaximumDepth, Status).

continue_candidate_arguments(
        found, _Index, _Arity, _Mode, _Term, _Ancestors, _Depth,
        Cells, MaximumDepth, Cells, MaximumDepth, found) :-
    !.
continue_candidate_arguments(
        bounded(Resource), _Index, _Arity, _Mode, _Term, _Ancestors, _Depth,
        Cells, MaximumDepth, Cells, MaximumDepth, bounded(Resource)) :-
    !.
continue_candidate_arguments(
        clear, Index, Arity, Mode, Term, Ancestors, Depth,
        Cells0, MaximumDepth0, Cells, MaximumDepth, Status) :-
    NextIndex is Index + 1,
    bounded_candidate_arguments(
        NextIndex, Arity, Mode, Term, Ancestors, Depth,
        Cells0, MaximumDepth0, Cells, MaximumDepth, Status).

maximum_number(First, Second, First) :-
    First >= Second,
    !.
maximum_number(_First, Second, Second).

continue_candidate_preflight(
        failed(Status), TokenPreflight, Sentence,
        _Candidate, _Authority,
        reduction_validation(
            Status,
            reduction_audit(
                checked(
                    tokens(TokenAudit),
                    candidate(not_completed)),
                complete(SentenceAudit),
                not_run, not_run, not_run, not_run, not_run, not_run))) :-
    token_audit_term(TokenPreflight, TokenAudit),
    checker_sentence_audit(Sentence, SentenceAudit),
    !.
continue_candidate_preflight(
        resource(Resource), TokenPreflight, Sentence,
        _Candidate, _Authority,
        reduction_validation(
            resource_exhausted(Resource),
            reduction_audit(
                checked(
                    tokens(TokenAudit),
                    candidate(limit(Resource))),
                complete(SentenceAudit),
                not_run, not_run, not_run, not_run, not_run, not_run))) :-
    token_audit_term(TokenPreflight, TokenAudit),
    checker_sentence_audit(Sentence, SentenceAudit),
    !.
continue_candidate_preflight(
        checked(CandidateCells, CandidateDepth),
        TokenPreflight, Sentence, Candidate, Authority, Validation) :-
    candidate_local_status(Candidate, LocalStatus),
    continue_candidate_local_status(
        LocalStatus, TokenPreflight, CandidateCells, CandidateDepth,
        Sentence, Candidate, Authority, Validation).

checker_sentence_audit(
        sentence(S, G, Values, T, _Order, _Operation, D, P),
        reduction_sentence(
            specification_id(S), program_id(G), type_id(T),
            values(ValueTerms), definition_space_id(D), premise_id(P))) :-
    checker_value_terms(Values, ValueTerms).

checker_value_terms([], []).
checker_value_terms([Value|Values], [atom_value(Value)|ValueTerms]) :-
    checker_value_terms(Values, ValueTerms).

candidate_local_status(
        reduction_candidate_v0(Specification, Program, Proof), Status) :-
    candidate_nested_shape(
        Specification, Program, Proof, NestedStatus),
    continue_candidate_nested_shape(
        NestedStatus, Specification, Program, Proof, Status).

candidate_nested_shape(Specification, _Program, _Proof,
        rejected(malformed_shape(candidate, specification))) :-
    \+ valid_specification_root(Specification),
    !.
candidate_nested_shape(_Specification, Program, _Proof,
        rejected(malformed_shape(candidate, program))) :-
    \+ valid_program_root(Program),
    !.
candidate_nested_shape(_Specification, _Program, Proof,
        unsupported(proof_format)) :-
    \+ valid_proof_root(Proof),
    !.
candidate_nested_shape(_Specification, _Program, Proof,
        unsupported(theory)) :-
    Proof =
        fixed_left_reduction_proof_v0(
            Theory, _Scope, _Steps, _Root, _Conclusion),
    Theory \== theory(source_relative_fixed_left_v0),
    !.
candidate_nested_shape(_Specification, _Program, Proof,
        unsupported(rule)) :-
    Proof =
        fixed_left_reduction_proof_v0(
            _Theory, _Scope, steps(Steps), _Root, _Conclusion),
    first_unsupported_step(Steps),
    !.
candidate_nested_shape(_Specification, _Program, _Proof, clear).

valid_specification_root(
    reduction_specification_v0(
        specification_id(_), program_id(_), type_id(_), values(_),
        operation_id(_), order(_), definition_space_id(_), premise_id(_))).

valid_program_root(
    reduction_program_v0(
        program_id(_),
        signature(input(sequence(type_id(_))), output(type_id(_))),
        expression(_), definition_space_id(_), premise_id(_))).

valid_proof_root(
    fixed_left_reduction_proof_v0(
        theory(_), scope_references(_), steps(_), root(_), conclusion(_))).

first_unsupported_step(Steps) :-
    proper_list(Steps),
    member(Step, Steps),
    unsupported_step(Step),
    !.

unsupported_step(
    proof_step(_Id, Rule, dependencies(_), source(_Index, _Value),
               conclusion(_Prefix, _Applications))) :-
    \+ supported_proof_rule(Rule),
    !.
unsupported_step(Step) :-
    \+ Step = proof_step(_, _, dependencies(_), source(_, _),
                         conclusion(_, _)).

supported_proof_rule(fixed_left_base).
supported_proof_rule(fixed_left_extend).
supported_proof_rule(hole).
supported_proof_rule(trusted_step).

continue_candidate_nested_shape(
        Status, _Specification, _Program, _Proof, Status) :-
    Status \== clear,
    !.
continue_candidate_nested_shape(
        clear, Specification, Program, Proof, Status) :-
    candidate_specific_resource(
        Specification, Program, Proof, ResourceStatus),
    continue_candidate_specific_resource(
        ResourceStatus, Specification, Program, Proof, Status).

candidate_specific_resource(
        Specification, _Program, _Proof, Status) :-
    Specification =
        reduction_specification_v0(
            _, _, _, values(Values), _, _, _, _),
    bounded_list_status(Values, 3, values, Status0),
    Status0 \== clear,
    !,
    Status = Status0.
candidate_specific_resource(
        _Specification, _Program, Proof, Status) :-
    Proof =
        fixed_left_reduction_proof_v0(
            _, scope_references(References), steps(Steps), _, _),
    bounded_list_status(Steps, 3, steps, StepsStatus),
    bounded_list_status(
        References, 5, scope_references, ReferenceStatus),
    first_non_clear([StepsStatus, ReferenceStatus], Status0),
    Status0 \== clear,
    !,
    Status = Status0.
candidate_specific_resource(
        _Specification, _Program, Proof, Status) :-
    Proof =
        fixed_left_reduction_proof_v0(
            _, _, steps(Steps), _, _),
    step_dependency_status(Steps, Status0),
    Status0 \== clear,
    !,
    Status = Status0.
candidate_specific_resource(
        _Specification, Program, _Proof, Status) :-
    Program = reduction_program_v0(_, _, expression(Expression), _, _),
    expression_measure(Expression, Nodes, Depth),
    select_ast_resource(Nodes, Depth, Status0),
    Status0 \== clear,
    !,
    Status = resource(Status0).
candidate_specific_resource(
        Specification, Program, Proof, Status) :-
    candidate_scalar_status(
        Specification, Program, Proof, ScalarStatus),
    ScalarStatus \== clear,
    !,
    Status = ScalarStatus.
candidate_specific_resource(
        _Specification, _Program, _Proof, clear).

bounded_list_status(List, Maximum, Field, Status) :-
    bounded_list_status(List, Maximum, Field, 0, Status).

bounded_list_status([], _Maximum, _Field, _Count, clear) :-
    !.
bounded_list_status([_Head|Tail], Maximum, Field, Count0, Status) :-
    !,
    Count is Count0 + 1,
    (   Count > Maximum
    ->  Observed is Maximum + 1,
        Status =
            resource(
                candidate_list(
                    Field, max(Maximum), observed_at_least(Observed)))
    ;   bounded_list_status(Tail, Maximum, Field, Count, Status)
    ).
bounded_list_status(_Term, _Maximum, Field, _Count,
        rejected(malformed_shape(candidate, Field))).

proper_list([]).
proper_list([_Head|Tail]) :-
    proper_list(Tail).

first_non_clear([Status|_Statuses], Status) :-
    Status \== clear,
    !.
first_non_clear([clear|Statuses], Status) :-
    first_non_clear(Statuses, Status).
first_non_clear([], clear).

step_dependency_status([], clear) :-
    !.
step_dependency_status(
        [proof_step(_, _, dependencies(Dependencies), _, _)|Steps], Status) :-
    !,
    bounded_list_status(Dependencies, 1, dependencies, HeadStatus),
    (   HeadStatus == clear
    ->  step_dependency_status(Steps, Status)
    ;   Status = HeadStatus
    ).
step_dependency_status([_Malformed|_Steps],
        rejected(malformed_shape(candidate, dependencies))).

expression_measure(value(_Value, _Type), 1, 1) :-
    !.
expression_measure(apply(_, Left, Right, _), Nodes, Depth) :-
    !,
    expression_measure(Left, LeftNodes, LeftDepth),
    expression_measure(Right, RightNodes, RightDepth),
    Nodes is LeftNodes + RightNodes + 1,
    maximum_number(LeftDepth, RightDepth, ChildDepth),
    Depth is ChildDepth + 1.
expression_measure(Term, Nodes, Depth) :-
    generic_expression_measure(Term, Nodes, Depth).

generic_expression_measure(Term, 1, 1) :-
    atomic(Term),
    !.
generic_expression_measure(Term, Nodes, Depth) :-
    functor(Term, _Name, Arity),
    generic_expression_arguments(1, Arity, Term, 1, 0, Nodes, Depth).

generic_expression_arguments(Index, Arity, _Term,
        Nodes0, ChildDepth0, Nodes, Depth) :-
    Index > Arity,
    !,
    Nodes = Nodes0,
    Depth is ChildDepth0 + 1.
generic_expression_arguments(Index, Arity, Term,
        Nodes0, ChildDepth0, Nodes, Depth) :-
    arg(Index, Term, Argument),
    generic_expression_measure(Argument, ArgumentNodes, ArgumentDepth),
    Nodes1 is Nodes0 + ArgumentNodes,
    maximum_number(ChildDepth0, ArgumentDepth, ChildDepth1),
    NextIndex is Index + 1,
    generic_expression_arguments(
        NextIndex, Arity, Term, Nodes1, ChildDepth1, Nodes, Depth).

select_ast_resource(Nodes, _Depth,
        program_ast(nodes(max(5), observed_at_least(6)))) :-
    Nodes > 5,
    !.
select_ast_resource(_Nodes, Depth,
        program_ast(depth(max(3), observed_at_least(4)))) :-
    Depth > 3,
    !.
select_ast_resource(_Nodes, _Depth, clear).

candidate_scalar_status(Specification, Program, Proof, Status) :-
    candidate_scalar_entries(
        Specification, Program, Proof, Entries),
    candidate_scalar_entries_status(Entries, Status).

candidate_scalar_entries(
        reduction_specification_v0(
            specification_id(S), program_id(G), type_id(T), values(Values),
            _Operation, _Order, definition_space_id(D), premise_id(P)),
        reduction_program_v0(
            program_id(ProgramG),
            signature(input(sequence(type_id(InputT))),
                      output(type_id(OutputT))),
            expression(Expression),
            definition_space_id(ProgramD), premise_id(ProgramP)),
        Proof,
        Entries) :-
    value_scalar_entries(Values, 1, ValueEntries),
    expression_scalar_entries(Expression, ExpressionEntries),
    proof_scalar_entries(Proof, ProofEntries),
    append(
        [ [ specification_id-S,
            program_id-G,
            type_id-T
          ],
          ValueEntries,
          [ definition_space_id-D,
            premise_id-P,
            program_id-ProgramG,
            type_id-InputT,
            type_id-OutputT,
            definition_space_id-ProgramD,
            premise_id-ProgramP
          ],
          ExpressionEntries,
          ProofEntries
        ],
        Entries).

value_scalar_entries([], _Index, []).
value_scalar_entries([atom_value(Value)|Values], Index,
        [value(Index)-Value|Entries]) :-
    !,
    Next is Index + 1,
    value_scalar_entries(Values, Next, Entries).
value_scalar_entries([_Malformed|Values], Index, Entries) :-
    Next is Index + 1,
    value_scalar_entries(Values, Next, Entries).

expression_scalar_entries(
        value(atom_value(Value), type_id(Type)),
        [program_value-Value, type_id-Type]) :-
    !.
expression_scalar_entries(
        apply(_Operation, Left, Right, type_id(Type)), Entries) :-
    !,
    expression_scalar_entries(Left, LeftEntries),
    expression_scalar_entries(Right, RightEntries),
    append([type_id-Type|LeftEntries], RightEntries, Entries).
expression_scalar_entries(_Other, []).

proof_scalar_entries(
        fixed_left_reduction_proof_v0(
            _Theory, scope_references(References), steps(Steps),
            _Root, conclusion(FinalConclusion)),
        Entries) :-
    scope_scalar_entries(References, ScopeEntries),
    proof_step_scalar_entries(Steps, StepEntries),
    proof_conclusion_scalar_entries(FinalConclusion, ConclusionEntries),
    append([ScopeEntries, StepEntries, ConclusionEntries], Entries).

scope_scalar_entries([], []).
scope_scalar_entries([Reference|References], Entries) :-
    reference_scalar_entry(Reference, HeadEntries),
    scope_scalar_entries(References, TailEntries),
    append(HeadEntries, TailEntries, Entries).

reference_scalar_entry(specification_id(Value), [specification_id-Value]) :- !.
reference_scalar_entry(program_id(Value), [program_id-Value]) :- !.
reference_scalar_entry(definition_space_id(Value),
                       [definition_space_id-Value]) :- !.
reference_scalar_entry(premise_id(Value), [premise_id-Value]) :- !.
reference_scalar_entry(_Other, []).

proof_step_scalar_entries([], []).
proof_step_scalar_entries(
        [ proof_step(
              _Id, _Rule, _Dependencies,
              source(_Index, atom_value(Value)),
              conclusion(prefix(Expression), _Applications))
        | Steps
        ],
        Entries) :-
    !,
    expression_scalar_entries(Expression, ExpressionEntries),
    proof_step_scalar_entries(Steps, TailEntries),
    append([proof_value-Value|ExpressionEntries], TailEntries, Entries).
proof_step_scalar_entries([_Other|Steps], Entries) :-
    proof_step_scalar_entries(Steps, Entries).

proof_conclusion_scalar_entries(
        fixed_left_reduction(Expression, _Applications), Entries) :-
    !,
    expression_scalar_entries(Expression, Entries).
proof_conclusion_scalar_entries(_Other, []).

candidate_scalar_entries_status([], clear).
candidate_scalar_entries_status([Slot-Token|Entries], Status) :-
    scalar_token_status(Token, TokenStatus),
    continue_candidate_scalar_entry(TokenStatus, Slot, Entries, Status).

continue_candidate_scalar_entry(resource, Slot, _Entries,
        resource(
            candidate_scalar(
                Slot, max(64), observed_at_least(65)))) :-
    !.
continue_candidate_scalar_entry(malformed, Slot, _Entries,
        rejected(malformed_scalar(candidate(Slot)))) :-
    !.
continue_candidate_scalar_entry(clear, _Slot, Entries, Status) :-
    candidate_scalar_entries_status(Entries, Status).

continue_candidate_specific_resource(
        Status, _Specification, _Program, _Proof, Status) :-
    Status \== clear,
    !.
continue_candidate_specific_resource(
        clear, Specification, Program, Proof,
        ready(candidate_data(Specification, Program, Proof))).

continue_candidate_local_status(
        LocalStatus, TokenPreflight, CandidateCells, CandidateDepth,
        Sentence, _Candidate, _Authority,
        reduction_validation(
            Status,
            reduction_audit(
                CheckedPreflight,
                complete(SentenceAudit),
                not_run, not_run, not_run, not_run, not_run, not_run))) :-
    local_failure_status(LocalStatus, Status),
    !,
    checked_validation_preflight(
        TokenPreflight, CandidateCells, CandidateDepth,
        CheckedPreflight),
    checker_sentence_audit(Sentence, SentenceAudit).
continue_candidate_local_status(
        ready(CandidateData), TokenPreflight, CandidateCells, CandidateDepth,
        Sentence, _Candidate, Authority, Validation) :-
    assess_law_claim_authority(Authority, Assessment),
    continue_authority_assessment(
        Assessment, Authority,
        TokenPreflight, CandidateCells, CandidateDepth,
        Sentence, CandidateData, Validation).

local_failure_status(rejected(Reason), rejected(Reason)).
local_failure_status(unsupported(Class), unsupported(Class)).
local_failure_status(resource(Resource), resource_exhausted(Resource)).

checked_validation_preflight(
        checked(Count, TokenCells, TokenDepth),
        CandidateCells, CandidateDepth,
        checked(
            tokens(tokens(Count), cells(TokenCells), depth(TokenDepth)),
            candidate(cells(CandidateCells), depth(CandidateDepth)))).

continue_authority_assessment(
        Assessment, _Authority,
        TokenPreflight, CandidateCells, CandidateDepth,
        Sentence, _CandidateData,
        reduction_validation(
            Status,
            reduction_audit(
                CheckedPreflight,
                complete(SentenceAudit),
                Assessment,
                not_run, not_run, not_run, not_run, not_run))) :-
    authority_nonacceptance_status(Assessment, Status),
    !,
    checked_validation_preflight(
        TokenPreflight, CandidateCells, CandidateDepth,
        CheckedPreflight),
    checker_sentence_audit(Sentence, SentenceAudit).
continue_authority_assessment(
        authority_assessment(accepted, AuthorityAudit), Authority,
        TokenPreflight, CandidateCells, CandidateDepth,
        Sentence, CandidateData, Validation) :-
    authority_projection_status(
        Sentence, Authority, AuthorityAudit, ProjectionStatus),
    continue_authority_projection(
        ProjectionStatus, AuthorityAudit,
        TokenPreflight, CandidateCells, CandidateDepth,
        Sentence, CandidateData, Validation).
continue_authority_assessment(
        Assessment, _Authority,
        TokenPreflight, CandidateCells, CandidateDepth,
        Sentence, _CandidateData,
        reduction_validation(
            unknown(internal_invariant(t002_result)),
            reduction_audit(
                CheckedPreflight,
                complete(SentenceAudit),
                Assessment,
                not_run, not_run, not_run, not_run, not_run))) :-
    checked_validation_preflight(
        TokenPreflight, CandidateCells, CandidateDepth,
        CheckedPreflight),
    checker_sentence_audit(Sentence, SentenceAudit).

authority_nonacceptance_status(
        authority_assessment(rejected(resource_limit_exceeded), _Audit),
        resource_exhausted(
            predecessor(t002, resource_limit_exceeded))) :-
    !.
authority_nonacceptance_status(
        authority_assessment(rejected(Reason), _Audit),
        rejected(authority(t002, Reason))) :-
    !.
authority_nonacceptance_status(
        authority_assessment(unknown(Missing), _Audit),
        unknown(authority(t002, Missing))).

authority_projection_status(
        Sentence, Authority, AuthorityAudit, Status) :-
    (   authority_projection_pairs(
            Sentence, Authority, AuthorityAudit, Pairs)
    ->  first_projection_difference(Pairs, Status)
    ;   Status = mismatch(authority_shape)
    ).

authority_projection_pairs(
        sentence(_S, _G, _Values, T, left, combine, D, P),
        authority_snapshot(
            policy(PolicyId, PolicyKind, PolicyProvenance),
            claim(
                ClaimId,
                semantics(
                    signature(SignatureId),
                    definedness(DefinitionId),
                    law(LawId, equality(EqualityId)),
                    termination(TerminationId),
                    cost(CostId),
                    effects(EffectsId),
                    provenance(ClaimProvenance)),
                uses(PremiseIds),
                requires(ObligationIds),
                conflicts(ContradictionIds),
                Lifecycle),
            semantic_records(
                SignatureRecord,
                DefinitionRecord,
                LawRecord,
                EqualityRecord,
                TerminationRecord,
                CostRecord,
                EffectsRecord),
            Premises,
            Obligations,
            Contradictions,
            Provenances),
        AuthorityAudit,
        Pairs) :-
    PolicyProvenance = provenance_id(_),
    Provenances = [provenance(PolicyProvenance, Evidence)],
    ExpectedUsed = [
        claim_id(combine_fixed_left),
        policy_id(source_policy),
        signature_id(T),
        definition_space_id(D),
        law_id(combine_fixed_left),
        equality_id(structural),
        termination_id(remaining_values),
        cost_id(n_minus_one),
        effects_id(pure_fresh),
        premise_id(P),
        obligation_id(each_application_defined),
        contradiction_id(no_undefined_application)
    ],
    ExpectedAudit =
        audit(
            claim_id(combine_fixed_left),
            policy_id(source_policy),
            used(ExpectedUsed),
            provenance([provenance(PolicyProvenance, Evidence)])),
    Pairs = [
        policy_id-policy_id(source_policy)-PolicyId,
        policy_kind-source_relative_law_v1-PolicyKind,
        claim_id-claim_id(combine_fixed_left)-ClaimId,
        signature_id-signature_id(T)-SignatureId,
        definition_space_id-definition_space_id(D)-DefinitionId,
        law_id-law_id(combine_fixed_left)-LawId,
        equality_id-equality_id(structural)-EqualityId,
        termination_id-termination_id(remaining_values)-TerminationId,
        cost_id-cost_id(n_minus_one)-CostId,
        effects_id-effects_id(pure_fresh)-EffectsId,
        premise_ids-[premise_id(P)]-PremiseIds,
        obligation_ids-[obligation_id(each_application_defined)]-ObligationIds,
        contradiction_ids-[contradiction_id(no_undefined_application)]-
            ContradictionIds,
        lifecycle-current(PolicyProvenance)-Lifecycle,
        claim_provenance-PolicyProvenance-ClaimProvenance,
        signature_descriptor-
            signature(
                signature_id(T), descriptor(binary_same_type_combine),
                accepted(PolicyProvenance), PolicyProvenance)-
            SignatureRecord,
        definition_descriptor-
            definition_space(
                definition_space_id(D), signature_id(T),
                descriptor(one_to_three_ground_values),
                accepted(PolicyProvenance), PolicyProvenance)-
            DefinitionRecord,
        law_descriptor-
            law(
                law_id(combine_fixed_left), signature_id(T),
                definition_space_id(D), equality_id(structural),
                descriptor(fixed_left_construction),
                accepted(PolicyProvenance), PolicyProvenance)-
            LawRecord,
        equality_relation-
            equality_relation(
                equality_id(structural), signature_id(T),
                definition_space_id(D), relation(structural_term_identity),
                accepted(PolicyProvenance), PolicyProvenance)-
            EqualityRecord,
        termination_measure-
            termination(
                termination_id(remaining_values),
                law_id(combine_fixed_left), measure(remaining_values),
                accepted(PolicyProvenance), PolicyProvenance)-
            TerminationRecord,
        cost_operation_count-
            cost(
                cost_id(n_minus_one), law_id(combine_fixed_left),
                operation_count(n_minus_one),
                accepted(PolicyProvenance), PolicyProvenance)-
            CostRecord,
        effects_conditions-
            effects(
                effects_id(pure_fresh), law_id(combine_fixed_left),
                conditions(pure_fresh_construction),
                accepted(PolicyProvenance), PolicyProvenance)-
            EffectsRecord,
        premise_records-
            [ premise(
                  premise_id(P), active(PolicyProvenance),
                  trusted(policy_id(source_policy), PolicyProvenance),
                  PolicyProvenance)
            ]-Premises,
        obligation_records-
            [ obligation(
                  obligation_id(each_application_defined),
                  law_id(combine_fixed_left), applicable(PolicyProvenance),
                  accepted(PolicyProvenance), PolicyProvenance)
            ]-Obligations,
        contradiction_records-
            [ contradiction(
                  contradiction_id(no_undefined_application),
                  claim_id(combine_fixed_left), cleared(PolicyProvenance),
                  PolicyProvenance)
            ]-Contradictions,
        provenance_records-
            [provenance(PolicyProvenance, Evidence)]-Provenances,
        audit_used-ExpectedAudit-AuthorityAudit
    ].

first_projection_difference([Field-Expected-Actual|_Pairs],
        mismatch(Field)) :-
    Expected \== Actual,
    !.
first_projection_difference([_Pair|Pairs], Status) :-
    first_projection_difference(Pairs, Status).
first_projection_difference([], clear).

continue_authority_projection(
        mismatch(Field), AuthorityAudit,
        TokenPreflight, CandidateCells, CandidateDepth,
        Sentence, _CandidateData,
        reduction_validation(
            rejected(authority_scope_mismatch(Field)),
            reduction_audit(
                CheckedPreflight,
                complete(SentenceAudit),
                authority_assessment(accepted, AuthorityAudit),
                not_run, not_run, not_run, not_run, not_run))) :-
    !,
    checked_validation_preflight(
        TokenPreflight, CandidateCells, CandidateDepth,
        CheckedPreflight),
    checker_sentence_audit(Sentence, SentenceAudit).
continue_authority_projection(
        clear, AuthorityAudit,
        TokenPreflight, CandidateCells, CandidateDepth,
        Sentence, CandidateData, Validation) :-
    independently_rebuild_candidate(
        Sentence, ExpectedSpecification, ExpectedProgram,
        ExpectedProof, ExpectedExpression),
    CandidateData =
        candidate_data(Specification, Program, Proof),
    specification_comparison(
        ExpectedSpecification, Specification, SpecificationStatus),
    continue_specification_comparison(
        SpecificationStatus,
        AuthorityAudit, TokenPreflight, CandidateCells, CandidateDepth,
        Sentence, Specification, Program, Proof,
        ExpectedProgram, ExpectedProof, ExpectedExpression,
        Validation).

% Checker constructors are intentionally separate from proposal constructors.

independently_rebuild_candidate(
        sentence(S, G, Values, T, left, combine, D, P),
        Specification, Program, Proof, Expression) :-
    checker_specification(S, G, Values, T, D, P, Specification),
    checker_program(G, Values, T, D, P, Program, Expression),
    checker_proof(S, G, Values, T, D, P, Expression, Proof).

checker_specification(S, G, Values, T, D, P,
        reduction_specification_v0(
            specification_id(S), program_id(G), type_id(T),
            values(ValueTerms), operation_id(combine), order(left),
            definition_space_id(D), premise_id(P))) :-
    checker_value_terms(Values, ValueTerms).

checker_program(G, Values, T, D, P,
        reduction_program_v0(
            program_id(G),
            signature(input(sequence(type_id(T))), output(type_id(T))),
            expression(Expression),
            definition_space_id(D), premise_id(P)),
        Expression) :-
    checker_expression(Values, T, Expression).

checker_expression([Value|Values], T, Expression) :-
    First = value(atom_value(Value), type_id(T)),
    checker_expression_tail(Values, T, First, Expression).

checker_expression_tail([], _T, Expression, Expression).
checker_expression_tail([Value|Values], T, Accumulator, Expression) :-
    Extended =
        apply(
            operation_id(combine),
            Accumulator,
            value(atom_value(Value), type_id(T)),
            type_id(T)),
    checker_expression_tail(Values, T, Extended, Expression).

checker_proof(S, G, Values, T, D, P, Expression,
        fixed_left_reduction_proof_v0(
            theory(source_relative_fixed_left_v0),
            scope_references([
                specification_id(S), program_id(G), operation_id(combine),
                definition_space_id(D), premise_id(P)
            ]),
            steps(Steps),
            root(step_id(Count)),
            conclusion(
                fixed_left_reduction(
                    Expression, operation_applications(Applications))))) :-
    length(Values, Count),
    Applications is Count - 1,
    checker_steps(Values, T, Steps).

checker_steps([Value|Values], T, Steps) :-
    FirstExpression = value(atom_value(Value), type_id(T)),
    FirstStep =
        proof_step(
            step_id(1), fixed_left_base, dependencies([]),
            source(index(1), atom_value(Value)),
            conclusion(prefix(FirstExpression), operation_applications(0))),
    checker_extension_steps(
        Values, T, 2, FirstExpression, [FirstStep], Steps).

checker_extension_steps([], _T, _Index, _Expression, Steps, Steps).
checker_extension_steps(
        [Value|Values], T, Index, PreviousExpression, Steps0, Steps) :-
    PreviousIndex is Index - 1,
    Applications is Index - 1,
    Expression =
        apply(
            operation_id(combine), PreviousExpression,
            value(atom_value(Value), type_id(T)), type_id(T)),
    Step =
        proof_step(
            step_id(Index), fixed_left_extend,
            dependencies([step_id(PreviousIndex)]),
            source(index(Index), atom_value(Value)),
            conclusion(prefix(Expression),
                       operation_applications(Applications))),
    append(Steps0, [Step], Steps1),
    NextIndex is Index + 1,
    checker_extension_steps(
        Values, T, NextIndex, Expression, Steps1, Steps).

specification_comparison(Expected, Actual, Status) :-
    Expected =
        reduction_specification_v0(
            ExpectedS, ExpectedG, ExpectedT, ExpectedValues,
            ExpectedOperation, ExpectedOrder, ExpectedD, ExpectedP),
    Actual =
        reduction_specification_v0(
            ActualS, ActualG, ActualT, ActualValues,
            ActualOperation, ActualOrder, ActualD, ActualP),
    first_field_difference(
        [ specification_id-ExpectedS-ActualS,
          program_id-ExpectedG-ActualG,
          type_id-ExpectedT-ActualT,
          values-ExpectedValues-ActualValues,
          operation_id-ExpectedOperation-ActualOperation,
          order-ExpectedOrder-ActualOrder,
          definition_space_id-ExpectedD-ActualD,
          premise_id-ExpectedP-ActualP
        ],
        Status).

first_field_difference([Field-Expected-Actual|_Pairs], mismatch(Field)) :-
    Expected \== Actual,
    !.
first_field_difference([_Pair|Pairs], Status) :-
    first_field_difference(Pairs, Status).
first_field_difference([], clear).

continue_specification_comparison(
        mismatch(Field), AuthorityAudit,
        TokenPreflight, CandidateCells, CandidateDepth,
        Sentence, _Specification, _Program, _Proof,
        _ExpectedProgram, _ExpectedProof, _ExpectedExpression,
        reduction_validation(
            rejected(specification_mismatch(Field)),
            reduction_audit(
                CheckedPreflight, complete(SentenceAudit),
                authority_assessment(accepted, AuthorityAudit),
                rejected(Field), not_run, not_run, not_run, not_run))) :-
    !,
    checked_validation_preflight(
        TokenPreflight, CandidateCells, CandidateDepth,
        CheckedPreflight),
    checker_sentence_audit(Sentence, SentenceAudit).
continue_specification_comparison(
        clear, AuthorityAudit,
        TokenPreflight, CandidateCells, CandidateDepth,
        Sentence, Specification, Program, Proof,
        ExpectedProgram, ExpectedProof, ExpectedExpression,
        Validation) :-
    program_comparison(ExpectedProgram, Program, ProgramStatus),
    continue_program_comparison(
        ProgramStatus, AuthorityAudit,
        TokenPreflight, CandidateCells, CandidateDepth,
        Sentence, Specification, Program, Proof,
        ExpectedProof, ExpectedExpression, Validation).

program_comparison(Expected, Actual, Status) :-
    Expected =
        reduction_program_v0(
            ExpectedId, ExpectedSignature, ExpectedExpression,
            ExpectedDefinition, ExpectedPremise),
    Actual =
        reduction_program_v0(
            ActualId, ActualSignature, ActualExpression,
            ActualDefinition, ActualPremise),
    first_field_difference(
        [ program_id-ExpectedId-ActualId,
          signature-ExpectedSignature-ActualSignature,
          expression-ExpectedExpression-ActualExpression,
          definition_space_id-ExpectedDefinition-ActualDefinition,
          premise_id-ExpectedPremise-ActualPremise
        ],
        Status).

continue_program_comparison(
        mismatch(Field), AuthorityAudit,
        TokenPreflight, CandidateCells, CandidateDepth,
        Sentence, Specification, _Program, _Proof,
        _ExpectedProof, _ExpectedExpression,
        reduction_validation(
            rejected(program_mismatch(Field)),
            reduction_audit(
                CheckedPreflight, complete(SentenceAudit),
                authority_assessment(accepted, AuthorityAudit),
                checked(Specification), rejected(Field),
                not_run, not_run, not_run))) :-
    !,
    checked_validation_preflight(
        TokenPreflight, CandidateCells, CandidateDepth,
        CheckedPreflight),
    checker_sentence_audit(Sentence, SentenceAudit).
continue_program_comparison(
        clear, AuthorityAudit,
        TokenPreflight, CandidateCells, CandidateDepth,
        Sentence, Specification, Program, Proof,
        ExpectedProof, ExpectedExpression, Validation) :-
    proof_observation(Proof, ExpectedProof, ProofStatus),
    continue_proof_observation(
        ProofStatus, AuthorityAudit,
        TokenPreflight, CandidateCells, CandidateDepth,
        Sentence, Specification, Program, Proof,
        ExpectedExpression, Validation).

proof_observation(Proof, _ExpectedProof,
        unknown(unchecked_evidence(Kind, StepId))) :-
    first_unchecked_step(Proof, Kind, StepId),
    !.
proof_observation(Proof, ExpectedProof, Status) :-
    proof_comparison(ExpectedProof, Proof, Comparison),
    (   Comparison = mismatch(Field)
    ->  Status = rejected(Field)
    ;   Status = clear
    ).

first_unchecked_step(
        fixed_left_reduction_proof_v0(
            _Theory, _Scope, steps(Steps), _Root, _ProofConclusion),
        Kind, StepId) :-
    member(
        proof_step(StepId, Rule, _Dependencies, _Source, _StepConclusion),
        Steps),
    unchecked_rule(Rule, Kind),
    !.

unchecked_rule(hole, hole).
unchecked_rule(trusted_step, trusted_step).

proof_comparison(Expected, Actual, Status) :-
    Expected =
        fixed_left_reduction_proof_v0(
            ExpectedTheory,
            scope_references(ExpectedReferences),
            steps(ExpectedSteps),
            ExpectedRoot,
            ExpectedConclusion),
    Actual =
        fixed_left_reduction_proof_v0(
            ActualTheory,
            scope_references(ActualReferences),
            steps(ActualSteps),
            ActualRoot,
            ActualConclusion),
    (   ExpectedTheory \== ActualTheory
    ->  Status = mismatch(theory)
    ;   ExpectedReferences \== ActualReferences
    ->  Status = mismatch(scope_references)
    ;   proof_steps_comparison(ExpectedSteps, ActualSteps, StepStatus),
        StepStatus \== clear
    ->  Status = StepStatus
    ;   ExpectedRoot \== ActualRoot
    ->  Status = mismatch(root)
    ;   ExpectedConclusion \== ActualConclusion
    ->  Status = mismatch(conclusion)
    ;   Status = clear
    ).

proof_steps_comparison([], [], clear) :-
    !.
proof_steps_comparison([], [_|_], mismatch(steps)) :-
    !.
proof_steps_comparison([_|_], [], mismatch(steps)) :-
    !.
proof_steps_comparison([Expected|ExpectedSteps], [Actual|ActualSteps], Status) :-
    proof_step_comparison(Expected, Actual, HeadStatus),
    (   HeadStatus == clear
    ->  proof_steps_comparison(ExpectedSteps, ActualSteps, Status)
    ;   Status = HeadStatus
    ).

proof_step_comparison(
        proof_step(ExpectedId, ExpectedRule,
                   dependencies(ExpectedDependencies),
                   source(ExpectedIndex, ExpectedValue),
                   conclusion(ExpectedPrefix, ExpectedApplications)),
        proof_step(ActualId, ActualRule,
                   dependencies(ActualDependencies),
                   source(ActualIndex, ActualValue),
                   conclusion(ActualPrefix, ActualApplications)),
        Status) :-
    (   ExpectedId \== ActualId
    ->  Status = mismatch(steps)
    ;   ExpectedRule \== ActualRule
    ->  Status = mismatch(steps)
    ;   ExpectedDependencies \== ActualDependencies
    ->  Status = mismatch(dependencies)
    ;   ExpectedIndex \== ActualIndex
    ->  Status = mismatch(source_index)
    ;   ExpectedValue \== ActualValue
    ->  Status = mismatch(source_value)
    ;   (   ExpectedPrefix \== ActualPrefix
        ;   ExpectedApplications \== ActualApplications
        )
    ->  Status = mismatch(step_conclusion)
    ;   Status = clear
    ).

continue_proof_observation(
        unknown(Missing), AuthorityAudit,
        TokenPreflight, CandidateCells, CandidateDepth,
        Sentence, Specification, Program, _Proof,
        _ExpectedExpression,
        reduction_validation(
            unknown(Missing),
            reduction_audit(
                CheckedPreflight, complete(SentenceAudit),
                authority_assessment(accepted, AuthorityAudit),
                checked(Specification), checked(Program),
                unknown(Missing), not_run, not_run))) :-
    !,
    checked_validation_preflight(
        TokenPreflight, CandidateCells, CandidateDepth,
        CheckedPreflight),
    checker_sentence_audit(Sentence, SentenceAudit).
continue_proof_observation(
        rejected(Field), AuthorityAudit,
        TokenPreflight, CandidateCells, CandidateDepth,
        Sentence, Specification, Program, _Proof,
        _ExpectedExpression,
        reduction_validation(
            rejected(proof_mismatch(Field)),
            reduction_audit(
                CheckedPreflight, complete(SentenceAudit),
                authority_assessment(accepted, AuthorityAudit),
                checked(Specification), checked(Program),
                rejected(Field), not_run, not_run))) :-
    !,
    checked_validation_preflight(
        TokenPreflight, CandidateCells, CandidateDepth,
        CheckedPreflight),
    checker_sentence_audit(Sentence, SentenceAudit).
continue_proof_observation(
        clear, AuthorityAudit,
        TokenPreflight, CandidateCells, CandidateDepth,
        Sentence, Specification, Program, Proof,
        ExpectedExpression, Validation) :-
    checker_render_expression(
        ExpectedExpression, Rendered, RenderScalars),
    length(Rendered, RenderTokenCount),
    select_render_resource(
        RenderTokenCount, RenderScalars, RenderStatus),
    finish_render_status(
        RenderStatus, Rendered, RenderScalars,
        AuthorityAudit,
        TokenPreflight, CandidateCells, CandidateDepth,
        Sentence, Specification, Program, Proof, Validation).

checker_render_expression(
        value(atom_value(Value), _Type), [Value], ScalarCount) :-
    atom_length(Value, ScalarCount).
checker_render_expression(
        apply(operation_id(combine), Left, Right, _Type),
        Rendered, ScalarCount) :-
    checker_render_expression(Left, LeftRendered, LeftScalars),
    checker_render_expression(Right, RightRendered, RightScalars),
    append([combine, '('|LeftRendered],
           [','|RightRendered], First),
    append(First, [')'], Rendered),
    ScalarCount is LeftScalars + RightScalars + 10.

select_render_resource(TokenCount, _ScalarCount,
        render_tokens(max(11), observed_at_least(12))) :-
    TokenCount > 11,
    !.
select_render_resource(_TokenCount, ScalarCount,
        render_scalars(max(212), observed_at_least(213))) :-
    ScalarCount > 212,
    !.
select_render_resource(_TokenCount, _ScalarCount, none).

finish_render_status(
        Resource, _Rendered, _RenderScalars,
        AuthorityAudit,
        TokenPreflight, CandidateCells, CandidateDepth,
        Sentence, Specification, Program, Proof,
        reduction_validation(
            resource_exhausted(Resource),
            reduction_audit(
                CheckedPreflight, complete(SentenceAudit),
                authority_assessment(accepted, AuthorityAudit),
                checked(Specification), checked(Program), checked(Proof),
                not_run, limit(Resource)))) :-
    Resource \== none,
    !,
    checked_validation_preflight(
        TokenPreflight, CandidateCells, CandidateDepth,
        CheckedPreflight),
    checker_sentence_audit(Sentence, SentenceAudit).
finish_render_status(
        none, Rendered, RenderScalars,
        AuthorityAudit,
        TokenPreflight, CandidateCells, CandidateDepth,
        Sentence, Specification, Program, Proof,
        reduction_validation(
            accepted(CheckedBundle),
            reduction_audit(
                CheckedPreflight, complete(SentenceAudit),
                authority_assessment(accepted, AuthorityAudit),
                checked(Specification), checked(Program), checked(Proof),
                checked(Cost), checked(rendered_tokens(Rendered))))) :-
    TokenPreflight = checked(_Count, TokenCells, _TokenDepth),
    checker_cost(
        Sentence, TokenCells, CandidateCells,
        Rendered, RenderScalars, Cost),
    CheckedBundle =
        checked_reduction_v0(
            Specification, Program, Proof,
            authority_audit(AuthorityAudit),
            Cost,
            rendered_tokens(Rendered)),
    checked_validation_preflight(
        TokenPreflight, CandidateCells, CandidateDepth,
        CheckedPreflight),
    checker_sentence_audit(Sentence, SentenceAudit).

checker_cost(
        sentence(_S, _G, Values, _T, left, combine, _D, _P),
        TokenCells, CandidateCells, Rendered, RenderScalars,
        reduction_cost(
            source_values(Count),
            operation_applications(Applications),
            token_inspections(TokenCells),
            candidate_inspections(CandidateCells),
            ast_nodes(AstNodes),
            proof_steps(Count),
            render_tokens(RenderTokenCount),
            render_scalars(RenderScalars))) :-
    length(Values, Count),
    Applications is Count - 1,
    AstNodes is Count * 2 - 1,
    length(Rendered, RenderTokenCount).
