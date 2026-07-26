:- begin_tests(repository_boundary).

:- use_module(library(filesex)).
:- use_module(library(process)).

repository_root(Root) :-
    source_file(repository_root(_), File),
    file_directory_name(File, UnitDirectory),
    file_directory_name(UnitDirectory, TestsDirectory),
    file_directory_name(TestsDirectory, Root).

git_ignore_status(Relative, Status) :-
    repository_root(Root),
    process_create(
        path(git),
        ['check-ignore', '--no-index', '-q', '--', Relative],
        [ cwd(Root),
          stderr(null),
          process(Pid)
        ]
    ),
    process_wait(Pid, Status).

assert_allowed(Relative) :-
    git_ignore_status(Relative, exit(1)).

assert_ignored(Relative) :-
    git_ignore_status(Relative, exit(0)).

fixture_path(Relative, Absolute) :-
    current_prolog_flag(pid, Pid),
    format(
        atom(Relative),
        'tests/.phase0 fixture (~d safe)/sample source.pl',
        [Pid]
    ),
    repository_root(Root),
    directory_file_path(Root, Relative, Absolute).

discover_prolog_files(Directory, Files) :-
    findall(Path,
            ( repository_file(Directory, Path),
              file_name_extension(_, pl, Path)
            ),
            Unsorted),
    sort(Unsorted, Files).

repository_file(Directory, Path) :-
    directory_files(Directory, Names),
    member(Name, Names),
    Name \== '.',
    Name \== '..',
    directory_file_path(Directory, Name, Candidate),
    (   exists_directory(Candidate)
    ->  repository_file(Candidate, Path)
    ;   exists_file(Candidate),
        absolute_file_name(Candidate, Path,
                           [file_type(regular), access(read)])
    ).

create_source_fixture(Relative-Absolute) :-
    fixture_path(Relative, Absolute),
    file_directory_name(Absolute, Directory),
    make_directory_path(Directory),
    setup_call_cleanup(
        open(Absolute, write, Stream, [encoding(utf8)]),
        format(Stream, 'fixture.~n', []),
        close(Stream)
    ).

remove_source_fixture(_Relative-Absolute) :-
    file_directory_name(Absolute, Directory),
    ( exists_file(Absolute) -> delete_file(Absolute) ; true ),
    ( exists_directory(Directory) -> delete_directory(Directory) ; true ).

test(root_readme_is_allowed) :-
    assert_allowed('README.md').

test(product_prolog_is_allowed) :-
    assert_allowed('src/example.pl').

test(nested_product_readme_is_allowed) :-
    assert_allowed('docs/architecture/README.md').

test(control_plane_readme_is_ignored) :-
    assert_ignored('.codex/README.md').

test(control_plane_metadata_is_ignored) :-
    assert_ignored('config/reference_manifest.json').

test(non_product_extension_is_ignored) :-
    assert_ignored('src/generated.json').

test(source_fixture_with_spaces_and_parentheses_is_allowed,
     [ setup(create_source_fixture(Fixture)),
       cleanup(remove_source_fixture(Fixture))
     ]) :-
    Fixture = Relative-Absolute,
    exists_file(Absolute),
    assert_allowed(Relative),
    file_directory_name(Absolute, Directory),
    discover_prolog_files(Directory, Files),
    assertion(Files == [Absolute]).

test(malformed_empty_path_is_rejected, [fail]) :-
    assert_allowed('').

:- end_tests(repository_boundary).
