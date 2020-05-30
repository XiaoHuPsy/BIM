function err = bim_error(params,observed_data)
% err = bim_error(params,observed_data)
% 
% The error function for BIM applied to recall tasks with continuous
% confidence.
%
% Please do not run this function directly. Instead, use the function fit_bim.

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
% transfrom the parameters Pexp and Mconf into two new parameters (a and b)
sigmal = sqrt(1/Pexp-1);
wavg = norminv(Mconf)*sqrt(1+sigmal^2+1/(sigmal^2));

a = 1/(sigmal*sqrt(sigmal^2+1));
b = wavg/sqrt(sigmal^2+1);

%% create grid for x1
count=100;  % steps in grid
lb_x1 = -5; % lower bound for x1
ub_x1 = 5; % upper bound for x1

rx1 = (ub_x1-lb_x1)./(count-1);

X1 = lb_x1:rx1:ub_x1;

X1 = repmat(X1,[ntrial,1]);

%% calculate normal pdf for grid
npdf=rx1.*normpdf(X1);


%% calculate log likelihood and prediction for each trial

lik_rec = (1-normcdf(-mu_m,rho*X1,sqrt(1-rho^2)));

conf_new = repmat(conf,[1,count]);
rec_new = repmat(rec,[1,count]);
    
grid_loglik = npdf.* normpdf(conf_new/100,normcdf(X1.*a+b),0.025).*(rec_new.*lik_rec+(1-rec_new).*(1-lik_rec));
loglik = log(sum(grid_loglik,2));

err = (-1)*sum(loglik); % sum of negative log likelihood