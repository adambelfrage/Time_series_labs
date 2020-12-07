function [output]= myFilter (c,a,input,n)
if nargin == 3
    orders = [length(c) length(a)]; %Start at index length is equal to removing length - 1 samples
    n=max(orders); 
end
output = filter (c, a, input); 
output=output(n:end); 
end
