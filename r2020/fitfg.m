function [model_parameters, gfpdata, gmtable, fgtest] = fitfg(blkdata, gfpdata)
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
% blkdata: table with the fluorescence measured from empty wells (F_BLK).
% gfpdata: table with the fluorescence measured from wells with
% fluorescein.
%
% OUTPUTS
%
% model_parameters: table with coefficients of the model (F_BLK for each
% gain, b1 and b2).
% gfpdata: gfp table with two additional columns. One is the F_BLK value
% used with each F_obs value to correct the aditive noise effect of the
% medium. The other column is the F_reporter value, but still with the gain
% effect.
% gmtable: table used for the ANOVA on the b1 and b2 coefficients of f_G.
% fgtest: results of the ANOVA.

arguments
    blkdata table
    gfpdata table
end

% First, calculate the F_BLK terms for each gain value
medianFblk = [arrayfun(@(x) ...
    median(blkdata.Fobs(blkdata.Gain == x)),...
    unique(blkdata.Gain)),unique(blkdata.Gain)];
model_parameters = array2table(medianFblk(:,1)');
model_parameters.Properties.VariableNames = strcat("F_BLK (G = ",...
    string(medianFblk(:,2)),")");
% Now, using these values,fit the gain effect model. 
% This model has two parameters to estimate (b_1 and b_2), so three
% fluorescence values at three different gain levels are the minimum 
% amount of data points necessary to fit the model.

fblk = nan(size(gfpdata,1),1);
ug = unique(gfpdata.Gain);
for kg = 1:length(ug)
    fblk(gfpdata.Gain == ug(kg)) = medianFblk(medianFblk(:,2)==ug(kg),1);
end
gfpdata.Fblk = fblk;
gfpdata.Freporter = gfpdata.Fobs - gfpdata.Fblk;

[~,gcfstables] = arrayfun(@(x) samplegainmodel(gfpdata.Fobs(gfpdata.Concentration==x),...
    gfpdata.Fblk(gfpdata.Concentration==x), ...
    unique(gfpdata.Gain(gfpdata.Concentration==x)),...
    gfpdata{gfpdata.Concentration==x,"Well"},...
    gfpdata.Repeat(gfpdata.Concentration==x),2,0),...
    unique(gfpdata.Concentration),'UniformOutput',false);

[uc] = unique(gfpdata.Concentration);
gmtable = vertcat(gcfstables{:,:});
nrep = numel(unique(gfpdata.Repeat));
nwells_conc = numel(unique(gfpdata.Well))/numel(unique(gfpdata.Concentration));
gmtable.Conc = reshape((uc * ones(1, nwells_conc*nrep))', nwells_conc*nrep*length(uc),1);

% ANOVA on coefficients
[~,~,vc] = unique(gmtable.Conc);
[~,~,wc] = unique(gmtable.Sample);
disp( "ANOVA on coefficient b_1 for all levels of concentration")
[fgtest.coefb1.p, fgtest.coefb1.tbl] = anovan(gmtable.coef1,{string(vc), string(wc)},...
    'nested',[0 0;1 0],'varnames',{'Concentration','Well'});
%fig = gcf;
%fig.Name = "ANOVA on coefficient b_1";
disp( "ANOVA on coefficient b_2 for all levels of concentration")
[fgtest.coefb2.p, fgtest.coefb2.tbl] = anovan(gmtable.coef2,{string(vc), string(wc)},...
    'nested',[0 0;1 0],'varnames',{'Concentration','Well'});
%fig = gcf;
%fig.Name = "ANOVA on coefficient b_2";
model_parameters.b1 = median(gmtable.coef1);
model_parameters.b2 = median(gmtable.coef2);

end