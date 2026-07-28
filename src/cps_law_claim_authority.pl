:- module(cps_law_claim_authority,
          [ assess_law_claim_authority/2
          ]).

:- use_module(cps_reference_normalization,
              [ normalize_reference_evidence/2
              ]).

/** <module> Bounded source-relative law-claim authority

This module assesses one closed, one-hop authority snapshot.  T001
normalization is used only as a syntactic provenance check.  No identifier,
payload, source, ordering position, or shared provenance record supplies
semantic truth or authority.
*/

%!  assess_law_claim_authority(+Snapshot, -Result) is det.
%
%   Produce one ground accepted, rejected, or unknown assessment for every
%   Prolog term in Snapshot.  Malformed and resource-excess inputs fail closed
%   with the pre-closure audit.
assess_law_claim_authority(Snapshot, Result) :-
    (   catch(assess_guarded(Snapshot, Guarded), _,
              emergency_resource_result(Guarded))
    ->  Result = Guarded
    ;   malformed_result(Result)
    ).

preclosure_audit(
    audit(no_claim, no_policy, used([]), provenance([]))).

rejected_preclosure(Reason,
                    authority_assessment(rejected(Reason), Audit)) :-
    preclosure_audit(Audit).

emergency_resource_result(Result) :-
    rejected_preclosure(resource_limit_exceeded, Result).

malformed_result(Result) :-
    rejected_preclosure(malformed_shape, Result).

assess_guarded(Snapshot, Result) :-
    (   var(Snapshot)
    ->  rejected_preclosure(non_ground_input, Result)
    ;   functor(Snapshot, authority_snapshot, 7)
    ->  snapshot_fields(Snapshot, Fields),
        preflight_snapshot(Snapshot, Fields, Preflight),
        assess_preflighted(Preflight, Snapshot, Result)
    ;   rejected_preclosure(malformed_shape, Result)
    ).

snapshot_fields(Snapshot,
                fields(Policy, Claim, Records, Premises, Obligations,
                       Contradictions, Provenances)) :-
    arg(1, Snapshot, Policy),
    arg(2, Snapshot, Claim),
    arg(3, Snapshot, Records),
    arg(4, Snapshot, Premises),
    arg(5, Snapshot, Obligations),
    arg(6, Snapshot, Contradictions),
    arg(7, Snapshot, Provenances).

assess_preflighted(ok, Snapshot, Result) :-
    close_snapshot(Snapshot, Closure),
    finish_closure(Closure, Result).
assess_preflighted(Status, _, Result) :-
    Status \== ok,
    rejected_preclosure(Status, Result).

finish_closure(rejected(Reason), Result) :-
    rejected_preclosure(Reason, Result).
finish_closure(closed(Data), Result) :-
    provenance_first_use(Data, ProvenanceIds),
    validate_provenance_table(
        ProvenanceIds, Data, ProvenanceTable, ExactRecords),
    canonical_missing(Data, ProvenanceTable, Missing),
    list_length_bounded(Missing, 48, MissingLimit),
    finish_closed_limit(
        MissingLimit, Data, ProvenanceTable, ExactRecords, Missing, Result).

finish_closed_limit(resource_limit_exceeded, _, _, _, _, Result) :-
    rejected_preclosure(resource_limit_exceeded, Result).
finish_closed_limit(ok, Data, ProvenanceTable, ExactRecords, Missing, Result) :-
    (   first_invalid_provenance(ProvenanceTable, InvalidReason)
    ->  rejected_preclosure(InvalidReason, Result)
    ;   closed_audit(Data, ExactRecords, Audit),
        authority_result(Data, Missing, Audit, Result)
    ).

% Structural preflight

preflight_snapshot(Snapshot, Fields, Status) :-
    structural_visit_limit(Limit),
    priority_fields_status(
        Fields, Limit, PriorityFields, PriorityStatus),
    finish_priority_preflight(
        PriorityStatus, PriorityFields, Snapshot, Fields, Limit, Status).

finish_priority_preflight(
    cyclic_input, _, _, _, _, cyclic_input).
finish_priority_preflight(
    non_ground_input, _, _, _, _, non_ground_input).
finish_priority_preflight(
    PriorityStatus, PriorityFields, Snapshot, Fields, Limit, Status) :-
    PriorityStatus \== cyclic_input,
    PriorityStatus \== non_ground_input,
    copy_term(Fields, ShapeFields),
    shallow_fields_status(
        ShapeFields, PriorityFields, FixedStatus),
    finish_fixed_preflight(FixedStatus, Snapshot, Limit, Status).

finish_fixed_preflight(ok, Snapshot, Limit, Status) :-
    scan_term(Snapshot, [], 0, Limit, _Remaining, Status).
finish_fixed_preflight(Status, _, _, Status) :-
    Status \== ok.

structural_visit_limit(750000).
maximum_depth(32).

priority_fields_status(
    fields(Policy, Claim, Records, Premises, Obligations,
           Contradictions, Provenances),
    Limit,
    priority_fields(
        PolicyStatus, ClaimStatus, RecordStatus, PremiseStatus,
        ObligationStatus, ContradictionStatus, ProvenanceStatus),
    Status) :-
    scan_priority_term(
        Policy, [], 1, Limit, _PolicyRemaining, PolicyStatus),
    scan_priority_term(
        Claim, [], 1, Limit, _ClaimRemaining, ClaimStatus),
    scan_priority_term(
        Records, [], 1, Limit, _RecordRemaining, RecordStatus),
    scan_priority_term(
        Premises, [], 1, Limit, _PremiseRemaining, PremiseStatus),
    scan_priority_term(
        Obligations, [], 1, Limit, _ObligationRemaining,
        ObligationStatus),
    scan_priority_term(
        Contradictions, [], 1, Limit, _ContradictionRemaining,
        ContradictionStatus),
    scan_priority_term(
        Provenances, [], 1, Limit, _ProvenanceRemaining,
        ProvenanceStatus),
    combine_preflight(PolicyStatus, ClaimStatus, Status01),
    combine_preflight(RecordStatus, PremiseStatus, Status23),
    combine_preflight(ObligationStatus, ContradictionStatus, Status45),
    combine_preflight(Status01, Status23, Status0123),
    combine_preflight(Status45, ProvenanceStatus, Status456),
    combine_preflight(Status0123, Status456, Status).

% Each non-list compound and list head descent increments Depth.  List tails
% retain one active spine root instead of every preceding cell.  A compound
% at depth 33 is checked for ancestor identity and then rejected without
% descent, so every ancestor scan compares at most 33 active frames.  Floyd's
% identity probe performs at most the remaining visit budget comparisons for
% each of at most 32 active list spines.  Comparison work is therefore a
% fixed-factor linear function of the inspected-node bound.
scan_priority_term(
    Term, Ancestors, Depth, Budget0, Budget, Status) :-
    (   nonvar(Term),
        compound(Term),
        identity_member(Term, Ancestors)
    ->  Status = cyclic_input,
        Budget = Budget0
    ;   var(Term)
    ->  Status = non_ground_input,
        Budget = Budget0
    ;   Budget0 =< 0
    ->  Status = resource_limit_exceeded,
        Budget = 0
    ;   atomic(Term)
    ->  Status = ok,
        Budget is Budget0 - 1
    ;   maximum_depth(MaximumDepth),
        Depth > MaximumDepth
    ->  Status = resource_limit_exceeded,
        Budget is Budget0 - 1
    ;   Term = [_|_]
    ->  scan_priority_list(
            Term, Ancestors, Depth, Budget0, Budget, Status)
    ;   Budget1 is Budget0 - 1,
        functor(Term, _, Arity),
        ChildDepth is Depth + 1,
        scan_priority_arguments(
            1, Arity, Term, [Term|Ancestors], ChildDepth,
            Budget1, Budget, Status)
    ).

scan_priority_list(
    List, Ancestors, Depth, Budget0, Budget, Status) :-
    list_spine_status(List, Budget0, SpineStatus),
    finish_priority_list_spine(
        SpineStatus, List, Ancestors, Depth,
        Budget0, Budget, Status).

finish_priority_list_spine(
    cyclic_input, _, _, _, Budget, Budget, cyclic_input).
finish_priority_list_spine(
    SpineStatus, List, Ancestors, Depth,
    Budget0, Budget, Status) :-
    SpineStatus \== cyclic_input,
    scan_priority_list_cells(
        List, List, Ancestors, Depth, Budget0, Budget, Status).

scan_priority_list_cells(
    Current, Root, Ancestors, Depth, Budget0, Budget, Status) :-
    Budget1 is Budget0 - 1,
    arg(1, Current, Head),
    arg(2, Current, Tail),
    list_head_ancestors(Current, Root, Ancestors, HeadAncestors),
    ChildDepth is Depth + 1,
    scan_priority_term(
        Head, HeadAncestors, ChildDepth,
        Budget1, Budget2, HeadStatus),
    scan_priority_list_tail(
        Tail, Current, Root, Ancestors, Depth,
        Budget2, Budget, TailStatus),
    combine_preflight(HeadStatus, TailStatus, Status).

list_head_ancestors(Current, Root, Ancestors, HeadAncestors) :-
    (   Current == Root
    ->  HeadAncestors = [Current|Ancestors]
    ;   HeadAncestors = [Current,Root|Ancestors]
    ).

scan_priority_list_tail(
    Tail, Current, Root, Ancestors, Depth,
    Budget0, Budget, Status) :-
    list_head_ancestors(Current, Root, Ancestors, TailAncestors),
    (   nonvar(Tail),
        Tail = [_|_]
    ->  (   identity_member(Tail, TailAncestors)
        ->  Budget = Budget0,
            Status = cyclic_input
        ;   Budget0 =< 0
        ->  Budget = 0,
            Status = resource_limit_exceeded
        ;   scan_priority_list_cells(
                Tail, Root, Ancestors, Depth,
                Budget0, Budget, Status)
        )
    ;   scan_priority_term(
            Tail, TailAncestors, Depth,
            Budget0, Budget, Status)
    ).

list_spine_status(List, Limit, Status) :-
    list_spine_floyd(List, List, Limit, Status).

list_spine_floyd(_, _, Limit, bounded) :-
    Limit =< 0,
    !.
list_spine_floyd(Slow, Fast, Limit, Status) :-
    list_tail_step(Slow, SlowNext, SlowState),
    list_tail_step(Fast, FastOnce, FastOnceState),
    (   SlowState == stopped
    ->  Status = ok
    ;   FastOnceState == stopped
    ->  Status = ok
    ;   list_tail_step(FastOnce, FastNext, FastState),
        (   FastState == stopped
        ->  Status = ok
        ;   SlowNext == FastNext
        ->  Status = cyclic_input
        ;   Next is Limit - 1,
            list_spine_floyd(
                SlowNext, FastNext, Next, Status)
        )
    ).

list_tail_step(Term, Tail, State) :-
    (   nonvar(Term),
        Term = [_|Next]
    ->  Tail = Next,
        State = advanced
    ;   State = stopped
    ).

scan_priority_arguments(
    Index, Arity, _, _, _, Budget, Budget, ok) :-
    Index > Arity.
scan_priority_arguments(
    Index, Arity, Term, Ancestors, Depth,
    Budget0, Budget, Status) :-
    Index =< Arity,
    arg(Index, Term, Argument),
    scan_priority_term(
        Argument, Ancestors, Depth,
        Budget0, Budget1, ArgumentStatus),
    (   ArgumentStatus == cyclic_input
    ->  Budget = Budget1,
        Status = cyclic_input
    ;   Next is Index + 1,
        scan_priority_arguments(
            Next, Arity, Term, Ancestors, Depth,
            Budget1, Budget, RestStatus),
        combine_preflight(ArgumentStatus, RestStatus, Status)
    ).

combine_preflight(cyclic_input, _, cyclic_input).
combine_preflight(_, cyclic_input, cyclic_input).
combine_preflight(non_ground_input, _, non_ground_input).
combine_preflight(_, non_ground_input, non_ground_input).
combine_preflight(_, malformed_shape, malformed_shape).
combine_preflight(malformed_shape, _, malformed_shape).
combine_preflight(resource_limit_exceeded, _,
                  resource_limit_exceeded).
combine_preflight(_, resource_limit_exceeded,
                  resource_limit_exceeded).
combine_preflight(ok, ok, ok).

scan_term(Term, Ancestors, Depth, Budget0, Budget, Status) :-
    (   nonvar(Term),
        compound(Term),
        identity_member(Term, Ancestors)
    ->  Status = cyclic_input,
        Budget = Budget0
    ;   var(Term)
    ->  Status = non_ground_input,
        Budget = Budget0
    ;   Budget0 =< 0
    ->  Status = resource_limit_exceeded,
        Budget = 0
    ;   atomic(Term)
    ->  scan_atomic(Term, Budget0, Budget, Status)
    ;   maximum_depth(MaximumDepth),
        Depth > MaximumDepth
    ->  Status = resource_limit_exceeded,
        Budget is Budget0 - 1
    ;   Budget1 is Budget0 - 1,
        scan_compound(Term, [Term|Ancestors], Depth, Budget1,
                      Budget, Status)
    ).

scan_atomic(Term, Budget0, Budget, Status) :-
    (   atom(Term)
    ->  Budget1 is Budget0 - 1,
        (   sub_atom(Term, Budget1, 1, _, _Character)
        ->  Budget = 0,
            Status = resource_limit_exceeded
        ;   atom_length(Term, Scalars),
            Budget is Budget1 - Scalars,
            Status = ok
        )
    ;   Budget is Budget0 - 1,
        Status = ok
    ).

scan_compound(Term, Ancestors, Depth, Budget0, Budget, Status) :-
    (   Term = [_|_]
    ->  arg(1, Term, Head),
        arg(2, Term, Tail),
        Ancestors = [_Current|ParentAncestors],
        ChildDepth is Depth + 1,
        scan_term(Head, Ancestors, ChildDepth, Budget0,
                  Budget1, HeadStatus),
        scan_term(Tail, ParentAncestors, Depth, Budget1,
                  Budget, TailStatus),
        combine_scan(HeadStatus, TailStatus, Status)
    ;   functor(Term, _, Arity),
        ChildDepth is Depth + 1,
        scan_arguments(1, Arity, Term, Ancestors, ChildDepth,
                       Budget0, Budget, Status)
    ).

scan_arguments(Index, Arity, _, _, _, Budget, Budget, ok) :-
    Index > Arity.
scan_arguments(Index, Arity, Term, Ancestors, Depth,
               Budget0, Budget, Status) :-
    Index =< Arity,
    arg(Index, Term, Argument),
    scan_term(Argument, Ancestors, Depth, Budget0,
              Budget1, ArgumentStatus),
    (   ArgumentStatus == cyclic_input
    ->  Budget = Budget1,
        Status = cyclic_input
    ;   Next is Index + 1,
        scan_arguments(Next, Arity, Term, Ancestors, Depth,
                       Budget1, Budget, RestStatus),
        combine_scan(ArgumentStatus, RestStatus, Status)
    ).

combine_scan(cyclic_input, _, cyclic_input).
combine_scan(_, cyclic_input, cyclic_input).
combine_scan(non_ground_input, _, non_ground_input).
combine_scan(_, non_ground_input, non_ground_input).
combine_scan(resource_limit_exceeded, _,
             resource_limit_exceeded).
combine_scan(_, resource_limit_exceeded,
             resource_limit_exceeded).
combine_scan(ok, ok, ok).

identity_member(Term, [Head|_]) :-
    Term == Head.
identity_member(Term, [_|Tail]) :-
    identity_member(Term, Tail).

shallow_fields_status(
    fields(Policy, Claim, Records, Premises, Obligations,
           Contradictions, Provenances),
    priority_fields(
        PolicyPriority, ClaimPriority, RecordPriority,
        PremisePriority, ObligationPriority, ContradictionPriority,
        ProvenancePriority),
    Status) :-
    shallow_policy_status(Policy, PolicyStatus),
    shallow_claim_status(Claim, ClaimStatus),
    shallow_semantic_records_status(Records, RecordStatus),
    shallow_premise_records_status(Premises, PremiseStatus),
    shallow_obligation_records_status(Obligations, ObligationStatus),
    shallow_contradiction_records_status(
        Contradictions, ContradictionStatus),
    shallow_provenance_records_status(Provenances, ProvenanceStatus),
    local_fixed_status(
        PolicyPriority, PolicyStatus, PolicyFixed),
    local_fixed_status(
        ClaimPriority, ClaimStatus, ClaimFixed),
    local_fixed_status(
        RecordPriority, RecordStatus, RecordFixed),
    local_fixed_status(
        PremisePriority, PremiseStatus, PremiseFixed),
    local_fixed_status(
        ObligationPriority, ObligationStatus, ObligationFixed),
    local_fixed_status(
        ContradictionPriority, ContradictionStatus,
        ContradictionFixed),
    local_fixed_status(
        ProvenancePriority, ProvenanceStatus, ProvenanceFixed),
    combine_preflight(PolicyFixed, ClaimFixed, Status01),
    combine_preflight(RecordFixed, PremiseFixed, Status23),
    combine_preflight(ObligationFixed, ContradictionFixed, Status45),
    combine_preflight(Status01, Status23, Status0123),
    combine_preflight(Status45, ProvenanceFixed, Status456),
    combine_preflight(Status0123, Status456, Status).

local_fixed_status(
    resource_limit_exceeded, _, resource_limit_exceeded).
local_fixed_status(ok, ShapeStatus, ShapeStatus).

shallow_policy_status(Policy, Status) :-
    shallow_functor_status(Policy, policy, 3, PolicyStatus),
    shallow_policy_fields_status(PolicyStatus, Policy, Status).

shallow_policy_fields_status(ok, Policy, Status) :-
    arg(1, Policy, PolicyId),
    arg(2, Policy, Kind),
    arg(3, Policy, ProvenanceId),
    shallow_functor_status(PolicyId, policy_id, 1, PolicyIdStatus),
    atom_token_status(Kind, 128, KindStatus),
    shallow_functor_status(
        ProvenanceId, provenance_id, 1, ProvenanceStatus),
    combine_preflight(PolicyIdStatus, KindStatus, First),
    combine_preflight(First, ProvenanceStatus, Status).
shallow_policy_fields_status(Status, _, Status) :-
    Status \== ok.

shallow_claim_status(Claim, Status) :-
    shallow_functor_status(Claim, claim, 6, ClaimStatus),
    shallow_claim_fields_status(ClaimStatus, Claim, Status).

shallow_claim_fields_status(ok, Claim, Status) :-
    arg(1, Claim, ClaimId),
    arg(2, Claim, Semantics),
    arg(3, Claim, Uses),
    arg(4, Claim, Requires),
    arg(5, Claim, Conflicts),
    arg(6, Claim, Lifecycle),
    shallow_functor_status(ClaimId, claim_id, 1, ClaimIdStatus),
    shallow_semantics_status(Semantics, SemanticsStatus),
    shallow_typed_id_collection_status(
        Uses, uses, premise_id, 8, UsesStatus),
    shallow_typed_id_collection_status(
        Requires, requires, obligation_id, 8, RequiresStatus),
    shallow_typed_id_collection_status(
        Conflicts, conflicts, contradiction_id, 8, ConflictsStatus),
    shallow_lifecycle_status(Lifecycle, LifecycleStatus),
    combine_preflight(ClaimIdStatus, SemanticsStatus, Status01),
    combine_preflight(UsesStatus, RequiresStatus, Status23),
    combine_preflight(Status01, Status23, Status0123),
    combine_preflight(ConflictsStatus, LifecycleStatus, Status45),
    combine_preflight(Status0123, Status45, Status).
shallow_claim_fields_status(Status, _, Status) :-
    Status \== ok.

shallow_semantics_status(Semantics, Status) :-
    shallow_functor_status(Semantics, semantics, 7, SemanticsStatus),
    shallow_semantics_fields_status(SemanticsStatus, Semantics, Status).

shallow_semantics_fields_status(ok, Semantics, Status) :-
    arg(1, Semantics, Signature),
    arg(2, Semantics, Definedness),
    arg(3, Semantics, Law),
    arg(4, Semantics, Termination),
    arg(5, Semantics, Cost),
    arg(6, Semantics, Effects),
    arg(7, Semantics, Provenance),
    shallow_unary_wrapped_status(
        Signature, signature, signature_id, SignatureStatus),
    shallow_unary_wrapped_status(
        Definedness, definedness, definition_space_id, DefinednessStatus),
    shallow_law_semantic_status(Law, LawStatus),
    shallow_unary_wrapped_status(
        Termination, termination, termination_id, TerminationStatus),
    shallow_unary_wrapped_status(Cost, cost, cost_id, CostStatus),
    shallow_unary_wrapped_status(
        Effects, effects, effects_id, EffectsStatus),
    shallow_unary_wrapped_status(
        Provenance, provenance, provenance_id, ProvenanceStatus),
    combine_preflight(SignatureStatus, DefinednessStatus, Status01),
    combine_preflight(LawStatus, TerminationStatus, Status23),
    combine_preflight(CostStatus, EffectsStatus, Status45),
    combine_preflight(Status01, Status23, Status0123),
    combine_preflight(Status45, ProvenanceStatus, Status456),
    combine_preflight(Status0123, Status456, Status).
shallow_semantics_fields_status(Status, _, Status) :-
    Status \== ok.

shallow_unary_wrapped_status(Term, OuterName, InnerName, Status) :-
    shallow_functor_status(Term, OuterName, 1, OuterStatus),
    shallow_unary_inner_status(OuterStatus, Term, InnerName, Status).

shallow_unary_inner_status(ok, Term, InnerName, Status) :-
    arg(1, Term, Inner),
    shallow_functor_status(Inner, InnerName, 1, Status).
shallow_unary_inner_status(Status, _, _, Status) :-
    Status \== ok.

shallow_law_semantic_status(Law, Status) :-
    shallow_functor_status(Law, law, 2, LawStatus),
    shallow_law_semantic_fields_status(LawStatus, Law, Status).

shallow_law_semantic_fields_status(ok, Law, Status) :-
    arg(1, Law, LawId),
    arg(2, Law, Equality),
    shallow_functor_status(LawId, law_id, 1, LawIdStatus),
    shallow_unary_wrapped_status(
        Equality, equality, equality_id, EqualityStatus),
    combine_preflight(LawIdStatus, EqualityStatus, Status).
shallow_law_semantic_fields_status(Status, _, Status) :-
    Status \== ok.

shallow_lifecycle_status(Lifecycle, non_ground_input) :-
    var(Lifecycle).
shallow_lifecycle_status(missing, ok).
shallow_lifecycle_status(Lifecycle, Status) :-
    nonvar(Lifecycle),
    Lifecycle \== missing,
    (   functor(Lifecycle, current, 1)
    ->  arg(1, Lifecycle, Provenance),
        shallow_functor_status(
            Provenance, provenance_id, 1, Status)
    ;   functor(Lifecycle, retracted, 1)
    ->  arg(1, Lifecycle, Provenance),
        shallow_functor_status(
            Provenance, provenance_id, 1, Status)
    ;   Status = malformed_shape
    ).

shallow_functor_status(Term, _, _, non_ground_input) :-
    var(Term).
shallow_functor_status(Term, Name, Arity, Status) :-
    nonvar(Term),
    (   functor(Term, Name, Arity)
    ->  shallow_functor_payload_status(
            Term, Name, Arity, Status)
    ;   Status = malformed_shape
    ).

shallow_functor_payload_status(Term, Name, 1, Status) :-
    shallow_scalar_limit(Name, Maximum),
    arg(1, Term, Scalar),
    atom_token_status(Scalar, Maximum, Status).
shallow_functor_payload_status(_, Name, Arity, ok) :-
    \+ (Arity =:= 1, shallow_scalar_limit(Name, _)).

shallow_scalar_limit(policy_id, 64).
shallow_scalar_limit(claim_id, 64).
shallow_scalar_limit(signature_id, 64).
shallow_scalar_limit(definition_space_id, 64).
shallow_scalar_limit(law_id, 64).
shallow_scalar_limit(equality_id, 64).
shallow_scalar_limit(termination_id, 64).
shallow_scalar_limit(cost_id, 64).
shallow_scalar_limit(effects_id, 64).
shallow_scalar_limit(premise_id, 64).
shallow_scalar_limit(obligation_id, 64).
shallow_scalar_limit(contradiction_id, 64).
shallow_scalar_limit(provenance_id, 64).
shallow_scalar_limit(descriptor, 128).
shallow_scalar_limit(relation, 128).
shallow_scalar_limit(measure, 128).
shallow_scalar_limit(operation_count, 128).
shallow_scalar_limit(conditions, 128).

shallow_list_status(Term, non_ground_input) :-
    var(Term).
shallow_list_status([], ok).
shallow_list_status(Term, Status) :-
    nonvar(Term),
    Term \== [],
    (   Term = [_|_]
    ->  Status = ok
    ;   Status = malformed_shape
    ).

shallow_typed_id_collection_status(
    Collection, CollectionFunctor, IdFunctor, Maximum, Status) :-
    shallow_functor_status(
        Collection, CollectionFunctor, 1, CollectionStatus),
    shallow_typed_id_collection_fields_status(
        CollectionStatus, Collection, IdFunctor, Maximum, Status).

shallow_typed_id_collection_fields_status(
    ok, Collection, IdFunctor, Maximum, Status) :-
    arg(1, Collection, Ids),
    shallow_typed_id_entries_status(
        Ids, IdFunctor, Maximum, 0, Status).
shallow_typed_id_collection_fields_status(
    Status, _, _, _, Status) :-
    Status \== ok.

shallow_typed_id_entries_status([], _, _, _, ok).
shallow_typed_id_entries_status([_|_], _, Maximum, Count, ok) :-
    Count >= Maximum.
shallow_typed_id_entries_status(
    [Id|Tail], IdFunctor, Maximum, Count, Status) :-
    Count < Maximum,
    shallow_functor_status(Id, IdFunctor, 1, IdStatus),
    Next is Count + 1,
    shallow_typed_id_entries_status(
        Tail, IdFunctor, Maximum, Next, TailStatus),
    combine_preflight(IdStatus, TailStatus, Status).
shallow_typed_id_entries_status(Term, _, _, _, malformed_shape) :-
    Term \== [],
    Term \= [_|_].

shallow_semantic_records_status(
    semantic_records(Signature, Definition, Law, Equality,
                     Termination, Cost, Effects),
    Status) :-
    shallow_signature_record_status(Signature, SignatureStatus),
    shallow_definition_record_status(Definition, DefinitionStatus),
    shallow_law_record_status(Law, LawStatus),
    shallow_equality_record_status(Equality, EqualityStatus),
    shallow_termination_record_status(Termination, TerminationStatus),
    shallow_cost_record_status(Cost, CostStatus),
    shallow_effects_record_status(Effects, EffectsStatus),
    combine_preflight(SignatureStatus, DefinitionStatus, Status01),
    combine_preflight(LawStatus, EqualityStatus, Status23),
    combine_preflight(TerminationStatus, CostStatus, Status45),
    combine_preflight(Status01, Status23, Status0123),
    combine_preflight(Status45, EffectsStatus, Status456),
    combine_preflight(Status0123, Status456, Status).
shallow_semantic_records_status(Term, malformed_shape) :-
    Term \= semantic_records(_, _, _, _, _, _, _).

shallow_signature_record_status(
    signature(Id, Descriptor, Disposition, RecordProv), Status) :-
    shallow_functor_status(Id, signature_id, 1, IdStatus),
    shallow_functor_status(
        Descriptor, descriptor, 1, DescriptorStatus),
    shallow_disposition_status(Disposition, DispositionStatus),
    shallow_functor_status(
        RecordProv, provenance_id, 1, RecordProvenanceStatus),
    combine_preflight(IdStatus, DescriptorStatus, Status01),
    combine_preflight(
        DispositionStatus, RecordProvenanceStatus, Status23),
    combine_preflight(Status01, Status23, Status).
shallow_signature_record_status(Term, malformed_shape) :-
    Term \= signature(_, _, _, _).

shallow_definition_record_status(
    definition_space(Id, SignatureId, Descriptor,
                     Disposition, RecordProv),
    Status) :-
    shallow_functor_status(Id, definition_space_id, 1, IdStatus),
    shallow_functor_status(
        SignatureId, signature_id, 1, SignatureStatus),
    shallow_functor_status(
        Descriptor, descriptor, 1, DescriptorStatus),
    shallow_disposition_status(Disposition, DispositionStatus),
    shallow_functor_status(
        RecordProv, provenance_id, 1, RecordProvenanceStatus),
    combine_preflight(IdStatus, SignatureStatus, Status01),
    combine_preflight(DescriptorStatus, DispositionStatus, Status23),
    combine_preflight(Status01, Status23, Status0123),
    combine_preflight(
        Status0123, RecordProvenanceStatus, Status).
shallow_definition_record_status(Term, malformed_shape) :-
    Term \= definition_space(_, _, _, _, _).

shallow_law_record_status(
    law(Id, SignatureId, DefinitionId, EqualityId, Descriptor,
        Disposition, RecordProv),
    Status) :-
    shallow_functor_status(Id, law_id, 1, IdStatus),
    shallow_functor_status(
        SignatureId, signature_id, 1, SignatureStatus),
    shallow_functor_status(
        DefinitionId, definition_space_id, 1, DefinitionStatus),
    shallow_functor_status(
        EqualityId, equality_id, 1, EqualityStatus),
    shallow_functor_status(
        Descriptor, descriptor, 1, DescriptorStatus),
    shallow_disposition_status(Disposition, DispositionStatus),
    shallow_functor_status(
        RecordProv, provenance_id, 1, RecordProvenanceStatus),
    combine_preflight(IdStatus, SignatureStatus, Status01),
    combine_preflight(DefinitionStatus, EqualityStatus, Status23),
    combine_preflight(DescriptorStatus, DispositionStatus, Status45),
    combine_preflight(Status01, Status23, Status0123),
    combine_preflight(Status0123, Status45, Status0to5),
    combine_preflight(
        Status0to5, RecordProvenanceStatus, Status).
shallow_law_record_status(Term, malformed_shape) :-
    Term \= law(_, _, _, _, _, _, _).

shallow_equality_record_status(
    equality_relation(Id, SignatureId, DefinitionId, Relation,
                      Disposition, RecordProv),
    Status) :-
    shallow_functor_status(Id, equality_id, 1, IdStatus),
    shallow_functor_status(
        SignatureId, signature_id, 1, SignatureStatus),
    shallow_functor_status(
        DefinitionId, definition_space_id, 1, DefinitionStatus),
    shallow_functor_status(
        Relation, relation, 1, RelationStatus),
    shallow_disposition_status(Disposition, DispositionStatus),
    shallow_functor_status(
        RecordProv, provenance_id, 1, RecordProvenanceStatus),
    combine_preflight(IdStatus, SignatureStatus, Status01),
    combine_preflight(DefinitionStatus, RelationStatus, Status23),
    combine_preflight(Status01, Status23, Status0123),
    combine_preflight(
        Status0123, DispositionStatus, Status0to4),
    combine_preflight(
        Status0to4, RecordProvenanceStatus, Status).
shallow_equality_record_status(Term, malformed_shape) :-
    Term \= equality_relation(_, _, _, _, _, _).

shallow_termination_record_status(
    termination(Id, LawId, Measure, Disposition, RecordProv),
    Status) :-
    shallow_functor_status(Id, termination_id, 1, IdStatus),
    shallow_functor_status(LawId, law_id, 1, LawStatus),
    shallow_functor_status(Measure, measure, 1, MeasureStatus),
    shallow_disposition_status(Disposition, DispositionStatus),
    shallow_functor_status(
        RecordProv, provenance_id, 1, RecordProvenanceStatus),
    combine_preflight(IdStatus, LawStatus, Status01),
    combine_preflight(MeasureStatus, DispositionStatus, Status23),
    combine_preflight(Status01, Status23, Status0123),
    combine_preflight(
        Status0123, RecordProvenanceStatus, Status).
shallow_termination_record_status(Term, malformed_shape) :-
    Term \= termination(_, _, _, _, _).

shallow_cost_record_status(
    cost(Id, LawId, OperationCount, Disposition, RecordProv),
    Status) :-
    shallow_functor_status(Id, cost_id, 1, IdStatus),
    shallow_functor_status(LawId, law_id, 1, LawStatus),
    shallow_functor_status(
        OperationCount, operation_count, 1, OperationStatus),
    shallow_disposition_status(Disposition, DispositionStatus),
    shallow_functor_status(
        RecordProv, provenance_id, 1, RecordProvenanceStatus),
    combine_preflight(IdStatus, LawStatus, Status01),
    combine_preflight(OperationStatus, DispositionStatus, Status23),
    combine_preflight(Status01, Status23, Status0123),
    combine_preflight(
        Status0123, RecordProvenanceStatus, Status).
shallow_cost_record_status(Term, malformed_shape) :-
    Term \= cost(_, _, _, _, _).

shallow_effects_record_status(
    effects(Id, LawId, Conditions, Disposition, RecordProv),
    Status) :-
    shallow_functor_status(Id, effects_id, 1, IdStatus),
    shallow_functor_status(LawId, law_id, 1, LawStatus),
    shallow_functor_status(
        Conditions, conditions, 1, ConditionsStatus),
    shallow_disposition_status(Disposition, DispositionStatus),
    shallow_functor_status(
        RecordProv, provenance_id, 1, RecordProvenanceStatus),
    combine_preflight(IdStatus, LawStatus, Status01),
    combine_preflight(ConditionsStatus, DispositionStatus, Status23),
    combine_preflight(Status01, Status23, Status0123),
    combine_preflight(
        Status0123, RecordProvenanceStatus, Status).
shallow_effects_record_status(Term, malformed_shape) :-
    Term \= effects(_, _, _, _, _).

shallow_disposition_status(accepted(Prov), Status) :-
    shallow_functor_status(Prov, provenance_id, 1, Status).
shallow_disposition_status(rejected(Prov), Status) :-
    shallow_functor_status(Prov, provenance_id, 1, Status).
shallow_disposition_status(missing, ok).
shallow_disposition_status(Term, malformed_shape) :-
    Term \= accepted(_),
    Term \= rejected(_),
    Term \== missing.

shallow_premise_records_status(Records, Status) :-
    shallow_premise_records_status(Records, 0, Status).

shallow_premise_records_status([], _, ok).
shallow_premise_records_status([_|_], Count, ok) :-
    Count >= 8.
shallow_premise_records_status([Record|Tail], Count, Status) :-
    Count < 8,
    shallow_premise_record_status(Record, RecordStatus),
    Next is Count + 1,
    shallow_premise_records_status(Tail, Next, TailStatus),
    combine_preflight(RecordStatus, TailStatus, Status).
shallow_premise_records_status(Term, _, malformed_shape) :-
    Term \== [],
    Term \= [_|_].

shallow_premise_record_status(
    premise(Id, Activation, Trust, RecordProv), Status) :-
    shallow_functor_status(Id, premise_id, 1, IdStatus),
    shallow_activation_status(Activation, ActivationStatus),
    shallow_trust_status(Trust, TrustStatus),
    shallow_functor_status(
        RecordProv, provenance_id, 1, RecordProvenanceStatus),
    combine_preflight(IdStatus, ActivationStatus, Status01),
    combine_preflight(TrustStatus, RecordProvenanceStatus, Status23),
    combine_preflight(Status01, Status23, Status).
shallow_premise_record_status(Term, malformed_shape) :-
    Term \= premise(_, _, _, _).

shallow_activation_status(active(Prov), Status) :-
    shallow_functor_status(Prov, provenance_id, 1, Status).
shallow_activation_status(inactive(Prov), Status) :-
    shallow_functor_status(Prov, provenance_id, 1, Status).
shallow_activation_status(missing, ok).
shallow_activation_status(Term, malformed_shape) :-
    Term \= active(_),
    Term \= inactive(_),
    Term \== missing.

shallow_trust_status(trusted(PolicyId, Prov), Status) :-
    shallow_functor_status(PolicyId, policy_id, 1, PolicyStatus),
    shallow_functor_status(Prov, provenance_id, 1, ProvenanceStatus),
    combine_preflight(PolicyStatus, ProvenanceStatus, Status).
shallow_trust_status(untrusted(PolicyId, Prov), Status) :-
    shallow_functor_status(PolicyId, policy_id, 1, PolicyStatus),
    shallow_functor_status(Prov, provenance_id, 1, ProvenanceStatus),
    combine_preflight(PolicyStatus, ProvenanceStatus, Status).
shallow_trust_status(missing, ok).
shallow_trust_status(Term, malformed_shape) :-
    Term \= trusted(_, _),
    Term \= untrusted(_, _),
    Term \== missing.

shallow_obligation_records_status(Records, Status) :-
    shallow_obligation_records_status(Records, 0, Status).

shallow_obligation_records_status([], _, ok).
shallow_obligation_records_status([_|_], Count, ok) :-
    Count >= 8.
shallow_obligation_records_status([Record|Tail], Count, Status) :-
    Count < 8,
    shallow_obligation_record_status(Record, RecordStatus),
    Next is Count + 1,
    shallow_obligation_records_status(Tail, Next, TailStatus),
    combine_preflight(RecordStatus, TailStatus, Status).
shallow_obligation_records_status(Term, _, malformed_shape) :-
    Term \== [],
    Term \= [_|_].

shallow_obligation_record_status(
    obligation(Id, LawId, Applicability, Disposition, RecordProv),
    Status) :-
    shallow_functor_status(Id, obligation_id, 1, IdStatus),
    shallow_functor_status(LawId, law_id, 1, LawStatus),
    shallow_applicability_status(Applicability, ApplicabilityStatus),
    shallow_obligation_disposition_status(
        Applicability, Disposition, DispositionStatus),
    shallow_functor_status(
        RecordProv, provenance_id, 1, RecordProvenanceStatus),
    combine_preflight(IdStatus, LawStatus, Status01),
    combine_preflight(
        ApplicabilityStatus, DispositionStatus, Status23),
    combine_preflight(Status01, Status23, Status0123),
    combine_preflight(
        Status0123, RecordProvenanceStatus, Status).
shallow_obligation_record_status(Term, malformed_shape) :-
    Term \= obligation(_, _, _, _, _).

shallow_applicability_status(applicable(Prov), Status) :-
    shallow_functor_status(Prov, provenance_id, 1, Status).
shallow_applicability_status(not_applicable(Prov), Status) :-
    shallow_functor_status(Prov, provenance_id, 1, Status).
shallow_applicability_status(missing, ok).
shallow_applicability_status(Term, malformed_shape) :-
    Term \= applicable(_),
    Term \= not_applicable(_),
    Term \== missing.

shallow_obligation_disposition_status(
    applicable(_), Disposition, Status) :-
    shallow_disposition_status(Disposition, Status).
shallow_obligation_disposition_status(
    not_applicable(_), not_applicable, ok).
shallow_obligation_disposition_status(missing, missing, ok).
shallow_obligation_disposition_status(_, _, malformed_shape).

shallow_contradiction_records_status(Records, Status) :-
    shallow_contradiction_records_status(Records, 0, Status).

shallow_contradiction_records_status([], _, ok).
shallow_contradiction_records_status([_|_], Count, ok) :-
    Count >= 8.
shallow_contradiction_records_status([Record|Tail], Count, Status) :-
    Count < 8,
    shallow_contradiction_record_status(Record, RecordStatus),
    Next is Count + 1,
    shallow_contradiction_records_status(Tail, Next, TailStatus),
    combine_preflight(RecordStatus, TailStatus, Status).
shallow_contradiction_records_status(Term, _, malformed_shape) :-
    Term \== [],
    Term \= [_|_].

shallow_contradiction_record_status(
    contradiction(Id, ClaimId, State, RecordProv), Status) :-
    shallow_functor_status(Id, contradiction_id, 1, IdStatus),
    shallow_functor_status(ClaimId, claim_id, 1, ClaimStatus),
    shallow_contradiction_state_status(State, StateStatus),
    shallow_functor_status(
        RecordProv, provenance_id, 1, RecordProvenanceStatus),
    combine_preflight(IdStatus, ClaimStatus, Status01),
    combine_preflight(StateStatus, RecordProvenanceStatus, Status23),
    combine_preflight(Status01, Status23, Status).
shallow_contradiction_record_status(Term, malformed_shape) :-
    Term \= contradiction(_, _, _, _).

shallow_contradiction_state_status(explicit(Prov), Status) :-
    shallow_functor_status(Prov, provenance_id, 1, Status).
shallow_contradiction_state_status(cleared(Prov), Status) :-
    shallow_functor_status(Prov, provenance_id, 1, Status).
shallow_contradiction_state_status(unresolved, ok).
shallow_contradiction_state_status(Term, malformed_shape) :-
    Term \= explicit(_),
    Term \= cleared(_),
    Term \== unresolved.

shallow_provenance_records_status(Records, Status) :-
    shallow_provenance_records_status(Records, 0, Status).

shallow_provenance_records_status([], _, ok).
shallow_provenance_records_status([_|_], Count, ok) :-
    Count >= 81.
shallow_provenance_records_status([Record|Tail], Count, Status) :-
    Count < 81,
    shallow_provenance_record_status(Record, RecordStatus),
    Next is Count + 1,
    shallow_provenance_records_status(Tail, Next, TailStatus),
    combine_preflight(RecordStatus, TailStatus, Status).
shallow_provenance_records_status(Term, _, malformed_shape) :-
    Term \== [],
    Term \= [_|_].

shallow_provenance_record_status(provenance(Id, _), Status) :-
    shallow_functor_status(Id, provenance_id, 1, Status).
shallow_provenance_record_status(Term, malformed_shape) :-
    Term \= provenance(_, _).

% Closed representation and shape validation

close_snapshot(Snapshot, Closure) :-
    (   snapshot_components(Snapshot, Data0)
    ->  data_shape_status(Data0, ShapeStatus),
        close_shaped(ShapeStatus, Data0, Closure)
    ;   Closure = rejected(malformed_shape)
    ).

close_shaped(ok, Data, Closure) :-
    structural_invariants(Data, Invariant),
    (   Invariant == ok
    ->  Closure = closed(Data)
    ;   Closure = rejected(Invariant)
    ).
close_shaped(Status, _, rejected(Status)) :-
    Status \== ok.

snapshot_components(
    authority_snapshot(
        policy(PolicyId, Kind, PolicyProv),
        claim(
            ClaimId,
            semantics(
                signature(SignatureId),
                definedness(DefinitionId),
                law(LawId, equality(EqualityId)),
                termination(TerminationId),
                cost(CostId),
                effects(EffectsId),
                provenance(ClaimProv)),
            uses(PremiseIds),
            requires(ObligationIds),
            conflicts(ContradictionIds),
            Lifecycle),
        semantic_records(
            signature(SignatureRecordId, descriptor(SignatureToken),
                      SignatureDisposition, SignatureProv),
            definition_space(DefinitionRecordId, DefinitionSignatureId,
                             descriptor(DefinitionToken),
                             DefinitionDisposition, DefinitionProv),
            law(LawRecordId, LawSignatureId, LawDefinitionId,
                LawEqualityId, descriptor(LawToken),
                LawDisposition, LawProv),
            equality_relation(EqualityRecordId, EqualitySignatureId,
                              EqualityDefinitionId,
                              relation(EqualityToken),
                              EqualityDisposition, EqualityProv),
            termination(TerminationRecordId, TerminationLawId,
                        measure(TerminationToken),
                        TerminationDisposition, TerminationProv),
            cost(CostRecordId, CostLawId, operation_count(CostToken),
                 CostDisposition, CostProv),
            effects(EffectsRecordId, EffectsLawId,
                    conditions(EffectsToken),
                    EffectsDisposition, EffectsProv)),
        Premises,
        Obligations,
        Contradictions,
        Provenances),
    data(
        policy_data(PolicyId, Kind, PolicyProv),
        claim_data(ClaimId, SignatureId, DefinitionId, LawId, EqualityId,
                   TerminationId, CostId, EffectsId, ClaimProv,
                   PremiseIds, ObligationIds, ContradictionIds, Lifecycle),
        semantic_data(
            semantic(signature, SignatureRecordId, SignatureDisposition,
                     SignatureProv,
                     refs([]), token(SignatureToken)),
            semantic(definedness, DefinitionRecordId,
                     DefinitionDisposition, DefinitionProv,
                     refs([signature-DefinitionSignatureId]),
                     token(DefinitionToken)),
            semantic(law, LawRecordId, LawDisposition, LawProv,
                     refs([signature-LawSignatureId,
                           definedness-LawDefinitionId,
                           equality-LawEqualityId]),
                     token(LawToken)),
            semantic(equality, EqualityRecordId, EqualityDisposition,
                     EqualityProv,
                     refs([signature-EqualitySignatureId,
                           definedness-EqualityDefinitionId]),
                     token(EqualityToken)),
            semantic(termination, TerminationRecordId,
                     TerminationDisposition, TerminationProv,
                     refs([law-TerminationLawId]),
                     token(TerminationToken)),
            semantic(cost, CostRecordId, CostDisposition, CostProv,
                     refs([law-CostLawId]), token(CostToken)),
            semantic(effects, EffectsRecordId, EffectsDisposition,
                     EffectsProv, refs([law-EffectsLawId]),
                     token(EffectsToken))),
        Premises,
        Obligations,
        Contradictions,
        Provenances)).

data_shape_status(
    data(Policy, Claim, Semantics, Premises, Obligations,
         Contradictions, Provenances),
    Status) :-
    policy_shape_status(Policy, PolicyStatus),
    claim_shape_status(Claim, ClaimStatus),
    semantics_shape_status(Semantics, SemanticStatus),
    list_limit_status(Premises, 8, PremiseListStatus),
    list_limit_status(Obligations, 8, ObligationListStatus),
    list_limit_status(Contradictions, 8, ContradictionListStatus),
    list_limit_status(Provenances, 81, ProvenanceListStatus),
    premise_records_status(Premises, 0, PremiseStatus),
    obligation_records_status(Obligations, 0, ObligationStatus),
    contradiction_records_status(
        Contradictions, 0, ContradictionStatus),
    provenance_records_status(Provenances, 0, ProvenanceStatus),
    combine_shape(PolicyStatus, ClaimStatus, Status01),
    combine_shape(SemanticStatus, PremiseListStatus, Status23),
    combine_shape(ObligationListStatus, ContradictionListStatus, Status45),
    combine_shape(ProvenanceListStatus, PremiseStatus, Status67),
    combine_shape(ObligationStatus, ContradictionStatus, Status89),
    combine_shape(Status01, Status23, Status0123),
    combine_shape(Status45, Status67, Status4567),
    combine_shape(Status89, ProvenanceStatus, Status8910),
    combine_shape(Status0123, Status4567, Status0to7),
    combine_shape(Status0to7, Status8910, Status).

combine_shape(malformed_shape, _, malformed_shape).
combine_shape(_, malformed_shape, malformed_shape).
combine_shape(resource_limit_exceeded, _, resource_limit_exceeded).
combine_shape(_, resource_limit_exceeded, resource_limit_exceeded).
combine_shape(ok, ok, ok).

list_limit_status(List, Maximum, Status) :-
    list_limit_status(List, Maximum, 0, Status).

list_limit_status([], _, _, ok).
list_limit_status([_|Tail], Maximum, Count, Status) :-
    (   Count >= Maximum
    ->  Status = resource_limit_exceeded
    ;   Next is Count + 1,
        list_limit_status(Tail, Maximum, Next, Status)
    ).
list_limit_status(Term, _, _, malformed_shape) :-
    Term \== [],
    Term \= [_|_].

list_length_bounded(List, Maximum, Status) :-
    list_limit_status(List, Maximum, Status).

policy_shape_status(policy_data(PolicyId, Kind, PolicyProv), Status) :-
    id_status(PolicyId, policy_id, PolicyStatus),
    id_status(PolicyProv, provenance_id, ProvenanceStatus),
    atom_token_status(Kind, 128, KindStatus),
    combine_shape(PolicyStatus, ProvenanceStatus, First),
    combine_shape(First, KindStatus, Status).

claim_shape_status(
    claim_data(ClaimId, SignatureId, DefinitionId, LawId, EqualityId,
               TerminationId, CostId, EffectsId, ClaimProv,
               PremiseIds, ObligationIds, ContradictionIds, Lifecycle),
    Status) :-
    id_status(ClaimId, claim_id, ClaimStatus),
    id_status(SignatureId, signature_id, SignatureStatus),
    id_status(DefinitionId, definition_space_id, DefinitionStatus),
    id_status(LawId, law_id, LawStatus),
    id_status(EqualityId, equality_id, EqualityStatus),
    id_status(TerminationId, termination_id, TerminationStatus),
    id_status(CostId, cost_id, CostStatus),
    id_status(EffectsId, effects_id, EffectsStatus),
    id_status(ClaimProv, provenance_id, ClaimProvStatus),
    typed_id_list_status(PremiseIds, premise_id, 8, PremiseStatus),
    typed_id_list_status(ObligationIds, obligation_id, 8, ObligationStatus),
    typed_id_list_status(
        ContradictionIds, contradiction_id, 8, ContradictionStatus),
    lifecycle_status(Lifecycle, LifecycleStatus),
    combine_shape(ClaimStatus, SignatureStatus, Status01),
    combine_shape(DefinitionStatus, LawStatus, Status23),
    combine_shape(EqualityStatus, TerminationStatus, Status45),
    combine_shape(CostStatus, EffectsStatus, Status67),
    combine_shape(ClaimProvStatus, PremiseStatus, Status89),
    combine_shape(ObligationStatus, ContradictionStatus, Status1011),
    combine_shape(Status01, Status23, Status0123),
    combine_shape(Status45, Status67, Status4567),
    combine_shape(Status89, Status1011, Status8to11),
    combine_shape(Status0123, Status4567, Status0to7),
    combine_shape(Status0to7, Status8to11, Status0to11),
    combine_shape(Status0to11, LifecycleStatus, Status).

typed_id_list_status(List, Functor, Maximum, Status) :-
    list_limit_status(List, Maximum, ListStatus),
    typed_id_entries_status(
        List, Functor, Maximum, 0, EntryStatus),
    combine_shape(ListStatus, EntryStatus, Status).

typed_id_entries_status([], _, _, _, ok).
typed_id_entries_status([Head|Tail], Functor, Maximum, Count, Status) :-
    (   Count >= Maximum
    ->  Status = resource_limit_exceeded
    ;   id_status(Head, Functor, HeadStatus),
        Next is Count + 1,
        typed_id_entries_status(
            Tail, Functor, Maximum, Next, TailStatus),
        combine_shape(HeadStatus, TailStatus, Status)
    ).
typed_id_entries_status(Term, _, _, _, malformed_shape) :-
    Term \== [],
    Term \= [_|_].

id_status(Term, Functor, Status) :-
    (   nonvar(Term),
        functor(Term, Functor, 1)
    ->  arg(1, Term, Atom),
        atom_token_status(Atom, 64, Status)
    ;   Status = malformed_shape
    ).

atom_token_status(Token, Maximum, Status) :-
    (   atom(Token),
        Token \== ''
    ->  (   sub_atom(Token, Maximum, 1, _, _Character)
        ->  Status = resource_limit_exceeded
        ;   Status = ok
        )
    ;   Status = malformed_shape
    ).

lifecycle_status(current(Prov), Status) :-
    id_status(Prov, provenance_id, Status).
lifecycle_status(retracted(Prov), Status) :-
    id_status(Prov, provenance_id, Status).
lifecycle_status(missing, ok).
lifecycle_status(Term, malformed_shape) :-
    Term \= current(_),
    Term \= retracted(_),
    Term \== missing.

semantics_shape_status(
    semantic_data(Signature, Definition, Law, Equality,
                  Termination, Cost, Effects),
    Status) :-
    semantic_status(Signature, signature_id, SignatureStatus),
    semantic_status(Definition, definition_space_id, DefinitionStatus),
    semantic_status(Law, law_id, LawStatus),
    semantic_status(Equality, equality_id, EqualityStatus),
    semantic_status(Termination, termination_id, TerminationStatus),
    semantic_status(Cost, cost_id, CostStatus),
    semantic_status(Effects, effects_id, EffectsStatus),
    combine_shape(SignatureStatus, DefinitionStatus, Status01),
    combine_shape(LawStatus, EqualityStatus, Status23),
    combine_shape(TerminationStatus, CostStatus, Status45),
    combine_shape(Status01, Status23, Status0123),
    combine_shape(Status45, EffectsStatus, Status456),
    combine_shape(Status0123, Status456, Status).

semantic_status(
    semantic(_, Id, Disposition, RecordProv, refs(Refs), token(Token)),
    IdFunctor,
    Status) :-
    id_status(Id, IdFunctor, IdStatus),
    disposition_status(Disposition, DispositionStatus),
    id_status(RecordProv, provenance_id, RecordProvStatus),
    semantic_refs_shape_status(Refs, RefStatus),
    atom_token_status(Token, 128, TokenStatus),
    combine_shape(IdStatus, DispositionStatus, Status01),
    combine_shape(RecordProvStatus, RefStatus, Status23),
    combine_shape(Status01, Status23, Status0123),
    combine_shape(Status0123, TokenStatus, Status).

semantic_refs_shape_status([], ok).
semantic_refs_shape_status([Type-Id|Tail], Status) :-
    reference_id_functor(Type, Functor),
    id_status(Id, Functor, IdStatus),
    semantic_refs_shape_status(Tail, TailStatus),
    combine_shape(IdStatus, TailStatus, Status).

reference_id_functor(signature, signature_id).
reference_id_functor(definedness, definition_space_id).
reference_id_functor(law, law_id).
reference_id_functor(equality, equality_id).

disposition_status(accepted(Prov), Status) :-
    id_status(Prov, provenance_id, Status).
disposition_status(rejected(Prov), Status) :-
    id_status(Prov, provenance_id, Status).
disposition_status(missing, ok).
disposition_status(Term, malformed_shape) :-
    Term \= accepted(_),
    Term \= rejected(_),
    Term \== missing.

premise_records_status([], _, ok).
premise_records_status([Record|Tail], Count, Status) :-
    (   Count >= 8
    ->  Status = resource_limit_exceeded
    ;   premise_record_status(Record, RecordStatus),
        Next is Count + 1,
        premise_records_status(Tail, Next, TailStatus),
        combine_shape(RecordStatus, TailStatus, Status)
    ).
premise_records_status(Term, _, malformed_shape) :-
    Term \== [],
    Term \= [_|_].

premise_record_status(
    premise(Id, Activation, Trust, RecordProv), Status) :-
    id_status(Id, premise_id, IdStatus),
    activation_status(Activation, ActivationStatus),
    trust_status(Trust, TrustStatus),
    id_status(RecordProv, provenance_id, RecordStatus),
    combine_shape(IdStatus, ActivationStatus, First),
    combine_shape(TrustStatus, RecordStatus, Second),
    combine_shape(First, Second, Status).
premise_record_status(Term, malformed_shape) :-
    Term \= premise(_, _, _, _).

activation_status(active(Prov), Status) :-
    id_status(Prov, provenance_id, Status).
activation_status(inactive(Prov), Status) :-
    id_status(Prov, provenance_id, Status).
activation_status(missing, ok).
activation_status(Term, malformed_shape) :-
    Term \= active(_),
    Term \= inactive(_),
    Term \== missing.

trust_status(trusted(PolicyId, Prov), Status) :-
    id_status(PolicyId, policy_id, PolicyStatus),
    id_status(Prov, provenance_id, ProvenanceStatus),
    combine_shape(PolicyStatus, ProvenanceStatus, Status).
trust_status(untrusted(PolicyId, Prov), Status) :-
    id_status(PolicyId, policy_id, PolicyStatus),
    id_status(Prov, provenance_id, ProvenanceStatus),
    combine_shape(PolicyStatus, ProvenanceStatus, Status).
trust_status(missing, ok).
trust_status(Term, malformed_shape) :-
    Term \= trusted(_, _),
    Term \= untrusted(_, _),
    Term \== missing.

obligation_records_status([], _, ok).
obligation_records_status([Record|Tail], Count, Status) :-
    (   Count >= 8
    ->  Status = resource_limit_exceeded
    ;   obligation_record_status(Record, RecordStatus),
        Next is Count + 1,
        obligation_records_status(Tail, Next, TailStatus),
        combine_shape(RecordStatus, TailStatus, Status)
    ).
obligation_records_status(Term, _, malformed_shape) :-
    Term \== [],
    Term \= [_|_].

obligation_record_status(
    obligation(Id, LawId, Applicability, Disposition, RecordProv),
    Status) :-
    id_status(Id, obligation_id, IdStatus),
    id_status(LawId, law_id, LawStatus),
    applicability_status(Applicability, ApplicabilityStatus),
    obligation_disposition_status(
        Applicability, Disposition, DispositionStatus),
    id_status(RecordProv, provenance_id, RecordStatus),
    combine_shape(IdStatus, LawStatus, Status01),
    combine_shape(ApplicabilityStatus, DispositionStatus, Status23),
    combine_shape(Status01, Status23, Status0123),
    combine_shape(Status0123, RecordStatus, Status).
obligation_record_status(Term, malformed_shape) :-
    Term \= obligation(_, _, _, _, _).

applicability_status(applicable(Prov), Status) :-
    id_status(Prov, provenance_id, Status).
applicability_status(not_applicable(Prov), Status) :-
    id_status(Prov, provenance_id, Status).
applicability_status(missing, ok).
applicability_status(Term, malformed_shape) :-
    Term \= applicable(_),
    Term \= not_applicable(_),
    Term \== missing.

obligation_disposition_status(applicable(_), Disposition, Status) :-
    disposition_status(Disposition, Initial),
    (   Disposition == missing
    ;   Disposition = accepted(_)
    ;   Disposition = rejected(_)
    ),
    Status = Initial.
obligation_disposition_status(not_applicable(_), not_applicable, ok).
obligation_disposition_status(missing, missing, ok).
obligation_disposition_status(_, _, malformed_shape).

contradiction_records_status([], _, ok).
contradiction_records_status([Record|Tail], Count, Status) :-
    (   Count >= 8
    ->  Status = resource_limit_exceeded
    ;   contradiction_record_status(Record, RecordStatus),
        Next is Count + 1,
        contradiction_records_status(Tail, Next, TailStatus),
        combine_shape(RecordStatus, TailStatus, Status)
    ).
contradiction_records_status(Term, _, malformed_shape) :-
    Term \== [],
    Term \= [_|_].

contradiction_record_status(
    contradiction(Id, ClaimId, State, RecordProv), Status) :-
    id_status(Id, contradiction_id, IdStatus),
    id_status(ClaimId, claim_id, ClaimStatus),
    contradiction_state_status(State, StateStatus),
    id_status(RecordProv, provenance_id, RecordStatus),
    combine_shape(IdStatus, ClaimStatus, First),
    combine_shape(StateStatus, RecordStatus, Second),
    combine_shape(First, Second, Status).
contradiction_record_status(Term, malformed_shape) :-
    Term \= contradiction(_, _, _, _).

contradiction_state_status(explicit(Prov), Status) :-
    id_status(Prov, provenance_id, Status).
contradiction_state_status(cleared(Prov), Status) :-
    id_status(Prov, provenance_id, Status).
contradiction_state_status(unresolved, ok).
contradiction_state_status(Term, malformed_shape) :-
    Term \= explicit(_),
    Term \= cleared(_),
    Term \== unresolved.

provenance_records_status([], _, ok).
provenance_records_status([Record|Tail], Count, Status) :-
    (   Count >= 81
    ->  Status = resource_limit_exceeded
    ;   provenance_record_status(Record, RecordStatus),
        Next is Count + 1,
        provenance_records_status(Tail, Next, TailStatus),
        combine_shape(RecordStatus, TailStatus, Status)
    ).
provenance_records_status(Term, _, malformed_shape) :-
    Term \== [],
    Term \= [_|_].

provenance_record_status(provenance(Id, _Evidence), Status) :-
    id_status(Id, provenance_id, Status).
provenance_record_status(Term, malformed_shape) :-
    Term \= provenance(_, _).

% Identifier, reference, policy, and provenance closure

structural_invariants(Data, Status) :-
    duplicate_invariant(Data, DuplicateStatus),
    (   DuplicateStatus \== ok
    ->  Status = DuplicateStatus
    ;   dangling_invariant(Data, DanglingStatus),
        (   DanglingStatus \== ok
        ->  Status = DanglingStatus
        ;   extra_invariant(Data, ExtraStatus),
            (   ExtraStatus \== ok
            ->  Status = ExtraStatus
            ;   reference_invariant(Data, ReferenceStatus),
                (   ReferenceStatus \== ok
                ->  Status = ReferenceStatus
                ;   equality_invariant(Data, EqualityStatus),
                    (   EqualityStatus \== ok
                    ->  Status = EqualityStatus
                    ;   policy_invariant(Data, Status)
                    )
                )
            )
        )
    ).

duplicate_invariant(Data, Status) :-
    data_claim_lists(Data, PremiseIds, ObligationIds, ContradictionIds),
    data_record_ids(Data, PremiseRecordIds, ObligationRecordIds,
                    ContradictionRecordIds, ProvenanceRecordIds),
    first_duplicate(PremiseIds, PremiseDuplicate),
    first_duplicate(ObligationIds, ObligationDuplicate),
    first_duplicate(ContradictionIds, ContradictionDuplicate),
    first_duplicate(PremiseRecordIds, PremiseRecordDuplicate),
    first_duplicate(ObligationRecordIds, ObligationRecordDuplicate),
    first_duplicate(
        ContradictionRecordIds, ContradictionRecordDuplicate),
    first_duplicate(ProvenanceRecordIds, ProvenanceDuplicate),
    duplicate_priority(
        [premise-PremiseDuplicate,
         obligation-ObligationDuplicate,
         contradiction-ContradictionDuplicate,
         premise-PremiseRecordDuplicate,
         obligation-ObligationRecordDuplicate,
         contradiction-ContradictionRecordDuplicate,
         provenance-ProvenanceDuplicate],
        Status).

first_duplicate(List, Duplicate) :-
    first_duplicate(List, [], Duplicate).

first_duplicate([], _, none).
first_duplicate([Head|Tail], Seen, Duplicate) :-
    (   identity_member(Head, Seen)
    ->  Duplicate = some(Head)
    ;   first_duplicate(Tail, [Head|Seen], Duplicate)
    ).

duplicate_priority([], ok).
duplicate_priority([Type-some(Id)|_],
                   duplicate_identifier(Type, Id)).
duplicate_priority([_-none|Tail], Status) :-
    duplicate_priority(Tail, Status).

dangling_invariant(Data, Status) :-
    semantic_dangling_status(Data, SemanticStatus),
    (   SemanticStatus \== ok
    ->  Status = SemanticStatus
    ;   data_claim_lists(Data, PremiseIds, ObligationIds, ContradictionIds),
        data_record_ids(Data, PremiseRecordIds, ObligationRecordIds,
                        ContradictionRecordIds, _),
        first_absent(PremiseIds, PremiseRecordIds, PremiseMissing),
        first_absent(ObligationIds, ObligationRecordIds, ObligationMissing),
        first_absent(
            ContradictionIds, ContradictionRecordIds, ContradictionMissing),
        provenance_first_use(Data, UsedProvenanceIds),
        data_provenance_ids(Data, ProvenanceRecordIds),
        first_absent(
            UsedProvenanceIds, ProvenanceRecordIds, ProvenanceMissing),
        missing_priority(
            [premise-PremiseMissing,
             obligation-ObligationMissing,
             contradiction-ContradictionMissing,
             provenance-ProvenanceMissing],
            dangling_reference,
            Status)
    ).

semantic_dangling_status(
    data(
        _,
        claim_data(_, SignatureExpected, DefinitionExpected, LawExpected,
                   EqualityExpected, TerminationExpected, CostExpected,
                   EffectsExpected, _, _, _, _, _),
        semantic_data(
            semantic(signature, SignatureActual, _, _, _, _),
            semantic(definedness, DefinitionActual, _, _, _, _),
            semantic(law, LawActual, _, _, _, _),
            semantic(equality, EqualityActual, _, _, _, _),
            semantic(termination, TerminationActual, _, _, _, _),
            semantic(cost, CostActual, _, _, _, _),
            semantic(effects, EffectsActual, _, _, _, _)),
        _, _, _, _),
    Status) :-
    first_semantic_absence(
        [identity(signature, SignatureExpected, SignatureActual),
         identity(definedness, DefinitionExpected, DefinitionActual),
         identity(law, LawExpected, LawActual),
         identity(equality, EqualityExpected, EqualityActual),
         identity(termination, TerminationExpected, TerminationActual),
         identity(cost, CostExpected, CostActual),
         identity(effects, EffectsExpected, EffectsActual)],
        Status).

first_semantic_absence([], ok).
first_semantic_absence(
    [identity(_, Expected, Actual)|Tail], Status) :-
    Expected == Actual,
    first_semantic_absence(Tail, Status).
first_semantic_absence(
    [identity(Type, Expected, Actual)|_],
    dangling_reference(Type, Expected)) :-
    Expected \== Actual.

extra_invariant(Data, Status) :-
    data_claim_lists(Data, PremiseIds, ObligationIds, ContradictionIds),
    data_record_ids(Data, PremiseRecordIds, ObligationRecordIds,
                    ContradictionRecordIds, _),
    first_absent(PremiseRecordIds, PremiseIds, PremiseExtra),
    first_absent(ObligationRecordIds, ObligationIds, ObligationExtra),
    first_absent(
        ContradictionRecordIds, ContradictionIds, ContradictionExtra),
    provenance_first_use(Data, UsedProvenanceIds),
    data_provenance_ids(Data, ProvenanceRecordIds),
    first_absent(ProvenanceRecordIds, UsedProvenanceIds, ProvenanceExtra),
    missing_priority(
        [premise-PremiseExtra,
         obligation-ObligationExtra,
         contradiction-ContradictionExtra,
         provenance-ProvenanceExtra],
        extra_record,
        Status).

first_absent([], _, none).
first_absent([Head|Tail], Available, Result) :-
    (   identity_member(Head, Available)
    ->  first_absent(Tail, Available, Result)
    ;   Result = some(Head)
    ).

missing_priority([], _, ok).
missing_priority([Type-some(Id)|_], dangling_reference,
                 dangling_reference(Type, Id)).
missing_priority([Type-some(Id)|_], extra_record,
                 extra_record(Type, Id)).
missing_priority([_-none|Tail], Functor, Status) :-
    missing_priority(Tail, Functor, Status).

reference_invariant(Data, Status) :-
    Data = data(
        policy_data(PolicyId, _, _),
        claim_data(ClaimId, SignatureId, DefinitionId, LawId, EqualityId,
                   TerminationId, CostId, EffectsId, _, PremiseIds,
                   ObligationIds,
                   ContradictionIds, _),
        Semantics, Premises, Obligations, Contradictions, _),
    semantic_primary_references(
        Semantics, SignatureId, DefinitionId, LawId, EqualityId,
        TerminationId, CostId, EffectsId, PrimaryStatus),
    semantic_secondary_references(
        Semantics, SignatureId, DefinitionId, LawId, SecondaryStatus),
    list_order_status(
        premise, PremiseIds, Premises, premise_record_id, PremiseOrder),
    list_order_status(
        obligation, ObligationIds, Obligations,
        obligation_record_id, ObligationOrder),
    list_order_status(
        contradiction, ContradictionIds, Contradictions,
        contradiction_record_id, ContradictionOrder),
    premise_policy_references(Premises, PolicyId, PolicyStatus),
    obligation_law_references(Obligations, LawId, ObligationLawStatus),
    contradiction_claim_references(
        Contradictions, ClaimId, ContradictionClaimStatus),
    first_non_ok(
        [PrimaryStatus, SecondaryStatus, PremiseOrder, ObligationOrder,
         ContradictionOrder, PolicyStatus, ObligationLawStatus,
         ContradictionClaimStatus],
        Status).

semantic_primary_references(
    semantic_data(
        semantic(signature, SignatureActual, _, _, _, _),
        semantic(definedness, DefinitionActual, _, _, _, _),
        semantic(law, LawActual, _, _, _, _),
        semantic(equality, EqualityActual, _, _, _, _),
        semantic(termination, TerminationActual, _, _, _, _),
        semantic(cost, CostActual, _, _, _, _),
        semantic(effects, EffectsActual, _, _, _, _)),
    SignatureExpected, DefinitionExpected, LawExpected,
    EqualityExpected, TerminationExpected, CostExpected,
    EffectsExpected, Status) :-
    reference_match(
        signature, SignatureExpected, SignatureActual, SignatureStatus),
    reference_match(
        definedness, DefinitionExpected, DefinitionActual, DefinitionStatus),
    reference_match(law, LawExpected, LawActual, LawStatus),
    reference_match(
        equality, EqualityExpected, EqualityActual, EqualityStatus),
    reference_match(
        termination, TerminationExpected, TerminationActual,
        TerminationStatus),
    reference_match(cost, CostExpected, CostActual, CostStatus),
    reference_match(effects, EffectsExpected, EffectsActual, EffectsStatus),
    first_non_ok(
        [SignatureStatus, DefinitionStatus, LawStatus, EqualityStatus,
         TerminationStatus, CostStatus, EffectsStatus],
        Status).

semantic_secondary_references(
    semantic_data(
        _,
        semantic(definedness, _, _, _,
                 refs([signature-DefinitionSignature]), _),
        semantic(law, _, _, _,
                 refs([signature-LawSignature,
                       definedness-LawDefinition,
                       equality-_]), _),
        semantic(equality, _, _, _,
                 refs([signature-EqualitySignature,
                       definedness-EqualityDefinition]), _),
        semantic(termination, _, _, _,
                 refs([law-TerminationLaw]), _),
        semantic(cost, _, _, _, refs([law-CostLaw]), _),
        semantic(effects, _, _, _, refs([law-EffectsLaw]), _)),
    SignatureId, DefinitionId, LawId, Status) :-
    reference_match(
        signature, SignatureId, DefinitionSignature, Status1),
    reference_match(signature, SignatureId, LawSignature, Status2),
    reference_match(definedness, DefinitionId, LawDefinition, Status3),
    reference_match(signature, SignatureId, EqualitySignature, Status4),
    reference_match(
        definedness, DefinitionId, EqualityDefinition, Status5),
    reference_match(law, LawId, TerminationLaw, Status6),
    reference_match(law, LawId, CostLaw, Status7),
    reference_match(law, LawId, EffectsLaw, Status8),
    first_non_ok(
        [Status1, Status2, Status3, Status4,
         Status5, Status6, Status7, Status8],
        Status).

reference_match(_, Expected, Actual, ok) :-
    Expected == Actual.
reference_match(Type, Expected, Actual,
                reference_mismatch(Type, Expected, Actual)) :-
    Expected \== Actual.

list_order_status(_, [], [], _, ok).
list_order_status(Type, [Expected|ExpectedTail], [Record|RecordTail],
                  Selector, Status) :-
    record_identifier(Selector, Record, Actual),
    reference_match(Type, Expected, Actual, HeadStatus),
    (   HeadStatus == ok
    ->  list_order_status(
            Type, ExpectedTail, RecordTail, Selector, Status)
    ;   Status = HeadStatus
    ).

record_identifier(premise_record_id, premise(Id, _, _, _), Id).
record_identifier(
    obligation_record_id, obligation(Id, _, _, _, _), Id).
record_identifier(
    contradiction_record_id, contradiction(Id, _, _, _), Id).

premise_policy_references([], _, ok).
premise_policy_references(
    [premise(_, _, Trust, _)|Tail], PolicyId, Status) :-
    trust_policy_status(Trust, PolicyId, HeadStatus),
    (   HeadStatus == ok
    ->  premise_policy_references(Tail, PolicyId, Status)
    ;   Status = HeadStatus
    ).

trust_policy_status(missing, _, ok).
trust_policy_status(trusted(Actual, _), Expected, Status) :-
    reference_match(policy, Expected, Actual, Status).
trust_policy_status(untrusted(Actual, _), Expected, Status) :-
    reference_match(policy, Expected, Actual, Status).

obligation_law_references([], _, ok).
obligation_law_references(
    [obligation(_, Actual, _, _, _)|Tail], Expected, Status) :-
    reference_match(law, Expected, Actual, HeadStatus),
    (   HeadStatus == ok
    ->  obligation_law_references(Tail, Expected, Status)
    ;   Status = HeadStatus
    ).

contradiction_claim_references([], _, ok).
contradiction_claim_references(
    [contradiction(_, Actual, _, _)|Tail], Expected, Status) :-
    reference_match(claim, Expected, Actual, HeadStatus),
    (   HeadStatus == ok
    ->  contradiction_claim_references(Tail, Expected, Status)
    ;   Status = HeadStatus
    ).

equality_invariant(
    data(_, claim_data(_, _, _, _, EqualityExpected, _, _, _, _, _, _, _, _),
         semantic_data(_, _, semantic(law, _, _, _,
                                      refs([_, _, equality-EqualityActual]),
                                      _),
                       semantic(equality, EqualityRecordId, _, _, _, _),
                       _, _, _),
         _, _, _, _),
    Status) :-
    (   EqualityExpected == EqualityRecordId
    ->  (   EqualityExpected == EqualityActual
        ->  Status = ok
        ;   Status = equality_mismatch(
                EqualityExpected, EqualityActual)
        )
    ;   Status = reference_mismatch(
            equality, EqualityExpected, EqualityRecordId)
    ).

policy_invariant(
    data(policy_data(_, Kind, _), _, _, _, _, _, _),
    Status) :-
    (   Kind == source_relative_law_v1
    ->  Status = ok
    ;   Status = unsupported_policy(Kind)
    ).

first_non_ok([], ok).
first_non_ok([Head|Tail], Status) :-
    (   Head == ok
    ->  first_non_ok(Tail, Status)
    ;   Status = Head
    ).

data_claim_lists(
    data(_, claim_data(_, _, _, _, _, _, _, _, _,
                       PremiseIds, ObligationIds, ContradictionIds, _),
         _, _, _, _, _),
    PremiseIds, ObligationIds, ContradictionIds).

data_record_ids(
    data(_, _, _, Premises, Obligations, Contradictions, Provenances),
    PremiseIds, ObligationIds, ContradictionIds, ProvenanceIds) :-
    premise_ids(Premises, PremiseIds),
    obligation_ids(Obligations, ObligationIds),
    contradiction_ids(Contradictions, ContradictionIds),
    provenance_ids(Provenances, ProvenanceIds).

premise_ids([], []).
premise_ids([premise(Id, _, _, _)|Tail], [Id|Ids]) :-
    premise_ids(Tail, Ids).

obligation_ids([], []).
obligation_ids([obligation(Id, _, _, _, _)|Tail], [Id|Ids]) :-
    obligation_ids(Tail, Ids).

contradiction_ids([], []).
contradiction_ids(
    [contradiction(Id, _, _, _)|Tail], [Id|Ids]) :-
    contradiction_ids(Tail, Ids).

provenance_ids([], []).
provenance_ids([provenance(Id, _)|Tail], [Id|Ids]) :-
    provenance_ids(Tail, Ids).

data_provenance_ids(data(_, _, _, _, _, _, Provenances), Ids) :-
    provenance_ids(Provenances, Ids).

% Provenance first-use order, immutable result table, and audit

provenance_first_use(Data, Unique) :-
    provenance_occurrences(Data, Occurrences),
    unique_first_use(Occurrences, [], Unique).

provenance_occurrences(
    data(
        policy_data(_, _, PolicyProv),
        claim_data(_, _, _, _, _, _, _, _, ClaimProv,
                   _, _, _, Lifecycle),
        semantic_data(Signature, Definition, Law, Equality,
                      Termination, Cost, Effects),
        Premises, Obligations, Contradictions, _),
    Occurrences) :-
    lifecycle_provenance(Lifecycle, LifecycleProvenance),
    semantic_provenances(Signature, SignatureProvenances),
    semantic_provenances(Definition, DefinitionProvenances),
    semantic_provenances(Law, LawProvenances),
    semantic_provenances(Equality, EqualityProvenances),
    semantic_provenances(Termination, TerminationProvenances),
    semantic_provenances(Cost, CostProvenances),
    semantic_provenances(Effects, EffectsProvenances),
    premise_provenances(Premises, PremiseProvenances),
    obligation_provenances(Obligations, ObligationProvenances),
    contradiction_provenances(
        Contradictions, ContradictionProvenances),
    append([ClaimProv|LifecycleProvenance],
           [PolicyProv],
           First),
    append(First, SignatureProvenances, A1),
    append(A1, DefinitionProvenances, A2),
    append(A2, LawProvenances, A3),
    append(A3, EqualityProvenances, A4),
    append(A4, TerminationProvenances, A5),
    append(A5, CostProvenances, A6),
    append(A6, EffectsProvenances, A7),
    append(A7, PremiseProvenances, A8),
    append(A8, ObligationProvenances, A9),
    append(A9, ContradictionProvenances, Occurrences).

lifecycle_provenance(current(Prov), [Prov]).
lifecycle_provenance(retracted(Prov), [Prov]).
lifecycle_provenance(missing, []).

semantic_provenances(
    semantic(_, _, Disposition, RecordProv, _, _),
    [RecordProv|DispositionProvenance]) :-
    disposition_provenance(Disposition, DispositionProvenance).

disposition_provenance(accepted(Prov), [Prov]).
disposition_provenance(rejected(Prov), [Prov]).
disposition_provenance(missing, []).

premise_provenances([], []).
premise_provenances(
    [premise(_, Activation, Trust, RecordProv)|Tail], Provenances) :-
    activation_provenance(Activation, ActivationProvenance),
    trust_provenance(Trust, TrustProvenance),
    premise_provenances(Tail, TailProvenance),
    append([RecordProv|ActivationProvenance], TrustProvenance, First),
    append(First, TailProvenance, Provenances).

activation_provenance(active(Prov), [Prov]).
activation_provenance(inactive(Prov), [Prov]).
activation_provenance(missing, []).

trust_provenance(trusted(_, Prov), [Prov]).
trust_provenance(untrusted(_, Prov), [Prov]).
trust_provenance(missing, []).

obligation_provenances([], []).
obligation_provenances(
    [obligation(_, _, Applicability, Disposition, RecordProv)|Tail],
    Provenances) :-
    applicability_provenance(Applicability, ApplicabilityProvenance),
    obligation_disposition_provenance(
        Disposition, DispositionProvenance),
    obligation_provenances(Tail, TailProvenance),
    append([RecordProv|ApplicabilityProvenance],
           DispositionProvenance, First),
    append(First, TailProvenance, Provenances).

applicability_provenance(applicable(Prov), [Prov]).
applicability_provenance(not_applicable(Prov), [Prov]).
applicability_provenance(missing, []).

obligation_disposition_provenance(accepted(Prov), [Prov]).
obligation_disposition_provenance(rejected(Prov), [Prov]).
obligation_disposition_provenance(missing, []).
obligation_disposition_provenance(not_applicable, []).

contradiction_provenances([], []).
contradiction_provenances(
    [contradiction(_, _, State, RecordProv)|Tail], Provenances) :-
    contradiction_state_provenance(State, StateProvenance),
    contradiction_provenances(Tail, TailProvenance),
    append([RecordProv|StateProvenance],
           TailProvenance, Provenances).

contradiction_state_provenance(explicit(Prov), [Prov]).
contradiction_state_provenance(cleared(Prov), [Prov]).
contradiction_state_provenance(unresolved, []).

unique_first_use([], _, []).
unique_first_use([Head|Tail], Seen, Unique) :-
    (   identity_member(Head, Seen)
    ->  unique_first_use(Tail, Seen, Unique)
    ;   Unique = [Head|UniqueTail],
        unique_first_use(Tail, [Head|Seen], UniqueTail)
    ).

validate_provenance_table([], _, [], []).
validate_provenance_table(
    [Id|Tail], Data,
    [provenance_result(Id, Mapping)|TableTail],
    [provenance(Id, Evidence)|RecordTail]) :-
    lookup_provenance(Data, Id, Evidence),
    normalize_reference_evidence(Evidence, T001Result),
    map_t001_result(T001Result, Mapping),
    validate_provenance_table(
        Tail, Data, TableTail, RecordTail).

lookup_provenance(
    data(_, _, _, _, _, _, Provenances), Id, Evidence) :-
    lookup_provenance_list(Provenances, Id, Evidence).

lookup_provenance_list(
    [provenance(RecordId, Evidence)|_], Id, Evidence) :-
    RecordId == Id.
lookup_provenance_list([_|Tail], Id, Evidence) :-
    lookup_provenance_list(Tail, Id, Evidence).

map_t001_result(normalization(accepted, _), accepted).
map_t001_result(normalization(unknown(Reasons), _), unknown(Reasons)).
map_t001_result(normalization(rejected(Reason), _), invalid(Reason)).

first_invalid_provenance(
    [provenance_result(Id, invalid(Reason))|_],
    invalid_provenance(Id, Reason)).
first_invalid_provenance([_|Tail], Reason) :-
    first_invalid_provenance(Tail, Reason).

closed_audit(
    Data, ExactRecords,
    audit(ClaimId, PolicyId, used(Items),
          provenance(ExactRecords))) :-
    Data = data(
        policy_data(PolicyId, _, _),
        claim_data(ClaimId, SignatureId, DefinitionId, LawId, EqualityId,
                   TerminationId, CostId, EffectsId, _,
                   PremiseIds, ObligationIds, ContradictionIds, _),
        _, _, _, _, _),
    append([ClaimId, PolicyId, SignatureId, DefinitionId, LawId,
            EqualityId, TerminationId, CostId, EffectsId],
           PremiseIds, First),
    append(First, ObligationIds, Second),
    append(Second, ContradictionIds, Items).

% Closed authority and canonical UNKNOWN

authority_result(Data, Missing, Audit, Result) :-
    closed_rejection(Data, Rejection),
    (   Rejection \== none
    ->  Result = authority_assessment(rejected(Rejection), Audit)
    ;   Missing \== []
    ->  Result = authority_assessment(unknown(Missing), Audit)
    ;   Result = authority_assessment(accepted, Audit)
    ).

closed_rejection(Data, Reason) :-
    retracted_rejection(Data, Retracted),
    explicit_contradiction_rejection(Data, Contradiction),
    inactive_premise_rejection(Data, Inactive),
    untrusted_premise_rejection(Data, Untrusted),
    rejected_obligation_rejection(Data, Obligation),
    rejected_semantic_rejection(Data, Semantic),
    first_present(
        [Retracted, Contradiction, Inactive, Untrusted,
         Obligation, Semantic],
        Reason).

first_present([], none).
first_present([some(Reason)|_], Reason).
first_present([none|Tail], Reason) :-
    first_present(Tail, Reason).

retracted_rejection(
    data(_, claim_data(ClaimId, _, _, _, _, _, _, _, _, _, _, _,
                       retracted(_)),
         _, _, _, _, _),
    some(retracted_claim(ClaimId))).
retracted_rejection(_, none).

explicit_contradiction_rejection(
    data(_, _, _, _, _, Contradictions, _), Result) :-
    first_explicit_contradiction(Contradictions, Result).

first_explicit_contradiction([], none).
first_explicit_contradiction(
    [contradiction(Id, _, explicit(_), _)|_],
    some(explicit_contradiction(Id))).
first_explicit_contradiction([_|Tail], Result) :-
    first_explicit_contradiction(Tail, Result).

inactive_premise_rejection(
    data(_, _, _, Premises, _, _, _), Result) :-
    first_inactive_premise(Premises, Result).

first_inactive_premise([], none).
first_inactive_premise(
    [premise(Id, inactive(_), _, _)|_],
    some(inactive_premise(Id))).
first_inactive_premise([_|Tail], Result) :-
    first_inactive_premise(Tail, Result).

untrusted_premise_rejection(
    data(_, _, _, Premises, _, _, _), Result) :-
    first_untrusted_premise(Premises, Result).

first_untrusted_premise([], none).
first_untrusted_premise(
    [premise(Id, _, untrusted(_, _), _)|_],
    some(untrusted_premise(Id))).
first_untrusted_premise([_|Tail], Result) :-
    first_untrusted_premise(Tail, Result).

rejected_obligation_rejection(
    data(_, _, _, _, Obligations, _, _), Result) :-
    first_rejected_obligation(Obligations, Result).

first_rejected_obligation([], none).
first_rejected_obligation(
    [obligation(Id, _, _, rejected(_), _)|_],
    some(rejected_obligation(Id))).
first_rejected_obligation([_|Tail], Result) :-
    first_rejected_obligation(Tail, Result).

rejected_semantic_rejection(
    data(_, _, semantic_data(Signature, Definition, Law, Equality,
                             Termination, Cost, Effects),
         _, _, _, _),
    Result) :-
    first_rejected_semantic(
        [Signature, Definition, Law, Equality, Termination, Cost, Effects],
        Result).

first_rejected_semantic([], none).
first_rejected_semantic(
    [semantic(Type, Id, rejected(_), _, _, _)|_],
    some(rejected_semantic(Type, Id))).
first_rejected_semantic([_|Tail], Result) :-
    first_rejected_semantic(Tail, Result).

canonical_missing(Data, ProvenanceTable, Missing) :-
    semantic_missing(Data, SemanticMissing),
    t001_missing(ProvenanceTable, T001Missing),
    lifecycle_missing(Data, LifecycleMissing),
    premise_missing(Data, PremiseMissing),
    obligation_missing(Data, ObligationMissing),
    contradiction_missing(Data, ContradictionMissing),
    append(SemanticMissing, T001Missing, First),
    append(First, LifecycleMissing, Second),
    append(Second, PremiseMissing, Third),
    append(Third, ObligationMissing, Fourth),
    append(Fourth, ContradictionMissing, Missing).

semantic_missing(
    data(_, _, semantic_data(Signature, Definition, Law, Equality,
                             Termination, Cost, Effects),
         _, _, _, _),
    Missing) :-
    semantic_missing_item(Signature, SignatureMissing),
    semantic_missing_item(Definition, DefinitionMissing),
    semantic_missing_item(Law, LawMissing),
    semantic_missing_item(Equality, EqualityMissing),
    semantic_missing_item(Termination, TerminationMissing),
    semantic_missing_item(Cost, CostMissing),
    semantic_missing_item(Effects, EffectsMissing),
    append(SignatureMissing, DefinitionMissing, First),
    append(First, LawMissing, Second),
    append(Second, EqualityMissing, Third),
    append(Third, TerminationMissing, Fourth),
    append(Fourth, CostMissing, Fifth),
    append(Fifth, EffectsMissing, Missing).

semantic_missing_item(
    semantic(Type, Id, missing, _, _, _),
    [missing(Type, Id)]).
semantic_missing_item(
    semantic(_, _, Disposition, _, _, _), []) :-
    Disposition \== missing.

t001_missing([], []).
t001_missing(
    [provenance_result(Id, unknown(Reasons))|Tail],
    [missing_t001(Id, Reasons)|MissingTail]) :-
    t001_missing(Tail, MissingTail).
t001_missing(
    [provenance_result(_, Mapping)|Tail], Missing) :-
    Mapping \= unknown(_),
    t001_missing(Tail, Missing).

lifecycle_missing(
    data(_, claim_data(ClaimId, _, _, _, _, _, _, _, _, _, _, _,
                       missing),
         _, _, _, _, _),
    [missing(lifecycle, ClaimId)]).
lifecycle_missing(
    data(_, claim_data(_, _, _, _, _, _, _, _, _, _, _, _,
                       Lifecycle),
         _, _, _, _, _),
    []) :-
    Lifecycle \== missing.

premise_missing(data(policy_data(PolicyId, _, _), _, _, Premises,
                     _, _, _),
                Missing) :-
    premise_missing_list(Premises, PolicyId, Missing).

premise_missing_list([], _, []).
premise_missing_list(
    [premise(Id, Activation, Trust, _)|Tail], PolicyId, Missing) :-
    premise_activation_missing(Id, Activation, ActivationMissing),
    premise_trust_missing(Id, PolicyId, Trust, TrustMissing),
    premise_missing_list(Tail, PolicyId, TailMissing),
    append(ActivationMissing, TrustMissing, First),
    append(First, TailMissing, Missing).

premise_activation_missing(
    Id, missing, [missing(premise_activation, Id)]).
premise_activation_missing(_, Activation, []) :-
    Activation \== missing.

premise_trust_missing(
    Id, PolicyId, missing,
    [missing(premise_trust(PolicyId), Id)]).
premise_trust_missing(_, _, Trust, []) :-
    Trust \== missing.

obligation_missing(data(_, _, _, _, Obligations, _, _), Missing) :-
    obligation_missing_list(Obligations, Missing).

obligation_missing_list([], []).
obligation_missing_list(
    [obligation(Id, _, Applicability, Disposition, _)|Tail], Missing) :-
    obligation_applicability_missing(
        Id, Applicability, ApplicabilityMissing),
    obligation_disposition_missing(
        Id, Disposition, DispositionMissing),
    obligation_missing_list(Tail, TailMissing),
    append(ApplicabilityMissing, DispositionMissing, First),
    append(First, TailMissing, Missing).

obligation_applicability_missing(
    Id, missing, [missing(obligation_applicability, Id)]).
obligation_applicability_missing(_, Applicability, []) :-
    Applicability \== missing.

obligation_disposition_missing(
    Id, missing, [missing(obligation_disposition, Id)]).
obligation_disposition_missing(_, Disposition, []) :-
    Disposition \== missing.

contradiction_missing(
    data(_, _, _, _, _, Contradictions, _), Missing) :-
    contradiction_missing_list(Contradictions, Missing).

contradiction_missing_list([], []).
contradiction_missing_list(
    [contradiction(Id, _, unresolved, _)|Tail],
    [missing(contradiction_resolution, Id)|MissingTail]) :-
    contradiction_missing_list(Tail, MissingTail).
contradiction_missing_list(
    [contradiction(_, _, State, _)|Tail], Missing) :-
    State \== unresolved,
    contradiction_missing_list(Tail, Missing).
