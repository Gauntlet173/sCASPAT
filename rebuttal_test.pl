% Test for whether Rebuttal works properly.

#include 'lpdat.pl'.

according_to(source1,yeap).
according_to(source2,nope).

opposes(source1,yeap,source2,nope).

?- not holds(X,Y).
% This correctly returns the following models:
% 1. The rule is not source1 and not source2.
% 2. The rule is source1, but the conclusion is not yeap.
% 3. The rule is source2, but the conclusion is not nope. (reported twice for some reason)
% 4. The rule is source1, the conclusion is yeap, but it is rebutted.
% 5. The rule is source2, the conclusion is nope, but it is rebutted.