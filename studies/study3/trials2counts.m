function [nR_S1, nR_S2] = trials2counts(stimID, response, rating, nRatings, padCells, padAmount)

% [nR_S1, nR_S2] = trials2counts(stimID, response, rating, nRatings, padCells, padAmount)
%
% Given data from an experiment where an observer discriminates between two
% stimulus alternatives on every trial and provides confidence ratings,
% converts trial by trial experimental information for N trials into response 
% counts.
%
% INPUTS
% stimID:   1xN vector. stimID(i) = 0 --> stimulus on i'th trial was S1.
%                       stimID(i) = 1 --> stimulus on i'th trial was S2.
%
% response: 1xN vector. response(i) = 0 --> response on i'th trial was "S1".
%                       response(i) = 1 --> response on i'th trial was "S2".
%
% rating:   1xN vector. rating(i) = X --> rating on i'th trial was X.
%                       X must be in the range 1 <= X <= nRatings.
%
% N.B. all trials where stimID is not 0 or 1, response is not 0 or 1, or
% rating is not in the range [1, nRatings], are omitted from the response
% count.
%
% nRatings: total # of available subjective ratings available for the
%           subject. e.g. if subject can rate confidence on a scale of 1-4,
%           then nRatings = 4
%
% optional inputs
%
% padCells: if set to 1, each response count in the output has the value of
%           padAmount added to it. Padding cells is desirable if trial counts 
%           of 0 interfere with model fitting.
%           if set to 0, trial counts are not manipulated and 0s may be
%           present in the response count output.
%           default value for padCells is 0.
%
% padAmount: the value to add to each response count if padCells is set to 1.
%            default value is 1/(2*nRatings)
%
%
% OUTPUTS
% nR_S1, nR_S2
% these are vectors containing the total number of responses in
% each response category, conditional on presentation of S1 and S2.
%
% e.g. if nR_S1 = [100 50 20 10 5 1], then when stimulus S1 was
% presented, the subject had the following response counts:
% responded S1, rating=3 : 100 times
% responded S1, rating=2 : 50 times
% responded S1, rating=1 : 20 times
% responded S2, rating=1 : 10 times
% responded S2, rating=2 : 5 times
% responded S2, rating=3 : 1 time
%
% The ordering of response / rating counts for S2 should be the same as it
% is for S1. e.g. if nR_S2 = [3 7 8 12 27 89], then when stimulus S2 was
% presented, the subject had the following response counts:
% responded S1, rating=3 : 3 times
% responded S1, rating=2 : 7 times
% responded S1, rating=1 : 8 times
% responded S2, rating=1 : 12 times
% responded S2, rating=2 : 27 times
% responded S2, rating=3 : 89 times


%% sort inputs

% check for valid inputs
if ~( length(stimID) == length(response) && length(stimID) == length(rating) )
    error('stimID, response, and rating input vectors must have the same lengths')
end

% filter bad trials
f = (stimID == 0 | stimID == 1) & (response == 0 | response == 1) & (rating >=1 & rating <= nRatings);
stimID   = stimID(f);
response = response(f);
rating   = rating(f);


% set input defaults
if ~exist('padCells','var') || isempty(padCells)
    padCells = 0;
end

if ~exist('padAmount','var') || isempty(padAmount)
    padAmount = 1 / (2*nRatings);
end


%% compute response counts

nR_S1 = [];
nR_S2 = [];

% S1 responses
for r = nRatings : -1 : 1
    nR_S1(end+1) = sum(stimID==0 & response==0 & rating==r);
    nR_S2(end+1) = sum(stimID==1 & response==0 & rating==r);
end

% S2 responses
for r = 1 : nRatings
    nR_S1(end+1) = sum(stimID==0 & response==1 & rating==r);
    nR_S2(end+1) = sum(stimID==1 & response==1 & rating==r);
end


% pad response counts to avoid zeros
if padCells
    nR_S1 = nR_S1 + padAmount;
    nR_S2 = nR_S2 + padAmount;
end