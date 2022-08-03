function [LowCI, UpCI] = cipred(xpred, se, DF, alpha)
% Copyright (C) 2020 A. Gonzalez Cebrian, J. Borràs Ferris
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
% DESCRIPTION
%
% Calculates lower and upper extremes of confidence intervals for the
% predictions in xpred, at a type I risk of alpha, assuming given values of
% the mean squared error and error degrees of freedom.
%
% INPUTS
%
% xpred: vector with predicted values.
% se: value of the estimated standard deviation of the error.
% edf: value of the error degrees of freedom (edf).
% alpha: optional input indicating the type I risk used to calculate the
% confidence intervals. Default value set to 0.05. Must be between 0 and 1.
%
% OUTPUTS
%
% LowCI: vector with the lower limit of the confidence interval for each
% observation from xpred.
% UpCI: vector with the upper limit of the confidence interval for each
% observation from xpred.
if nargin == 3
    alpha = 0.05;
end
LowCI = zeros(length(xpred), 1);
UpCI = zeros(length(xpred), 1);
for i = 1:length(xpred)
    se2 = se*xpred(i);
    talfa = tinv((1-alpha/2), DF);
    LowCI(i) = xpred(i) - talfa*se2;
    UpCI(i) = xpred(i) + talfa*se2;
end

end

