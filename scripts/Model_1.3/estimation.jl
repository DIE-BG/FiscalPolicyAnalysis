#= 
Scritp for estimating the model version 1.2 equation by equation using OLS
Translated from estimation.m
=#
using DrWatson
@quickactivate "FiscalPolicyAnalysis"

using CSV
using DataFrames
using GLM

# Load the "ola" variable
# Assuming the path is relative to the project root as in the original script
data = CSV.read("Models/Model_1.2/data/ola_variables.csv", DataFrame)

# All equations are estimated from 2009Q1 to 2025Q3 (implied by the data slices)

## 1) Foreing economic growth %%%%%
FEGTbl = DataFrame(
    GDP_star = data.GDP_star[2:end],
    GDP_star_lag = data.GDP_star[1:end-1]
)

# Estimating the equation
Eq_Y_star = lm(@formula(GDP_star ~ 0 + GDP_star_lag), FEGTbl)
coef(Eq_Y_star)
# alpha_1,1 = 0.7543613302382054

## 2) Foreing policy interest rate %%%%%
FIRTbl = DataFrame(
    i_star = data.i_star[2:end],
    i_star_lag = data.i_star[1:end-1]
)

Eq_i_star = lm(@formula(i_star ~ 0 + i_star_lag), FIRTbl)
coef(Eq_i_star)

# alpha_2,1 = 0.8660579303383931

## 3) Foreing core inflation
FCoreCPITbl = DataFrame(
    core_cpi_star = data.core_cpi_star[2:end],
    core_cpi_star_lag = data.core_cpi_star[1:end-1]
)

Eq_core_CPI_star = lm(@formula(core_cpi_star ~ 0 + core_cpi_star_lag), FCoreCPITbl)
coef(Eq_core_CPI_star)
# alpha_3,1 = 0.8178626896898692

## 4) Public investment
IPubTbl = DataFrame(
    IPub = data.IPub[2:end],
    IPub_lag = data.IPub[1:end-1]
)

Eq_IPub = lm(@formula(IPub ~ 0 + IPub_lag), IPubTbl)
coef(Eq_IPub)
# alpha_4,1 = 0.7765023412019942

## 5) Government total revenue
IngTTbl = DataFrame(
    IngT = data.IngT[2:end],
    IngT_lag = data.IngT[1:end-1]
)

Eq_IngT = lm(@formula(IngT ~ 0 + IngT_lag), IngTTbl)
coef(Eq_IngT)
# alpha_5,1 = 0.8282073536284056

## 6) Government operating expenses
GFunTbl = DataFrame(
    GFun = data.GFun[2:end],
    GFun_lag = data.GFun[1:end-1]
)

Eq_GFun = lm(@formula(GFun ~ 0 + GFun_lag), GFunTbl)
coef(Eq_GFun)
# alpha_6,1 = 0.7678270891359275

## 7) External public debt
DPETbl = DataFrame(
    DPE = data.DPE[2:end],
    DPE_lag = data.DPE[1:end-1]
)

Eq_DPE = lm(@formula(DPE ~ 0 + DPE_lag), DPETbl)
coef(Eq_DPE)
# alpha_7,1 = 0.8564561278895014

## 8) Remittances
RemTbl = DataFrame(
    Rem = data.Rem[2:end],
    Rem_lag = data.Rem[1:end-1]
)

Eq_Rem = lm(@formula(Rem ~ 0 + Rem_lag), RemTbl)
coef(Eq_Rem)
# alpha_8,1 = 0.9598150390995895

## 9) Domestic public debt
DPITbl = DataFrame(
    DPI = data.DPI[2:end],
    DPI_lag = data.DPI[1:end-1],
    DPE_lag = data.DPE[1:end-1],
    Def_lag = data.GFun[1:end-1] .+ data.IPub[1:end-1] .- data.IngT[1:end-1]
)

Eq_DPI = lm(@formula(DPI ~ 0 + DPI_lag + DPE_lag + Def_lag), DPITbl)
coef(Eq_DPI)
# alpha_9,1 = 0.9102550296031721
# alpha_9,2 = 0.0236523143411762
# alpha_9,3 = 0.09337412293715418

## 10) Net external assets
AENTbl = DataFrame(
    AEN = data.AEN[2:end],
    AEN_lag = data.AEN[1:end-1],
    DPE_lag = data.DPE[1:end-1],
    z = data.core_cpi_star[1:end-1] + data.e[1:end-1] - data.core_cpi[1:end-1],
)

Eq_AEN = lm(@formula(AEN ~ 0 + AEN_lag + DPE_lag + z), AENTbl)
coef(Eq_AEN)
# alpha_10,1 = 0.8821558174474926
# alpha_10,2 = -0.052260550182794185
# alpha_10,3 = -0.0002786436816535314

## 11) Net domestic assets
AINTbl = DataFrame(
    AIN = data.AIN[2:end],
    AIN_lag = data.AIN[1:end-1],
    DPI_lag = data.DPI[1:end-1],
    i_lag = data.i[1:end-1],
    core_CPI_lag = data.core_cpi[1:end-1]
)

Eq_AIN = lm(@formula(AIN ~ 0 + AIN_lag + DPI_lag + i_lag + core_CPI_lag), AINTbl)
coef(Eq_AIN)
# alpha_11,1 = 0.816623271699054
# alpha_11,2 = 0.0916909621818119
# alpha_11,3 = 0.075192187969831
# alpha_11,4 = -0.0122415376991626

## 12) Domestic policy interest rate
iTbl = DataFrame(
    i = data.i[2:end],
    i_lag = data.i[1:end-1],
    i_star_lag = data.i_star[1:end-1],
    core_cpi_lag = data.core_cpi[1:end-1],
    GDP_lag = data.GDP[1:end-1]
)

Eq_i = lm(@formula(i ~ 0 + i_lag + i_star_lag + core_cpi_lag + GDP_lag), iTbl)
coef(Eq_i)
# alpha_12,1 = 0.488725059259753
# alpha_12,2 = 0.242331399256555
# alpha_12,3 = 0.158571988548305
# alpha_12,4 = -0.000578554035124701

## 13) exchange rate
eTbl = DataFrame(
    e = data.e[2:end],
    e_lag = data.e[1:end-1],
    DPEC_lag = data.DPE[1:end-1] .- data.AEN[1:end-1],
    Z_lag = data.i[1:end-1] .- data.i_star[1:end-1] .- data.PREM[1:end-1]
)

Eq_e = lm(@formula(e ~ 0 + e_lag + DPEC_lag + Z_lag), eTbl)
coef(Eq_e)
# alpha_13,1 = 0.778224497246161
# alpha_13,2 = -1.43624446918375
# alpha_13,3 = 0.254729415021685

## 14) Country risk premium
PREMTbl = DataFrame(
    PREM = data.PREM[2:end],
    PREM_lag = data.PREM[1:end-1],
    X_lag = (data.DPI[1:end-1] .- data.AIN[1:end-1]) .+ (data.DPE[1:end-1] .- data.AEN[1:end-1])
)

Eq_PREM = lm(@formula(PREM ~ 0 + PREM_lag + X_lag), PREMTbl)
coef(Eq_PREM)
# alpha_14,1 = 0.523506275786604
# alpha_14,2 = -0.150167841593611

## 15) Domestic core inflation
core_CPITbl = DataFrame(
    core_CPI = data.core_cpi[2:end],
    core_CPI_lag = data.core_cpi[1:end-1],
    GDP_lag = data.GDP[1:end-1],
    core_CPI_star_lag = data.core_cpi_star[1:end-1],
    e_lag = data.e[1:end-1],
    MB_lag = data.AEN[1:end-1] .+ data.AIN[1:end-1]
)

Eq_core_CPI = lm(@formula(core_CPI ~ 0 + core_CPI_lag + GDP_lag + core_CPI_star_lag + e_lag + MB_lag), core_CPITbl)
coef(Eq_core_CPI)
# alpha_15,1 = 0.67161374705576
# alpha_15,2 = -0.185533136275859
# alpha_15,3 = 0.916343659735078
# alpha_15,4 = -0.116835511186213
# alpha_15,5 = -0.209159266630752

## 16) Domestic economic growth
GDPTbl = DataFrame(
    GDP = data.GDP[2:end],
    GDP_lag = data.GDP[1:end-1],
    GDP_star_lag = data.GDP_star[1:end-1],
    Rem_lag = data.Rem[1:end-1],
    ITotal_lag = data.IPub[1:end-1] .+ data.IPriv[1:end-1],
    MB_lag = data.AEN[1:end-1] .+ data.AIN[1:end-1]
)

Eq_GDP = lm(@formula(GDP ~ 0 + GDP_lag + GDP_star_lag + Rem_lag + ITotal_lag + MB_lag), GDPTbl)
coef(Eq_GDP)
# alpha_16,1 = 1.17659964534197
# alpha_16,2 = -0.3510357800862 
# alpha_16,3 = -0.606648828459218
# alpha_16,4 = 0.08974169553208515
# alpha_16,5 = 1.77895954474665

## 17) Private total investment
IPrivTbl = DataFrame(
    IPriv = data.IPriv[2:end],
    IPriv_lag = data.IPriv[1:end-1],
    i_lag = data.i[1:end-1],
    DPIC_lag = data.DPI[1:end-1] .- data.AIN[1:end-1],
    PREM_lag = data.PREM[1:end-1]
)

Eq_IPriv = lm(@formula(IPriv ~ 0 + IPriv_lag + i_lag + DPIC_lag + PREM_lag), IPrivTbl)
coef(Eq_IPriv)
# alpha_17,1 = 0.841937068648307
# alpha_17,2 = 0.0054177288032476
# alpha_17,3 = 0.131695196775483
# alpha_17,4 = -0.1712624694918

println("Estimation complete.")
