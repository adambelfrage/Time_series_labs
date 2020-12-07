sturup = load('sturup.mat');
svedala = load('svedala.mat'); 
u = sturup.sturup; 
y = svedala.svedala; 
A = [ 1 -1.49 0.57] ;
B = [0 0 0 0.28 -0.26] ;
C = [1] ;
k = 3; 
[Fk, Gk] = polydiv(C, A, k);
[Fhat,Ghat] = polydiv(conv(B,Fk),C, k); %Why fhat zero?
% Ghat = Ghat(1,k+1:end); 
% G_order_hat = length(Ghat)- 1;
% Gk_ = Gk(1,k+1:end); 
% G_order_k = length(Gk) -1; 
u_pred_hat = myFilter(Ghat,C,u); 
y_pred_hat_0 = myFilter(Gk,C, y); 
%false_pred_error = y(5:end) - y_pred_hat_0; 
false_pred_error = y(k + 2:end) - y_pred_hat_0; 
%%
y_pred_hat_0 = y_pred_hat_0(1:end-(k+1)); %For k = 3 why is the difference between y_pred_hat_0 and u_pred_hat_0 4?
y_pred_hat = u_pred_hat + y_pred_hat_0; %y_pred_hat = myFilter(Fhat, 1, u_pred_hat) + myFilter(Ghat, C, u) + myFilter(Gk, C, y)
diff = length(y) - length(y_pred_hat); 
y_pred_hat = y_pred_hat(1:1351); k = 3
%y_pred_hat = y_pred_hat(1:1300); % k = 26; 
y = y(k+1:1350 + k +1 );  % k = 3
%y = y(k+1:1299 + k +1 ); 
pred_error = y - y_pred_hat; 
var_pred_error = var(pred_error); 
var_pred_error_false = var(false_pred_error); 
%% Plotting
close all
figure(1)
plot(y_pred_hat(1:100))
hold on
plot(y(1:100))
hold on
plot(y_pred_hat_0(1:100))
hold on
plot(abs(pred_error(1:100)))
hold on 
plot(abs(false_pred_error(1:100)))
legend( 'Prediction', 'Real outputs', 'False prediction','Prediction error', 'False prediction error')






