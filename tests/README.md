# Tests

The tracked Phase 0 tests cover the bootstrap-stage predicate in isolation and
through clean child SWI-Prolog processes, including failed-query propagation
and enforced timeout termination. They do not load or execute any immutable
legacy source.

Unit and integration suites are deliberately separate. Later product changes
must add focused rejection and boundary cases as well as observable
cross-module or process tests.
