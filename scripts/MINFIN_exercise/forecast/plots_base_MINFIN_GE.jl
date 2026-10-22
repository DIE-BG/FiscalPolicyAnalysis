#=
    Script to plot the forecast results for the base scenario forcing the path of the
    fiscal variables.

=#
using DrWatson
@quickactivate "FiscalPolicyAnalysis"

using CairoMakie
using CSV, DataFrames, DataFramesMeta, Dates
using Mudie
using TerminalPager

ModelPath = "MINFIN_exercise"

# ===== Check if the forecast plots folder exists, if not, create it =====
if !isdir(joinpath("Models", ModelPath, "plots"))

    mkdir(joinpath("Models", ModelPath, "plots"))
    mkdir(joinpath("Models", ModelPath, "plots", "forecast"))
    println("The folder for the forecast plots has been created.")

else
    println("The folder for the forecast plots already exists.")
end

# Create the folder for the base scenario
mkdir(joinpath("Models", ModelPath, "plots", "forecast", "MINFIN_scenario"))

# ====== We will plot the series for the model ======
# Load base scenario data for model 1.5
base_escenario = CSV.read(joinpath("Models", ModelPath, "forecast", "forecast_GE.csv"), DataFrame; skipto = 12, select = 2:57)
base_escenario.date = collect(Date(2009, 3):Month(3):Date(2033, 12))

# load variables names
var_names = CSV.read(joinpath("Models", ModelPath, "forecast", "forecast_GE.csv"), DataFrame; limit = 1, select = 2:57)
vars = names(base_escenario)[1:end-1]

# Create the data frame only with historical data
HistoricalData = @chain base_escenario begin
    @subset :date .<= Date(2025, 12)
end

# ===== Plot the series =====

for i in 1:length(vars)

    var = vars[i]
    name = var_names[1, var]

    fig = Figure(size = (1350, 800))

    ax = Axis(
        fig[1,1,],
        title = name,
        subtitle = var,
        titlesize = 25,
        subtitlesize = 22,
        xlabelsize = 20,
        ylabelsize = 20,
        xgridvisible = false,
        ygridvisible = false
    )

    # Forecast from free scenario
    lines!(
        ax,
        datetime2rata.(base_escenario.date),
        base_escenario[:, var],
        label = "Pronóstico con datos MINFIN",
        color = :blue
    )

    # Historial data
    lines!(
        ax,
        datetime2rata.(HistoricalData.date),
        HistoricalData[:, var],
        label = "Historia",
        color = :black
    )

    vlines!(
        ax,
        datetime2rata.(Date(2026, 6)),
        linestyle = :dash,
        color = :black,
        linewidth = 0.75,
        label = "Fin de historia"
    )

    if occursin(r"\(ola\)", name)
        hlines!(
            ax,
            0.0,
            color = :black,
            linewidth = 1
        )
    end

    Mudie.dateticks!(ax, first(base_escenario.date):last(base_escenario.date), step = Month(28))

    Legend(fig[2,1], ax, orientation = :horizontal, framevisible = false, padding = (10, 10, 10, 10), spacing = 20, labelsize = 18)

    # ===== table =====
    tbl = fig[3, 1] = GridLayout()

    headers = ["Escenario", "2026Q2", "2026Q4", "2027Q4", "2029Q4", "2031Q4", "2032Q4", "2033Q4"]
    data = [
            (
                "Pronóstico\ndatos MINFIN", 
                base_escenario[base_escenario.date .== Date(2026, 6, 1), var],
                base_escenario[base_escenario.date .== Date(2026, 12, 1), var],
                base_escenario[base_escenario.date .== Date(2027, 12, 1), var],
                base_escenario[base_escenario.date .== Date(2029, 12, 1), var],
                base_escenario[base_escenario.date .== Date(2031, 12, 1), var],
                base_escenario[base_escenario.date .== Date(2032, 12, 1), var],
                base_escenario[base_escenario.date .== Date(2033, 12, 1), var]
            )
    ]

    # Headings
    for (j, h) in enumerate(headers)
        Box(tbl[1, j], color = :gray90, strokecolor = :black, tellwidth = false)
        Label(tbl[1, j], h, font = :bold, padding = (8, 8, 8, 8), tellwidth = false, fontsize = 17)
    end

    # cells
    for k in 1:length(data)
        row = data[k]
        for j in 1:length(row)
            Box(tbl[k + 1, j], color = :white, strokecolor = :black, tellwidth = false)
            txt = j == 1 ? string(row[j]) : string(round(row[j][1], digits = 2))
            Label(tbl[k + 1, j], txt, padding = (8, 8, 8, 8), tellwidth = false, fontsize = 17, justification = :left)
        end
    end
    

    rowgap!(tbl, 2)
    colgap!(tbl, 2)

    resize_to_layout!(fig)

    save(joinpath("Models",ModelPath, "plots", "forecast", "MINFIN_scenario", string(i)*"_"*var*".png"), fig, px_per_unit = 2)

end
