% Remove the simulated datasets in which performance for all trials is
% the same.
% Run this code after the simulation is finished.

ind=[];
k = size(data,1); % number of simulations

for i=1:k
   if sum(data{i,1})==0 || sum(data{i,2})==0 % performance for all trials is the same
       ind=[ind i];
   end
end

% remove the data and parameters
params(ind,:)=[];
fit_params(ind,:)=[];
data(ind,:)=[];