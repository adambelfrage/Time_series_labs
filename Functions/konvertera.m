function [r]=konvertera(rpolar)
%[r]=konvertera(rpolar)
%rpolar=[absr1 argr1; absr2 argr2; ... ; absrp argrp]
%r=[r1; r2; ... ; rp]
[r]=rpolar(:,1).*(cos(rpolar(:,2))+sqrt(-1)*sin(rpolar(:,2)));
