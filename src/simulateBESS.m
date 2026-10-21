%% Introduction
% This script simulates the Battery Energy Storage System to store excess 
% energy from solar PV and wind turbine systems
%% graphics settings

%% data
% timing
dt = 1/12; % time step in hours
tSpan = (datetime(2020,1,1,0,0,0):hours(dt):datetime(2020,12,31,23,0,0))'; %time span in datetime format 
tf = length(tSpan)*dt; % final time in hours
t = (0:dt:tf)'; % time span in hours
tLim = [t(1) t(end)]; % time axis limits, h
K = length(t) - 1; % number of time steps

% battery parameters
tau = 1600; % self-dissipation time constant, h
a = exp(-dt/tau); % discrete-time dynamics parameter
etac = 0.95; % charging efficiency
etad = etac; % discharging efficiency
pcMax = 10000; % power capacity, kW
xMax = N_Battery; % energy capacity, kWh
x0 = 0; % initial energy, kWh
xMin = 0; % minimum acceptable energy capacity, kWh

%% Loop de Loop
pSun_total = pSun*N_Solar;
pWind_total = pWind*N_Wind;
totalE_Sun = sum(pSun_total*dt);
totalE_Wind = sum(pWind_total*dt);

%fprintf('Total Solar Energy = %0.2f kWh\n',totalE_Sun);
%fprintf('Total Wind Energy = %0.2f kWh\n',totalE_Wind);

% generate total power during operation
pChem = pSun_total + pWind_total - pLoad ; % power left in kW

%% input signal plot
% plot parameters
%eLim = [0,xMax]; % energy axis limits, kWh
%pLim = [0,pcMax]; % electric power axis limits, kW
%pChemLim = [0,ceil(max(pChem)/5)*5]; % chemical power axis limits, kW

%% simulation
[x1,e1,e2,e3] = simulatePolicy1(x0,pLoad, K, dt, pChem,a,tau,etac,etad,pcMax,xMax);

totalE_wasted= sum(e2);
%fprintf('Total Energy Wasted= %0.2f kWh\n',totalE_wasted);

totalE_grid = sum(e1);
totalE_battery = sum(e3);

%TotalCost = yFrame * sum(eCost*totalE_grid) + N_Wind * (wiCost + yFrame * woCost) + N_Solar * (siCost + yFrame * soCost) + N_Battery * (biCost);
%TotalSavings = eCost*sum(pLoad)*dt*yFrame - TotalCost; 
%fprintf('Total Energy from Grid= %0.2f kWh\n',totalE_grid);
%fprintf('Total Energy wasted due to efficiency losses in battery= %0.2f kWh\n',totalE_battery*0.05);
% energy plot
% figure(1), clf
% subplot(2,1,1), fullStairs(t,x1(2:end),'k')
% ylabel({'Stored','energy (kWh)'})
% hold on
% text(mean(tLim)/4,xMin,'$\underline x$','color','m',...
%     'horizontalalignment','left','verticalalignment','top')
% 
% % charging power plot
% subplot(2,1,2)
% hold on, fullStairs(t,pChem,'k')
% ylabel({'Charging','power (kW)'})
% xlabel('Hour (0 = midnight)')




