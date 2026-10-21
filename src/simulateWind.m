%% Introduction 
% This script simulates electricity generation using a wind power output.
% Vestas V110 2 MW turbine; power-coefficient curve fitted to manufacturer data.
% Stats:
% Hub height = 100m

%% Input data

% timing
dt = 5/60; % time step, h
tSpan = (datetime(2020,1,1,0,0,0):hours(dt):datetime(2020,12,31,23,0,0))'; % time span as datetime
K = length(tSpan); % number of time steps
t = (0:dt:K*dt)';

% wind data import
windFile = fullfile(dataDir(), 'west-lafayette-2020-wind.csv'); % wind file name
[windSpeed80m,windSpeed100m,windSpeed120m,offsetGMT] = ...
    importWind(windFile,tSpan); % weather data import

%% Wind Power Generation

% Turbine parameters
ratedP = 2000; % rated power [kW]
ratedV = 11.5; % rated speed, [m/s]
cutinV = 3; % cut in speed, [m/s]
cutoutV = 21; % cut out speed, [m/s]
V = windSpeed100m(1:K); %wind speed at selected hub height (100m)
pWind = NaN; %Wind Power [kW]
eWind = NaN; %Energy Produced [kWh]
CP = NaN; %Power coefficient

% Wind energy generated
for k = 1:1:K
    if V(k) < cutinV
        pWind(k) = 0;
    elseif V(k) >= cutinV && V(k) <= ratedV
        CP = 0.00008125*V(k)^6 - 0.00330702*V(k)^5 + 0.05321091*V(k)^4 - ...
        0.43395758*V(k)^3 + 1.91371824*V(k)^2 - 4.28922087*V(k) + 3.81730608;
        pWind(k) = CP * ratedP;
    elseif V(k) > ratedV && V(k) < cutoutV
        pWind(k) = ratedP;
    elseif V(k) >= cutoutV
        pWind(k) = 0;
    end        
end


%% Results
% Display total energy generated
pWind = pWind.';
eWind = pWind * dt;
totalE_Wind = sum(eWind);
%fprintf('Total Wind Energy = %0.2f kWh\n',totalE_Wind);

% Plot for Presentation
m_wind = 0:0.001:25;
cp_wind(1:3000) = 0;
cp_wind(11001:21000) = 1;
cp_wind(21000:25001) = 0;
cp_wind(3001:11000) = 0.00008125*m_wind(3001:11000).^6 - 0.00330702*m_wind(3001:11000).^5 + 0.05321091*m_wind(3001:11000).^4 - ...
        0.43395758*m_wind(3001:11000).^3 + 1.91371824*m_wind(3001:11000).^2 - 4.28922087*m_wind(3001:11000) + 3.79520608;
figure(1), clf
plot(m_wind,cp_wind,'k')
title('Power Coefficient for Vestas 110 2MW');
xlabel('Wind Speed [m/s]');
ylabel({'Power Coefficient'})
% datetick('x', 'mmm', 'keepticks');
grid on;
figure(2), clf
plot(tSpan,pWind,'k')
title('Wind Energy Production');
xlabel('Date');
ylabel({'Power [kW]'})
datetick('x', 'dd', 'keepticks');
grid on;
















