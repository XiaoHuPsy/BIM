% When estimating the correlation between true and fitted values of Mconf
% in each of the 2(stimulus: S1 vs. S2) x 2(response: S1 vs. S2)
% conditions, remove datasets with no trials in the same condition.

% Run this code after the simulation is finished.

k = size(data,3); % number of simulations

ind=ones(k,4);


for i=1:k
    
    data1 = data(:,:,i);
    stim = data1(:,1);
    resp = data1(:,2);
   
    if sum(stim==1 & resp==1) == 0 % no S1 response in trials with S1 stimuli
        ind(i,1) = 0;
    end

    if sum(stim==1 & resp==2) == 0 % no S2 response in trials with S1 stimuli
        ind(i,2) = 0;
    end

    if sum(stim==2 & resp==1) == 0 % no S1 response in trials with S2 stimuli
        ind(i,3) = 0;
    end

    if sum(stim==2 & resp==2) == 0 % no S2 response in trials with S2 stimuli
        ind(i,4) = 0;
    end
   
end

corr(params(find(ind(:,1)),2),fit_params(find(ind(:,1)),2)) % corrected correlation for the Mconf for S1 stimulus with S1 response
corr(params(find(ind(:,2)),3),fit_params(find(ind(:,2)),3)) % corrected correlation for the Mconf for S1 stimulus with S2 response
corr(params(find(ind(:,3)),4),fit_params(find(ind(:,3)),4)) % corrected correlation for the Mconf for S2 stimulus with S1 response
corr(params(find(ind(:,4)),5),fit_params(find(ind(:,4)),5)) % corrected correlation for the Mconf for S2 stimulus with S2 response