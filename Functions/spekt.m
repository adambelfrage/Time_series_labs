function [R,f]=spekt(C,A,n)
%[R,f]=spekt(C,A,n)
%
%  C=[1 c1 ... cq]
%  A=[1 a1 ... ap]
%  n är antalet önskade frekvensvärden.

[H,w]=freqz(C,A,n);
R=H.*conj(H);
f=w/(2*pi);
