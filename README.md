# FiscalPolicyAnalysis
Repository for the development of the model for analyzing fiscal and monetary policy interactions.

# Directory structure
To maintain order in the development of the model, the following directory structure is proposed. It is inspired by the structure used in the SVAR model selection tool.

```text
FiscalPolicyAnalysis/             # Project's main folder.
├─ data/                          # Data's main folder
│  ├─ model_1/                    # Model 1 data
│  └─ estimation/                 # Data for estimating the model_1
│  └─ forecast/                   # Initial conditions for generating the forecast
│
├─ lyx/                           # Lyx files
│
├─ manuscripts/                   # files containing the model structure and its modifications
│
├─ results/                       # Results for each version of the model
│  └─ model_1/                    # Model_1 results
│      └─ plots/                  # Forecast plots
│      └─ csv_files/              # csv of xlsx files of the model_1 forecast
│
├─ scripts/                       # Estimation and forecast scripts
│  ├─ model_1/                    # Model_1 scripts
│  └─ estimation/                 # Script for estimating the model_1 (OLS, Bayesian estimation, etc.)
│  └─ forecast/                   # script to generate model_1 forecasts
│
├─ src/                           # Source code. Contains functions, structures and modules that are used throughout the project
├─ helpers/                       # Auxiliary functions or scripts
│
├─ README.md                      # This file
├─ .gitignore                     # Ignore unnecessary files to replicate the results.
└─ Changelog.md                   # File documenting the different versions of the model. Each modification must be documented.
