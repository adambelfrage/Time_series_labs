function [simulated_data] = simulateMyARMA(c,a,length_simulated_data)

%length of driving noise sequence
N = 100000;

% unit variance
sigma2 = 1;

% create driving noise
e = sqrt(sigma2)*randn(N,1); 

% simulate the process
output = filter(c,a,e);

% return the last part of the simulated data
simulated_data = output((end-length_simulated_data+1):end);
end

