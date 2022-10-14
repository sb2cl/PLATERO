%% Plate Reader 2 -- experiment 1
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

filename = "PlateReader2_exp1.xlsx";
colnames = {'WellID','Well','Concentration','G50','G60','G70','G80','G90','G120'};
[dataPR, indgfp] = readexperiment(filename,"A7:I103",[50:10:90,120],false,colnames,0);
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
data_cal_pr2 = [datPRblk; datagfp_cal];
save('calibration_PR2.mat',"data_cal_pr2")
save('validation_PR2.mat',"datagfp_val")
%% Step 2: Model Building step
% Load the calibration subset, fit the model and store the coefficients.

data_cal_pr2 = load("calibration_PR2.mat").data_cal_pr2;
[blk_data, flu_data_PR2e1] = explore_data(data_cal_pr2, 0);
[flu_data_PR2e1, modelPR2e1, calmetrics_PR2e1] = fit_platero_model(blk_data, flu_data_PR2e1,...
    "PR_2e1");
%% Step 3: Model Validation step

datagfp_val = load("validation_PR2.mat").datagfp_val;
uG = unique(flu_data_PR2e1.Gain);
uC = unique(flu_data_PR2e1.Concentration);
data_val_pr2e1 = datagfp_val(ismember(datagfp_val.Gain, uG),:);
G = unique(data_val_pr2e1.Gain);

% Assign the correspoding F_BLK values to each observation F_obs
data_val_pr2e1.Fblk = repmat(modelPR2e1{:,1:4}', size(data_val_pr2e1,1)/length(G),1);

% Run the model on the validation set
[data_val_pr2e1, valmetrics_inrange, vprocv] = use_platero_model(data_val_pr2e1, ...
    modelPR2e1,"PR_2e1");

% Comparison between calibration-set and validation-set metrics
% load(strcat(dirdatasave,'cal_results.mat'))
perftable = table([calmetrics_PR2e1.mse;valmetrics_inrange.mse],...
[calmetrics_PR2e1.minrelerror;valmetrics_inrange.minrelerror]*100,...
[calmetrics_PR2e1.maxrelerror;valmetrics_inrange.maxrelerror]*100,...
'RowNames',{'Calibration', 'Validation (within range)'},...
'VariableNames',{'MSE','Min.Rel.Error (%)','Max.Rel.Error (%)'});
display(perftable)