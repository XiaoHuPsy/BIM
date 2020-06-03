function sigmal = func_estSigmal(mconf,mue,mub)

%% set up initial value
sigmal = 1;

%% fit the model
options=optimset('TolFun',1e-10); % fminsearch 
options=optimset(options,'TolX',1e-10);
options=optimset(options,'MaxFunEvals',10000);
options=optimset(options,'MaxIter',10000);
options=optimset(options,'Display','off');

options_pso = optimoptions(@particleswarm,'Display','off','InitialSwarm',[]);

lb=0;
ub=5;

options_pso.InitialSwarm = repmat(sigmal,[1000 1]);

% turn off the warning for particleswarm
warning('off','globaloptim:particleswarm:initialSwarmLength');

sigmal = particleswarm(@(sigmal) sigmal_error(sigmal,mconf,mue,mub),length(sigmal),lb,ub,options_pso);
sigmal = fminsearch(@(sigmal) sigmal_error(sigmal,mconf,mue,mub),sigmal,options);

% turn on the warning for particleswarm
warning('on','globaloptim:particleswarm:initialSwarmLength');

%% error function
function err = sigmal_error(sigmal,mconf,mue,mub)

% set boundary for sigmal in order to prevent sigmal from being too
% large or small. If the value of sigmal is too extreme then we may fail to
% compute the estimated JOL value for each trial.
if sigmal < 0.1
    err=100000;
    return
elseif sigmal > 5
    err=100000;
    return
end

mconf_predict = normcdf((mue/sigmal+mub*sigmal)/sqrt(sigmal^2+1/(sigmal^2)+1));

err = (mconf_predict-mconf)^2;