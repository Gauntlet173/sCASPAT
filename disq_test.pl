% Disqualification Test.
#include 'lpdat.pl'.

% if a rule is in a cycle of self-defeating rebuttals or refutations, not
% considering whether those rebuttals or refutations are by defeated rules,
% then it is "disqualified".

according_to(a,b).
according_to(c,d).
opposes(a,b,c,d).
according_to(e,f).
opposes(c,d,e,f).
opposes(e,f,a,b).

?- disqualified(A,B).
% returns 12 models, beacuse there are three disqualified rules a, c, e, and each is diqualified
% in four ways, because each of the defeating relationships to the other two is bi-directional.