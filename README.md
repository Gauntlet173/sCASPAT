# s(CASP)AT

An implementation of Logic Programming with Defaults and Argumentation Theories in s(CASP).

By Jason Morris, for the SMU Centre for Computational Law.

## s(CASP)

For deatils on s(CASP) [see here](https://gitlab.software.imdea.org/ciao-lang/sCASP).

## LPDAT

Logic Programming with Defaults and Argumentation Theories is described in
Wan H., Grosof B., Kifer M., Fodor P., Liang S. (2009) Logic Programming with Defaults and Argumentation Theories. In: Hill P.M., Warren D.S. (eds) Logic Programming. ICLP 2009. Lecture Notes in Computer Science, vol 5649. Springer, Berlin, Heidelberg. https://doi.org/10.1007/978-3-642-02846-5_35

## What is this for?

s(CASP) allows you to write rules that are exceptions to other rules, as follows:

```
flies(X) :- bird(X), not -flies(X).

bird(X) :- penguin(X).

-flies(X) :- penguin(X).

penguin(tweety).

?- flies(tweety). % returns no models.
?- -flies(tweety). % returns true.
```

The two advantages that using argumentation theory adds to this capability are the ability to
choose an argumentation theory in a modular way, and the ability to specify exceptions at
whatever location in your code you might like.

The interface to the argumentation theory is three predicates:

* `according_to(Rule,Conclusion)` sets out the things your knowledge base defeasibly concludes.
* `opposes(Rule,Conclusion,OtherRule,OtherConclusion)` sets out conclusions that conflict, and
  this needs to be done explicitly, and in a fully-grounded way.
* `overrides(Rule,Conclusion,OtherRule,OtherConclusion)` sets out that Rule defeats Other Rule
  with regard to the conflict between Conclusion and Other Conclusion.

Those three predicates can then be used in different ways by different argumentation theories.
In the background, the argumentation theories calculate whether rules are "defeated", "rebutted",
"refuted", "disqualified", etc. The primary interface for getting results is `holds(Rule,Conclusion)`
which is true when a conclusion is defeasibly found, and not defeated.

Note that currently only one argumentation theory is implemented.

So the above code can be rewritten as follows:

```
#include 'lpdat.pl'.

% usually, birds fly
according_to(default,flies(X)) :- bird(X).

% penguins are birds
bird(X) :- penguin(X).

% penguins don't fly.
according_to(penguin,-flies(X)) :- penguin(X).

% the conclusions flies(X) and -flies(X) from default and penguin are in conflict
opposes(default,flies(X),penguin,-flies(X)).

% in the conflict between penguin and default, penguin wins.
overrides(penguin,-flies(X),default,flies(X)).

penguin(tweety).

?- holds(default,flies(tweety)). %no models
?- holds(penguin,-flies(tweety)). % success
```

In addition to being able to change the argumentation theory in one place instead of needing
to change it anywhere an exception is stated, this also gives you the ability to express
the defeasibility relationship wherever in the code it is represented in your source materials.

Legal materials that say "subject to" can have the `override` statement placed with the default,
and legal materials that say "despite" can have the `override` statement placed with the exception.
This eliminating reformulation of rules to include their exceptions, and simplifies maintenance
by maintaining a one-to-one relationship between source materials and code.

## Not For Deployment

The included demonstration runs, but the library is still a work in progress. We have not yet
confirmed that all of the features of the argumentation theory are working properly.