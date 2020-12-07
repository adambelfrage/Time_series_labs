function res=rekdet(p,a,s,H,x)

a=-a;
[v,w]=size(x);
if v>w
  x=x';
end

[r,q]=size(a);
n=length(x);
x=[zeros(1,q) x];
psi=reshape([a log(s)']',r*(q+1),1);
res=[reshape(a',r*q,1)' s 0];
pp_ii=zeros(r);
pp_i=filter_start(p,r);
for k=q+1:n+q
  back=fliplr(x(k-q:k-1));
  for j=1:r
    u(j)=res_id([x(k) back],s(j),a(j,:));
    f(j)=fi(u(j))/s(j);
  end
  [pp_i,pp_ii]=filter_uppdat2(pp_i,p,f);
  [maxpi,zeta]=max(pp_i);
  ha=(back'*(pp_i.*u./s))';
  hsigma=(u.*u-1).*pp_i;
  h=reshape([ha hsigma']',r*(q+1),1);
  psi=psi+H*h/(k-q);
  H=(k-q+1)*(H-H*h*h'*H/(k-q+h'*H*h))/(k-q);
  psim=reshape(psi,q+1,r)';
  a=psim(:,1:q);
  s=exp(psim(:,q+1))';
  res=[res; reshape(a',r*q,1)' s zeta];
end
res=[-res(2:n+1,1:4) res(2:n+1,5:7)];


