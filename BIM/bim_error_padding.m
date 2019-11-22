function err = bim_error_padding(params,observed_data)
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

%% calculate log likelihood for padding trial

conf_padding = [conf;conf];
rec_padding = [zeros(ntrial,1);ones(ntrial,1)];

ntrial_padding = length(conf_padding);

X1 = lb_x1:rx1:ub_x1;
X1_padding = repmat(X1,[ntrial_padding,1]);
npdf=rx1.*normpdf(X1_padding);

lik_rec = (1-normcdf(-mu_m,rho*X1_padding,sqrt(1-rho^2)));

conf_padding_new = repmat(conf_padding,[1,count]);
rec_padding_new = repmat(rec_padding,[1,count]);

grid_loglik_paddding = npdf.* normpdf(conf_padding_new/100,normcdf(X1_padding.*a+b),0.025).*(rec_padding_new.*lik_rec+(1-rec_padding_new).*(1-lik_rec));

loglik_padding = log(sum(grid_loglik_paddding,2));

% Correct the log likelihood based on memory performance. Estimation of rho
% is more likely to be inaccurate when performance is more extreme (i.e.,
% more close to 0 or 1) and a larger correction is added
err_padding = (-1)*sum(loglik_padding)/ntrial_padding*abs(mean(rec)-0.5);

err = err + err_padding;




