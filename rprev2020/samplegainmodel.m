function [coeffs, gcfstable] = samplegainmodel(ymeas,yblk,g,sample,reps,order,alpha,plottype)
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
% Fits gain effect correction model with each set of values acquired at
% G_level1,...,G_levelN.
%
% INPUTS
%
% ymeas: vector with fluorescence (F read) values.
% yblk: vector with fluorescence blank (F BLK) values.
% g: vector with gain (G) values.
% sample: vector indicating the sample to which each observation belongs.
% reps: vector indicating the repetition to which each observation belongs.
% order: optional input with the order considered on the epression of the
% exponential term of the gain effect model. Default value set to 2.
% alpha: type I risk (false positive rate) assumed. Default value set to
% 0.01.
% plottype: char indicating the tpye of data representation, with possible
% values 'boxplot' or 'points'. Default set to boxplot.
%
% OUTPUTS
%
% coeffs: struct with the average coefficients of the gain effect model.
% Containing fields:
%   - b1: linear term of the gain effect correction model.
%   - b2: quadratic term of the gain effect correction model.
% gfcstable: table with the fitted terms of the gain effect model for each
% sample.
switch nargin
    case  5
        order = 2;
        alpha = 0.01;
        plottype = 'boxplot';
    case 6
        alpha = 0.01;
        plottype = 'boxplot';
    case  7
        plottype = 'boxplot';
    case 8
        % all input arguments
    otherwise
        error('Missing or unexpected inputs')
end
% Coefficients for gain effect model
usmpl = unique(sample);
Gcoeffs = table();
Name = {};
B = [];
if isa(sample,'cell')
    if isa(sample{1},'double')
        sample = cellfun(@(x) string(x), sample, 'Uniformoutput',0);
    end
elseif isa(sample,'double')
    sample = string(sample);
end
ylog = blkcorr(ymeas,yblk,'log');
for i = 1:length(usmpl)
    ysmple = ylog(strcmp(sample,usmpl{i}));
    repsmple = reps(strcmp(sample,usmpl{i}));
    ureps = unique(repsmple);
    for j = 1:length(ureps)
        Name = [Name; strcat(usmpl{i},'_rep',string(ureps(j)))];
        B = [B; gaincfs(ysmple(repsmple==ureps(j)),g,order)'];
    end
end
Gcoeffs.Name = Name;
Gcoeffs.coef0 = B(:,1);
Gcoeffs.coef1 = B(:,2);
Gcoeffs.coef2 = B(:,3);
% Delete possible NA
Gcoeffs(isnan(table2array(Gcoeffs(:,2))),:) = [];
% Check outlying coefficients
[~,idc1] = normalout(Gcoeffs.coef1,alpha);
[~,idc2] = normalout(Gcoeffs.coef2,alpha);

%%%%%%%%%%% Plot coefficient values %%%%%%%%%%%%%%%
if ~isempty(plottype)
    figure,
    if strcmp(plottype,'points')
        subplot(2,3,1),
        histogram(Gcoeffs.coef1,'b'),grid on,xlabel('b_1'),ylabel('freq.'),
        title('Hisogram b_1')
        subplot(2,3,[2,3])
        scatter(find(idc1==0),Gcoeffs.coef1(~idc1),'Marker','o',...
            'MarkerFaceColor','k', 'MarkerFaceAlpha',0.7,...
            'MarkerEdgeColor','none','HandleVisibility','off');
        grid on,hold on,
        scatter(find(idc1),Gcoeffs.coef1(idc1),'Marker','^',...
            'MarkerFaceColor','r', 'MarkerFaceAlpha',0.7,...
            'MarkerEdgeColor','none');
        legend('Outliers'), legend('boxoff'),
        legend('Location','northwest','FontSize',9),
        xlabel('Index'), title('Values b_1')


        subplot(2,3,4),
        histogram(Gcoeffs.coef2,'b'),grid on,xlabel('b_2'),ylabel('freq.'),
        title('Hisogram b_2')
        subplot(2,3,[5,6])
        scatter(find(idc2==0),Gcoeffs.coef2(~idc2),'Marker','o',...
            'MarkerFaceColor','k', 'MarkerFaceAlpha',0.7,...
            'MarkerEdgeColor','none','HandleVisibility','off');
        grid on,hold on,
        scatter(find(idc2),Gcoeffs.coef2(idc2),'Marker','^',...
            'MarkerFaceColor','r', 'MarkerFaceAlpha',0.7,...
            'MarkerEdgeColor','none');
        legend('Outliers'), legend('boxoff'),
        legend('Location','northwest','FontSize',9),
        title('Values b_2')
    elseif strcmp(plottype,'boxplot')
        subplot(221)
        histogram(Gcoeffs.coef1,'FaceColor','b'),grid on,xlabel('b_1'),ylabel('freq.'),
        title('Hisogram b_1')
        subplot(222)
        boxplot(Gcoeffs.coef1(~idc1));
        grid on,hold on,
        scatter(unifrnd(0.95,1.05,sum(idc2),1), Gcoeffs.coef1(idc1),...
            'Marker','^','MarkerFaceColor','r', 'MarkerFaceAlpha',0.5,...
            'MarkerEdgeColor','none');
        ylim([min(Gcoeffs.coef1)-0.1*abs(range(Gcoeffs.coef1)), ...
            max(Gcoeffs.coef1)+0.1*abs(range(Gcoeffs.coef1))])
        legend('Outliers'), %legend('boxoff'),
        %     legend('Position',[0.65 0.5 0.2 0.05],'FontSize',9)
        legend('Location','northeast','FontSize',9)
        title('Boxplot b_1')

        subplot(223),
        histogram(Gcoeffs.coef2,'FaceColor','b'),grid on,xlabel('b_2'),ylabel('freq.'),
        title('Hisogram b_2')
        subplot(224),
        boxplot(Gcoeffs.coef2(~idc2));
        grid on,hold on,
        scatter(unifrnd(0.95,1.05,sum(idc2),1), Gcoeffs.coef2(idc2),...
            'Marker','^','MarkerFaceColor','r', 'MarkerFaceAlpha',0.5,...
            'MarkerEdgeColor','none');
        ylim([min(Gcoeffs.coef2)-0.1*abs(range(Gcoeffs.coef2)), ...
            max(Gcoeffs.coef2)+0.1*abs(range(Gcoeffs.coef2))])
        legend('Outliers'), %legend('boxoff'),
        %     legend('Position',[0.65 0.01 0.2 0.05],'FontSize',9),
        legend('Location','northeast','FontSize',9)
        title('Boxplot b_2')
    end
end
%%%%%%%%%%% Table for ANOVA on the coefficients %%%%%%%%%%%
[sample_spl1,sample_spl2] = split(Gcoeffs.Name,"_");
Gcoeffs.Sample = sample_spl1(:,1);
for i = 1:length(sample_spl1(:,1))
    splaux = char(sample_spl1(i,2));
    Gcoeffs.Repeat(i) = str2double(splaux(4:end));
end
%%%%%%%%%%% Global coefficients: mean %%%%%%%%%%%
coeffs.b1 = median(Gcoeffs.coef1(~idc1));
coeffs.b2 = median(Gcoeffs.coef2(~idc2));
gcfstable = Gcoeffs((idc1 + idc2) == 0,:);
end