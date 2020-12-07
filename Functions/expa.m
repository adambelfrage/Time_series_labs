
function [rgles]=expa(rkomp)
%[rgles]=expand(rkomp)
%rgles=[1 0 0 0 0 0 -1 0 0 0 0 -1]
%rkomp=[1 1;7 -1;12 -1]
[m,n]=size(rkomp);
if rkomp(1,1)==1
   rgles=rkomp(1,2);
else
   rgles=[zeros(1,rkomp(1,1)-1) rkomp(1,2)];
end
for i=2:m
   rgles=[rgles zeros(1,rkomp(i,1)-rkomp(i-1,1)-1) rkomp(i,2)];
end
