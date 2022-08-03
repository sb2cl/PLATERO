function [blk_data, flu_data] = explore_data(data_cal)
arguments
    data_cal
end
% Before fitting any expression to model the gain effect on the fluorescence 
% values, it is crucial to assess the existence of missing data. This is quite 
% often when different concentration levels are being used. 
studmissing(data_cal)   
%% 
% As it can be seen, there are missing values at some gains for the two maximum 
% concentration levels. *For these reasons only the concentrations 0.0391, 0.0781 
% and 0.1562 will be used for the calibration purpose.* Thus, the resulting data 
% set has _*11 wells * 8 repetitions * 4 gains * 3 concentration levels = 1056 
% observations*_. 

blk_data = data_cal(isnan(data_cal.Concentration),:);
flu_data = data_cal(~isnan(data_cal.Concentration),:);
flu_data(flu_data.Concentration > 0.3,:) = [];
figure('Position',[360 439 472 258]),
plotbyfactor(flu_data.Concentration,flu_data.Fobs,flu_data.Gain,1,0,...
    0,'Concentration (uM)','F_{observed} (A.U)',"Gain",'Calibration data set')
%% 
% Once we stablished the range of values that will be used for the calibration, 
% we proceed to estimate the _F_BLK_ term. Before doing this, it is a good practice 
% to check for potential outliers. As it can be seen in the figure below, one 
% of the wells without Fluorescein (G6), has extreme values of fluorescence at 
% gains 70 and 80.

figure('Position',[360 456 770 241])
tiledlayout(1,2), nexttile
plotbyfactor(blk_data.Well,blk_data.Fobs,blk_data.Gain,1,0,0.001,...
    'Well','F_{BLK}',"Gain", 'F_{BLK} by Well and Gain')
xtickangle(45)
nexttile
boxchart(blk_data.Gain,blk_data.Fobs),grid on, xlabel('Gain'), 
ylabel('F_{BLK}'), title('F_{BLK} by Gain')
end