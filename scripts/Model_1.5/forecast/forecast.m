%% Load the model in the matlab workspace
clc;
clear all;

% add necesary functions to make the series of errors
addpath('src/helpers/forecast');

% Check if forecas folder exists
if ~isfolder(fullfile('Models', 'Model_1.5', 'forecast'))
    mkdir(fullfile('Models', 'Model_1.5', 'forecast'));
    disp('The forecast folder was created')
else
    disp('The forecast folder exists')
end
    
% Load the parameters
run(fullfile('scripts', 'Model_1.5', 'forecast', 'setparam.m'));
% Creación del objeto "model", en el workspace, asignación de parámetros y solución.
MODEL = model(fullfile('scripts', 'Model_1.5', 'forecast', 'model.mod'), 'assign', p);
MODEL = sstate(MODEL,'growth=',true,'MaxFunEvals',1000,'display=','off');
[flag,discrep,eqtn] = chksstate(MODEL);

if flag
    disp(" ")
else
    warning("El estado estacionario calculado discrepa del impuesto.")
end

MODEL = solve(MODEL,'error=',true);

%% Load the historical data
d = databank.fromCSV(fullfile('Models', 'Model_1.5', 'data', 'initial_conditions.csv'));

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

%% Forecast
% We define the start and end dates for forecast.
StartPred = qq(2025,4);
EndPred = qq(2025,4)+124;

% Simulación, utilizando el model (g) y la base de datos (d) 
Forecast = simulate(MODEL, F, StartPred:EndPred, 'Deviation=', false, 'anticipate=',false);
Forecast = dbextend(F,Forecast);

% Export the free scenario path of the forecast
% variables will be exported
Vars = [get(MODEL, 'xlist'),  [{'u5'}, {'u9'}]];
databank.toCSV(Forecast*Vars, fullfile('Models', 'Model_1.5', 'forecast', 'free_forecast.csv'), Inf);

%% Forecast with a shock in u9 period by period and a u5 one period shock
%{
    We will make forecast one step ahead. For each period, we force the
    residual u9 so that it equals:

    u9 = (1 - p.a9_1)*NewDB.DPI(end) + (1 - p.a7_1 - p.a9_2)*NewDB.DPE(end) ...
         + (p.a6_1 - p.a9_3)*NewDB.GFun(end) + (p.a4_1 - p.a9_3)*NewDB.IPub(end) ...
         - (p.a5_1 + p.a9_3)*NewDB.IngT(end); ...
         + u4 + u6 - u5 - u7;

    In order to mantain the accounting equation for total domestic debt.
%}

% Database copy. This data base will store the one step ahead forecast
NewDB = F;
u9_path = [];

u5_path = [];

for i = 1:length(StartPred:EndPred)
    
    if i == 1
       u5 = 0.35;
       
    else
        
        u5 = 0;
       
    end
    
    % u9 residuel from the data and forecast
    u9 = (1 - p.a9_1)*NewDB.DPI_ola(end) + (1 - p.a7_1 - p.a9_2)*NewDB.DPE_ola(end) ...
         + (p.a6_1 - p.a9_3)*NewDB.GFun_ola(end) + (p.a4_1 - p.a9_3)*NewDB.IPub_ola(end) ...
         - (p.a5_1 + p.a9_3)*NewDB.IngT_ola(end) ...
         - u5;

    % Quarters that will be exogenized
    SPred = NewDB.GDP_star_ola.Range(end) + 1;

    % zero data base of shocks
    shocks = zerodb(MODEL, NewDB.GDP_star_ola.Range(1):NewDB.GDP_star_ola.Range(end))*{'u9', 'u5'};

    % Combine the data base with intial conditions and shocks
    NewDB = dboverlay(NewDB,shocks);

    % Exogenize by SPred quarter
    NewDB.u9(SPred) = u9;
    NewDB.u5(SPred) = u5;
    
    % simulation plan
    planSim = plan(MODEL, SPred);
    % variable that will be endogenized
    planSim = endogenize(planSim,{'DPI_ola'}, SPred); 
    planSim = endogenize(planSim,{'IngT_ola'}, SPred); 
    % shock that will be exogenized
    planSim = exogenize(planSim,{'u9'}, SPred);
    planSim = exogenize(planSim,{'u5'}, SPred);

    % simulation One Step Ahead
    Forecast_OSAH = simulate(MODEL,...
                      NewDB,...
                      SPred,...
                      'plan', planSim,...
                      'anticipate',false,...
                      'DbOverlay=', true);
                  
    NewDB = Forecast_OSAH;
    
    u9_path(i) = u9;
    u5_path(i) = u5;

end

NewDB.u9(qq(2009, 1):StartPred) = F.u9;
NewDB.u9(qq(2025, 4):EndPred) = u9_path;
NewDB.u5(qq(2009, 1):StartPred) = F.u5;
NewDB.u5(qq(2025, 4):EndPred) = u5_path;

% Export the data
%databank.toCSV(NewDB*Vars, fullfile('Models', 'Model_1.5', 'forecast', 'forecast_with_u9_and_u5_path.csv'), Inf);
