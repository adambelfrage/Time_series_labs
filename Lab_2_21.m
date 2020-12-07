rng (0)
n = 500;
A1 = [1 -0.65];
A2 = [1 0.90 0.78];
C = 1;
B = [0 0 0 0 0.4] ;
e = sqrt (1.5) * randn( n + 100, 1);
w = sqrt(2) * randn(n + 100, 1) ;
A3 = [1  0.5] ;
C3 = [1 -0.3 0.2] ;
u = filter(C3, A3, w) ;
y = filter (C, A1, e ) + filter (B, A2, u );
u = u (101 : end); 
y = y (101 : end);
clear A1 A2 C B e w A3 C3; 
%%
close all
% figure(1)
% visualize_process(u,100)
%model_init = idpoly([1 0],[],[]); % This should also work??
model_init = idpoly([1 0],[],[1 0 0]);
model_armax = pem(u, model_init);
A3 = model_armax.A; 
C3 = model_armax.C; 
u_pw = myFilter(A3, C3, u); 
figure(2)
visualize_process(u_pw)
figure(3)
whitenessTest(u_pw, 0.05)
present(model_armax)
%%
close all
y_pw = myFilter(A3, C3, y); 
M = 40; 
stem(-M:M, crosscorr(u_pw , y_pw ,M)) ;
title ('Crosscorrelationfunction')  
xlabel ('Lag');
hold on
plot(-M:M, 2/ sqrt(length(u_pw)) * ones(1, 2*M+1), '--' )
plot(-M:M, -2/sqrt(length (u_pw)) * ones (1, 2*M+1) , '--' )
hold off
% d = 4, s = 0 , r = 2; 
%%
close all
M2 = 100;
A2 = [1 0 0];
B = [0 0 0 0 1] ;
Mi = idpoly([1],[B], [] , [] , [A2]) ;
Mi.Structure.b.Free = [zeros(1,4) 1]; 
z_pw = iddata (y_pw, u_pw) ;
Mba2 = pem(z_pw, Mi) ;
present(Mba2)
vhat = resid(Mba2, z_pw );
B_hat = Mba2.b; 
A2_hat = Mba2.f; 
figure(1)
visualize_process(vhat.y,100)
figure(2)
stem(-M2:M2, crosscorr(u_pw, vhat.y, M2)) 
hold on
plot(-M2:M2, 2/ sqrt(length(u_pw)) * ones(1, 2*M2+1), '--' )
plot(-M2:M2, -2/sqrt(length (u_pw)) * ones (1, 2*M2+1) , '--' )
hold off
%%
close all
 x_temp = myFilter(B_hat, A2_hat, u);
 y_temp = y(5:end); 
 x = y_temp - x_temp;
 %visualize_process(x)
 model_init = idpoly([1 0 ], [] , [] ) ; 
 model_ar = pem(x, model_init); 
 present(model_ar)
 residual = myFilter(model_ar.a, model_ar.c, x); 
 figure(1)
 visualize_process(residual, 100); 
 figure(2)
 whitenessTest(residual, 0.05)
 %%
close all
M3 = 100; 
A1 = [1 0] ;
A2 = [1 0 0] ;
B = [0 0 0 0 1];
C = []; 
Mi = idpoly(1, B, C, A1, A2);
z = iddata(y, u);
MboxJ = pem(z, Mi) ;
present(MboxJ )
ehat = resid(MboxJ , z);
figure(1)
visualize_process(ehat.y)
figure(2)
whitenessTest(ehat.y)
figure(3)
stem(-M3:M3, crosscorr(u, ehat.y, M3))  
hold on
plot(-M3:M3, 2/ sqrt(length(u)) * ones(1, 2*M3+1), '--' )
plot(-M3:M3, -2/sqrt(length (u)) * ones (1, 2*M3+1) , '--' )
%%


