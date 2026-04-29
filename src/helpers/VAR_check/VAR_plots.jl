"""
    EigenPlot(λ::Vector)

    Show the eigenvalues of a companion matrix within a unit circle to check the stability of the VAR system.

    - λ are the eigenvalues of the companion matrix 
"""

function EigenPlot(λ::Vector; save_path::String)

    # Unit circle
    θ = range(0, 2π, length=500)
    x_circle = cos.(θ)
    y_circle = sin.(θ)

    # Plot
    fig = Figure()
    ax = Axis(fig[1, 1],
        title = "Eigenvalores",
        aspect = DataAspect()
    )

    lines!(ax, x_circle, y_circle, linewidth=2)
    scatter!(ax, real.(λ), imag.(λ), markersize=12)

    # horizontal and vertical axes
    hlines!(ax, [0], linestyle=:dash)
    vlines!(ax, [0], linestyle=:dash)


    save(save_path, fig, px_per_unit = 2.0)
end

"""
    DynamicMultipliersPlots(Responses::Array, var_names::Vector; save_path::String)

    Plot all responses to all shocks into the Responses array. The output is a K dimensional 
    set with K as the number of variables into the VAR system.

    - Responses is an array with the responses of the VAR system
    - var_names is a vector with the names of the variables
    - save_path is the path to save the figures
"""

function DynamicMultipliersPlots(Responses::Array, shock_names::Vector, var_names::Vector; save_path::String)

    for j in 1:length(shock_names) # Create 17 separate figures, one per shock
        fig = Figure(size = (1200, 1400))
        
        # Title for the specific shock
        Label(fig[0, 1:4], "Respuestas al choque de $(var_names[j])", 
            fontsize = 32, font = :bold)

        for i in 1:length(var_names) # Subplots for each responding variable
            # Arrange in a 6x4 grid
            row = (i - 1) ÷ 4 + 1
            col = (i - 1) % 4 + 1
            
            ax = Axis(
                fig[row, col], 
                title = var_names[i],
                titlesize = 20,
                xlabelsize = 19,
                ylabelsize = 19
                )
            
            i == j ? lines!(ax, Responses[i, j, :], color = :firebrick, linewidth = 2) : lines!(ax, Responses[i, j, :], color = :blue, linewidth = 2)
            hlines!(ax, [0], color = :black, linestyle = :dash) # Baseline
        end

        note = (length(var_names) - 1) ÷ 4 + 1

        Label(
            fig[note + 1, 1:4], 
            "*La respuesta dinámica en rojo representa la variable que recibe el choque",
            fontsize = 15, font = :bold, halign = :left, color = :firebrick
        )

        # Display or save the figure
        
        save(joinpath(save_path, "$j"*"_"*"$(var_names[j]).png"), fig, px_per_unit = 2.0)
    end
end

function DynamicMultipliersPlots(Responses_dict::Dict, shock_names::Vector, var_names::Vector; save_path::String)

    for j in 1:length(shock_names) # Create 17 separate figures, one per shock
        fig = Figure(size = (1200, 1400))
        
        # Title for the specific shock
        Label(fig[0, 1:4], "Respuestas al choque de $(var_names[j])", 
            fontsize = 32, font = :bold)

        for i in 1:length(var_names) # Subplots for each responding variable
            # Arrange in a 6x4 grid
            row = (i - 1) ÷ 4 + 1
            col = (i - 1) % 4 + 1
            
            ax = Axis(
                fig[row, col], 
                title = var_names[i],
                titlesize = 20,
                xlabelsize = 19,
                ylabelsize = 19
                )
            
            for d in keys(Responses_dict)
                Responses = Responses_dict[d]

                i == j ? lines!(ax, Responses[i, j, :], color = :firebrick, linewidth = 2, label = d) : lines!(ax, Responses[i, j, :], linewidth = 2, label = d)
                hlines!(ax, [0], color = :black, linestyle = :dash) # Baseline

            end

            if i == length(var_names)
                Legend(fig[row + 1, 1:4], ax, framevisible = false, orientation  = :horizontal, tellwidth = false)
            end

        end

        note = (length(var_names) - 1) ÷ 4 + 1

        Label(
            fig[note + 2, 1:4], 
            "*La respuesta dinámica en rojo representa la variable que recibe el choque",
            fontsize = 15, font = :bold, halign = :left, color = :firebrick
        )
        
        # Display or save the figure
        
        save(joinpath(save_path, "$j"*"_"*"$(var_names[j]).png"), fig, px_per_unit = 2.0)
    end
    
end