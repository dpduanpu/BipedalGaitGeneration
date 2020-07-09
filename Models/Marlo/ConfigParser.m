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
BeginPackage["BipedalLocomotion`Marlo`", {"GlobalVariables`", "RigidBodyDynamics`", "BipedalLocomotion`", "BipedalLocomotion`Model`"}]

Begin["`Private`"]

data = Import["Marlo/marlo-dat.csv"][[2;;]];


(* ::Input::Initialization:: *)
MarloRBD["torso"]  := Module[{side},
MarloRBD@data[[1;;1]]
];

MarloRBD[s_String]  := Module[{side},
side = data[[2;;]];
side[[All, 1]] = s <> "_" <> #& /@ side[[All, 1]];
If[StringMatchQ[s, "left"], side[[All, 2]] = -side[[All, 2]]];
MarloRBD@side
];

MarloRBD[B_] := Module[{data, b, pre, n, p,  s, f, I},
data = AssociationThread[B[[All, 1]] -> B[[All, 2;;4]]];

Table[
n = b[[1]];
f = N@{0, 0, 0};
I = Flatten@{b[[5]], f, b[[6;;17]]};

s = Which[
StringContainsQ[n, "torso"], "fb-marlo",
StringContainsQ[n, "hip"], "ry",
True, "rx"
];

pre = Which[
StringContainsQ[n, "left"], "left_",
StringContainsQ[n, "right"], "right_",
True, ""
];

{p, f} = Which[
StringContainsQ[n, "torso"], 
{Root, Join[f ,f]},
StringContainsQ[n, "hip"], 
{"torso", Join[f ,f]},
StringContainsQ[n, "lower_leg"], 
pre = pre <>"thigh";
{pre, Join[f, data[pre]]},
StringContainsQ[n, "four_bar_link"], 
pre = pre <> "shin";
{pre, Join[f, data[pre]]},
True, 
pre = pre <> "hip";
{pre, Join[f, data[pre]]}
];

Flatten@{n, p, s, f, I},
{b, B}
]
];



(* ::Input::Initialization:: *)
CreateModelData[] := Module[{R, torso, right, left, poi},
(* name, poi, mass, com, I *)
(* drop header in first row *)
data = Import["Marlo/marlo-dat.csv"][[2;;]];

R = RotationMatrix[\[Pi], {0, 1, 0}];
data[[3;;, 2;;4]] = (R.data[[3;;, 2;;4]]\[Transpose])\[Transpose];
data[[3;;, 6;;8]] = (R.data[[3;;, 6;;8]]\[Transpose])\[Transpose];

RBDJoint["fb-marlo", {"px", "py", "pz", "rz", "ry", "rx"}];

torso = data[[{1}]];

right = left = data[[2;;]];
right[[All, 1]] = "right_" <> #& /@ right[[All, 1]];
left[[All, 1]] = "left_" <> #& /@ left[[All, 1]];
left[[All, 2]] = -left[[All, 2]];

torso = MarloRBD["torso"];
left = MarloRBD["left"];
right = MarloRBD["right"];

poi = {#[[1]], #[[2;;4]]}& /@ data[[{1, 7, 8, 7, 8}]];
poi[[2;;3, 1]] = "left_" <> #& /@ poi[[2;;3, 1]];
poi[[4;;5, 1]] = "right_" <> #& /@ poi[[4;;5, 1]];

{Join[torso, left, right], poi, poi[[{3,5}]]}
];


(* ::Input::Initialization:: *)
End[]
EndPackage[]