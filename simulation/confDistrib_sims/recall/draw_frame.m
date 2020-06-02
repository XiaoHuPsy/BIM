% draw frame for the figures
figure('units','normalized','outerposition',[0 0 1 1]);
ylim([0 2.5]);
xlim([0 1]);

set(findall(gcf,'-property','FontSize'),'FontSize',80);
set(findall(gcf,'-property','FontWeight'),'FontWeight','bold');
set(gca,'linewidth',12);
yticks([0.5 1.5 2.5])

% use export_fig function to export high-quality figures
% see https://www.mathworks.com/matlabcentral/fileexchange/23629-export_fig/
export_fig frame_2.5 -tiff -nocrop -r1000 -transparent