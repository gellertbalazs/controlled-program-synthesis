:- module(cps_reference_normalization,
          [ normalize_reference_evidence/2,
            reference_normalization_equal/3
          ]).

/** <module> Bounded normalization of source-relative evidence

This module validates immutable, ground evidence-view terms.  Acceptance is
syntactic only: no source is read and no legacy term is loaded or executed.
*/

%!  normalize_reference_evidence(+Input, -Result) is det.
%
%   Validate Input without changing its raw code points.  Every input term
%   produces exactly one accepted, unknown, or rejected normalization result.
normalize_reference_evidence(Input, Result) :-
    input_preflight(Input, Preflight, Kind, Ats, Label, Class, Facets),
    (   Preflight == ok
    ->  normalize_preflighted(Input, Kind, Ats, Label, Class, Facets, Result)
    ;   Result = normalization(rejected(Preflight), none)
    ).

%!  reference_normalization_equal(+Left, +Right, -Equality) is det.
%
%   Compare complete normalization results structurally.  A rejected left
%   side takes priority over a rejected right side.
reference_normalization_equal(Left, Right, Equality) :-
    normalize_reference_evidence(Left, LeftResult),
    normalize_reference_evidence(Right, RightResult),
    (   LeftResult = normalization(rejected(LeftReason), _)
    ->  Equality = equality(rejected(left(LeftReason)))
    ;   RightResult = normalization(rejected(RightReason), _)
    ->  Equality = equality(rejected(right(RightReason)))
    ;   LeftResult == RightResult
    ->  Equality = equality(equal)
    ;   Equality = equality(unknown(behavioral_equality))
    ).

input_preflight(Input, Status, Kind, Ats, Label, Class, Facets) :-
    (   var(Input)
    ->  Status = non_ground_input,
        Kind = invalid,
        Ats = [],
        Label = invalid,
        Class = invalid,
        Facets = invalid
    ;   Input = evidence(At, Claim)
    ->  Kind = evidence,
        Ats = [At],
        preflight_at(At, AtStatus),
        preflight_claim(Claim, Label, Class, Facets, ClaimStatus),
        combine_status(AtStatus, ClaimStatus, Status)
    ;   Input = difference(LeftAt, RightAt, Claim)
    ->  Kind = difference,
        Ats = [LeftAt, RightAt],
        preflight_at(LeftAt, LeftStatus),
        preflight_at(RightAt, RightStatus),
        preflight_claim(Claim, Label, Class, Facets, ClaimStatus),
        combine_status(LeftStatus, RightStatus, EndpointStatus),
        combine_status(EndpointStatus, ClaimStatus, Status)
    ;   malformed_term_status(Input, Status),
        Kind = invalid,
        Ats = [],
        Label = invalid,
        Class = invalid,
        Facets = invalid
    ).

% Each fixed field is inspected independently.  This prevents an oversized
% earlier field from consuming the budget before a later fixed-field variable
% is checked, while keeping cyclic and excess field inspection bounded.
input_term_node_limit(17000).

bounded_term_status(Term, Budget0, Budget, Status) :-
    (   var(Term)
    ->  Status = non_ground_input,
        Budget = Budget0
    ;   Budget0 =< 0
    ->  Status = resource_limit_exceeded,
        Budget = 0
    ;   Budget1 is Budget0 - 1,
        (   compound(Term)
        ->  functor(Term, _Name, Arity),
            bounded_argument_status(1, Arity, Term, Budget1, Budget, Status)
        ;   Status = ok,
            Budget = Budget1
        )
    ).

bounded_argument_status(Index, Arity, Term, Budget0, Budget, Status) :-
    (   Index > Arity
    ->  Status = ok,
        Budget = Budget0
    ;   arg(Index, Term, Argument),
        bounded_term_status(Argument, Budget0, Budget1, ArgumentStatus),
        (   ArgumentStatus == ok
        ->  Next is Index + 1,
            bounded_argument_status(
                Next, Arity, Term, Budget1, Budget, Status)
        ;   Status = ArgumentStatus,
            Budget = Budget1
        )
    ).

malformed_term_status(Term, Status) :-
    input_term_node_limit(Limit),
    bounded_term_status(Term, Limit, _Remaining, TermStatus),
    (   TermStatus == non_ground_input
    ->  Status = non_ground_input
    ;   Status = malformed_shape
    ).

preflight_at(At, Status) :-
    (   var(At)
    ->  Status = non_ground_input
    ;   At = at(Source, Span, Raw)
    ->  preflight_source(Source, SourceStatus),
        preflight_span(Span, SpanStatus),
        preflight_raw(Raw, RawStatus),
        combine_status(SourceStatus, SpanStatus, AtStatus),
        combine_status(AtStatus, RawStatus, Status)
    ;   malformed_term_status(At, Status)
    ).

preflight_source(Source, Status) :-
    (   var(Source)
    ->  Status = non_ground_input
    ;   Source = source(Basename, Path, Bytes, Sha256)
    ->  leaf_status(Basename, BasenameStatus),
        leaf_status(Path, PathStatus),
        leaf_status(Bytes, BytesStatus),
        leaf_status(Sha256, ShaStatus),
        combine_status(BasenameStatus, PathStatus, First),
        combine_status(BytesStatus, ShaStatus, Second),
        combine_status(First, Second, Status)
    ;   malformed_term_status(Source, Status)
    ).

preflight_span(Span, Status) :-
    (   var(Span)
    ->  Status = non_ground_input
    ;   Span = lines(First, Last)
    ->  leaf_status(First, FirstStatus),
        leaf_status(Last, LastStatus),
        combine_status(FirstStatus, LastStatus, Status)
    ;   Span = pages(PF, PL, VF, VL)
    ->  leaf_status(PF, PFStatus),
        leaf_status(PL, PLStatus),
        leaf_status(VF, VFStatus),
        leaf_status(VL, VLStatus),
        combine_status(PFStatus, PLStatus, PhysicalStatus),
        combine_status(VFStatus, VLStatus, VisibleStatus),
        combine_status(PhysicalStatus, VisibleStatus, Status)
    ;   malformed_term_status(Span, Status)
    ).

preflight_raw(Raw, Status) :-
    (   var(Raw)
    ->  Status = non_ground_input
    ;   Raw = raw_utf8(CodePoints)
    ->  raw_list_status(CodePoints, 0, Status)
    ;   malformed_term_status(Raw, Status)
    ).

raw_list_status(List, Count, Status) :-
    (   var(List)
    ->  Status = non_ground_input
    ;   List == []
    ->  (   Count =:= 0
        ->  Status = malformed_shape
        ;   Status = ok
        )
    ;   List = [CodePoint|Rest]
    ->  (   var(CodePoint)
        ->  Status = non_ground_input
        ;   Count >= 4096
        ->  Status = resource_limit_exceeded
        ;   leaf_status(CodePoint, CodePointStatus),
            (   CodePointStatus == ok
            ->  Next is Count + 1,
                raw_list_status(Rest, Next, Status)
            ;   Status = CodePointStatus
            )
        )
    ;   malformed_term_status(List, Status)
    ).

preflight_claim(Claim, Label, Class, Facets, Status) :-
    (   var(Claim)
    ->  Status = non_ground_input,
        Label = invalid,
        Class = invalid,
        Facets = invalid
    ;   Claim = claim(Label, Class, Facets)
    ->  label_status(Label, LabelStatus),
        leaf_status(Class, ClassStatus),
        preflight_facets(Facets, FacetStatus),
        combine_status(LabelStatus, ClassStatus, ClaimStatus),
        combine_status(ClaimStatus, FacetStatus, Status)
    ;   malformed_term_status(Claim, Status),
        Label = invalid,
        Class = invalid,
        Facets = invalid
    ).

label_status(Label, Status) :-
    leaf_status(Label, LeafStatus),
    (   LeafStatus \== ok
    ->  Status = LeafStatus
    ;   valid_label(Label)
    ->  Status = ok
    ;   Status = malformed_shape
    ).

valid_label(source_fact).
valid_label(project_interpretation).
valid_label(proposed_decision).
valid_label(hypothesis).

preflight_facets(Facets, Status) :-
    (   var(Facets)
    ->  Status = non_ground_input
    ;   Facets = facets(Signature, Concepts, Definedness, Laws, Termination,
                        Cost, Effects, Aliasing, Provenance, TestImplications)
    ->  preflight_facet(Signature, SignatureStatus),
        preflight_facet(Concepts, ConceptsStatus),
        preflight_facet(Definedness, DefinednessStatus),
        preflight_facet(Laws, LawsStatus),
        preflight_facet(Termination, TerminationStatus),
        preflight_facet(Cost, CostStatus),
        preflight_facet(Effects, EffectsStatus),
        preflight_facet(Aliasing, AliasingStatus),
        preflight_facet(Provenance, ProvenanceStatus),
        preflight_facet(TestImplications, TestStatus),
        combine_status(SignatureStatus, ConceptsStatus, Status01),
        combine_status(DefinednessStatus, LawsStatus, Status23),
        combine_status(TerminationStatus, CostStatus, Status45),
        combine_status(EffectsStatus, AliasingStatus, Status67),
        combine_status(ProvenanceStatus, TestStatus, Status89),
        combine_status(Status01, Status23, Status0123),
        combine_status(Status45, Status67, Status4567),
        combine_status(Status0123, Status4567, Status0to7),
        combine_status(Status0to7, Status89, Status)
    ;   malformed_term_status(Facets, Status)
    ).

preflight_facet(Facet, Status) :-
    (   var(Facet)
    ->  Status = non_ground_input
    ;   Facet = established(Token)
    ->  token_status(Token, Status)
    ;   Facet = unknown(Reason)
    ->  token_status(Reason, Status)
    ;   Facet == not_applicable
    ->  Status = ok
    ;   malformed_term_status(Facet, Status)
    ).

token_status(Token, Status) :-
    leaf_status(Token, LeafStatus),
    (   LeafStatus \== ok
    ->  Status = LeafStatus
    ;   atom(Token)
    ->  token_scalar_status(Token, 0, Status)
    ;   Status = malformed_shape
    ).

token_scalar_status(Token, Index, Status) :-
    (   sub_atom(Token, Index, 1, _, Character)
    ->  (   Index >= 256
        ->  Status = resource_limit_exceeded
        ;   char_code(Character, CodePoint),
            (   unicode_scalar(CodePoint)
            ->  Next is Index + 1,
                token_scalar_status(Token, Next, Status)
            ;   Status = malformed_shape
            )
        )
    ;   (   Index =:= 0
        ->  Status = malformed_shape
        ;   Status = ok
        )
    ).

leaf_status(Value, Status) :-
    input_term_node_limit(Limit),
    bounded_term_status(Value, Limit, _Remaining, Status).

combine_status(Left, Right, Status) :-
    (   Left == non_ground_input
    ->  Status = non_ground_input
    ;   Right == non_ground_input
    ->  Status = non_ground_input
    ;   Left == malformed_shape
    ->  Status = malformed_shape
    ;   Right == malformed_shape
    ->  Status = malformed_shape
    ;   Left == resource_limit_exceeded
    ->  Status = resource_limit_exceeded
    ;   Right == resource_limit_exceeded
    ->  Status = resource_limit_exceeded
    ;   Status = ok
    ).

normalize_preflighted(Input, Kind, Ats, Label, Class, Facets, Result) :-
    source_status(Ats, SourceStatus, Descriptors),
    (   SourceStatus \== ok
    ->  Result = normalization(rejected(SourceStatus), none)
    ;   provenance_status(Ats, Descriptors, ProvenanceStatus),
        (   ProvenanceStatus \== ok
        ->  Result = normalization(rejected(invalid_provenance), none)
        ;   raw_unicode_status(Ats, UnicodeStatus),
            (   UnicodeStatus \== ok
            ->  Result = normalization(rejected(invalid_unicode_scalar), none)
            ;   class_status(Kind, Class, ClassStatus),
                finish_classification(ClassStatus, Input, Kind, Label, Class,
                                      Facets, Result)
            )
        )
    ).

source_status(Ats, Status, Descriptors) :-
    (   Ats = [At]
    ->  Descriptors = [Descriptor],
        at_source(At, Source),
        source_identity_status(Source, Status, Descriptor)
    ;   Ats = [LeftAt, RightAt],
        Descriptors = [LeftDescriptor, RightDescriptor],
        at_source(LeftAt, LeftSource),
        at_source(RightAt, RightSource),
        source_identity_status(LeftSource, LeftStatus, LeftDescriptor),
        source_identity_status(RightSource, RightStatus, RightDescriptor),
        combine_source_status(LeftStatus, RightStatus, Status)
    ).

at_source(at(Source, _, _), Source).

source_identity_status(source(Basename, Path, Bytes, Sha256),
                       Status, Descriptor) :-
    (   manifest_source(Basename, ExpectedPath, ExpectedBytes, ExpectedSha,
                        Descriptor)
    ->  (   Path == ExpectedPath,
            Bytes == ExpectedBytes,
            Sha256 == ExpectedSha
        ->  Status = ok
        ;   Status = source_identity_mismatch
        )
    ;   Status = unsupported_source,
        Descriptor = unsupported
    ).

combine_source_status(Left, Right, Status) :-
    (   Left == unsupported_source
    ->  Status = unsupported_source
    ;   Right == unsupported_source
    ->  Status = unsupported_source
    ;   Left == source_identity_mismatch
    ->  Status = source_identity_mismatch
    ;   Right == source_identity_mismatch
    ->  Status = source_identity_mismatch
    ;   Status = ok
    ).

manifest_source(
    'prolog_and_natural_language_analysis.pdf',
    'references/prolog_and_natural_language_analysis.pdf',
    1238678,
    '935c443ea3858af52e76897c65ae84612b4213001b62c718cc19740537e0b776',
    pdf(11, 204, 10)).
manifest_source(
    'dcg_compiler.pl',
    'references/dcg_compiler.pl',
    6743,
    'ce0851db9749c748b4bf194af539da5cf53174c1a2873b07b2a60aa883b11c2f',
    prolog(235)).
manifest_source(
    'talk.pl',
    'references/talk.pl',
    12610,
    'ebe594a23f6274c0c29ec855c8730f774be9739ba22ab75f0943dbae174b9bd6',
    prolog(495)).
manifest_source(
    'eop.pdf',
    'references/eop.pdf',
    1126874,
    '3393c7b5c90ad86ee16b5c827282d7f78ae7c4250840842c13e52e51483aa33f',
    pdf(15, 279, 14)).
manifest_source(
    'eop_concepts.pdf',
    'references/eop_concepts.pdf',
    243726,
    '401346f1e3d75b790cf0229dab174773a4eb854880e6e7c05f6cc924a4afac19',
    pdf(1, 18, 0)).

provenance_status(Ats, Descriptors, Status) :-
    (   Ats = [At],
        Descriptors = [Descriptor]
    ->  at_span(At, Span),
        span_status(Descriptor, Span, Status)
    ;   Ats = [LeftAt, RightAt],
        Descriptors = [LeftDescriptor, RightDescriptor],
        at_span(LeftAt, LeftSpan),
        at_span(RightAt, RightSpan),
        span_status(LeftDescriptor, LeftSpan, LeftStatus),
        span_status(RightDescriptor, RightSpan, RightStatus),
        (   LeftStatus == ok,
            RightStatus == ok
        ->  Status = ok
        ;   Status = invalid_provenance
        )
    ).

at_span(at(_, Span, _), Span).

span_status(Descriptor, Span, Status) :-
    (   Descriptor = prolog(Maximum),
        Span = lines(First, Last)
    ->  (   integer(First),
            integer(Last),
            First >= 1,
            First =< Last,
            Last =< Maximum
        ->  Status = ok
        ;   Status = invalid_provenance
        )
    ;   Descriptor = pdf(Minimum, Maximum, Offset),
        Span = pages(PF, PL, VF, VL)
    ->  (   integer(PF),
            integer(PL),
            integer(VF),
            integer(VL),
            PF >= Minimum,
            PF =< PL,
            PL =< Maximum,
            VF =:= PF - Offset,
            VL =:= PL - Offset,
            VF =< VL
        ->  Status = ok
        ;   Status = invalid_provenance
        )
    ;   Status = invalid_provenance
    ).

raw_unicode_status(Ats, Status) :-
    (   Ats = [At]
    ->  at_code_points(At, CodePoints),
        code_points_status(CodePoints, Status)
    ;   Ats = [LeftAt, RightAt],
        at_code_points(LeftAt, LeftCodePoints),
        at_code_points(RightAt, RightCodePoints),
        code_points_status(LeftCodePoints, LeftStatus),
        code_points_status(RightCodePoints, RightStatus),
        (   LeftStatus == ok,
            RightStatus == ok
        ->  Status = ok
        ;   Status = invalid_unicode_scalar
        )
    ).

at_code_points(at(_, _, raw_utf8(CodePoints)), CodePoints).

code_points_status([], ok).
code_points_status([CodePoint|Rest], Status) :-
    (   unicode_scalar(CodePoint)
    ->  code_points_status(Rest, Status)
    ;   Status = invalid_unicode_scalar
    ).

unicode_scalar(CodePoint) :-
    integer(CodePoint),
    CodePoint >= 0,
    CodePoint =< 1114111,
    (   CodePoint < 55296
    ;   CodePoint > 57343
    ).

class_status(Kind, Class, Status) :-
    (   supported_class(Class)
    ->  (   Kind == difference,
            Class \== cross_source_difference
        ->  Status = unsupported_class
        ;   Status = ok
        )
    ;   Status = unsupported_class
    ).

supported_class(encoding).
supported_class(operator).
supported_class(dependency).
supported_class(control).
supported_class(host_goal_execution).
supported_class(dynamic_database_mutation).
supported_class(grammar).
supported_class(logical_form).
supported_class(query).
supported_class(anomaly).
supported_class(cross_source_difference).
supported_class(eop_semantics).

finish_classification(unsupported_class, _, _, _, _, _, Result) :-
    Result = normalization(rejected(unsupported_class), none).
finish_classification(ok, Input, Kind, Label, Class, Facets, Result) :-
    (   forbidden_class(Class)
    ->  Result = normalization(rejected(Class), normalized(Input))
    ;   facet_unknown_reasons(Facets, FacetReasons),
        finish_unknowns(Kind, Label, FacetReasons, Input, Result)
    ).

forbidden_class(host_goal_execution).
forbidden_class(dynamic_database_mutation).

finish_unknowns(Kind, Label, FacetReasons, Input, Result) :-
    (   FacetReasons == [],
        (Kind == difference ; Label == hypothesis)
    ->  Result = normalization(rejected(missing_required_unknown), none)
    ;   FacetReasons == []
    ->  Result = normalization(accepted, normalized(Input))
    ;   Kind == difference
    ->  Reasons = [cross_source_difference|FacetReasons],
        Result = normalization(unknown(Reasons), normalized(Input))
    ;   Result = normalization(unknown(FacetReasons), normalized(Input))
    ).

facet_unknown_reasons(
    facets(Signature, Concepts, Definedness, Laws, Termination, Cost, Effects,
           Aliasing, Provenance, TestImplications),
    Reasons) :-
    facet_unknown(signature, Signature, Reasons, Tail1),
    facet_unknown(concepts, Concepts, Tail1, Tail2),
    facet_unknown(definedness, Definedness, Tail2, Tail3),
    facet_unknown(laws, Laws, Tail3, Tail4),
    facet_unknown(termination, Termination, Tail4, Tail5),
    facet_unknown(cost, Cost, Tail5, Tail6),
    facet_unknown(effects, Effects, Tail6, Tail7),
    facet_unknown(aliasing, Aliasing, Tail7, Tail8),
    facet_unknown(provenance, Provenance, Tail8, Tail9),
    facet_unknown(test_implications, TestImplications, Tail9, []).

facet_unknown(Name, unknown(Reason), [unknown(Name, Reason)|Tail], Tail).
facet_unknown(_, established(_), Tail, Tail).
facet_unknown(_, not_applicable, Tail, Tail).
