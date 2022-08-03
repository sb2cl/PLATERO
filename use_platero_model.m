function [flu_data, valmetrics, vprocv] = use_platero_model(flu_data, ...
    model_parameters, dirdatasave)
arguments
    flu_data
    model_parameters
    dirdatasave string = pwd
end
% First, the gain effect is corrected:
flu_data.Fcorr = gaincorrect(flu_data.Fobs, flu_data.Fblk, flu_data.Gain, ...
    model_parameters.b1, model_parameters.b2);
%% 
% Next, the corrected fluorescence values are converted to concentration values:
flu_data.CPred = flu2conc(flu_data.Fcorr, model_parameters.c0, model_parameters.c1);
%% 
% The following scatterplot shows the predicted concentration values vs. the 
% observed (true) concentrations. As it can be seen, there is a clear match between 
% predictions and real values.

figure('Position', [360 439 472 258]),
plotcalib(flu_data.Concentration,flu_data.CPred,nan,nan);
hold on
plot(0,0,'MarkerFaceColor','none', 'MarkerEdgeColor','none')
xlabel('Observed'),ylabel('Predicted')
title('Predicted vs. Observed Concentration - validation sub set')
%% 
% Next, the MSA is performed on the validation data set. First, the R&R analysis 
% is carried out. For all concentration levels, the variability introduced by 
% the measurement system is less than the "Part-to-Part" variability. This indicates 
% a high repeatability and reproducibility of the measurement system.

%% RR
[~, vprocv] = randr(flu_data.CPred,flu_data.Well,flu_data.Concentration,...
    flu_data.Gain,flu_data.Repeat,1);
figure('Position',[360 458 685 239])
[mdl_sc, lin_comp, bias_comp] = biasanalysis(flu_data.Concentration, ...
    flu_data.CPred,vprocv,1,1,"1/Concentration");
disp(mdl)
%% 
% Finally, using the estimates for the concentration and for the expected uncertainty, 
% Confidence Intervals for the true concentration values, are obtained. 

[LowCI, UpCI] = cipred(flu_data.CPred, model_parameters.sBias, ...
    model_parameters.EDF);
[Percent_in_calrange] = validateci(LowCI, UpCI, flu_data.Concentration);
% Error metrics
% The following metrics express the accuracy of the units conversion procedure, 
% evaluated with the validation data set:

valmetrics.pctgeci = Percent_in_calrange;
valmetrics.mse = mean((flu_data.Concentration - flu_data.CPred).^2);
valmetrics.relerr = abs(flu_data.Concentration - ...
    flu_data.CPred)./flu_data.Concentration;
valmetrics.minrelerror = min(valmetrics.relerr);
valmetrics.maxrelerror = max(valmetrics.relerr);
disp(valmetrics)
%%
figure('Position',[111 276 1027 421]),
ciplots(flu_data, model_parameters.sBias, model_parameters.EDF,linspecer(1))
save(strcat(dirdatasave, 'val_results.mat'), 'valmetrics', 'vprocv')
end