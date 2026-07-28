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

test(fresh_process_authority_accepted) :-
    run_goal(
        "use_module('src/cps_reference_normalization.pl'),use_module('src/cps_law_claim_authority.pl'),Snapshot=authority_snapshot(policy(policy_id(source_policy),source_relative_law_v1,provenance_id(eop_concepts_p9)),claim(claim_id(partial_associativity),semantics(signature(signature_id(binary_op)),definedness(definition_space_id(adjacent_defined)),law(law_id(partial_assoc),equality(equality_id(represented_equal))),termination(termination_id(structural_descent)),cost(cost_id(operation_count)),effects(effects_id(read_write_alias)),provenance(provenance_id(eop_concepts_p9))),uses([premise_id(adjacent_applications)]),requires([obligation_id(both_parenthesizations_defined)]),conflicts([contradiction_id(no_counterexample)]),current(provenance_id(eop_concepts_p9))),semantic_records(signature(signature_id(binary_op),descriptor(binary_operation),accepted(provenance_id(eop_concepts_p9)),provenance_id(eop_concepts_p9)),definition_space(definition_space_id(adjacent_defined),signature_id(binary_op),descriptor(adjacent_applications),accepted(provenance_id(eop_concepts_p9)),provenance_id(eop_concepts_p9)),law(law_id(partial_assoc),signature_id(binary_op),definition_space_id(adjacent_defined),equality_id(represented_equal),descriptor(partial_associativity),accepted(provenance_id(eop_concepts_p9)),provenance_id(eop_concepts_p9)),equality_relation(equality_id(represented_equal),signature_id(binary_op),definition_space_id(adjacent_defined),relation(represented_value_equality),accepted(provenance_id(eop_concepts_p9)),provenance_id(eop_concepts_p9)),termination(termination_id(structural_descent),law_id(partial_assoc),measure(smaller_structure),accepted(provenance_id(eop_concepts_p9)),provenance_id(eop_concepts_p9)),cost(cost_id(operation_count),law_id(partial_assoc),operation_count(primitive_applications),accepted(provenance_id(eop_concepts_p9)),provenance_id(eop_concepts_p9)),effects(effects_id(read_write_alias),law_id(partial_assoc),conditions(explicit_read_write_alias_overlap),accepted(provenance_id(eop_concepts_p9)),provenance_id(eop_concepts_p9))),[premise(premise_id(adjacent_applications),active(provenance_id(eop_concepts_p9)),trusted(policy_id(source_policy),provenance_id(eop_concepts_p9)),provenance_id(eop_concepts_p9))],[obligation(obligation_id(both_parenthesizations_defined),law_id(partial_assoc),applicable(provenance_id(eop_concepts_p9)),accepted(provenance_id(eop_concepts_p9)),provenance_id(eop_concepts_p9))],[contradiction(contradiction_id(no_counterexample),claim_id(partial_associativity),cleared(provenance_id(eop_concepts_p9)),provenance_id(eop_concepts_p9))],[provenance(provenance_id(eop_concepts_p9),evidence(at(source('eop_concepts.pdf','references/eop_concepts.pdf',243726,'401346f1e3d75b790cf0229dab174773a4eb854880e6e7c05f6cc924a4afac19'),pages(9,9,9,9),raw_utf8([112,97,114,116,105,97,108])),claim(source_fact,eop_semantics,facets(established(binary_operation),established(partial_associativity),established(adjacent_definedness),established(partial_associativity_law),established(well_founded_measure),established(operation_count),established(effect_conditions),established(alias_conditions),established(physical_and_printed_page),established(negative_cases)))))]),Expected=authority_assessment(accepted,audit(claim_id(partial_associativity),policy_id(source_policy),used([claim_id(partial_associativity),policy_id(source_policy),signature_id(binary_op),definition_space_id(adjacent_defined),law_id(partial_assoc),equality_id(represented_equal),termination_id(structural_descent),cost_id(operation_count),effects_id(read_write_alias),premise_id(adjacent_applications),obligation_id(both_parenthesizations_defined),contradiction_id(no_counterexample)]),provenance([provenance(provenance_id(eop_concepts_p9),evidence(at(source('eop_concepts.pdf','references/eop_concepts.pdf',243726,'401346f1e3d75b790cf0229dab174773a4eb854880e6e7c05f6cc924a4afac19'),pages(9,9,9,9),raw_utf8([112,97,114,116,105,97,108])),claim(source_fact,eop_semantics,facets(established(binary_operation),established(partial_associativity),established(adjacent_definedness),established(partial_associativity_law),established(well_founded_measure),established(operation_count),established(effect_conditions),established(alias_conditions),established(physical_and_printed_page),established(negative_cases)))))]))),findall(Assessment,cps_law_claim_authority:assess_law_claim_authority(Snapshot,Assessment),Assessments),Assessments=[Only],ground(Only),Only==Expected,write_canonical(Only),nl,halt",
        "authority_assessment(accepted,audit(claim_id(partial_associativity),policy_id(source_policy),used([claim_id(partial_associativity),policy_id(source_policy),signature_id(binary_op),definition_space_id(adjacent_defined),law_id(partial_assoc),equality_id(represented_equal),termination_id(structural_descent),cost_id(operation_count),effects_id(read_write_alias),premise_id(adjacent_applications),obligation_id(both_parenthesizations_defined),contradiction_id(no_counterexample)]),provenance([provenance(provenance_id(eop_concepts_p9),evidence(at(source('eop_concepts.pdf','references/eop_concepts.pdf',243726,'401346f1e3d75b790cf0229dab174773a4eb854880e6e7c05f6cc924a4afac19'),pages(9,9,9,9),raw_utf8([112,97,114,116,105,97,108])),claim(source_fact,eop_semantics,facets(established(binary_operation),established(partial_associativity),established(adjacent_definedness),established(partial_associativity_law),established(well_founded_measure),established(operation_count),established(effect_conditions),established(alias_conditions),established(physical_and_printed_page),established(negative_cases)))))])))\n",
        exit(0)
    ).

test(fresh_process_authority_rejected) :-
    run_goal(
        "use_module('src/cps_reference_normalization.pl'),use_module('src/cps_law_claim_authority.pl'),Snapshot=authority_snapshot(policy(policy_id(source_policy),source_relative_law_v1,provenance_id(eop_concepts_p9)),claim(claim_id(partial_associativity),semantics(signature(signature_id(binary_op)),definedness(definition_space_id(adjacent_defined)),law(law_id(partial_assoc),equality(equality_id(represented_equal))),termination(termination_id(structural_descent)),cost(cost_id(operation_count)),effects(effects_id(read_write_alias)),provenance(provenance_id(eop_concepts_p9))),uses([premise_id(adjacent_applications)]),requires([obligation_id(both_parenthesizations_defined)]),conflicts([contradiction_id(no_counterexample)]),current(provenance_id(eop_concepts_p9))),semantic_records(signature(signature_id(binary_op),descriptor(binary_operation),accepted(provenance_id(eop_concepts_p9)),provenance_id(eop_concepts_p9)),definition_space(definition_space_id(adjacent_defined),signature_id(binary_op),descriptor(adjacent_applications),accepted(provenance_id(eop_concepts_p9)),provenance_id(eop_concepts_p9)),law(law_id(partial_assoc),signature_id(binary_op),definition_space_id(adjacent_defined),equality_id(represented_equal),descriptor(partial_associativity),accepted(provenance_id(eop_concepts_p9)),provenance_id(eop_concepts_p9)),equality_relation(equality_id(represented_equal),signature_id(binary_op),definition_space_id(adjacent_defined),relation(represented_value_equality),accepted(provenance_id(eop_concepts_p9)),provenance_id(eop_concepts_p9)),termination(termination_id(structural_descent),law_id(partial_assoc),measure(smaller_structure),accepted(provenance_id(eop_concepts_p9)),provenance_id(eop_concepts_p9)),cost(cost_id(operation_count),law_id(partial_assoc),operation_count(primitive_applications),accepted(provenance_id(eop_concepts_p9)),provenance_id(eop_concepts_p9)),effects(effects_id(read_write_alias),law_id(partial_assoc),conditions(explicit_read_write_alias_overlap),accepted(provenance_id(eop_concepts_p9)),provenance_id(eop_concepts_p9))),[premise(premise_id(adjacent_applications),active(provenance_id(eop_concepts_p9)),trusted(policy_id(source_policy),provenance_id(eop_concepts_p9)),provenance_id(eop_concepts_p9))],[obligation(obligation_id(both_parenthesizations_defined),law_id(partial_assoc),applicable(provenance_id(eop_concepts_p9)),accepted(provenance_id(eop_concepts_p9)),provenance_id(eop_concepts_p9))],[contradiction(contradiction_id(no_counterexample),claim_id(partial_associativity),explicit(provenance_id(eop_concepts_p9)),provenance_id(eop_concepts_p9))],[provenance(provenance_id(eop_concepts_p9),evidence(at(source('eop_concepts.pdf','references/eop_concepts.pdf',243726,'401346f1e3d75b790cf0229dab174773a4eb854880e6e7c05f6cc924a4afac19'),pages(9,9,9,9),raw_utf8([112,97,114,116,105,97,108])),claim(source_fact,eop_semantics,facets(established(binary_operation),established(partial_associativity),established(adjacent_definedness),established(partial_associativity_law),established(well_founded_measure),established(operation_count),established(effect_conditions),established(alias_conditions),established(physical_and_printed_page),established(negative_cases)))))]),Expected=authority_assessment(rejected(explicit_contradiction(contradiction_id(no_counterexample))),audit(claim_id(partial_associativity),policy_id(source_policy),used([claim_id(partial_associativity),policy_id(source_policy),signature_id(binary_op),definition_space_id(adjacent_defined),law_id(partial_assoc),equality_id(represented_equal),termination_id(structural_descent),cost_id(operation_count),effects_id(read_write_alias),premise_id(adjacent_applications),obligation_id(both_parenthesizations_defined),contradiction_id(no_counterexample)]),provenance([provenance(provenance_id(eop_concepts_p9),evidence(at(source('eop_concepts.pdf','references/eop_concepts.pdf',243726,'401346f1e3d75b790cf0229dab174773a4eb854880e6e7c05f6cc924a4afac19'),pages(9,9,9,9),raw_utf8([112,97,114,116,105,97,108])),claim(source_fact,eop_semantics,facets(established(binary_operation),established(partial_associativity),established(adjacent_definedness),established(partial_associativity_law),established(well_founded_measure),established(operation_count),established(effect_conditions),established(alias_conditions),established(physical_and_printed_page),established(negative_cases)))))]))),findall(Assessment,cps_law_claim_authority:assess_law_claim_authority(Snapshot,Assessment),Assessments),Assessments=[Only],ground(Only),Only==Expected,write_canonical(Only),nl,halt",
        "authority_assessment(rejected(explicit_contradiction(contradiction_id(no_counterexample))),audit(claim_id(partial_associativity),policy_id(source_policy),used([claim_id(partial_associativity),policy_id(source_policy),signature_id(binary_op),definition_space_id(adjacent_defined),law_id(partial_assoc),equality_id(represented_equal),termination_id(structural_descent),cost_id(operation_count),effects_id(read_write_alias),premise_id(adjacent_applications),obligation_id(both_parenthesizations_defined),contradiction_id(no_counterexample)]),provenance([provenance(provenance_id(eop_concepts_p9),evidence(at(source('eop_concepts.pdf','references/eop_concepts.pdf',243726,'401346f1e3d75b790cf0229dab174773a4eb854880e6e7c05f6cc924a4afac19'),pages(9,9,9,9),raw_utf8([112,97,114,116,105,97,108])),claim(source_fact,eop_semantics,facets(established(binary_operation),established(partial_associativity),established(adjacent_definedness),established(partial_associativity_law),established(well_founded_measure),established(operation_count),established(effect_conditions),established(alias_conditions),established(physical_and_printed_page),established(negative_cases)))))])))\n",
        exit(0)
    ).

test(fresh_process_authority_unknown) :-
    run_goal(
        "use_module('src/cps_reference_normalization.pl'),use_module('src/cps_law_claim_authority.pl'),Snapshot=authority_snapshot(policy(policy_id(source_policy),source_relative_law_v1,provenance_id(eop_concepts_p9)),claim(claim_id(partial_associativity),semantics(signature(signature_id(binary_op)),definedness(definition_space_id(adjacent_defined)),law(law_id(partial_assoc),equality(equality_id(represented_equal))),termination(termination_id(structural_descent)),cost(cost_id(operation_count)),effects(effects_id(read_write_alias)),provenance(provenance_id(eop_concepts_p9))),uses([premise_id(adjacent_applications)]),requires([obligation_id(both_parenthesizations_defined)]),conflicts([contradiction_id(no_counterexample)]),missing),semantic_records(signature(signature_id(binary_op),descriptor(binary_operation),missing,provenance_id(eop_concepts_p9)),definition_space(definition_space_id(adjacent_defined),signature_id(binary_op),descriptor(adjacent_applications),accepted(provenance_id(eop_concepts_p9)),provenance_id(eop_concepts_p9)),law(law_id(partial_assoc),signature_id(binary_op),definition_space_id(adjacent_defined),equality_id(represented_equal),descriptor(partial_associativity),accepted(provenance_id(eop_concepts_p9)),provenance_id(eop_concepts_p9)),equality_relation(equality_id(represented_equal),signature_id(binary_op),definition_space_id(adjacent_defined),relation(represented_value_equality),missing,provenance_id(eop_concepts_p9)),termination(termination_id(structural_descent),law_id(partial_assoc),measure(smaller_structure),accepted(provenance_id(eop_concepts_p9)),provenance_id(eop_concepts_p9)),cost(cost_id(operation_count),law_id(partial_assoc),operation_count(primitive_applications),accepted(provenance_id(eop_concepts_p9)),provenance_id(eop_concepts_p9)),effects(effects_id(read_write_alias),law_id(partial_assoc),conditions(explicit_read_write_alias_overlap),accepted(provenance_id(eop_concepts_p9)),provenance_id(eop_concepts_p9))),[premise(premise_id(adjacent_applications),missing,missing,provenance_id(eop_concepts_p9))],[obligation(obligation_id(both_parenthesizations_defined),law_id(partial_assoc),missing,missing,provenance_id(eop_concepts_p9))],[contradiction(contradiction_id(no_counterexample),claim_id(partial_associativity),unresolved,provenance_id(eop_concepts_p9))],[provenance(provenance_id(eop_concepts_p9),evidence(at(source('eop_concepts.pdf','references/eop_concepts.pdf',243726,'401346f1e3d75b790cf0229dab174773a4eb854880e6e7c05f6cc924a4afac19'),pages(9,9,9,9),raw_utf8([117,110,107,110,111,119,110])),claim(source_fact,eop_semantics,facets(established(binary_operation),established(partial_associativity),established(adjacent_definedness),unknown(law_requires_proof),established(well_founded_measure),established(operation_count),established(effect_conditions),established(alias_conditions),established(physical_and_printed_page),established(negative_cases)))))]),Expected=authority_assessment(unknown([missing(signature,signature_id(binary_op)),missing(equality,equality_id(represented_equal)),missing_t001(provenance_id(eop_concepts_p9),[unknown(laws,law_requires_proof)]),missing(lifecycle,claim_id(partial_associativity)),missing(premise_activation,premise_id(adjacent_applications)),missing(premise_trust(policy_id(source_policy)),premise_id(adjacent_applications)),missing(obligation_applicability,obligation_id(both_parenthesizations_defined)),missing(obligation_disposition,obligation_id(both_parenthesizations_defined)),missing(contradiction_resolution,contradiction_id(no_counterexample))]),audit(claim_id(partial_associativity),policy_id(source_policy),used([claim_id(partial_associativity),policy_id(source_policy),signature_id(binary_op),definition_space_id(adjacent_defined),law_id(partial_assoc),equality_id(represented_equal),termination_id(structural_descent),cost_id(operation_count),effects_id(read_write_alias),premise_id(adjacent_applications),obligation_id(both_parenthesizations_defined),contradiction_id(no_counterexample)]),provenance([provenance(provenance_id(eop_concepts_p9),evidence(at(source('eop_concepts.pdf','references/eop_concepts.pdf',243726,'401346f1e3d75b790cf0229dab174773a4eb854880e6e7c05f6cc924a4afac19'),pages(9,9,9,9),raw_utf8([117,110,107,110,111,119,110])),claim(source_fact,eop_semantics,facets(established(binary_operation),established(partial_associativity),established(adjacent_definedness),unknown(law_requires_proof),established(well_founded_measure),established(operation_count),established(effect_conditions),established(alias_conditions),established(physical_and_printed_page),established(negative_cases)))))]))),findall(Assessment,cps_law_claim_authority:assess_law_claim_authority(Snapshot,Assessment),Assessments),Assessments=[Only],ground(Only),Only==Expected,write_canonical(Only),nl,halt",
        "authority_assessment(unknown([missing(signature,signature_id(binary_op)),missing(equality,equality_id(represented_equal)),missing_t001(provenance_id(eop_concepts_p9),[unknown(laws,law_requires_proof)]),missing(lifecycle,claim_id(partial_associativity)),missing(premise_activation,premise_id(adjacent_applications)),missing(premise_trust(policy_id(source_policy)),premise_id(adjacent_applications)),missing(obligation_applicability,obligation_id(both_parenthesizations_defined)),missing(obligation_disposition,obligation_id(both_parenthesizations_defined)),missing(contradiction_resolution,contradiction_id(no_counterexample))]),audit(claim_id(partial_associativity),policy_id(source_policy),used([claim_id(partial_associativity),policy_id(source_policy),signature_id(binary_op),definition_space_id(adjacent_defined),law_id(partial_assoc),equality_id(represented_equal),termination_id(structural_descent),cost_id(operation_count),effects_id(read_write_alias),premise_id(adjacent_applications),obligation_id(both_parenthesizations_defined),contradiction_id(no_counterexample)]),provenance([provenance(provenance_id(eop_concepts_p9),evidence(at(source('eop_concepts.pdf','references/eop_concepts.pdf',243726,'401346f1e3d75b790cf0229dab174773a4eb854880e6e7c05f6cc924a4afac19'),pages(9,9,9,9),raw_utf8([117,110,107,110,111,119,110])),claim(source_fact,eop_semantics,facets(established(binary_operation),established(partial_associativity),established(adjacent_definedness),unknown(law_requires_proof),established(well_founded_measure),established(operation_count),established(effect_conditions),established(alias_conditions),established(physical_and_printed_page),established(negative_cases)))))])))\n",
        exit(0)
    ).

:- end_tests(bootstrap_process).
