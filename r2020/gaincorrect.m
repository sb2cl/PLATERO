function ycorr = gaincorrect(ymeas, yblk, gain, b1, b2, scale)
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
% Corrects the fluorescence values (F read) eliminating the blank (F BLK)
% and the gain effect.
%
% INPUTS
%
% ymeas: vector with fluorescence (F read) values.
% yblk: vector with fluorescence blank (F BLK) values.
% gain: vector with gain (G) values.
% b1: linear term of the gain effect correction model.
% b2: quadratic term of the gain effect correction model
% scale: optional string or char indicating the scale of the output fector.
% Possible values are ""(default)|"log".
%
% OUTPUTS
%
% ycorr: vector with the corrected falue of fluorescence (F real) for each
% observation.
arguments
    ymeas double
    yblk double
    gain double
    b1 (1,1)double
    b2 (1,1)double
    scale {string,char}=""
end
gainterm = exp((gain*b1)+(gain.^2)*b2);
ycorr = blkcorr(ymeas,yblk)./gainterm;
if strcmp(scale,"log")
    ycorr = log(ycorr);
end
end