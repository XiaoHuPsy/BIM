function [nC,nI] = trial2countsCI(conf,performance,nratings)
% [nC,nI] = trial2countsCI(conf,performance,nratings)
%
% Generate the vectors nC and nI from raw data of confidence ratings and
% recall performance. nC and nI can be used in the function fit_bim_bins.
%
% INPUTS:
%
% * conf
% An N-by-1 vector containing the confidence rating in each trial.
% N represents the total number of trials. conf(i) = X when the confidence
% rating on i'th trial was X. X must be in the range 1 <= X <= nratings.
%
% * performance
% An N-by-1 vector containing the recall performance in each trial.
% N represents the total number of trials. performance(i) = 1 when the
% answer was correct on i'th trial. performance(i) = 0 when the answer was
% incorrect on i'th trial.
%
% * nratings
% The total available level of confidence ratings. For example, if subject
% can rate confidence on a scale of 1-4, then nratings = 4. PLEASE NOTE:
% BIM requires nratings to be no less than 3.
%
% OUTPUTS
%
% * nC, nI
% nC is a 1-by-nratings vector containing the number of correctly answered
% trials (i.e., recalled trials) in each level of confidence ratings. nI is
% a 1-by-nratings vector containing the number of incorrectly answered
% trials (i.e., unrecalled trials) in each level of confidence ratings.
%
% e.g., if nC = [11 15 31 56], and nI = [44 37 25 8], then the subject had
% the following response counts:
% correctly answered, confidence = 1 : 11 trials
% correctly answered, confidence = 2 : 15 trials
% correctly answered, confidence = 3 : 31 trials
% correctly answered, confidence = 4 : 56 trials
% incorrectly answered, confidence = 1 : 44 trials
% incorrectly answered, confidence = 2 : 37 trials
% incorrectly answered, confidence = 3 : 25 trials
% incorrectly answered, confidence = 4 : 8 trials

if length(conf) ~= length(performance)
    error('conf and performance must have the same length')
end

nC = zeros(1,nratings);
nI = zeros(1,nratings);

for i = 1:nratings
   nC(i) = sum(conf==i & performance==1);
   nI(i) = sum(conf==i & performance==0);
end