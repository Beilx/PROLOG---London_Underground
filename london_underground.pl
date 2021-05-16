connect(maida_vale , warwick_avenue , 0.79 ,  1.50 , bakerloo).
connect(warwick_avenue , paddington , 0.88, 1.58,  bakerloo).
connect(paddington , royal_oak , 0.64 , 1.33 , hammersmith).
connect(royal_oak , westbourne_park , 0.98 , 1.72 ,  hammersmith).
connect(westbourne_park , ladbroke_grove , 0.79 , 1.48 ,  hammersmith).
connect(ladbroke_grove , latimer_road , 0.66 , 1.28 ,  hammersmith).
connect(latimer_road , white_city , 1.01 , 1.70 ,  hammersmith).
connect(paddington , edgeware_road , 0.82, 1.85 , circle).
connect(paddington , bayswater , 0.98 , 1.65 , circle).
connect(bayswater , notting_hill_gate , 0.79 , 1.47 , circle).
connect(notting_hill_gate , holland_park , 0.61 , 1.18 , central).
connect(holland_park , sheperds_bush , 0.87 , 1.52 , central).
connect(sheperds_bush , white_city , 1.16 , 2.77 , central).
connect(notting_hill_gate , queensway , 0.69 , 1.18 , central).
connect(queensway , lancaster_gate , 0.90 , 1.65 , central).
connect(lancaster_gate , marble_arch , 1.20 , 1.62 , central).
connect(marble_arch , bond_street , 0.55 , 1.02 , central).
connect(bond_street , oxford_circus , 0.66 , 1.03 , central).
connect(oxford_circus , warren_street , 0.90 , 1.72 , victoria).
connect(oxford_circus , tottenham_court_road , 0.58 , 0.98 , central).
connect(tottenham_court_road , holborn , 0.88 , 1.63 , central).
connect(holborn , russell_square , 0.72 , 1.55 , piccadily).
connect(russell_square , kings_cross , 0.91 , 1.90 , piccadily).
connect(kings_cross , euston , 0.74 , 1.32 , victoria).
connect(euston , warren_street , 0.76 , 1.30 , victoria).





% If stop A is connected to stop C, then C is also connected to A with
% the same line L, length X and time V.


next(A,C,X,V,L):-connect(A,C,X,V,L).
next(A,C,X,V,L):-connect(C,A,X,V,L).




% Path predicate for finding the path between two
% station,recursively updating each path's respective length and time
% at each stop.


path([B | Left], B, [B | Left], Length, Length,Time,Time).
path([A | Left], B, Path, TempLength, Length, TempTime,Time) :-
               next(A, C, X,V,_),
               \+member(C, [A | Left]),
               UpdateLength is TempLength + X,
               UpdateTime is TempTime + V,
               path([C, A | Left],B,Path,UpdateLength,Length,UpdateTime,Time).




% Path predicate for findng all possible paths, with their respective
% lenght and time.


all_paths(A, B) :-
  path([A], B, Path, 0, Length,0,Time),
  reverse(Path, StraightPath),
  print(StraightPath),
  write('with a length (in km) of '), print(Length),
  write(', and time (in mins) of '),  print(Time),nl,nl,
  fail.




% Minimum path calculation by comparing the diferent 'Lengths/times',
% and picking the smallest one.



minCalc([[Path, Length]], [Path, Length]).
minCalc([[Path,Length] | Left],[Path2,Length2]):-
                                        minCalc(Left,[Path1,Length1]),
                                        Length < Length1 ->
                                        Path2 = Path,
                                        Length2 = Length;
                                        Length >= Length1 ->
                                        Path2 = Path1,
                                        Length2 = Length1.




% Predicate for the path with the shortest distance in km between two
% stations.


min_km(A,End,Min):-
   bagof([Path,Length],path([A],End,Path,0,Length,0,_),List),minCalc(List,Min).




% Predicate for the path with the lowest time in minutes between two
% stations.


min_time(A,End,Min):-
    bagof([Path,Time],path([A],End,Path,0,_,0,Time),List),minCalc(List,Min).





% This gives the case when the path between two station A and C lies on
% the same underground line L, where S is the temporary route covered
% while F is the final route.


straightlink(A,C,L,S,[C|S]):- next(A,C,_,_,L).
straightlink(A,C,L,S,F):-
    next(A,Z,_,_,L),\+(member(Z,S)),
       straightlink(Z,C,L,[Z|S],F).




% Case where the path between two stations A and C requires one
% change, with Z being the interchange station and L and L2 being the
% two different lines.


one_change(A,C,L,F):-
        straightlink(A,Z,L,[A],F1),
        straightlink(Z,C,L2,[Z|F1],F),L\=L2.



% Case where the path between two stations A and C requires two
% changes, with Z and U being the interchange stations, and L, L1 and L2
% being the three different lines.



two_change(A,C,L,F):-
        straightlink(A,Z,L1,[A],F1),
        straightlink(Z,U,L2,[Z|F1],F2),L1\=L2,
        straightlink(U,C,L,[U|F2],F),L\=L1,L\=L2.




% Case where the path between two stations A and C requires three
% changes, with Z,U and R being the interchange stations and L, L1,
% L2 and L3 being the four different lines.



three_change(A,C,L,F):-
        straightlink(A,Z,L1,[A],F1),
        straightlink(Z,U,L2,[Z|F1],F2),L1\=L2,
        straightlink(U,R,L3,[U|F2],F3),L3\=L1,L3\=L2,
        straightlink(R,C,L,[R|F3],F),L\=L1,L\=L2,L\=L3.




% Condition to check that a station actually exists in case of any
% errors.
exist(A):-next(A,_,_,_,_).


% Checks if route between two station requires no changes by querying
% straightlink and if true writes the message 'No change required'.


route(A,C,F):-exist(A),exist(C),
       straightlink(A,C,_,[A],F),
       write('No change required'),nl,
       re_write(F).




% Checks if route between two station requires one change by querying
% one_change, and if true writes the message 'One change required'.


route(A,C,F):-exist(A),exist(C),
              one_change(A,C,_,F),
              write('One change required'),nl,
              re_write(F).




% Checks if route between two station requires two changes by querying
% two_change and if true writes the message 'Two changes required'.



route(A,C,F):-exist(A),exist(C),
       two_change(A,C,_,F),
       write('Two changes required'),nl,
       re_write(F).



% Checks if route between two station requires three changes by querying
% three_change and if true writes the message 'Three change required'.


route(A,C,F):-exist(A),exist(C),
       three_change(A,C,_,F),
       write('Three changes required'),nl,
       re_write(F).



% Reverses the order (Tail first and then Head) and adds a separator for
% clarity.

re_write([X1]):-write(X1).
re_write([H1|T1]):-re_write(T1), write('->'),write(H1).
