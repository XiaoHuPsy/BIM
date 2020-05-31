function [err,loglik] = bim_error_recog(params,observed_data,d,C)
% [err,loglik] = bim_error_recog(params,observed_data,d,C)
%
% The error function for BIM applied to recognition tasks with continuous
% confidence.
%
% Please do not run this function directly. Instead, use the function
% fit_bim_recog.

%% get data and parameters
% parameters
Pexp = params(1);
Mconf1 = params(2); % Mconf for S1 stimulus with S1 response
Mconf2 = params(3); % Mconf for S1 stimulus with S2 response
Mconf3 = params(4); % Mconf for S2 stimulus with S1 response
Mconf4 = params(5); % Mconf for S2 stimulus with S2 response
rho = params(6);

% data
stim = observed_data(:,1);
resp = observed_data(:,2);
conf = observed_data(:,3);

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

if Mconf1 < 0.01
    err=100000;
    return    
elseif Mconf1 > 0.99
    err=100000;
    return 
end

if Mconf2 < 0.01
    err=100000;
    return    
elseif Mconf2 > 0.99
    err=100000;
    return 
end

if Mconf3 < 0.01
    err=100000;
    return    
elseif Mconf3 > 0.99
    err=100000;
    return 
end

if Mconf4 < 0.01
    err=100000;
    return    
elseif Mconf4 > 0.99
    err=100000;
    return 
end

%% parameter transform
% transfrom the parameters Pexp and Mconf into new parameters (a and b)
sigmal = sqrt(1/Pexp-1);
a = 1 / (sigmal * sqrt(1+sigmal^2));
b1 = norminv(Mconf1) * sqrt(1+a^2);
b2 = norminv(Mconf2) * sqrt(1+a^2);
b3 = norminv(Mconf3) * sqrt(1+a^2);
b4 = norminv(Mconf4) * sqrt(1+a^2);

%% create grid for x0
count=100;  % steps in grid
lb_x0 = -5; % lower bound for x0
ub_x0 = 5; % upper bound for x0

rx0 = (ub_x0-lb_x0)./(count-1);

X0 = lb_x0:rx0:ub_x0;

X0 = repmat(X0,[ntrial,1]);

%% calculate normal pdf for grid
npdf=rx0.*normpdf(X0);

%% calculate log likelihood for each trial

conf_new = repmat(conf,[1,count]);
stim_new = repmat(stim,[1,count]);
resp_new = repmat(resp,[1,count]);

likrec_rS1_S1 = normcdf(C,(-0.5)*d+rho*X0,sqrt(1-rho^2));
likrec_rS2_S1 = (1-normcdf(C,(-0.5)*d+rho*X0,sqrt(1-rho^2)));
likrec_rS1_S2 = normcdf(C,0.5*d+rho*X0,sqrt(1-rho^2));
likrec_rS2_S2 = (1-normcdf(C,0.5*d+rho*X0,sqrt(1-rho^2)));

likconf_rS1_S1 = normpdf(conf_new/100,normcdf((-X0)*a+b1),0.025);
likconf_rS2_S1 = normpdf(conf_new/100,normcdf(X0*a+b2),0.025);
likconf_rS1_S2 = normpdf(conf_new/100,normcdf((-X0)*a+b3),0.025);
likconf_rS2_S2 = normpdf(conf_new/100,normcdf(X0*a+b4),0.025);

grid_loglik_rS1_S1 = npdf.*likrec_rS1_S1.*likconf_rS1_S1.*(resp_new==1 & stim_new==1);
grid_loglik_rS2_S1 = npdf.*likrec_rS2_S1.*likconf_rS2_S1.*(resp_new==2 & stim_new==1);
grid_loglik_rS1_S2 = npdf.*likrec_rS1_S2.*likconf_rS1_S2.*(resp_new==1 & stim_new==2);
grid_loglik_rS2_S2 = npdf.*likrec_rS2_S2.*likconf_rS2_S2.*(resp_new==2 & stim_new==2);

loglik = log(sum(grid_loglik_rS1_S1+grid_loglik_rS2_S1+grid_loglik_rS1_S2+grid_loglik_rS2_S2,2));

err = (-1)*sum(loglik); % sum of negative log likelihood