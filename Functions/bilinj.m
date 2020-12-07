function y=bilinj(A,C,D,e);
% y=bilinj(A,C,D,e);
%
% Simulerar datapunkter från en bilinjär tidsserie given av
% AR-polynom A, MA-polynom C, matris D och brussekvens e.
n=length(e);
[w,v]=size(e);
if v>w
  e=e';
end
p=length(A)-1;
q=length(C);
[m,k]=size(D);
pprim=max([p m k]);
start=max([p q m k]);
AA=[A(2:p+1) zeros(1,pprim-p); eye(pprim-1) zeros(pprim-1,1)];
Cp=[C(2:q); eye(q-2) zeros(q-2,1)];
CC=[C; zeros(pprim-1,q)];
D=[D zeros(m,pprim-k); zeros(pprim-m,pprim)];
e=[zeros(start,1); e];
x=zeros(start,1);
for i=1+start:n+start
   gamlax=flipud(x(i-pprim:i-1));
   gammaltbrus=flipud(e(i-pprim:i-1));
   nyttbrus=flipud(e(i-q+1:i));
   nyax=AA*gamlax+gamlax'*D*gammaltbrus+CC*nyttbrus;
   x(i)=nyax(1);
end

y=x(1+start:n+start);
