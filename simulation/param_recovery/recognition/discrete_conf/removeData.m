% When estimating the correlation between true and fitted values of Mconf
% in each of the 2(stimulus: S1 vs. S2) x 2(response: S1 vs. S2)
% conditions, remove datasets with no trials in the same condition.

% Run this code after the simulation is finished.

k = size(data_nR,1); % number of simulations

ind=ones(k,4);


for i=1:k
    
    nR_S1 = data_nR{i,1};
    nR_S2 = data_nR{i,2};
   
    if sum(nR_S1(1:nratings)) == 0 % no S1 response in trials with S1 stimuli
        ind(i,1) = 0;
    end

    if sum(nR_S1(nratings+1:end)) == 0 % no S2 response in trials with S1 stimuli
        ind(i,2) = 0;
    end

    if sum(nR_S2(1:nratings)) == 0 % no S1 response in trials with S2 stimuli
        ind(i,3) = 0;
    end

    if sum(nR_S2(nratings+1:end)) == 0 % no S2 response in trials with S2 stimuli
        ind(i,4) = 0;
    end
   
end

corr(params(find(ind(:,1)),2),fit_params(find(ind(:,1)),2)) % corrected correlation for the Mconf for S1 stimulus with S1 response
corr(params(find(ind(:,2)),3),fit_params(find(ind(:,2)),3)) % corrected correlation for the Mconf for S1 stimulus with S2 response
corr(params(find(ind(:,3)),4),fit_params(find(ind(:,3)),4)) % corrected correlation for the Mconf for S2 stimulus with S1 response
corr(params(find(ind(:,4)),5),fit_params(find(ind(:,4)),5)) % corrected correlation for the Mconf for S2 stimulus with S2 response