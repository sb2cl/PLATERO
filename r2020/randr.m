function [s_RandR, varproc_rel, ff] = randr(measurements,replicates,pieces,operary,repeat,allinone,figobj)
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
% Runs a Repeatability and Reproducibility (R&R) analyis. Obtains the
% decomposition of total variability in the different sources, as well as
% bar plots for the variability sources and anova tables for each type of
% piece considering as factors the different sources of variability.
%
% INPUTS
%
% measurements: vector with the response variable measurements. 
% replicates: vector or cell indicating the replicates ID for each 
% observation.
% pieces: vector or cell indicating the piece ID for each observation.
% operary: vectoror cell indicating the operary ID for each observation.
% repeat: vector or cell indicating the repetition ID for each observation.
% allionone: optional number indicating if the bar plots with the
% different sources of variability for each piece, will be all in the same
% figure, or separated. Possible values are 0(different figure, default
% value)|1(same figure).
%
% OUTPUTS
%
% s_RandR: struct with the amount of variability accounted to each source
% for each type of piece. Contains one struct for each piece. The fields 
% for each piece, are:
%   - s2Gain: variability apported by variations in the operary (gain) term.
%   - s2nReplicate: variability apported by  variations in the replicate term.
%   - s2Repeat: variability apported by variations in the repetition term.
%   - Gage: variability apported by the machine (operary + repeat).
%   - VarCont.s2Gain: pctge of variability apported by s2Gain.
%   - VarCont.s2nReplicate: pctge of variability apported by s2nReplicate.
%   - VarCont.s2Repeat: pctge of variability apported by s2Repeat.
%   - VarCont.Gage: pctge of variability apported by Gage.
arguments
    measurements double
    replicates
    pieces
    operary
    repeat
    allinone double=0
    figobj = []
end
% Measurements: CPred
% Replicates: Well
% Pieces: Concentration
% Operary: Gain
% Repeat: Repeat
%
% Numeric factors
vecreplicates = numericifcell(replicates);
vecpieces = numericifcell(pieces);
vecoperary = numericifcell(operary);
vecrepeat = numericifcell(repeat);

upieces = unique(vecpieces);

s_RandR = struct();
c = categorical(["Measurement System", "Repeat", "Reprod (Gain)",...
    "Part-to-Part"]);
c = reordercats(c,string(c));
ybar = [];
varproc_rel = nan(length(upieces),2);
varproc_abs = nan(length(upieces),2);
for i = 1:length(upieces)
    disp(strcat("R & R Analysis on measurements for C = ", string(upieces(i))))
    [~, table, ~] = anovan(measurements(vecpieces == upieces(i)),...
        {vecoperary(vecpieces == upieces(i)), ...
        vecreplicates(vecpieces == upieces(i))}, 'varnames',...
        [strcat("Reprod (Gain), C = (", string(upieces(i)),")"), ...
        strcat("Replicates, C = (", string(upieces(i)),")")]);
    MeanG = table{2, 5};
    MeanR = table{3, 5};
    MeanE = table{4, 5};
    nOperary = length(unique(vecoperary(vecpieces == upieces(i))));
    nReplicate = length(unique(vecreplicates(vecpieces == upieces(i))));
    nRepeat = length(unique(vecrepeat(vecpieces == upieces(i))));
    
    s2Gain = abs(MeanG - MeanE)/(nReplicate * nRepeat);
    s2nReplicate = abs(MeanR - MeanE)/(nOperary * nRepeat);
    s2Repeat = MeanE;
    s_RandR.(strcat("C", string(i))).s2Gain = s2Gain;
    s_RandR.(strcat("C", string(i))).s2nReplicate = s2nReplicate;
    s_RandR.(strcat("C", string(i))).s2Repeat = s2Repeat;
    s_RandR.(strcat("C", string(i))).Gage = (s2Gain+s2Repeat);
    s_RandR.(strcat("C", string(i))).VarCont.s2Gain = ...
        s2Gain/(s2Gain+s2nReplicate+s2Repeat)*100;
    s_RandR.(strcat("C", string(i))).VarCont.s2Replicate = ...
        s2nReplicate/(s2Gain+s2nReplicate+s2Repeat)*100;
    s_RandR.(strcat("C", string(i))).VarCont.s2Repeat = ...
        s2Repeat/(s2Gain+s2nReplicate+s2Repeat)*100;
    s_RandR.(strcat("C", string(i))).VarCont.Gage = ...
        (s2Gain+s2Repeat)/(s2Gain+s2nReplicate+s2Repeat)*100;
    ybar = [ybar;[s_RandR.(strcat("C", string(i))).VarCont.Gage,...
        s_RandR.(strcat("C", string(i))).VarCont.s2Repeat,...
        s_RandR.(strcat("C", string(i))).VarCont.s2Gain,...
        s_RandR.(strcat("C", string(i))).VarCont.s2Replicate]];
    varproc_rel(i,:) = [upieces(i), 6*(sqrt(s2Gain + s2Repeat + s2nReplicate))];
end
colscale = gray(3);
if allinone == 0
    d1 = ceil(sqrt(length(upieces)));
    d2 = ceil(length(upieces)/ceil(sqrt(length(upieces))));
    ff = rrbarplot(ybar, colscale);
    for i = 1:length(upieces)
        subplot(d2,d1,i)
        bar(c, ybar(i,:),'FaceColor',colscale(i,:)),
        xlabel('Components of variation');
        ylabel('Percent.(%)');
        ylim([0, 100]);
        grid on
        title(strcat("C = ", string(upieces(i)), " \muM"))
    end
else
    ff = rrbarplot(ybar, upieces, colscale, figobj);
%     b = bar(c,ybar','FaceColor','flat');
%     for k = 1:size(ybar,1)
%         b(k).CData = colscale(k,:);
%     end
%     xlabel('Components of variation');
%     ylabel('Percent.(%)');
%     ylim([0, 100]);
%     grid on
%     title('Sources of variability')
%     legend(cellstr(strcat("C = ", string(upieces), " uM")),'NumColumns',3)
end

end

% Custom validation function
function [xvec] = numericifcell(x)
if iscell(x)
    [~,~,xvec] = unique(x);
else
    xvec = x;
end
end
