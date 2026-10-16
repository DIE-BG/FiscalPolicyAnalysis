#=
The developing of the version 1.5 of the model requires a new parameter that will be used to control
the magnitude of the reaction of Domestic Net Assets (AIN) to the changes in the External Public Debt (AEN).

In the version 1.5 we model the effect of contemporaneous shocks in the External Public Debt on AEN
as a direct effect and the effect on AIN as an filtered effect by the γ parameter. The γ parameter must be a 
number between -1 and 0.

One posible way to estimate the γ  parameter is to use the following formula:

γ = (ΔAIN / ΔAEN)

Where:
Δ = quarter-over-quarter change in the "ola" variables.

The mean or median of the distribution of the could be used as the estimate of the γ parameter.

=#

using DrWatson
@quickactivate "FiscalPolicyAnalysis"

using Statistics
using CSV, DataFrames
using CairoMakie

## Load the data
# first we check if the data exists
if !isfile("data/processing/ola_variables.csv")
    error("The file data/processing/ola_variables.csv does not exist. Please create it first using the processing scripts.")
else 
    ola_variables = CSV.read("data/processing/ola_variables.csv", DataFrame)
end

## compute the quarter-over-quarter changes for AIN and AEN
ola_variables[:, :qqAIN] = [NaN; diff(ola_variables[:, :AIN])]
ola_variables[:, :qqAEN] = [NaN; diff(ola_variables[:, :AEN])]

# compute the ratio of the changes in AIN and AEN
ola_variables[:, :gamma] = ola_variables[:, :qqAIN] ./ ola_variables[:, :qqAEN]

# compute the number of observations for the gamma parameter above and below zero
num_gamma_above_zero = sum(ola_variables[2:end, :gamma] .> 0)
num_gamma_below_zero = sum(ola_variables[2:end, :gamma] .< 0)

## Create a subplot of the changes in AIN and AEN
fig = Figure(size = (600, 800))

# AIN
ax = Axis(
    fig[1,1],
    title = "Diferencia intertrimestral de los activos internos netos (AIN)",
    subtitle = "La diferencia fue aplicada sobre la variable ola"
)

lines!(
    ax,
    ola_variables[2:end, :qqAIN],
    color = :blue
)

# add a zeroline
hlines!(ax, [0], color = :black, linestyle = :dash)

# AEN
ax = Axis(
    fig[2,1],
    title = "Diferencia intertrimestral de los activos externos netos (AEN)",
    subtitle = "La diferencia fue aplicada sobre la variable ola"
)

lines!(
    ax,
    ola_variables[2:end, :qqAEN],
    color = :red
)

# add a zeroline
hlines!(ax, [0], color = :black, linestyle = :dash)

# ratio of the changes in AIN and AEN

ax = Axis(
    fig[3,1],
    title = L"\text{Cociente de las diferencias intertrimestrales } \frac{ΔAIN}{ΔAEN}"
)

lines!(
    ax,
    ola_variables[2:end, :gamma],
    color = :green
)

# add a zeroline
hlines!(ax, [0], color = :black, linestyle = :dash)

# add a text indicating the mean and median of the distribution of the gamma parameter
mean_gamma = mean(ola_variables[2:end, :gamma])
median_gamma = median(ola_variables[2:end, :gamma])

textlabel!(
    ax,
    Point2f(7, 20),
    text = "Media = $(round(mean_gamma, digits = 4))\nMediana = $(round(median_gamma, digits = 4))",
    fontsize = 11,
    strokewidth = 0
)

# add a text indicating the number of observations above and below zero
textlabel!(
    ax,
    Point2f(10, -15),
    text = "observaciones positivas: $num_gamma_above_zero\nobservaciones negativas: $num_gamma_below_zero",
    fontsize = 11,
    strokewidth = 0
)

fig

# save the plot
save(plotsdir("gamma_parameter.png"), fig, px_per_unit = 2)

## Get the mean and median of the distribution of the gamma parameter
mean_gamma = mean(ola_variables[2:end, :gamma])
median_gamma = median(ola_variables[2:end, :gamma])