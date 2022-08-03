function [xclean,outids] = normalout(x,alpha)
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
% Eliminates outlying observations assuming a normal distribution of the
% variable and a type I risk level of alpha.
%
% INPUTS
%
% x: vector observations.
% alpha: optional argument with the type I risk level assumed to compute 
% the threshold value based on the normal distrbution (i.e.: the false
% positive rate). Default value set to 0.05.
%
% OUTPUTS
%
% xclean: vector with clean observation.
% outids: logical vector indicating outyling observations.
if nargin == 1
    alpha = 0.05;
end
% Normalization
z = (x-mean(x))/std(x);
cout = norminv(1-alpha/2);
outids = abs(z) > cout;
xclean = x(~outids);
end