:- encoding(utf8).
% schedule.pl — KB and rules (levels 1–2). SWI-Prolog 8.x+.
% Идентификаторы и сообщения в коде — на английском; комментарии можно на русском.

:- module(schedule, [
    lesson/6,
    weekday/1,
    slot/2,
    room/3,
    group_size/2,
    subject_requires/2,
    teacher/1,
    group/1,
    subject/1,
    room_free/3,
    group_lesson_count/2,
    teacher_hours_week/2,
    gaps_in_schedule/2,
    group_total_gaps/2,
    group_subject_slots/3,
    free_rooms/3,
    groups_of_teacher/2,
    teacher_free_weekdays/2,
    no_group_conflicts/0,
    no_teacher_conflicts/0,
    no_teacher_conflicts_typo/0,
    no_room_conflicts/0,
    schedule_valid/0,
    group_conflict/1,
    teacher_conflict/1,
    room_conflict/1,
    weekday_min_lessons/2,
    overloaded_teachers/1,
    can_swap_slots/2
]).

% ---------- domains ----------

weekday(mon).
weekday(tue).
weekday(wed).
weekday(thu).
weekday(fri).

slot(1, 9).
slot(2, 11).
slot(3, 13).
slot(4, 15).
slot(5, 17).
slot(6, 19).

group(it211).
group(it212).
group(it213).
group(pi211).
group(mo211).

subject(discrete_math).
subject(programming).
subject(algorithms).
subject(databases).
subject(operating_systems).
subject(networks).
subject(web_tech).
subject(calculus).
subject(physics).
subject(foreign_language).
subject(project_work).

teacher(petrov).
teacher(ivanova).
teacher(sidorov).
teacher(kozlov).
teacher(morozov).

% room(Name, Capacity, Equipment)
room(a101, 30, board).
room(a102, 40, projector).
room(a103, 35, projector).
room(a201, 35, projector).
room(a202, 50, projector).
room(lab1, 45, pc_lab).
room(lab2, 45, lab_room).
room(lab3, 45, pc_lab).
room(lec310, 120, projector).
room(lec205, 100, projector).

group_size(it211, 28).
group_size(it212, 27).
group_size(it213, 26).
group_size(pi211, 22).
group_size(mo211, 20).

subject_requires(discrete_math, board).
subject_requires(programming, pc_lab).
subject_requires(algorithms, pc_lab).
subject_requires(databases, pc_lab).
subject_requires(operating_systems, pc_lab).
subject_requires(networks, lab_room).
subject_requires(web_tech, pc_lab).
subject_requires(calculus, board).
subject_requires(physics, board).
subject_requires(foreign_language, projector).
subject_requires(project_work, projector).

equipment_not_weaker(lab_room, board).
equipment_not_weaker(lab_room, projector).
equipment_not_weaker(lab_room, pc_lab).
equipment_not_weaker(lab_room, lab_room).
equipment_not_weaker(pc_lab, board).
equipment_not_weaker(pc_lab, projector).
equipment_not_weaker(pc_lab, pc_lab).
equipment_not_weaker(projector, board).
equipment_not_weaker(projector, projector).
equipment_not_weaker(board, board).

equipment_ok(Actual, Req) :-
    equipment_not_weaker(Actual, Req).

% ---------- facts: lesson(Group, Subject, Teacher, Weekday, Slot, Room) ----------

lesson(it211, discrete_math, petrov, mon, 1, a101).
lesson(it211, programming, sidorov, mon, 2, lab1).
lesson(it212, discrete_math, petrov, mon, 3, a102).
lesson(it212, calculus, ivanova, mon, 4, a201).
lesson(it213, programming, sidorov, mon, 1, lab2).
lesson(pi211, foreign_language, morozov, mon, 2, a103).
lesson(mo211, physics, kozlov, mon, 3, a202).

lesson(it211, algorithms, sidorov, tue, 1, lab1).
lesson(it211, databases, kozlov, tue, 3, lab3).
lesson(it212, programming, sidorov, tue, 2, lab1).
lesson(it212, operating_systems, kozlov, tue, 4, lab3).
lesson(it213, discrete_math, petrov, tue, 2, a101).
lesson(it213, calculus, ivanova, tue, 5, a201).
lesson(pi211, algorithms, sidorov, tue, 3, lab2).
lesson(mo211, calculus, ivanova, tue, 1, a202).

lesson(it211, networks, kozlov, wed, 2, lab2).
lesson(it211, foreign_language, morozov, wed, 4, a102).
lesson(it212, databases, kozlov, wed, 1, lab3).
lesson(it212, web_tech, morozov, wed, 3, lab1).
lesson(it213, algorithms, sidorov, wed, 4, lab1).
lesson(it213, project_work, morozov, wed, 1, a201).
lesson(pi211, calculus, ivanova, wed, 2, a103).
lesson(mo211, programming, sidorov, wed, 5, lab3).

lesson(it211, operating_systems, kozlov, thu, 1, lab3).
lesson(it211, web_tech, morozov, thu, 3, lab2).
lesson(it212, networks, kozlov, thu, 2, lab2).
lesson(it212, foreign_language, morozov, thu, 4, a103).
lesson(it213, databases, kozlov, thu, 3, lab3).
lesson(it213, physics, kozlov, thu, 5, a202).
lesson(pi211, programming, sidorov, thu, 1, lab2).
lesson(mo211, discrete_math, petrov, thu, 2, a101).

lesson(it211, calculus, ivanova, fri, 2, lec310).
lesson(it211, project_work, morozov, fri, 4, a201).
lesson(it212, web_tech, morozov, fri, 1, lab1).
lesson(it212, project_work, morozov, fri, 5, a102).
lesson(it213, operating_systems, kozlov, fri, 2, lab3).
lesson(it213, foreign_language, morozov, fri, 6, a103).
lesson(pi211, discrete_math, petrov, fri, 3, a101).
lesson(pi211, physics, kozlov, fri, 4, a202).
lesson(mo211, algorithms, sidorov, fri, 1, lab2).

% ---------- level 1 ----------

room_free(R, D, N) :-
    room(R, _, _),
    weekday(D),
    slot(N, _),
    \+ lesson(_, _, _, D, N, R).

group_lesson_count(G, K) :-
    group(G),
    findall(1, lesson(G, _, _, _, _, _), L),
    length(L, K).

% one slot = 2 academic hours per week load
teacher_hours_week(T, H) :-
    teacher(T),
    findall(1, lesson(_, _, T, _, _, _), L),
    length(L, P),
    H is P * 2.

group_slots_on_day(G, D, SortedSlots) :-
    findall(N, lesson(G, _, _, D, N, _), Raw),
    sort(Raw, SortedSlots).

gaps_in_sorted_slots([_], 0).
gaps_in_sorted_slots([A, B | T], Sum) :-
    gaps_in_sorted_slots([B | T], Rest),
    Gap is max(0, B - A - 1),
    Sum is Gap + Rest.

gaps_on_day(G, D, O) :-
    group_slots_on_day(G, D, S),
    ( S = [] -> O = 0 ; gaps_in_sorted_slots(S, O) ).

group_total_gaps(G, Total) :-
    group(G),
    findall(O, (weekday(D), gaps_on_day(G, D, O)), L),
    sum_list(L, Total).

gaps_in_schedule(G, N) :-
    group_total_gaps(G, N).

group_subject_slots(G, S, lesson(G, S, P, D, N, A)) :-
    lesson(G, S, P, D, N, A).

free_rooms(D, N, R) :-
    room_free(R, D, N).

groups_of_teacher(T, G) :-
    findall(G0, lesson(G0, _, T, _, _, _), L),
    sort(L, Gs),
    member(G, Gs).

teacher_free_weekdays(T, D) :-
    weekday(D),
    \+ lesson(_, _, T, D, _, _).

% ---------- level 2: validation ----------

group_conflict(group_double_booking(G, D, N, S1, S2)) :-
    lesson(G, S1, _, D, N, _),
    lesson(G, S2, _, D, N, _),
    S1 \= S2.

no_group_conflicts :-
    \+ group_conflict(_).

teacher_conflict(teacher_double_booking(T, D, N, G1, S1, G2, S2)) :-
    lesson(G1, S1, T, D, N, _),
    lesson(G2, S2, T, D, N, _),
    (G1, S1) \= (G2, S2).

no_teacher_conflicts :-
    \+ teacher_conflict(_).

% алиас под опечатку из текста задания
no_teacher_conflicts_typo :-
    no_teacher_conflicts.

room_conflict(room_double_booking(R, D, N, G1, G2)) :-
    lesson(G1, _, _, D, N, R),
    lesson(G2, _, _, D, N, R),
    G1 \= G2.

room_conflict(room_too_small(G, S, R, Cap, Need)) :-
    lesson(G, S, _, _, _, R),
    group_size(G, Need),
    room(R, Cap, _),
    Need > Cap.

room_conflict(room_bad_equipment(G, S, R, Eq, Req)) :-
    lesson(G, S, _, _, _, R),
    subject_requires(S, Req),
    room(R, _, Eq),
    \+ equipment_ok(Eq, Req).

no_room_conflicts :-
    \+ room_conflict(_).

schedule_valid :-
    no_group_conflicts,
    no_teacher_conflicts,
    no_room_conflicts.

% ---------- level 2: analytics ----------

lessons_on_day_count(G, D, K) :-
    findall(1, lesson(G, _, _, D, _, _), L),
    length(L, K).

list_min([X], X).
list_min([A, B | T], M) :-
    ( A =< B -> list_min([A | T], M) ; list_min([B | T], M) ).

% weekdays where group's lesson count is minimal (possibly several)
weekday_min_lessons(G, D) :-
    group(G),
    findall(K, (weekday(Dx), lessons_on_day_count(G, Dx, K)), Ks),
    Ks \= [],
    list_min(Ks, MinK),
    weekday(D),
    lessons_on_day_count(G, D, MinK).

overloaded_teachers(List) :-
    findall(T, (teacher(T), teacher_hours_week(T, H), H > 20), Raw),
    sort(Raw, List).

% ---------- can_swap_slots: swap (weekday, slot) for two lessons of same group ----------

lesson_term(Z) :-
    Z = lesson(G, S, T, D, N, A),
    lesson(G, S, T, D, N, A).

other_teacher_lesson_except(Teacher, D, N, Except) :-
    lesson(G, S, Teacher, D, N, A),
    Except \= lesson(G, S, Teacher, D, N, A).

room_occupied_by_other(R, D, N, Skip1, Skip2) :-
    lesson(G, S, Te, D, N, R),
    Z = lesson(G, S, Te, D, N, R),
    Z \= Skip1,
    Z \= Skip2.

group_third_lesson_in_slot(G, D, N, Z1, Z2) :-
    lesson(G, S, Te, D, N, A),
    Z = lesson(G, S, Te, D, N, A),
    Z \= Z1,
    Z \= Z2.

can_swap_slots(Z1, Z2) :-
    lesson_term(Z1),
    lesson_term(Z2),
    Z1 @< Z2,
    Z1 = lesson(G, _, Te1, D1, N1, A1),
    Z2 = lesson(G, _, Te2, D2, N2, A2),
    (D1, N1) \= (D2, N2),
    ( Te1 = Te2
    -> true
    ; \+ other_teacher_lesson_except(Te1, D2, N2, Z1),
      \+ other_teacher_lesson_except(Te1, D2, N2, Z2),
      \+ other_teacher_lesson_except(Te2, D1, N1, Z1),
      \+ other_teacher_lesson_except(Te2, D1, N1, Z2)
    ),
    \+ group_third_lesson_in_slot(G, D2, N2, Z1, Z2),
    \+ group_third_lesson_in_slot(G, D1, N1, Z1, Z2),
    \+ room_occupied_by_other(A1, D2, N2, Z1, Z2),
    \+ room_occupied_by_other(A2, D1, N1, Z1, Z2).
