close all
clear all
temperature = load('svedala.mat');
temperature = temperature.svedala; 
A = [1 -1.79 0.84] ;
C = [1 -0.18 -0.11];
k = 3; 

[Fk , Gk] = polydiv(C,A,k);
Gk = Gk(1,k+1:end); 
G_order = length(Gk)- 1;
C_order = length(C) - 1; 
yhatk = myFilter(Gk, C, temperature) ;
driving_noise = myFilter(A, C, temperature); 
temperature = temperature(max(G_order, C_order) + 1: end); 

%% Driving noise / variance

est_var_noise = var(driving_noise); 
est_mean = mean(yhatk);
prediction_error = temperature - yhatk; 
mean_error = mean(prediction_error); 
var_pred_err_th = (sum(Fk.^2))*est_var_noise;
var_pred_err_est = var(prediction_error);

normplot(prediction_error)
conf_upper = mean_error + 1.96*sqrt(var_pred_err_est);
conf_lower = mean_error - 1.96*sqrt(var_pred_err_est);

sum_outside = sum(prediction_error > conf_upper) + sum(prediction_error < conf_lower); 
percentage = sum_outside/length(prediction_error); 
%% Plotting

figure(1)
plot(temperature,'blue') % removes the first five samples, due to the fact that the first plausible prediction % is made when t = 2 and then 3 predictions forward. 
hold on 
plot(yhatk,'red')
legend('temperature', 'prediction')
figure(2)
visualize_process(prediction_error)










