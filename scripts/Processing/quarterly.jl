using DrWatson
@quickactivate "FiscalPolicyAnalysis"

##### Load the packages #####
using CSV, DataFrames, DataFramesMeta
using Statistics, Dates

include(srcdir("helpers", "Processing", "processing_helpers.jl"))

##### Load Monthly data #####
Monthly_data = CSV.read(datadir("processing", "Monthly_data.csv"), DataFrame)

#### Load Quarterly data ####
Quarterly_BG = CSV.read(datadir("processing", "BG", "Quarterly_BG.csv"), DataFrame)
Quarterly_BG.date = Date.(Quarterly_BG.date, "dd/mm/yyyy")

##### Load data from FRED #####
# GDP, core inflation and federal fund effective rate comes from FRED as a quarterly data.
FRED = CSV.read(datadir("processing", "FRED", "Qdata.csv"), DataFrame)
FRED.date = Date.(FRED.date, "dd/mm/yyyy")

##### Quarterly data #####
# Quarterly data comes from Banguat that was vectorized
# Quarterly Flow variables
data_dict_quarterly = Dict()
# Quarterly public investment
data_dict_quarterly["IPub"] = Quarterly(Monthly_data[:, [:date, :IPub]]; method = :sum)
# Quarterly total revenues
data_dict_quarterly["IngT"] = Quarterly(Monthly_data[:, [:date, :IngT]]; method = :sum)
# Quarterly fobernment operating expenses
data_dict_quarterly["GFun"] = Quarterly(Monthly_data[:, [:date, :GFun]]; method = :sum)
# Quarterly Remittances
data_dict_quarterly["Rem"] = Quarterly(Monthly_data[:, [:date, :Rem]]; method = :sum)
# Quarterly Deficit
data_dict_quarterly["Def"] = Quarterly(Monthly_data[:, [:date, :Def]]; method = :sum)

# Quarterly Stock variables
# Quarterly Domestic Public Debt
data_dict_quarterly["DPI"] = Quarterly(Monthly_data[:, [:date, :DPI]]; method = :mean)
# Quarterly Foreing Public Debt
data_dict_quarterly["DPE"] = Quarterly(Monthly_data[:, [:date, :DPE]]; method = :mean)
# Quarterly Domestic net assets
data_dict_quarterly["AIN"] = Quarterly(Monthly_data[:, [:date, :AIN]]; method = :mean)
# Quarterly Monetary Base
data_dict_quarterly["BM"] = Quarterly(Monthly_data[:, [:date, :BM]]; method = :mean)
# Quarterly core cpi data
data_dict_quarterly["core_cpi"] = Quarterly(Monthly_data[:, [:date, :core_cpi]]; method = :mean)
# Quarterly the exchange rate
data_dict_quarterly["e"] = Quarterly(Monthly_data[:, [:date, :e]]; method = :mean)
# Quarterly i
data_dict_quarterly["i"] = Quarterly(Monthly_data[:, [:date, :i]]; method = :mean)
# Quarterly PREM
data_dict_quarterly["PREM"] = Quarterly(Monthly_data[:, [:date, :PREM]]; method = :mean)

# Data already are quarterly frequency
# add the nominal and real GDP
data_dict_quarterly["GDP_nom"] = DataFrame(date = Quarterly_BG.date, value = Quarterly_BG.y_nom)
data_dict_quarterly["GDP"] = DataFrame(date = Quarterly_BG.date, value = Quarterly_BG.y)
# add total invest
data_dict_quarterly["ITotal"] = DataFrame(date = Quarterly_BG.date, value = Quarterly_BG.ITotal)
# add FRED data
data_dict_quarterly["GDP_star"] = DataFrame(date = FRED.date, value = FRED.y_star)
data_dict_quarterly["i_star"] = DataFrame(date = FRED.date, value = FRED.i_star)
data_dict_quarterly["core_cpi_star"] = DataFrame(date = FRED.date, value = FRED.cpi_sub_star)

# Create a new data frame
data_df_quarterly = dict_to_dataframe(data_dict_quarterly)

#### Transform the data #####
# the dataframe doen't have AEN and IPriv variables
Data_df_quarterly_complete = @chain data_df_quarterly begin
    @transform(:AEN = :BM -:AIN) # External public debt
    @transform(:DPEC = :DPE - :AEN) # Consolidating external public debt
    @transform(:DPIC = :DPI - :AIN) # Consolidating internal public debt
    @transform(:DPTC = :DPEC + :DPIC) # Total consolidationg public debt 
    @transform(:DPT = :DPE + :DPI) # Total public debt
    @transform(:IPriv = :ITotal - :IPub) # Total investment
    
end

# export the data
CSV.write(datadir("processing", "Quarterly_data.csv"), Data_df_quarterly_complete)