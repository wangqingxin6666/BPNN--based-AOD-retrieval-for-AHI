function plot_densityTM(x,y,xname,yname,flabel,sitename)
%%和plot_densityT相比  改变了字的大小
if nargin==1   %仅有1个输入变量
    if size(x,1)
        x=x';    %转置为列向量
    end
    y=x;
    x=(1:length(y))';
else if nargin==2   %有2个输入变量
        if size(x,1)
            x=x';   %转置为列向量
        end
        if size(y,1)
            y=y';       %转置为列向量
        end
    end
end
N=length(x);   %数据长度
c=zeros(N,1);
max_x=max(x);min_x=min(x);   %搜索边界点
max_y=max(y);min_y=min(y);    %搜索边界点
NLevel=101;   %划分等级100份
color_Map=zeros(NLevel+1);
step_x=(max_x-min_x)/(NLevel-1);  % x轴步长
step_y=(max_y-min_y)/(NLevel-1);    % y轴步长 
for j=1:N
    color_Map_x=int32((x(j)-min_x)/step_x)+1;
    color_Map_y=int32((y(j)-min_y)/step_y)+1;
    color_Map(color_Map_x,color_Map_y)=color_Map(color_Map_x,color_Map_y)+1;
end
for j=1:N
    color_Map_x=int32((x(j)-min_x)/step_x)+1;
    color_Map_y=int32((y(j)-min_y)/step_y)+1;
    c(j)=color_Map(color_Map_x,color_Map_y);
end
xx=[0 3];
y3=polyfit(3.5,3.5,1);
y4=polyval(y3,xx);
plot(xx,y4,'k','LineWidth',1.6);

hold on
scatter(x,y,30,c,'filled')

%scatter(x,y,30,'filled','MarkerEdgeColor','k','MarkerFaceColor','k');
hold on
 caxis([0,50]);
 colormap(jet);   %查阅colormap函数改变颜色变化趋势
% 
% colorbar   %显示颜色条
yy=polyfit(x,y,1);

y1=polyval(yy,x);


set(gca,'FontSize',17,'Fontname','Cambria');

set(gca,'LineWidth',1.6);
set(gca,'TickLength',[0.015 0]);

h1=plot(x,y1,'-r','LineWidth',1.6);
h2=plot([0 4],[-0.05 3.2],'--b','LineWidth',1.6);
h3=plot([0 4],[0.05 4.8],'--b','LineWidth',1.6);
set(gca,'xTick',[0:0.5:3]); 
set(gca,'yTick',[0:0.5:3]); 
axis([ 0 3 0 3]); 


%% 
 t11=[2.0];
 t1=[0.1];
 %% 
t2=[2.85];
t3=[2.55];
t4=[2.25];
t5=[2.0];
t6=[1.7];
t7=[1.4];



t8=[1.0];
t9=[0.7];
t10=[0.4];
t22=[1.2];%时刻显示位置
%计算RMSE
mae=mean(abs(y-x));
bias=mean(y-x);

su=0;
msu=0;
within=0;
above=0;
below=0;

for i=1:N
    su=su+abs(y(i)-x(i))/x(i);

    aboveline=0.05+1.2*x(i);
    below_line=-0.05+0.8*x(i);
%           aboveline=0.05+1.15*x(i); 
%      below_line=-0.05+0.85*x(i);
    if y(i) >= below_line & y(i) <= aboveline
        within=within+1;
    end
     if y(i) > aboveline
        above=above+1;
     end
     if y(i) < below_line
        below=below+1;
     end
    
end

fill([0.1 1.3 1.3 0.1],[1.8 1.8 2.99 2.99],'w','facealpha',0.7,'EdgeColor','none');
fill([2 2.99 2.99 2],[0.2 0.2 1.1 1.1],'w','facealpha',0.7,'EdgeColor','none');

withinperc=100*within/N;
aboveperc=100*above/N;
belowperc=100*below/N;
mre=su/N;

RMB=mean(y)/mean(x);
rmse=sqrt(sum((y-x).^2)/N);
a=sprintf('%5.3f',yy(1,1));
b=sprintf('%5.3f',yy(1,2));
 plus=' ';
if yy(1,2)> 0 
   plus='+';
end

NUB=num2str(N);
str1=strcat('N:',NUB);

str2=strcat('y=',a,'x',plus,b);
%str=strcat('y=0.80x',plus,b)
r=corrcoef(x,y);
str3=sprintf('%5.3f',r(2,1));
str3=strcat('R:',str3);

% str4=sprintf('%5.3f',bias);
% str4=strcat('Bias:',str4);

str5= sprintf('%5.3f',rmse);
str5=strcat('RMSE:',str5);

% str6= sprintf('%5.3f',RMB);
% str6=strcat('RMB:',str6);

str7=sprintf('%4.2f',withinperc);
str7=strcat('=EE:',str7,'%');
str8=sprintf('%4.2f',belowperc);
str8=strcat('<EE:',str8,'%');


str9=sprintf('%4.2f',aboveperc);
str9=strcat('>EE:',str9,'%');
xlabel(xname,'Fontname','微软雅黑','FontSize',17,'FontWeight','bold');
ylabel(yname,'Fontname','微软雅黑','FontSize',17,'FontWeight','bold');
strtime=sitename;
%text(2.8,0.15,'(a)','FontSize',25,'Fontname','Cambria')
%text(700,40,'(d)','FontSize',30,'Fontname','Cambria')
text(t1,t2,str1,'FontSize',17,'Fontname','Cambria');
text(t1,t3,str2,'FontSize',17,'Fontname','Cambria');
text(t1,t4,str3,'FontSize',17,'Fontname','Cambria');
 text(1.2,t2,strtime,'FontSize',20,'Fontname','Cambria')
%text(t1,t5,str4,'FontSize',22,'Fontname','Cambria');
text(t1,t5,str5,'FontSize',17,'Fontname','Cambria');
%text(t1,t7,str6,'FontSize',22,'Fontname','Cambria');
% 

text(t11,t8,str7,'FontSize',17,'Fontname','Cambria');
text(t11,t9,str8,'FontSize',17,'Fontname','Cambria');
text(t11,t10,str9,'FontSize',17,'Fontname','Cambria');
text(2.7,0.2,flabel,'FontSize',22,'Fontname','Cambria');
%set(gca,'xticklabel',[]);

end