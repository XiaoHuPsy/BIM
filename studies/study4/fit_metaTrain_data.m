function [fit,warning] = fit_metaTrain_data(rawData)
% Fit BIM to metacognitive training data

nratings = 4;

subID = fieldnames(rawData.session_01.abstract);

% define output structures
fit_session_01_abstract = zeros(length(subID),8);
fit_session_01_words = zeros(length(subID),8);
fit_session_10_abstract = zeros(length(subID),8);
fit_session_10_words = zeros(length(subID),8);

warning_session_01_abstract = zeros(length(subID),1);
warning_session_01_words = zeros(length(subID),1);
warning_session_10_abstract = zeros(length(subID),1);
warning_session_10_words = zeros(length(subID),1);

% start parallel pool
% delete(gcp('nocreate'));
% parpool(10);

for subj = 1:length(subID)
    
    % fit model to data for session 1 with abstract
    rawData_sub = getfield(rawData.session_01.abstract,subID{subj});
    [nR_S1, nR_S2] = trials2counts(rawData_sub(:,1)', rawData_sub(:,2)', rawData_sub(:,3)', nratings);
    
    [params,~,~,w,d,C]=fit_bim_bins_recog(nR_S1,nR_S2);
    
    fit_session_01_abstract(subj,:) = [params d C];
    warning_session_01_abstract(subj,:) = w;
    
    % fit model to data for session 1 with words
    rawData_sub = getfield(rawData.session_01.words,subID{subj});
    [nR_S1, nR_S2] = trials2counts(rawData_sub(:,1)', rawData_sub(:,2)', rawData_sub(:,3)', nratings);
    
    [params,~,~,w,d,C]=fit_bim_bins_recog(nR_S1,nR_S2);
    
    fit_session_01_words(subj,:) = [params d C];
    warning_session_01_words(subj,:) = w;
    
    % fit model to data for session 10 with abstract
    rawData_sub = getfield(rawData.session_10.abstract,subID{subj});
    [nR_S1, nR_S2] = trials2counts(rawData_sub(:,1)', rawData_sub(:,2)', rawData_sub(:,3)', nratings);
    
    [params,~,~,w,d,C]=fit_bim_bins_recog(nR_S1,nR_S2);
    
    fit_session_10_abstract(subj,:) = [params d C];
    warning_session_10_abstract(subj,:) = w;
    
    % fit model to data for session 10 with words
    rawData_sub = getfield(rawData.session_10.words,subID{subj});
    [nR_S1, nR_S2] = trials2counts(rawData_sub(:,1)', rawData_sub(:,2)', rawData_sub(:,3)', nratings);
    
    [params,~,~,w,d,C]=fit_bim_bins_recog(nR_S1,nR_S2);
    
    fit_session_10_words(subj,:) = [params d C];
    warning_session_10_words(subj,:) = w;
    
end

% output strcture
fit = struct('session_01',[],'session_10',[]);
fit.session_01 = struct('abstract',fit_session_01_abstract,'words',fit_session_01_words);
fit.session_10 = struct('abstract',fit_session_10_abstract,'words',fit_session_10_words);

warning = struct('session_01',[],'session_10',[]);
warning.session_01 = struct('abstract',warning_session_01_abstract,'words',warning_session_01_words);
warning.session_10 = struct('abstract',warning_session_10_abstract,'words',warning_session_10_words);