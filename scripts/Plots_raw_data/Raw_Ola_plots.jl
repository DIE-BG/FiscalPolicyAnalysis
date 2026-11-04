#=
This scripts loading monthly and quarterly data and transform them into the their "ola" version
also create two types of plots. The first of them are plots that show how the raw data is transformed
into the "ola" version for each variable. The second one are plots that show the behavor of the "ola"
variables throughout the years
=#
using DrWatson
@quickactivate "FiscalPolicyAnalysis"


##### Load the packages #####
using CSV, DataFrames, DataFramesMeta
using Statistics, Dates
using CairoMakie, Mudie
using Revise

include(srcdir("helpers", "Plots", "plots_helpers.jl"))
include(srcdir("helpers", "Processing", "processing_helpers.jl"))
include(srcdir("helpers", "Plots", "ola_helpers.jl"))
include(srcdir("helpers", "Plots", "plots_ola.jl"))

# ===== Check if the plot/ola folder exists, if not create it =====
    if !isdir(plotsdir("ola"))
        mkdir(plotsdir("ola"))

    else
        
        println("The folder 'ola' already exists in the 'plots' directory.")

    end

# ===== Load data =====
# quarterly data
Qdata = CSV.read(datadir("processing", "Quarterly_data.csv"), DataFrame)
Mdata = CSV.read(datadir("processing", "Monthly_data.csv"), DataFrame)

# ===== Exporting all the "ola" variables from our quarter data frame. =====
# Creating the "ola" variables
RatiosFlows = OlaRatiosFlowDict(Qdata, ["IngT", "IPub", "IPriv", "GFun", "Rem", "ITotal"], T = 4)
RatiosStocks = OlaRatiosStockDict(Qdata, ["DPI", "DPE", "AEN", "AIN", "DPEC", "DPIC", "DPTC", "DPT", "BM"], T = 4)
GrowthVariables = OlaGrowthDict(Qdata, ["GDP", "GDP_star"]; T = 4)
PercentageRateVariables = OlaPercentageRateDict(Qdata, ["e", "core_cpi", "core_cpi_star"]; T = 4)
SimpleVariables_ola = OlaSimpleVariablesDict(Qdata, ["i", "i_star", "PREM"]; T = 4)

# Now we're going to combine all dictionaries into the new one
ola_dictionary = merge(
    RatiosFlows,
    RatiosStocks,
    GrowthVariables,
    PercentageRateVariables,
    SimpleVariables_ola
)

# Finally wi will export the data into the a single CSV file. 
# The dataframe contains all variables, and the date rage was generated 
# based on the intersection of the dates across the varialbes.
CSV.write(datadir("processing", "ola_variables.csv"), dict_to_dataframe(ola_dictionary))

# ===== Create the plots =====
# Ploting the the ratio flow variables.
PlotRatioFlowVariable(
    Mdata,  
    Qdata, 
    ["IngT", "IPub", "GFun", "Rem"]; 
    varnames = ["Ingresos Totales", "Inversión pública", "Gasto en funcionamiento", "Remesas"], 
    savepath = joinpath("ola", "flows"),
    T = 4
    )

PlotRatioFlowIPriv(
    Qdata, 
    ["IPriv", "ITotal"]; 
    varnames = ["Inversión Privada", "Inversion total"], 
    savepath = joinpath("ola", "flows"),
    T = 4
)

PlotGrowthVariable( 
    Qdata, 
    ["GDP", "GDP_star"]; 
    varnames = ["PIB doméstico", "PIB Trimestral de Estados Unidos"],
    subtitles = ["Millones de quetzales \nAño de referencia 2013", "Miles de millones de dólares \nAño de referencia 2017"],
    olatitles = ["Crecimiento económico", "Crecimiento económico externo"],
    savepath = joinpath("ola", "growth"),
    T = 4
)

# Ploting the ratio stock variables.
PlotRatioStockVariable(
    Mdata,  
    Qdata, 
    ["DPI", "DPE", "AEN", "AIN", "DPEC", "DPIC", "DPTC", "DPT", "BM"]; 
    varnames = [
                    "Deuda pública interna", 
                    "Deuda pública externa", 
                    "Activos Externos Netos", 
                    "Activos Internos Netos",
                    "Deuda pública externa consolidada",
                    "Deuda pública interna consolidada",
                    "Deuda pública total consolidada",
                    "Deuda pública total",
                    "Base Monetaria Ampliada"
                    ], 
    savepath = joinpath("ola", "stocks"),
    T = 4
    )

# Ploting CPI data
#  We do not plot exchange rate data because it is daily data, unlike CPI data, which is monthly.
PlotPercentageRateVariable(
    Mdata,
    Qdata, 
    ["e", "core_cpi", "core_cpi_star"]; 
    varnames = ["Tipo de cambio nominal (Q/US\$)", "IPC subyacente Guatemala (RMSE 2026 B)", "IPC PCE subyacente EE.UU"],
    olatitles = ["Tipo de cambio nominal", "Inflación doméstica", "Inflación externa"],
    savepath = joinpath("ola", "CPI"),
    T = 4
)

# Ploting both foreing and comestic interest rates
SimpleVariables(
    Mdata,
    Qdata, 
    ["i", "i_star", "PREM"]; 
    varnames = ["Tasa de interés líder", "Tasa de interés efectiva de fondos federales", "Prima por riesgo-país"],
    olatitles = ["Tasa de interés líder", "Tasa de interés externa", "Prima por riesgo-país"],
    savepath = joinpath("ola", "i"),
    T = 4
)

# Ploting "ola" variable of real exchange rate
include(scriptsdir("Plots_raw_data", "Ola_z.jl"))

# ===== Ploting "ola" variables =====
# Load the data
OlaData = CSV.read(datadir("processing", "ola_variables.csv"), DataFrame)

# Create additional variables from their definitions
# Real exchange rate
OlaData.z = OlaData.core_cpi_star + OlaData.e - OlaData.core_cpi

PlotOla(
    OlaData,
    [
        "IngT", "IPub", "GFun", "IPriv", "DPI", "DPE", "Rem", "AEN", 
        "AIN", "GDP", "GDP_star", "e", "core_cpi", "core_cpi_star", "i", "i_star", "PREM",
        "BM", "z", "DPEC", "DPIC", "DPTC", "DPT", "ITotal"
    ]; 
    varnames = [
                    "Ingresos Totales (%)", 
                    "Inversión pública (%)", 
                    "Gasto de funcionamiento (%)", 
                    "Inversion Privada (%)",
                    "Deuda pública interna (%)", "Deuda pública externa (%)", "Remesas (%)", 
                    "Activos Externos Netos (%)", "Activos Internos Netos (%)",
                    "Crecimiento económico (%)", "Crecimiento económico externo (%)",
                    "Depreciación (%)", "Inflación (%)", "Inflación externa (%)",
                    "Tasa de interés líder (%)", "Tasa de interés externa (%)",
                    "Prima por Riesgo-País (%)",
                    "Base Monetaria Ampliada (%)",
                    "Depreciación cambiaria real (%)",
                    "Deuda pública externa consolidada (%)",
                    "Deuda pública interna consolidada (%)",
                    "Deuda pública total consolidada (%)",
                    "Deuda pública total (%)",
                    "Inversión total (%)"
                ],
    savepath = joinpath("ola", "ola")
)