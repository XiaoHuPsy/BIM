function observed_data = BIM_simulation(Pexp,Mconf,mu_m,rho,ntrial)
% simulate data from BIM applied to recall tasks with continuous confidence

% transform parameters
sigmal = sqrt(1/Pexp-1);
wavg = norminv(Mconf)*sqrt(1+sigmal^2+1/(sigmal^2));
a = 1/(sigmal*sqrt(sigmal^2+1));
b = wavg/sqrt(sigmal^2+1);
    
observed_data = zeros(ntrial,2);

for trial = 1:ntrial

    x = mvnrnd([mu_m 0],[1 rho;rho 1],1);

    x_rec = x(1);
    x_conf = x(2);

    % generate confidence rating
    conf_pre = normcdf(x_conf*a+b,0,1)*100;
    conf = normrnd(conf_pre,2.5);
    
    if conf < 0 
       conf=0;
    elseif conf > 100
        conf=100;
    end

    observed_data(trial,1)=conf;

    % generate performance
    if x_rec > 0
        observed_data(trial,2) = 1;
    else
        observed_data(trial,2) = 0;
    end

end