function [c,mdl] = fitfuc(flu,c_true,intercept)
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
% Fits the coefficients of the f_C function with the conversion from
% corrected fluorescence to concentration.
%
% INPUTS
%
% flu: vector with corrected fluorescence values (F real).
% c_pattern: vector with fluorescein pattern concentration values
% (Concentration).
% intercept: optional input indicating if the intercept term of the model
% should be considered or not. Possible values are 1 (with intercept term)
% and 0 (w.o. intercept). Default value set to 0.
%
% OUTPUTS
%
% c: coefficients of the units conversion model.
% mdl: LinearModel object with the information of the calibration
% Fluorescence-Concentration model.

% Measured (flu,x) Real (concpatt,y)

fc = [flu,c_true];
if intercept==0
    mdl = fitlm(fc(:,1),fc(:,2), 'Intercept', false);
else
    mdl = fitlm(fc(:,1),fc(:,2));
end

c = mdl.Coefficients;
end
