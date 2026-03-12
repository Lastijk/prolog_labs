% tests.pl
% Автоматические тесты для ЛР №1.
%
% Загрузка:
% ?- [family, tests].
%
% Запуск всех тестов:
% ?- run_tests.
%
% Каждый тест оформлен как отдельный предикат test_*/0.

% Вспомогательный предикат для запуска одного теста по имени.
run_test(Name, Goal) :-
    (   call(Goal)
    ->  format('~w: ok~n', [Name])
    ;   format('~w: FAIL~n', [Name]),
        fail
    ).

% Запуск всех тестов подряд.
run_tests :-
    format('--- family.pl tests ---~n', []),
    run_test(test_father,        test_father),
    run_test(test_mother,        test_mother),
    run_test(test_grandfather,   test_grandfather),
    run_test(test_grandmother,   test_grandmother),
    run_test(test_brother,       test_brother),
    run_test(test_sister,        test_sister),
    run_test(test_uncle,         test_uncle),
    run_test(test_aunt,          test_aunt),
    run_test(test_ancestor,      test_ancestor),
    run_test(test_descendant,    test_descendant),
    run_test(test_cousin_pair,   test_cousin_pair),
    run_test(test_cousin_bro,    test_cousin_bro),
    run_test(test_generation,    test_generation),
    run_test(test_lca,           test_lca),
    run_test(test_kinship,       test_kinship),
    run_test(test_validation,    test_validation),
    format('--- all tests passed ---~n', []).

% ----------------------------------------------------------
% 1. Отец и мать
% ----------------------------------------------------------

test_father :-
    father(alexey, sergey).

test_mother :-
    mother(olga, ivan).

% ----------------------------------------------------------
% 2. Дедушка и бабушка
% ----------------------------------------------------------

test_grandfather :-
    grandfather(alexey, oleg).

test_grandmother :-
    grandmother(olga, victoria).

% ----------------------------------------------------------
% 3. Брат и сестра
% ----------------------------------------------------------

test_brother :-
    brother(sergey, ivan).

test_sister :-
    sister(elena, sergey).

% ----------------------------------------------------------
% 4. Дядя и тётя
% ----------------------------------------------------------

test_uncle :-
    uncle(sergey, denis).

test_aunt :-
    aunt(elena, oleg).

% ----------------------------------------------------------
% 5. Предок и потомок
% ----------------------------------------------------------

test_ancestor :-
    ancestor(alexey, denis).

test_descendant :-
    descendant(denis, alexey).

% ----------------------------------------------------------
% 6. Двоюродные
% ----------------------------------------------------------

% oleg и denis – двоюродные (через sergey и ivan)
test_cousin_pair :-
    cousin(oleg, denis).

% двоюродный брат через специализированный предикат
test_cousin_bro :-
    cousin_brother(oleg, denis).

% ----------------------------------------------------------
% 7. Поколения от корня alexey
% ----------------------------------------------------------

test_generation :-
    generation(alexey, 0),
    generation(sergey, 1),
    generation(oleg,   2).

% ----------------------------------------------------------
% 8. Ближайший общий предок
% ----------------------------------------------------------

test_lca :-
    lca(oleg, denis, alexey).

% ----------------------------------------------------------
% 9. Степень родства как длина кратчайшего пути
% ----------------------------------------------------------

test_kinship :-
    kinship_degree(oleg, denis, 4).

% ----------------------------------------------------------
% 10. Валидация БЗ
% ----------------------------------------------------------

test_validation :-
    no_cycles,
    ages_ok,
    no_hooks.