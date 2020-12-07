function analyzets(data,M, sigLvl,figNbr,plotZero)
%analyzets Analyze Time Series function plots the basic analysis tools.
%
%   Input:  data is an iddata-object
%           M is the nbr of lags to be displayed
%           sigLvl is the level of significance for the confidence
%           interval, assuming Gaussian distributed data.
%           figNbr is the figure number that should be plotted in


data = iddata(data);
if nargin<5
    plotZero = 1;
end

if nargin<4
    figNbr = 1;
end
if nargin<3
    sigLvl = .05;
end
if nargin<2
    M=40;
end

figure(figNbr)

if isempty(data.u)
    
    y = data.y;
    subplot 311
    acf(y,M, sigLvl, 1, 0, plotZero);
    title('Auto-correlation function (ACF)')
    subplot 312
    pacf(y,M, sigLvl, 1, plotZero);
    title('Partial auto-correlation function (PACF)')
    subplot 313
    normplot(y); %title('Data')
    
else
    
    y = data.y;
    u = data.u;
    
    subplot 411
    acf(y,M, sigLvl, 1, 0, plotZero);
    title('Auto-correlation function (ACF)')
    subplot 412
    pacf(y,M, sigLvl, 1, plotZero);
    title('Partial auto-correlation function (PACF)')
    subplot 413
    signScale = norminv( 1-sigLvl/2, 0, 1 );
    rxy = crosscorr(u,y,M);
    
    stem(-M:M,rxy), title('Cross correlation function'), xlabel('Lag')
    hold on, plot(-M:M, signScale/sqrt(length(u))*ones(1,2*M+1),'--'), hold off
    hold on, plot(-M:M, -signScale/sqrt(length(u))*ones(1,2*M+1),'--'), hold off
    
    if max(abs(rxy))< signScale/sqrt(length(u))
        axis([-M M -1.2*signScale/sqrt(length(u)) 1.2*signScale/sqrt(length(u))])
    end
    subplot 414
    normplot(y)

    
end

end
