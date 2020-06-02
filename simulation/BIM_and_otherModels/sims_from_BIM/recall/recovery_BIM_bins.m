function fit_params_BIM = recovery_BIM_bins(data,nratings)
% Fit BIM to simulated datasets

sampleNum = size(data,3);
fit_params_BIM = zeros(sampleNum,4); % fitted BIM parameters

% start parallel pool
% delete(gcp('nocreate'));
% parpool(10);

for i = 1:sampleNum
    
    observed_data = data(:,:,i);
    
    [nC,nI] = trial2countsCI(observed_data(:,1),observed_data(:,2),nratings);
    
    temp1 = fit_bim_bins(nC,nI);

    if abs(temp1(:,4)) > 0.98 % if the estimated value of rho is at edge, use a padding correction to re-estimate the value of rho
        temp1 = fit_bim_bins(nC,nI,1);
    end
    
    fit_params_BIM(i,:) = temp1;
    
end