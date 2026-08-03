# Integration tests

Clean child SWI-Prolog processes load the bootstrap module through its public
repository-relative path and verify both successful output and rejection
status propagation under a fixed timeout.

The T006 `fresh_process_fixed_left_reduction_v0_boundary` group loads the root
reduction module in clean child processes and checks exact accepted,
rejected, unsupported, `UNKNOWN`, and resource propagation without granting
proposal, child-process, or test output any acceptance authority.
