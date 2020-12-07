close all
clear all
temp = load('svedala.mat');
temp = temp.svedala; 
visualize_process(temp)
%%
%remove seasonality 
 A24 =[ 1 zeros(1,23) -1]; 
 temp_s  = myFilter(A24,1,temp); 
 data = iddata(temp_s);
%Estimate according to guessed model 
 model_init = idpoly([1 0 0],[],[]); 
 model_sarima = pem(data, model_init); 
residual = myFilter(model_sarima.A, model_sarima.C, temp_s); 
visualize_process(residual)
%%
data = iddata(temp); 
model_init = idpoly([1 0 0 zeros(1,21) 0 0 0], [], [1 zeros(1,24)]); 
model_init.Structure.c.Free = [zeros(1,24) 1]; 
model_init.Structure.a.Free = [0 1 1 zeros(1,21) 1 1 1]; 
model_sarima = pem(data, model_init); 
residual = myFilter(model_sarima.A, model_sarima.C, temp); 
present(model_sarima) 
 
figure(1)
visualize_process(residual) 
figure(2)
whitenessTest(residual)  
%%
k = 26; 
A = model_sarima.A; 
C = model_sarima.C;
[Fk , Gk] = polydiv(C,A,k);
yhatk = myFilter(Gk, C, temp) ;
driving_noise = myFilter(A, C, temp); 
G_order = length(Gk)- 1;
temp = temp(G_order + 1:end); % first reasonable prediction

est_var_noise = var(driving_noise); 
est_mean = mean(yhatk);
prediction_error = temp - yhatk; 
mean_error = mean(prediction_error); 
var_pred_err_th = (sum(Fk.^2))*est_var_noise;
var_pred_err_est = var(prediction_error);
%% Plotting
plot(temp)
hold on 
plot(yhatk)
%%
visualize_process(prediction_error)


