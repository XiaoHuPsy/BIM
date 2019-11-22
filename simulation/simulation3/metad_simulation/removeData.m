% Run this code after the simulation is finished.

%% Remove the simulated datasets in which performance for all trials is the same
ind=[];
k = size(data,3); % number of simulations

for i=1:k
   if length(unique(data(:,2,i)))==1 % performance for all trials is the same
       ind=[ind i];
   end
end

% remove the data and parameters
params(ind,:)=[];
fit_params(ind,:)=[];
data(:,:,ind)=[];
fit_params_Metad(ind,:)=[];

%% remove the datasets with infinite meta-d'/d'
ind=[];
k = size(data,3);

for i=1:k
   if abs(fit_params_Metad(i,3))==Inf
       ind=[ind i];
   end
end

% remove the data and parameters
params(ind,:)=[];
fit_params(ind,:)=[];
data(:,:,ind)=[];
fit_params_Metad(ind,:)=[];