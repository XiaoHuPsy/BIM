function fit_params_Gamma = recovery_Gamma(data_nR)
% calculate Gamma correlation for simulated datasets

nratings = length(data_nR{1,1})/2;

sampleNum = size(data_nR,1);
fit_params_Gamma = zeros(sampleNum,1); % Gamma correlation

% calculate gamma
for i = 1:sampleNum
    
    % data transformation
    nR_S1 = data_nR{i,1};
    nR_S2 = data_nR{i,2};
    
    nC_rS1 = rot90(nR_S1(1:nratings),2);
    nI_rS1 = rot90(nR_S2(1:nratings),2);
    nC_rS2 = nR_S2(nratings+1:end);
    nI_rS2 = nR_S1(nratings+1:end);
    
    nC = nC_rS1+nC_rS2;
    nI = nI_rS1+nI_rS2;
    
    observed_data = [];
    
    for j = 1:nratings
        observed_data = [observed_data; [j*ones(nC(j),1) ones(nC(j),1)] ];
    end
    
    for j = 1:nratings
        observed_data = [observed_data; [j*ones(nI(j),1) zeros(nI(j),1)] ];
    end
    
    % calculate gamma
    fit_params_Gamma(i) = gammaCorr(observed_data(:,1),observed_data(:,2));
    
end