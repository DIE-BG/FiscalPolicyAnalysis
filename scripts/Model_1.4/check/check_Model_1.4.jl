#= 
Scritp to check the stability of the VAR system and to calculate the dynamic multipliers of the model.
We are working with the version 1.2 of the model. This version takes the A_Matrix estimated from the version 1.1 and
modified the coefficients of the equation 10 (AEN), since that equation has been re-estimated to take into account only
the global effect of the real exchange rate z, instead of the separate effects from each one of its components (pi_star, e and pi).

Moreover, all coefficients of the equation 13 (exchange rate) have been modified changing their singses. Only the AR coefficient has
been maintained with the same sign.

Finally, Since the equation 10 has been re-estimated, we shrunk the coefficients by the exponentical decreasing factor, with the same
shrinking factor used in the version 1.1. 

exponential decreasing factor: 0.99^9

All the re-estimated coefficients are shown in the estimation script of the version 1.2.
=#

using DrWatson
@quickactivate "FiscalPolicyAnalysis"

using CairoMakie
using CSV, Tables

include(srcdir("helpers", "VAR_check", "VAR_check.jl"))
include(srcdir("helpers", "VAR_check", "VAR_plots.jl"))

ModelPath = "Model_1.4"

# ====== Check if the plots folder exists, if not, create it ======
    if !isdir(joinpath("Models", ModelPath, "plots"))

        mkdir(joinpath("Models", ModelPath, "plots"))
        mkdir(joinpath("Models", ModelPath, "plots", "Dynamic_multipliers"))
            println("The folder for the plots has been created.")

    else
        println("The folder for the plots already exists.")
    end

# ===== Check in fthe A_Matrix folder exists, if not, create it =====
    if !isdir(joinpath("Models", ModelPath, "A_matrix"))

        mkdir(joinpath("Models", ModelPath, "A_matrix"))
            println("The folder for the A_matrix has been created.")

    else
        println("The folder for the A_matrix already exists.")
    end

# ===== Shrink the coefficients of the equation 10 by the exponential decreasing factor =====
AEN_row = [0 0 -0.0002786436816535314 0 0 0 0.052260 0 0 0.8821 0 0 -0.00027864 0 0.00027864 0 0]
for i in 1:9
    AEN_row = 0.99^i * AEN_row
end

AEN_row

# ===== Check the stability of the VAR system =====
# Define the coefficients matrix

A = [
    0.5254   0        0             0        0        0        0          0        0         0         0         0         0            0        0            0         0;
    0        0.6032   0             0        0        0        0          0        0         0         0         0         0            0        0            0         0;
    0        0        0.56960       0        0        0        0          0        0         0         0         0         0            0        0            0         0;
    0        0        0             0.54076  0        0        0          0        0         0         0         0         0            0        0            0         0;
    0        0        0             0        0.57677  0        0          0        0         0         0         0         0            0        0            0         0;
    0        0        0             0        0        0.53471  0          0        0         0         0         0         0            0        0            0         0;
    0        0        0             0        0        0        0.59648    0        0         0         0         0         0            0        0            0         0;
    0        0        0             0        0        0        0          0.66842  0         0         0         0         0            0        0            0         0;
    0        0        0             0.06504 -0.06504  0.06504  0.01650    0        0.63394   0         0         0         0            0        0            0         0;
    0        0       -0.000177269   0        0        0        0.0332471  0        0         0.561179  0         0        -0.000177267  0        0.000177267  0         0;
    0        0        0             0        0        0        0          0        0.06385   0         0.56869  -0.05236   0            0       -0.00852      0         0;
    0        0.16874  0             0        0        0        0          0        0         0         0         0.34034   0            0        0.11045      0.00040   0;
    0        0.17738  0             0        0        0       -1.000189   0        0         1.000189  0        -0.17738   0.54195      0.17738  0            0         0;
    0        0        0             0        0        0        0.10460    0        0.10460  -0.10460  -0.10460   0         0            0.36457  0            0         0;
    0        0        0.63812       0        0        0        0          0        0         0.14569   0.14569   0         0.08134      0        0.46771      0.12918   0;
    0.24444  0        0             0.18420  0        0        0          0.042244  0        0.023885   0.023885   0         0            0        0            0.81933   0.18420;
    0        0        0             0        0        0        0          0       -0.09165   0         0.09165  -0.00377   0           -0.11923  0            0         0.58631
]

# Crete the companion matrix of the VAR system
A_Comp = companion(A; K = 17, P = 1)

# Plot the eigenvalues of the companion matrix
any(x -> x > 1, real.(eigvals(A_Comp))) # Any of the eigenvalues are greater than 1 in absolute value

# Plot the eigenvalues of the companion matrix
EigenPlot(eigvals(A_Comp); save_path = joinpath("Models", ModelPath, "plots", "Dynamic_multipliers", "eigenvalues.png"))

# ===== Dynamic Multiplier =====
# Make the Dynamic Multipliers of the VAR system
DM_raw = DynamicMultipliers(A; K = 17, P = 1, T = 30*4, structural = false)

# Pre-allocate a larger array to hold calculated variables (17 original + 6 new = 23)
DM_model = zeros(24, 17, size(DM_raw, 3))
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

# Calculate the response of DPT
for i in 1:17
    DM_model[23, i, :] = DM_model[7, i, :] + DM_model[9, i, :] 
end

# Calculate the response of Total investment
for i in 1:17
    DM_model[24, i, :] = DM_model[4, i, :] + DM_model[17, i, :] 
end

# ==== Plots =====
# Define the names of the variables (responding variables)
var_names = [
    "GDP_star", "i_star", "pi_star", "IPub", "IngT", 
    "GFun", "DPE", "Rem", "DPI", "AEN", 
    "AIN", "i", "e", "PREM", "pi", 
    "GDP", "IPriv", L"M_{0}Ampliada", "z", "DPEC", 
    "DPIC", "DPTC", "DPT", "ITotal"
]

# Define the names of the shocks (the original 17 variables)
shock_names = var_names[1:17]

# Plot the responses
DynamicMultipliersPlots(DM_model, shock_names, var_names, save_path = joinpath("Models", ModelPath, "plots", "Dynamic_multipliers"))

# ===== Export the A_Forced Matrix to a CSV file =====
CSV.write(joinpath("Models", ModelPath, "A_matrix", "A_matrix.csv"), Tables.table(A), writeheader = false)