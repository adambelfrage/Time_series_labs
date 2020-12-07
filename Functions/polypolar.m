function [A]=polypolar(rpolar)
%[A]=polyopolar(rpolar)
%rpolar=[absr1 argr1; absr2 argr2; ... ; absrp argrp]
%A=[1 a1 ... ap]
[A]=poly(konvertera(rpolar));
