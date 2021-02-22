# Explainable Argumentation Theory for Defeasibility in Legal Knowledge Representation in s(CASP)

An implementation of Logic Programming with Defaults and Argumentation Theories in s(CASP).

By Jason Morris, for the SMU Centre for Computational Law.

## s(CASP)

For details on s(CASP) [see here](https://gitlab.software.imdea.org/ciao-lang/sCASP).

## LPDAT

Logic Programming with Defaults and Argumentation Theories is described in
Wan H., Grosof B., Kifer M., Fodor P., Liang S. (2009) Logic Programming with Defaults and Argumentation Theories. In: Hill P.M., Warren D.S. (eds) Logic Programming. ICLP 2009. Lecture Notes in Computer Science, vol 5649. Springer, Berlin, Heidelberg. https://doi.org/10.1007/978-3-642-02846-5_35

## What is this for?

s(CASP) by itself allows you to write rules that are exceptions to other rules, as follows:

```
flies(X) :- bird(X), not -flies(X).

bird(X) :- penguin(X).

-flies(X) :- penguin(X).

penguin(tweety).

?- flies(tweety). % returns no models.
?- -flies(tweety). % returns true.
```

Argumentation theory is another way to achieve defeasibility that gets you two advantages: the ability to
choose an argumentation theory for your ruleset in a modular way, and the ability to specify exceptions at
whatever location in your code you prefer, instead of being forced to place them in the conditions of the defeated rule.

## Usage

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

Legal materials that say "subject to" can have the `override` statement placed with the default rule,
and legal materials that say "despite" can have the `override` statement placed with the exception to the default rule.
This eliminates reformulation of default rules to include their exceptions in the conditions which makes legal rules easier to encode one at a time. It also simplifies code maintenance when rules change
by better maintaining the one-to-one relationship between source materials and code.

## Explainable

Because s(CASP) generates human-readable explanations, the defeasibility
relationships between your rules can be easily seen and used to explain the conclusions of the tool.


## Example Output

If the above code is run with the question `?- not holds(flies(tweety)).` and the command
`scasp lpdat_test.pl --human --tree --pos` you should get the following:

```
QUERY:I would like to know if
     there is no evidence that the conclusion flies(tweety) from rule default ultimately holds.

        ANSWER: 1 (in 4.535 ms)

JUSTIFICATION_TREE:
according to default, tweety flies, because
    tweety is a bird, because
        tweety is a penguin.
the conclusion flies(tweety) from rule default is defeated, because
    the conclusion flies(tweety) from rule default conflicts with the conclusion -flies(tweety) from rule penguin, and
    the conclusion flies(tweety) from rule default is defeated by refutation by the conclusion -flies(tweety) from rule default, because
        the conclusion flies(tweety) from rule default is refuted by the conclusion -flies(tweety) from rule penguin, because
            the conclusion flies(tweety) from rule default conflicts with the conclusion -flies(tweety) from rule penguin, justified above, and
            the conclusion -flies(tweety) from rule penguin overrides the conclusion flies(tweety) from rule default, and
            according to default, tweety flies, justified above, and
            according to penguin, tweety does not fly, because
                tweety is a penguin, justified above.
The global constraints hold.

MODEL:
{ not holds(default,flies(tweety)),  according_to(default,flies(tweety)),  bird(tweety),  penguin(tweety),  defeated(default,flies(tweety)),  opposes(default,flies(tweety),penguin,-flies(tweety)),  defeated_by_refutation(default,flies(tweety),penguin,-flies(tweety)),  refuted_by(default,flies(tweety),penguin,-flies(tweety)),  overrides(penguin,-flies(tweety),default,flies(tweety)),  according_to(penguin,-flies(tweety)) }
```

If you change the query to `?- holds(X,Y).`, you will get one model:

```
QUERY:I would like to know if
     the conclusion B from rule A ultimately holds.

        ANSWER: 1 (in 51.537 ms)

JUSTIFICATION_TREE:
the conclusion -flies(tweety) from rule penguin ultimately holds, because
    according to penguin, tweety does not fly, because
        tweety is a penguin.
The global constraints hold.

MODEL:
{ holds(penguin,-flies(tweety)),  according_to(penguin,-flies(tweety)),  penguin(tweety),  not defeated(penguin,-flies(tweety)),  not opposes(penguin,-flies(tweety),C | {C \= default},D),  not opposes(C | {C \= default},D,penguin,-flies(tweety)),  not opposes(penguin,-flies(tweety),default,flies(E | {E \= tweety})),  not opposes(default,flies(E | {E \= tweety}),penguin,-flies(tweety)),  not opposes(penguin,-flies(tweety),F | {F \= default},G),  not opposes(F | {F \= default},G,penguin,-flies(tweety)),  not opposes(penguin,-flies(tweety),default,flies(H | {H \= tweety})),  not opposes(default,flies(H | {H \= tweety}),penguin,-flies(tweety)),  not opposes(penguin,-flies(tweety),I | {I \= default},J),  not opposes(I | {I \= default},J,penguin,-flies(tweety)),  not opposes(penguin,-flies(tweety),default,flies(K | {K \= tweety})),  not opposes(default,flies(K | {K \= tweety}),penguin,-flies(tweety)) }

BINDINGS: 
A equal penguin 
B equal -flies(tweety) ? ;
```

## Abduction over Argumentation

In combination with s(CASP)'s abudctive reasoning, using this library makes it possible to ask questions like "what rule would need to override what other rule in order for this conclusion to be true in this fact scenario?"

## Not For Deployment

The included demonstration runs, but the library is still a work in progress. We have not yet
confirmed that all of the features of the argumentation theory are working properly.