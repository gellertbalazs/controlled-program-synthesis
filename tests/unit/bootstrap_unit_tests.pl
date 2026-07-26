:- begin_tests(cps_bootstrap).

:- use_module('../../src/cps_bootstrap').

test(stage_query_reports_phase0) :-
    bootstrap_stage(Stage),
    assertion(Stage == phase0).

test(future_stage_is_rejected, [fail]) :-
    bootstrap_stage(phase1).

test(stage_query_has_one_solution) :-
    findall(Stage, bootstrap_stage(Stage), Stages),
    assertion(Stages == [phase0]).

test(malformed_stage_is_rejected, [fail]) :-
    bootstrap_stage(stage(phase0)).

:- end_tests(cps_bootstrap).
