%% PLATE Reader Operator pipeline
%% Step 1: data loading and preparation
% Add PLATERO set of functions to your working directory:
my = version('-release');
if str2double(my(1:4))<2020
    addpath(genpath('rprev2020'))
else
    addpath(genpath('r2020'))
end
dirdatasave = pwd; % The directory where the database is stored. 
% In this case, the working directory, extracted by the "pwd" command.
%% Step 0: Data read
% Load the experimental data. In this case, the data is in the file :
% "Fluorescein_random_2020_rows_8rep_one_rep_per_sheet.xlsx". 
% The data is organized by sheets. Each sheet has one repetition of the 
% measurements. 
filename = "Fluorescein_random_2020_rows_8rep_one_rep_per_sheet.xlsx";
colstable = "B102:I197";
gainlevels = 50:10:80;
colnames = {'WellID','Well','Concentration','G50','G60','G70','G80','OD'};

[data_cal, datagfp_val] = prep_data(filename,colstable,gainlevels, ...
    colnames);
save('calibration_PR1.mat',"data_cal")
save('validation_PR1.mat',"datagfp_val")
%% Step 1: Model fitting
% load(strcat(pwd,'calibration.mat'))
[blk_data, flu_data] = explore_data(data_cal);
% Fit the units conversion equation (eq. X from paper) and return:
% - the predicted concentration as a new column of flu_data;
% - all model coefficients;
% - metrics evaluating the prediction of the concentration for the
% calibration set
[flu_data, modelPR1, calmetricsPR1] = fit_platero_model(blk_data, flu_data);

%% Step 3: Model Validation
% load(strcat(dirdatasave,'validation.mat'))
% load(strcat(dirdatasave,'coefficients.mat'))
% Now, the coefficients obtained in the model fitting step (shown in the previous 
% table), are used to predict the concentration values from the observed fluorescence 
% values that were not used to fit the model. 

% %%%%%%%%%%%%%%% This code is for the dataset used in the paper %%%%%%%%%%
% %%% The goal is no other than to achieve a table with the following columns:
%
% %%%  F_obs | Gain | F_BLK(G level 1) | ... | F_BLK(G level g)
%
uG = unique(flu_data.Gain);
uC = unique(flu_data.Concentration);
flu_data_val = datagfp_val(ismember(datagfp_val.Gain, uG),:);
G = unique(flu_data_val.Gain);
% Assign the correspoding F_BLK values to each observation F_obs
flu_data_val.Fblk = repmat(modelPR1{:,1:4}', size(flu_data_val,1)/length(G),1);
% %%%%%%%%%%%%%%% End of data preparation step %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
[flu_data_val, valmetrics_inrange, vprocvPR1] = use_platero_model(flu_data_val, modelPR1);

% Comparison between calibration-set and validation-set metrics
load(strcat(dirdatasave,'cal_results.mat'))
perftable = table([calmetrics.mse;valmetrics_inrange.mse],...
    [calmetrics.minrelerror;valmetrics_inrange.minrelerror]*100,...
    [calmetrics.maxrelerror;valmetrics_inrange.maxrelerror]*100,...
    'RowNames',{'Calibration', 'Validation (within range)'},...
    'VariableNames',{'MSE','Min.Rel.Error (%)','Max.Rel.Error (%)'});
display(perftable)
