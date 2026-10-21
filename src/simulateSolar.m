%% simulateSolar
% Output of one Jinko Eagle 540 W module at West Lafayette, IN, at 5-minute
% resolution: solar geometry, beam + diffuse irradiance on a surface tilted at
% latitude, and temperature-dependent cell efficiency.

%% Inputs

%Solar Weather Inputs - Data obtained through Oikolab
dt = 1/12; % time step in hours
tSpan = (datetime(2020,1,1,0,0,0):hours(dt):datetime(2020,12,31,23,0,0))';  %time span in datetime format 
K = length(tSpan); % number of time steps
t = (0:dt:K*dt)'; % time span in hours
weatherFile = fullfile(dataDir(), 'west-lafayette-2020-solar.csv'); % OikoLab, see data/README.md 
[theta,totalHorizontal,beamNormal,diffuseHorizontal,offsetGMT] = importWeather(weatherFile,tSpan);
lat = 40.4259; % latitude in degrees
long = -86.9081; % longitude in degrees

%% Solar Angles

el = zeros(length(tSpan),1);
az = zeros(length(tSpan),1);
D = zeros(length(tSpan),1);
gamma = zeros(length(tSpan),1);
delta = zeros(length(tSpan),1);
tau = zeros(length(tSpan),1);
lambda = zeros(length(tSpan),1);
tgm = zeros(length(tSpan),1);

for i = 1:length(tSpan)

    tgm(i) = rem(datenum(tSpan(i) - dateshift(tSpan(i), 'start', 'day')),1)*24; 
    D(i) = day(tSpan(i), 'dayofyear'); % day of year
    gamma(i) = 360*(D(i)-81)/365; 
    delta(i) = 23.45*sind(gamma(i)); %declination angle
    tau(i) = (0.165*sind(2*gamma(i)) - 0.126*cosd(gamma(i)) - 0.025*sind(gamma(i)));
    lambda(i) = long + 15*(tau(i) + tgm(i) -offsetGMT(i) - 12);
    el(i) = 90 - acosd(sind(lat)*sind(delta(i)) + cosd(lat)*cosd(delta(i))*cosd(lambda(i)));
    az(i) = atan2d(cosd(delta(i))*sind(lambda(i)), sind(lat)*cosd(delta(i))*cosd(lambda(i)) - cosd(lat)*sind(delta(i)));

end

% Surface Irradiance
beta = lat; % surface tilt angle in degrees
az0 = 0; % surface azimuth angle in degrees
[Stot,Sb,Sd] = surfaceIrradiance(az,el,az0,beta,beamNormal,diffuseHorizontal); %terms defined in the function file

% Solar Array Efficiency
ratedEta = 0.20; % rated solar array efficiency as per most recent and updated modules
ratedT = 25; % rated temperature, C
zeroT = 270; % temperature at which power output stops, C
Tc = theta + 35*Stot;
solarEta = ratedEta*(1 - (Tc - ratedT)/(zeroT - ratedT));

% Solar Power Supply
% Number of solar panels
panelA = 2.58; % Jinko Eagle 540 W module area in m^2 
pSun = panelA*solarEta.*Stot; % solar power supply for A solar panels, kW
eSun = pSun * dt;
totalE_Sun = sum(eSun);
%fprintf('Total Solar Energy = %0.2f kWh\n',totalE_Sun);

% Costs for Solar
% 
% Not utility scale, so no T&D lines required which are a big cost
% Included costs are Module price, Inverters, Structural and Electrical BOM, Labour, Inspection and Regulatory costs, 
% Taxes, Overhead extras, EPC/Developer profit
% This is the estimated cost for a ground mounted system assuming land has already been acquired. 
% In case the facility has empty roofs available, the cost would reduce a little.


