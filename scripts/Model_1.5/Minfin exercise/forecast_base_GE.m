%{
This script performs a forecast for the baseline scenario of the model and includes shocks to fiscal variables to reproduce
the projected path of the fiscal variables.

To compare the projected path of the fiscal variables with the model's baseline forecast run the scripts/MINFIN_exercise/Minfin exercise/GE_table.m script.
%}
%% Load the model in the matlab workspace
clc;
clear all;

irisstartup;

% add necesary functions to make the series of errors
addpath('src/helpers/forecast');

ModelPath = 'MINFIN_exercise';

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

% using the makeErrros function to get the errors by difference
F = makeErrors(F, MODEL);

%% Forecast with a shock in u9 period by period and a u5 one period shock
%{
    We will make forecast one step ahead. For each period, we force the
    residual u9 so that it equals:

    u9 = (1 - p.a9_1)*Forecast.DPI(end) + (1 - p.a7_1 - p.a9_2)*Forecast.DPE(end) ...
         + (p.a6_1 - p.a9_3)*Forecast.GFun(end) + (p.a4_1 - p.a9_3)*Forecast.IPub(end) ...
         - (p.a5_1 + p.a9_3)*Forecast.IngT(end); ...
         + u4 + u6 - u5 - u7;

    In order to mantain the accounting equation for total domestic debt.
%}

% Database copy. This data base will store the one step ahead forecast
Forecast = F;
u9_path = [];

u4_path = [];
u5_path = [];
u6_path = [];
u7_path = [];
u16_path = [];

% We define the start and end dates for forecast.
StartPred = qq(2026,3);
EndPred = StartPred+29;

for i = 1:length(StartPred:EndPred)
    
    if i == 1 % 2026Q3
        u4 = -0.04216;
        u5 = -0.08;
        u6 = 0.1726;
        u7 = -0.4827;
        u16 = -0.45;
        u18 = 7;

    elseif i == 2 % 2026Q4
        u4 = 0;
        u5 = -0.0414;
        u6 = 0.1082;
        u7 = -0.2683;
        u16 = -0.25;
        u18 = 3.305;

    elseif i == 3 % 2027Q1
        u4 = 0.15674;
        u5 = 0.1424;
        u6 = 0.65;
        u7 = -0.35;
        u16 = -0.15;
        u18 = 7;

    elseif i == 4 % 2027Q2
        u4 = 0.20;
        u5 = 0;
        u6 = 0.5992;
        u7 = -0.35;
        u16 = -0.15;
        u18 = 7;

    elseif i == 5 % 2027Q3
        u4 = 0.29721;
        u5 = 0;
        u6 = 0.50;
        u7 = -0.1315;
        u16 = -0.08;
        u18 = 2.9478;

    elseif i == 6 % 2027Q4
        u4 = 0;
        u5 = 0;
        u6 = 0.35;
        u7 = -0.0816;
        u16 = -0.10;
        u18 = 0;

    elseif i == 7 % 2028Q1
        u4 = 0;
        u5 = 0.10;
        u6 = -0.05;
        u7 = 0;
        u16 = 0;
        u18 = 0;

    elseif i == 8 % 2028Q2
        u4 = 0;
        u5 = 0.10;
        u6 = -0.10;
        u7 = 0;
        u16 = 0;
        u18 = 0;

    elseif i == 9 % 2028Q3
        u4 = 0;
        u5 = 0.25;
        u6 = -0.25;
        u7 = 0;
        u16 = 0;
        u18 = 0;

    elseif i == 10 % 2028Q4
        u4 = 0;
        u5 = 0.35;
        u6 = -0.25;
        u7 = 0;
        u16 = 0;
        u18 = 0;

    elseif i == 11 % 2029Q1
        u4 = 0;
        u5 = 0.10;
        u6 = -0.20;
        u7 = 0;
        u16 = 0;
        u18 = 0;

    elseif i == 12 % 2029Q2

        u4 = 0;
        u5 = 0.10;
        u6 = -0.22;
        u7 = 0;
        u16 = 0;
        u18 = 0;

    elseif i == 13 % 2029Q3

        u4 = 0;
        u5 = 0.15;
        u6 = -0.25;
        u7 = 0;
        u16 = 0;
        u18 = 0;

    elseif i == 14 % 2029Q4

        u4 = 0;
        u5 = 0.15;
        u6 = -0.30;
        u7 = 0;
        u16 = 0;
        u18 = 0;

    elseif i == 15 % 2030Q1

        u4 = 0;
        u5 = 0;
        u6 = 0;
        u7 = 0;
        u16 = 0;
        u18 = 0;

    elseif i == 16 % 2030Q2

        u4 = 0;
        u5 = 0;
        u6 = 0;
        u7 = 0;
        u16 = 0;
        u18 = 0;

    elseif i == 17 % 2030Q3

        u4 = 0;
        u5 = 0;
        u6 = 0;
        u7 = 0;
        u16 = 0;
        u18 = 0;

    elseif i == 18 % 2030Q4

        u4 = 0;
        u5 = 0;
        u6 = 0;
        u7 = 0;
        u16 = 0;
        u18 = 0;

    else
        u4 = 0;
        u5 = 0;
        u6 = 0;
        u7 = 0;
        u16 = 0;
        u18 = 0;
    end
    
    
    % u9 residuel from the data and forecast
    u9 = (1 - p.a9_1)*Forecast.DPI_ola(end) + (1 - p.a7_1 - p.a9_2)*Forecast.DPE_ola(end) ...
         + (p.a6_1 - p.a9_3)*Forecast.GFun_ola(end) + (p.a4_1 - p.a9_3)*Forecast.IPub_ola(end) ...
         - (p.a5_1 + p.a9_3)*Forecast.IngT_ola(end) ...
         + u4 + u6 - u5 - u7 + u18;
     
    % Quarters that will be exogenized
    SPred = Forecast.GDP_star_ola.Range(end) + 1;

    % zero data base of shocks
    shocks = zerodb(MODEL, Forecast.GDP_star_ola.Range(1):Forecast.GDP_star_ola.Range(end))*{'u9', 'u4', 'u5', 'u6', 'u7', 'u16'};

    % Combine the data base with intial conditions and shocks
    Forecast = dboverlay(Forecast,shocks);

    % Exogenize by SPred quarter
    Forecast.u9(SPred) = u9;
    Forecast.u4(SPred) = u4;
    Forecast.u5(SPred) = u5;
    Forecast.u6(SPred) = u6;
    Forecast.u7(SPred) = u7;
    Forecast.u16(SPred) = u16;
    
    % simulation plan
    planSim = plan(MODEL, SPred);
    % variable that will be endogenized
    planSim = endogenize(planSim,{'DPI_ola'}, SPred);
    planSim = endogenize(planSim,{'IPub_ola'}, SPred);
    planSim = endogenize(planSim,{'IngT_ola'}, SPred);
    planSim = endogenize(planSim,{'GFun_ola'}, SPred);
    planSim = endogenize(planSim,{'DPE_ola'}, SPred);
    planSim = endogenize(planSim,{'GDP_ola'}, SPred);

    % shock that will be exogenized
    planSim = exogenize(planSim,{'u9'}, SPred);
    planSim = exogenize(planSim,{'u4'}, SPred);
    planSim = exogenize(planSim,{'u5'}, SPred);
    planSim = exogenize(planSim,{'u6'}, SPred);
    planSim = exogenize(planSim,{'u7'}, SPred);
    planSim = exogenize(planSim,{'u16'}, SPred);

    % simulation One Step Ahead
    Forecast_OSAH = simulate(MODEL,...
                      Forecast,...
                      SPred,...
                      'plan', planSim,...
                      'anticipate',false,...
                      'DbOverlay=', true);
                  
    Forecast = Forecast_OSAH;
    
    u9_path(i) = u9;
    u4_path(i) = u4;
    u5_path(i) = u5;
    u6_path(i) = u6;
    u7_path(i) = u7;
    u16_path(i) = u16;

end

Forecast.u9(qq(2009, 1):StartPred) = F.u9;
Forecast.u9(StartPred:EndPred) = u9_path;
Forecast.u4(qq(2009, 1):StartPred) = F.u4;
Forecast.u4(StartPred:EndPred) = u4_path;
Forecast.u5(qq(2009, 1):StartPred) = F.u5;
Forecast.u5(StartPred:EndPred) = u5_path;
Forecast.u6(qq(2009, 1):StartPred) = F.u6;
Forecast.u6(StartPred:EndPred) = u6_path;
Forecast.u7(qq(2009, 1):StartPred) = F.u7;
Forecast.u7(StartPred:EndPred) = u7_path;
Forecast.u16(qq(2009, 1):StartPred) = F.u16;
Forecast.u16(StartPred:EndPred) = u16_path;

% Nominal GDP growth in decimal form. Since both operands are IRIS Series,
% the result is also an IRIS Series and retains the quarterly date range.
Forecast.GDP_nom_SM_yoy = ...
    (Forecast.GDP_SM_yoy + Forecast.pi_yoy)/100;

% Variables have to be including into the forecast csv
Vars = [get(MODEL, 'xlist'),  [{'u4'}, {'u5'}, {'u6'}, {'u7'}, {'u9'}, {'u16'}]];

% Export the data
databank.toCSV(Forecast*Vars, fullfile('Models', ModelPath, 'forecast', 'forecast_GE.csv'), Inf);

table(...
    Forecast.GDP_nom_SM_yoy([qq(2026, 4); qq(2027, 4)]).*100,...
    Forecast.GDP_SM_yoy([qq(2026, 4); qq(2027, 4)]),...
    'VariableNames', {'PIB nominal', 'PIB real'},...
    'RowNames', {'2026Q4', '2027Q4'}...
    )
%}