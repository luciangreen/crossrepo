% Theorems, proved by exhaustion. Run: swipl -g main -t halt proofs/theorems.pl
:- module(theorems, [main/0]).
:- use_module(prove).
:- discontiguous theorem/1.
:- use_module(library(lists)).
:- use_module(library(apply)).
main :- prove_all(theorems).
:- use_module('../prolog/crossrepo').

% Domain: three repos a, b, c; a exports from {f/1, g/2}; b imports any of a's; c imports from a or b; every change to a.
subset_of([], []).
subset_of([X|Xs], [X|Ys]) :- subset_of(Xs, Ys).
subset_of([_|Xs], Ys) :- subset_of(Xs, Ys).
repos([repo(a, EA, []), repo(b, [h/1], IB), repo(c, [], IC)]) :- subset_of([f/1, g/2], EA), subset_of([a:f/1, a:g/2], IB), subset_of([a:f/1, b:h/1], IC).
change(change(a, remove(X))) :- subset_of([f/1, g/2], X).
change(change(a, add(X))) :- subset_of([f/1, g/2, k/3], X).

% 1. Adding exports never breaks a repo that wasn't already broken.
theorem(adding_never_breaks) :- forall(( repos(Rs), change(C), C = change(_, add(_)) ), ( broken(Rs, C, B), broken(Rs, change(a, add([])), B0), subtract(B, B0, []) )).

% 2. A repo is broken exactly when one of its imports is missing after the change.
theorem(broken_is_exact) :- forall(( repos(Rs), change(C), apply_change(Rs, C, Rs2), broken(Rs, C, B), member(repo(M, _, I), Rs2) ),
    iff(memberchk(M, B), ( member(F:P, I), \+ ( member(repo(F, E, _), Rs2), memberchk(P, E) ) ))).

% 3. Everything at risk is broken or depends (directly or not) on something broken, and every broken repo is at risk.
theorem(risk_is_the_closure) :- forall(( repos(Rs), change(C) ), ( broken(Rs, C, B), at_risk(Rs, C, R), subtract(B, R, []), forall(member(X, R), ( memberchk(X, B) ; dependents(Rs, Y, Ds), memberchk(X, Ds), memberchk(Y, R) )) )).

% 4. Removing nothing changes nothing.
theorem(empty_change_is_harmless) :- forall(repos(Rs), ( apply_change(Rs, change(a, remove([])), Rs2), Rs2 == Rs )).
