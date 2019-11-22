function r = draw_predictFig(jol_data,predicted_BIM,predicted_SDRM)
% draw figure for data and model predictions (from BIM and SDRM) in Studies
% 1 and 2

nSub = size(predicted_BIM,1);
nBins = size(predicted_BIM{1},1);

% bin confidence
if size(jol_data,2)==4
    jol_data(:,3) = bin_conf(jol_data(:,3),0,100,nBins);
    conf = jol_data(:,3);
    rec = jol_data(:,4);
    condition = jol_data(:,2);
elseif size(jol_data,2)==3
    jol_data(:,2) = bin_conf(jol_data(:,2),0,100,nBins);
    conf = jol_data(:,2);
    rec = jol_data(:,3);
    condition = zeros(length(conf),1);
else
    error('Please check the format of data')
end

sub = jol_data(:,1);
conAll = sort(unique(condition));

for c = 1:length(conAll)

    % generate overall data in bins
    data_conf = zeros(nBins,2,nSub);
    for i = 1:nSub
        for j = 1:nBins
           data_conf(j,1,i) = sum(sub==i & conf==j & condition==conAll(c) & rec==1)/sum(sub==i & condition==conAll(c));
           data_conf(j,2,i) = sum(sub==i & conf==j & condition==conAll(c) & rec==0)/sum(sub==i & condition==conAll(c));
        end
    end
    
    mean_data_conf = mean(data_conf,3);
    std_data_conf = std(data_conf,[],3);
    se_data_conf = std_data_conf/sqrt(nSub);

    % generate overall prediction
    predicted_conf_BIM = zeros(nBins,2,nSub);
    predicted_conf_SDRM = zeros(nBins,2,nSub);
    for i = 1:nSub
        predicted_conf_BIM(:,:,i) = predicted_BIM{i,c};
        predicted_conf_SDRM(:,:,i) = predicted_SDRM{i,c};
    end
    
    mean_predicted_conf_BIM = mean(predicted_conf_BIM,3);
    std_predicted_conf_BIM = std(predicted_conf_BIM,[],3);
    se_predicted_conf_BIM = std_predicted_conf_BIM/sqrt(nSub);
    
    mean_predicted_conf_SDRM = mean(predicted_conf_SDRM,3);
    std_predicted_conf_SDRM = std(predicted_conf_SDRM,[],3);
    se_predicted_conf_SDRM = std_predicted_conf_SDRM/sqrt(nSub);
    
    % draw figures
    ctrs = 1:size(mean_data_conf,1);
    data = mean_data_conf(:,1:2);
    figure(c);
    hBar = bar(ctrs, data);
    
    set(hBar(1),'FaceColor',[200/255 200/255 200/255]);
    set(hBar(2),'FaceColor',[1 248/255 220/255]);

    legends=cell(1,2);
    legends{1}='Recalled';
    legends{2}='Unrecalled';
    legend(hBar,legends);

    for k1 = 1:2
        ctr(k1,:) = bsxfun(@plus, hBar(1).XData, [hBar(k1).XOffset]');
        ydt(k1,:) = hBar(k1).YData;
    end
    hold on
    e=errorbar(ctr, ydt, zeros(size(ydt)), se_data_conf(:,1:2)', '.k');
    for i=1:size(mean_data_conf,1)
        e(i).LineWidth=2;
    end
    
    % draw predictions of BIM
    pre_points_rec = plot(ctr-0.07,mean_predicted_conf_BIM','r.','MarkerSize',30);
    e_pre=errorbar(ctr-0.07, mean_predicted_conf_BIM', se_predicted_conf_BIM', se_predicted_conf_BIM', '.r');
    for i=1:size(mean_predicted_conf_BIM,1)
        e_pre(i).LineWidth=2;
    end
    
    % draw predictions of SDRM
    pre_points_rec = plot(ctr+0.07,mean_predicted_conf_SDRM','b.','MarkerSize',30);
    e_pre=errorbar(ctr+0.07, mean_predicted_conf_SDRM', se_predicted_conf_SDRM', se_predicted_conf_SDRM', '.b');
    for i=1:size(mean_predicted_conf_SDRM,1)
        e_pre(i).LineWidth=2;
    end
    
    set(findall(gcf,'-property','FontSize'),'FontSize',24)
    set(findall(gcf,'-property','FontWeight'),'FontWeight','bold')
    set(gca,'XTick',[0 (nBins+1)/2 nBins+1])
    set(gca,'XTickLabel',{'0','50','100'})

end

r=1;
