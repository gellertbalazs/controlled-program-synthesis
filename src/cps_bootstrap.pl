:- module(cps_bootstrap, [bootstrap_stage/1]).

%!  bootstrap_stage(?Stage) is semidet.
%
%   Succeed exactly for the only implemented product stage.

bootstrap_stage(phase0).
