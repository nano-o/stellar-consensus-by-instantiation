----------------------------- MODULE Utilities -----------------------------

EXTENDS FiniteSets, Naturals, Sequences
    
Max(S, LessEq(_,_)) == CHOOSE e \in S : \A e1 \in S : LessEq(e1,e)
LessEqLexico(x,y) ==
        \/  x.epoch < y.epoch
        \/  x.epoch = y.epoch /\ x.phase < y.phase
        \/  x.epoch = y.epoch /\ x.phase = y.phase
MaxLexico(S) ==  Max(S, LessEqLexico)

=============================================================================
\* Modification History
\* Last modified Thu Oct 10 14:24:32 PDT 2019 by nano
\* Created Thu Oct 10 14:23:41 PDT 2019 by nano
