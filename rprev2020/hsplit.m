function [datagfp_cal,datagfp_val] = hsplit(data,pctge,factor1,factor2)
% Split data set with n cases in k subsets each one with a certain 
% percentage of the original data set, by factor 1, keeping the balance on
% factor 1. Returns a matrix with k-columns and n-observations, indicating
% in each column with 1s and 0s, which observations should be in each of
% the k-partitions of the dataset. 
if nargin==1
   pctge = 0.7;
   factor1 = 1;
   factor2 = 1;
elseif nargin==2
   factor1 = 1;
   factor2 = 1;
elseif nargin==3
   factor2 = 1;
end
% Separate blank and gfp values
datPRblk = data(isnan(data{:,factor1}),:);
datPRgfp = data(~isnan(data{:,factor1}),:);

aa = [arrayfun(@(x) datPRgfp(datPRgfp{:,factor1}==x,:),...
    unique(datPRgfp{:,factor1}),'UniformOutput',false),...
    num2cell(unique(datPRgfp{:,factor1}))];

uwell = cellfun(@(x) unique(x{:,factor2}), aa(:,1),'UniformOutput',false);
ncal = [cellfun(@numel,uwell),cell2mat(cellfun(@(x) round(pctge*size(x,1)),...
    uwell,'UniformOutput',false)),cell2mat(aa(:,2))];
rng(1101)
selcal = cellfun(@(x,y) x(y),uwell,arrayfun(@(x) randperm(x,round(pctge*x)),...
    ncal(:,1),'UniformOutput',false),'UniformOutput',false);
selcal = string(vertcat(selcal{:}));
idcal = ismember(datPRgfp{:,factor2},selcal);
idval = ~idcal;
datagfp_cal = [datPRblk;datPRgfp(idcal,:)];
datagfp_val = datPRgfp(idval,:);
end