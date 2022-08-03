function tablenew = tableprep(tableold,colidsjoin,colidsrep,factorlevels)
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
% Re-arragnes table for its further use with the toolbox functions.
%
% INPUTS
%
% tableold: table with information to be rearranged.
% colidsjoin: vector with indices of the columns in table_old which have to
% be joined in one varible in the new table.
% colidsrep: vector with indices of the columns in table_old which have to
% be repeated in the new table.
% factorlevels: vector with the Gain levels.
%
% OUTPUTS
%
% tablenew: re-arranged table.
arguments
   tableold table
   colidsjoin double
   colidsrep double
   factorlevels double
end
factlev = length(colidsjoin);
arrtable_join = table2array(tableold(:,colidsjoin))';
arrtable_repeat = repelem(tableold(:,colidsrep),factlev,1);
vectortable = reshape(arrtable_join,factlev*size(tableold,1),1);
factor = repmat(reshape(factorlevels,factlev,1),size(tableold,1),1);

tablenew = arrtable_repeat;
tablenew.Fobs = vectortable;
tablenew.Gain = factor;
end