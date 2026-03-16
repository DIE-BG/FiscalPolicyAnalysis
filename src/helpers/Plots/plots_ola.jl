function PlotOla(Oladata::DataFrame, variables::Vector{String}; varnames::Vector{String}, savepath::String)

    for i in 1:length(variables)
        var = variables[i]
        var_name = varnames[i]

        fig = Figure(size = (900, 600))

        # Plot
        tslines!(
            Axis(
                fig[1,1], 
                title = "Representación \"ola\" de $var_name",
                titlesize = 18,
                ytickformat = "{:.4f}",
                ),
            Oladata.date,
            Oladata[:, var]
        )

        # zeroline
        hlines!(fig[1,1], 0, color = (:black, 0.25))

        # Mean
        hl1 = hlines!(fig[1,1], mean(Oladata[:, var]), color = :black, linestyle = :dash)
        # Median
        hl2 = hlines!(fig[1,1], median(Oladata[:, var]), color = :black, linestyle = :dot)

        Legend(
            fig[2,1],
            [hl1, hl2], 
            [
                "Promedio",
                "Mediana"
            ],
            tellwidth = false,
            framevisible = false,
            orientation = :horizontal
        )

        Label(
            fig[3,1], 
            "Desviación estándar $(round(std(Oladata[:, var]), digits=4)) \t \t \t \t media $(round(mean(Oladata[:, var]), digits=4)) \t \t \t \t mediana $(round(median(Oladata[:, var]), digits=4))",
            tellwidth = false,
            halign = :center
            )

        fig

        # export figure
        isdir(plotsdir(savepath)) ? "The $(plotsdir(savepath)) exists" : mkdir(plotsdir(savepath))
        save(plotsdir(savepath, var*".png"), fig, px_per_unit=2.0)
    end

end