function [data_cal, data_val, idcal] = cvsplit(dataset,calpctge)
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
% Provides partition of the data set into a calibration and a validation
% data sub sets. The selection is done on the wells variable, keeping all
% the gains and repetitions of a certain well as part of the training or
% the validation. Both subsets are exluding (they do not repeat wells). The
% calibration percentage is applied stratifying in each concentration.
%
% INPUTS
%
% dataset: table with complete data set.
% calpctge: percentage (0 to 1) of observations to be part of the
% calibration data set.
%
% OUTPUTS
%
% data_cal: table with calibration data set.
% data_val: table with validation data set.
% idcal: index of calibration observations, referred to the original data
% set.
%

aa = arrayfun(@(x) dataset(dataset{:,"Concentration"} == x,:),...
    unique(dataset{:,"Concentration"}),'UniformOutput',false);
aa = [aa,num2cell(unique(dataset{:,"Concentration"}))];

uwell = cellfun(@(x) unique(x.Well), aa(:,1),'UniformOutput',false);
ncal = [cellfun(@numel,uwell),cell2mat(cellfun(@(x) ...
    round(calpctge*size(x,1)),uwell,'UniformOutput',false)),cell2mat(aa(:,2))];
selcal = cellfun(@(x,y) x(y),uwell,arrayfun(@(x) ...
    randperm(x,round(calpctge*x)),ncal(:,1),'UniformOutput',false),...
    'UniformOutput',false);
selcal = string(vertcat(selcal{:}));
idcal = ismember(dataset{:,"Well"},selcal);
idval = ~idcal;
data_cal = dataset(idcal,:);
data_val = dataset(idval,:);

end