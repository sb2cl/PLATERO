function [sBias, sBiasnorm, mdl1, mdl2] = quantifyuncertainty(xobs,xpred,vblename)
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
% Quantifies uncertainty according to the prediction error. Returns normal
% probability plots for the error considering it in normal scale and
% scaling it by the observed values of the variable. If the later option
% presents a better normal probability plot, then this option should be
% considered to estimate the uncertainty in the predictions.
%
% INPUTS
%
% xobs: vector with the observed values.
% xpred: vector with the predicted values.
% vblename: optional argument with variable name, to be included in the
% plots. Default set to "".
%
% OUTPUTS
%
% sBias: standard deviation of the bias.
% sBiasnorm: standard deviation of the bias scaled by the concentration.
% mdl1: linear model fitteg for the bias.
% mdl2:linear model fitteg for the bias scaling by the concentration.
arguments
   xobs double
   xpred double
   vblename {char,string}=""
end
Bias = xpred - xobs;
x = 1./(xobs);
y = Bias./(xobs);
sBias = std(Bias);
sBiasnorm = std(y);
mdl1 = LinearModel.fit(xobs, Bias);

mdl2 = LinearModel.fit(x,y);


subplot(121)
h1 = normplot(mdl1.Residuals.Raw);
h1(1).Color = 'k';
h1(2).LineWidth = 1.2;
h1(3).LineWidth = 1.2;
xlabel('Residuals'),
ylabel('Percent'),
title(strcat("Bias ~",vblename))
grid on
subplot(122)
h2 = normplot(mdl2.Residuals.Raw);
h2(1).Color = 'k';
h2(2).LineWidth = 1.2;
h2(3).LineWidth = 1.2;
xlabel('Residuals');
ylabel('Percent');
title(strcat("Bias/",vblename," ~ 1/",vblename))
grid on

unique_value_obs = unique(xobs);
unique_value = unique(x);
figure('Position',[360 458 685 239]),
subplot(121)
yline(0,'LineStyle',':','Color','Black','LineWidth',0.8);hold on
% boxchart(xobs,Bias)
scatter(xobs,Bias,20,'Marker','o','MarkerFaceColor','k',...
    'MarkerFaceAlpha',0.3,'MarkerEdgeColor','none');hold on
for i = 1:length(unique_value)
    scatter(unique_value_obs(i),mean(Bias(x == unique_value(i))),100,....
        'Marker','sq','MarkerFaceColor','red','MarkerEdgeColor','red');
end
if length(unique_value_obs)<10
    xticks(unique_value_obs);
    xticklabels(string(unique_value_obs));
end
xlabel("Concentration");
ylabel("Bias");
% xlim([0.8*min(xobs), 1.1*max(xobs)])
title('Bias vs. Concentration')
grid on

subplot(122)
yline(0,'LineStyle',':','Color','Black','LineWidth',0.8);hold on
% boxchart(x,y)
scatter(x,y,20,'Marker','o','MarkerFaceColor','k',...
    'MarkerFaceAlpha',0.3,'MarkerEdgeColor','none');hold on
for i = 1:length(unique_value)
    scatter(unique_value(i),mean(y(x == unique_value(i))),100,....
        'Marker','sq','MarkerFaceColor','red','MarkerEdgeColor','red');
end
if length(unique_value)<10
    xticks(unique_value);
    xticklabels(string(unique_value));
end
xlabel("Concentration^{-1}");
ylabel("Bias·Concentration^{-1}");
% xlim([0.8*min(x), 1.1*max(x)])
title('Bias·Concentration^{-1} vs. Concentration^{-1}')

grid on

%%%%%%%%%%%%%%%%%%%%%%%%%%% BIAS for SCALED only

figure('Position',[182 458 865 303])
% Scatter plot
subplot(121)
yline(0,'LineStyle',':','Color','Black','LineWidth',0.8);hold on
scatter(x,y,20,'Marker','o','MarkerFaceColor','k',...
    'MarkerFaceAlpha',0.3,'MarkerEdgeColor','none');hold on
for i = 1:length(unique_value)
    scatter(unique_value(i),mean(y(x == unique_value(i))),100,....
        'Marker','sq','MarkerFaceColor','red','MarkerEdgeColor','red');
end
if length(unique_value)<10
    xticks(unique_value);
    xticklabels(string(unique_value));
end
xlabel("Concentration^{-1}");
ylabel("Bias·Concentration^{-1}");
title('Bias·Concentration^{-1} vs. Concentration^{-1}')
grid on
% Proability Plot
subplot(122)
h2 = normplot(mdl2.Residuals.Raw);
h2(1).Color = 'k';
h2(2).LineWidth = 1.2;
h2(3).LineWidth = 1.2;
xlabel('Residuals');
ylabel('Percent');
title(strcat("Bias/",vblename," ~ 1/",vblename))
grid on
end

