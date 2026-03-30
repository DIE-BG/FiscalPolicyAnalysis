# Script that checks the stability of a proposed VAR system 
# The VAR is assessed based on its eigenvalues and the 
# behavior of the dynamic multipliers.

# For ensure stability of the VAR system we applied a shriking factor to the coefficients matrix.
# The shriking algorithm is describe below:

# A₂ = 0.99 * I * A₁ # For the first iteration and then the eigenvalues of A₂ are chicking
# A₂ = 0.99 * I * A₁ # If the eivenvalues are outside the unite circle the process continues
# ...
# Aₙ = 0.99 * I * Aₙ₋₁ # The process ends untill all eigenvalues are inside the unit circle

using DrWatson
@quickactivate "FiscalPolicyAnalysis"

using CairoMakie
using CSV, Tables

include(srcdir("helpers", "VAR_check", "VAR_check.jl"))
include(srcdir("helpers", "VAR_check", "VAR_plots.jl"))

##### Define the coefficients matrix

A = 
    [
    0.7544   0.0      0.0          0.0      0.0     0.0      0.0      0.0      0.0       0.0      0.0     0.0        0.0       0.0      0.0       0.0        0.0;
    0.0      0.8661   0.0          0.0      0.0     0.0      0.0      0.0      0.0       0.0      0.0     0.0        0.0       0.0      0.0       0.0        0.0;
    0.0      0.0      0.8179       0.0      0.0     0.0      0.0      0.0      0.0       0.0      0.0     0.0        0.0       0.0      0.0       0.0        0.0;
    0.0      0.0      0.0          0.7765   0.0     0.0      0.0      0.0      0.0       0.0      0.0     0.0        0.0       0.0      0.0       0.0        0.0;
    0.0      0.0      0.0          0.0      0.8282  0.0      0.0      0.0      0.0       0.0      0.0     0.0        0.0       0.0      0.0       0.0        0.0;
    0.0      0.0      0.0          0.0      0.0     0.7678   0.0      0.0      0.0       0.0      0.0     0.0        0.0       0.0      0.0       0.0        0.0;
    0.0      0.0      0.0          0.0      0.0     0.0      0.8565   0.0      0.0       0.0      0.0     0.0        0.0       0.0      0.0       0.0        0.0;
    0.0      0.0      0.0          0.0      0.0     0.0      0.0      0.9598   0.0       0.0      0.0     0.0        0.0       0.0      0.0       0.0        0.0;
    0.0      0.0      0.0          0.0934  -0.0934  0.0934   0.0237   0.0      0.9103    0.0      0.0     0.0        0.0       0.0      0.0       0.0        0.0;
    0.0      0.0     -0.000305625  0.0      0.0     0.0     -0.2378   0.0      0.0       0.9868   0.0     0.0       -0.02306   0.0     -0.1059    0.0        0.0;
    0.0      0.0      0.0          0.0      0.0     0.0      0.0      0.0      0.09169   0.0      0.8166  0.07519    0.0       0.0     -0.01224   0.0        0.0;
    0.0      0.2423   0.0          0.0      0.0     0.0      0.0      0.0      0.0       0.0      0.0     0.4887     0.0       0.0      0.1586   -0.0005786  0.0;
    0.0     -0.2547   0.0          0.0      0.0     0.0     -1.4362   0.0      0.0       1.4362   0.0     0.2547     0.7782   -0.2547   0.0       0.0        0.0;
    0.0      0.0      0.0          0.0      0.0     0.0     -0.1502   0.0     -0.1502    0.1501   0.1501  0.0        0.0       0.5235   0.0       0.0        0.0;
    0.0      0.0      0.9163       0.0      0.0     0.0      0.0      0.0      0.0      -0.2092  -0.2091  0.0       -0.1168    0.0      0.6716   -0.1855     0.0;
    -0.351    0.0      0.0          0.2645   0.0     0.0      0.0     -0.6066   0.0       1.7789   1.7789  0.0        0.0       0.0      0.0       1.1765     0.2645;
    0.0      0.0      0.0          0.0      0.0     0.0      0.0      0.0      0.1316    0.0     -0.1316  0.005417   0.0      -0.1712   0.0       0.0        0.8419
    ]

# Crete the companion matrix of the VAR system
A_Comp = companion(A; K = 17, P = 1)

# Plot the eigenvalues of the companion matrix
any(x -> x > 1, real.(eigvals(A_Comp))) # We can see that at least one eigenvalue is greater than 1

# We ensured the stability of the system by multiplying the coefficients matrix by 0.99 as many times as necessary
A_Forced = ForceStability(A; K = 17, P = 1, shrinking_type = "diagonal")

# Check the stability of the system again
# companion matrix
A_Comp_Forced = companion(A_Forced; K = 17, P = 1)
# eigenvalues
any(x -> x > 1, real.(eigvals(A_Comp_Forced))) # Any of the eigenvalues is greater than 1

# Make the eigenvalues plot
EigenPlot(eigvals(A_Forced); save_path = plotsdir("Model_1.0", "stable_shrking_1", "eigenvalues.png"))

# Make the Dynamic Multipliers of the VAR system
DM_model = DynamicMultipliers(A_Forced; K = 17, P = 1, T = 30*4, structural = false)

#### Plots
# Difine the names of the variables
var_names = [
    "GDP_star", "i_star", "pi_star", "IPub", "IngT", 
    "GFun", "DPE", "Rem", "DPI", "AEN", 
    "AIN", "i", "e", "PREM", "pi", 
    "GDP", "IPriv"
]

# Plot the responses
DynamicMultipliersPlots(DM_model, var_names, save_path = plotsdir("Model_1.0", "stable_shrking_1"))

# Export the coefficients matrix of the VAR system
CSV.write(joinpath("results", "Model_1.0", "stable_shrking_1", "A_forced_shrking_1.csv"), Tables.table(A_Forced))