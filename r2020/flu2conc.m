function conchat = flu2conc(f, c0, c1)
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
% Predicts concentration from corrected fluorescence data.
%
% INPUTS
%
% f: vector with corrected fluorescence vlaues (F real).
% c0: intercept term of the units conversion model.
% c1: slope term of the units conversion model.
%
% OUTPUTS
%
% conchat: vector with predicted values of the concentration (Chat).
arguments
    f double
    c0 (1,1)double
    c1 (1,1)double
end
conchat = f*c1 + c0;
end