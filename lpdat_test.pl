#include 'lpdat.pl'.

% By default, a bird flies.
#pred according_to(R,flies(X)) :: 'according to @(R), @(X) flies'.
#pred according_to(R,-flies(X)) :: 'according to @(R), @(X) does not fly'.
#pred bird(X) :: '@(X) is a bird'.
#pred penguin(X) :: '@(X) is a penguin'.

opposes(default,flies(X),penguin,-flies(X)).

according_to(default,flies(X)) :- bird(X).

% A penguin is a bird.
bird(X) :- penguin(X).

% Penguins do not fly, despite the default.
according_to(penguin,-flies(X)) :- penguin(X).
overrides(penguin,-flies(X),default,flies(X)).

% tweety is a penguin.
%#abducible penguin(X).
%#abducible bird(X).
penguin(tweety).

?- not holds(default,flies(tweety)).
%?- holds(X,Y). %returns only penguin,-flies(tweety).