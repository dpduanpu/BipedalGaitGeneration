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



(* ::Code::Initialization:: *)
(*
RootFinding.nb: An implementation of various continuation methods.
Copyright (C) 2017 Nelson Rosa Jr.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version. This program is distributed in the 
hope that it will be useful, but WITHOUT ANY WARRANTY; without even the 
implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU General Public License for more details. You should have 
received a copy of the GNU General Public License along with this program.
If not, see <http://www.gnu.org/licenses/>.
*)


(* ::Input::Initialization:: *)
BeginPackage["BipedalLocomotion`", {"GlobalVariables`", "RigidBodyDynamics`", "HybridDynamics`"}]
Begin["`Private`"]


(* ::Input::Initialization:: *)
MAX = 100;
TOL = 3.08^-13;
brent::brack = "The root is not bracketed by the interval x \[Element] [`1`, `2`].";
brent::maxiter = "Maximum number of iterations reached.";

brent[f_, x0_, x1_, tol_: TOL] := Module[{root, a, fa, b, fb, c, fc, d, e, min1, min2, p, q, r, s, tol1, xm},
root = \[Infinity];

a = x0;
b = x1;
c = x1;
fa = f[a];
fb = f[b];

If[(fa > 0 && fb > 0) ||  (fa < 0 && fb < 0),
Message[brent::brack, NumberForm[x0, 4], NumberForm[x1, 4]];
Return[];
];

fc = fb;
Do[
(* relabel if bounds have changed *)
If[(fb > 0 && fc > 0) || (fb < 0 && fc < 0),
c = a;
fc = fa;
d = b-a;
e = d;
];

If[Abs[fc] < Abs[fb],
a = b; b = c; c = a;
fa = fb; fb = fc; fc = fa;
];

tol1 = 2 TOL Abs[b] + tol/2;
xm = (c - b)/2;

If[Abs[xm] <= tol1 || fb == 0, Return[root = b]];
If[Abs[e] >= tol1 && Abs[fa] > Abs[fb],
s = fb / fa; (* inverse quadratic *)
If[a == c,
p = 2 xm  s;
q = 1 - s;,
(* else *)
q = fa/fc;
r = fb/fc;
p = s (2 xm q (q-r) - (b-a)(r-1));
q = (q-1) (r-1) (s - 1);
];

(* check bounds *)
If[p > 0, q = -q];
p = Abs[p];
min1 = 3 xm q - Abs[tol1 q];
min2 = Abs[e q];

If[2 p < Min[min1, min2],
e = d; (* interpolation is safe *)
d = p/q;,
(* else *)
d = xm; (* revert to bisection *)
e = d;
];,
(* else *)
(* progress is slow, use bisection *)
d = xm;
e = d;
];

(* store current value *)
a = b;
fa = fb;

(* update guess *)
If[Abs[d] > tol1, 
b = b + d;, 
(* else *)
b = b + If[xm >= 0, Abs[tol1], -Abs[tol1]];
];
fb = f[b];,
MAX
];

If[root === \[Infinity], Message[brent::maxiter]];
root
];


(* ::Input::Initialization:: *)
binewton::brack = "The root is not bracketed by the interval x \[Element] [`1`, `2`].";
binewton::maxiter = "Maximum number of iterations reached.";
binewton[f_, x0_, x1_, xacc_:TOL] := Module[{root, dy, dx, dxold, y, gh, gl, temp, xh ,xl, r},
root = \[Infinity];

{gl, dy} = f[x0];
{gh, dy} = f[x1];
If[(gl > 0 && gh > 0) || (gl < 0 && gh < 0),
Message[binewton::brack, NumberForm[x0, 4], NumberForm[x1, 4]];
Return[];
];

If[gl == 0, Return[root = x0]];
If[gh == 0, Return[root = x1]];

If[gl < 0,
xl = x0;
xh = x1;,
(* else *)
xh = x0;
xl = x1;
];

r = (x0+x1)/2;
dxold = Abs[x1-x0];
dx = dxold;
{y, dy} = f[r];
Do[
If[((r-xh) dy-y) ((r-xl)dy-y) > 0 || Abs[2y] > Abs[dxold dy],
(* bisection, if newton is out of range or not fast enough *)
dxold = dx;
dx = (xh-xl)/2;
r = xl + dx;
If[xl == r, Return[root = r]];,
(* else *)
(* newton *)
dxold = dx;
dx = y/dy;
temp = r;
r = r - dx;
If[temp == r, Return[root = r]];
];

If[Abs[dx] < xacc, Return[root = r]];

{y, dy} = f[r];
If[y < 0, xl = r;, xh = r];,
MAX
];

If[root === \[Infinity], Message[binewton::maxiter]];
root
];


(* ::Input::Initialization:: *)
AllRoots[f_, x0_, x1_, N_:All, n_:100, tol_:TOL] := Module[{x, y, r, xr, yr},
x = Range[x0, x1, (x1-x0)/n];
y = f /@ x;
If[ListQ@First@y, 
r = binewton;
y = y[[All, 1]];, 
(* else *)
r = brent
];

yr = y[[1;;-2]]y[[2;;-1]];
xr = MapThread[List, {x[[1;;-2]], x[[2;;-1]]}];
xr = Pick[xr, yr, z_/;Negative@z];
xr = Which[Length@xr == 0, xr, IntegerQ[N], Take[xr, N], True, xr[[N]]];

r = r[f, #[[1]], #[[2]], tol]& /@ xr;

{r, {x, y}\[Transpose]}
];


(* ::Input::Initialization:: *)
End[]
EndPackage[]
