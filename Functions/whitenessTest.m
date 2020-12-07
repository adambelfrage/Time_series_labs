% Function whitenessTest( data, significanceLvl, K )
%
% The function performs various whiteness tests. The significance level 
% indicates the likelihood that the signal is white but fails the test 
% (default 5%). The parameter K denotes the number of correlation lags
% used to form the Portmanteau lack-of-fit tests (default K=24).
%

% Reference: 
%   "An Introduction to Time Series Modeling" by Andreas Jakobsson
%   Studentlitteratur, 2013
%
function whitenessTest( data, significanceLvl, K )

if nargin<2,
    significanceLvl = 0.05;
end
if nargin<3,
    K = 24;
end
N = length(data);
n = floor(N/2);
disp( sprintf('Whiteness test with %d%% significance', significanceLvl*100) ) 


% Perform various tests.
[S, Q, chiV] = lbpTest( data, K, significanceLvl );
disp( sprintf('  Ljung-Box-Pierce test: %d (white if %5.2f < %5.2f)', S, Q, chiV) )

[S, Q] = mlTest( data, K, significanceLvl );
disp( sprintf('  McLeod-Li test:        %d (white if %5.2f < %5.2f)', S, Q, chiV) )

[S, Q] = montiTest( data, K, significanceLvl );
disp( sprintf('  Monti test:            %d (white if %5.2f < %5.2f)', S, Q, chiV) )

[ nRatio, confInt ] = countSignChanges( data, 1-significanceLvl );
disp( sprintf('  Sign change test:      %d (white if %4.2f in [%4.2f,%4.2f])', nRatio>confInt(1) & nRatio<confInt(2), nRatio, confInt(1), confInt(2) ) )

[ C_val, x1, x2 ] = plotCumPer( data, significanceLvl, 1 );

