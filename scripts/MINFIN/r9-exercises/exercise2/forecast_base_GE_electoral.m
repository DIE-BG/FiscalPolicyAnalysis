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

ModelPath = 'MINFIN';

% Check if forecas folder exists
if ~isfolder(fullfile('Models', ModelPath, 'forecast', 'r9_exercises'))
    mkdir(fullfile('Models', ModelPath, 'forecast', 'r9_exercises'));
    disp('The forecast folder was created')
else
    disp('The forecast folder exists')
end

% Load the parameters
run(fullfile('Models', ModelPath, 'Initial_setup', 'setparam.m'));
% Creación del objeto "model", en el workspace, asignación de parámetros y solución.
MODEL = model(fullfile('Models', ModelPath, 'Initial_setup', 'model.mod'), 'assign', p);
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

% MINFIN figures of the exercise (Cuadro 3, millions of quetzales). IPub,
% IngT and GFun are annual flows; DPE and DPI are annual changes in the
% stock of debt.
Minfin.dates = [qq(2026, 4), qq(2027, 4)];
Minfin.IPub = [31000; 39000*0.9432];
Minfin.IngT = [127000; 140000*0.9432];
Minfin.GFun = [120000; 149000*0.9432];
Minfin.DPE  = [2300; 500*0.9432];
Minfin.DPI  = [24500; 41000*0.9432];

% Load data of nominal GDP. NameRow is explicit for compatibility with the
% unquoted "Variables ->" header in this CSV and IRIS 2019.
GDP_n = databank.fromCSV( ...
    fullfile('Models', ModelPath, 'data', 'GDP_nom_SM.csv'), ...
    'NameRow=', 1 ...
    );

% We define the start and end dates for forecast.
StartPred = qq(2026,3);
EndPred = qq(2033, 4);

%{
    Automatic adjustment of the 2027Q4 shocks. Each pass runs the whole
    forecast, measures diff = MINFIN - model in 2027Q4 and corrects the
    shocks of that quarter with

        du = 100*diff/Y                                  (u4, u5, u6, u7)
        du18 = 1000*diff_DPI/Y - (du4 + du6 - du5 - du7)

    where Y is the nominal GDP of 2027Q4. The values written in the if
    block are the starting point; the loop adds the correction to them.
%}
Tadj = qq(2027, 4);                     % quarter whose shocks are adjusted
iAdj = round(Tadj - StartPred) + 1;     % its position in the loop (i == 6)
kAdj = find(Minfin.dates == Tadj);      % its position in Minfin
adj = struct('u4', 0, 'u5', 0, 'u6', 0, 'u7', 0, 'u18', 0);
tol = 0.5;                              % millions of quetzales
maxPass = 10;
converged = false;

for pass = 1:maxPass

    % Database copy. This data base will store the one step ahead forecast
    Forecast = F;
    u9_path = [];

    u4_path = [];
    u5_path = [];
    u6_path = [];
    u7_path = [];
    u16_path = [];
    u18_path = [];

    for i = 1:length(StartPred:EndPred)

        if i == 1 % 2026Q3
            u4 = -0.04216;
            u5 = -0.08;
            u6 = 0.1726;
            u7 = -0.4827;
            u16 = -0.45;
            u18 = 7;

        elseif i == 2 % 2026Q4
            u4 = 0.0382;
            u5 = 0.0195;
            u6 = 0.1644;
            u7 = -0.2368;
            u16 = -0.25;
            u18 = 3.703;

        elseif i == 3 % 2027Q1
            u4 = 0.06;
            u5 = -0.10;
            u6 = 0.2;
            u7 = -0.15;
            u16 = -0.15;
            u18 = 7;

        elseif i == 4 % 2027Q2
            u4 = 0.07;
            u5 = -0.10;
            u6 = 0.2;
            u7 = -0.15;
            u16 = -0.15;
            u18 = 7;

        elseif i == 5 % 2027Q3
            u4 = 0.08;
            u5 = -0.10;
            u6 = 0.2;
            u7 = -0.15;
            u16 = -0.1;
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
            u6 = -0.1;
            u7 = 0;
            u16 = 0;
            u18 = 0;

        elseif i == 12 % 2029Q2

            u4 = 0;
            u5 = 0.10;
            u6 = -0.15;
            u7 = 0;
            u16 = 0;
            u18 = 0;

        elseif i == 13 % 2029Q3

            u4 = 0;
            u5 = 0.15;
            u6 = -0.1;
            u7 = 0;
            u16 = 0;
            u18 = 0;

        elseif i == 14 % 2029Q4

            u4 = 0;
            u5 = 0.15;
            u6 = -0.12;
            u7 = 0;
            u16 = 0;
            u18 = 0;

        else % 2030Q1 onwards: no shocks

            u4 = 0;
            u5 = 0;
            u6 = 0;
            u7 = 0;
            u16 = 0;
            u18 = 0;

        end

        % Correction of the 2027Q4 shocks computed by the adjustment loop
        if i == iAdj
            u4 = u4 + adj.u4;
            u5 = u5 + adj.u5;
            u6 = u6 + adj.u6;
            u7 = u7 + adj.u7;
            u18 = u18 + adj.u18;
        end

        % u9 residuel from the data and forecast
        u9 = (1 - p.a9_1)*Forecast.DPI_ola(end) + (1 - p.a7_1 - p.a9_2)*Forecast.DPE_ola(end) ...
            + (p.a6_1 - p.a9_3)*Forecast.GFun_ola(end) + (p.a4_1 - p.a9_3)*Forecast.IPub_ola(end) ...
            - (p.a5_1 + p.a9_3)*Forecast.IngT_ola(end) ...
            + u4 + u6 - u5 - u7 + u18;

        % Quarter that will be simulated
        SPred = Forecast.GDP_star_ola.Range(end) + 1;

        % zero data base of shocks
        shocks = zerodb(MODEL, Forecast.GDP_star_ola.Range(1):Forecast.GDP_star_ola.Range(end))*{'u9', 'u4', 'u5', 'u6', 'u7', 'u16'};

        % Combine the data base with intial conditions and shocks
        Forecast = dboverlay(Forecast,shocks);

        % Shocks of the SPred quarter
        Forecast.u9(SPred) = u9;
        Forecast.u4(SPred) = u4;
        Forecast.u5(SPred) = u5;
        Forecast.u6(SPred) = u6;
        Forecast.u7(SPred) = u7;
        Forecast.u16(SPred) = u16;

        % simulation One Step Ahead
        Forecast_OSAH = simulate(MODEL,...
            Forecast,...
            SPred,...
            'anticipate',false,...
            'DbOverlay=', true);

        Forecast = Forecast_OSAH;

        u9_path(i) = u9;
        u4_path(i) = u4;
        u5_path(i) = u5;
        u6_path(i) = u6;
        u7_path(i) = u7;
        u16_path(i) = u16;
        u18_path(i) = u18;

    end

    % Nominal GDP implied by this pass (Y of 2027Q4 and of 2026Q4)
    g_nom = (Forecast.GDP_SM_yoy + Forecast.pi_yoy)/100;
    Y_nom = GDP_n.GDP_nom_SM;
    for t = qq(2025, 1):Tadj
        Y_nom(t) = Y_nom(t-4) * (1 + g_nom(t));
    end
    Y = Y_nom(Tadj);
    Y_lag = Y_nom(Tadj-4);

    % diff = MINFIN - model in 2027Q4 (DPE and DPI as annual change of the stock)
    gap.IPub = Minfin.IPub(kAdj) - Y*Forecast.IPub_ratio(Tadj)/100;
    gap.IngT = Minfin.IngT(kAdj) - Y*Forecast.IngT_ratio(Tadj)/100;
    gap.GFun = Minfin.GFun(kAdj) - Y*Forecast.Gfun_ratio(Tadj)/100;
    gap.DPE  = Minfin.DPE(kAdj) - (Y*Forecast.DPE_ratio(Tadj) - Y_lag*Forecast.DPE_ratio(Tadj-4))/100;
    gap.DPI  = Minfin.DPI(kAdj) - (Y*Forecast.DPI_ratio(Tadj) - Y_lag*Forecast.DPI_ratio(Tadj-4))/100;

    fprintf('Pass %d | diff 2027Q4: IPub %9.2f  IngT %9.2f  GFun %9.2f  DPE %9.2f  DPI %9.2f\n', ...
        pass, gap.IPub, gap.IngT, gap.GFun, gap.DPE, gap.DPI);

    if max(abs(cell2mat(struct2cell(gap)))) < tol
        converged = true;
        break
    end

    % du = diff*100/Y, added to the correction of the 2027Q4 shocks
    du4 = 100*gap.IPub/Y;
    du5 = 100*gap.IngT/Y;
    du6 = 100*gap.GFun/Y;
    du7 = 100*gap.DPE/Y;
    du18 = 1000*gap.DPI/Y - (du4 + du6 - du5 - du7);

    adj.u4 = adj.u4 + du4;
    adj.u5 = adj.u5 + du5;
    adj.u6 = adj.u6 + du6;
    adj.u7 = adj.u7 + du7;
    adj.u18 = adj.u18 + du18;

end

if ~converged
    warning('The 2027Q4 shocks did not converge after %d passes.', maxPass);
end

% Shocks of 2027Q4 actually used (copy them into the if block if you want
% to fix them by hand)
fprintf('\n2027Q4 shocks:\n');
fprintf('        u4 = %.5f;\n', u4_path(iAdj));
fprintf('        u5 = %.5f;\n', u5_path(iAdj));
fprintf('        u6 = %.5f;\n', u6_path(iAdj));
fprintf('        u7 = %.5f;\n', u7_path(iAdj));
fprintf('        u16 = %.5f;\n', u16_path(iAdj));
fprintf('        u18 = %.5f;\n\n', u18_path(iAdj));

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
databank.toCSV(Forecast*Vars, fullfile('Models', ModelPath, 'forecast','r9_exercises', 'forecast_GE_historical.csv'), Inf);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CHECKING THE FISCAL ACCOUNTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Recover the nominal levels of selected fiscal accounts for the exercise.
The model forecasts each fiscal variable as a percentage of the
four-quarter moving sum of nominal GDP.

Required input in the workspace:
    Forecast    IRIS databank containing GDP_nom_SM_yoy and the fiscal
                ratios generated by the forecast section above.

Output:
    fiscal_accounts    IRIS databank whose fields are quarterly Series.
%}

% Minfin (Cuadro 3) and GDP_n (nominal GDP data) are loaded before the
% forecast section, since the 2027Q4 adjustment loop uses them.

%% Transform the data into the required format
% nominal GDP
% expand the data to include the forecast period
dates_range = qq(2025, 1):EndPred;
GDP_n.GDP_nom_SM(dates_range) = 0;

% using the model's forecast of nominal GDP growth rate to recover the nominal GDP series
for i = dates_range
    GDP_n.GDP_nom_SM(i) = GDP_n.GDP_nom_SM(i-4) * (1 + Forecast.GDP_nom_SM_yoy(i));
end

%% using the nominal GDP series to recover the series of the fiscal accounts
fiscal_accounts = struct();

% Curly-brace indexing preserves the IRIS Series class; parenthesis
% indexing would extract a numeric array instead.
GDP_nom_SM = GDP_n.GDP_nom_SM{dates_range};

% Recover nominal levels from ratios expressed in percent of nominal GDP.
fiscal_accounts.IPub = ...
    GDP_nom_SM .* Forecast.IPub_ratio{dates_range}/100;
fiscal_accounts.IngT = ...
    GDP_nom_SM .* Forecast.IngT_ratio{dates_range}/100;
fiscal_accounts.DPE = ...
    GDP_nom_SM .* Forecast.DPE_ratio{dates_range}/100;
fiscal_accounts.GFun = ...
    GDP_nom_SM .* Forecast.Gfun_ratio{dates_range}/100;
fiscal_accounts.DPI = ...
    GDP_nom_SM .* Forecast.DPI_ratio{dates_range}/100;

% Debt flows: change of the stock with respect to the same quarter of the
% previous year (in a Q4 it is the annual change compared with MINFIN).
fiscal_accounts.DPE_change = fiscal_accounts.DPE - fiscal_accounts.DPE{-4};
fiscal_accounts.DPI_change = fiscal_accounts.DPI - fiscal_accounts.DPI{-4};

% Deficit (IPub + GFun - IngT) in millions of quetzales
fiscal_accounts.Def = ...
    GDP_nom_SM .* Forecast.Def_ratio{dates_range}/100;

% Ratios in percent of the four-quarter moving sum of nominal GDP
fiscal_accounts.IPub_ratio = Forecast.IPub_ratio{dates_range};
fiscal_accounts.IngT_ratio = Forecast.IngT_ratio{dates_range};
fiscal_accounts.GFun_ratio = Forecast.Gfun_ratio{dates_range};
fiscal_accounts.DPE_ratio  = Forecast.DPE_ratio{dates_range};
fiscal_accounts.DPI_ratio  = Forecast.DPI_ratio{dates_range};
fiscal_accounts.Def_ratio  = Forecast.Def_ratio{dates_range};

% GDP: real growth (yoy of the four-quarter moving sum, %) and nominal level
fiscal_accounts.GDP_SM_yoy = Forecast.GDP_SM_yoy{dates_range};
fiscal_accounts.GDP_nom_SM = GDP_nom_SM;

% Descriptions written in the "Comments ->" row of the csv
fiscal_accounts.IPub = comment(fiscal_accounts.IPub, 'Inversión pública (millones de Q)');
fiscal_accounts.IngT = comment(fiscal_accounts.IngT, 'Ingresos totales (millones de Q)');
fiscal_accounts.GFun = comment(fiscal_accounts.GFun, 'Gasto de funcionamiento (millones de Q)');
fiscal_accounts.DPE = comment(fiscal_accounts.DPE, 'Saldo de deuda pública externa (millones de Q)');
fiscal_accounts.DPI = comment(fiscal_accounts.DPI, 'Saldo de deuda pública interna (millones de Q)');
fiscal_accounts.DPE_change = comment(fiscal_accounts.DPE_change, 'Cambio interanual de deuda pública externa (millones de Q)');
fiscal_accounts.DPI_change = comment(fiscal_accounts.DPI_change, 'Cambio interanual de deuda pública interna (millones de Q)');
fiscal_accounts.Def = comment(fiscal_accounts.Def, 'Déficit fiscal (millones de Q)');
fiscal_accounts.IPub_ratio = comment(fiscal_accounts.IPub_ratio, 'Inversión pública (% del PIB)');
fiscal_accounts.IngT_ratio = comment(fiscal_accounts.IngT_ratio, 'Ingresos totales (% del PIB)');
fiscal_accounts.GFun_ratio = comment(fiscal_accounts.GFun_ratio, 'Gasto de funcionamiento (% del PIB)');
fiscal_accounts.DPE_ratio = comment(fiscal_accounts.DPE_ratio, 'Deuda pública externa (% del PIB)');
fiscal_accounts.DPI_ratio = comment(fiscal_accounts.DPI_ratio, 'Deuda pública interna (% del PIB)');
fiscal_accounts.Def_ratio = comment(fiscal_accounts.Def_ratio, 'Déficit fiscal (% del PIB)');
fiscal_accounts.GDP_SM_yoy = comment(fiscal_accounts.GDP_SM_yoy, 'Crecimiento interanual del PIB real (%)');
fiscal_accounts.GDP_nom_SM = comment(fiscal_accounts.GDP_nom_SM, 'PIB nominal, suma móvil de 4 trimestres (millones de Q)');

%% Export the fiscal accounts, real GDP and deficit
databank.toCSV(fiscal_accounts, fullfile('Models', ModelPath, 'forecast', 'r9_exercises', 'fiscal_accounts_historical.csv'), Inf);

%% Summary table for year-end quarters
table_dates = Minfin.dates(:);

fiscal_accounts_table = table( ...
    Minfin.IPub,...
    fiscal_accounts.IPub(table_dates), ...
    Minfin.IPub - fiscal_accounts.IPub(table_dates), ...
    Minfin.IngT,...
    fiscal_accounts.IngT(table_dates), ...
    Minfin.IngT - fiscal_accounts.IngT(table_dates), ...
    Minfin.DPE, ...
    fiscal_accounts.DPE_change(table_dates), ...
    Minfin.DPE - fiscal_accounts.DPE_change(table_dates), ...
    Minfin.GFun, ...
    fiscal_accounts.GFun(table_dates), ...
    Minfin.GFun - fiscal_accounts.GFun(table_dates), ...
    Minfin.DPI, ...
    fiscal_accounts.DPI_change(table_dates), ...
    Minfin.DPI - fiscal_accounts.DPI_change(table_dates), ...
    'VariableNames', {'IPub minfin', 'IPub', 'IPub diff', 'IngT minfin', 'IngT', 'IngT diff', 'DPE minfin', 'DPE', 'DPE diff', 'GFun minfin', 'GFun', 'GFun diff', 'DPI minfin', 'DPI', 'DPI diff'}, ...
    'RowNames', cellstr(dat2str(table_dates)) ...
    );

format bank
disp(fiscal_accounts_table)

%% Real GDP growth and deficit path (percent)
path_dates = qq(2026, 4):EndPred;
path_table = table( ...
    Forecast.GDP_SM_yoy(path_dates), ...
    Forecast.IPub_ratio(path_dates), ...
    Forecast.Gfun_ratio(path_dates), ...
    Forecast.IngT_ratio(path_dates), ...
    Forecast.Def_ratio(path_dates), ...
    'VariableNames', {'PIB real', 'IPub', 'GFun', 'IngT', 'Deficit'}, ...
    'RowNames', cellstr(dat2str(path_dates)) ...
    );
disp(path_table)

