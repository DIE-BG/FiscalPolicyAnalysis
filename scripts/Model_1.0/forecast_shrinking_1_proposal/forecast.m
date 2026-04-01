%% Load the model in the matlab workspace
clear all;
% Load the parameters
run(fullfile('scripts', 'Model_1.0', 'forecast_shrinking_1', 'setparam.m'));
% Creación del objeto "model", en el workspace, asignación de parámetros y solución.
MODEL = model(fullfile('scripts', 'Model_1.0', 'forecast_shrinking_1', 'model.mod'), 'assign', p);
MODEL = sstate(MODEL,'growth=',true,'MaxFunEvals',1000,'display=','off');
[flag,discrep,eqtn] = chksstate(MODEL);

if flag
    disp(" ")
else
    warning("El estado estacionario calculado discrepa del impuesto.")
end

MODEL = solve(MODEL,'error=',true);

get(MODEL, 'sstateLevel')

%% Load the historical data
d = databank.fromCSV(fullfile('data', 'model_1.0', 'initial_conditions.csv'));

%% Forecast
% We define the start and end dates for forecast.
startpred = qq(2025,4);
endpred = qq(2056,4);

% Simulación, utilizando el model (g) y la base de datos (d) 
Forecast = simulate(MODEL,d, startpred:endpred, 'Deviation=', false, 'anticipate=',false);
Forecast = dbextend(d,Forecast);

databank.toCSV(Forecast, fullfile('Models', 'Model_1.0', 'forecast', 'forecast_shrinking_proposal_1', 'forecast.csv'), Inf);
