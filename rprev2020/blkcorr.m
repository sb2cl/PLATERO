function Ycorr = blkcorr(Yflu,Yblk,scale)
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
% Returns fluorescence values corrected by the blank noise.
%
% INPUTS
%
% yflu: vector with fluorescence values (F read).
% yblk: vector with blank values (F BLK).
% scale: optional input with the scale of the output. Options:
% ""(default)|"log"
%
% OUTPUTS
%
% ycorr: vector with corrected values (F reporter).
if nargin == 2
    scale = "";
end
Ycorr = Yflu - Yblk;
if strcmp(scale,"log")
    Ycorr = log(Ycorr);
end
end