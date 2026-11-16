:- module(cases, [title/1, case/3]).
:- use_module('../prolog/crossrepo').
:- use_module(engine).
title('crossrepo').
names_g([mnns, detlog2, plop2, fastos, lucianos, s2a2]).
exports_g(Es) :- rnd_subset([opt/2, run/1, parse/2, prove/3], Es).
repos_g(Rs) :- names_g(Ns), foldl([N, A0, A]>>( exports_g(E), findall(M:P, ( member(repo(M, EM, _), A0), member(P, EM), rnd_chance(40) ), I), append(A0, [repo(N, E, I)], A) ), Ns, [], Rs).
change_g(Rs, change(N, Op)) :- findall(M, member(repo(M, _, _), Rs), Ms), rnd_pick(Ms, N), memberchk(repo(N, E, _), Rs), rnd_subset(E, Rm), ( rnd_chance(70) -> Op = remove(Rm) ; Op = add([new/1]) ).
case(broken, [Rs, C], broken) :- repos_g(Rs), change_g(Rs, C).
case(at_risk, [Rs, C], at_risk) :- repos_g(Rs), change_g(Rs, C).
case(dependents, [Rs, R], dependents) :- repos_g(Rs), names_g(Ns), rnd_pick(Ns, R).
