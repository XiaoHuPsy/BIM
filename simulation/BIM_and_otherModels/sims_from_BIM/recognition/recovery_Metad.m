function fit_params_Metad = recovery_Metad(data_nR)
% Fit the meta-d' model to simulated datasets

nratings = length(data_nR{1,1})/2;

sampleNum = size(data_nR,1);
fit_params_Metad = zeros(sampleNum,2*nratings+1); % fitted parameters in the meta-d' model

for i = 1:sampleNum
    
    nR_S1 = data_nR{i,1};
    nR_S2 = data_nR{i,2};
    
    % padding correction
    nR_S1 = nR_S1 + 1 / (2*nratings);
    nR_S2 = nR_S2 + 1 / (2*nratings);
    
    
    % fit the meta-d' model
    fit{i,1} = fit_meta_d_MLE(nR_S1, nR_S2);
    fit_params_Metad(i,:) = [fit{i,1}.da fit{i,1}.meta_da fit{i,1}.M_ratio fit{i,1}.t2ca_rS1 fit{i,1}.t2ca_rS2];
    
end