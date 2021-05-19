%-------------------------------------------------------------------------
% File        : format_plot.m
% Author      : Michael Wurm <wurm.michael95@gmail.com>
% Description : Plot format helper.
%-------------------------------------------------------------------------

function [fig] = format_plot(fig,fig_title,fontsize)

ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
%box off;

% get axis limits for label positions
Ylm=ylim();
Xlm=xlim();
Xlb=mean(Xlm);
Ylb=0.99*Ylm(1);

title(fig_title, 'FontSize',fontsize);
xlabel('time [s]','FontSize',fontsize, 'Position',[Xlb Ylb],'HorizontalAlignment','center');
ylabel('amplitude','FontSize',fontsize);
set(gca,'XTickLabel',[],'YTickLabel',[])
%legend();

end
