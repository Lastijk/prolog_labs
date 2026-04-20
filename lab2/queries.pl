:- encoding(utf8).
% queries.pl — тесты к schedule.pl; идентификаторы на английском.
% Запуск: из каталога lab2 выполнить swipl -q queries.pl

:- use_module(schedule).

% 1) When does group X have subject Y? — all matching lessons
q1_group_subject_slots :-
    forall(
        group_subject_slots(it211, programming, Z),
        (writeln(Z), true)
    ).

% 2) Free rooms on Wednesday, first slot (model hour 9:00; adjust slot for "10:00")
q2_free_rooms_wed_slot1 :-
    writeln('Free rooms: wed, slot 1'),
    forall(
        free_rooms(wed, 1, R),
        (write('  '), writeln(R))
    ).

% 3) Groups taught by teacher Z
q3_groups_of_teacher :-
    writeln('Groups for sidorov:'),
    forall(groups_of_teacher(sidorov, G), (write('  '), writeln(G))).

% 4) Lesson count per week for group X
q4_week_lesson_count :-
    group_lesson_count(it212, N),
    format('Lessons/week it212: ~w~n', [N]).

% 5) Weekdays when teacher has no lessons
q5_teacher_free_days :-
    writeln('Free weekdays for petrov:'),
    forall(
        teacher_free_weekdays(petrov, D),
        (write('  '), writeln(D))
    ).

% 6) room_free/3 — single check
q6_room_free_sample :-
    ( room_free(lec310, mon, 3)
    -> writeln('lec310 free on mon slot 3')
    ; writeln('lec310 busy on mon slot 3')
    ).

% 7) group_lesson_count/2 — compare two groups
q7_compare_group_load :-
    group_lesson_count(mo211, N1),
    group_lesson_count(pi211, N2),
    format('mo211: ~w lessons; pi211: ~w lessons~n', [N1, N2]).

% 8) gaps_in_schedule/2 — total gaps across weekdays
q8_gaps :-
    gaps_in_schedule(it211, O),
    format('Total gap slots it211: ~w~n', [O]).

% 9) All lessons of a group on one day
q9_schedule_one_day :-
    writeln('it213, thu:'),
    forall(
        lesson(it213, S, T, thu, N, A),
        format('  slot ~w: ~w, ~w, ~w~n', [N, S, T, A])
    ).

% 10) All subjects in domain
q10_all_subjects :-
    writeln('Subjects in domain:'),
    forall(subject(P), (write('  '), writeln(P))).

% 11) Teacher weekly hours (2 h per slot)
q11_teacher_hours :-
    teacher_hours_week(kozlov, H),
    format('kozlov: ~w academic hours/week~n', [H]).

% 12) Who teaches networks and where
q12_networks :-
    writeln('Lessons: networks'),
    forall(
        lesson(G, networks, Te, D, N, A),
        format('  ~w ~w slot ~w: ~w, ~w~n', [G, D, N, Te, A])
    ).

% ---------- level 2 ----------

q13_no_group_conflicts :-
    ( no_group_conflicts
    -> writeln('OK: no group conflicts')
    ; writeln('FAIL: group conflicts')
    ).

q14_no_teacher_conflicts :-
    ( no_teacher_conflicts
    -> writeln('OK: no teacher conflicts')
    ; writeln('FAIL: teacher conflicts')
    ).

q15_no_room_conflicts :-
    ( no_room_conflicts
    -> writeln('OK: rooms ok (capacity/equipment)')
    ; writeln('FAIL: room issues')
    ).

q16_schedule_valid :-
    ( schedule_valid
    -> writeln('OK: schedule_valid')
    ; writeln('FAIL: schedule_valid')
    ).

q17_demo_conflicts :-
    ( group_conflict(D)
    -> format('Sample group conflict: ~w~n', [D])
    ; writeln('No group conflict')
    ),
    ( teacher_conflict(D2)
    -> format('Sample teacher conflict: ~w~n', [D2])
    ; writeln('No teacher conflict')
    ),
    ( room_conflict(D3)
    -> format('Sample room issue: ~w~n', [D3])
    ; writeln('No room conflict')
    ).

q18_weekday_min_lessons :-
    writeln('Weekdays with min lessons (it211):'),
    forall(
        weekday_min_lessons(it211, D),
        (write('  '), writeln(D))
    ).

q19_overloaded :-
    overloaded_teachers(L),
    format('Overloaded (>20 h/week): ~w~n', [L]).

take_first_n(_, [], []).
take_first_n(N, [H | T], [H | R]) :-
    N > 0,
    N1 is N - 1,
    take_first_n(N1, T, R).
take_first_n(0, _, []).

q20_can_swap_sample :-
    findall(Z1-Z2, can_swap_slots(Z1, Z2), L),
    writeln('Sample allowed slot swaps (first 8):'),
    take_first_n(8, L, L8),
    forall(member(X, L8), writeln(X)).

run_all :-
    writeln('=== lab2 queries ==='),
    q1_group_subject_slots,
    nl,
    q2_free_rooms_wed_slot1,
    nl,
    q3_groups_of_teacher,
    nl,
    q4_week_lesson_count,
    nl,
    q5_teacher_free_days,
    nl,
    q6_room_free_sample,
    nl,
    q7_compare_group_load,
    nl,
    q8_gaps,
    nl,
    q9_schedule_one_day,
    nl,
    q10_all_subjects,
    nl,
    q11_teacher_hours,
    nl,
    q12_networks,
    nl,
    writeln('--- validation ---'),
    q13_no_group_conflicts,
    q14_no_teacher_conflicts,
    q15_no_room_conflicts,
    q16_schedule_valid,
    nl,
    q17_demo_conflicts,
    nl,
    q18_weekday_min_lessons,
    nl,
    q19_overloaded,
    nl,
    q20_can_swap_sample,
    nl,
    writeln('=== done ===').

:- initialization(run_all, main).
