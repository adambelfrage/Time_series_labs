tar2 = load('tar2.dat'); 
thx = load('thx.dat'); 
%%
N = length(tar2); 
% xt = state[a1 a2]
A = [1  0; 0 1]; 
Re = 10^-3 *[ 1 0 ; 0 0]; %Hidden state noise covariance  
Rw = 1.25; 
Rxx_1 = 1 * eye(2); 
xtt_1 = [0; 0]; 
xsave = zeros(2,N) ;
%Rxx = Rxx_1;
Ryy_1 = Rw; %* eye(2); 
for k=3:N
    C = [ -tar2(k-1) -tar2(k-2) ]; 
    % Update
    Kt = Rxx_1*C'*inv(Ryy_1); %Ryy is in this sense Ryy at time t gven t  - 1
    %Rxx is still Rxx at t given t - 1
    Rxx =(eye(2) - Kt*C)*Rxx_1; % Updates Rxx at time t given t 
    xtt = xtt_1 + Kt *(tar2(k) - C*xsave(:,k-1)); % expected value of e is equal to zero. 
    %Save 
    xsave(:,k) = xtt; 
    %Precitions
    Rxx_1 = A *Rxx*A' + Re; %Rxx will eventually go to zero leaving the variance of the noise
    Ryy_1 = C*Rxx_1*C' + Rw; 
    xtt_1 = A * xtt; 
    
    
    
end
%%
figure(1)
plot(1:N, xsave(1,:), 'r'); 
hold on
plot(1:N, xsave(2,:), 'g'); 
model =[2]; 
lambda = 0.94; 
[ Aest, yhat, covAest, yprev ]= rarx(tar2 , model , 'ff' ,lambda);
figure(2)
plot(Aest)