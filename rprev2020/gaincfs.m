function B = gaincfs(y,g,order)
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
% Fits gain effect correction model.
%
% INPUTS
%
% y: vector with fluorescence (F reporter) values already corrected by the
% F BLK. 
% g: vector with gain values at which each observation in y was acquired.
% order: optioanl argument with the order of the expression in the exponent
% term of the gain effect correction model. Default value set to 2.
%
% OUTPUTS
%
% B: array with coefficients of the gain effect correction model.
if nargin == 2
    order = 2;
end
B = zeros(order + 1, size(y,2));
vpredict = ones(size(y,1),1);
for i = 1:order
   vpredict = [vpredict,g.^(i)];
end
for i = 1:size(y,2)
    B(:,i) = pinv(vpredict'*vpredict)*(vpredict'*y(:,i));
end

end