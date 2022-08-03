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
filename = "Fluorescein_random_2020_rows_8rep_one_rep_per_sheet.xlsx";
[~,sheet_name]=xlsfinfo(filename);
datrng = "B102:I197";
VariableNames = {'WellID','Well','Concentration','G50','G60','G70','G80','OD'};
dataPR = table();
for i=1:length(sheet_name)
    d1=readtable(filename,'Sheet',sheet_name{i},'Range',datrng);
    dataPR = [dataPR;d1];
end
dataPR.Properties.VariableNames = VariableNames;
dataPR.Repeat = reshape(repmat(1:8,size(d1,1),1),8*size(d1,1),1);
% Config tables as: F,row,col,conc,gain,repl,repet
datPRnew = tableprep(dataPR,[4:7],[2,3,8,9],[50:10:80]);
my = strsplit(version('-date'),',');
if str2double(my{2})<2020
    datPRnew.Properties.VariableNames{5} = 'Fread';
    datPRnew.Properties.VariableNames{6} = 'Gain';
else
    datPRnew = renamevars(datPRnew,["Y","X"],["Fread","Gain"]);
end
% Split for calibration (5 repetitions) and validation (3 repetitions)
rng(0)
idcal = randperm(8,5);
data_cal = datPRnew(ismember(datPRnew.Repeat,idcal),:);
data_val = datPRnew(~ismember(datPRnew.Repeat,idcal),:);
save('calibration','data_cal')
save('validation','data_val')