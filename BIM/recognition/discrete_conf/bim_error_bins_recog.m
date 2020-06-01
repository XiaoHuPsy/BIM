function [err,predicted] = bim_error_bins_recog(params,nR_S1,nR_S2,d,C)
% [err,predicted] = bim_error_bins_recog(params,nR_S1,nR_S2,d,C)
%
% The error function for BIM applied to recognition tasks with discrete
% confidence.
%
% Please do not run this function directly. Instead, use the function
% fit_bim_bins_recog.

%% get parameters
% parameters
Pexp = params(1);
Mconf1 = params(2); % Mconf for S1 stimulus with S1 response
Mconf2 = params(3); % Mconf for S1 stimulus with S2 response
Mconf3 = params(4); % Mconf for S2 stimulus with S1 response
Mconf4 = params(5); % Mconf for S2 stimulus with S2 response
rho = params(6);

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

%% calculate confidence criteria on x0 distribution
nratings = length(nR_S1)/2;
conf_criteria = linspace(1/nratings,1-1/nratings,nratings-1);

x0c_rS1_S1 = (norminv(conf_criteria)-b1)/(-a); % conf criteria for S1 response in S1 trials
x0c_rS2_S1 = (norminv(conf_criteria)-b2)/a; % conf criteria for S2 response in S1 trials
x0c_rS1_S2 = (norminv(conf_criteria)-b3)/(-a); % conf criteria for S1 response in S2 trials
x0c_rS2_S2 = (norminv(conf_criteria)-b4)/a; % conf criteria for S2 response in S2 trials

%% calculate probability for each confidence category

p_rS1_S1 = zeros(1,nratings);
p_rS2_S1 = zeros(1,nratings);
p_rS1_S2 = zeros(1,nratings);
p_rS2_S2 = zeros(1,nratings);

cov = [1 rho;rho 1];

p_rS1_S1(1) = normcdf(C,-0.5*d,1) - mvncdf([C,x0c_rS1_S1(1)],[-0.5*d,0],cov);
p_rS2_S1(1) = normcdf(x0c_rS2_S1(1)) - mvncdf([C,x0c_rS2_S1(1)],[-0.5*d,0],cov);
p_rS1_S2(1) = normcdf(C,0.5*d,1) - mvncdf([C,x0c_rS1_S2(1)],[0.5*d,0],cov);
p_rS2_S2(1) = normcdf(x0c_rS2_S2(1)) - mvncdf([C,x0c_rS2_S2(1)],[0.5*d,0],cov);

if nratings > 2
    
    p_rS1_S1([2:(nratings-1)]) = mvncdf([repmat(C,nratings-2,1) x0c_rS1_S1([2:(nratings-1)]-1)'],[-0.5*d,0],cov)' - mvncdf([repmat(C,nratings-2,1) x0c_rS1_S1([2:(nratings-1)])'],[-0.5*d,0],cov)';
    p_rS2_S1([2:(nratings-1)]) = (normcdf(x0c_rS2_S1([2:(nratings-1)])) - mvncdf([repmat(C,nratings-2,1) x0c_rS2_S1([2:(nratings-1)])'],[-0.5*d,0],cov)') - (normcdf(x0c_rS2_S1([2:(nratings-1)]-1)) - mvncdf([repmat(C,nratings-2,1) x0c_rS2_S1([2:(nratings-1)]-1)'],[-0.5*d,0],cov)');
    p_rS1_S2([2:(nratings-1)]) = mvncdf([repmat(C,nratings-2,1) x0c_rS1_S2([2:(nratings-1)]-1)'],[0.5*d,0],cov)' - mvncdf([repmat(C,nratings-2,1) x0c_rS1_S2([2:(nratings-1)])'],[0.5*d,0],cov)';
    p_rS2_S2([2:(nratings-1)]) = (normcdf(x0c_rS2_S2([2:(nratings-1)])) - mvncdf([repmat(C,nratings-2,1) x0c_rS2_S2([2:(nratings-1)])'],[0.5*d,0],cov)') - (normcdf(x0c_rS2_S2([2:(nratings-1)]-1)) - mvncdf([repmat(C,nratings-2,1) x0c_rS2_S2([2:(nratings-1)]-1)'],[0.5*d,0],cov)');

end

p_rS1_S1(nratings) = mvncdf([C,x0c_rS1_S1(nratings-1)],[-0.5*d,0],cov);
p_rS2_S1(nratings) = 1 - normcdf(C,-0.5*d,1) - ( normcdf(x0c_rS2_S1(nratings-1)) - mvncdf([C,x0c_rS2_S1(nratings-1)],[-0.5*d,0],cov) );
p_rS1_S2(nratings) = mvncdf([C,x0c_rS1_S2(nratings-1)],[0.5*d,0],cov);
p_rS2_S2(nratings) = 1 - normcdf(C,0.5*d,1) - ( normcdf(x0c_rS2_S2(nratings-1)) - mvncdf([C,x0c_rS2_S2(nratings-1)],[0.5*d,0],cov) );

p_rS1_S1(p_rS1_S1<=0) = 1e-50;
p_rS2_S1(p_rS2_S1<=0) = 1e-50;
p_rS1_S2(p_rS1_S2<=0) = 1e-50;
p_rS2_S2(p_rS2_S2<=0) = 1e-50;

predicted_S1 = [rot90(p_rS1_S1,2) p_rS2_S1];
predicted_S2 = [rot90(p_rS1_S2,2) p_rS2_S2];

predicted.S1 = predicted_S1;
predicted.S2 = predicted_S2;

%% calculate log likelihood

logL = sum(nR_S1.*log(predicted_S1)) + sum(nR_S2.*log(predicted_S2));
err = -logL;