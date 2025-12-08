clc;
clear all;
% AOD空间分布的变化趋势例子
load('A9AODNEWnotrain2.mat');
load('JAXAAODnotrain.mat');
%% Beijing    "Luang-Namtha" 20230207 
Beijingfile='I:\AERONET15\2023AHI\csvnew\XiangHeAOD550.csv';
AERONETdata=importdata(Beijingfile);
date='20230307';
index1=find(str2num(date)==AERONETdata(:,1));
times1=AERONETdata(index1,2);
AERAODs=AERONETdata(index1,5);
times1u=[];
for i=1:length(times1)

times1t=floor(times1(i)./100)+(times1(i)-floor(times1(i)./100)*100)./60;
times1u=[times1u;times1t];
end

index2=find(date==AHIusedata(:,4) &  'XiangHe'==AHIusedata(:,1));
times2=double(AHIusedata(index2,5));
AHIAOD=double(AHIusedata(index2,6));


times2u=[];
for i=1:length(times2)

times2t=floor(times2(i)./100)+(times2(i)-floor(times2(i)./100)*100)./60;
times2u=[times2u;times2t];
end


index3=find(date==JAXAusedata(:,2) &  'XiangHe'==JAXAusedata(:,1));
times3=double(JAXAusedata(index3,3));
JAXAAOD=double(JAXAusedata(index3,4));

times3u=[];
for i=1:length(times3)

times3t=floor(times3(i)./100)+(times3(i)-floor(times3(i)./100)*100)./60;
times3u=[times3u;times3t];
end


nums=length(index3);
JAXAAODS=[];
for i=1:nums
    time=times3(i);
    timeu=floor(time./100)+(time-floor(time./100)*100)./60
    JAXAAOD500=JAXAAOD(i);
    findex=find(times1u>timeu-0.5 & times1u<timeu+0.5);
    if isempty(findex)
        JAXAAOD550= JAXAAOD500 *0.8735+0.004;
    else
      
    AE=mean(AERONETdata(findex,4));
    JAXAAOD550=JAXAAOD500*((550.0/500)^AE);
    end

JAXAAODS =[JAXAAODS;JAXAAOD550];
end


uindex=find(times1>=200 & times1<=830);

set (gcf,'Position',[400,100,800,500], 'color','w');

plot(times1u(uindex),AERAODs(uindex),'--g*','linewidth',2,'Markersize',12,'MarkerEdgecolor','g','MarkerFacecolor','g');
hold on;
plot(times2u,AHIAOD,'--ro','linewidth',2,'Markersize',12,'MarkerEdgecolor','r','MarkerFacecolor','r');
hold on;
plot(times3u,JAXAAODS,'--k+','linewidth',2,'Markersize',12,'MarkerEdgecolor','k','MarkerFacecolor','k');
 set(gca,'LineWidth',1.6);
set(gca,'TickLength',[0.015 0]);
set(gca,'xTick',[2:1:9]); 
set(gca,'yTick',[0.8:0.2:1.6]); 
xtb = get(gca,'XTickLabel');
axis([ 2 8.5 0.7 1.6]); 

C={'2:00' '3:00' '4:00' '5:00' '6:00' '7:00' '8:00' };
 
xlabel('Time','Fontname','Cambria','FontSize',20,'FontWeight','bold')
ylabel('AOD','Fontname','Cambria','FontSize',20,'FontWeight','bold')
set(gca,'FontSize',25,'Fontname','Cambria');
set(gca,'XTickLabel',C);
legend('AERONET AOD','Retrieved AOD','JAXA AOD','Northeast');
legend('boxoff');
text(3.5,1.5,"XiangHe",'FontSize',25,'Fontname','Cambria');
text(7.9,0.77,'(a)','FontSize',25,'Fontname','Cambria');
