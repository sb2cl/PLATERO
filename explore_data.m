function [blk_data, flu_data] = explore_data(data_cal, blkvalue)
arguments
    data_cal
    blkvalue = nan
end
% Before fitting any expression to model the gain effect on the fluorescence 
% values, it is crucial to assess the existence of missing data. This is quite 
% often when different concentration levels are being used. 
disp("Explorative plot of missing data for each concentration level: ")
[c_na, g_na, c_neg, g_neg] = studmissing(data_cal, blkvalue);   
disp(strcat("Concentration(s)", strjoin(string(round(c_na, 4)), ", "), ...
" had missing values"));
disp(strcat("Concentration(s)", strjoin(string(round(c_neg, 4)), ", "), ...
" had negative values"))

disp(strcat("Gain(s)", strjoin(string(round(g_na, 4)), ", "), ...
" had missing values"));
disp(strcat("Gain(s)", strjoin(string(round(g_neg, 4)), ", "), ...
" had negative values"))

if ~isempty([c_na', g_na', c_neg', g_neg'])
    elim_crit = input("Elimination criteria G/C (gain/concentration): ", "s");
end

%% 
% As it can be seen, there are missing values at some gains for the two maximum 
% concentration levels. *For these reasons only the concentrations 0.0391, 0.0781 
% and 0.1562 will be used for the calibration purpose.* Thus, the resulting data 
% set has _*11 wells * 8 repetitions * 4 gains * 3 concentration levels = 1056 
% observations*_. 
if isnan(blkvalue)
    blk_data = data_cal(isnan(data_cal.Concentration),:);
    flu_data = data_cal(~isnan(data_cal.Concentration),:);
else
    blk_data = data_cal(data_cal.Concentration == blkvalue,:);
    flu_data = data_cal(data_cal.Concentration ~= blkvalue,:);
end

if exist("elim_crit","var")
    if or(strcmp(elim_crit, "c"), strcmp(elim_crit, "C"))
        flu_data(ismember(round(flu_data.Concentration, 5),...
            round(unique([c_na', c_neg']), 5)),:) = [];
    elseif or(strcmp(elim_crit, "g"), strcmp(elim_crit, "G"))
        flu_data(ismember(flu_data.Gain, unique([g_na', g_neg'])),:) = [];
        blk_data(ismember(blk_data.Gain, unique([g_na', g_neg'])),:) = [];
    end
end

disp("Explorative plot of the raw F_observed Fluorescein data: ")
figure('Position',[360 439 472 345]),
plotbyfactor(flu_data.Concentration,flu_data.Fobs,flu_data.Gain,1,0,...
    0,'Concentration (\muM)','F_{observed} (A.U)',"Gain",'Calibration data set')
xtickangle(45)
%% 
% Once we stablished the range of values that will be used for the calibration, 
% we proceed to estimate the _F_BLK_ term. Before doing this, it is a good practice 
% to check for potential outliers. As it can be seen in the figure below, one 
% of the wells without Fluorescein (G6), has extreme values of fluorescence at 
% gains 70 and 80.
disp("Explorative plot of the raw F_BLK data: ")
figure('Position',[360 456 770 241])
tiledlayout(1,2), nexttile
plotbyfactor(blk_data.Well,blk_data.Fobs,blk_data.Gain,1,0,0.001,...
    'Well','F_{BLK}',"Gain", 'F_{BLK} by Well and Gain')
legend('Location','bestoutside','Orientation','vertical')
xtickangle(45)
nexttile
boxchart(blk_data.Gain,blk_data.Fobs),grid on, xlabel('Gain'), 
ylabel('F_{BLK}'), title('F_{BLK} by Gain')
end