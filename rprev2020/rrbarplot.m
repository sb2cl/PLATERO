function [ff] = rrbarplot(ybar, upieces, colscale, ff, bs, bw)
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
% Fits the terms of the f_G function with the effect of the gain on the
% fluorescence measurements. It assumes the following exponential gain
% effect: F_real = (F_obs - F_BLK)exp(b1*G + b2*G^2. It fits the
% aforementioned expression using 4 data points of the same well and
% repetition, obtainining "size(gfpdata,1)/gain_levels" models. In order to
% prove the assumptions on the coefficients' consistency, an ANOVA analysis
% is carried out on b1 and b2, studying statistically significant
% differcens between concentrations and wells.
%
% INPUTS
%
% ybar: values with contributions
% upieces: values of concentration levels
% colscale: scale of colours
% ff: handle of the barplot with contributions
% bs: bar 
% bw: bar width
%
% OUTPUTS
%
% ff: handle of the barplot with contributions

if nargins == 3
    ff = [];
    bs = 0.03;
    bw = 0.2;
elseif nargins == 4
    bs = 0.03;
    bw = 0.2;
elseif nargins == 5
    bw = 0.2;
end
nconc = size(ybar,1);
if mod(nconc,2) ~= 0
    xb = [fliplr(1-0.5*bw*(1-mod(nconc,2)): -(bs + bw): 1-0.5*bw*(1-mod(nconc,2))-(bs + bw)*floor(nconc/2)),...
        1+0.5*bw*(1-mod(nconc,2)): (bs + bw): 1+0.5*bw*(1-mod(nconc,2))+(bs + bw)*floor(nconc/2)];
else
    xb = [fliplr(1-(bs + bw)*0.5: -(bs + bw): 1-0.5*(bs + bw)*floor(nconc/2)),...
        1+(bs + bw)*0.5: (bs + bw): 1+0.5*(bs + bw)*floor(nconc/2)];
end
xb = unique(xb);
if isempty(ff)
    ff = figure('Position',[405 342  872 338]);
else
    ff = gcf;
end
bar(xb,ybar(:,2:3),'stacked'), grid on
ff.Children.Position(4) = 0.6;
ff.Children.Position(2) = 0.3;
hold on
bar(xb + 2, ybar(:,4))
ylim([0,130])
xticks([xb,xb+2]),xticklabels(strcat(string(repmat(round(upieces,4),2,1)), " \muM")),
xtickangle(45)
gca.XAxis.Fontsize = 6;
annotation('textbox', [0.2,0.05,0.27,0.1], 'String', ...
    "Measurement System",'EdgeColor','none')
annotation('textbox', [0.6,0.05,0.27,0.1], 'String', ...
    "Part-to-Part (Well)",'EdgeColor','none')
title("Sources of variability"), ylabel('Percent (%)')
legend("Repeat. (Repetition)", "Reprod. (Gain)", "Part-to-Part (Well)", ...
    'Orientation','horizontal','Location','north')
ff.Children(2).Children(1).FaceColor = colscale(1,:);
ff.Children(2).Children(2).FaceColor = colscale(2,:);
ff.Children(2).Children(3).FaceColor = colscale(3,:);

text([xb,xb+2] - bw/2.5, 5+[ybar(:,1);ybar(:,4)],  ...
    strcat(string(round([ybar(:,1);ybar(:,4)], 2)), "%"),'FontSize',9)
end
