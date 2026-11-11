# Comparación de cuentas fiscales del MPM y MINFIN.
# Ejecutar desde cualquier directorio con:
# julia --project=/ruta/FiscalPolicyAnalysis /ruta/FiscalPolicyAnalysis/scripts/MINFIN_exercise/forecast/plots_MINFIN_saldos.jl
using CairoMakie
using CSV, DataFrames
using Printf

const ROOT = normpath(joinpath(@__DIR__, "..", "..", ".."))
const INPUT = joinpath(ROOT, "Models", "MINFIN_exercise", "forecast", "fiscal_accounts.csv")
const OUTPUT = joinpath(ROOT, "Models", "MINFIN_exercise", "plots", "forecast", "MIFIN_saldos")

# La segunda fila contiene descripciones; las observaciones empiezan en la tercera.
metadata = CSV.read(INPUT, DataFrame; limit = 1, types = String)
accounts = CSV.read(INPUT, DataFrame; skipto = 3)
period_col = names(accounts)[1]
periods = string.(accounts[!, period_col])
isempty(periods) && error("El archivo no contiene observaciones")

function quarter_index(period)
    m = match(r"^(\d{4})Q([1-4])$", period)
    isnothing(m) && error("Periodo trimestral inválido: $period")
    return 4 * parse(Int, m[1]) + parse(Int, m[2])
end

x = quarter_index.(periods)
issorted(x) && allunique(x) || error("Los periodos deben estar ordenados y no repetidos")
columns = names(accounts)[2:end]
variables = filter(name -> !endswith(name, "_MINFIN"), columns)
isempty(variables) && error("No se encontraron variables MPM")
for var in variables
    var * "_MINFIN" in columns || error("Falta la columna MINFIN para $var")
end
for name in filter(name -> endswith(name, "_MINFIN"), columns)
    chop(name; tail = length("_MINFIN")) in variables || error("Falta la columna MPM para $name")
end

function numeric_values(column, name)
    return map(column) do value
        ismissing(value) && return NaN
        value isa Real || error("Valor no numérico en $name: $value")
        isfinite(value) || error("Valor no finito en $name: $value")
        Float64(value)
    end
end

# Agrupar únicamente la parte entera, conservando el punto decimal.
function group_thousands(text)
    parts = split(text, "."; limit = 2)
    integer = replace(parts[1], r"(?<=\d)(?=(\d{3})+(?!\d))" => ",")
    return length(parts) == 1 ? integer : integer * "." * parts[2]
end

format_value(value) = isnan(value) ? "—" : group_thousands(@sprintf("%.2f", value))

# Formatear las marcas del eje sin notación científica y con separador de miles.
function format_y_ticks(ticks)
    differences = filter(>(0), abs.(diff(sort(collect(ticks)))))
    digits = isempty(differences) ? 0 : max(0, ceil(Int, -log10(minimum(differences))))
    fmt = Printf.Format("%." * string(digits) * "f")
    return [group_thousands(Printf.format(fmt, tick)) for tick in ticks]
end

mkpath(OUTPUT)
for (i, var) in enumerate(variables)
    minfin_var = var * "_MINFIN"
    mpm = numeric_values(accounts[!, var], var)
    minfin = numeric_values(accounts[!, minfin_var], minfin_var)
    # Eliminar únicamente el sufijo de la fuente de la descripción.
    title = strip(replace(string(metadata[1, var]), r"\s*\(MPM\)\s*$"i => ""))

    fig = Figure(size = (1100, 700))
    ax = Axis(fig[1, 1], title = title, titlesize = 25,
              subtitle = "Millones de quetzales\nComparativo entre pronósticos del modelo MPM y presupuesto multianual MINFIN",
              subtitlesize = 18,
              xticks = (x, periods), xticklabelsize = 17, yticklabelsize = 17,
              ytickformat = format_y_ticks,
              xgridvisible = false, ygridvisible = false)

    # NaN conserva los huecos sin unir observaciones separadas; scatter muestra
    # incluso series con una sola observación disponible (p. ej. DPI_MINFIN).
    for (label, values, color) in (("MPM", mpm, :blue), ("MINFIN", minfin, "#bd5e5e"))
        lines!(ax, x, values; label = label, color = color, linewidth = 2.5)
        scatter!(ax, x, values; color = color, markersize = 10)
    end
    Legend(fig[2, 1], ax; orientation = :horizontal, framevisible = false,
           labelsize = 18, padding = (10, 10, 10, 10))

    tbl = fig[3, 1] = GridLayout()
    headers = ["Fuente"; periods]
    for (j, text) in enumerate(headers)
        Box(tbl[1, j]; color = :gray90, strokecolor = :black, tellwidth = false)
        Label(tbl[1, j], text; font = :bold, padding = (8, 8, 8, 8),
              tellwidth = false, fontsize = 17)
    end
    for (irow, (label, values)) in enumerate((("MPM", mpm), ("MINFIN", minfin)))
        cells = [label; format_value.(values)]
        for (j, text) in enumerate(cells)
            Box(tbl[irow + 1, j]; color = :white, strokecolor = :black, tellwidth = false)
            Label(tbl[irow + 1, j], text; padding = (8, 8, 8, 8),
                  tellwidth = false, fontsize = 17)
        end
    end
    rowgap!(tbl, 2)
    colgap!(tbl, 2)
    output_file = joinpath(OUTPUT, "$(i)_$(var).png")
    save(output_file, fig; px_per_unit = 2)
    println("Guardada: $output_file")
end
