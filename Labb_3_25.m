addpath('Functions')
addpath('data')

clear all 
clc
svedala94 = load('svedala94.mat');
y = svedala94.svedala94(850:1100);


t = (1:length(y))';
U = [sin(2*pi*t/6) cos(2*pi*t/6)]; % changing the season results in sin/cos with higher frequency.
Z = iddata(y, U);
model = [3 [1 1] 4 [0 0]]; %[na[nb_1 nb_2] nc [nk_1 nk_2 ]]
thx = armax(Z,model); % coefficients for cos and sine

plot(U*cell2mat(thx.b)', 'b')
hold on 
%plot(y - mean(y),'r' )
%plot(y - U*cell2mat(thx.b)' - mean(y),'r' )

Y_season = y - U*cell2mat(thx.b)' - mean(y); % removed season and mean
visualize_process(Y_season); % the season is not very well modeled by the sin/cos signal

%%
U = [sin(2*pi*t/6) cos(2*pi*t/6) ones(size(t))];
Z = iddata(y, U);
m0 = [thx.A(2:end) cell2mat(thx.B) 0 thx.C(2:end)];
Re = diag([0 0 0 0 0 1 0 0 0 0]);
model=[3 [1 1 1] 4 0 [0 0 0] [1 1 1]];
[thr , yhat] = rpem(Z, model, 'kf', Re, m0);
%%
m = thr(:,6);
a = thr(end,4);
b = thr(end,5);
y_mean = m+a*U(:,1)+b*U(:,2);
y_mean = [0;y_mean(1:end-1)];

plot(y - mean(y))
hold on
plot(y_mean)
hold on
plot(thr(:,6),'m')
%% LAST TASK
clear all
clc

svedala94 = load('svedala94.mat');
y = svedala94.svedala94;
% plot(y)
% hold on
% y = y-y(1);
% plot(y)

y = y-y(1);
t = (1:length(y))';
U = [sin(2*pi*t/6) cos(2*pi*t/6)]; % changing the season results in sin/cos with higher frequency.
Z = iddata(y, U);
model = [3 [1 1] 4 [0 0]]; %[na[nb_1 nb_2] nc [nk_1 nk_2 ]]
thx = armax(Z,model); % coefficients for cos and sine

U = [sin(2*pi*t/6) cos(2*pi*t/6) ones(size(t))];
Z = iddata(y, U);
m0 = [thx.A(2:end) cell2mat(thx.B) 0 thx.C(2:end)];
Re = diag([0 0 0 0 0 0.15 0 0 0 0]);
model=[3 [1 1 1] 4 0 [0 0 0] [1 1 1]];
[thr , yhat] = rpem(Z, model, 'kf', Re, m0);

m = thr(:,6);
a = thr(end,4);
b = thr(end,5);
% y_recreated = m+a*U(:,1)+b*U(:,2);
y_recreated = m+1*U(:,1)+1*U(:,2);
y_recreated = [0;y_recreated(1:end-1)];

plot(y, 'b')
hold on
plot(y_recreated, 'g')
hold on
plot(thr(:,6),'m')
legend('y', 'recreated', 'varying mean')


