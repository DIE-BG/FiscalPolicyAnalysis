using DrWatson
@quickactivate "FiscalPolicyAnalysis"

##### Load the packages #####
using CSV, DataFrames, DataFramesMeta
using Statistics, Dates

include(srcdir("helpers", "processing_helpers.jl"))

##### Load BG data (data comes from the Banguat website) #####
# The data will be loaded as a dictionary, and then vectorized
data_dir = datadir("processing", "BG", "matrix_data")
data_dict = Dict(
    f => DataFrame(CSV.File(joinpath(data_dir, f))) for f in readdir(data_dir) if endswith(f, ".csv")
)

# We will vectorize the data, since it comes from the source in matrix form.
data_dict = vectorize_data(data_dict)

##### load exchange rate data #####
# Before 2006-12-2 there are no values for the reference exchance rate TCR. We define the TCR as a average
# between the buy and sell exchange rate. See the JM 126-2006 legal resolution.
# I define the exchange rate as the last value observed within the month.

# load 
e = CSV.read(datadir("processing", "BG", "e_daily.csv"), DataFrame)
e.date = Date.(e.date, "dd/mm/yyyy") # Transform the str dates into Dates format
# Create the month flag to identify the month in each row
e = @chain e begin
    @transform(:date = Date.(year.(:date), month.(:date)))
    @select(:date, :e)
end

e = combine(groupby(e, :date), last)
# e dataframe contains the data in monthly frequency and we use it to express the DPE and Rem in local currency. 

##### load core inflation, nominal and real GDP, ITotal and interest rate #####
# inflation
core_infl = CSV.read(datadir("processing", "BG", "core_inflation.csv"), DataFrame)
core_infl.date = Date.(core_infl.date, "dd/mm/yyyy")
# GDP
GDP = CSV.read(datadir("processing", "BG", "GDP.csv"), DataFrame) # Quarterly frequency
GDP.date = Date.(GDP.date, "dd/mm/yyyy")
# ITotal
ITotal = CSV.read(datadir("processing", "BG", "ITotal.csv"), DataFrame) # Quarterly frequency
ITotal.date = Date.(ITotal.date, "dd/mm/yyyy")
# i
i = CSV.read(datadir("processing", "BG", "i.csv"), DataFrame)
i.date = Date.(i.date, "dd/mm/yyyy")

##### Express DPE and Rem in local currency #####
# DPE
DPE_df = data_dict["DPE"]
DPE_df.value = e[(e.date .>= DPE_df.date[begin]) .& (e.date .<= DPE_df.date[end]), :e] .* DPE_df.value
DPE_df.value = round.(DPE_df.value; digits = 2)
data_dict["DPE"] = DPE_df

# Rem
Rem_df = data_dict["Rem"]
Rem_df.value = e[(e.date .>= Rem_df.date[begin]) .& (e.date .<= Rem_df.date[end]), :e] .* Rem_df.value
Rem_df.value = round.(Rem_df.value; digits = 2)
data_dict["Rem"] = Rem_df


##### Load data from FRED #####
# GDP, core inflation and federal fund effective rate comes from FRED as a quarterly data.
FRED = CSV.read(datadir("processing", "FRED", "data.csv"), DataFrame)
FRED.date = Date.(FRED.date, "dd/mm/yyyy")

##### Quarterly data #####
# Quarterly data comes from Banguat that was vectorized
data_dict_quarterly = Quarterly(data_dict; method = :mean)
# Quarterly core cpi data
data_dict_quarterly["core_cpi"] = Quarterly(core_infl; method = :mean)
# Quarterly the exchange rate
data_dict_quarterly["e"] = Quarterly(e; method = :mean)
# Quarterly i
data_dict_quarterly["i"] = Quarterly(i; method = :mean)
# add the nominal and real GDP
data_dict_quarterly["GDP_nom"] = DataFrame(date = GDP.date, value = GDP.y_nom)
data_dict_quarterly["GDP"] = DataFrame(date = GDP.date, value = GDP.y)
# add total invest
data_dict_quarterly["ITotal"] = DataFrame(date = ITotal.date, value = ITotal.ITotal)
# add FRED data
data_dict_quarterly["GDP_star"] = DataFrame(date = FRED.date, value = FRED.y_star)
data_dict_quarterly["i_star"] = DataFrame(date = FRED.date, value = FRED.i_star)
data_dict_quarterly["core_cpi_star"] = DataFrame(date = FRED.date, value = FRED.cpi_sub_star)

# Create a new data frame
data_df_quarterly = dict_to_dataframe(data_dict_quarterly)

#### Transform the data #####
# the dataframe doen't have AEN and IPriv variables
Data_df_quarterly_complete = @chain data_df_quarterly begin
    @transform(:AEN = :BM -:AIN)
    @transform(:IPriv = :ITotal -:Ipub)
    
end

# export the data
CSV.write(datadir("processing", "Quarterly_data.csv"), Data_df_quarterly_complete)