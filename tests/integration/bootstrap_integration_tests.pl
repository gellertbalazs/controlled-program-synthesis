:- begin_tests(bootstrap_process).

:- use_module(library(process)).
:- use_module(library(time)).

repository_root(Root) :-
    source_file(repository_root(_), File),
    file_directory_name(File, IntegrationDirectory),
    file_directory_name(IntegrationDirectory, TestsDirectory),
    file_directory_name(TestsDirectory, Root).

cleanup_child(Pid, Out, Error) :-
    catch(close(Out), _, true),
    catch(close(Error), _, true),
    (   catch(process_wait(Pid, Status, [timeout(0)]), _, Status = gone),
        Status == timeout
    ->  stop_timed_out_child(Pid)
    ;   true
    ).

stop_timed_out_child(Pid) :-
    catch(process_kill(Pid, term), _, true),
    bounded_process_wait(Pid, 1, TermStatus),
    (   TermStatus == timeout
    ->  catch(process_kill(Pid, kill), _, true),
        bounded_process_wait(Pid, 1, _)
    ;   true
    ).

bounded_process_wait(Pid, Limit, Status) :-
    catch(
        call_with_time_limit(Limit, process_wait(Pid, Observed)),
        time_limit_exceeded,
        Observed = timeout
    ),
    Status = Observed.

run_goal(Goal, Output, Status) :-
    run_goal(Goal, 5, Output, Status).

run_goal(Goal, Limit, Output, Status) :-
    repository_root(Root),
    setup_call_cleanup(
        process_create(
            path(swipl),
            ['-f', none, '-q', '-g', Goal, '-t', 'halt(1)'],
            [ cwd(Root),
              stdout(pipe(Out)),
              stderr(pipe(Error)),
              process(Pid)
            ]
        ),
        ( wait_bounded(Pid, Limit, Status),
          read_string(Out, _, Output),
          read_string(Error, _, ErrorOutput),
          assertion(ErrorOutput == "")
        ),
        cleanup_child(Pid, Out, Error)
    ).

wait_bounded(Pid, Limit, Status) :-
    bounded_process_wait(Pid, Limit, Observed),
    (   Observed == timeout
    ->  stop_timed_out_child(Pid),
        Status = timeout
    ;   Status = Observed
    ).

test(fresh_process_reports_phase0) :-
    run_goal(
        "use_module('src/cps_bootstrap.pl'),cps_bootstrap:bootstrap_stage(Stage),format('~w~n',[Stage]),halt",
        "phase0\n",
        exit(0)
    ).

test(fresh_process_propagates_rejection) :-
    run_goal(
        "use_module('src/cps_bootstrap.pl'),cps_bootstrap:bootstrap_stage(phase1)",
        "",
        exit(1)
    ).

test(silent_process_is_terminated_at_timeout) :-
    run_goal(
        "sleep(5)",
        0.2,
        "",
        timeout
    ).

:- end_tests(bootstrap_process).
