:- begin_tests(cps_bootstrap).

:- use_module('../../src/cps_bootstrap').

test(stage_is_exact) :-
    bootstrap_stage(cps_stage{phase:0, status:infrastructure_only}).

test(stage_is_ground) :-
    bootstrap_stage(Stage),
    ground(Stage).

test(stage_is_deterministic) :-
    findall(Stage, bootstrap_stage(Stage), Stages),
    assertion(Stages == [cps_stage{phase:0, status:infrastructure_only}]).

test(stage_rejects_other_phase, [fail]) :-
    bootstrap_stage(cps_stage{phase:1, status:infrastructure_only}).

test(stage_rejects_malformed_term, [fail]) :-
    bootstrap_stage(not_a_stage_dict).

:- end_tests(cps_bootstrap).
