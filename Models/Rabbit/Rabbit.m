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
BeginPackage["BipedalLocomotion`Rabbit`", {"GlobalVariables`", "RigidBodyDynamics`", "BipedalLocomotion`", "BipedalLocomotion`Model`"}]

RabbitP::usage = "";
Rabbit::usage = "";

Begin["`Private`"]


(* ::Input::Initialization:: *)
g = {0, 9.81, 0};

(* poi's in link coordinates *)
foot = {0, -Ltib, 0};
trunk = {0, Ltor, 0};

left = {"left tib", foot};
right = {"right tib", foot};


(* ::Input::Initialization:: *)
(* pre-impact stance x[0-]/c- *)
stsw[s_] := If[StringMatchQ[s, "left"], {"left", "right"}, {"right", "left"}];

pcon[s_] := <|0 -> {If[StringMatchQ[s, "left"], left, right]}|>;


(* ::Input::Initialization:: *)
model2007[] := Module[{},
(* parameters from [1] & [2] *)
Mtor = 12;
Mfem = 6.8;
Mtib = 3.2;

Ltor = 0.63;
Lfem = 0.4;
Ltib = 0.4;

Itor = 1.33;
Ifem = 0.47;
Itib = 0.20;

ptor = 0.24;
pfem = 0.11;
ptib = 0.24;
];

model2003[] := Module[{},
(* parameters from [3], unactuated gaits are bird-like *)
Mtor = 20;
Mfem = 6.8;
Mtib = 3.2;

Ltor = 0.625;
Lfem = 0.4;
Ltib = 0.4;

Itor = 2.22;
Ifem = 1.08;
Itib = 0.93;

ptor = 0.2;
pfem = 0.163;
ptib = 0.128;
];


(* ::Input::Initialization:: *)
cm[s_, A_] := Module[{q, v, a, n, \[Theta]0T, t, w, C},
(* BLc indices *)
n = mm -1; (* 2D *)
{q, v} = Partition[BLIndices[BLGetBipedBase[], "p", "n" -> {\[DoubleStruckQ], \[DoubleStruckV]}], n];
q = "q" -> {q, Range@Length@q, 2A["np", s]};
v = "v" -> {v, Range@Length@v, A["np", s]};

(* polynomial scaling factors *)
\[Theta]0T = A["\[Theta]", s];

{t, w}  = stsw[s]; (* other leg shows controls affected by \[DoubleStruckC][s] *)

(* BLSummary controls *)
n = <|"P" -> pcon[w], "V" -> vcon[w]|>;

(* function specific parameters *)
a = <|"BLc" -> <|q, v|>, "BLc0T" -> <|"\[Theta]" -> \[Theta]0T|>, "BLSummary" -> n|>;

(* create parameters *)
C = BLContinuationParameters["q" -> qrm[s], "v" -> vrm[s], "\[Alpha]" -> A["\[Alpha]", s, "\[Alpha]f"], Association -> a];

<|s -> C|>
];

viz[] := Module[{r},
r = {4, 5, 6};
BLDontDraw[{"torso"}];
BLWidth[0.06];
BLRadius[0.08];

<|
"axes" -> {1, 2},

"scale" -> Lfem+Ltib,

"poi" -> <|"left foot" -> \[DoubleStruckB]["left tib", r, foot], "right foot" -> \[DoubleStruckB]["right tib", r, foot], "trunk" -> \[DoubleStruckB]["torso", r, trunk]|>,

"lc" -> <|"right foot" -> LightGray, "right tib" -> LightGray|>
|>
];

CreateModel[] := Module[{},
RBDNewModel[];

RBDLink["\[Theta]", Root, "m" -> 1, "S"-> "pz"];

RBDLink["torso", Root, "m" -> Mtor, "S"-> "pln", "I" -> {0, 0, Itor}, "com" -> {0, 0, 0, 0, ptor, 0}];

RBDLink[{"left fem", "right fem"}, "torso", "m" -> Mfem, "S"-> "rz", "I" -> {0, 0, Ifem}, "com" -> {0, 0, 0, 0, -pfem, 0}];

RBDLink[{"left tib", "right tib"}, {"left fem", "right fem"}, "m" -> Mtib, "I" -> {0, 0, Itib}, "com" -> {0, 0, 0, 0, -ptib, 0}, "S"-> "rz", "loc" -> {0,0,0,0,-Lfem,0}];

RBDCreateModel["g" -> g];
];


(* ::Input::Initialization:: *)
RabbitP[cp_, opts:OptionsPattern[]] := RabbitP[BLbiped["m[0]"], cp, opts]["R"];

Rabbit[n_:0, k_:1, m07_:True] := Module[{A, c, x, l, r, J, F},
(* model *)
If[TrueQ@m07, model2007[], model2003[]];
CreateModel[];

VHC[k];

A = BLA[];

(* regimes *)
F = {left, right};

l = BLRegime["left", "P" -> pcon["left"], "V" -> vcon["left"], "Pcon" -> P["left"], "S" -> F];

r = BLRegime["right", "P" -> pcon["right"], "V" -> vcon["right"], "Pcon" -> P["right"], "S" -> Reverse@F];

c = Join[l, r];

(* pre-impact stance/post-impact mode *)
l = BLxT["left", "ST" -> right, "SW" -> left, "A" -> A];
r = BLxT["right", "ST" -> left, "SW" -> right, "A" -> A];
x = Join[l, r];

A = BLCreateBiped["Rabbit", c, x, viz[], F, <|"A" -> A|>];

c = Join[cm["left", A], cm["right", A]];
BLCreateContinuationParameters["right", c];

BLCompileBiped[n]
];


(* ::Input::Initialization:: *)
End[]
EndPackage[]