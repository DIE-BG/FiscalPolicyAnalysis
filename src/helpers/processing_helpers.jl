using Dates
using DataFrames
"""
    This function takes a DataFrame and vectorizes the data. It is applied to data that have the following structure:

        | month | year |

    Given the datha are by column, the data need to be vectorized by row. The function returns a data framen. The first column
    is the date, which is created by combining the month and year columns. The second column is the value.

    vectorize_data(data::DataFrame)
"""
function vectorize_data(data::DataFrame)
    # get the year en the second and last column
    start_year = names(data)[2]

    # Create a vector of the values
    values = vec(Matrix(data[:, 2:end]))
    values = collect(skipmissing(values))

    # Create the dataframe
    df = 
        DataFrame(
            date = Date(start_year):Month(1):(Date(start_year)+Month(length(values)-1)),
            value = values
        )
    return df
end

function vectorize_data(data::Dict)
    # Create a new dictionary to store the vectorized data
    vectorized_data = Dict()

    # Loop through the data and vectorize each dataframe
    for (key, df) in data
        key = match(r"^(.*?)\.csv", key)[1]
        vectorized_data[key] = vectorize_data(df)
    end

    return vectorized_data
end

"""
    This function quarterly the data. The data must be monthly frequency and the average within the quarter was method of aggregation selected.

        Quarterly(df::DataFrame; method::Symbol = :mean)

        - df is a dataframe
"""

using DataFrames
using Dates
using Statistics

function Quarterly(df::DataFrame; method::Symbol = :mean)
    date_col = names(df)[1]
    value_col = names(df)[2]

    @assert ncol(df) == 2 "The DataFrame must have exactly two columns."
    @assert eltype(df[!, date_col]) <: Date "First column must contain Date values."
    @assert method in (:mean, :last) "method must be :mean or :last"

    df_sorted = sort(copy(df), date_col)

    df_sorted.year_ = year.(df_sorted[!, date_col])
    df_sorted.quarter_ = quarterofyear.(df_sorted[!, date_col])
    df_sorted.month_ = month.(df_sorted[!, date_col])

    gdf = groupby(df_sorted, [:year_, :quarter_])

    result = combine(gdf) do sdf
        # Keep only complete quarters: exactly 3 distinct months
        complete_quarter = length(unique(sdf.month_)) == 3

        if !complete_quarter
            return DataFrame()
        end

        val = method == :mean ? mean(skipmissing(sdf[!, value_col])) : sdf[end, value_col]

        DataFrame(
            date_col => [sdf[end, date_col]],
            value_col => [val]
        )
    end

    select!(result, date_col, value_col)

    return result
end

function Quarterly(data::Dict; method::Symbol = :mean)
    # Create a new dictionary to store the vectorized data
    quarterly_data = Dict()

    # Loop through the data and vectorize each dataframe
    for (key, df) in data
        quarterly_data[key] = Quarterly(df; method)
    end

    return quarterly_data
end

function dict_to_dataframe(data_dict::Dict)
    @assert !isempty(data_dict) "The dictionary is empty."

    keys_vec = collect(keys(data_dict))

    # Basic checks using the first dataframe
    first_df = data_dict[keys_vec[1]]
    @assert ncol(first_df) == 2 "Each DataFrame must have exactly two columns."

    date_col = names(first_df)[1]

    @assert eltype(first_df[!, date_col]) <: Date "The first column must contain Date values."

    # Compute intersection of dates across all dataframes
    common_dates = Set(first_df[!, date_col])

    for k in keys_vec[2:end]
        df = data_dict[k]
        @assert ncol(df) == 2 "Each DataFrame must have exactly two columns."
        @assert names(df)[1] == date_col "All DataFrames must have the same date column position/name."
        @assert eltype(df[!, date_col]) <: Date "The first column must contain Date values. $k"

        common_dates = intersect(common_dates, Set(df[!, date_col]))
    end

    common_dates = sort(collect(common_dates))

    # Initialize output dataframe
    result = DataFrame(date_col => common_dates)

    # Add one column per dataframe
    for k in keys_vec
        df = sort(copy(data_dict[k]), date_col)
        value_col = names(df)[2]

        filtered_df = df[in.(df[!, date_col], Ref(common_dates)), [date_col, value_col]]

        rename!(filtered_df, value_col => Symbol(k))

        result = leftjoin(result, filtered_df, on=date_col)
    end

    return sort(result, date_col)
end