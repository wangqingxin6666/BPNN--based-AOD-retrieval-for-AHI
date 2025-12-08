
function p=plotzhexian4(y,yname,ymin,ymax,ystep)
x=1:12;
plot(x,y(:,1),'-go','linewidth',2,'Markersize',12,'MarkerEdgecolor','w','MarkerFacecolor','g')
hold on;
plot(x,y(:,2),'-ro','linewidth',2,'Markersize',12,'MarkerEdgecolor','w','MarkerFacecolor','r')
hold on;
plot(x,y(:,3),'-ko','linewidth',2,'Markersize',12,'MarkerEdgecolor','w','MarkerFacecolor','k')
hold on;



set(gca,'LineWidth',1.6);
set(gca,'TickLength',[0.015 0]);

set(gca,'xTick',[1:12]); 

set(gca,'yTick',[ymin:ystep:ymax]); 
xtb = get(gca,'XTickLabel');
axis([ 1 12 ymin ymax]); 
set(gca,'FontSize',22,'Fontname','Cambria')
xlabel('Month','Fontname','微软雅黑','FontSize',25,'FontWeight','bold')
ylabel(yname,'Fontname','Cambria','FontSize',25,'FontWeight','bold')


end