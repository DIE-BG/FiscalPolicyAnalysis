"""
    SM(d::Vector{Date}, x::Vector)

    Build the moving sum for a quarterly variable. This function requiers a dates vector "d" and a vector of values called "x".
    The movinving sum is defined as the sum of the four steps backward.

    - d vector of dates
    - x vector
"""
function SM(d::Vector{Date}, x::Vector, T::Int = 4)

    out = similar(x, length(x)-T+1)
    out[1] = sum(x[begin:T])
    for i in 2:length(out)
        out[i] = out[i-1] - x[i-1] + x[i+T-1]
    end

    out_df = DataFrame(date = d[T:end], value = out)
    return out_df

end

"""
    Mavg(d::Vector{Date}, x::Vector)
    
    Provde the simple moving average for a variable.
"""
function SimpleMavg(d::Vector{Date}, x::Vector, T::Int)

    out = Vector{Float64}(undef, length(x) - T + 1)

    # primer promedio
    s = sum(x[1:T])
    out[1] = s / T

    # actualizar suma de forma recursiva
    for i in 2:length(out)
        s = s - x[i-1] + x[i + T - 1]
        out[i] = s / T
    end

    out_df = DataFrame(date = d[T:end], value = out)
    return out_df

end

"""
    yoy(d::Vector{Date}, x::Vector; freq = "monthly")

    Gives the year on year percent change of a given variable. This function requiers a Date Vector "d", a Float numbers Vector "x" and the frequency
    of the data. For instance, if the variable is provided with a montly frequency, the function returns the percentage corresponding to 12 steps backward. 
    However, the data is quarterly, the percentage change will be four steps backward.
"""
function yoy(d::Vector{Date}, x::Vector; freq = "quarterly")
    
    if freq == "monthly"
        out = similar(x, length(x)-12)
        out = (((x[13:end]./x[begin:end-12])).-1).*100
        
        out_df = DataFrame(date = d[13:end], value = out)

    elseif freq == "quarterly"
        out = similar(x, length(x)-4)
        out = (((x[5:end]./x[begin:end-4])).-1).*100
        
        out_df = DataFrame(date = d[5:end], value = out)

    end

    return out_df
end

"""
    moving_ola(x::AbstractVector, T::Int)

    Create a series of movign average with window T periods. The series is the same as shown in the papaer. This means it is shifted one step forward.
"""

function moving_ola(x::Vector, T::Int)
    n = length(x)
    T >= 1 || throw(ArgumentError("T must be equal or more than 1"))

    ma = Vector{Union{Missing, Float64}}(missing, n)

    for t in T+1:n
        ma[t] = mean(x[t-T:t-1])
    end

    return ma
end

"""

    ola(d::Vector{Date}, x::Vector)

    The "ola" variable is the differece between its value at perior t and a moving average of the previous T periods.

"""
function ola_var(d::Vector{Date}, x::Vector, T::Int = 4)
    ma = moving_ola(x, T)

    ola = x[T+1:end] .- ma[T+1:end]
        
    ola_df = DataFrame(date = d[T+1:end], value = ola)

    return ola_df
    
end

"""
    OlaRationsFlowDict(qdf::DataFrame, variables::Vector{String}; T::Int = 4)

    - qdf is a data frame that contains quarterly data
    - variables is a vector containing the name of the variables as they appears in the qdf data frame
    - T is the length that will be applied to both the moving sum and average of the variable and nominal GDP, respectively.

    Converts the flow variables in their "ola" version. These variables are transformed using moving average calculated over the past T
    periods. Morover, each moving average of the flow variable must be divided by the moving sum of the nominal GDP calculated using 
    the same length T as that used for the flow variables.

    returns a dictionary containintg many data frames. These data frames must have two columns. The first column contains dates, and the 
    second has the "ola" version of the variable.
"""
function OlaRatiosFlowDict(qdf::DataFrame, variables::Vector{String}; T::Int = 4)
    Dict_ola = Dict()
    for i in 1:length(variables)
        var = variables[i]

            # Variable's moving sum
            var_SM = SM(qdf.date, qdf[:, var], T)

            # GDP's moving sum
            GDP_SM = SM(qdf.date, qdf.GDP_nom, T)

            # Ola variable
            var_ola = ola_var(var_SM.date, (var_SM.value./GDP_SM.value).*100,  T)

            Dict_ola[var] = var_ola
    end

    return Dict_ola

end

"""
    OlaRatiosStockDict(qdf::DataFrame, variables::Vector{String}; T::Int = 4)

    - qdf is a data frame that contains quarterly data
    - variables is a vector with the name of the variables as they appear in the qdf data frame
    - T is the length that will be applied to the moving sum of both variable and nominal GDP

    Transform the Stock varialbes into the their "ola" version. Stock variables are transformed by the moving averages T steps back.
    Additionally, the moving sum of the stock variables should be divided by the moving sum of the nominal GDP over the same length 
    of T used for the stock variables.

    returns a dictionary containig many dataframes. Each data frame have two coloms, the first contains the dates, and the second 
    has the "ola" version of the variable.
"""
function OlaRatiosStockDict(qdf::DataFrame, variables::Vector{String}; T::Int = 4)
    Dict_ola = Dict()
    for i in 1:length(variables)
        var = variables[i]

            # Variable's moving average
            var_Stock = SimpleMavg(qdf.date, qdf[:, var], T)

            # GDP's moving sum
            GDP_SM = SM(qdf.date, qdf.GDP_nom, T)

            # Ola variable
            var_ola = ola_var(var_Stock.date, (var_Stock.value./GDP_SM.value).*100, T)

            Dict_ola[var] = var_ola
    end

    return Dict_ola

end

"""
   OlaGrowthDict(qdf::DataFrame, variables::Vector{String}; T::Int = 4)

    - qdf is a data frame that contains quarterly data
    - variables is a vector with the name of the variables as they appear in the qdf data frame
    - T is the time period that will be applied to the moving sum of the variable

    Some variables such as foreing and domestic GDP need to be expressed as a moving sum of T periods. This is generally done
    because GDP represents the growth economic trhoughout a year and, it is usual to use T = 4 for quarterly frequency.

    It is important to highlight that we calculate the “wave” variable using the year on year percentage change of the 
    moving sum of GDP

    returns a dicth containing many data frames. These data frames must be contain two columns, the first column containing dates,
    and the second has the "ola" version of the variable.

"""
function OlaGrowthDict(qdf::DataFrame, variables::Vector{String}; T::Int = 4)
    Dict_ola = Dict()
    for i in 1:length(variables)
        var = variables[i]

            # Variable's moving average
            VarSM = SM(qdf.date, qdf[:, var], T)

            # Percentage change rate
            VarSMVariation = yoy(VarSM.date, VarSM.value; freq = "quarterly")

            # Ola variable
            var_ola = ola_var(VarSMVariation.date, VarSMVariation.value, T)

            Dict_ola[var] = var_ola
    end

    return Dict_ola
end

"""
    OlaPercentageRateDict(qdf::DataFrame, variables::Vector{String}; T::Int = 4)

    - qdf is a data frame that contains quarterly data
    - variables is a vector with the name of the variables as they appear in the qdf data frame
    - T is the time period that will be applied to the moving sum of the variable

    Transforms the varialbes and creates the "ola" version of them. Variales such as exchange rate and CPIs don't need to be
    transformed, unlike GDP, which does. Therefore, we only obtain the year on yaer percentage range and then create their
    "ola" versions.

    returns a dicth containing many data frames. These data frames must be contain two columns, the first column containing dates,
    and the second has the "ola" version of the variable.
"""

function OlaPercentageRateDict(qdf::DataFrame, variables::Vector{String}; T::Int = 4)
    Dict_ola = Dict()
    for i in 1:length(variables)
        var = variables[i]

            # Percentage change rate
            VarVariation = yoy(qdf.date, qdf[:, var]; freq = "quarterly")

            # Ola variable
            var_ola = ola_var(VarVariation.date, VarVariation.value, T)

            Dict_ola[var] = var_ola
    end

    return Dict_ola
end

"""
    OlaSimpleVariablesDict(qdf::DataFrame, variables::Vector{String}; T::Int = 4)

    - qdf is a data frame that contains quarterly data
    - variables is a vector with the name of the variables as they appear in the qdf data frame
    - T is the time period that will be applied to the moving sum of the variable

    Creates the "ola" version for variables expressed as an annual interest rate. Theses varialbes don't need any
    transformation. Therefore, their "ola" version is calculated from their quarterly aggregation.

    returns a dicth containing many data frames. These data frames must be contain two columns, the first column containing dates,
    and the second has the "ola" version of the variable.
"""

function OlaSimpleVariablesDict(qdf::DataFrame, variables::Vector{String}; T::Int = 4)
    Dict_ola = Dict()
    for i in 1:length(variables)
        var = variables[i]

            # Ola variable
            var_ola = ola_var(qdf.date, qdf[:, var], T)

            Dict_ola[var] = var_ola
    end

    return Dict_ola
end