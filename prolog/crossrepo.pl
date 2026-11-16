% crossrepo: detect when a change in one of your repos breaks another. Each repo exports
% predicates (Name/Arity) and imports some from other repos. A change removes or adds exports;
% a repo breaks if it imports something no longer exported, and a repo that depends on a broken
% repo is at risk too. Adding exports never breaks anything.
% Repos: repo(Name, Exports, Imports) with Imports as From:Name/Arity.
%?- broken([repo(mnns, [opt/2], []), repo(fastos, [run/1], [mnns:opt/2])], change(mnns, remove([opt/2])), B).   % B = [fastos]
%?- at_risk([repo(a, [f/1], []), repo(b, [g/1], [a:f/1]), repo(c, [], [b:g/1])], change(a, remove([f/1])), R).  % R = [b, c]
:- module(crossrepo, [apply_change/3, broken/3, at_risk/3, dependents/3]).
:- use_module(library(lists)).
:- use_module(library(apply)).

apply_change(Rs, change(N, remove(Xs)), Rs2) :- maplist([repo(M, E, I), repo(M, E2, I)]>>( M == N -> subtract(E, Xs, E2) ; E2 = E ), Rs, Rs2).
apply_change(Rs, change(N, add(Xs)), Rs2) :- maplist([repo(M, E, I), repo(M, E2, I)]>>( M == N -> append(E, Xs, E1), sort(E1, E2) ; E2 = E ), Rs, Rs2).

% broken(+Repos, +Change, -Broken): repos whose imports are no longer all exported after the change.
broken(Rs, Ch, B) :- apply_change(Rs, Ch, Rs2), findall(M, ( member(repo(M, _, I), Rs2), member(F:P, I), \+ ( member(repo(F, E, _), Rs2), memberchk(P, E) ) ), B0), sort(B0, B).

% dependents(+Repos, +Repo, -Ds): repos that import from Repo.
dependents(Rs, R, Ds) :- findall(M, ( member(repo(M, _, I), Rs), member(R:_, I) ), D0), sort(D0, Ds).

% at_risk(+Repos, +Change, -Risk): the broken repos and everything that depends on them, directly or not.
at_risk(Rs, Ch, R) :- broken(Rs, Ch, B), close(Rs, B, B, R0), sort(R0, R).
close(_, [], Seen, Seen).
close(Rs, [X|Q], Seen, R) :- dependents(Rs, X, Ds), subtract(Ds, Seen, New), append(Seen, New, Seen1), append(Q, New, Q1), close(Rs, Q1, Seen1, R).
