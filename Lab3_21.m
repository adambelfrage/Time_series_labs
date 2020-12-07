tar2 = load('tar2.dat'); 
thx = load('thx.dat'); 
subplot(2,1,1)
plot(tar2)
subplot(2,1,2)
plot(thx)

%%
close all
n = 100;
lambda_line = linspace ( 0.85, 1 , n);
ls2 = zeros (n, 1);
for i =1:length(lambda_line)
[ Aest , yhat , CovAest , trash ] = rarx (tar2 ,[2] ,'ff' ,lambda_line(i));
ls2(i) = sum( ( tar2 - yhat ).^2 ) ;
end
plot (lambda_line, ls2 )
%%
model =[2]; 
lambda = 0.94; 
[ Aest, yhat, covAest, yprev ]= rarx(tar2 , model , 'ff' ,lambda);
plot(Aest)