%% Load the model in the matlab workspace
clc;
clear all;

ModelPath = 'Model_1.2';

% add necesary functions to make the series of errors
addpath('src/helpers/forecast');

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

u5_path = [];
U16_path = [];

% We define the start and end dates for forecast.
StartPred = qq(2026,1);
EndPred = StartPred+123;

for i = 1:length(StartPred:EndPred)
    
    if i == 1
       u5 = 0.35083;
    else
        
       u5 = 0;       
    end
    
    if i == 1
        u16 = -0.91;
    elseif i == 2
        u16 = -0.6;
    elseif i == 3
        u16 = -0.58;    
    elseif i == 4
        u16 = -0.58;
    elseif i == 5
        u16 = -0.05;
    else
        u16 = 0;
    end
    
    % u9 residuel from the data and forecast
    u9 = (1 - p.a9_1)*Forecast.DPI_ola(end) + (1 - p.a7_1 - p.a9_2)*Forecast.DPE_ola(end) ...
         + (p.a6_1 - p.a9_3)*Forecast.GFun_ola(end) + (p.a4_1 - p.a9_3)*Forecast.IPub_ola(end) ...
         - (p.a5_1 + p.a9_3)*Forecast.IngT_ola(end) ...
         - u5;

    % Quarters that will be exogenized
    SPred = Forecast.GDP_star_ola.Range(end) + 1;

    % zero data base of shocks
    shocks = zerodb(MODEL, Forecast.GDP_star_ola.Range(1):Forecast.GDP_star_ola.Range(end))*{'u9', 'u5', 'u16'};

    % Combine the data base with intial conditions and shocks
    Forecast = dboverlay(Forecast,shocks);

    % Exogenize by SPred quarter
    Forecast.u9(SPred) = u9;
    Forecast.u5(SPred) = u5;
    Forecast.u16(SPred) = u16;
    
    % simulation plan
    planSim = plan(MODEL, SPred);
    % variable that will be endogenized
    planSim = endogenize(planSim,{'DPI_ola'}, SPred); 
    planSim = endogenize(planSim,{'IngT_ola'}, SPred);
    planSim = endogenize(planSim,{'GDP_ola'}, SPred);

    % shock that will be exogenized
    planSim = exogenize(planSim,{'u9'}, SPred);
    planSim = exogenize(planSim,{'u5'}, SPred);
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
    u5_path(i) = u5;
    u16_path(i) = u16;

end

Forecast.u9(qq(2009, 1):StartPred) = F.u9;
Forecast.u9(StartPred:EndPred) = u9_path;
Forecast.u5(qq(2009, 1):StartPred) = F.u5;
Forecast.u5(StartPred:EndPred) = u5_path;
Forecast.u16(qq(2009, 1):StartPred) = F.u16;
Forecast.u16(StartPred:EndPred) = u16_path;

% Variables have to be including into the forecast csv
Vars = [get(MODEL, 'xlist'),  [{'u4'}, {'u5'}, {'u7'}, {'u9'}, {'u16'}]];

% Export the data
databank.toCSV(Forecast*Vars, fullfile('Models', ModelPath, 'forecast', 'forecast_base.csv'), Inf);
