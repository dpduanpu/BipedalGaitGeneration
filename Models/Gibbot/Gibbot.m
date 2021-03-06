(* ::Package:: *)

(************************************************************************)
(* This file was generated automatically by the Mathematica front end.  *)
(* It contains Initialization cells from a Notebook file, which         *)
(* typically will have the same name as this file except ending in      *)
(* ".nb" instead of ".m".                                               *)
(*                                                                      *)
(* This file is intended to be loaded into the Mathematica kernel using *)
(* the package loading commands Get or Needs.  Doing so is equivalent   *)
(* to using the Evaluate Initialization Cells menu command in the front *)
(* end.                                                                 *)
(*                                                                      *)
(* DO NOT EDIT THIS FILE.  This entire file is regenerated              *)
(* automatically each time the parent Notebook file is saved in the     *)
(* Mathematica front end.  Any changes you make to this file will be    *)
(* overwritten.                                                         *)
(************************************************************************)



(* ::Input::Initialization:: *)
BeginPackage["BipedalLocomotion`Gibbot`", {"GlobalVariables`", "RigidBodyDynamics`", "BipedalLocomotion`", "BipedalLocomotion`Model`"}]

Gibbot::usage = "";

Begin["`Private`"]


(* ::Input::Initialization:: *)
(* parameters *)
m = 3.083276839957533;
L = 0.61;
p = 6.376870661657008 10^-2;
Iz = 5.386568898408416 10^-2;
g = {0, 9.81, 0};
nap = 1;

(* points of interest *)
foot = {0, -L, 0};
left = {"left leg", foot};
right = {"right leg", foot};


(* ::Input::Initialization:: *)
cm[s_, A_] := Module[{q, v, a, n, \[Theta]0T, C},
(* BLc indices *)
n = mm -1; (* 2D *)
(* get prismatic base joints and velocities *)
{q, v} = Partition[BLIndices[BLGetBipedBase[], "p", "n" -> {\[DoubleStruckQ], \[DoubleStruckV]}], n];
(* joints are part of 2 np holonomic and Pfaffian constraints *)
q = "q" -> {q, Range@Length@q, 2A["np", s]};
(* velocities are part of np Pfaffian constraints *)v = "v" -> {v, Range@Length@v, A["np", s]};

(* scaling factors for phase variable \[Theta] *)
\[Theta]0T = A["\[Theta]", s];

(* function specific parameters *)
a = <|"BLc" -> <|q, v|>, "BLc0T" -> <|"\[Theta]" -> \[Theta]0T|>, "BLSummary" -> <|"P" -> <|0 -> BLSide[s, {left, right}, 1;;1]|>|>|>;

(* create parameters *)
C = BLContinuationParameters[Association -> a];

<|s -> C|>
];

viz[] := Module[{r},
r = {4, 5, 6};
BLDontDraw[{"left leg"}];
BLWidth[0.09];
BLRadius[0.1];
<|
"axes" -> {1,2},

"scale" -> L,

"poi" -> <|"left foot" -> \[DoubleStruckB]["left leg", r, foot], "right foot" -> \[DoubleStruckB]["right leg", r, foot]|>,

"lc" -> <|"right foot" -> LightPurple, "left foot" -> Purple|>
|>
];

CreateModel[] := Module[{com, c},
com = {0, -p, 0};

RBDNewModel[];
RBDLink["\[Theta]", Root, "m" -> 1, "S"-> "pz"];
RBDLink["left leg", Root, "m" -> m, "com" -> com, "I" -> {0, 0,Iz}, "S"-> "pln"];

RBDLink["right leg", "left leg", "m" -> m, "com" -> com, "I" -> {0, 0,Iz}, "S"-> "rz"];

RBDCreateModel["g" -> g];
];


(* ::Input::Initialization:: *)
Gibbot[n_:0] := Module[{A, C, X, J, l, r, draw, F, L, R},
CreateModel[];

(* coordinate flip *)
BLA[];
A = IdentityMatrix[nq];
A[[4, 5]] = 1;
A[[5, 5]] = -1;
A = ArrayFlatten[{{A, 0}, {0, A}}];

(* feet constraints *)
F = {left, right};

(* create dynamic regimes *)
L = BLRegime["left", "P" -> <|0 -> {left}|>, "S" -> F];
R = BLRegime["right", "P" -> <|0 -> {right}|>, "S" -> Reverse@F];
C = Join[L, R];

(* create jumps given state of biped at transition at t- (pre-impact) *)
L = BLxT["left", "ST" -> right, "SW" -> left, "A" -> A];
R = BLxT["right", "ST" -> left, "SW" -> right, "A" -> A];
X = Join[L, R];

A = BLCreateBiped["Gibbot", C, X, viz[], F, <|"A" -> A|>];
C = Join[cm["left", A], cm["right", A]];
BLCreateContinuationParameters["right", C];

BLCompileBiped[n]
];


(* ::Input::Initialization:: *)
End[]
EndPackage[]
