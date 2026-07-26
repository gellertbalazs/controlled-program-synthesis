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

test(fresh_process_unicode_success) :-
    run_goal(
        "use_module('src/cps_reference_normalization.pl'),Input=evidence(at(source('dcg_compiler.pl','references/dcg_compiler.pl',6743,'ce0851db9749c748b4bf194af539da5cf53174c1a2873b07b2a60aa883b11c2f'),lines(49,49),raw_utf8([73,116,8217,115])),claim(source_fact,encoding,facets(not_applicable,not_applicable,not_applicable,not_applicable,not_applicable,not_applicable,not_applicable,not_applicable,established(exact_code_points),established(preserve_unicode)))),normalize_reference_evidence(Input,Result),write_canonical(Result),nl,halt",
        "normalization(accepted,normalized(evidence(at(source('dcg_compiler.pl','references/dcg_compiler.pl',6743,ce0851db9749c748b4bf194af539da5cf53174c1a2873b07b2a60aa883b11c2f),lines(49,49),raw_utf8([73,116,8217,115])),claim(source_fact,encoding,facets(not_applicable,not_applicable,not_applicable,not_applicable,not_applicable,not_applicable,not_applicable,not_applicable,established(exact_code_points),established(preserve_unicode))))))\n",
        exit(0)
    ).

test(fresh_process_forbidden_meta_status) :-
    run_goal(
        "use_module('src/cps_reference_normalization.pl'),Input=evidence(at(source('dcg_compiler.pl','references/dcg_compiler.pl',6743,'ce0851db9749c748b4bf194af539da5cf53174c1a2873b07b2a60aa883b11c2f'),lines(207,207),raw_utf8([99,97,108,108])),claim(source_fact,host_goal_execution,facets(not_applicable,not_applicable,not_applicable,not_applicable,not_applicable,not_applicable,not_applicable,not_applicable,established(exact_legacy_line),established(reject_host_execution)))),normalize_reference_evidence(Input,Result),write_canonical(Result),nl,halt",
        "normalization(rejected(host_goal_execution),normalized(evidence(at(source('dcg_compiler.pl','references/dcg_compiler.pl',6743,ce0851db9749c748b4bf194af539da5cf53174c1a2873b07b2a60aa883b11c2f),lines(207,207),raw_utf8([99,97,108,108])),claim(source_fact,host_goal_execution,facets(not_applicable,not_applicable,not_applicable,not_applicable,not_applicable,not_applicable,not_applicable,not_applicable,established(exact_legacy_line),established(reject_host_execution))))))\n",
        exit(0)
    ).

test(fresh_process_working_directory_independence) :-
    RootGoal = "use_module('src/cps_reference_normalization.pl'),Input=evidence(at(source('dcg_compiler.pl','references/dcg_compiler.pl',6743,'ce0851db9749c748b4bf194af539da5cf53174c1a2873b07b2a60aa883b11c2f'),lines(49,49),raw_utf8([73,116,8217,115])),claim(source_fact,encoding,facets(not_applicable,not_applicable,not_applicable,not_applicable,not_applicable,not_applicable,not_applicable,not_applicable,established(exact_code_points),established(preserve_unicode)))),normalize_reference_evidence(Input,Result),write_canonical(Result),nl,halt",
    OtherGoal = "use_module('src/cps_reference_normalization.pl'),working_directory(_,'/tmp'),Input=evidence(at(source('dcg_compiler.pl','references/dcg_compiler.pl',6743,'ce0851db9749c748b4bf194af539da5cf53174c1a2873b07b2a60aa883b11c2f'),lines(49,49),raw_utf8([73,116,8217,115])),claim(source_fact,encoding,facets(not_applicable,not_applicable,not_applicable,not_applicable,not_applicable,not_applicable,not_applicable,not_applicable,established(exact_code_points),established(preserve_unicode)))),normalize_reference_evidence(Input,Result),write_canonical(Result),nl,halt",
    run_goal(RootGoal, RootOutput, exit(0)),
    run_goal(OtherGoal, OtherOutput, exit(0)),
    assertion(OtherOutput == RootOutput).

:- end_tests(bootstrap_process).
