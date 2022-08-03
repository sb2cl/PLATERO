function datPRnew = readexperiment(filename,datarange,glevels,readvarnames,varnames)
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
% filename: name of the excel file with the data.
% datarange: char with data range in the excel file.
% glevels: vector with gain levels.
% readvarnames: boolean indicating if variable names should be read. 
% Default set to 'false'.
% varnames: vector with the variable names of the resulting table.
% Recommended to use its default value. 
%
% OUTPUTS
%
% datPRnew: re-arranged table with plate reader measurements.
arguments
   filename {string,char}
   datarange {string,char}
   glevels double
   readvarnames logical = false
   varnames {cell,string,char} = cellstr(['WellID','Well',...
       'Concentration',strcat('G',string(glevels)),'OD'])
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
end