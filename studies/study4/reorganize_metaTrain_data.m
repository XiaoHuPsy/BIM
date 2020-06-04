function [info,rawData] = reorganize_metaTrain_data(analysis)
% reorganize the metacognitive training data

subID = fieldnames(analysis);

% define output structures for info
info = cell(length(subID)+1,3);
info(1,:) = [{'subID'} {'group'} {'trainedStim'}]; % titles

% define output structures for rawData
rawData = struct('session_01',[],'session_10',[]);
rawData.session_01 = struct('abstract',[],'words',[]);
rawData.session_10 = struct('abstract',[],'words',[]);

for subj = 1:length(subID)
    
    % output subject ID
    info(subj+1,1) = subID(subj);
    
    % extract data structure for subject
    subData = getfield(analysis,subID{subj});
    
    % output group info
    info{subj+1,2} = subData.group;
    
    % output info for trained stimulus
    if isequal(subData.session_01.memory.abstract.nR_S1,subData.session_01.memory.trained.nR_S1) && isequal(subData.session_01.memory.abstract.nR_S2,subData.session_01.memory.trained.nR_S2)
        info{subj+1,3} = 'abstract';
    elseif isequal(subData.session_01.memory.abstract.nR_S1,subData.session_01.memory.untrained.nR_S1) && isequal(subData.session_01.memory.abstract.nR_S2,subData.session_01.memory.untrained.nR_S2)
        info{subj+1,3} = 'words';
    end
    
    % extract data for session 1 with abstract
    subData_session = subData.session_01.memory.abstract;
    
    trialData = [subData_session.stimID subData_session.resp subData_session.confResp];
    rtData = [subData_session.rt subData_session.confRT];
    
    trialNaN = sum(isnan(trialData),2)>0;
    rtNaN = sum(isnan(rtData),2)>0;
    
    nanInd = trialNaN | rtNaN;
    trialData(nanInd,:) = [];
    
    rawData.session_01.abstract = setfield(rawData.session_01.abstract,subID{subj},trialData);
    
    % extract data for session 1 with words
    subData_session = subData.session_01.memory.words;
    
    trialData = [subData_session.stimID subData_session.resp subData_session.confResp];
    rtData = [subData_session.rt subData_session.confRT];
    
    trialNaN = sum(isnan(trialData),2)>0;
    rtNaN = sum(isnan(rtData),2)>0;
    
    nanInd = trialNaN | rtNaN;
    trialData(nanInd,:) = [];
    
    rawData.session_01.words = setfield(rawData.session_01.words,subID{subj},trialData);
    
    % extract data for session 10 with abstract
    subData_session = subData.session_10.memory.abstract;
    
    trialData = [subData_session.stimID subData_session.resp subData_session.confResp];
    rtData = [subData_session.rt subData_session.confRT];
    
    trialNaN = sum(isnan(trialData),2)>0;
    rtNaN = sum(isnan(rtData),2)>0;
    
    nanInd = trialNaN | rtNaN;
    trialData(nanInd,:) = [];
    
    rawData.session_10.abstract = setfield(rawData.session_10.abstract,subID{subj},trialData);
    
    % extract data for session 10 with words
    subData_session = subData.session_10.memory.words;
    
    trialData = [subData_session.stimID subData_session.resp subData_session.confResp];
    rtData = [subData_session.rt subData_session.confRT];
    
    trialNaN = sum(isnan(trialData),2)>0;
    rtNaN = sum(isnan(rtData),2)>0;
    
    nanInd = trialNaN | rtNaN;
    trialData(nanInd,:) = [];
    
    rawData.session_10.words = setfield(rawData.session_10.words,subID{subj},trialData);
    
end