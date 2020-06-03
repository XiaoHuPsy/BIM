function [err,predicted1,predicted2]=sdrm4c_sigma0_error(params,observed1,observed2,which_run,set_params)
% Error function for Model 4c of SDRM (with sigma_M and sigma_c as 0)

n=size(observed1,1); % number of confidence levels

if which_run==1
    params=[params set_params];
elseif which_run==2
    params=[set_params params];
end

conf1 = params(1:(n-1));
beta = params(n);

if beta <= 0
    err=100000;
    predicted1=[];
    predicted2=[];
    return
end

conf2 = conf1*beta;

cm1 = params(n+1);
cm2 = params(n+2);

rho1 = params(n+3);
rho2 = params(n+4);

params1 = [conf1 cm1 rho1];
params2 = [conf2 cm2 rho2];
    
[err1,predicted1] = sdrm_sigma0_error(params1,observed1,3,[]);
[err2,predicted2] = sdrm_sigma0_error(params2,observed2,3,[]);
    
err = err1 + err2;

end