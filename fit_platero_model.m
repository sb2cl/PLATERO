function [flu_data, model_parameters, calmetrics] = fit_platero_model(blk_data, ...
    flu_data, dirdatasave)
arguments
    blk_data
    flu_data
    dirdatasave string = pwd
end
%% Gain effect function ($f_{\textrm{G}}$)
% The function fitfg.m returns the estimated parameters $b_1$ and $b_2$from 
% the previous equation. Moreover, it also returns the output of the ANOVA test 
% on both coefficients for all levels of the concentration. As it can be seen, 
% there are no statistically significant differences between the estimated values 
% for different concentrations. As a result, this validates the assumption that 
% the gain effect is the same for all concentrations being measured by the plate 
% reader. 

[model_parameters, flu_data, gmdata, fgtest] = fitfg(blk_data, flu_data);

% After fitting the gain effect model, the gaincorrect.m function can be used 
% to obtain the corrected fluorescence value for each well of the plate. The following 
% figure represents the relationship between the $F_{\textrm{reporter}}$ (i.e., 
% fluorescence without the gain and medium effect) and the true concentration 
% for each observation in the flu_data table.

flu_data.Fcorr = gaincorrect(flu_data.Fobs, flu_data.Fblk, flu_data.Gain, ...
    model_parameters.b1, model_parameters.b2);


figure('Position',[360 439 472 258]),
plotbyfactor(flu_data.Concentration,flu_data.Fcorr,flu_data.Gain,1,0,0, ...
    'Concentration (uM)','F_{reporter} (A.U)',"Gain")
title('Data processed with gain (exp. model) correction'), 

%% Units Conversion function ($f_{\textrm{UC}}$)

% Using the true concentration and the corrected fluorescence, we can input 
% them to the fitfc.m function to estimate the coefficients of the units conversion 
% model: $C=c_0 +c_1 F_{\textrm{reporter}}$

[c_CF, CFmodel] = fitfuc(flu_data.Fcorr,flu_data.Concentration);
model_parameters.c0 = c_CF{1,1};
model_parameters.c1 = c_CF{2,1};
flu_data.CPred = flu2conc(flu_data.Fcorr, model_parameters.c0, ...
    model_parameters.c1);
%
% The resulting model is shown in the following figure:

figure('Position',[360 439 472 258]),
plotcalib(flu_data.Fcorr,flu_data.Concentration, model_parameters.c0, ...
    model_parameters.c1);

%% Quantify uncertainty in the predictions
% In order to provide an estimate of the uncertainty expected in the predictions, 
% we must check the error or bias of the predictions. In this case, there seems 
% to be a clear heterocedasticity on the residuals. This is indicating a proportional 
% effect of the concentration on the variability of the error values. As it can 
% be seen in the following figure, this can be easily neutralised by scaling the 
% error with the concentration. Thus, the final $s_{\textrm{Bias}}$ estimate is 
% calculated as the standard deviation of the scaled bias (sBiasnorm). 

figure('Position',[360 458 685 239])
[sBias, sBiasnorm, mdlBias, mdlBiasnorm] = quantifyuncertainty( ...
    flu_data.Concentration, flu_data.CPred, "Concentration");
model_parameters.sBias = sBiasnorm;
model_parameters.EDF = mdlBiasnorm.DFE;

disp(model_parameters)
calmetrics.mse = mean((flu_data.Concentration - flu_data.CPred).^2);
calmetrics.relerr = abs(flu_data.Concentration - ...
    flu_data.CPred)./flu_data.Concentration;
calmetrics.minrelerror = min(calmetrics.relerr);
calmetrics.maxrelerror = max(calmetrics.relerr);

save(strcat(dirdatasave, 'cal_results.mat'), 'calmetrics', 'model_parameters')
save(strcat(dirdatasave, 'coefficients.mat'), 'model_parameters')
end