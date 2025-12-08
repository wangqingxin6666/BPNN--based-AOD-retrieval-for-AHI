
function p=plotzhexian2(y,yname,ymin,ymax,ystep)
x=2:0.5:8.5;
plot(x,y(:,1),'-ro','linewidth',2,'Markersize',12,'MarkerEdgecolor','w','MarkerFacecolor','r')
hold on;
plot(x,y(:,2),'-ko','linewidth',2,'Markersize',12,'MarkerEdgecolor','w','MarkerFacecolor','k')
hold on;
set(gca,'LineWidth',1.6);
set(gca,'TickLength',[0.015 0]);

set(gca,'xTick',[2:1:9]); 

set(gca,'yTick',[ymin:ystep:ymax]); 
xtb = get(gca,'XTickLabel');
axis([ 2 8.5 ymin ymax]); 
set(gca,'FontSize',25,'Fontname','Cambria')
xlabel('Time','Fontname','Î¢ÈíÑÅºÚ','FontSize',25,'FontWeight','bold')
ylabel(yname,'Fontname','Cambria','FontSize',25,'FontWeight','bold')


end