% importLoadProfile generates a simulated 5-minute electricity demand profile
% for an automotive assembly plant over all of 2020 (15-20 MW, ~180 GWh/yr).
% Night shift (00:00-06:00) averages ~17.5 MW, day shifts ~21.5 MW, with
% uniform random variation to represent short over- and under-loads.

% Get annual/monthly electricity consumption to calculate average power
% usage for the factory and generate demand profile

% Define parameters
set(0,'DefaultAxesFontSize',16);
set(0,'DefaultTextFontSize',24);
set(0,'DefaultLegendFontSizeMode','manual')
set(0,'DefaultLegendFontSize',24)

days_in_week = 7;
hours_in_day = 24; 
minutes_in_hour = 12; % 5-minute-wise data
dt = 1/12; % time step in hours (5 minutes)

% Generate time span
tSpan = (datetime(2020,1,1,0,0,0):hours(1/12):datetime(2020,12,31,23,0,0))';  %time span in datetime format 

% Initialize load profile
pLoad = zeros(length(tSpan), 1);

% Generate load for each day
for i = 1:length(tSpan)
    % Determine the day of the week
    day_of_week = mod(i-1, days_in_week) + 1;
    % Full production load (20000 kW) after 6am
    if mod(i-1, hours_in_day*minutes_in_hour) >= 6*minutes_in_hour
        pLoad(i) = 20*1000 + 3.0*1000 * rand;
    % Half capacity load (15000 kW) for 6 hours in the morning
    else
        pLoad(i) = 15*1000 + 5.0*1000 * rand;
    end
end

totalE_Demand = sum(pLoad)*dt;
%fprintf('Total Energy Demand= %0.2f kWh\n',totalE_Demand);

%Plot the load profile for the entire year
figure;
plot(tSpan, pLoad, 'LineWidth', 1);
title('Electricity Demand Load for Car Factory (2020)');
xlabel('Date');
ylabel('Load (kW)');
xlim([tSpan(1), tSpan(end)]);
ylim([10000, 30000]);
datetick('x', 'mmm', 'keepticks');
grid on;
