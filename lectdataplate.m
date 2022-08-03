% A. Gonzalez Cebrian, J. Borras Ferris
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
% Script to sort experiment data for a calibration model. 
% Use only if each repetition is stored in one sheet. Otherwise, the excel
% reading must be re-configured.
%
% OUTPUTS
%
% mat files with calibration and validation data sets
%
my = version('-release');
if str2double(my(1:4))<2020
    addpath('rprev2020')
else
    addpath('r2020')
end
filename = "Fluorescein_random_2020_rows_8rep_one_rep_per_sheet.xlsx";
[~,sheet_name]=xlsfinfo(filename);

ct = cellfun(@(x) cell2table(table2cell(readtable(filename,'Sheet',x,...
    'Range',"B102:I197",'ReadVariableNames', false)),'VariableNames',...
    {'WellID','Well','Concentration','G50','G60','G70','G80','OD'}),...
    sheet_name, 'UniformOutput', false)';
dataPR = vertcat(ct{:});
dataPR.Repeat = reshape(repmat(1:8,size(ct{1},1),1),8*size(ct{1},1),1);
% Config tables as: F,row,col,conc,gain,repl,repet
datPRnew = tableprep(dataPR,[4:7],[2,3,8,9],[50:10:80]);

[data_cal, data_val] = hsplit(datPRnew,0.7,"Concentration","Well");
% data_cal size = sum(isnan(datPRnew.Concentration)) + 11*8*4*5
% (blk_values + 11 wells * 8 repetitions * 4 gain levels * 5 concentrations)

% data_val size = 5*8*4*5
% (5 wells * 8 repetitions * 4 gain levels * 5 concentrations)
save('calibration','data_cal')
save('validation','data_val')