function [datPRnew, ind_GFP] = readexperiment(filename,datarange,glevels,...
    readvarnames,varnames,nanvalue)
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
% datPRnew: re-arranged table with plate reader measurements.
% ind_GFP: indices of rows with GFP 
switch nargin
    case 3
        readvarnames = false;
        varnames = cellstr(['WellID','Well',...
       'Concentration',strcat('G',string(glevels)),'OD']);
        nanvalue = nan;
    case 4
        varnames = cellstr(['WellID','Well',...
       'Concentration',strcat('G',string(glevels)),'OD']);
        nanvalue = nan;
    case 5
        nanvalue = nan;
    case 6
    otherwise
        error("More inputs than expected (max. 5) ")
end
        
[~,sheet_name] = xlsfinfo(filename);
ct = cellfun(@(x) cell2table(table2cell(readtable(filename,'Sheet',x,...
    'Range',datarange,'ReadVariableNames',readvarnames)),'VariableNames',...
    varnames),...
    sheet_name, 'UniformOutput', false)';
dataPR = vertcat(ct{:});
% Add the repetition column (each cell from ct belongs to one repetition)
dataPR.Repeat = reshape(repmat(1:8,size(ct{1},1),1),8*size(ct{1},1),1);
% Config table as: F,row,col,conc,gain,repl,repet

gainloc = find(cellfun(@(x) ismember('G',x),dataPR.Properties.VariableNames));
well_conc_od_rep = [find(cellfun(@(x) ismember("Well",x),dataPR.Properties.VariableNames)),...
    find(cellfun(@(x) ismember("Concentration",x),dataPR.Properties.VariableNames)),...
    find(cellfun(@(x) ismember("OD",x),dataPR.Properties.VariableNames)),...
    find(cellfun(@(x) ismember("Repeat",x),dataPR.Properties.VariableNames))];
datPRnew = tableprep(dataPR, gainloc, well_conc_od_rep, glevels);

if isnan(nanvalue)
    ind_GFP = ~isnan(datPRnew.Concentration);
else
    ind_GFP = (datPRnew.Concentration ~= nanvalue);
end

end