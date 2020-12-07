function [pip_i,pip_ii]=filter_uppdat2(pp_i,p_sm,f)
%[pip_i,pip_ii]=filter_uppdat2(pp_i,p_sm,f)
% räknar ut nya filtersannolikheter

slask=ones(length(f),1);
fm=slask*f;
pp_im=(slask*pp_i)';
pip_ii=pp_im.*p_sm.*fm;
psumma=sum(sum(pip_ii));
pip_ii=pip_ii/psumma;
pip_i=sum(pip_ii);

