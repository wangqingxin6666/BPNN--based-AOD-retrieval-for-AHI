clc;
clear all;
%小时数据验证

%% 读取数据
load('AHIJAXAmatch.mat');
%% 获取时间信息
hour=AHIJAXAmatch(:,3);
AERAOD1=AHIJAXAmatch(:,4);
%% 计算精度
RS=[];
RMSES=[];
EES=[];

Ns=[];
MAODs=[];
hours=[200,230,300,330,400,430,500,530,600,630,700,730,800,830]
for y=1:14
    idx1=find(double(hour)==hours(y));
    % MERSI
    x1=AERAOD1(idx1);
    % DT
    y1=AHIJAXAmatch(idx1,5);
    y2=AHIJAXAmatch(idx1,6);
 
   [r1,EE1,rmse1,bias1,N1]=validation(double(x1),double(y1));
   [r2,EE2,rmse2,bias2,N2]=validation(double(x1),double(y2));
   RS=[RS;r1,r2];
   RMSES=[RMSES;rmse1,rmse2];
   EES=[EES;EE1,EE2];
   MAODs=[MAODs;mean(double(x1)),mean(double(y1)),mean(double(y2))];
   %Bias=[Bias;bias1,bias2];
end
 set (gcf,'Position',[50,50,1200,800], 'color','w')
 subplot('Position',[0.07,0.62,0.4,0.35]);
 plotzhexian2(RS,'R',0.5,1,0.1);
 set(gca,'FontSize',22,'Fontname','微软雅黑')
legend('Retrieved AOD','JAXA AOD','Location','southeast');
legend('boxoff');
 subplot('Position',[0.07,0.15,0.4,0.35]);
 plotzhexian2(EES,'Within EE (%)',10,100,20);
 subplot('Position',[0.56,0.62,0.4,0.35]);
 plotzhexian2(RMSES,'RMSE',0,0.4,0.1);
 subplot('Position',[0.56,0.15,0.4,0.35]);
 plotzhexian3(MAODs,'AOD',0,0.6,0.1);
 legend('AERONET AOD','Retrieved AOD','JAXA AOD','Location','southeast');
  legend('boxoff');
 x=2:0.5:8.5;
 y=zeros(1,14);
 %plot(x,y,'--b')
 c=1;

