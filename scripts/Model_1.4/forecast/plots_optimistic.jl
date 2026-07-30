#=
    Scritp to plots the forecast of the model
=#
using DrWatson
@quickactivate "FiscalPolicyAnalysis"

using CairoMakie
using CSV, DataFrames, DataFramesMeta, Dates
using Mudie
using TerminalPager

ModelPath = "Model_1.4"

# ===== Check if the forecast plots folder exists, if not, create it =====
if !isdir(joinpath("Models", ModelPath, "plots", "forecast"))

    mkdir(joinpath("Models", ModelPath, "plots", "forecast"))
        println("The folder for the forecast plots has been created.")

else
    println("The folder for the forecast plots already exists.")
end

# Create the folder for the base scenario
mkdir(joinpath("Models", ModelPath, "plots", "forecast", "optimistic_scenario"))

# ====== We will plot the series for the model ======
# Load free forecast data
optimistic_scenario = CSV.read(joinpath("Models", ModelPath, "forecast", "forecast_optimistic.csv"), DataFrame; skipto = 12, select = 2:52)
optimistic_scenario.date = collect(Date(2009, 3):Month(3):Date(2056, 12))

# load variables names
var_names = CSV.read(joinpath("Models", ModelPath, "forecast", "forecast_optimistic.csv"), DataFrame; limit = 1, select = 2:52)
vars = names(optimistic_scenario)[1:end-1]

# Create the data frame only with historical data
HistoricalData = @chain optimistic_scenario begin
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
        datetime2rata.(optimistic_scenario.date),
        optimistic_scenario[:, var],
        label = "Escenario optimista",
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
        datetime2rata.(Date(2025, 12)),
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

    Mudie.dateticks!(ax, first(optimistic_scenario.date):last(optimistic_scenario.date), step = Month(28))

    Legend(fig[2,1], ax, orientation = :horizontal, framevisible = false, padding = (10, 10, 10, 10), spacing = 20, labelsize = 18)

    # ===== table =====
    tbl = fig[3, 1] = GridLayout()

    headers = ["Escenario", "2025Q4", "2026Q1", "2026Q2", "2026Q3", "2026Q4", "2036Q4", "2046Q4", "2056Q1"]
    data = [
            (
                "optimista", 
                optimistic_scenario[optimistic_scenario.date .== Date(2025, 12, 1), var],
                optimistic_scenario[optimistic_scenario.date .== Date(2026, 3, 1), var],
                optimistic_scenario[optimistic_scenario.date .== Date(2026, 6, 1), var],
                optimistic_scenario[optimistic_scenario.date .== Date(2026, 9, 1), var],
                optimistic_scenario[optimistic_scenario.date .== Date(2025, 12, 1), var],
                optimistic_scenario[optimistic_scenario.date .== Date(2036, 12, 1), var],
                optimistic_scenario[optimistic_scenario.date .== Date(2046, 12, 1), var],
                optimistic_scenario[optimistic_scenario.date .== Date(2056, 12, 1), var]
            ),
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

    save(joinpath("Models",ModelPath, "plots", "forecast", "optimistic_scenario", string(i)*"_"*var*".png"), fig, px_per_unit = 2)

end
