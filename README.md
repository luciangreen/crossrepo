# crossrepo

detect when a change in one of your repos breaks another. Each repo exports predicates (Name/Arity) and imports some from other repos. A change removes or adds exports; a repo breaks if it imports something no longer exported, and a repo that depends on a broken repo is at risk too. Adding exports never breaks anything. Repos: repo(Name, Exports, Imports) with Imports as From:Name/Arity.

## Use

```prolog
?- use_module(prolog/crossrepo).
?- broken([repo(mnns, [opt/2], []), repo(fastos, [run/1], [mnns:opt/2])], change(mnns, remove([opt/2])), B).   % B = [fastos]
?- at_risk([repo(a, [f/1], []), repo(b, [g/1], [a:f/1]), repo(c, [], [b:g/1])], change(a, remove([f/1])), R).  % R = [b, c]
```

## Proofs

`proofs/theorems.pl` proves 4 theorems by exhaustion: each one is checked for every case in a finite domain that covers every branch of the definitions. three repos a, b, c; a exports from {f/1, g/2}; b imports any of a's; c imports from a or b; every change to a.

1. Adding exports never breaks a repo that wasn't already broken.
2. A repo is broken exactly when one of its imports is missing after the change.
3. Everything at risk is broken or depends (directly or not) on something broken, and every broken repo is at risk.
4. Removing nothing changes nothing.

```sh
swipl -g main -t halt proofs/theorems.pl
```

## 200 inputs and outputs

`io/ios.txt` lists 200 inputs and outputs from real runs, and `io/ios.pl` has the same as Prolog facts. The inputs come from a fixed seed (`io/cases.pl`). `swipl -g check -t halt io/run.pl` runs them again. It fails if any output changes, or if a predicate doesn't confirm its own recorded output, which checks steadfastness. GitHub Actions runs the proofs and the examples on every push, and records the examples on the first push.

Licence: BSD-3-Clause.
