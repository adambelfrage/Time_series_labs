
function [R,f]=tspekt(C,A,n)
%[R,f]=spekt(C,A)
%R=[R1 R2 ... Rn]
%f=[f1 f2 ... fn]
%C=[1 c1 ... cq]
%A=[1 a1 ... ap]
%n aer antalet oenskade vaerde

f=linspace(0,0.5,n);
ei=exp(-sqrt(-1)*2*pi*f);
taeljare=polyval(C,ei);
naemnare=polyval(A,ei);
taeljare=taeljare.*conj(taeljare);
naemnare=naemnare.*conj(naemnare);
R=taeljare./naemnare;


