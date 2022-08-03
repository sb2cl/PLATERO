function blk = checkblk(fblk,gblk,blkdata,report,alpha,plottype)
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
% Checks blank fluorescence values and returns average F BLK for each gain
% level.
%
% INPUTS
%
% fblk: vector with blank fluorescence values (F BLK).
% gblk: vector with gain at which each fblk value was measured (G)
% blkdata: optional table with information about the F BLK values from the
% plate reader. Only necessary if the user asks for the report.
% report: optional input indicating if user wants a report about the
% exluded blank values, printed in the command window. Possible values are
% 1 (report) and 0 (w.o. report). Default value set to 0.
% alpha: type I risk (false positive rate) assumed. Default value set to
% 0.01.
% plottype: char indicating the tpye of data representation, with possible
% values 'boxplot' or 'points'. Default set to boxplot.
%
% OUTPUTS
%
% blk: struct with blank values for each gain level. Fields:
%   - Gain: vector with Gain levels.
%   - mFread: vector with mean F BLK value for each Gain level.
%   - sFread: vector with standard deviation of F BLK values for each Gain
% level.
arguments
    fblk double
    gblk double
    blkdata table
    report double=0
    alpha (1,1)double= 0.01
    plottype = 'boxplot'
end
% Check BLK values
G = unique(gblk);
% Assuming normal distribution for values acquired at same GAIN and 0 conc.
cldata = cell(length(G),1);
pry = cell(length(G),1);
prx = cell(length(G),1);
pky = cell(length(G),1);
blk.Gain = G;
clc

for i = 1:length(G)
    datg = fblk(gblk==G(i));
    [datg_cl,outgid] = normalout(datg,alpha);
    pky{i} = [find(outgid==0), datg_cl];
    prx{i} = i*ones(sum(outgid),1) + unifrnd(-0.1,0.1,sum(outgid),1);
    pry{i} = [find(outgid),datg(outgid)];
    cldata{i} = [datg_cl,G(i)*ones(size(datg_cl,1),1)];
    blk.mFread(i) = mean(datg_cl);
    blk.sFread(i) = std(datg_cl);
    
    if report==1
        blkg = blkdata(gblk==G(i),:);
        disp(strcat("Outliers at G = ",string(G(i)),":"))
        blkg(outgid,:)
        disp(strcat("mean F:",string(blk.mFread(i))))
        disp(strcat("std F:",string(blk.sFread(i))))
        disp("--------------------------------------------------------------")
    end
end

if strcmp(plottype,'points')
    figure('Name','Outliers in BLK values','Position',[50 50 1000 250]),
    for i = 1:length(G)
        sp = subplot(1,length(G),i);
        sp.Position(2) = 0.3;
        sp.Position(4) = 0.6;
        pk = scatter(pky{i}(:,1),pky{i}(:,2),'Marker','o',...
            'MarkerFaceColor','k', 'MarkerFaceAlpha',0.7,...
            'MarkerEdgeColor','none');
        hold on
        pr = scatter(pry{i}(:,1),pry{i}(:,2),'Marker','^',...
            'MarkerFaceColor','r','MarkerEdgeColor','none');
        grid on
        ylim([0,inf]), title(strcat('G',string(G(i))))
        xlabel('Observation'),ylabel('Fluorescence (A.U.)')
        legend([pk(1),pr(1)],{'Accepted points','Outliers with \alpha = 1%'})
        legend('Orientation','Horizontal','Position',[0.4 0.05 0.2 0.05],...
            'FontSize',9)
    end
elseif strcmp(plottype,'boxplot')
    figure('Name','Outliers in BLK values','Position', [360 200 682 382]),
    clmat = cell2mat(cldata);
    xoutmat = cell2mat(prx);
    youtmat = cell2mat(pry);
    boxplot(clmat(:,1), clmat(:,2)),grid on, hold on
    pr = scatter(xoutmat,youtmat(:,2),'Marker','^',...
            'MarkerFaceColor','r','MarkerEdgeColor','none');
    ylim([0, 1.1*max([clmat(:,1);youtmat(:,2)])])
    legend(pr(1),"Outliers with \alpha = 1%")
    legend('Orientation','Horizontal','Location','southoutside',...
        'FontSize',9),
    xlabel('Gain level'),ylabel("Fluorescence (a.u.)"), 
    title('Boxplot of F_b_l_k values by Gain level')
end
    
end