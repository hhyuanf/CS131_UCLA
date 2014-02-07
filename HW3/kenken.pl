kenken_testcase(
  6,
  [
   +(11, [1-1, 2-1]),
   /(2, 1-2, 1-3),
   *(20, [1-4, 2-4]),
   *(6, [1-5, 1-6, 2-6, 3-6]),
   -(3, 2-2, 2-3),
   /(3, 2-5, 3-5),
   *(240, [3-1, 3-2, 4-1, 4-2]),
   *(6, [3-3, 3-4]),
   *(6, [4-3, 5-3]),
   +(7, [4-4, 5-4, 5-5]),
   *(30, [4-5, 4-6]),
   *(6, [5-1, 5-2]),
   +(9, [5-6, 6-6]),
   +(8, [6-1, 6-2, 6-3]),
   /(2, 6-4, 6-5)
  ]
).

trans([], []).
trans([F|Fs], Ts) :-
trans(F, [F|Fs], Ts).

trans([], _, []).
trans([_|Rs], Ms, [Ts|Tss]) :-
lists_firsts_rests(Ms, Ts, Ms1),
trans(Rs, Ms1, Tss).

lists_firsts_rests([], [], []).
lists_firsts_rests([[F|Os]|Rest], [F|Fs], [Os|Oss]) :-
lists_firsts_rests(Rest, Fs, Oss).

%implementation of kenken/3
kenken(N, [], L):-
length(L, N),
distinct_null(N, L),
trans(L, LTrans),
distinct_null(N, LTrans),
statistics.

kenken(N, C, L):-
length(C, X),
X #>= 1,
length(L, N),
distinct(N, L),
trans(L, LTrans),
distinct(N, LTrans),
kenken1(N,C,L),
statistics.

distinct(_, []).
distinct(N, [Lx|Ly]):-
length(Lx, N),
fd_all_different(Lx),
distinct(N, Ly).

distinct_null(_, []).
distinct_null(N, [Lx|Ly]):-
length(Lx, N),
fd_domain(Lx,1,N),
fd_all_different(Lx),
fd_labeling(Lx),
distinct_null(N, Ly).

kenken1(_,[],_).
kenken1(N,[X|Y],L):-
test(X,L,N),
kenken1(N,Y,L).

test(+(A,B),L,N):-calc_add(A,B,0,L,N).
test(*(A,B),L,N):-calc_mul(A,B,1,L,N).
test(/(A,B,C),L,N):- calc_div(A,B,C,L,N).
test(-(A,B,C),L,N):- calc_sub(A,B,C,L,N).

calc_sub(A,B,C,L,N):-
B= BR-BC,
C=CR-CC,
element(L,BR,BC,E1,N),
element(L,CR,CC,E2,N),
check_sub(E1,E2,A).

calc_add(V,[],E,_,_):- V #= E.
calc_add(V,[A|B],E,L,N):-
A = AR-AC,
element(L,AR,AC,E1,N),
E2 #= E + E1,
calc_add(V,B,E2,L,N).

calc_mul(V,[],E,_,_):- V #= E.
calc_mul(V,[A|B],E,L,N):-
A=AR-AC,
element(L,AR, AC,E1,N),
E2 #= E * E1,
calc_mul(V,B,E2,L,N).

calc_div(A,B,C,L,N):-
B=BR-BC,
C=CR-CC,
element(L,BR,BC,E1,N),
element(L,CR,CC,E2,N),
check_div(E1,E2,A).

element(L, R, C, Value,N):-
nth(R,L,V),
nth(C,V,Value),
fd_domain(Value,1,N),
fd_labeling(Value).

check_sub(E1,E2,Result):-Result #=E1-E2.
check_sub(E1,E2,Result):-Result #=E2-E1 .

check_div(E1,E2,Result):-E2*Result #=E1.
check_div(E1,E2,Result):-E1*Result #=E2.

%implementation of plain_kenken/3
plain_kenken(N, [], L):-
length(L, N),
plain_distinct_null(N, L),
trans(L, LTrans),
plain_distinct_null(N, LTrans),
statistics.

plain_kenken(N, C, L):-
length(C,X),
X >= 1,
length(L, N),
plain_distinct(N, L),
plain_kenken1(N,C,L),
diff(L),
trans(L,LTrans1),
diff(LTrans1),
statistics.

plain_distinct_null(_, []).
plain_distinct_null(N, [Lx|Ly]):-
length(Lx, N),
gen(Lx,N),
different(Lx),
plain_distinct_null(N, Ly).

gen([],_).
gen([A|B],N):-
range(A,1,N),
gen(B,N).

plain_kenken1(_,[],_).
plain_kenken1(N,[X|Y],L):-
plain_test(X,L,N),
plain_kenken1(N,Y,L).

plain_distinct(_, []).
plain_distinct(N, [Lx|Ly]):-
length(Lx, N),
plain_distinct(N, Ly).

plain_test(+(A,B),L,N):-plain_calc_add(A,B,0,L,N).
plain_test(*(A,B),L,N):-plain_calc_mul(A,B,1,L,N).
plain_test(/(A,B,C),L,N):- plain_calc_div(A,B,C,L,N).
plain_test(-(A,B,C),L,N):- plain_calc_sub(A,B,C,L,N).

plain_calc_sub(A,B,C,L,N):-
B= BR-BC,
C=CR-CC,
plain_element(L,BR,BC,E1,N),
plain_element(L,CR,CC,E2,N),
plain_check_sub(E1,E2,A).

plain_calc_add(V,[],E,_,_):- =(V, E).
plain_calc_add(V,[A|B],E,L,N):-
A = AR-AC,
plain_element(L,AR,AC,E1,N),
E2 is E + E1,
plain_calc_add(V,B,E2,L,N).

plain_calc_mul(V,[],E,_,_):- =(V, E).
plain_calc_mul(V,[A|B],E,L,N):-
A=AR-AC,
plain_element(L,AR, AC,E1,N),
E2 is E * E1,
plain_calc_mul(V,B,E2,L,N).

plain_calc_div(A,B,C,L,N):-
B=BR-BC,
C=CR-CC,
plain_element(L,BR,BC,E1,N),
plain_element(L,CR,CC,E2,N),
plain_check_div(E1,E2,A).

plain_element(L, R, C, Value,N):-
nth(R,L,V),
nth(C,V,Value),
range(Value,1,N).

plain_check_sub(E1,E2,Result):-
E is E1-E2,
=(Result,E).
plain_check_sub(E1,E2,Result):-
E is E2-E1,
=(Result,E).

plain_check_div(E1,E2,Result):-
E is E2*Result,
=(E,E1).
plain_check_div(E1,E2,Result):-
E is E1*Result,
=(E,E2).

range(Low, Low, _).
range(Out,Low,High) :- NewLow is Low+1, NewLow =< High,range(Out, NewLow, High).

diff([]).
diff([Lx|Ly]):-
different(Lx),
diff(Ly).

different([]).
different([Lx|Ly]):-
\+(member(Lx,Ly)),
different(Ly).