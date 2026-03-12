% family.pl
% База знаний генеалогического дерева и предикаты

% мужчина man(Person).
man(alexey).
man(sergey).
man(ivan).
man(pavel).
man(oleg).
man(denis).
man(kirill).
man(roman).

% женщина woman(Person).
woman(olga).
woman(maria).
woman(anna).
woman(tatiana).
woman(irina).
woman(victoria).
woman(elena).

% супруги spouse(spouse1, spouse2).
spouse(alexey, olga).
spouse(olga, alexey).

spouse(sergey, maria).
spouse(maria, sergey).

spouse(ivan, anna).
spouse(anna, ivan).

spouse(pavel, tatiana).
spouse(tatiana, pavel).

% родитель parent(Parent, Child).
parent(alexey, sergey).
parent(olga,   sergey).

parent(alexey, ivan).
parent(olga,   ivan).

parent(alexey, elena).
parent(olga,   elena).

parent(sergey, oleg).
parent(maria,  oleg).

parent(sergey, victoria).
parent(maria,  victoria).

parent(ivan,   denis).
parent(anna,   denis).

parent(ivan,   kirill).
parent(anna,   kirill).

parent(elena,  roman).
parent(pavel,  roman).

% дата рождения и смерти: date(Year, Month, Day)
born(alexey,  date(1955,5,10)).
born(olga,    date(1957,8,2)).
born(sergey,  date(1980,3,12)).
born(maria,   date(1982,11,30)).
born(ivan,    date(1983,7,1)).
born(anna,    date(1984,9,14)).
born(elena,   date(1985,1,25)).
born(pavel,   date(1984,4,3)).
born(oleg,    date(2005,6,21)).
born(victoria,date(2008,9,5)).
born(denis,   date(2010,2,18)).
born(kirill,  date(2013,12,1)).
born(roman,   date(2015,5,9)).

% место рождения place(Name, Place)
place(alexey,  moscow).
place(olga,    moscow).
place(sergey,  moscow).
place(maria,   tver).
place(ivan,    moscow).
place(anna,    tula).
place(elena,   moscow).
place(pavel,   moscow).
place(oleg,    moscow).
place(victoria,moscow).
place(denis,   moscow).
place(kirill,  moscow).
place(roman,   moscow).

% профессия job(Name, Occupation)
job(alexey,  engineer).
job(olga,    teacher).
job(sergey,  programmer).
job(maria,   doctor).
job(ivan,    designer).
job(anna,    lawyer).
job(elena,   manager).
job(pavel,   architect).
job(oleg,    student).
job(victoria,student).
job(denis,   schoolboy).
job(kirill,  schoolboy).
job(roman,   child).

% отец father(Father, Child)
father(F, C) :-
    parent(F, C),
    man(F).

% мать mother(Mother, Child)
mother(M, C) :-
    parent(M, C),
    woman(M).

% дедушка grandfather(Grandfather, Child)
grandfather(GF, C) :-
    parent(GF, P),
    parent(P, C),
    man(GF).

% бабушка grandmother(Grandmother, Child)
grandmother(GM, C) :-
    parent(GM, P),
    parent(P, C),
    woman(GM).

% брат brother(Brother, Person)
brother(B, X) :-
    parent(P, B),
    parent(P, X),
    B \= X,
    man(B).

% сестра sister(Sister, Person)
sister(S, X) :-
    parent(P, S),
    parent(P, X),
    S \= X,
    woman(S).

% дядя uncle(Uncle, Child)
uncle(U, C) :-
    parent(P, C),
    brother(U, P).
uncle(U, C) :-
    parent(P, C),
    sister(S, P),
    spouse(U, S),
    man(U).

% тётя aunt(Aunt, Child)
aunt(A, C) :-
    parent(P, C),
    sister(A, P).
aunt(A, C) :-
    parent(P, C),
    brother(B, P),
    spouse(A, B),
    woman(A).

% предок ancestor(Ancestor, Descendant)
ancestor(A, D) :-
    ancestor_helper(A, D, [A]).

ancestor_helper(A, D, _) :-
    parent(A, D).
ancestor_helper(A, D, Visited) :-
    parent(A, X),
    \+ member(X, Visited),
    ancestor_helper(X, D, [X|Visited]).

descendant(D, A) :-
    ancestor(A, D).

% двоюродные cousin(Cousin1, Cousin2)
cousin(X, Y) :-
    parent(P1, X),
    parent(P2, Y),
    P1 \= P2,
    (brother(P1, P2) ; sister(P1, P2) ; brother(P2, P1) ; sister(P2, P1)),
    X \= Y.

% двоюродный брат cousin_brother(CousinBrother, Person)
cousin_brother(B, X) :-
    cousin(B, X),
    man(B).

% двоюродная сестра cousin_sister(CousinSister, Person)
cousin_sister(S, X) :-
    cousin(S, X),
    woman(S).

% троюродная сестра triple_sister(CousinSister, Person)
triple_sister(S, X) :-
    parent(P1, S),
    parent(P2, X),
    cousin(P1, P2),
    woman(S).

% троюродный брат triple_brother(CousinBrother, Person)
triple_brother(B, X) :-
    parent(P1, B),
    parent(P2, X),
    cousin(P1, P2),
    man(B).


% корень дерева (нулевое поколение)
root(alexey).

% поколение generation(Person, Generation)
generation(Person, Gen) :-
    root(Root),
    generation_from(Root, Person, Gen).

generation_from(Person, Person, 0).
generation_from(From, To, Gen) :-
    parent(From, Child),
    path_length_down(Child, To, 1, Gen).

path_length_down(Person, Person, Acc, Acc).
path_length_down(From, To, Acc, Gen) :-
    parent(From, Child),
    Acc1 is Acc + 1,
    path_length_down(Child, To, Acc1, Gen).

% вспомогательный предикат: предок с глубиной
ancestor_with_depth(Anc, Desc, Depth) :-
    ancestor_depth_helper(Anc, Desc, 1, Depth).

ancestor_depth_helper(Anc, Desc, Cur, Cur) :-
    parent(Anc, Desc).
ancestor_depth_helper(Anc, Desc, Cur, Depth) :-
    parent(Anc, X),
    Cur1 is Cur + 1,
    ancestor_depth_helper(X, Desc, Cur1, Depth).

% первый общий предок lca(Person1, Person2, Ancestor)
lca(X, Y, Anc) :-
    setof(D1-Anc1, ancestor_with_depth(Anc1, X, D1), List1),
    setof(D2-Anc2, ancestor_with_depth(Anc2, Y, D2), List2),
    findall(Sum-AncCommon,
            ( member(Dx-A, List1),
              member(Dy-A, List2),
              Sum is Dx + Dy
            ),
            CommonList),
    sort(CommonList, [ _MinSum-Anc | _ ]).

% рёбра графа родства (неориентированные)
rel_edge(X, Y) :- parent(X, Y).
rel_edge(X, Y) :- parent(Y, X).
rel_edge(X, Y) :- spouse(X, Y).

% степень родства relation_degree(Person1, Person2, Degree)
relation_degree(A, B, Degree) :-
    bfs([[A]], B, RevPath),
    reverse(RevPath, Path),
    length(Path, Len),
    Degree is Len - 1.

% обход в ширину bfs(Queue, Goal, ResultPath)
bfs([[Goal|RestPath]|_], Goal, [Goal|RestPath]).
bfs([Path|OtherPaths], Goal, ResultPath) :-
    Path = [Current|_],
    findall([Next|Path],
            ( rel_edge(Current, Next),
              \+ member(Next, Path)
            ),
            NewPaths),
    append(OtherPaths, NewPaths, Queue),
    bfs(Queue, Goal, ResultPath).

% проверка: нет циклов по отношению родительства
no_cycles :-
    \+ has_cycle.

has_cycle :-
    parent(X, Y),
    path_parent(Y, X, [Y]).

% путь только по родительским рёбрам path_parent(From, To, Visited)
path_parent(From, To, _) :-
    parent(From, To).
path_parent(From, To, Visited) :-
    parent(From, Next),
    \+ member(Next, Visited),
    path_parent(Next, To, [Next|Visited]).

% проверка логичности возрастов: родитель старше ребёнка хотя бы на 16 лет
ages_ok :-
    \+ bad_age.

bad_age :-
    parent(P, C),
    born(P, date(Yp, Mp, Dp)),
    born(C, date(Yc, Mc, Dc)),
    age_diff_years(date(Yp, Mp, Dp), date(Yc, Mc, Dc), Diff),
    Diff < 16.

date_before(date(Y1, M1, D1), date(Y2, M2, D2)) :-
    (  Y1 < Y2
    ;  Y1 = Y2, M1 < M2
    ;  Y1 = Y2, M1 = M2, D1 < D2
    ).

% полное число лет между двумя датами D1 и D2 (предполагаем D1 =< D2)
full_years_between(date(Y1, M1, D1), date(Y2, M2, D2), Years) :-
    Yraw is Y2 - Y1,
    (  (M2 < M1 ; (M2 = M1, D2 < D1))
    -> Years is Yraw - 1
    ;  Years is Yraw
    ).

% разница в полных годах по датам рождения age_diff_years(DateParent, DateChild, Difference)
age_diff_years(DParent, DChild, Diff) :-
    (  date_before(DChild, DParent)
    -> full_years_between(DChild, DParent, Y),
       Diff is -Y
    ;  full_years_between(DParent, DChild, Diff)
    ).

% проверка на петлю
no_hooks :-
    \+ ( ancestor(X, X) ).