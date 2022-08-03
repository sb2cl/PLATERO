% load calibration data
load calibration
blk_data = data_cal(isnan(data_cal.Concentration),:);
flu_data = data_cal(~isnan(data_cal.Concentration),:);
%% Missing values (overflows) check
% We can see that the two highest concentrations present overflow
% meausrement problems:
figure('Name','Missing data in Fluorescence measurents'),
histogram(flu_data.Concentration(isnan(flu_data.Fread))),title('NaNs Fluorescence')
xlabel('Conc.'),ylabel('#NA')
flu_data = flu_data(flu_data.Concentration< 0.3125,:);
%% Check BLK values
blk = checkblk(blk_data.Fread,blk_data.Gain);
% Once outliers have been removed, the mean for each gain level is
% calculated to its further use in the data correction. This assumption can
% be done, once more, based on the normal distribution of the values at the
% same concentration and same gain.
%% Gain effect correction
G = unique(flu_data.Gain);
flu_data.Fblk = repmat(blk.mFread',size(flu_data,1)/length(G),1);
% Fit quadratic model for the Gain effect
[b1, b2, gcfstable] = samplegainmodel(flu_data.Fread,flu_data.Fblk,G,flu_data.Well,flu_data.Repeat);
flu_data.Fcorr = gaincorrect(flu_data.Fread, flu_data.Fblk, flu_data.Gain, b1, b2);
%% Transformation to concentration units
% Fluorescence - Concentration model with intercept term:
[c_CF,CFmodel] = cfcoeff(flu_data.Fcorr,flu_data.Concentration);
c0 = table2array(c_CF(1,1));
c1 = table2array(c_CF(2,1)); 
flu_data.CPred = concpred(flu_data.Fcorr,c0,c1);
% Fluorescence - Concentration model w.o. intercept term (c0_0 = 0):
[c_CF_00,CFmodel_00] = cfcoeff(flu_data.Fcorr,flu_data.Concentration,"off");
c1_0 = table2array(c_CF_00(1,1));
flu_data.CPred00 = concpred(flu_data.Fcorr,0,c1_0);

figure,
subplot(211)
plotcalib(flu_data.Fcorr,flu_data.Concentration,c0,c1);
subplot(212)
plotcalib(flu_data.Fcorr,flu_data.Concentration,0,c1_0);
%% Error metrics
% Correlation between estimated and real concentration
calmetrics.corr = corr(flu_data.Concentration,flu_data.CPred00);
calmetrics.mse = mean((flu_data.Concentration - flu_data.CPred00).^2);
calmetrics.minerror = min(flu_data.Concentration - flu_data.CPred00);
calmetrics.maxerror = max(flu_data.Concentration - flu_data.CPred00);
% Save results
save('coefficients','b1','b2','c0','c1');
