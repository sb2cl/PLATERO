%% Plate Reader 1
%% Step 1: data loading and preparation
% Add PLATERO set of functions to your working directory:

my = version('-release');
if str2double(my(1:4))<2020
addpath(genpath('rprev2020'))
else
addpath(genpath('r2020'))
end
%% 
% Now, load the data resulting from the calibration experiment, written in "|filename|". 
% This data is organized by sheets, where each sheet has one repetition of the 
% measurements.

filename = "PlateReader1.xlsx";
colnames = {'WellID','Well','Concentration','G50','G60','G70','G80','OD'};
[dataPR, indgfp] = readexperiment(filename,"B102:I197",50:10:80,false,colnames);
size(dataPR)
%% 
% Divide the dataset into the subset with medium values (|dataPRblk|) and the 
% set with fluorescein values (|dataPRgfp|).

datPRblk = dataPR(~indgfp,:);
datPRgfp = dataPR(indgfp,:);
disp(strcat("This data set has ", string(size(datPRblk,1)),...
" BLK observations and ", string(size(datPRgfp,1)), ...
" GFP observations."))
%% 
% Obtain the partition of the fluorescein dataset into the model building set  
% (70%) and the model validation set (30%). A seed is set to ensure reproducibility 
% of the results. The resulting subsets are stored as the |calibration_PR1.mat| 
% and the |validation_PR1.mat| files.

rng(0207)
[datagfp_cal, datagfp_val] = cvsplit(datPRgfp, 0.7);
disp(strcat("The calibration data set has ", string(size(datagfp_cal,1)),...
" observations and the validation data set has ", ...
string(size(datagfp_val,1)), " observations."))
data_cal_pr1 = [datPRblk; datagfp_cal];
save('calibration_PR1.mat',"data_cal_pr1")
save('validation_PR1.mat',"datagfp_val")
%% Step 2: Model Building step
% Load the calibration subset, fit the model and store the coefficients.

data_cal_pr1 = load("calibration_PR1.mat").data_cal_pr1;
[blk_data, flu_data_PR1] = explore_data(data_cal_pr1, nan);
[flu_data_PR1, modelPR1, calmetrics_PR1] = fit_platero_model(blk_data, flu_data_PR1, "PR_1");
%% Step 3: Model Validation step

datagfp_val = load("validation_PR1.mat").datagfp_val;
uG = unique(flu_data_PR1.Gain);
uC = unique(flu_data_PR1.Concentration);
data_val_pr1 = datagfp_val(ismember(datagfp_val.Gain, uG),:);
G = unique(data_val_pr1.Gain);

% Assign the correspoding F_BLK values to each observation F_obs
data_val_pr1.Fblk = repmat(modelPR1{:,1:4}', size(data_val_pr1,1)/length(G),1);

% Run the model on the validation set
[data_val_pr1, valmetrics_inrange, vprocv] = use_platero_model(data_val_pr1, ...
    modelPR1,"PR_1");

% Comparison between calibration-set and validation-set metrics
% load(strcat(dirdatasave,'cal_results.mat'))
perftable = table([calmetrics_PR1.mse;valmetrics_inrange.mse],...
[calmetrics_PR1.minrelerror;valmetrics_inrange.minrelerror]*100,...
[calmetrics_PR1.maxrelerror;valmetrics_inrange.maxrelerror]*100,...
'RowNames',{'Calibration', 'Validation (within range)'},...
'VariableNames',{'MSE','Min.Rel.Error (%)','Max.Rel.Error (%)'});
display(perftable)