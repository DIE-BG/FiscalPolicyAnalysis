# Script that checks the stability of a proposed VAR system 
# The VAR is assessed based on its eigenvalues and the 
# behavior of the dynamic multipliers.

using DrWatson
@quickactivate "FiscalPolicyAnalysis"

using CairoMakie

include(srcdir("helpers", "VAR_check", "VAR_functions.jl"))

##### Define the coefficients matrix

A = 
    [
    0.7544 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0; 
    0 0.8661 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
    0 0 0.8179 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
    0 0 0.7765 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
    0 0 0 0.8282 0 0 0 0 0 0 0 0 0 0 0 0 0;
    0 0 0 0 0.7678 0 0 0 0 0 0 0 0 0 0 0 0;
    0 0 0 0 0 0 0.8565 0 0 0 0 0 0 0 0 0 0;
    0 0 0 0 0 0 0 0.9598 0 0 0 0 0 0 0 0 0;
    0 0 0 0.0934 -0.0934 0.0934 0.0237 0 0.9103 0 0 0 0 0 0 0 0;
    0 0 -0.000305625133559185 0 0 0 -0.2378 0 0 0.9868 0 0 -0.02306 0 -0.1059 0 0;
    0 0 0 0 0 0 0 0 0.09169 0 0.8166 0.07519 0 -0.01224 0 0; 
    0 0.2423 0 0 0 0 0 0 0 0 0 0.4887 0 0 0.1586 -0.0005786 0;
    0 -0.2547 0 0 0 0 -1.4362 0 0 -1.4362 0 0.2547 0.7782 -0.2547 0 0 0;
    0 0 0 0 0 0 -0.1502 0 -0.1502 0.1501 0.1501 0 0 0.5235 0 0 0;
    0 0 0.9163 0 0 0 0 0 0 -0.2092 -0.2091 0 0 -0.1168 0.6716 -0.1855 0; 
    ]
