function [err,predicted]=sdrm_sigma0_error(params,observed,which_run,set_params)
% Error function for SDRM with sigma_M and sigma_c as 0

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
sc=0;
sm=0;
rho=params(n+1);

if rho<-.99 % keep values in range
    err=100000;
    predicted=[];
    return
elseif rho>.99
    err=100000;
    predicted=[];
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

rec(rec<=0) = 1e-50;
not(not<=0) = 1e-50;

% normalize distributions (should only be necessary for independent model)
tot=sum(rec)+sum(not); % add up joint probabilities
rec=rec./tot; 
not=not./tot;

predicted=cat(2,not,rec);

err=-sum(sum(observed.*log(predicted))); % negative log likelihood

end