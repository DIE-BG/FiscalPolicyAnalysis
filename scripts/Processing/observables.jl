using DrWatson
@quickactivate "FiscalPolicyAnalysis"

# ===== Load the packages =====
using CSV, DataFrames
using Dates, Statistics

# ===== Load quarterly data =====
Quarterly_data = CSV.read(datadir("processing", "Quarterly_data.csv"), DataFrame)

required_columns = [
    :date, :GDP_star, :GDP, :GDP_nom, :core_cpi_star, :core_cpi, :e,
    :i_star, :i, :PREM, :IPub, :IngT, :GFun, :Rem, :IPriv,
    :DPE, :DPI, :AEN, :AIN,
]
missing_columns = setdiff(required_columns, Symbol.(names(Quarterly_data)))
isempty(missing_columns) || error("Missing columns in Quarterly_data.csv: $(missing_columns)")

# Convert quarterly dates to the format used by the output file.
quarter_by_month = Dict(3 => 1, 6 => 2, 9 => 3, 12 => 4)
quarterly_dates = Date.(string.(Quarterly_data.date), dateformat"yyyy-mm-dd")
all(date -> haskey(quarter_by_month, month(date)), quarterly_dates) ||
    error("Quarterly_data.csv must use quarter-end dates (March, June, September, or December).")

quarters = [quarter_by_month[month(date)] for date in quarterly_dates]
periods = string.(year.(quarterly_dates), "Q", quarters)
period_numbers = year.(quarterly_dates) .* 4 .+ quarters .- 1
all(period_numbers[index] == period_numbers[index - 1] + 1 for index in 2:length(period_numbers)) ||
    error("Quarterly_data.csv must contain consecutive quarters with no duplicates.")

# Names and order of the exported observable variables.
observable_names = [
    "GDP_star_SM_yoy", "i_star", "pi_star_yoy",
    "IPub_ratio", "IngT_ratio", "Gfun_ratio", "DPE_ratio", "Rem_ratio",
    "DPI_ratio", "AEN_ratio", "AIN_ratio", "i", "e_yoy", "PREM",
    "pi_yoy", "GDP_SM_yoy", "IPriv_ratio",
]

function numeric_series(data::DataFrame, column::Symbol)
    return Union{Missing, Float64}[
        ismissing(value) ? missing : Float64(value)
        for value in data[!, column]
    ]
end

function rolling(values; window::Int = 4, operation::Symbol = :sum)
    result = Vector{Union{Missing, Float64}}(undef, length(values))
    fill!(result, missing)

    for index in window:length(values)
        current_window = values[index - window + 1:index]
        if all(value -> !ismissing(value) && isfinite(value), current_window)
            if operation == :sum
                result[index] = sum(Float64.(current_window))
            elseif operation == :mean
                result[index] = mean(Float64.(current_window))
            else
                error("Unknown rolling operation: $(operation)")
            end
        end
    end
    return result
end

function year_over_year(values; lag::Int = 4)
    result = Vector{Union{Missing, Float64}}(undef, length(values))
    fill!(result, missing)

    for index in lag + 1:length(values)
        current = values[index]
        previous = values[index - lag]
        if !ismissing(current) && !ismissing(previous) && previous != 0 &&
           isfinite(current) && isfinite(previous)
            result[index] = 100 * (Float64(current) / Float64(previous) - 1)
        end
    end
    return result
end

function ratio_percent(numerator, denominator)
    result = Vector{Union{Missing, Float64}}(undef, length(numerator))
    fill!(result, missing)

    for index in eachindex(numerator, denominator)
        num = numerator[index]
        den = denominator[index]
        if !ismissing(num) && !ismissing(den) && den != 0 &&
           isfinite(num) && isfinite(den)
            result[index] = 100 * Float64(num) / Float64(den)
        end
    end
    return result
end

# ===== Economic growth rates =====
# Growth is calculated from four-quarter moving sums of real GDP.
observables = Dict{String, Vector{Union{Missing, Float64}}}()
observables["GDP_star_SM_yoy"] = year_over_year(rolling(numeric_series(Quarterly_data, :GDP_star)))
observables["GDP_SM_yoy"] = year_over_year(rolling(numeric_series(Quarterly_data, :GDP)))

# ===== Interest rates and country-risk premium =====
# These quarterly rates are used directly without a GDP ratio or growth transform.
observables["i_star"] = numeric_series(Quarterly_data, :i_star)
observables["i"] = numeric_series(Quarterly_data, :i)
observables["PREM"] = numeric_series(Quarterly_data, :PREM)

# ===== Inflation and nominal exchange-rate depreciation =====
# Year-over-year percent changes are calculated from the quarterly price indices and exchange rate.
observables["pi_star_yoy"] = year_over_year(numeric_series(Quarterly_data, :core_cpi_star))
observables["pi_yoy"] = year_over_year(numeric_series(Quarterly_data, :core_cpi))
observables["e_yoy"] = year_over_year(numeric_series(Quarterly_data, :e))

# ===== Flow ratios to nominal GDP =====
# Four-quarter flow sums are divided by the four-quarter sum of nominal GDP.
GDP_nominal_4q = rolling(numeric_series(Quarterly_data, :GDP_nom))
flow_variables = [
    ("IPub_ratio", :IPub),
    ("IngT_ratio", :IngT),
    ("Gfun_ratio", :GFun),
    ("Rem_ratio", :Rem),
    ("IPriv_ratio", :IPriv),
]

for (observable, source) in flow_variables
    observables[observable] = ratio_percent(
        rolling(numeric_series(Quarterly_data, source)),
        GDP_nominal_4q,
    )
end

# ===== Stock ratios to nominal GDP =====
# Four-quarter stock averages are divided by the same four-quarter nominal-GDP sum.
stock_variables = [
    ("DPE_ratio", :DPE),
    ("DPI_ratio", :DPI),
    ("AEN_ratio", :AEN),
    ("AIN_ratio", :AIN),
]

for (observable, source) in stock_variables
    observables[observable] = ratio_percent(
        rolling(numeric_series(Quarterly_data, source); operation = :mean),
        GDP_nominal_4q,
    )
end

# ===== Export observables =====
valid_indices = [
    index for index in eachindex(periods)
    if all(!ismissing(observables[name][index]) for name in observable_names)
]
isempty(valid_indices) && error("No periods have all observable variables available.")

output_data = DataFrame()
output_data[!, Symbol("Variables ->")] = periods[valid_indices]
for name in observable_names
    output_data[!, Symbol(name)] = Float64[observables[name][index] for index in valid_indices]
end

output_path = datadir("initial_conditions.csv")
mkpath(dirname(output_path))
CSV.write(output_path, output_data)
println("File created: $(output_path)")
println("Periods: $(first(periods[valid_indices]))–$(last(periods[valid_indices])); observables: $(length(observable_names)).")


