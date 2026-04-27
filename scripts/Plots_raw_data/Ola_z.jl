#=
    Script for calculating the real interest rate. We have decided to calculate the real interest rate in a separate script, 
    since it must be derived from the its definition based on ola version of the variables.

    foreing inflation + exchange rate - domestic inflation
=#

using DrWatson
@quickactivate "FiscalPolicyAnalysis"

# ===== Load the packages =====
using CSV, DataFrames, DataFramesMeta
using Statistics, Dates
using CairoMakie, Mudie
using Revise

include(srcdir("helpers", "Plots", "plots_helpers.jl"))
include(srcdir("helpers", "Processing", "processing_helpers.jl"))
include(srcdir("helpers", "Plots", "ola_helpers.jl"))
include(srcdir("helpers", "Plots", "plots_ola.jl"))

# ===== Load data =====
# "ola" data
OlaDataz = CSV.read(datadir("processing", "ola_variables.csv"), DataFrame)

# ===== Create the plots =====
# Real interest rate
OlaDataz.z = OlaDataz.core_cpi_star + OlaDataz.e - OlaDataz.core_cpi

fig = Figure(size = (1500, 900), fontsize = 22)

Label(
    fig[0,1:2], 
    "Construcción de la variable \"ola\" para Tipo de cambio real", 
    fontsize = 30,
    font = :bold
    )

# Foreing inflation (ola)
tslines!(
    Axis(
        fig[1,1], 
        title = "Inflación externa",
        subtitle = "representación ola (%)",
        xticklabelsize = 17,
        yticklabelsize = 25,
        ytickformat = "{:.0f}",
        ),
    OlaDataz.date,
    OlaDataz.core_cpi_star,
    figure = (; size = (400, 200)),
)

# zero line
hlines!(fig[1,1], 0, color = (:black, 0.25))

# exchange rate (ola)
tslines!(
    Axis(
        fig[1,2], 
        title = "Depreciación",
        subtitle = "representación ola (%)",
        xticklabelsize = 17,
        yticklabelsize = 25,
        ytickformat = "{:.0f}",
        ),
    OlaDataz.date,
    OlaDataz.e,
    figure = (; size = (400, 200)),
)

# zero line
hlines!(fig[1,2], 0, color = (:black, 0.25))


# exchange rate (ola)
tslines!(
    Axis(
        fig[2,1], 
        title = "Inflación",
        subtitle = "representación ola (%)",
        xticklabelsize = 17,
        yticklabelsize = 25,
        ytickformat = "{:.0f}",
        ),
    OlaDataz.date,
    OlaDataz.core_cpi,
    figure = (; size = (400, 200)),
)

# zero line
hlines!(fig[2,1], 0, color = (:black, 0.25))

# real exchange rate (ola)
tslines!(
    Axis(
        fig[2,2], 
        title = "Depreciación cambiaria real",
        subtitle = "representación ola (%)",
        xticklabelsize = 17,
        yticklabelsize = 25,
        ytickformat = "{:.0f}",
        ),
    OlaDataz.date,
    OlaDataz.z,
    figure = (; size = (400, 200)),
)

# zero line
hlines!(fig[2,2], 0, color = (:black, 0.25))

# Mean
hl1 = hlines!(fig[2,2], mean(OlaDataz.z), color = :black, linestyle = :dash)
# Median
hl2 = hlines!(fig[2,2], median(OlaDataz.z), color = :black, linestyle = :dot)

# text
text!(
    fig[2,2], 
    datetime2rata(Date(2011, 03, 01)), 7, 
    text = L"z = π^* + e - π",
    fontsize = 25)

Legend(
    fig[3,2],
    [hl1, hl2], 
    [
        "Promedio",
        "Mediana"
    ],
    tellwidth = false,
    framevisible = false,
    orientation = :horizontal,
    labelsize = 18
)

Label(
    fig[4,2], 
    "Desviación estándar $(round(std(OlaDataz.z), digits=4)) \t \t \t \t media $(round(mean(OlaDataz.z), digits=4)) \t \t \t \t mediana $(round(median(OlaDataz.z), digits=4))",
    fontsize = 18,
    tellwidth = false,
    halign = :center
    )

Label(
    fig[5,1:2],
    "*Construido a partir de las variables 'ola' de la inflación externa y doméstica, y de la depreciación cambiaria nominal.",
    halign = :left
)

save(plotsdir("ola", "CPI", "z.png"), fig, px_per_unit = 2.0)