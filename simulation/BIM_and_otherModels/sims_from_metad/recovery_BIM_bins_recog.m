function fit_params_BIM = recovery_BIM_bins_recog(data_nR)
% Fit BIM to simulated datasets

sampleNum = size(data_nR,1);
fit_params_BIM = zeros(sampleNum,8); % fitted BIM parameters and the two parameters (d' and C) in Type I SDT

% start parallel pool
% delete(gcp('nocreate'));
% parpool(10);

for i = 1:sampleNum
    
    nR_S1 = data_nR{i,1};
    nR_S2 = data_nR{i,2};
    
    [temp1,~,~,~,d,C] = fit_bim_bins_recog(nR_S1,nR_S2);
    
    fit_params_BIM(i,:) = [temp1 d C];
    
end