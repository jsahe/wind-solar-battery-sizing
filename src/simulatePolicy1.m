function [x1,e1,e2, e3] = simulatePolicy1(x0,pLoad, K, dt,pChem,a,tau,etac,etad,pcMax,xMax)
% simulatePolicy1 simulates the battery storage charging and discharging policy
%
% Inputs:
%   x0, the battery's initial chemical energy, kWh
%   pChem, a K x 1 of operational power, kW
%   a, a scalar discrete-time dynamics parameter
%   tau, the battery's self-dissipation time constant, h
%   etac, the battery's charging efficiency
%   etad, the battery's discharging efficiency
%   pcMax, the battery's maximum charging electrical power, kW
%   xMax, the battery's chemical energy capacity, kWh
%
% Outputs:
%   x1, a K+1 x 1 vector of stored chemical energies, kWh
%   p1, a K x 1 vector of electrical charging powers, kW

% initialization
x1 = zeros(K+1,1); % stored chemical energy, kWh
e1 = zeros(K+1,1); % energy from grid, kW
e2 = zeros(K+1,1); % energy wasted, kW
e3 = zeros(K+1,1); % energy into/out of battery

x1(1) = x0; % initial state

% simulation
for k=1:K
    if pChem(k) > 0
        if pChem(k) >= pcMax
            x1(k+1) = min(x1(k) + dt*pcMax, xMax);
            e2(k) = (pChem(k) - pcMax)*dt;
            e3(k) = abs(x1(k+1) - x1(k));
            if x1(k+1) == xMax
                e2(k) = e2(k) + abs(xMax - x1(k) - dt*pcMax);
            end
        else
            x1(k+1) = min(x1(k) + dt*pChem(k), xMax);
            e3(k) = abs(x1(k+1) - x1(k));
            if x1(k+1) == xMax
                e2(k) = e2(k) + abs(xMax - x1(k) - dt*pChem(k));
            end
        end
      
    else
        if x1(k) > abs(pChem(k)*dt)
            x1(k+1) = x1(k) + dt*pChem(k);
            e1(k) = abs(pChem(k))*dt + (x1(k+1) - x1(k)); 
            e3(k) = abs(x1(k+1) - x1(k));
        else
            x1(k+1) = 0;
            e1(k) = abs(pChem(k))*dt  - x1(k);
            e3(k) = abs(x1(k+1) - x1(k));
        end
    end
 end

end

