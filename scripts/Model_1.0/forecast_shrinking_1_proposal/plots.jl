# Script that checks the stability of a proposed VAR system 
# The VAR is assessed based on its eigenvalues and the 
# behavior of the dynamic multipliers.

using DrWatson
@quickactivate "FiscalPolicyAnalysis"

using CairoMakie
using CSV, DataFrames, Dates
using Mudie

# Load data
data = CSV.read(joinpath("Models", "Model_1.0", "forecast", "forecast_shrinking_proposal_1", "forecast.csv"), DataFrame)
data_plot = data[!, 2:18]
data_plot.u9 = data[!, :u9]
data_plot.date = collect(Date(2009, 1):Month(3):Date(2056, 12))

#### Plots
# Difine the names of the variables
var_names = [
    "GDP_star", "i_star", "pi_star", "IPub", "IngT", 
    "GFun", "DPE", "Rem", "DPI", "AEN", 
    "AIN", "i", "e", "PREM", "pi", 
    "GDP", "IPriv", "u_9"
]

#### Plot the series

for i in 1:18

    name = var_names[i]

    fig = Figure(size = (900, 600))

    ax = Axis(
        fig[1,1,],
        title = name,
        titlesize = 20,
        xgridvisible = false,
        ygridvisible = false
    )

    lines!(
        ax,
        datetime2rata.(data_plot.date),
        data_plot[:, i],
        label = "Serie"
    )

    vlines!(
        ax,
        datetime2rata.(Date(2025, 12)),
        linestyle = :dash,
        color = :black,
        linewidth = 0.75,
        label = "Inicio de pronóstico"
    )

    hlines!(
        ax,
        0.0,
        color = :black,
        linewidth = 1
    )

    Mudie.dateticks!(ax, first(data_plot.date):last(data_plot.date), step = Month(28))

    axislegend()

    save(joinpath("Models", "Model_1.0", "plots", "forecast_shrinking_1_proposal", string(i)*name*".png"), fig, px_per_unit = 2)

end