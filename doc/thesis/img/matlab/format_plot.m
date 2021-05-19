%-------------------------------------------------------------------------
% File        : format_plot.m
% Author      : Michael Wurm <wurm.michael95@gmail.com>
% Description : Plot format helper.
%-------------------------------------------------------------------------

function [fig] = format_plot(fig,fig_title,fontsize)

%ax = gca;
ax=fig.CurrentAxes;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
%box off;

fig.Color='w';
fig.OuterPosition=fig.InnerPosition;

title(fig_title, 'FontSize',fontsize);
xlabel('time [s]', 'FontSize',fontsize, 'Position',getLabelPosition('x'),'HorizontalAlignment','center');
ylabel('amplitude','FontSize',fontsize, 'Position',getLabelPosition('y'),'HorizontalAlignment','center','VerticalAlignment','bottom','Rotation',90);

% integer ticks
%xticks(unique(round(ax.XTick)));
yticks(unique(round(ax.YTick)));
% no tick labels
set(gca,'XTickLabel',[],'YTickLabel',[]);

%legend();

end

function [pos] = getLabelPosition(label_axis)
%getLabelPosition - Description
%
% Syntax: [x,y] = getLabelPosition(label_axis)
%
%         label_axis ... x | y
%

Ylm=ylim();
Xlm=xlim();

if label_axis == 'x'
    x = mean(Xlm);
    y = 0.99*Ylm(1);
elseif label_axis == 'y'
    y = mean(Ylm);
    x = 0.99*Xlm(1);    
else
    error('unknown parameter for label_axis');
end

pos = [x,y]

end
