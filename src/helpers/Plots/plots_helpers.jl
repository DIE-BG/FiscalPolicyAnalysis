using Statistics
using DataFrames
using Mudie
using Formatting
include(srcdir("helpers", "Plots", "ola_helpers.jl"))

"""
    moving_avg(d::Vector{Date}, x::Vector)
    
    Construct the moving average as shown in the paper. This means that the moving average is a four step back, but
    moved one step forward. 
"""
function moving_avg(d::Vector{Date}, x::Vector, T::Int)
    n = length(x)
    ma = Vector{Union{Missing, Float64}}(missing, n)

    for t in T+1:n
        ma[t] = mean(x[t-T:t-1])
    end

    out_df = DataFrame(date = d[T+1:end], value = ma[T+1:end])

    return out_df
end

"""
    PlotFlowVariable(mdf::DataFrame,  qdf::DataFrame, variables::Vector{String}; varnames::Vector{String}, savepath::String)

    Create a subplot of eigth boxes. Each of the boxes contains specifict plots in order to show how the "ola" variable is calculated.
    
    The first plot shows the data comes the sourse, this means the data didn't was transformed in any way. Generally the data is monthly.
    
    The second one is the quarterly version of the variable. We have considered that the average within the quarter is a suitable method 
    to converting the data from monthly to quarterly frequency.

    Third shows the moving sum of the variable. We have considered that that the four steps backward sum is an appropriate way to managing with the
    stationary component of the variable. Moreover, The moving sum as showed here is the most suitable transformation for a flow variable, because
    allows us observing its trend.

    Fourth plots the nominal GDP.

    The fifth is the moving sum version of the nominal GDP. As in the third box, this transformation is the best way to dealing with the stationary
    process within the GDP behavor.

    Sixth, GDP and the variable, both in their moving average versions, are plotted together, although each one has its own axe.

    seventh, both the ratio variable/GDP and its moving average "ola" are showed in the same box.

    eighth, shows the "ola" version of the variable. Moreover, its mean and median are represented as a horizontal lines across the graph.
    The dashed line represents the meand and the dot line refers to the median.

"""
function PlotRatioFlowVariable(
    mdf::DataFrame,  
    qdf::DataFrame, 
    variables::Vector{String}; 
    varnames::Vector{String}, 
    savepath::String, 
    T::Int
    )
    for i in 1:length(variables)
        var = variables[i]
        var_name = varnames[i]

            fig = Figure(size = (1800, 2500), fontsize = 30)

            Label(
                fig[0,1:2], 
                "Construcción de la variable \"ola\" para $var_name", 
                fontsize = 45,
                font = :bold
                )

            # plot 1
            tslines!(
                Axis(
                    fig[1,1], 
                    title = var_name,
                    subtitle = "Millones de quetzales \nFrecuencia mensual",
                    xticklabelsize = 17,
                    yticklabelsize = 25,
                    ytickformat = v -> format.(v, commas=true, precision=0)
                    ),
                mdf.date,
                mdf[:, var],
                figure = (; size = (400, 200)),
            )

            # Plot 2
            tslines!(
                Axis(
                    fig[1,2],
                    title = var_name,
                    subtitle = "Millones de quetzales \nFrecuencia trimestral",
                    xticklabelsize = 17,
                    yticklabelsize = 25,
                    ytickformat = v -> format.(v, commas=true, precision=0)
                    ),
                qdf.date,
                qdf[:, var],
                figure = (; size = (400, 200)),
            )

            # Plot 3
            var_SM = SM(qdf.date, qdf[:, var], T)
            tslines!(
                Axis(
                    fig[2,1],
                    title = "Suma móvil de $T trimestres de $var_name",
                    subtitle = "Millones de quezales",
                    xticklabelsize = 17,
                    yticklabelsize = 25,
                    ytickformat = v -> format.(v, commas=true, precision=0)
                    ),
                var_SM.date,
                var_SM.value,
                figure = (; size = (400, 200)),
            )

            # Plot 4
            tslines!(
                Axis(
                    fig[2,2],
                    title = "PIB nominal de Guatemala",
                    subtitle = "Millones de quetzales \nFrecuencia trimestral",
                    xticklabelsize = 17,
                    yticklabelsize = 25,
                    ytickformat = v -> format.(v, commas=true, precision=0)
                    ),
                qdf.date,
                qdf.GDP_nom,
                figure = (; size = (400, 200)),
            )

            # Plot 5
            GDP_SM = SM(qdf.date, qdf.GDP_nom, T)
            tslines!(
                Axis(
                    fig[3,1],
                    title = "Suma móvil de $T trimestres del PIB nominal de Guatemala",
                    subtitle = "Millones de quezales",
                    xticklabelsize = 17,
                    yticklabelsize = 25,
                    ytickformat = v -> format.(v, commas=true, precision=0)
                    ),
                GDP_SM.date,
                GDP_SM.value,
                figure = (; size = (400, 200)),
            )

            # Plot 6
            ax = Axis(
                fig[3,2],
                title = "Evolución conjunta de la suma móvil de $T trimestres",
                subtitle = "$var_name y PIB",
                xticklabelsize = 17,
                yticklabelsize = 25,
                ytickformat = v -> format.(v, commas=true, precision=0)
            )

            l1 = lines!(
                ax,
                datetime2rata.(var_SM.date),
                var_SM.value
            )

            ax2 = Axis(
                fig[3,2], 
                yticklabelcolor = :red, 
                yaxisposition = :right, 
                yticklabelsize = 25,
                ytickformat = v -> format.(v, commas=true, precision=0),
                xgridvisible = false,
                ygridvisible = false
                )

            hidespines!(ax2)
            hidexdecorations!(ax2)

            l2 = lines!(
                ax2,
                datetime2rata.(GDP_SM.date),
                GDP_SM.value,
                color = :red
            )

            linkxaxes!(ax, ax2)

            Mudie.dateticks!(ax, first(var_SM.date):last(var_SM.date))

            Legend(
                fig[4,2], 
                [l1, l2], 
                [var_name, "PIB"],
                orientation = :horizontal,
                tellwidth = false,
                framevisible = false,
                labelsize = 18
                )

            # Plot 7
            var_GDP_Mavg = moving_avg(var_SM.date, (var_SM.value./GDP_SM.value).*100, T)

            ax = Axis(
                fig[5,1],
                title ="Cociente de la suma móvil de $T trimestres",
                subtitle = "Numerador: $var_name\nDenominador: PIB nominal",
                xticklabelsize = 20,
                yticklabelsize = 25
            )

            l1 = lines!(
                ax,
                datetime2rata.(var_GDP_Mavg.date),
                (var_SM.value[T+1:end]./GDP_SM.value[T+1:end]).*100
                )

            

            l2 = lines!(
                ax, 
                datetime2rata.(var_GDP_Mavg.date), 
                var_GDP_Mavg.value,
                color = :red
                )

            Mudie.dateticks!(ax, first(var_SM.date):last(var_SM.date))

            # Mean
            h1 = hlines!(
                ax,
                mean((var_SM.value[T+1:end]./GDP_SM.value[T+1:end]).*100),
                color = :black, 
                linestyle = :dash
            )

            # Median
            h2 = hlines!(
                ax,
                median((var_SM.value[T+1:end]./GDP_SM.value[T+1:end]).*100),
                color = :black, 
                linestyle = :dot
            )

            Legend(
                fig[6,1],
                [l1, l2, h1, h2],
                [
                    "Cociente", 
                    "Promedio móvil de $T trimestres del cociente\n(adelantado un periodo)", 
                    "Promedio del cociente", 
                    "Mediana del cociente"
                ],
                framevisible = false,
                orientation = :horizontal,
                nbanks = 2,
                tellwidth = false,
                labelsize = 18
            )

            Label(
                fig[7,1], 
                "Desviación estándar $(round(std((var_SM.value[T+1:end]./GDP_SM.value[T+1:end]).*100), digits=4)) \t \t \t \t media $(round(mean((var_SM.value[T+1:end]./GDP_SM.value[T+1:end]).*100), digits=4)) \t \t \t \t $(round(median((var_SM.value[T+1:end]./GDP_SM.value[T+1:end]).*100), digits=4))",
                fontsize = 18,
                tellwidth = false,
                halign = :center
                )

            # Plot 8

            var_ola = ola_var(var_SM.date, (var_SM.value./GDP_SM.value).*100, T)

            tslines!(
                Axis(
                    fig[5,2],
                    title = var_name,
                    subtitle = "Representación \"ola\" de la variable",
                    xticklabelsize = 20,
                    yticklabelsize = 25
                    ),
                var_ola.date,
                var_ola.value,
            )

            # zeroline
            hlines!(fig[5,2], 0, color = (:black, 0.25))

            # Mean
            hl1 = hlines!(fig[5,2], mean(var_ola.value), color = :black, linestyle = :dash)
            # Median
            hl2 = hlines!(fig[5,2], median(var_ola.value), color = :black, linestyle = :dot)

            Legend(
                fig[6,2],
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
                fig[7,2], 
                "Desviación estándar $(round(std(var_ola.value), digits=4)) \t \t \t \t media $(round(mean(var_ola.value), digits=4)) \t \t \t \t mediana $(round(median(var_ola.value), digits=4))",
                fontsize = 18,
                tellwidth = false,
                halign = :center
                )

            fig

            # export figure
            isdir(plotsdir(savepath)) ? "The $(plotsdir(savepath)) exists" : mkdir(plotsdir(savepath))
            save(plotsdir(savepath, var*".png"), fig, px_per_unit=2.0)

    end

end

function PlotRatioStockVariable(
    mdf::DataFrame,  
    qdf::DataFrame, 
    variables::Vector{String}; 
    varnames::Vector{String}, 
    savepath::String, 
    T::Int
    )

    for i in 1:length(variables)
        var = variables[i]
        var_name = varnames[i]

            fig = Figure(size = (1800, 2500), fontsize = 30)

            Label(
                fig[0,1:2], 
                "Construcción de la variable \"ola\" para $var_name", 
                fontsize = 45,
                font = :bold
                )

            # plot 1
            tslines!(
                Axis(
                    fig[1,1], 
                    title = var_name,
                    subtitle = "Millones de quetzales \nFrecuencia mensual",
                    xticklabelsize = 17,
                    yticklabelsize = 25,
                    ytickformat = v -> format.(v, commas=true, precision=0)
                    ),
                mdf.date,
                mdf[:, var],
                figure = (; size = (400, 200)),
            )

            # Plot 2
            tslines!(
                Axis(
                    fig[1,2],
                    title = var_name,
                    subtitle = "Millones de quetzales \nFrecuencia trimestral",
                    xticklabelsize = 17,
                    yticklabelsize = 25,
                    ytickformat = v -> format.(v, commas=true, precision=0)
                    ),
                qdf.date,
                qdf[:, var],
                figure = (; size = (400, 200)),
            )

            # Plot 3
            var_Mavg = SimpleMavg(qdf.date, qdf[:, var], T)
            tslines!(
                Axis(
                    fig[2,1],
                    title = "Promedio móvil de $T trimestres de $var_name",
                    subtitle = "Millones de quezales",
                    xticklabelsize = 17,
                    yticklabelsize = 25,
                    ytickformat = v -> format.(v, commas=true, precision=0)
                    ),
                var_Mavg.date,
                var_Mavg.value,
                figure = (; size = (400, 200)),
            )

            # Plot 4
            tslines!(
                Axis(
                    fig[2,2],
                    title = "PIB nominal de Guatemala",
                    subtitle = "Millones de quetzales \nFrecuencia trimestral",
                    xticklabelsize = 17,
                    yticklabelsize = 25,
                    ytickformat = v -> format.(v, commas=true, precision=0)
                    ),
                qdf.date,
                qdf.GDP_nom,
                figure = (; size = (400, 200)),
            )

            # Plot 5
            GDP_SM = SM(qdf.date, qdf.GDP_nom, T)
            tslines!(
                Axis(
                    fig[3,1],
                    title = "Suma móvil de $T trimestres del PIB nominal de Guatemala",
                    subtitle = "Millones de quezales",
                    xticklabelsize = 17,
                    yticklabelsize = 25,
                    ytickformat = v -> format.(v, commas=true, precision=0)
                    ),
                GDP_SM.date,
                GDP_SM.value,
                figure = (; size = (400, 200)),
            )

            # Plot 6
            ax = Axis(
                fig[3,2],
                title = "Evolución conjunta",
                subtitle = "Promedio móvil de $var_name y suma móvil PIB",
                xticklabelsize = 17,
                yticklabelsize = 25,
                ytickformat = v -> format.(v, commas=true, precision=0)
            )

            l1 = lines!(
                ax,
                datetime2rata.(var_Mavg.date),
                var_Mavg.value
            )

            ax2 = Axis(
                fig[3,2], 
                yticklabelcolor = :red, 
                yaxisposition = :right, 
                yticklabelsize = 25,
                ytickformat = v -> format.(v, commas=true, precision=0),
                xgridvisible = false,
                ygridvisible = false
                )

            hidespines!(ax2)
            hidexdecorations!(ax2)

            l2 = lines!(
                ax2,
                datetime2rata.(GDP_SM.date),
                GDP_SM.value,
                color = :red
            )

            linkxaxes!(ax, ax2)

            Mudie.dateticks!(ax, first(var_Mavg.date):last(var_Mavg.date))

            Legend(
                fig[4,2], 
                [l1, l2], 
                [var_name, "PIB"],
                orientation = :horizontal,
                tellwidth = false,
                framevisible = false,
                labelsize = 18
                )

            # Plot 7
            var_GDP_Mavg = moving_avg(var_Mavg.date, (var_Mavg.value./GDP_SM.value).*100, T)

            ax = Axis(
                fig[5,1],
                title ="Cociente",
                subtitle = "Numerador: Promedio móvil de $var_name\nDenominador: Suma móvil del PIB nominal",
                xticklabelsize = 20,
                yticklabelsize = 25
            )

            l1 = lines!(
                ax,
                datetime2rata.(var_GDP_Mavg.date),
                (var_Mavg.value[T+1:end]./GDP_SM.value[T+1:end]).*100
                )

            

            l2 = lines!(
                ax, 
                datetime2rata.(var_GDP_Mavg.date), 
                var_GDP_Mavg.value,
                color = :red
                )

            Mudie.dateticks!(ax, first(var_Mavg.date):last(var_Mavg.date))

            # Mean
            h1 = hlines!(
                ax,
                mean((var_Mavg.value[T+1:end]./GDP_SM.value[T+1:end]).*100),
                color = :black, 
                linestyle = :dash
            )

            # Median
            h2 = hlines!(
                ax,
                median((var_Mavg.value[T+1:end]./GDP_SM.value[T+1:end]).*100),
                color = :black, 
                linestyle = :dot
            )

            Legend(
                fig[6,1],
                [l1, l2, h1, h2],
                [
                    "Cociente", 
                    "Promedio móvil de 4 periodos del cociente\n(adelantado un periodo)", 
                    "Promedio del cociente", 
                    "Mediana del cociente"
                ],
                framevisible = false,
                orientation = :horizontal,
                nbanks = 2,
                tellwidth = false,
                labelsize = 18
            )

            Label(
                fig[7,1],
                "Desviación estándar $(round(std((var_Mavg.value[T+1:end]./GDP_SM.value[T+1:end]).*100), digits=4)) \t \t \t \t media $(round(mean((var_Mavg.value[T+1:end]./GDP_SM.value[T+1:end]).*100), digits=4)) \t \t \t \t mediana $(round(median((var_Mavg.value[T+1:end]./GDP_SM.value[T+1:end]).*100), digits=4))", 
                fontsize = 18,
                tellwidth = false,
                halign = :center
                )

            # Plot 8

            var_ola = ola_var(var_Mavg.date, (var_Mavg.value./GDP_SM.value).*100, T)

            tslines!(
                Axis(
                    fig[5,2],
                    title = var_name,
                    subtitle = "Representación \"ola\" de la variable",
                    xticklabelsize = 20,
                    yticklabelsize = 25
                    ),
                var_ola.date,
                var_ola.value,
            )

            # zero line
            hlines!(fig[5,2], 0, color = (:black, 0.25))

            # Mean
            hl1 = hlines!(fig[5,2], mean(var_ola.value), color = :black, linestyle = :dash)
            # Median
            hl2 = hlines!(fig[5,2], median(var_ola.value), color = :black, linestyle = :dot)

            Legend(
                fig[6,2],
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
                fig[7,2], 
                "Desviación estándar $(round(std(var_ola.value), digits=4)) \t \t \t \t media $(round(mean(var_ola.value), digits=4)) \t \t \t \t mediana $(round(median(var_ola.value), digits=4))",
                fontsize = 18,
                tellwidth = false,
                halign = :center
                )

            fig

            # export figure
            isdir(plotsdir(savepath)) ? "The $(plotsdir(savepath)) exists" : mkdir(plotsdir(savepath))
            save(plotsdir(savepath, var*".png"), fig, px_per_unit=2.0)

    end

end

function PlotGrowthVariable(
    qdf::DataFrame, 
    variables::Vector{String}; 
    varnames::Vector{String},
    subtitles::Vector{String}, 
    savepath::String,
    T = 4
    )
    
    for i in 1:length(variables)
        var = variables[i]
        var_name = varnames[i]
        sub_title = subtitles[i]

        fig = Figure(size = (1600, 1100), fontsize = 20)

        Label(
            fig[0,1:2], 
            "Construcción de la variable \"ola\" de $var_name", 
            fontsize = 35,
            font = :bold
            )

        # Plot 1
        tslines!(
            Axis(
                fig[1,1], 
                title = var_name,
                subtitle = sub_title,
                xticklabelsize = 17,
                ytickformat = v -> format.(v, commas=true, precision=0)
                ),
            qdf.date,
            qdf[:, var],
            figure = (; size = (400, 200)),
        )

        # Plot 2
        GDPVariableSM = SM(qdf.date, qdf[:, var], T)
        tslines!(
            Axis(
                fig[1,2],
                title = "Suma móvil de $T trimestres del $var_name",
                subtitle = sub_title,
                xticklabelsize = 17,
                ytickformat = v -> format.(v, commas=true, precision=0)
                ),
            GDPVariableSM.date,
            GDPVariableSM.value,
            figure = (; size = (400, 200)),
        )

        # Plot 3
        GDPGrowth = yoy(GDPVariableSM.date, GDPVariableSM.value; freq = "quarterly")
        GDPGrowth_Mavg = moving_avg(GDPGrowth.date, GDPGrowth.value, T)

        ax = Axis(
            fig[2,1],
            title = "Suma móvil de $T trimestres del $var_name",
            subtitle = "Tasa de variación interanual"
        )

        l1 = lines!(ax, datetime2rata.(GDPGrowth_Mavg.date), GDPGrowth.value[T+1:end])

        l2 = lines!(ax, datetime2rata.(GDPGrowth_Mavg.date), GDPGrowth_Mavg.value, color = :red)

        Mudie.dateticks!(ax, first(GDPGrowth_Mavg.date):last(GDPGrowth_Mavg.date))

        hl1 = hlines!(ax, mean(GDPGrowth.value[T+1:end]), color = :black, linestyle = :dash)
        hl2 = hlines!(ax, median(GDPGrowth.value[T+1:end]), color = :black, linestyle = :dot)
        hlines!(ax, 0, color = :black, linewidth = 0.5)

        Legend(
            fig[3,1],
            [l1, l2, hl1, hl2], 
            [
                "Tasa de varación", 
                "Promedio móvil de $T trimestres\n(adelantado un periodo)",
                "Promedio",
                "Mediana"
            ],
            tellwidth = false,
            framevisible = false,
            orientation = :horizontal,
            labelsize = 17
        )

        Label(
            fig[4,1], 
            "Desviación estándar $(round(std(GDPGrowth.value[T+1:end]), digits=2)) \t \t \t \t media $(round(mean(GDPGrowth.value[T+1:end]), digits=2)) \t \t \t \t mediana $(round(mean(GDPGrowth.value[T+1:end]), digits=2))",
            fontsize = 17,
            tellwidth = false,
            halign = :center
            )

        # Plot 4
        GDPOla = ola_var(GDPGrowth.date, GDPGrowth.value, T)

        tslines!(
            Axis(
                fig[2,2],
                title = "Suma móvil de $T trimestres del $var_name",
                subtitle = "Representación \"ola\" de la variable",
                xticklabelsize = 17,
                ),
            GDPOla.date,
            GDPOla.value,
            figure = (; size = (400, 200)),
        )

        hl1 = hlines!(fig[2,2], mean(GDPOla.value), color = :black, linestyle = :dash)
        hl2 = hlines!(fig[2,2], median(GDPOla.value), color = :black, linestyle = :dot)

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
            labelsize = 17
        )

        Label(
            fig[4,2], 
            "Desviación estándar $(round(std(GDPOla.value), digits=2)) \t \t \t \t media $(round(mean(GDPOla.value), digits=2)) \t \t \t \t mediana $(round(median(GDPOla.value), digits=2))",
            fontsize = 17,
            tellwidth = false,
            halign = :center
            )

        fig

        # export figure
        isdir(plotsdir(savepath)) ? "The $(plotsdir(savepath)) exists" : mkdir(plotsdir(savepath))
        save(plotsdir(savepath, var*".png"), fig, px_per_unit=2.0)

    end
end

function PlotPercentageRateVariable(
    mdf::DataFrame,  
    qdf::DataFrame, 
    variables::Vector{String}; 
    varnames::Vector{String}, 
    savepath::String, 
    T::Int
    )

    for i in 1:length(variables)
        var = variables[i]
        var_name = varnames[i]

            fig = Figure(size = (1800, 2500), fontsize = 30)

            Label(
                fig[0,1:2], 
                "Construcción de la variable \"ola\" para $var_name", 
                fontsize = 45,
                font = :bold
                )

            # plot 1
            tslines!(
                Axis(
                    fig[1,1], 
                    title = var_name,
                    subtitle = "Frecuencia mensual",
                    xticklabelsize = 17,
                    yticklabelsize = 25,
                    ytickformat = "{:.0f}",
                    ),
                mdf.date,
                mdf[:, var],
                figure = (; size = (400, 200)),
            )

            # Plot 2
            tslines!(
                Axis(
                    fig[1,2],
                    title = var_name,
                    subtitle = "Frecuencia trimestral",
                    xticklabelsize = 17,
                    yticklabelsize = 25,
                    ytickformat = "{:.0f}"
                    ),
                qdf.date,
                qdf[:, var],
                figure = (; size = (400, 200)),
            )

            # Plot 3
            CPIyoy = yoy(qdf.date, qdf[:, var]; freq = "quarterly")
            tslines!(
                Axis(
                    fig[2,1],
                    title = var_name,
                    subtitle = "variación interanual",
                    xticklabelsize = 17,
                    yticklabelsize = 25,
                    ytickformat = "{:.0f}"
                    ),
                CPIyoy.date,
                CPIyoy.value,
                figure = (; size = (400, 200)),
            )

            # Plot 4
            var_GDP_Mavg = moving_avg(CPIyoy.date, CPIyoy.value, T)

            ax = Axis(
                fig[2,2],
                title = var_name,
                subtitle = "Variación interanual",
                xticklabelsize = 20,
                yticklabelsize = 25
            )

            l1 = lines!(
                ax,
                datetime2rata.(var_GDP_Mavg.date),
                CPIyoy.value[T+1:end]
                )

            
            l2 = lines!(
                ax, 
                datetime2rata.(var_GDP_Mavg.date), 
                var_GDP_Mavg.value,
                color = :red
                )

            Mudie.dateticks!(ax, first(var_GDP_Mavg.date):last(var_GDP_Mavg.date))

            # Mean
            h1 = hlines!(
                ax,
                mean(CPIyoy.value[T+1:end]),
                color = :black, 
                linestyle = :dash
            )

            # Median
            h2 = hlines!(
                ax,
                median(CPIyoy.value[T+1:end]),
                color = :black, 
                linestyle = :dot
            )

            Legend(
                fig[3,2],
                [l1, l2, h1, h2],
                [
                    "Variación interanual", 
                    "Promedio móvil de 4 periodos\n(adelantado un periodo)", 
                    "Promedio", 
                    "Mediana"
                ],
                framevisible = false,
                orientation = :horizontal,
                nbanks = 2,
                tellwidth = false,
                labelsize = 18
            )

            Label(
                fig[4,2],
                "Desviación estándar $(round(std(CPIyoy.value[T+1:end]), digits=4)) \t \t \t \t media $(round(mean(CPIyoy.value[T+1:end]), digits=4)) \t \t \t \t mediana $(round(median(CPIyoy.value[T+1:end]), digits=4))", 
                fontsize = 18,
                tellwidth = false,
                halign = :center
                )

            # Plot 5

            var_ola = ola_var(CPIyoy.date, CPIyoy.value, T)

            tslines!(
                Axis(
                    fig[5,1:2],
                    title = var_name,
                    subtitle = "Representación \"ola\" de la variable",
                    xticklabelsize = 20,
                    yticklabelsize = 25
                    ),
                var_ola.date,
                var_ola.value,
            )

            # zero line
            hlines!(fig[5,1:2], 0, color = (:black, 0.25))

            # Mean
            hl1 = hlines!(fig[5,1:2], mean(var_ola.value), color = :black, linestyle = :dash)
            # Median
            hl2 = hlines!(fig[5,1:2], median(var_ola.value), color = :black, linestyle = :dot)

            Legend(
                fig[6,1:2],
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
                fig[7,1:2], 
                "Desviación estándar $(round(std(var_ola.value), digits=4)) \t \t \t \t media $(round(mean(var_ola.value), digits=4)) \t \t \t \t mediana $(round(median(var_ola.value), digits=4))",
                fontsize = 18,
                tellwidth = false,
                halign = :center
                )

            fig

            # export figure
            isdir(plotsdir(savepath)) ? "The $(plotsdir(savepath)) exists" : mkdir(plotsdir(savepath))
            save(plotsdir(savepath, var*".png"), fig, px_per_unit=2.0)

    end
end

function SimpleVariables(
    mdf::DataFrame,  
    qdf::DataFrame, 
    variables::Vector{String}; 
    varnames::Vector{String}, 
    savepath::String, 
    T::Int
    )

    for i in 1:length(variables)
        var = variables[i]
        var_name = varnames[i]

            fig = Figure(size = (1500, 900), fontsize = 30)

            Label(
                fig[0,1:2], 
                "Construcción de la variable \"ola\" para $var_name", 
                fontsize = 45,
                font = :bold
                )

            # plot 1
            tslines!(
                Axis(
                    fig[1,1], 
                    title = var_name,
                    subtitle = "Frecuencia mensual",
                    xticklabelsize = 17,
                    yticklabelsize = 25,
                    ytickformat = "{:.0f}",
                    ),
                mdf.date,
                mdf[:, var],
                figure = (; size = (400, 200)),
            )

            # Plot 2
            tslines!(
                Axis(
                    fig[1,2],
                    title = var_name,
                    subtitle = "Frecuencia trimestral",
                    xticklabelsize = 17,
                    yticklabelsize = 25,
                    ytickformat = "{:.0f}"
                    ),
                qdf.date,
                qdf[:, var],
                figure = (; size = (400, 200)),
            )

            # Plot 4
            var_Mavg = moving_avg(qdf.date, qdf[:, var], T)

            ax = Axis(
                fig[2,1],
                title = var_name,
                xticklabelsize = 20,
                yticklabelsize = 25
            )

            l1 = lines!(
                ax,
                datetime2rata.(var_Mavg.date),
                qdf[T+1:end, var]
                )

            
            l2 = lines!(
                ax, 
                datetime2rata.(var_Mavg.date), 
                var_Mavg.value,
                color = :red
                )

            Mudie.dateticks!(ax, first(var_Mavg.date):last(var_Mavg.date))

            # Mean
            h1 = hlines!(
                ax,
                mean(qdf[T+1:end, var]),
                color = :black, 
                linestyle = :dash
            )

            # Median
            h2 = hlines!(
                ax,
                median(qdf[T+1:end, var]),
                color = :black, 
                linestyle = :dot
            )

            Legend(
                fig[3,1],
                [l1, l2, h1, h2],
                [
                    "Observación trimestral", 
                    "Promedio móvil de 4 periodos\n(adelantado un periodo)", 
                    "Promedio", 
                    "Mediana"
                ],
                framevisible = false,
                orientation = :horizontal,
                nbanks = 2,
                tellwidth = false,
                labelsize = 18
            )

            Label(
                fig[4,1],
                "Desviación estándar $(round(std(qdf[T+1:end, var]), digits=4)) \t \t \t \t media $(round(mean(qdf[T+1:end, var]), digits=4)) \t \t \t \t mediana $(round(median(qdf[T+1:end, var]), digits=4))", 
                fontsize = 18,
                tellwidth = false,
                halign = :center
                )

            # Plot 5

            var_ola = ola_var(qdf.date, qdf[:, var], T)

            tslines!(
                Axis(
                    fig[2,2],
                    title = var_name,
                    subtitle = "Representación \"ola\" de la variable",
                    xticklabelsize = 20,
                    yticklabelsize = 25
                    ),
                var_ola.date,
                var_ola.value,
            )

            # zero line
            hlines!(fig[2,2], 0, color = (:black, 0.25))

            # Mean
            hl1 = hlines!(fig[2,2], mean(var_ola.value), color = :black, linestyle = :dash)
            # Median
            hl2 = hlines!(fig[2,2], median(var_ola.value), color = :black, linestyle = :dot)

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
                "Desviación estándar $(round(std(var_ola.value), digits=4)) \t \t \t \t media $(round(mean(var_ola.value), digits=4)) \t \t \t \t mediana $(round(median(var_ola.value), digits=4))",
                fontsize = 18,
                tellwidth = false,
                halign = :center
                )

            fig

            # export figure
            isdir(plotsdir(savepath)) ? "The $(plotsdir(savepath)) exists" : mkdir(plotsdir(savepath))
            save(plotsdir(savepath, var*".png"), fig, px_per_unit=2.0)

    end
end

function PlotRatioFlowIPriv(  
    qdf::DataFrame, 
    variables::Vector{String}; 
    varnames::Vector{String}, 
    savepath::String, 
    T::Int
    )

    for i in 1:length(variables)
        var = variables[i]
        var_name = varnames[i]

            fig = Figure(size = (1800, 2500), fontsize = 30)

            Label(
                fig[0,1:2], 
                "Construcción de la variable \"ola\" para $var_name", 
                fontsize = 45,
                font = :bold
                )

            # Plot 1
            tslines!(
                Axis(
                    fig[1,1],
                    title = var_name,
                    subtitle = "Millones de quetzales \nFrecuencia trimestral",
                    xticklabelsize = 17,
                    yticklabelsize = 25,
                    ytickformat = v -> format.(v, commas=true, precision=0)
                    ),
                qdf.date,
                qdf[:, var],
                figure = (; size = (400, 200)),
            )

            # Plot 2
            var_Mavg = SM(qdf.date, qdf[:, var], T)
            tslines!(
                Axis(
                    fig[1,2],
                    title = "Suma Móvil de $T trimestres de $var_name",
                    subtitle = "Millones de quezales",
                    xticklabelsize = 17,
                    yticklabelsize = 25,
                    ytickformat = v -> format.(v, commas=true, precision=0)
                    ),
                var_Mavg.date,
                var_Mavg.value,
                figure = (; size = (400, 200)),
            )

            # Plot 4
            tslines!(
                Axis(
                    fig[2,1],
                    title = "PIB nominal de Guatemala",
                    subtitle = "Millones de quetzales \nFrecuencia trimestral",
                    xticklabelsize = 17,
                    yticklabelsize = 25,
                    ytickformat = v -> format.(v, commas=true, precision=0)
                    ),
                qdf.date,
                qdf.GDP_nom,
                figure = (; size = (400, 200)),
            )

            # Plot 5
            GDP_SM = SM(qdf.date, qdf.GDP_nom, T)
            tslines!(
                Axis(
                    fig[2,2],
                    title = "Suma móvil de $T trimestres del PIB nominal de Guatemala",
                    subtitle = "Millones de quezales",
                    xticklabelsize = 17,
                    yticklabelsize = 25,
                    ytickformat = v -> format.(v, commas=true, precision=0)
                    ),
                GDP_SM.date,
                GDP_SM.value,
                figure = (; size = (400, 200)),
            )

            # Plot 6
            ax = Axis(
                fig[3,1],
                title = "Evolución conjunta",
                subtitle = "Suma móvil de $var_name y suma móvil PIB",
                xticklabelsize = 17,
                yticklabelsize = 25,
                ytickformat = v -> format.(v, commas=true, precision=0)
            )

            l1 = lines!(
                ax,
                datetime2rata.(var_Mavg.date),
                var_Mavg.value
            )

            ax2 = Axis(
                fig[3,1], 
                yticklabelcolor = :red, 
                yaxisposition = :right, 
                yticklabelsize = 25,
                ytickformat = v -> format.(v, commas=true, precision=0),
                xgridvisible = false,
                ygridvisible = false
                )

            hidespines!(ax2)
            hidexdecorations!(ax2)

            l2 = lines!(
                ax2,
                datetime2rata.(GDP_SM.date),
                GDP_SM.value,
                color = :red
            )

            linkxaxes!(ax, ax2)

            Mudie.dateticks!(ax, first(var_Mavg.date):last(var_Mavg.date))

            Legend(
                fig[4,1], 
                [l1, l2], 
                [var_name, "PIB"],
                orientation = :horizontal,
                tellwidth = false,
                framevisible = false,
                labelsize = 18
                )

            # Plot 7
            var_GDP_Mavg = moving_avg(var_Mavg.date, (var_Mavg.value./GDP_SM.value).*100, T)

            ax = Axis(
                fig[3,2],
                title ="Cociente de la suma móvil de $T trimestres",
                subtitle = "Numerador: $var_name\nDenominador: PIB nominal",
                xticklabelsize = 20,
                yticklabelsize = 25
            )

            l1 = lines!(
                ax,
                datetime2rata.(var_GDP_Mavg.date),
                (var_Mavg.value[T+1:end]./GDP_SM.value[T+1:end]).*100
                )

            

            l2 = lines!(
                ax, 
                datetime2rata.(var_GDP_Mavg.date), 
                var_GDP_Mavg.value,
                color = :red
                )

            Mudie.dateticks!(ax, first(var_Mavg.date):last(var_Mavg.date))

            # Mean
            h1 = hlines!(
                ax,
                mean((var_Mavg.value[T+1:end]./GDP_SM.value[T+1:end]).*100),
                color = :black, 
                linestyle = :dash
            )

            # Median
            h2 = hlines!(
                ax,
                median((var_Mavg.value[T+1:end]./GDP_SM.value[T+1:end]).*100),
                color = :black, 
                linestyle = :dot
            )

            Legend(
                fig[4,2],
                [l1, l2, h1, h2],
                [
                    "Cociente", 
                    "Promedio móvil de 4 periodos del cociente\n(adelantado un periodo)", 
                    "Promedio del cociente", 
                    "Mediana del cociente"
                ],
                framevisible = false,
                orientation = :horizontal,
                nbanks = 2,
                tellwidth = false,
                labelsize = 18
            )

            Label(
                fig[5,2],
                "Desviación estándar $(round(std((var_Mavg.value[T+1:end]./GDP_SM.value[T+1:end]).*100), digits=4)) \t \t \t \t media $(round(mean((var_Mavg.value[T+1:end]./GDP_SM.value[T+1:end]).*100), digits=4)) \t \t \t \t mediana $(round(median((var_Mavg.value[T+1:end]./GDP_SM.value[T+1:end]).*100), digits=4))", 
                fontsize = 18,
                tellwidth = false,
                halign = :center
                )

            # Plot 8

            var_ola = ola_var(var_Mavg.date, (var_Mavg.value./GDP_SM.value).*100, T)

            tslines!(
                Axis(
                    fig[6,1:2],
                    title = var_name,
                    subtitle = "Representación \"ola\" de la variable",
                    xticklabelsize = 20,
                    yticklabelsize = 25
                    ),
                var_ola.date,
                var_ola.value,
            )

            # zero line
            hlines!(fig[6,1:2], 0, color = (:black, 0.25))

            # Mean
            hl1 = hlines!(fig[6,1:2], mean(var_ola.value), color = :black, linestyle = :dash)
            # Median
            hl2 = hlines!(fig[6,1:2], median(var_ola.value), color = :black, linestyle = :dot)

            Legend(
                fig[7,1:2],
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
                fig[8,1:2], 
                "Desviación estándar $(round(std(var_ola.value), digits=4)) \t \t \t \t media $(round(mean(var_ola.value), digits=4)) \t \t \t \t mediana $(round(median(var_ola.value), digits=4))",
                fontsize = 18,
                tellwidth = false,
                halign = :center
                )

            fig

            # export figure
            isdir(plotsdir(savepath)) ? "The $(plotsdir(savepath)) exists" : mkdir(plotsdir(savepath))
            save(plotsdir(savepath, var*".png"), fig, px_per_unit=2.0)

    end

end