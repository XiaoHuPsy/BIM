function fit_params_Gamma = recovery_Gamma(data)
% calculate Gamma correlation for simulated datasets

sampleNum = size(data,3);
fit_params_Gamma = zeros(sampleNum,1); % Gamma correlation

for i = 1:sampleNum
    
    observed_data = data(:,:,i);
    
    fit_params_Gamma(i) = gammaCorr(observed_data(:,1),observed_data(:,2));
    
end