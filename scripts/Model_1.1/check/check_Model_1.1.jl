# Script that checks the stability of a proposed VAR system 
# The VAR is assessed based on its eigenvalues and the 
# behavior of the dynamic multipliers.

using DrWatson
@quickactivate "FiscalPolicyAnalysis"

using CairoMakie

include(srcdir("helpers", "VAR_check", "VAR_check.jl"))
include(srcdir("helpers", "VAR_check", "VAR_plots.jl"))

#---------- Define the coefficients matrix ----------

A = [
    0.5254   0        0        0        0        0        0         0        0         0         0         0         0        0        0        0         0;
    0        0.6032   0        0        0        0        0         0        0         0         0         0         0        0        0        0         0;
    0        0        0.56960  0        0        0        0         0        0         0         0         0         0        0        0        0         0;
    0        0        0        0.54076  0        0        0         0        0         0         0         0         0        0        0        0         0;
    0        0        0        0        0.57677  0        0         0        0         0         0         0         0        0        0        0         0;
    0        0        0        0        0        0.53471  0         0        0         0         0         0         0        0        0        0         0;
    0        0        0        0        0        0        0.59648   0        0         0         0         0         0        0        0        0         0;
    0        0        0        0        0        0        0         0.66842  0         0         0         0         0        0        0        0         0;
    0        0        0        0.06504 -0.06504  0.06504  0.01650   0        0.63394   0         0         0         0        0        0        0         0;
    0        0       -0.00021  0        0        0        0.16561   0        0         0.68722   0         0        -0.01606  0        0.07375  0         0;
    0        0        0        0        0        0        0         0        0.06385   0         0.56869  -0.05236   0        0       -0.00852  0         0;
    0        0.16874  0        0        0        0        0         0        0         0         0         0.34034   0        0        0.11045  0.00040   0;
    0       -0.17738  0        0        0        0        1.000189  0        0        -1.000189  0         0.17738   0.54195 -0.17738  0        0         0;
    0        0        0        0        0        0        0.10460   0        0.10460  -0.10460  -0.10460   0         0        0.36457  0        0         0;
    0        0        0.63812  0        0        0        0         0        0         0.14569   0.14569   0         0.08134  0        0.46771  0.12918   0;
    0.24444  0        0        0.18420  0        0        0         0.42244  0         1.23885   1.23885   0         0        0        0        0.81933   0.18420;
    0        0        0        0        0        0        0         0       -0.09165   0         0.09165  -0.00377   0       -0.11923  0        0         0.58631
]

#---------- Check the stability of the VAR system ----------
# Crete the companion matrix of the VAR system
A_Comp = companion(A; K = 17, P = 1)

# Plot the eigenvalues of the companion matrix
EigenPlot(eigvals(A_Comp); save_path = joinpath("Models", "Model_1.1", "plots", "Dynamic_multipliers", "eigenvalues.png"))

# Make the Dynamic Multipliers of the VAR system
DM_raw = DynamicMultipliers(A; K = 17, P = 1, T = 30*4, structural = false)

# Pre-allocate a larger array to hold calculated variables (17 original + 6 new = 23)
DM_model = zeros(23, 17, size(DM_raw, 3))
DM_model[1:17, :, :] .= DM_raw

# Calculate the response of the Monetary base 
for i in 1:17
    DM_model[18, i, :] = DM_model[10, i, :] .+ DM_model[11, i, :]
end

# Calculate the response of the real interest rate 
for i in 1:17
    DM_model[19, i, :] = DM_model[3, i, :] .+ DM_model[13, i, :] .- DM_model[15, i, :]
end

# Calculate the response of DPE consolidated
for i in 1:17
    DM_model[20, i, :] = DM_model[7, i, :] .- DM_model[10, i, :]
end

# Calculate the response of DPI consolidated
for i in 1:17
    DM_model[21, i, :] = DM_model[9, i, :] .- DM_model[11, i, :]
end

# Calculate the response of DPT consolidated
for i in 1:17
    DM_model[22, i, :] = DM_model[7, i, :] .- DM_model[10, i, :] .+ DM_model[9, i, :] .- DM_model[11, i, :]
end

# Calculate the response of Total investment
for i in 1:17
    DM_model[23, i, :] = DM_model[4, i, :] + DM_model[17, i, :] 
end

#---------- Check the responses of the calculated variables against the original ones to make sure they are correct ----------
# M_0
[DM_raw[10, 17, :] .+ DM_raw[11, 17, :]  DM_model[18, 17,:]]
# r
[DM_raw[3, 17, :] .+ DM_raw[13, 17, :] .- DM_raw[15, 17, :] DM_model[19,17,:]]
# DPEC
[DM_raw[7, 17, :] .- DM_raw[10, 17, :]  DM_model[20,17,:]]
# DPIC
[DM_raw[9, 17, :] .- DM_raw[11, 17, :]  DM_model[21, 17,:]]
# DPTC
[DM_raw[7, 17, :] .- DM_raw[10, 17, :] .+ DM_raw[9, 17, :] .- DM_raw[11, 17, :] DM_model[22,17,:]]
# Total investment
[DM_raw[4, 17, :] + DM_raw[17, 17, :]  DM_model[23, 17,:]]

#### Plots
# Define the names of the variables (responding variables)
var_names = [
    "GDP_star", "i_star", "pi_star", "IPub", "IngT", 
    "GFun", "DPE", "Rem", "DPI", "AEN", 
    "AIN", "i", "e", "PREM", "pi", 
    "GDP", "IPriv", L"M_{0}Ampliada", "r", "DPEC", 
    "DPIC", "DPTC", "ITotal"
]

# Define the names of the shocks (the original 17 variables)
shock_names = var_names[1:17]

# Plot the responses
DynamicMultipliersPlots(DM_model, shock_names, var_names, save_path = joinpath("Models", "Model_1.1", "plots", "Dynamic_multipliers"))