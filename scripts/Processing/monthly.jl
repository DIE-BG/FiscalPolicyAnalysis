using DrWatson
@quickactivate "FiscalPolicyAnalysis"

##### Load the packages #####
using CSV, DataFrames, DataFramesMeta
using Statistics, Dates

include(srcdir("helpers", "processing_helpers.jl"))

##### Load FRED data #####
dataFRED = CSV.read(datadir("processing", "FRED", "Mdata.csv"), DataFrame)
dataFRED.date = Date.(dataFRED.date, "dd/mm/yyyy")

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

##### Create a new data frame
data_dict["e"] = DataFrame(date = e.date, value = e.e)
data_dict["core_cpi"] = DataFrame(date = core_infl.date, value = core_infl.core_inflation)
data_dict["i"] = DataFrame(date = i.date, value = i.i)
data_dict["core_cpi_star"] = dataFRED

data_df_monthly = dict_to_dataframe(data_dict)

#### Transform the data #####
# the dataframe doen't have AEN and IPriv variables
Data_df_monthly_complete = @chain data_df_monthly begin
    @transform(:AEN = :BM -:AIN)
end

# export the data
CSV.write(datadir("processing", "Monthly_data.csv"), Data_df_monthly_complete)