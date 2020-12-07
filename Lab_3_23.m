clc
clear all; 
close all
clear global 
P = [7/8 1/8; 1/8 7/8]; 
mc = dtmc(P); 
u = simulate(mc, 999)';
b = 20; 
x = simulateMyARMA(1,[1 0.5],1000)'; 
v = 4.*randn(1, 1000);
y = b.*u + x +v; 



N = length(y); 
% xt = state[xt b]'
A = [1  0; 0 1]; 
Re = [1 0; 0 0]*.1; %Hidden state noise covariance  
Rw = 4; 
Rxx_1 = 1 * eye(2); 
xtt_1 = [0; 0]; 
xsave = zeros(2,N) ;
%Rxx = Rxx_1;
Ryy_1 = Rw; %* eye(2); 
for k=3:N
    C = [1  u(k)]; 
    % Update
    Kt = Rxx_1*C'*inv(Ryy_1); %Ryy is in this sense Ryy at time t gven t  - 1
    %Rxx is still Rxx at t given t - 1
    Rxx =(eye(2) - Kt*C)*Rxx_1; % Updates Rxx at time t given t 
    xtt = xtt_1 + Kt *(y(k) - C*xsave(:,k-1)); % expected value of e is equal to zero. 
    %Save 
    xsave(:,k) = xtt; 
    %Precitions
    Rxx_1 = A *Rxx*A' + Re; %Rxx will eventually go to zero leaving the variance of the noise
    Ryy_1 = C*Rxx_1*C' + Rw; 
    xtt_1 = A * xtt; 
end

figure(1)
% plot(1:N, xsave(1,:), 'r'); 
% hold on
plot(1:N, xsave(2,:), 'g');
hold on
plot(1:N, 20*(ones(1,N)), 'g--'); 
