function [c_na, g_na, c_neg, g_neg] = studmissing(datatable, blkvalue)
arguments
    datatable table
    blkvalue = nan
end
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
if isnan(blkvalue)
    uConc = unique(datatable.Concentration(~isnan(datatable.Concentration)));
else
    uConc = unique(datatable.Concentration(datatable.Concentration ~= blkvalue));
end
[uG,~,catG] = unique(datatable.Gain);
bcols = gray(length(uG)+1);
nmissing = arrayfun(@(x) [x, splitapply(@sum, ...
    or(isnan(datatable.Fobs(datatable.Concentration == x)), ...
    datatable.Fobs(datatable.Concentration == x) == blkvalue),...
    catG(datatable.Concentration == x))'], uConc, 'UniformOutput',false);
nmissing = vertcat(nmissing{:});
c_na = uConc(sum(nmissing(:,2:end), 2) > 0);
g_na = uG(sum(nmissing(:,2:end)) > 0, 1);

nneg =  arrayfun(@(x) [x, splitapply(@sum, ...
    (datatable.Fobs(datatable.Concentration == x)<0),...
    catG(datatable.Concentration == x))'], uConc, 'UniformOutput',false);
nneg = vertcat(nneg{:});
c_neg = uConc(sum(nneg(:,2:end), 2) > 0);
g_neg = uG(sum(nneg(:,2:end)) > 0, 1);

ymax = max([1.05*max([max(nmissing(:,2:length(uG)+1)), max(nneg(:,2:length(uG)+1))]),100]);

figure("Position",[100, 100, 630, 300])
tiledlayout(1,2)
nexttile,
b1 = bar(1:size(nmissing,1),[nmissing(:,2:length(uG)+1)], ...
    'FaceColor','flat');
title('Missing values'),
for k = 1:length(b1)
    b1(k).CData = bcols(k,:);
end
ylim([0,ymax])
grid on, ylabel('Counts'),xlabel('Concentration'),
xticklabels(string(nmissing(:,1))),xtickangle(45)
leg = legend(string(uG),'Location','southoutside', ...
    'Orientation','Horizontal','NumColumns',4);
title(leg, "Gain")

nexttile,
b2 = bar(1:size(nmissing,1),[nneg(:,2:length(uG)+1)], ...
    'FaceColor','flat');
title('Negative values')
for k = 1:length(b1)
    b2(k).CData = bcols(k,:);
end
ylim([0,ymax])
grid on, ylabel('Counts'),xlabel('Concentration'),
xticklabels(string(nmissing(:,1))),xtickangle(45)

%leg.Layout.Tile = "South";


end