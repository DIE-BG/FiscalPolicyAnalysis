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

##### Load data #####
# quarterly data
Qdata = CSV.read(datadir("processing", "Quarterly_data.csv"), DataFrame)
Mdata = CSV.read(datadir("processing", "Monthly_data.csv"), DataFrame)
OlaData = CSV.read(datadir("processing", "ola_variables.csv"), DataFrame)

##### Exporting all the "ola" variables from our quarter data frame. #####
# Creating the "ola" variables
RatiosFlows = OlaRatiosFlowDict(Qdata, ["IngT", "Ipub", "IPriv", "GFun", "Rem"], T = 4)
RatiosStocks = OlaRatiosStockDict(Qdata, ["DPI", "DPE", "AEN", "AIN"], T = 4)
GrowthVariables = OlaGrowthDict(Qdata, ["GDP", "GDP_star"]; T = 4)
PercentageRateVariables = OlaPercentageRateDict(Qdata, ["e", "core_cpi", "core_cpi_star"]; T = 4)
SimpleVariables_ola = OlaSimpleVariablesDict(Qdata, ["i", "i_star"]; T = 4)

# Now we're going to combine all dictionaries into the new one
ola_dictionary = merge(
    RatiosFlows,
    RatiosStocks,
    GrowthVariables,
    PercentageRateVariables,
    SimpleVariables_ola
)

# Finally wi will export the data into the a single CSV file. 
# The dataframe will contain all the variables and the date rage will be generated 
# based on the intersection of the dates across the varialbes.
# As we can see in the data frame bellow. The date range covers 2024-12-01 through 2025-09-01.
CSV.write(datadir("processing", "ola_variables.csv"), dict_to_dataframe(ola_dictionary))

##### Create the plots ####
# Ploting the the ratio flow variables.
PlotRatioFlowVariable(
    Mdata,  
    Qdata, 
    ["IngT", "Ipub", "GFun", "Rem"]; 
    varnames = ["Ingresos Totales", "Inversió pública", "Gasto en funcionamiento", "Remesas"], 
    savepath = joinpath("ola", "flows"),
    T = 4
    )

# Ploting the ratio stock variables.
PlotRatioStockVariable(
    Mdata,  
    Qdata, 
    ["DPI", "DPE", "AEN", "AIN"]; 
    varnames = ["Deuda pública interna", "Deuda pública externa", "Activos Externos Netos", "Activos Internos Netos"], 
    savepath = joinpath("ola", "stocks"),
    T = 4
    )

# Ploting both foreing and domestic GDP.
PlotGrowthVariable( 
    Qdata, 
    ["GDP", "GDP_star"]; 
    varnames = ["PIB doméstico", "PIB de Estados Unidos"],
    subtitles = ["Millones de quetzales", "Millones de dólares"], 
    savepath = joinpath("ola", "growth"),
    T = 4
)

# Ploting CPI data
#  We do not plot exchange rate data because it is daily data, unlike CPI data, which is monthly.
PlotPercentageRateVariable(
    Mdata,
    Qdata, 
    ["e", "core_cpi", "core_cpi_star"]; 
    varnames = ["Tipo de cambio nominal", "IPC subyacente Guatemala", "IPC PCE subyacente EE.UU"],
    savepath = joinpath("ola", "CPI"),
    T = 4
)

SimpleVariables(
    Mdata,
    Qdata, 
    ["i", "i_star"]; 
    varnames = ["Tasa de interés líder", "Tasa de interés efectiva de fondos federales"],
    savepath = joinpath("ola", "i"),
    T = 4
)

PlotRatioFlowIPriv(
    Qdata, 
    ["IPriv"]; 
    varnames = ["Inversión Privada"], 
    savepath = joinpath("ola", "stocks"),
    T = 4
)

PlotOla(
    OlaData,
    ["IngT", "Ipub", "GFun", "IPriv", "DPI", "DPE", "Rem", "AEN", 
    "AIN", "GDP", "GDP_star", "e", "core_cpi", "core_cpi_star", "i", "i_star"]; 
    varnames = ["Ingresos Totales", 
                "Inversió pública", 
                "Gasto en funcionamiento", 
                "Inversion Privada",
                "Deuda pública interna", "Deuda pública externa", "Remesas", 
                "Activos Externos Netos", "Activos Internos Netos",
                "PIB doméstico", "PIB de Estados Unidos",
                "Tipo de cambio nominal", "IPC subyacente Guatemala", "IPC PCE subyacente EE.UU",
                "Tasa de interés líder", "Tasa de interés efectiva de fondos federales"],
    savepath = joinpath("ola", "ola")
)