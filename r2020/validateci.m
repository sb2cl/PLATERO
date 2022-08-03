function [Percent_in] = validateci(LowCI, UpCI, x)
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
% Calculates the pertentage of observations whose confidence interval
% (C.I.) contains the true observed value.
%
% INPUTS
%
% LowCI: vector with lower limit of the confidence interval for each
% observation.
% UpCI: vector with upper limit of the confidence interval for each
% observation.
% x: vector with true observed values of each observation.
%
% OUTPUTS
%
% Percent_in: percentage of observations whose C.I.  contains the true
% observed value.
arguments
   LowCI double
   UpCI double
   x double
end
inci = (x >= LowCI).*(x <= UpCI);
Percent_in = (sum(inci)/length(x))*100;
end

