function observed_data = BIM_simulation_recog(Pexp,Mconf1,Mconf2,Mconf3,Mconf4,rho,d,C,ntrial)
% simulate data from BIM applied to recognition tasks with continuous confidence

% transform parameters
sigmal = sqrt(1/Pexp-1);
a = 1 / (sigmal * sqrt(1+sigmal^2));
b1 = norminv(Mconf1) * sqrt(1+a^2); % S1 stimulus with S1 response
b2 = norminv(Mconf2) * sqrt(1+a^2); % S1 stimulus with S2 response
b3 = norminv(Mconf3) * sqrt(1+a^2); % S2 stimulus with S1 response
b4 = norminv(Mconf4) * sqrt(1+a^2); % S2 stimulus with S2 response
    
observed_data = zeros(ntrial,3);

for trial = 1:ntrial
    
    if trial <= ntrial/2
        x = mvnrnd([(-0.5)*d 0],[1 rho;rho 1],1);
        observed_data(trial,1) = 1; % S1 stimulus
    else
        x = mvnrnd([0.5*d 0],[1 rho;rho 1],1);
        observed_data(trial,1) = 2; % S2 stimulus
    end

    x_rec = x(1);
    x_conf = x(2);
    
    % generate performance and confidence rating
    if x_rec < C
        observed_data(trial,2) = 1; % S1 response
        if observed_data(trial,1) == 1 % S1 stimulus
            conf_pre = normcdf((-x_conf)*a+b1)*100;
            conf = normrnd(conf_pre,2.5);
        else % S2 stimulus
            conf_pre = normcdf((-x_conf)*a+b3)*100;
            conf = normrnd(conf_pre,2.5);
        end
    else
        observed_data(trial,2) = 2; % S2 response
        if observed_data(trial,1) == 1 % S1 stimulus
            conf_pre = normcdf(x_conf*a+b2)*100;
            conf = normrnd(conf_pre,2.5);
        else % S2 stimulus
            conf_pre = normcdf(x_conf*a+b4)*100;
            conf = normrnd(conf_pre,2.5);
        end
    end
    
    
    if conf < 0 
       conf=0;
    elseif conf > 100
        conf=100;
    end

    observed_data(trial,3)=conf;

end