function res=res_id(y,s,koeff)
% res=res_id(y,s,koeff)
% räknar ut residualen m.a.p ett givet Markov tillstånd
arp=[1 -koeff];
res=arp*y'/s;

