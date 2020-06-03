function [err,max_X0] = bim_error_genX0(params,observed_data)
% error function for BIM applied to recall tasks with continuous
% confidence. This function can generate X0 for each trial.

%% get data and parameters
% parameters
Pexp = params(1);
Mconf = params(2);
mu_m = params(3);
rho = params(4);

% data
conf = observed_data(:,1);
rec = observed_data(:,2);

ntrial = length(conf);

%% set bound for parameters
if rho < -0.99
    err=100000;
    return
elseif rho > 0.99
    err=100000;
    return
end

if Pexp < 0.01
    err=100000;
    return    
elseif Pexp > 0.99
    err=100000;
    return 
end

if Mconf < 0.01
    err=100000;
    return    
elseif Mconf > 0.99
    err=100000;
    return 
end

if mu_m < -5
    err=100000;
    return    
elseif mu_m > 5
    err=100000;
    return 
end

%% parameter transform

sigmaj = sqrt(1/Pexp-1);
wavg = norminv(Mconf)*sqrt(1+sigmaj^2+1/(sigmaj^2));

a = 1/(sigmaj*sqrt(sigmaj^2+1));
b = wavg/sqrt(sigmaj^2+1);

%% create grid for x0
count=100;  % steps in grid
lb_x0 = -5; % lower bound for x0
ub_x0 = 5; % upper bound for x0

rx0 = (ub_x0-lb_x0)./(count-1);

X0 = lb_x0:rx0:ub_x0;

X0 = repmat(X0,[ntrial,1]);

%% calculate normal pdf for grid
npdf=rx0.*normpdf(X0);


%% calculate log likelihood and prediction for each trial

lik_rec = (1-normcdf(-mu_m,rho*X0,sqrt(1-rho^2)));

conf_new = repmat(conf,[1,count]);
rec_new = repmat(rec,[1,count]);
    
grid_loglik = npdf.* normpdf(conf_new/100,normcdf(X0.*a+b),0.025).*(rec_new.*lik_rec+(1-rec_new).*(1-lik_rec));
loglik = log(sum(grid_loglik,2));

err = (-1)*sum(loglik); % sum of negative log likelihood

%% generate X0 value for each trial
max_grid_loglik = max(grid_loglik,[],2);

max_grid_loglik = repmat(max_grid_loglik,[1,size(X0,2)]);

maxInd = (grid_loglik == max_grid_loglik);

[maxIndRow,maxIndCol] = find(maxInd);

[maxIndRow,IA,~] = unique(maxIndRow);

maxIndCol = maxIndCol(IA);

max_X0 = X0(sub2ind(size(X0),maxIndRow,maxIndCol));