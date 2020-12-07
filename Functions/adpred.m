function adpred(A, predstep, Sigma, N)
% adpred - Recursive estimating and predicting
%
% adpred(A, predstep, Sigma, N)
%
% Simulate N step of a time-serie, Ay=e with standard 
% deviation of e equal to Sigma. Then recursively estimating 
% the parameters in A and predict the process, y, predstep 
% forward. If an argument is left out the standard values
%  A=[1 -1.5 0.7];
%  predstep=1;
%  Sigma=3;
%  N=40;
% is used. Observe that the A polynomial has to be of second order.

% lab4 - lab4 in time series analysis
% exercise 3.3

if(~exist('A') | isempty(A))
  A=[1 -1.5 0.7];
end
if(~exist('predstep') | isempty(predstep))
  predstep=1;
end
if(~exist('Sigma') | isempty(Sigma))
  Sigma=3;
end
if(~exist('N') | isempty(N))
  N=40;
end

% Setup all parameters
clf
%predstep=1;
%N=40;
%Sigma=3;
extra=predstep+5;
%A=[1 -1.5 0.7];

v=ver('ident');


% Simulate the process and start the recursive algorithm
e=Sigma*randn(N+extra, 1);
y=filter(1, A, e);
y=y(extra+1-predstep:end);
yp=zeros(size(y));
[th, yhat, P, phi]=rarx(y(1), 2, 'ff', 1);

% Setup axes for the plots
subplot(3,1,1)
plot(1, th(1,1), '*', 1, th(1,2), '+', [1 N], [A(2) A(2)], 'b', [1 N], [A(3) A(3)], 'g')
hold on
%plot(1, [th(1,1)+1.96*sqrt(P(1,1)) th(1,1)-1.96*sqrt(P(1,1))], 'b.' )
%plot(1, [th(1,2)+1.96*sqrt(P(2,2)) th(1,2)-1.96*sqrt(P(2,2))], 'g.' )
axis([1 N -3 2])
title('Parameter values')
subplot(3,1,2)
plot(1, y(1), '*', 1, 0, '+')
axis([1 N min(y)-Sigma max(y)+Sigma])
title(sprintf('Process value (*) and %d-step prediction (+)', predstep))
hold on
subplot(3,1,3)
axis([1 N 10*Sigma 11*Sigma])
set(gca, 'YScale', 'log')
grid on
title('Mean square prediction error up to step k')
xlabel('Time')
hold on

% Do the iterations.
for k=2:N
  [th, yhat, P, phi]=rarx(y(k), 2, 'ff', 1, th, P, phi);
  if(str2num(v.Version(1))>4)
    yp_tmp=predict(poly2th([1 th],[]), y(1:k+predstep), predstep);
  else
    yp_tmp=predict(y(1:k+predstep), poly2th([1 th],[]), predstep);
  end
  
  yp(k+predstep)=yp_tmp(end);

  subplot(3,1,1)
  plot(k, th(1,1), '*', k, th(1,2), '+')
%  plot(k, [th(1,1)+1.96*sqrt(P(1,1)) th(1,1)-1.96*sqrt(P(1,1))], 'b.' )
%  plot(k, [th(1,2)+1.96*sqrt(P(2,2)) th(1,2)-1.96*sqrt(P(2,2))], 'g.' )
  subplot(3,1,2)
  plot(k, y(k), '*', k+predstep, yp(k+predstep), '+')

  subplot(3,1,3)
  mVar=mean(abs(y(1:k)-yp(1:k)).^2);
  ax=axis;
  if(ax(3)>mVar)
    axis([1 N 0.5*mVar ax(4)])
  end
  if(ax(4)<mVar)
    axis([1 N ax(3) 2*mVar])
  end
  plot(k, mean(abs(y(1:k)-yp(1:k)).^2), '*')
  drawnow
%  pause
end
