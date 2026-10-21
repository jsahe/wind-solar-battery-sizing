function [Stot,Sb,Sd] = surfaceIrradiance(az,el,az0,tilt,beamNormal,diffuseHorizontal)
% To calculate the solar irradiance on a surface
%
% az, a K x 1 vector of solar azimuth angles, in degrees (theta)
% el, a K x 1 vector of solar elevation angles, in degrees (alpha)
% az0, a scalar surface azimuth angle, in degrees
% tilt, a scalar surface tilt angle, in degrees
% beamNormal, a K x 1 vector of beam irradiances on a surface normal to the sun, in kW/m^2
% diffuseHorizontal, a K x 1 vector of diffuse irradiances on a horizontal surface, in kW/m^2
% Stot, the total irradiance on the surface, in kW/m^2
% Sb, the beam irradiance on the surface, in kW/m^2
% Sd, the diffuse irradiance on the surface, in kW/m^2

Sb = zeros(length(az),1);
Sd = zeros(length(az),1);
Stot = zeros(length(az),1);

for i = 1:length(az)
    if el(i) < 0  || (90 < abs(az(i) - az0) && abs(az(i) - az0)< 270)
        Sb(i) = 0;
    else 
        Sb(i) = beamNormal(i)*(cosd(el(i))*sind(tilt)*cosd(az(i) - az0) + sind(el(i))*cosd(tilt));
    end
    Sd(i) = diffuseHorizontal(i);
    Stot(i) = Sb(i) + Sd(i); 
end

