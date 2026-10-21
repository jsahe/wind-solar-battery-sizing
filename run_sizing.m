%% Wind, solar and battery sizing for an industrial load
% Sweeps the number of PV modules and the battery capacity for a fixed number
% of wind turbines, simulates a full year at 5-minute resolution for each
% configuration, and reports 10-year cost, savings, payback and CO2e avoided.
%
% Jose Sandoval & Sanat Rajagopalan, Purdue University, ME 597 (Distributed
% Energy Resources), April 2024.

clear; close all
addpath(fullfile(fileparts(mfilename('fullpath')), 'src'))
configureGraphics;
rng(0); % the load profile has random variation; fix it for repeatable runs

%% User inputs
N_Wind  = 14;          % number of Vestas V110 2 MW turbines (5 to 25 were tested)
eCost   = 0.13;        % industrial electricity price, $/kWh
wiCost  = 2400000;     % capital cost per 2 MW turbine, $
woCost  = 80000;       % O&M per turbine per year, $ ($40/kW-yr)
siCost  = 621;         % capital cost per 540 W module, $ ($1.15/W)
soCost  = 23*0.54;     % O&M per module per year, $ ($23/kW-yr)
biCost  = 2551*600/4800; % battery capital cost per kWh of storage, $
yFrame  = 10;          % evaluation horizon, years

solarRange   = 1000:1000:100000; % number of PV modules to sweep
batteryRange = 0:500:20000;      % battery capacity to sweep, kWh

% lifecycle emission factors, g CO2e/kWh
gridEF  = 640; % grid average (natural gas : coal = 2 : 1)
solarEF = 6;
windEF  = 7.2;

%% Generation and load (one year, 5-minute steps)
importLoadProfile;   % pLoad, kW
simulateSolar;       % pSun, kW per module
simulateWind;        % pWind, kW per turbine

%% Sweep
nRuns = numel(solarRange)*numel(batteryRange);
[TotalCost, TotalSavings, Payback, Emission_saved, Solars, BatterySize] = deal(zeros(nRuns,1));
l = 0;
for N_Solar = solarRange
    for N_Battery = batteryRange
        simulateBESS; % totalE_grid, totalE_Sun, totalE_Wind (kWh/yr)
        l = l + 1;
        capex = N_Wind*(wiCost + yFrame*woCost) + N_Solar*(siCost + yFrame*soCost) + N_Battery*biCost;
        TotalCost(l)    = yFrame*eCost*totalE_grid + capex;
        TotalSavings(l) = eCost*sum(pLoad)*dt*yFrame - TotalCost(l);
        Payback(l)      = capex/(eCost*(sum(pLoad)*dt - totalE_grid)); % simple payback, years
        Emission_saved(l) = sum(pLoad)*dt*gridEF ...
            - (totalE_grid*gridEF + totalE_Sun*solarEF*yFrame + totalE_Wind*windEF*yFrame); % g CO2e
        Solars(l) = N_Solar;
        BatterySize(l) = N_Battery;
    end
end

%% Results
[~, iSav] = max(TotalSavings);
[~, iPay] = min(Payback);
fprintf('\n%d turbines, %d configurations\n', N_Wind, nRuns);
fprintf('Max savings : %6d PV, %5.1f MWh BESS | savings %6.2f M$ | cost %6.2f M$ | payback %.2f yr | %.1f kt CO2e\n', ...
    Solars(iSav), BatterySize(iSav)/1000, TotalSavings(iSav)/1e6, TotalCost(iSav)/1e6, Payback(iSav), Emission_saved(iSav)/1e9);
fprintf('Min payback : %6d PV, %5.1f MWh BESS | savings %6.2f M$ | cost %6.2f M$ | payback %.2f yr | %.1f kt CO2e\n', ...
    Solars(iPay), BatterySize(iPay)/1000, TotalSavings(iPay)/1e6, TotalCost(iPay)/1e6, Payback(iPay), Emission_saved(iPay)/1e9);

figure
scatter(Payback, TotalSavings/1e6, 10, Emission_saved/1e9, 'filled')
xlabel('Simple payback [years]'), ylabel('10-year net savings [M\$]')
c = colorbar; c.Label.String = 'CO$_2$e avoided [kt]'; c.Label.Interpreter = 'latex';
title(sprintf('%d wind turbines: PV and battery configurations', N_Wind)), grid on
