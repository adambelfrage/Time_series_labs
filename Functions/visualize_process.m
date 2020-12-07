function visualize_process(input,n)
if nargin == 1
    n = round(length(input)/4); %Do you really want to round here?
end 
acf_cf = acf(input,n); 
pacf_cf = pacf(input,n); 
subplot(2,2,1)
stem(acf_cf)
title('ACF')
subplot(2,2,3)
stem(pacf_cf)
title('PACF')
subplot(2,2,2)
normplot(acf_cf(2:end))
title('Normplot ACF')
subplot(2,2,4)
normplot(pacf_cf(2:end))
title('Normplot PACF')
end