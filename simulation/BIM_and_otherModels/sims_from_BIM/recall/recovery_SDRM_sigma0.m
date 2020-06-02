function fit_params_SDRM_sigma0 = recovery_SDRM_sigma0(data,nratings)
% fit SDRM (with sigma_M and sigma_c as 0) to simulated datasets

sampleNum = size(data,3);
fit_params_SDRM_sigma0 = zeros(sampleNum,nratings+1); % fitted SDRM parameters

% start parallel pool
% delete(gcp('nocreate'));
% parpool(10);

for i = 1:sampleNum
    
    observed_data = data(:,:,i);
    
    % fit SDRM
    [nC,nI] = trial2countsCI(observed_data(:,1),observed_data(:,2),nratings);
    fit_params_SDRM_sigma0(i,:) = fit_sdrm_sigma0(nC,nI);
    
end