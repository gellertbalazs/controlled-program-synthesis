:- begin_tests(cps_bootstrap_process).

:- use_module(library(process)).
:- use_module(library(readutil)).
:- use_module(library(time)).

project_root(Root) :-
    source_file(project_root(_), ThisFile),
    file_directory_name(ThisFile, IntegrationDirectory),
    file_directory_name(IntegrationDirectory, TestsDirectory),
    file_directory_name(TestsDirectory, Root).

cleanup_child(Pid, Out, Err) :-
    catch(close(Out), _, true),
    catch(close(Err), _, true),
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
        call_with_time_limit(Limit, process_wait(Pid, Status0)),
        time_limit_exceeded,
        Status0 = timeout),
    Status = Status0.

wait_for_child(Pid, Limit, Status) :-
    bounded_process_wait(Pid, Limit, InitialStatus),
    (   InitialStatus == timeout
    ->  stop_timed_out_child(Pid),
        Status = timeout
    ;   Status = InitialStatus
    ).

read_child_output(Out, Err, StandardOutput, StandardError) :-
    call_with_time_limit(
        2,
        ( read_string(Out, _, StandardOutput),
          read_string(Err, _, StandardError)
        )).

run_child(Arguments, Limit, Status, StandardOutput, StandardError) :-
    project_root(Root),
    setup_call_cleanup(
        process_create(
            path(swipl),
            Arguments,
            [ cwd(Root),
              stdout(pipe(Out)),
              stderr(pipe(Err)),
              process(Pid)
            ]),
        ( wait_for_child(Pid, Limit, Status),
          (   Status == timeout
          ->  StandardOutput = "",
              StandardError = ""
          ;   read_child_output(
                  Out, Err, StandardOutput, StandardError)
          )
        ),
        cleanup_child(Pid, Out, Err)).

test(clean_process_reports_canonical_stage) :-
    Goal = 'cps_bootstrap:bootstrap_stage(Stage),write_canonical(Stage),nl',
    run_child(
        [ '-f', none,
          '-q',
          '-s', 'src/cps_bootstrap.pl',
          '-g', Goal,
          '-t', halt
        ],
        10,
        Status,
        StandardOutput,
        StandardError),
    assertion(Status == exit(0)),
    assertion(StandardOutput ==
              "cps_stage{phase:0,status:infrastructure_only}\n"),
    assertion(StandardError == "").

test(clean_process_propagates_failed_stage_query) :-
    Goal = '(cps_bootstrap:bootstrap_stage(cps_stage{phase:1,status:infrastructure_only})->halt(0);halt(7))',
    run_child(
        [ '-f', none,
          '-q',
          '-s', 'src/cps_bootstrap.pl',
          '-g', Goal
        ],
        10,
        Status,
        StandardOutput,
        StandardError),
    assertion(Status == exit(7)),
    assertion(StandardOutput == ""),
    assertion(StandardError == "").

test(silent_child_is_terminated_at_timeout) :-
    Goal = 'sleep(5)',
    run_child(
        [ '-f', none,
          '-q',
          '-g', Goal,
          '-t', halt
        ],
        0.2,
        Status,
        StandardOutput,
        StandardError),
    assertion(Status == timeout),
    assertion(StandardOutput == ""),
    assertion(StandardError == "").

:- end_tests(cps_bootstrap_process).
