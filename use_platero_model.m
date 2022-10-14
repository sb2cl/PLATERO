function [flu_data, valmetrics, varRR] = use_platero_model(flu_data, ...
    model_parameters, dirdatasave, nanvalue)
arguments
    flu_data
    model_parameters
    dirdatasave string = pwd
    nanvalue {double,char,string}= nan;
end
% First, the gain effect is corrected:
if isnan(nanvalue)
    ind_obs = ~or(isnan(flu_data.Fobs), flu_data.Fobs<0);
else
    ind_obs = ~or(or(flu_data.Fobs == nanvalue, flu_data.Fobs<0),isnan(flu_data.Fobs));
end
disp(strcat("A ", string(round(sum(~ind_obs)/length(ind_obs)*100, 2)),...
    " % of the observations was missing." ))
flu_data = flu_data(ind_obs,:);
flu_data.Fcorr = gaincorrect(flu_data.Fobs, flu_data.Fblk, flu_data.Gain, ...
    model_parameters.b1, model_parameters.b2);
%% 
% Next, the corrected fluorescence values are converted to concentration values:
flu_data.CPred = flu2conc(flu_data.Fcorr, model_parameters.c0, model_parameters.c1);
%% 
% The following scatterplot shows the predicted concentration values vs. the 
% observed (true) concentrations. As it can be seen, there is a clear match between 
% predictions and real values.
disp("")
disp("Plot the Validation dataset transformed to concentration units: ")
figure('Position', [360 439 472 258]),
plotcalib(flu_data.Concentration,flu_data.CPred,nan,nan);
hold on
plot(0,0,'MarkerFaceColor','none', 'MarkerEdgeColor','none')
xlabel('Observed C_T (\muM)'),ylabel('Predicted $\hat{C}$ ($\mu$M)', 'Interpreter','latex')
title('Predicted vs. Observed Concentration - validation sub set')
%% 
% Next, the MSA is performed on the validation data set. First, the R&R analysis 
% is carried out. For all concentration levels, the variability introduced by 
% the measurement system is less than the "Part-to-Part" variability. This indicates 
% a high repeatability and reproducibility of the measurement system.

%% RR
disp("R&R Analysis: ")
[varRR.abss2, varRR.rels2] = randr(flu_data.CPred,flu_data.Well,flu_data.Concentration,...
    flu_data.Gain,flu_data.Repeat,1);

disp(" ")
disp("B&L Analysis: ")
figure('Position',[360 458 685 239])
[mdl_sc, lin_comp, bias_comp] = biasanalysis(flu_data.Concentration, ...
    flu_data.CPred,varRR.rels2,1,1,"Concentration^{-1}");
disp(mdl_sc)
disp("-------------------------------------------------------------------")
disp("Contribution of model terms to the total bias variability:")
disp(strcat("Bias Model - linear term (%): ", string(round(lin_comp,4)), " %"))
disp(strcat("Bias Model - bias term (%): ", string(round(bias_comp,4)), " %"))
%% 
% Finally, using the estimates for the concentration and for the expected uncertainty, 
% Confidence Intervals for the true concentration values, are obtained. 
disp(" ")
disp("Confidence Intervals and Error metrics: ")
[LowCI, UpCI] = cipred(flu_data.CPred, model_parameters.sBias, model_parameters.EDF);
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
uc = unique(flu_data.Concentration);
for jc = 1:length(uc)
    figure('Position',[111 276 932 236]),
    ciplots(flu_data(flu_data.Concentration == uc(jc),:), ...
        model_parameters.sBias, model_parameters.EDF,linspecer(1))
    save(strcat(dirdatasave, 'val_results.mat'), 'valmetrics', 'varRR')
end
end