%-------------------------------------------------------------------------
% File        : do_plot.m
% Author      : Michael Wurm <wurm.michael95@gmail.com>
% Description : Plot helper.
%-------------------------------------------------------------------------

function [fig] = do_plot(fig)

ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
%box on;
title(fig_title, 'FontSize',fontsize);
Ylm=ylim();                          % get x, y axis limits 
Xlm=xlim();                          % so can position relative instead of absolute
Xlb=mean(Xlm);                       % set horizontally at midpoint
Ylb=0.99*Ylm(1);                     % and just 1% below minimum y value
xlabel('time [s]','FontSize',fontsize, 'Position',[Xlb Ylb],'HorizontalAlignment','center');
ylabel('amplitude','FontSize',fontsize);
set(gca,'XTickLabel',[],'YTickLabel',[])
legend();
saveas(fig_time_rf, sprintf("%s/%s",dir_output, "fig_time_rf.png"));

end
