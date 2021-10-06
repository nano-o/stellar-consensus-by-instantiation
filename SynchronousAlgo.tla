-------------------------- MODULE SynchronousAlgo --------------------------

(***************************************************************************)
(* `^This is a specification of the FBQS consensus algorithm for strong    *)
(* consensus clusters.  The algorithm is given in a synchronous            *)
(* round-by-round model implemented by the "scheduler" process below.^'    *)
(***************************************************************************)

EXTENDS PBQS, Utilities
        
CONSTANTS
    V, 
    InitVal, 
    \* `^The set of epoch. This should be the set of natural numbers, but it can be replaced by a finite set for model-checking:^'
    Epoch, 
    C \* `^A strong consensus cluster.^'

ASSUME IsStrongConsensusCluster(C)

Phase == 1..5

(*
--algorithm Consensus {
    variables
        adopted = [p \in P |-> [e \in Epoch |-> [i \in Phase |->
            IF e = 1 /\ i = 1 THEN InitVal[p] ELSE <<>> ]]],
        proposal = [p \in P |-> [e \in Epoch |-> IF e = 1 THEN InitVal[p] ELSE <<>>]],
        locked = [p \in P |-> FALSE],
        epoch = 1;
    define {
        \* A function to convert a PID to a processor:
        NumToProc == CHOOSE f \in [1..Cardinality(P) -> P] :
            \A p \in P : \E i \in DOMAIN f : f[i] = p
        \* The inverse of NumToProc:
        ProcToNum(p) == CHOOSE n \in 1..Cardinality(P) : NumToProc[n] = p

        Candidate(p) ==
            LET tuples == {t \in [epoch : Epoch, phase : Phase, val : V] :
                    adopted[p][t.epoch][t.phase] = t.val}
            IN MaxLexico(tuples)
           
        \* A record describing the highest value that blocks p at phase i of some epoch:
        MaxBlocking(p, i, H) ==
            LET tuples == {t \in [epoch: Epoch, phase : i..5, val: V] :
                    \/ \E B \in Blocking(p) : B \subseteq H /\ \A q \in B :
                            adopted[q][t.epoch][t.phase] = t.val }
            IN  IF tuples # {} THEN MaxLexico(tuples) ELSE <<>>
            
        \* The set of values that reached quorum threshold in phase i:
        GotQuorum(p, H, i) == {v \in V :
            \E Q \in Quorums(p) : Q \subseteq H /\
                \A q \in Q : adopted[q][epoch][i] = v }
                    
        HeardFrom == {H \in (SUBSET P) \ P : Cardinality(H) # 1 /\ H # {}} 
        \* Here we remove some sets to speed up model-checking
        
        Leader(e) == NumToProc[(e % Cardinality(P))+1] \* We use a rotating leader
        
        Safety == \A p,q \in C : \A e1,e2 \in Epoch : 
            \A v1,v2 \in V : adopted[p][e1][5] = v1 /\ adopted[q][e2][5] = v2 => v1 = v2
            
        Inv1 == \A p \in C : \A Q \in Quorums(p) : \A e \in Epoch : \A v,v2 \in V : \A e2 \in Epoch : 
            (\A q \in Q \cap WellBehaved : adopted[p][e][4] = v) /\ e2 > e =>  \A q \in Q : adopted[p][e2][1] = v2 => v = v2
    }

    
    (***********************************************************************)
    (* We now specify what a participant does upon changing round.  `proc` *)
    (* is the processor ID, `phase` is the current phase (1, 2, 3, 4, or   *)
    (* 5), and `H` is the set of processors that `proc` hears from in the  *)
    (* phase `phase`.                                                      *)
    (***********************************************************************)
    procedure changeRound(proc, phase, H) {
l0:     if (phase = 1) { 
            \* adopt the leader's proposal unless the lock prevents it.
l1:         with (v = proposal[Leader(epoch)][epoch]) {
                if (/\  Leader(epoch) \in H
                    /\  \/ \neg locked[proc] 
                        \/ Candidate(proc).val = v)
                    adopted[proc][epoch][1] := v;
            }
        };
l2:     if (phase \in 2..5) {
            if (GotQuorum(proc, H, phase-1) # {}) 
            \* some value has a unanimous quorum with phase `phase-1`
            with (v \in GotQuorum(proc, H, phase-1)) { \* pick one such value
                adopted[proc][epoch][phase] := v; \* adopt it for the current round
                if (phase = 4) locked[proc] := TRUE \* in phas4, lock the candidate
            } 
        };
l3:     if (phase = 5) { 
            with (b2 = MaxBlocking(proc, 2, H))
                \* unlock if the max phase-2 blocking value contradicts the candidate:
                if (b2 # <<>> /\ b2.val # Candidate(proc).val /\ b2.epoch > Candidate(proc).epoch)
                    locked[proc] := FALSE;
            if (proc = Leader(epoch+1) /\ epoch+1 \in Epoch) 
                \* set the proposal to the max phase-3 blocking value
                \* `epoch+1 \in Epoch` prevents the model-checker from generating an epoch that does not belong to `Epochs`.
                with (b3 = MaxBlocking(proc, 3, H))
                    if (b3 # <<>>) proposal[proc][epoch+1] := b3.val;
                    else proposal[proc][epoch+1] := Candidate(proc);
        };
l4:     return
    }
    
    process (scheduler = "sched") 
        variables procNum = 1, phase = 1;
    {
l5:     while (epoch \in Epoch) {
l6:         while (phase <= 5) {
l7:             while (procNum \in DOMAIN NumToProc) {
ll:                with (Heard \in HeardFrom) 
                        call changeRound(NumToProc[procNum], phase, Heard);
l8:                procNum := procNum+1
                };
                phase := phase+1;
                procNum := 1;
            };
            epoch := epoch + 1;
            phase := 1
        }
    }
}
*)
=============================================================================
\* Modification History
\* Last modified Tue Jan 07 11:49:27 PST 2020 by nano
\* Created Thu Nov 01 10:46:36 PDT 2018 by nano
