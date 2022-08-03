function [mdl,contlin,meanbias] = biasanalysis(xobs,xpred,varproc,biasnorm,basemodel,xlab)
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
% Bias analysis for a given pair of predicted and observed values. Fits
% a linear regression model of the prediction error, returning the table
% with the information of the coefficients and a figure with the bias at
% each level of the predicted variable.
%
% INPUTS
%
% xobs: vector with observed values.
% xpred: vector with predicted values.
% varproc: matrix with process variability (2nd column) for each
% concentration level (1st column).
% biasnorm: number indicating the regresor of the bias analysis. Possible
% values are 0 (x, dafault value) and 1 (1/x).
% swap
% basemodel: number indicating if the bias and linearity terms should be
% referred to the fitted model (0) or to the basic linear model (1).
% Default value is set to 0.
% xlab: optional label for the horizontal axis. Default value set to "".
%
% OUTPUTS
%
% mdl: LinearModel object with the information of the bias regression
% model.
% contlin: contribution of the linear term from the bias regression model
% to the total variability of the bias.
% meanbias: mean contribution of the bias to the total variability.
%
arguments
   xobs double
   xpred double
   varproc double
   biasnorm (1,1)double=0
   basemodel (1,1)double=0
   xlab {char,string}=""
   
end
Bias = xpred - xobs;
if biasnorm==0
    x = xobs;
    y = Bias;
    ylab = "Bias";
elseif biasnorm==1
    x = 1./(xobs);
    y = Bias./(xobs);
    xlab2 = strsplit(xlab,'/');
    ylab = strcat("Bias/",xlab2{2});
end
mdl = LinearModel.fit(x,y);
unique_value = unique(x);
hold on 
yline(0,'LineStyle',':','Color','Black','LineWidth',0.8);
scatter(x,y,20,'Marker','o','MarkerFaceColor','k',...
    'MarkerFaceAlpha',0.3,'MarkerEdgeColor','none');
for i = 1:length(unique_value)
    scatter(unique_value(i),mean(y(x == unique_value(i))),100,....
        'Marker','sq','MarkerFaceColor','red','MarkerEdgeColor','red');
end
if length(unique_value)<10
    xticks(unique_value);
end
xlabel(xlab);
ylabel(ylab);
xlim([0.8*min(x), 1.1*max(x)])
title('Bias analysis')
grid on

if basemodel==0 % Parameters referenced to the fitted model
    lin = abs(mdl.Coefficients{2,1}*100);
    bias = mdl.Coefficients{1,1}*100;
    contlin = lin*100;
    levbias = nan(length(unique_value),1);
    contbias = nan(length(unique_value),1);
    for k = 1:length(unique_value)
        levbias(k) = abs(mean(y(x == unique_value(k))));
        if biasnorm==1
            varprock = varproc((1./varproc(:,1)) == unique_value(k),2)/(1/unique_value(k));
        elseif biasnorm==0
            varprock = varproc(varproc(:,1) == unique_value(k),2);
        end
        contbias(k) = levbias(k)/varprock*100;
    end
    meanbias = mean(contbias);
elseif basemodel==1 % Parameters referenced to the basic linear model (without scaling)
    lin = abs(mdl.Coefficients{1,1});
    bias = mdl.Coefficients{2,1};
    contlin = lin*100;
    levbias = nan(length(unique_value),1);
    contbias = nan(length(unique_value),1);
    for k = 1:length(unique_value)
        levbias(k) = abs(mean(y(x == unique_value(k)))).* (1/unique_value(k));
        if biasnorm==1
            varprock = varproc((1./varproc(:,1)) == unique_value(k),2);
        elseif biasnorm==0
            varprock = varproc(varproc(:,1) == unique_value(k),2);
        end
        contbias(k) = levbias(k)/varprock*100;
    end
    meanbias = mean(contbias);
end

end

