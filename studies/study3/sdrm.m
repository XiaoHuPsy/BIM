function [params,err,predicted]=sdrm(observed)

% pass to this function a n X 2 matrix of observed frequency values
% the first column is not recalled confidence
% the second column is recalled confidence

% here is an example dataset that could be passed for immediate JOLs
% without prior test experience
% observed = [113 25; 248 72; 159 90; 105 73; 80 56; 27 32]

% here is an example dataset that could be passed for delayed JOLs without
% prior test experience
% observed = [433 9; 154 31; 51 53; 20 69; 7 47; 11 195]

% here is an example dataset that could be passed for immediate JOLs with
% prior test experience (condition SJTSJT in the Psych Review paper)
% observed = [163 42; 132 111; 62 105; 33 105; 15 116; 11 185]

% after enter the observed data type the following command
% [params,err,predicted]=sdrm(observed)

% here is the list of free parameters
    % conf = list of confidence criteria
    % cm = memory criterion
    % sc = standard deviation of confidence criteria
    % sm = standard deviation of memory criteria
    % rho = correlation between confidence and memory
    
n=size(observed,1); % number of confidence levels
for i=1:n-1    % set up initial values for confidence criteria
    conf(i)=-1.5+(i-1)*(3/(n-2));
end
% set up initial values for other parameters
cm=0.0;
sc=.75;
sm=.75;
rho=.8;

options=optimset('TolFun',.001); % fminsearch 
options=optimset(options,'TolX',.001);
options=optimset(options,'MaxFunEvals',10000);
options=optimset(options,'MaxIter',10000);

which_run=1; % fit only the confidence parameters
set_params=[sc sm rho]; 
params=[conf cm]; 
params=fminsearch(@sdrm_error,params,options,observed,which_run,set_params);

which_run=2; % fit only the sensitivity parameters
set_params=params; 
params=[sc sm rho]; 
params=fminsearch(@sdrm_error,params,options,observed,which_run,set_params);

which_run=3; % using best parameters from 1 and 2, fit all parameters
params=[set_params params]; 
params=fminsearch(@sdrm_error,params,options,observed,which_run,set_params);

[err,predicted]=sdrm_error(params,observed,which_run,set_params); % get predicted values
err=-err; % convert negative log likelihood back to log likelihood

end


function [err,predicted]=sdrm_error(params,observed,which_run,set_params)

n=size(observed,1); % number of confidence levels
dp = 0; % set to 0 for independent criteria model or 1 for linked model

if which_run==1
    params=[params set_params];
elseif which_run==2
    params=[set_params params];
end

for i=1:n-1
    conf(i)=params(i);
end
cm=params(n);
sc=params(n+1);
sm=params(n+2);
rho=params(n+3);

if rho<-.99 % keep values in range
    err=100000;
    return
elseif rho>.99
    err=100000;
    return
end
if sm<.0001
    err=100000;
    return
end
if sc<.0001
    err=100000;
    return
end

count=50;  % # of steps in grid

rec=zeros(n,1);
not=zeros(n,1);
    
lx=-3;  % calculate vector memory steps (x)
mx=3;
rx=(mx-lx)./(count-1);
x=lx:rx:mx;

ly=-3; % calculate vector confidence steps (y)
my=3;
ry=(my-ly)./(count-1);
y=ly:ry:my;

[X Y]=meshgrid(x,y);   % make x,y grid
cons=1./(2.*pi.*((1-rho.^2).^.5));      % calculate bivariate normal for grid
expon=(X.^2-(2.*rho.*X.*Y)+Y.^2) ./ (2.*(1-rho.^2));
bnpdf=rx.*ry.*cons.*exp(-expon);
      
                    
     % step through confidence levels
     % note that equations in the manuscript go from 0 to n where there are
     % n+1 confidence levels whereas these equations go from 1 to n where
     % there are n confidence levels
for i=1:n
    if i==1     % below first confidence criterion
        rec(i)=sum(sum(bnpdf.*normcdf(X,cm,sm).*(1-normcdf(Y,conf(i),sc)) )); 
        not(i)=sum(sum(bnpdf.*(1-normcdf(X,cm,sm)).*(1-normcdf(Y,conf(i),sc)) )); 
    elseif i<n  % some middle confidence criterion
        if dp==1
            rec(i)=sum(sum(bnpdf.*normcdf(X,cm,sm).*(normcdf(Y,conf(i-1),sc)-normcdf(Y,conf(i),sc)) )); 
            not(i)=sum(sum(bnpdf.*(1-normcdf(X,cm,sm)).*(normcdf(Y,conf(i-1),sc)-normcdf(Y,conf(i),sc)) )); 
        else
            rec(i)=sum(sum(bnpdf.*normcdf(X,cm,sm).*(1-normcdf(Y,conf(i),sc)).*normcdf(Y,conf(i-1),sc) )); 
            not(i)=sum(sum(bnpdf.*(1-normcdf(X,cm,sm)).*(1-normcdf(Y,conf(i),sc)).*normcdf(Y,conf(i-1),sc) )); 
        end
    elseif i==n  % above top confidence criterion
        rec(i)=sum(sum(bnpdf.*normcdf(X,cm,sm).*normcdf(Y,conf(i-1),sc) )); 
        not(i)=sum(sum(bnpdf.*(1-normcdf(X,cm,sm)).*normcdf(Y,conf(i-1),sc) )); 
    end
end

% normalize distributions (should only be necessary for independent model)
tot=sum(rec)+sum(not); % add up joint probabilities
rec=rec./tot; 
not=not./tot;

predicted=cat(2,not,rec);

err=-sum(sum(observed.*log(predicted))); % negative log likelihood

end



