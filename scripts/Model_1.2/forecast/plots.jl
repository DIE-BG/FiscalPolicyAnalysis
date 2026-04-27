
# Script that checks the stability of a proposed VAR system 
# The VAR is assessed based on its eigenvalues and the 
# behavior of the dynamic multipliers.

using DrWatson
@quickactivate "FiscalPolicyAnalysis"

using CairoMakie
using CSV, DataFrames, DataFramesMeta, Dates
using Mudie
using TerminalPager

# ===== Check if the forecast plots folder exists, if not, create it =====
    if !isdir(joinpath("Models", "Model_1.2", "plots", "forecast"))

        mkdir(joinpath("Models", "Model_1.2", "plots", "forecast"))
            println("The folder for the forecast plots has been created.")

    else
        println("The folder for the forecast plots already exists.")
    end


##### We will plot the series for the model only exogenize the variable u9
# Load free forecast data
FreeForecastData = CSV.read(joinpath("Models", "Model_1.2", "forecast", "free_forecast.csv"), DataFrame; skipto = 12, select = 2:51)
FreeForecastData.date = collect(Date(2009, 3):Month(3):Date(2056, 12))

# load variables names
var_names = CSV.read(joinpath("Models", "Model_1.2", "forecast", "free_forecast.csv"), DataFrame; limit = 1, select = 2:51)
vars = names(FreeForecastData)[1:end-1]

# Load forecast with u9 path
ForecastWithU9Data = CSV.read(joinpath("Models", "Model_1.2", "forecast", "forecast_with_u9_path.csv"), DataFrame; skipto = 12, select = 2:51)
ForecastWithU9Data.date = collect(Date(2009, 3):Month(3):Date(2056, 12))

# Load forecast with u5 and u9 paths
ForecastWithU9andU5Data = CSV.read(joinpath("Models", "Model_1.2", "forecast", "forecast_with_u9_and_u5_path.csv"), DataFrame; skipto = 12, select = 2:51)
ForecastWithU9andU5Data.date = collect(Date(2009, 3):Month(3):Date(2056, 12))

# Create the data frame only with historical data
HistoricalData = @chain FreeForecastData begin
    @subset :date .<= Date(2025, 9)
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
        datetime2rata.(FreeForecastData.date),
        FreeForecastData[:, var],
        label = "VAR libre",
        color = :blue
    )

    # Forecast With u9 path
    lines!(
        ax,
        datetime2rata.(ForecastWithU9Data.date),
        ForecastWithU9Data[:, var],
        label = "Escenario con efecto de u9",
        color = :red
    )

    # Forecast With u5 and u9 paths
    lines!(
        ax,
        datetime2rata.(ForecastWithU9andU5Data.date),
        ForecastWithU9andU5Data[:, var],
        label = "Escenario con efecto de u9 y correcció por u5",
        color = :green
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
        datetime2rata.(Date(2025, 9)),
        linestyle = :dash,
        color = :black,
        linewidth = 0.75,
        label = "Fin de historia"
    )

    hlines!(
        ax,
        0.0,
        color = :black,
        linewidth = 1
    )

    Mudie.dateticks!(ax, first(FreeForecastData.date):last(FreeForecastData.date), step = Month(28))

    Legend(fig[2,1], ax, orientation = :horizontal, framevisible = false, padding = (10, 10, 10, 10), spacing = 20, labelsize = 18)

    # ===== table =====
    tbl = fig[3, 1] = GridLayout()

    headers = ["Escenario", "2025Q3", "2025Q4", "2026Q1", "2026Q2", "2026Q3", "2026Q4", "2036Q4", "2046Q4", "2056Q1"]
    data = [
            (
                "VAR libre", 
                FreeForecastData[FreeForecastData.date .== Date(2025, 9, 1), var], 
                FreeForecastData[FreeForecastData.date .== Date(2025, 12, 1), var],
                FreeForecastData[FreeForecastData.date .== Date(2026, 3, 1), var],
                FreeForecastData[FreeForecastData.date .== Date(2026, 6, 1), var],
                FreeForecastData[FreeForecastData.date .== Date(2026, 9, 1), var],
                FreeForecastData[FreeForecastData.date .== Date(2025, 12, 1), var],
                FreeForecastData[FreeForecastData.date .== Date(2036, 12, 1), var],
                FreeForecastData[FreeForecastData.date .== Date(2046, 12, 1), var],
                FreeForecastData[FreeForecastData.date .== Date(2056, 12, 1), var]
            ),

            (
                "Escenario con \nefecto de u9", 
                ForecastWithU9Data[ForecastWithU9Data.date .== Date(2025, 9, 1), var], 
                ForecastWithU9Data[ForecastWithU9Data.date .== Date(2025, 12, 1), var],
                ForecastWithU9Data[ForecastWithU9Data.date .== Date(2026, 3, 1), var],
                ForecastWithU9Data[ForecastWithU9Data.date .== Date(2026, 6, 1), var],
                ForecastWithU9Data[ForecastWithU9Data.date .== Date(2026, 9, 1), var],
                ForecastWithU9Data[ForecastWithU9Data.date .== Date(2025, 12, 1), var],
                ForecastWithU9Data[ForecastWithU9Data.date .== Date(2036, 12, 1), var],
                ForecastWithU9Data[ForecastWithU9Data.date .== Date(2046, 12, 1), var],
                ForecastWithU9Data[ForecastWithU9Data.date .== Date(2056, 12, 1), var]
            ),

            (
                "Escenario con \nefecto de u9 y \ncorrecció por u5", 
                ForecastWithU9andU5Data[ForecastWithU9andU5Data.date .== Date(2025, 9, 1), var], 
                ForecastWithU9andU5Data[ForecastWithU9andU5Data.date .== Date(2025, 12, 1), var],
                ForecastWithU9andU5Data[ForecastWithU9andU5Data.date .== Date(2026, 3, 1), var],
                ForecastWithU9andU5Data[ForecastWithU9andU5Data.date .== Date(2026, 6, 1), var],
                ForecastWithU9andU5Data[ForecastWithU9andU5Data.date .== Date(2026, 9, 1), var],
                ForecastWithU9andU5Data[ForecastWithU9andU5Data.date .== Date(2025, 12, 1), var],
                ForecastWithU9andU5Data[ForecastWithU9andU5Data.date .== Date(2036, 12, 1), var],
                ForecastWithU9andU5Data[ForecastWithU9andU5Data.date .== Date(2046, 12, 1), var],
                ForecastWithU9andU5Data[ForecastWithU9andU5Data.date .== Date(2056, 12, 1), var]
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

    save(joinpath("Models","Model_1.2", "plots", "forecast", string(i)*"_"*var*".png"), fig, px_per_unit = 2)

end
