%% Load the model in the matlab workspace
clc;
clear all;

ModelPath = 'Model_1.3';

% Check if forecas folder exists
if ~isfolder(fullfile('Models', ModelPath, 'forecast'))
    mkdir(fullfile('Models', ModelPath, 'forecast'));
    disp('The forecast folder was created')
else
    disp('The forecast folder exists')
end
    
% Load the parameters
run(fullfile('scripts', ModelPath, 'forecast', 'setparam.m'));
% Creación del objeto "model", en el workspace, asignación de parámetros y solución.
MODEL = model(fullfile('scripts', ModelPath, 'forecast', 'model.mod'), 'assign', p);
MODEL = sstate(MODEL,'growth=',true,'MaxFunEvals',1000,'display=','off');
[flag,discrep,eqtn] = chksstate(MODEL);

if flag
    disp(" ")
else
    warning("El estado estacionario calculado discrepa del impuesto.")
end

MODEL = solve(MODEL,'error=',true);

%% Load the historical data
d = databank.fromCSV(fullfile('Models', ModelPath, 'data', 'initial_conditions.csv'));

%% Kalman filter

% Assing the data to measurement equations
Ylist = get(MODEL,'ylist');                                         
Ylist_obs = cellfun(@(x) regexp(x, '(?<=m_)(\S*)$', 'tokens', 'once'), ...
    Ylist);

for i = 1:length(Ylist)
    DataFilter.(Ylist{i}) = d.(Ylist_obs{i});
end

[~,F] = filter(MODEL, DataFilter, DataFilter.m_GDP_star_SM_yoy.Range);

F = F.mean * get(MODEL, 'xlist');

%% Forecast
%{
    We going to test if there is exist a equivalence between the
    innovations come from the kalman filter and the difference between the
    estimation one step ahead and the observed value.
%}

startForecast = qq(2009, 4);
numPeriods = 65;

namesToSave = get(MODEL, 'xlist');  % List of variables we will get the one stpet ahead forecast

Forecast_1step = struct();

for k = 1:numPeriods

    t = startForecast + k - 1;

    disp(t)

    Hist = databank.clip(F, t-4, t-1);

    Forecast_OSAH = simulate(MODEL, ...
        Hist, ...
        t:t, ...
        'anticipate', false);

    for j = 1:numel(namesToSave)

        name = namesToSave{j};

        if k == 1
            Forecast_1step.(name) = Forecast_OSAH.(name){t};
        else
            Forecast_1step.(name)(t) = Forecast_OSAH.(name)(t);
        end

    end

end

%% Get the error for the variables of the model

errors = struct();

errors.u1 = F.GDP_star_ola - Forecast_1step.GDP_star_ola;
errors.u2 = F.i_star_ola - Forecast_1step.i_star_ola;
errors.u3 = F.pi_star_ola - Forecast_1step.pi_star_ola;
errors.u4 = F.IPub_ola - Forecast_1step.IPub_ola;
errors.u5 = F.IngT_ola - Forecast_1step.IngT_ola;
errors.u6 = F.GFun_ola - Forecast_1step.GFun_ola;
errors.u7 = F.DPE_ola - Forecast_1step.DPE_ola;
errors.u8 = F.Rem_ola - Forecast_1step.Rem_ola;
errors.u9 = F.DPI_ola - Forecast_1step.DPI_ola;
errors.u10 = F.AEN_ola - Forecast_1step.AEN_ola;
errors.u11 = F.AIN_ola - Forecast_1step.AIN_ola;
errors.u12 = F.i_ola - Forecast_1step.i_ola;
errors.u13 = F.e_ola - Forecast_1step.e_ola;
errors.u14 = F.PREM_ola - Forecast_1step.PREM_ola;
errors.u15 = F.pi_ola - Forecast_1step.pi_ola;
errors.u16 = F.GDP_ola - Forecast_1step.GDP_ola;
errors.u17 = F.IPriv_ola - Forecast_1step.IPriv_ola;

%% Incorporating errors into the F-structure

errorsNames = get(MODEL, 'elist');

for i = 1:length(errorsNames)
    
   errorName = errorsNames{i};
   
   F.(errorName) = errors.(errorName);
end

