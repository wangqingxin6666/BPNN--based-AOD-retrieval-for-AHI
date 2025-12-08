clc;
clear all;
%% 画H9 retrieved 和JAXA 散点
load('matchdataJAXA.mat');
load('matchdata.mat');
load('AHIJAXAmatch.mat');

matchdataAERx=matchdata(:,4);
matchdataAHIy=matchdata(:,5);
matchdataJAXAx=matchdataJAXA(:,4);
matchdataJAXAy=matchdataJAXA(:,5);

AHIerrors=double(matchdataAHIy)-double(matchdataAERx);
JAXAerrors=double(matchdataJAXAy)-double(matchdataJAXAx);


matchdataAHIxx=AHIJAXAmatch(:,4);
matchdataAHIyy=AHIJAXAmatch(:,5);
matchdataJAXAyy=AHIJAXAmatch(:,6);

AHIerrors=double(matchdataAHIyy)-double(matchdataAHIxx);
JAXAerrors=double(matchdataJAXAyy)-double(matchdataAHIxx);




set (gcf,'Position',[100,10,1500,450], 'color','w')
 subplot('Position',[0.05,0.2,0.26,0.75]);

 plot_densityTMP(double(matchdataAHIxx),double(matchdataAHIyy),'AERONET AOD (550 nm)','Retrieved AOD (550 nm)','(a)','');
 subplot('Position',[0.37,0.2,0.307,0.75]);
 plot_densityTM(double(matchdataAHIxx),double(matchdataJAXAyy),'AERONET AOD (550 nm)','JAXA AOD (550 nm)','(b)','');
  subplot('Position',[0.73,0.2,0.26,0.75]);





[xx1,yy1]=ksdensity(AHIerrors,'NumPoints',1000);
[xx2,yy2]=ksdensity(JAXAerrors,'NumPoints',1000);
fill([yy1(1),yy1,yy1(end)],[0,xx1,min(xx1)],[255,153,154]./255,'FaceAlpha',0.8,'EdgeColor','r','EdgeLighting','gouraud','LineWidth',1.6);
hold on;
fill([yy2(1),yy2,yy2(end)],[0,xx2,min(xx2)],[153,153,154]./255,'FaceAlpha',0.8,'EdgeColor',[100,100,100]./255,'EdgeLighting','gouraud','LineWidth',1.6);
hold on;
set(gca,'LineWidth',1.6);
set(gca,'FontSize',17,'Fontname','Cambria');
axis([-1 1 0 4])
legend('Retrieved AOD','JAXA AOD','Location','best');
legend boxoff;


xlabel('Bias','Fontname','微软雅黑','FontSize',17,'FontWeight','bold');
ylabel('Probability Density Function','Fontname','微软雅黑','FontSize',17,'FontWeight','bold');

text(0.8,0.23,'(c)','FontSize',22,'Fontname','Cambria');