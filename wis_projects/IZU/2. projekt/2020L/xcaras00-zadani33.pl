% Author: Elena Carasec (xcaras00)

uloha33([], []).

uloha33([InHead|InTail], [OutHead|OutTail]) :-
    ((InHead mod 2 =:= 0,
    OutHead is InHead - 1);
    (InHead mod 2 =:= 1,
    OutHead is InHead)),
    uloha33(InTail, OutTail).
