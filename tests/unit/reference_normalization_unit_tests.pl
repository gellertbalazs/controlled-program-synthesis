:- begin_tests(cps_reference_normalization).

:- use_module('../../src/cps_reference_normalization').

dcg_unicode(
    evidence(
        at(source('dcg_compiler.pl',
                  'references/dcg_compiler.pl',
                  6743,
                  'ce0851db9749c748b4bf194af539da5cf53174c1a2873b07b2a60aa883b11c2f'),
           lines(49, 49),
           raw_utf8([73, 116, 8217, 115])),
        claim(source_fact, encoding,
              facets(not_applicable, not_applicable, not_applicable,
                     not_applicable, not_applicable, not_applicable,
                     not_applicable, not_applicable,
                     established(exact_code_points),
                     established(preserve_unicode))))).

eop_definedness(
    evidence(
        at(source('eop_concepts.pdf',
                  'references/eop_concepts.pdf',
                  243726,
                  '401346f1e3d75b790cf0229dab174773a4eb854880e6e7c05f6cc924a4afac19'),
           pages(9, 9, 9, 9),
           raw_utf8([100, 101, 102, 105, 110, 101, 100])),
        claim(source_fact, eop_semantics,
              facets(established(binary_operation),
                     established(partial_associativity),
                     unknown(adjacent_applications_must_be_defined),
                     established(partial_associativity_law),
                     not_applicable, not_applicable, not_applicable,
                     not_applicable, established(physical_and_printed_page),
                     established(test_undefined_cases))))).

all_sources(
    [ evidence(
          at(source('prolog_and_natural_language_analysis.pdf',
                    'references/prolog_and_natural_language_analysis.pdf',
                    1238678,
                    '935c443ea3858af52e76897c65ae84612b4213001b62c718cc19740537e0b776'),
             pages(11, 11, 1, 1), raw_utf8([110])),
          claim(source_fact, dependency,
                facets(not_applicable, not_applicable, not_applicable,
                       not_applicable, not_applicable, not_applicable,
                       not_applicable, not_applicable, not_applicable,
                       not_applicable))),
      evidence(
          at(source('dcg_compiler.pl',
                    'references/dcg_compiler.pl',
                    6743,
                    'ce0851db9749c748b4bf194af539da5cf53174c1a2873b07b2a60aa883b11c2f'),
             lines(1, 1), raw_utf8([100])),
          claim(source_fact, grammar,
                facets(not_applicable, not_applicable, not_applicable,
                       not_applicable, not_applicable, not_applicable,
                       not_applicable, not_applicable, not_applicable,
                       not_applicable))),
      evidence(
          at(source('talk.pl',
                    'references/talk.pl',
                    12610,
                    'ebe594a23f6274c0c29ec855c8730f774be9739ba22ab75f0943dbae174b9bd6'),
             lines(1, 1), raw_utf8([116])),
          claim(source_fact, query,
                facets(not_applicable, not_applicable, not_applicable,
                       not_applicable, not_applicable, not_applicable,
                       not_applicable, not_applicable, not_applicable,
                       not_applicable))),
      evidence(
          at(source('eop.pdf',
                    'references/eop.pdf',
                    1126874,
                    '3393c7b5c90ad86ee16b5c827282d7f78ae7c4250840842c13e52e51483aa33f'),
             pages(15, 15, 1, 1), raw_utf8([101])),
          claim(source_fact, eop_semantics,
                facets(established(operation_signature),
                       established(operation_concept),
                       established(definition_space),
                       established(operation_law),
                       established(termination_requirement),
                       established(operation_count),
                       established(effect_condition),
                       established(alias_condition),
                       established(physical_and_printed_page),
                       established(proof_obligation_test)))),
      evidence(
          at(source('eop_concepts.pdf',
                    'references/eop_concepts.pdf',
                    243726,
                    '401346f1e3d75b790cf0229dab174773a4eb854880e6e7c05f6cc924a4afac19'),
             pages(1, 1, 1, 1), raw_utf8([99])),
          claim(source_fact, eop_semantics,
                facets(established(operation_signature),
                       established(operation_concept),
                       established(definition_space),
                       established(operation_law),
                       established(termination_requirement),
                       established(operation_count),
                       established(effect_condition),
                       established(alias_condition),
                       established(physical_and_printed_page),
                       established(proof_obligation_test))))
    ]).

call_hazard(
    evidence(
        at(source('dcg_compiler.pl',
                  'references/dcg_compiler.pl',
                  6743,
                  'ce0851db9749c748b4bf194af539da5cf53174c1a2873b07b2a60aa883b11c2f'),
           lines(207, 207), raw_utf8([99, 97, 108, 108])),
        claim(source_fact, host_goal_execution,
              facets(not_applicable, not_applicable, not_applicable,
                     not_applicable, not_applicable, not_applicable,
                     not_applicable, not_applicable,
                     established(exact_legacy_line),
                     established(reject_host_execution))))).

assert_hazard(
    evidence(
        at(source('dcg_compiler.pl',
                  'references/dcg_compiler.pl',
                  6743,
                  'ce0851db9749c748b4bf194af539da5cf53174c1a2873b07b2a60aa883b11c2f'),
           lines(46, 52), raw_utf8([97, 115, 115, 101, 114, 116])),
        claim(source_fact, dynamic_database_mutation,
              facets(not_applicable, not_applicable, not_applicable,
                     not_applicable, not_applicable, not_applicable,
                     not_applicable, not_applicable,
                     established(exact_legacy_lines),
                     established(reject_dynamic_mutation))))).

connect_difference(
    difference(
        at(source('dcg_compiler.pl',
                  'references/dcg_compiler.pl',
                  6743,
                  'ce0851db9749c748b4bf194af539da5cf53174c1a2873b07b2a60aa883b11c2f'),
           lines(17, 17), raw_utf8([99, 111, 110, 110, 101, 99, 116])),
        at(source('prolog_and_natural_language_analysis.pdf',
                  'references/prolog_and_natural_language_analysis.pdf',
                  1238678,
                  '935c443ea3858af52e76897c65ae84612b4213001b62c718cc19740537e0b776'),
           pages(149, 150, 139, 140),
           raw_utf8([99, 111, 110, 110, 101, 99, 116, 115])),
        claim(hypothesis, cross_source_difference,
              facets(unknown(connect_or_connects), not_applicable,
                     not_applicable, not_applicable, not_applicable,
                     not_applicable, not_applicable, not_applicable,
                     established(two_exact_sources),
                     established(preserve_difference))))).

raw_limit(Accepted, Rejected) :-
    findall(97, between(1, 4096, _), Codes4096),
    findall(97, between(1, 4097, _), Codes4097),
    Source = source('dcg_compiler.pl',
                    'references/dcg_compiler.pl',
                    6743,
                    'ce0851db9749c748b4bf194af539da5cf53174c1a2873b07b2a60aa883b11c2f'),
    Claim = claim(source_fact, encoding,
                  facets(not_applicable, not_applicable, not_applicable,
                         not_applicable, not_applicable, not_applicable,
                         not_applicable, not_applicable, not_applicable,
                         not_applicable)),
    Accepted = evidence(at(Source, lines(49, 49), raw_utf8(Codes4096)), Claim),
    Rejected = evidence(at(Source, lines(49, 49), raw_utf8(Codes4097)), Claim).

span_edges(
    [ evidence(
          at(source('dcg_compiler.pl',
                    'references/dcg_compiler.pl',
                    6743,
                    'ce0851db9749c748b4bf194af539da5cf53174c1a2873b07b2a60aa883b11c2f'),
             lines(235, 235), raw_utf8([100])), Claim)
      -evidence(
          at(source('dcg_compiler.pl',
                    'references/dcg_compiler.pl',
                    6743,
                    'ce0851db9749c748b4bf194af539da5cf53174c1a2873b07b2a60aa883b11c2f'),
             lines(236, 236), raw_utf8([100])), Claim),
      evidence(
          at(source('talk.pl',
                    'references/talk.pl',
                    12610,
                    'ebe594a23f6274c0c29ec855c8730f774be9739ba22ab75f0943dbae174b9bd6'),
             lines(495, 495), raw_utf8([116])), Claim)
      -evidence(
          at(source('talk.pl',
                    'references/talk.pl',
                    12610,
                    'ebe594a23f6274c0c29ec855c8730f774be9739ba22ab75f0943dbae174b9bd6'),
             lines(496, 496), raw_utf8([116])), Claim),
      evidence(
          at(source('prolog_and_natural_language_analysis.pdf',
                    'references/prolog_and_natural_language_analysis.pdf',
                    1238678,
                    '935c443ea3858af52e76897c65ae84612b4213001b62c718cc19740537e0b776'),
             pages(204, 204, 194, 194), raw_utf8([110])), Claim)
      -evidence(
          at(source('prolog_and_natural_language_analysis.pdf',
                    'references/prolog_and_natural_language_analysis.pdf',
                    1238678,
                    '935c443ea3858af52e76897c65ae84612b4213001b62c718cc19740537e0b776'),
             pages(205, 205, 195, 195), raw_utf8([110])), Claim),
      evidence(
          at(source('eop.pdf',
                    'references/eop.pdf',
                    1126874,
                    '3393c7b5c90ad86ee16b5c827282d7f78ae7c4250840842c13e52e51483aa33f'),
             pages(279, 279, 265, 265), raw_utf8([101])), Claim)
      -evidence(
          at(source('eop.pdf',
                    'references/eop.pdf',
                    1126874,
                    '3393c7b5c90ad86ee16b5c827282d7f78ae7c4250840842c13e52e51483aa33f'),
             pages(280, 280, 266, 266), raw_utf8([101])), Claim),
      evidence(
          at(source('eop_concepts.pdf',
                    'references/eop_concepts.pdf',
                    243726,
                    '401346f1e3d75b790cf0229dab174773a4eb854880e6e7c05f6cc924a4afac19'),
             pages(18, 18, 18, 18), raw_utf8([99])), Claim)
      -evidence(
          at(source('eop_concepts.pdf',
                    'references/eop_concepts.pdf',
                    243726,
                    '401346f1e3d75b790cf0229dab174773a4eb854880e6e7c05f6cc924a4afac19'),
             pages(19, 19, 19, 19), raw_utf8([99])), Claim)
    ]) :-
    Claim = claim(source_fact, anomaly,
                  facets(not_applicable, not_applicable, not_applicable,
                         not_applicable, not_applicable, not_applicable,
                         not_applicable, not_applicable, not_applicable,
                         not_applicable)).

assert_non_ground_rejected(Input) :-
    normalize_reference_evidence(Input, Result),
    assertion(Result == normalization(rejected(non_ground_input), none)).

test(unicode_u2019_is_preserved) :-
    dcg_unicode(Input),
    normalize_reference_evidence(Input, Result),
    assertion(Result == normalization(accepted, normalized(Input))),
    Result = normalization(_, normalized(
        evidence(at(_, _, raw_utf8(CodePoints)), _))),
    assertion(CodePoints == [73, 116, 8217, 115]).

test(eop_concepts_definedness_pages_are_preserved) :-
    eop_definedness(Input),
    normalize_reference_evidence(Input, Result),
    Result = normalization(unknown(_), normalized(
        evidence(at(_, Pages, raw_utf8(CodePoints)), _))),
    assertion(Pages == pages(9, 9, 9, 9)),
    assertion(CodePoints == [100, 101, 102, 105, 110, 101, 100]).

test(all_five_source_identities_are_accepted) :-
    all_sources([Nlp, Dcg, Talk, Eop, Concepts]),
    normalize_reference_evidence(Nlp, NlpResult),
    normalize_reference_evidence(Dcg, DcgResult),
    normalize_reference_evidence(Talk, TalkResult),
    normalize_reference_evidence(Eop, EopResult),
    normalize_reference_evidence(Concepts, ConceptsResult),
    assertion(NlpResult == normalization(accepted, normalized(Nlp))),
    assertion(DcgResult == normalization(accepted, normalized(Dcg))),
    assertion(TalkResult == normalization(accepted, normalized(Talk))),
    assertion(EopResult == normalization(accepted, normalized(Eop))),
    assertion(ConceptsResult == normalization(accepted, normalized(Concepts))).

test(host_goal_execution_is_rejected) :-
    call_hazard(Input),
    normalize_reference_evidence(Input, Result),
    assertion(Result ==
              normalization(rejected(host_goal_execution),
                            normalized(Input))).

test(dynamic_database_mutation_is_rejected) :-
    assert_hazard(Input),
    normalize_reference_evidence(Input, Result),
    assertion(Result ==
              normalization(rejected(dynamic_database_mutation),
                            normalized(Input))).

test(source_identity_mismatch_is_rejected) :-
    dcg_unicode(
        evidence(at(source(Basename, Path, Bytes, _), Span, Raw), Claim)),
    Input = evidence(
        at(source(Basename, Path, Bytes,
                  '0000000000000000000000000000000000000000000000000000000000000000'),
           Span, Raw),
        Claim),
    normalize_reference_evidence(Input, Result),
    assertion(Result ==
              normalization(rejected(source_identity_mismatch), none)).

test(silent_unicode_repair_is_not_accepted_as_equal) :-
    dcg_unicode(Input),
    Input = evidence(at(Source, Span, raw_utf8(_)), Claim),
    Repaired = evidence(
        at(Source, Span, raw_utf8([73, 116, 39, 115])), Claim),
    reference_normalization_equal(Input, Repaired, Equality),
    assertion(Equality == equality(unknown(behavioral_equality))).

test(non_ground_input_is_rejected) :-
    dcg_unicode(GroundInput),
    GroundInput = evidence(
        at(source(Basename, Path, Bytes, Sha256), Span, Raw),
        claim(Label, Class, Facets)),
    Direct = evidence(at(_Source, Span, Raw),
                      claim(Label, Class, Facets)),
    NestedSource = evidence(
        at(source(nested(_BasenameVariable), Path, Bytes, Sha256), Span, Raw),
        claim(Label, Class, Facets)),
    NestedSpan = evidence(
        at(source(Basename, Path, Bytes, Sha256),
           lines(nested(_FirstLineVariable), 49),
           Raw),
        claim(Label, Class, Facets)),
    NestedRaw = evidence(
        at(source(Basename, Path, Bytes, Sha256),
           Span,
           raw_utf8([nested(_CodePointVariable)])),
        claim(Label, Class, Facets)),
    NestedLabel = evidence(
        at(source(Basename, Path, Bytes, Sha256), Span, Raw),
        claim(nested(_LabelVariable), Class, Facets)),
    NestedClass = evidence(
        at(source(Basename, Path, Bytes, Sha256), Span, Raw),
        claim(Label, nested(_ClassVariable), Facets)),
    NestedFacet = evidence(
        at(source(Basename, Path, Bytes, Sha256), Span, Raw),
        claim(Label, Class,
              facets(established(nested(_TokenVariable)),
                     not_applicable, not_applicable, not_applicable,
                     not_applicable, not_applicable, not_applicable,
                     not_applicable, established(exact_code_points),
                     established(preserve_unicode)))),
    WrongShape = not_evidence(_WrongShapeVariable),
    assert_non_ground_rejected(Direct),
    assert_non_ground_rejected(NestedSource),
    assert_non_ground_rejected(NestedSpan),
    assert_non_ground_rejected(NestedRaw),
    assert_non_ground_rejected(NestedLabel),
    assert_non_ground_rejected(NestedClass),
    assert_non_ground_rejected(NestedFacet),
    assert_non_ground_rejected(WrongShape),
    numlist(1, 17000, OversizedAt),
    assert_non_ground_rejected(evidence(OversizedAt, _LateVariable)),
    reference_normalization_equal(NestedSource, GroundInput, Equality),
    assertion(Equality ==
              equality(rejected(left(non_ground_input)))).

test(wrong_shape_is_rejected) :-
    normalize_reference_evidence(not_evidence, Result),
    assertion(Result == normalization(rejected(malformed_shape), none)),
    numlist(1, 17000, OversizedShapeArgument),
    normalize_reference_evidence(
        not_evidence(OversizedShapeArgument), OversizedResult),
    assertion(OversizedResult ==
              normalization(rejected(malformed_shape), none)).

test(invalid_unicode_scalar_is_rejected) :-
    dcg_unicode(evidence(at(Source, Span, _), Claim)),
    Input = evidence(at(Source, Span, raw_utf8([55296])), Claim),
    normalize_reference_evidence(Input, Result),
    assertion(Result ==
              normalization(rejected(invalid_unicode_scalar), none)).

test(raw_utf8_4096_is_accepted_and_4097_is_rejected) :-
    raw_limit(Accepted, Rejected),
    normalize_reference_evidence(Accepted, AcceptedResult),
    normalize_reference_evidence(Rejected, RejectedResult),
    assertion(AcceptedResult ==
              normalization(accepted, normalized(Accepted))),
    assertion(RejectedResult ==
              normalization(rejected(resource_limit_exceeded), none)),
    Accepted = evidence(At, _),
    MaximumDifference = difference(
        At,
        At,
        claim(hypothesis, cross_source_difference,
              facets(unknown(maximum_representation),
                     not_applicable, not_applicable, not_applicable,
                     not_applicable, not_applicable, not_applicable,
                     not_applicable, not_applicable, not_applicable))),
    normalize_reference_evidence(MaximumDifference, DifferenceResult),
    assertion(DifferenceResult ==
              normalization(
                  unknown([cross_source_difference,
                           unknown(signature, maximum_representation)]),
                  normalized(MaximumDifference))).

test(final_endpoint_is_accepted_and_overflow_is_rejected) :-
    span_edges([ValidDcg-OverflowDcg, ValidTalk-OverflowTalk,
                ValidNlp-OverflowNlp, ValidEop-OverflowEop,
                ValidConcepts-OverflowConcepts]),
    normalize_reference_evidence(ValidDcg, ValidDcgResult),
    normalize_reference_evidence(OverflowDcg, OverflowDcgResult),
    normalize_reference_evidence(ValidTalk, ValidTalkResult),
    normalize_reference_evidence(OverflowTalk, OverflowTalkResult),
    normalize_reference_evidence(ValidNlp, ValidNlpResult),
    normalize_reference_evidence(OverflowNlp, OverflowNlpResult),
    normalize_reference_evidence(ValidEop, ValidEopResult),
    normalize_reference_evidence(OverflowEop, OverflowEopResult),
    normalize_reference_evidence(ValidConcepts, ValidConceptsResult),
    normalize_reference_evidence(OverflowConcepts, OverflowConceptsResult),
    assertion(ValidDcgResult == normalization(accepted,
                                             normalized(ValidDcg))),
    assertion(ValidTalkResult == normalization(accepted,
                                              normalized(ValidTalk))),
    assertion(ValidNlpResult == normalization(accepted,
                                             normalized(ValidNlp))),
    assertion(ValidEopResult == normalization(accepted,
                                             normalized(ValidEop))),
    assertion(ValidConceptsResult == normalization(accepted,
                                                  normalized(ValidConcepts))),
    assertion(OverflowDcgResult ==
              normalization(rejected(invalid_provenance), none)),
    assertion(OverflowTalkResult ==
              normalization(rejected(invalid_provenance), none)),
    assertion(OverflowNlpResult ==
              normalization(rejected(invalid_provenance), none)),
    assertion(OverflowEopResult ==
              normalization(rejected(invalid_provenance), none)),
    assertion(OverflowConceptsResult ==
              normalization(rejected(invalid_provenance), none)).

test(normalization_result_is_ground) :-
    dcg_unicode(Input),
    normalize_reference_evidence(Input, Accepted),
    normalize_reference_evidence(evidence(_At, invalid_claim), Rejected),
    assertion(ground(Accepted)),
    assertion(ground(Rejected)).

test(public_calls_have_one_solution) :-
    dcg_unicode(Input),
    findall(Result, normalize_reference_evidence(Input, Result), Results),
    findall(Malformed,
            normalize_reference_evidence([wrong|shape], Malformed),
            MalformedResults),
    findall(Equality,
            reference_normalization_equal(Input, Input, Equality),
            Equalities),
    assertion(Results == [normalization(accepted, normalized(Input))]),
    assertion(MalformedResults ==
              [normalization(rejected(malformed_shape), none)]),
    assertion(Equalities == [equality(equal)]).

test(result_is_working_directory_independent) :-
    dcg_unicode(Input),
    normalize_reference_evidence(Input, RootResult),
    working_directory(Original, Original),
    setup_call_cleanup(
        working_directory(_, '/tmp'),
        normalize_reference_evidence(Input, OtherResult),
        working_directory(_, Original)),
    assertion(OtherResult == RootResult).

test(result_is_call_order_independent) :-
    dcg_unicode(Input),
    call_hazard(Forbidden),
    normalize_reference_evidence(Input, First),
    normalize_reference_evidence(Forbidden, Middle),
    normalize_reference_evidence(Input, Last),
    assertion(First == Last),
    assertion(Middle ==
              normalization(rejected(host_goal_execution),
                            normalized(Forbidden))).

test(module_has_no_dynamic_or_meta_predicates) :-
    findall(Name/Arity,
            ( current_predicate(cps_reference_normalization:Name/Arity),
              functor(Head, Name, Arity),
              \+ predicate_property(cps_reference_normalization:Head,
                                    imported_from(_)),
              predicate_property(cps_reference_normalization:Head, dynamic)
            ),
            Dynamic),
    findall(Name/Arity,
            ( current_predicate(cps_reference_normalization:Name/Arity),
              functor(Head, Name, Arity),
              \+ predicate_property(cps_reference_normalization:Head,
                                    imported_from(_)),
              predicate_property(cps_reference_normalization:Head,
                                 meta_predicate(_))
            ),
            Meta),
    assertion(Dynamic == []),
    assertion(Meta == []).

test(connect_difference_is_unknown) :-
    connect_difference(Input),
    normalize_reference_evidence(Input, Result),
    assertion(Result ==
              normalization(
                  unknown([cross_source_difference,
                           unknown(signature, connect_or_connects)]),
                  normalized(Input))).

test(missing_definedness_is_unknown) :-
    eop_definedness(Input),
    normalize_reference_evidence(Input, Result),
    assertion(Result ==
              normalization(
                  unknown([
                      unknown(definedness,
                              adjacent_applications_must_be_defined)
                  ]),
                  normalized(Input))).

test(unequal_valid_records_have_unknown_equality) :-
    dcg_unicode(Left),
    eop_definedness(Right),
    reference_normalization_equal(Left, Right, Equality),
    assertion(Equality == equality(unknown(behavioral_equality))).

:- end_tests(cps_reference_normalization).
