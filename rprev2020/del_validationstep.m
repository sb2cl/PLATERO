% load data and coefficients
load validation
load coefficients
blk_data = data_val(isnan(data_val.Concentration),:);
flu_data = data_val(~isnan(data_val.Concentration),:);
blk = checkblk(blk_data.FLUOR,blk_data.G);
G = unique(flu_data.G);
flu_data.Fblk = repmat(blk.mFLUOR',size(flu_data,1)/length(G),1);
flu_data.Fcorr = gaincorrect(flu_data.FLUOR, flu_data.Fblk, flu_data.G, b1, b2);
flu_data.ConPred00 = concpred(flu_data.Fcorr,c0,c1);

figure,
plotcalib(flu_data.ConPred00,flu_data.Concentration,nan,nan);

flu_data_nomiss = flu_data(~isnan(flu_data.ConPred00),:);
valmetrics.corr = corr(flu_data_nomiss.Concentration,flu_data_nomiss.ConPred00);
valmetrics.mse = mean((flu_data_nomiss.Concentration - flu_data_nomiss.ConPred00).^2);
valmetrics.minerror = min(flu_data.Concentration - flu_data.ConPred00);
valmetrics.maxerror = max(flu_data.Concentration - flu_data.ConPred00);
disp(valmetrics)
