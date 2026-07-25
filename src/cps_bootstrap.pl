:- module(cps_bootstrap, [bootstrap_stage/1]).

%!  bootstrap_stage(-Stage:dict) is det.
%
%   Report the only product capability implemented during Phase 0.
bootstrap_stage(cps_stage{phase:0, status:infrastructure_only}).
