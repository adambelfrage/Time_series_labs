% FUNCTION [F, G] = polydiv( C, A, k )
%
% The function computes the polynomial division C = A F + z^{-k} G.
%

% Reference: 
%   "An Introduction to Time Series Modeling" by Andreas Jakobsson
%   Studentlitteratur, 2019
%
function [F, G] = polydiv( C, A, k )

[C,A] = equalLength(C,A);
[F,G] = deconv( conv( [1 zeros(1,k-1)],C ), A);
