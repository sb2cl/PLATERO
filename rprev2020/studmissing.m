function studmissing(datatable)
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
% Provides a descriptive analysis of the presence of missing data in the
% table.
%
% INPUTS
%
% datatable: table with the data recorded by the plate reader. 
%
% OUTPUTS
%
% barplot with the amount of missing observations for each concentration
% level.
uConc = unique(datatable.Concentration(~isnan(datatable.Concentration)));
[uG,~,catG] = unique(datatable.Gain);
bcols = gray(length(uG)+1);
nmissing = arrayfun(@(x) [x, splitapply(@sum, ...
    isnan(datatable.Fobs(datatable.Concentration == x)),...
    catG(datatable.Concentration == x))'], uConc, 'UniformOutput',false);
nmissing = vertcat(nmissing{:});

figure('Position',[350 380 300 250]),
b = bar(1:size(nmissing,1),nmissing(:,2:length(uG)+1),'FaceColor','flat');
title('Missing values'),
for k = 1:length(b)
    b(k).CData = bcols(k,:);
end
bar(1:size(nmissing,1),nmissing(:,2:length(uG)+1)),title('Missing values'),
grid on, ylabel('Counts'),xlabel('Concentration'),
xticklabels(string(nmissing(:,1))),xtickangle(45)
leg = legend(string(uG),'Location','southoutside','Orientation','Horizontal');
title(leg,"Gain")
end