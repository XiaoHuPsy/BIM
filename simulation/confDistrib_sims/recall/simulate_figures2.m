% simulate data from BIM applied to recall tasks with continuous confidence,
% and draw figures for confidence-performance joint distribution

ntrial = 50000; % number of trials

% set parameter value
Pexp = 0.5;
Mconf = 0.5;
mu_m = -1:0.5:1;
rho = -0.8:0.4:0.8;
params = combvec(Pexp,Mconf,mu_m,rho);

y_lim = [0 1.5];

% simulate data and draw figures
for i = 1:size(params,2)

    % simulate data
    observed_data = BIM_simulation(params(1,i),params(2,i),params(3,i),params(4,i),ntrial);

    conf_recalled = observed_data(observed_data(:,2)==1,1)/100;
    conf_unrecalled = observed_data(observed_data(:,2)==0,1)/100;

    % adjust extreme values to avoid error in kernel density estimation
    conf_recalled(conf_recalled==1)=0.9999;
    conf_recalled(conf_recalled==0)=0.0001;
    conf_unrecalled(conf_unrecalled==1)=0.9999;
    conf_unrecalled(conf_unrecalled==0)=0.0001;

    % kernel density estimation
    [F1,XI1,~]=ksdensity(conf_recalled,'support',[0 1],'BoundaryCorrection','reflection','NumPoints',1000);
    [F2,XI2,~]=ksdensity(conf_unrecalled,'support',[0 1],'BoundaryCorrection','reflection','NumPoints',1000);

    F1 = F1 * length(conf_recalled) / (length(conf_recalled)+length(conf_unrecalled));
    F2 = F2 * length(conf_unrecalled) / (length(conf_recalled)+length(conf_unrecalled));

    % draw figure
    figure('units','normalized','outerposition',[0 0 1 1]);

    plot(XI1(2:end-1),F1(2:end-1),'b','LineWidth',15);hold on;plot(XI2(2:end-1),F2(2:end-1),'r','LineWidth',15);

    ylim(y_lim);
    xlim([0 1]);

    set(findall(gcf,'-property','FontSize'),'FontSize',50);
    set(findall(gcf,'-property','FontWeight'),'FontWeight','bold');

    set(gca,'xtick','')
    set(gca,'ytick','')

    set(gca,'linewidth',12);
    
    % use export_fig function to export high-quality figures
    % see https://www.mathworks.com/matlabcentral/fileexchange/23629-export_fig/
    filename = sprintf('fig_pexp_%2.1f_mconf_%2.1f_mu_m_%2.1f_rho_%2.1f',params(1,i),params(2,i),params(3,i),params(4,i));
    eval(sprintf('export_fig %s -tiff -nocrop -r1000 -transparent',filename));
    
    close all

end