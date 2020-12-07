clear all
close all
load ( 'tork.dat')
tork = tork - repmat(mean(tork), length(tork),1) ;
y = tork (:,1) ;
u = tork (:,2) ;
z = iddata(y,u) ;
%plot(z(1:300))
figure(1)
visualize_process(y)
figure(2)
visualize_process(u)
%% Pre - whitening input % output
close all
A3 = [1 0]; 
C3 = []; 
model_init =idpoly([A3, [], C3]); 
model_ar = pem(u,model_init);
A3 = model_ar.a; 
C3 = model_ar.c;
u_pw = myFilter(A3, C3, u); 
whitenessTest(u_pw)
visualize_process(u_pw)
y_pw = myFilter(A3, C3, y); 
%% Checking cross-correlation 
close all
M = 40; 
stem(-M:M, crosscorr(u_pw , y_pw ,M)) ;
title ('Crosscorrelationfunction')  
xlabel ('Lag');
hold on
plot(-M:M, 2/ sqrt(length(u_pw)) * ones(1, 2*M+1), '--' )
plot(-M:M, -2/sqrt(length (u_pw)) * ones (1, 2*M+1) , '--' )
hold off
%%
z_pw = iddata(y_pw, u_pw) ;
A2 = [1 0]; 
B = [0 0 0 1 0 0 0];
model_init = idpoly([1],[B], [] , [] , [A2]) ;
model_init.Structure.b.Free = [zeros(1,3) 1 1 1 1]; 
Mba2 = pem(z_pw, model_init);
present(Mba2)
vhat = resid(Mba2, z_pw );
%vhat = y_pw - my
B_hat = Mba2.b; 
A2_hat = Mba2.f; 
figure(1)
visualize_process(vhat.y,100)
figure(2)
stem(-M:M, crosscorr(u_pw, vhat.y, M)) 
hold on
plot(-M:M, 2/ sqrt(length(u_pw)) * ones(1, 2*M+1), '--' )
plot(-M:M, -2/sqrt(length (u_pw)) * ones (1, 2*M+1) , '--' )
hold off

%%
close all
x_temp = myFilter(B_hat, A2_hat, u);
y_temp = y(length(y)-length(x_temp)+1:end); 
x = y_temp - x_temp;
%visualize_process(x,20)
A1 = [1 0]; 
C1 = [];
model_init = idpoly(A1, [], C1); 
model_ar = pem(x, model_init); 
present(model_ar)
A1_hat = model_ar.a;
C1_hat = model_ar.c;
residual = myFilter(A1_hat,C1_hat,x); 
figure(1)
visualize_process(residual); 
figure(2)
whitenessTest(residual); 
%%
close all
A1 = [1 0] ;
A2 = [1 0] ;
B = [0 0 0 1 0 0 0];
C = []; 
model_init = idpoly(1, B, C, A1, A2);
z = iddata(y, u);
MboxJ = pem(z, model_init) ;
present(MboxJ )
ehat = resid(MboxJ , z);
figure(1)
visualize_process(ehat.y)
figure(2)
whitenessTest(ehat.y)
figure(3)
stem(-M:M, crosscorr(u, ehat.y, M))  
hold on
plot(-M:M, 2/ sqrt(length(u)) * ones(1, 2*M+1), '--' )
plot(-M:M, -2/sqrt(length (u)) * ones (1, 2*M+1) , '--' )
hold off
figure(4)
normplot(crosscorr(u,ehat.y,M))





