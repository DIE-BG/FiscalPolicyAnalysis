%{
Function to create error based on one step ahed forecast. The algorithm is
simple:

1- Make a one step ahed forecast for each variable
2- Collect all one step ahed forecast into time series struct
3- Make the errors by difference between observed value and forecast

The funciton need a databank struct and return the same struct with the
errors that have been added.
%}

function F_errors = makeErrors(F_struct, MODEL)

    startForecast = qq(2009, 4);
    numPeriods = 67;

    namesToSave = get(MODEL, 'xlist');  % List of variables we will get the one stpet ahead forecast

    Forecast_1step = struct();

    for k = 1:numPeriods

        t = startForecast + k - 1;

        disp(t)

        Hist = databank.clip(F_struct, t-4, t-1);

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

    errors.u1 = F_struct.GDP_star_ola - Forecast_1step.GDP_star_ola;
    errors.u2 = F_struct.i_star_ola - Forecast_1step.i_star_ola;
    errors.u3 = F_struct.pi_star_ola - Forecast_1step.pi_star_ola;
    errors.u4 = F_struct.IPub_ola - Forecast_1step.IPub_ola;
    errors.u5 = F_struct.IngT_ola - Forecast_1step.IngT_ola;
    errors.u6 = F_struct.GFun_ola - Forecast_1step.GFun_ola;
    errors.u7 = F_struct.DPE_ola - Forecast_1step.DPE_ola;
    errors.u8 = F_struct.Rem_ola - Forecast_1step.Rem_ola;
    errors.u9 = F_struct.DPI_ola - Forecast_1step.DPI_ola;
    errors.u10 = F_struct.AEN_ola - Forecast_1step.AEN_ola;
    errors.u11 = F_struct.AIN_ola - Forecast_1step.AIN_ola;
    errors.u12 = F_struct.i_ola - Forecast_1step.i_ola;
    errors.u13 = F_struct.e_ola - Forecast_1step.e_ola;
    errors.u14 = F_struct.PREM_ola - Forecast_1step.PREM_ola;
    errors.u15 = F_struct.pi_ola - Forecast_1step.pi_ola;
    errors.u16 = F_struct.GDP_ola - Forecast_1step.GDP_ola;
    errors.u17 = F_struct.IPriv_ola - Forecast_1step.IPriv_ola;

    %% Incorporating errors into the F-structure

    errorsNames = get(MODEL, 'elist');

    for i = 1:length(errorsNames)

       errorName = errorsNames{i};

       F_struct.(errorName) = errors.(errorName);
    end
    
    F_errors = F_struct;
end