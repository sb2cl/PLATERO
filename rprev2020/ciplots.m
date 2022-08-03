function ciplots(datatbl,sterror,edf,cicol)
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
% Plot the confidence intervals with a layout distinguishing between
% concentration levels and samples.
%
% INPUTS
% 
% datatbl: table with the data containing the predicted and the true
% values.
% sterror: value of the estimated error standard deviation.
% edf: value of the error degrees of fredom.
% cicol: char or RGB color of the shadowed area for the confidence
% intervals. Default set to 'b'.
%
% OUTPUTS
%
% Figure with as many subplots as concentration levels, with the known
% concentration values and the estimated confidence interval for the
% predictions. Subplots present divided regions for each sample.
if nargin < 4
    cicol = 'b';
end
[sortC,isortC] = sort(datatbl.Concentration,'descend');
%[sortW,isortW] = sort(flu_data.Well,'descend');
flu_datas = datatbl(isortC,:);
uconc = unique(flu_datas.Concentration);
tiledlayout(length(uconc),1)
for uc = 1:length(uconc)
    nexttile,
    flu_conc = flu_datas(flu_datas.Concentration == uconc(uc),:);
    [~,iws] = sort(flu_conc.Well);
    flu_conc = flu_conc(iws,:);
    uwell = unique(flu_conc.Well);
    formattedText = cell(length(uwell),1);
    xaxwell = nan(length(uwell),1);
    plot(flu_conc.Concentration,'k--','Linewidth',0.8,'DisplayName',"C_o_b_s"),
    hold on; grid on;
    for uw = 1:length(uwell)
        ind_uw = find(ismember(flu_conc.Well, uwell(uw)));
        [LowCIs, UpCIs] = cipred(flu_conc.CPred(ind_uw), sterror, edf);
        [Percent_in_uw] = validateci(LowCIs, UpCIs, flu_conc.Concentration(ind_uw));
        if uw == length(uwell)
            fill([ind_uw(1):ind_uw(end), fliplr(ind_uw(1):ind_uw(end))], ...
                [LowCIs', fliplr(UpCIs')], cicol,'FaceAlpha',0.5,...
                'DisplayName',"C.I._9_5_% C_p_r_e_d",'EdgeColor','none');
        else
            fill([ind_uw(1):ind_uw(end), fliplr(ind_uw(1):ind_uw(end))], ...
                [LowCIs', fliplr(UpCIs')], cicol,'FaceAlpha',0.5,...
                'HandleVisibility',"off",'EdgeColor','none');
        end
        formattedText{uw} = {strcat(" Well ", uwell(uw)),...
            strcat(" ", string(Percent_in_uw),"% obs. in C.I.")};
        xaxwell(uw) = prctile(ind_uw,25);
        
    end
    yax = ylim;
    x1coord = 1:length(ind_uw):size(flu_conc,1)';
    xticks(x1coord);
    text(xaxwell,1.04*yax(2)*ones(size(xaxwell)),formattedText)
    ylim([yax(1),1.1*yax(2)])
    title(strcat("Concentration = ", string(uconc(uc))))
     xlabel('Observations');ylabel('Concentration');
end
legend('Location','bestoutside','Orientation','Vertical');
end