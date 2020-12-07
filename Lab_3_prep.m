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
A = [1  0; 0 1]; % allow both parameters to change
Re = 10^-6*eye(2); %Hidden state noise covariance  
%Rw = var(y); 
Rw = 5;

Rxx_1 = 1 * eye(2); % trust in initial conditions
xtt_1 = [0; 0];  % initial states
xsave = zeros(2,N) ;
Ryy_1 = Rw; % initial value

for k=3:N
    C = [ -y(k-1) -y(k-2) ]; % past observations
    
    % Update
    Kt = Rxx_1*C'*inv(Ryy_1); % Ryy_1 = prediction based on past observations Ryy t|(t-1) - NOT YET UPDTED
    Rxx =(eye(2) - Kt*C)*Rxx_1; % Update Rxx t|t based on the prediction Rxx t|(t-1)
    xtt = xtt_1 + Kt *(y(k) - C*xsave(:,k-1)); % E[et] = 0,  update estimated states based on previous prediction of the states and prediction error
   
    %Save current estimate of the states
    xsave(:,k) = xtt; 
    
    %Precitions
    Rxx_1 = A *Rxx*A' + Re; % prediction based on the updated states. If Rxx is small, the variance of the model noise will still be present
    Ryy_1 = C*Rxx_1*C' + Rw; % prediction based on the predicted variance of the states. If Rxx_1 is small, the variance of the measurement noise will still be present
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
