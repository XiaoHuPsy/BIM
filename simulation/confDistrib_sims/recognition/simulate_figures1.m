% simulate data from BIM applied to recognition tasks with continuous confidence,
% and draw figures for confidence-performance joint distribution

ntrial = 100000; % number of trials

% set parameter value
Pexp = 0.5;
Mconf1 = 0.3:0.1:0.7;
Mconf2 = 0.3:0.1:0.7;
Mconf3 = 0.5;
Mconf4 = 0.5;
rho = 0;
d = 0;
C = 0;
params = combvec(Mconf1,Mconf2);

y_lim = [0 1.5];

% simulate data and draw figures
for i = 1:size(params,2)

    % simulate data
    observed_data = BIM_simulation_recog(Pexp,params(1,i),params(2,i),Mconf3,Mconf4,rho,d,C,ntrial);

    conf_correct = observed_data(observed_data(:,1)==1 & observed_data(:,2)==1,3)/100;
    conf_incorrect = observed_data(observed_data(:,1)==1 & observed_data(:,2)~=1,3)/100;

    % adjust extreme values to avoid error in kernel density estimation
    conf_correct(conf_correct==1)=0.9999;
    conf_correct(conf_correct==0)=0.0001;
    conf_incorrect(conf_incorrect==1)=0.9999;
    conf_incorrect(conf_incorrect==0)=0.0001;

    % kernel density estimation
    [F1,XI1,~]=ksdensity(conf_correct,'support',[0 1],'BoundaryCorrection','reflection','NumPoints',1000);
    [F2,XI2,~]=ksdensity(conf_incorrect,'support',[0 1],'BoundaryCorrection','reflection','NumPoints',1000);

    F1 = F1 * length(conf_correct) / (length(conf_correct)+length(conf_incorrect));
    F2 = F2 * length(conf_incorrect) / (length(conf_correct)+length(conf_incorrect));

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
    filename = sprintf('fig_pexp_%2.1f_mconf1_%2.1f_mconf2_%2.1f_rho_%2.1f',Pexp,params(1,i),params(2,i),rho);
    eval(sprintf('export_fig %s -tiff -nocrop -r1000 -transparent',filename));
    
    close all

end