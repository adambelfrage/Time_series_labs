addpath('Functions')
addpath('data')

clear all; 
clc; 

% marcov process
P = [7/8 1/8; 1/8 7/8]; 
mc = dtmc(P); 
u = simulate(mc, 1000)';

% simulate AR(2)
a1 = 0.5;
a2 = 0.25;
y = simulateMyARMA(1,[1 a1 a2], 10000); 
N = length(y); 

% the states xt = [a1 a2]'
A = [1  0; 0 1];
Re = 10^-4*eye(2); %Hidden state noise covariance, allow both parameters to change
Rw = 0.5*var(y); 
Rxx_1 = 0.5 * eye(2); % trust in initial conditions
xtt_1 = [0; 0];  % initial states
xsave = zeros(2,N) ;

for k=3:N
    C = [ -y(k-1) -y(k-2) ];
     
    % Update
    Ryy_1 = C*Rxx_1*C' + Rw; 
    Kt = Rxx_1*C'*inv(Ryy_1); %Ryy is in this sense Ryy at time t gven t  - 1
    %Rxx is still Rxx at t given t - 1
    Rxx =(eye(2) - Kt*C)*Rxx_1; % Updates Rxx at time t given t 
    xtt = xtt_1 + Kt *(y(k) - C*xsave(:,k-1)); % expected value of e is equal to zero. 
    %Save 
    xsave(:,k) = xtt; 
    %Precitions
    Rxx_1 = A *Rxx*A' + Re; %Rxx will eventually go to zero leaving the variance of the noise
    xtt_1 = A * xtt; 
end

clf; 
figure(1)
plot(1: N,0.5*(ones(1,N)),'r--'); 
hold on 
plot(1:N, xsave(1,:), 'r'); 
hold on
plot(1:N, 0.25*(ones(1,N)), 'g--'); 
hold on
plot(1:N, xsave(2,:), 'g'); 
% figure(2)
% plot(y)
