addpath('Functions')
addpath('data')

clear all 
clc
svedala94 = load('svedala94.mat');
y = svedala94.svedala94;
% plot(y)
% visualize_process(y,100)

A6 = [1 zeros(1,5) -1]; % season z^-6
y_diff = myFilter(A6,1,y);

% visualize_process(y_diff,100)
T = linspace(datenum(1994,1 , 1), datenum(1994, 12, 31), length(y_diff));
% plot(T, y_diff);
datetick('x');

th = armax(y_diff,[2 2]);
th_winter = armax(y_diff(1:540),[2 2]);
th_summer = armax(y_diff(907:1458),[2 2]);

% %present(th_winter)
% present(th)

%%
%th0 = [th_winter.A(2:end) th_winter.C(2:end)]; % initial estimate
th0 = [th_summer.A(2:end) th_summer.C(2:end)]; % initial estimate
[thr , yhat] = rarmax(y_diff,[2 2],'ff',0.999,th0);

subplot (3, 1, 1)
plot(T,y(7:end));
datetick('x')

subplot(3, 1, 2)
plot(thr(:,1:2), 'b') % AR parameter (a1, a2)
hold on
plot(repmat(th_winter.A(2:end),[length(thr) 1]),'b:');
plot(repmat(th_summer.A(2:end),[length(thr) 1]),'r:');
axis tight
hold off

subplot(3, 1, 3)
plot(thr(:,3:end))
hold on
plot(repmat(th_winter.C(2:end),[length(thr) 1]),'b:');
plot(repmat(th_summer.C(2:end),[length(thr) 1]),'r:');
axis tight
hold off

