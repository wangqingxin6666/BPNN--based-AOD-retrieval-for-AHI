clc;
clear all;
%月数据验证
%% 路径
load('AHIJAXAmatch.mat');
%% 读取数据
data=AHIJAXAmatch;
%% 获取时间信息
tmons=data(:,2);


mons=floor((double(tmons)-20230000)/100);
AERAOD1=double(data(:,4));
%% 计算精度
RS=[];
RMSES=[];
EES=[];
MAODs=[];
for y=1:12
    idx1=find(mons==y);
    % MERSI
    x1=AERAOD1(idx1);
    y1=double(data(idx1,5));
    y2=double(data(idx1,6));
   [r1,EE1,rmse1,bias1,N1]=validation(x1,y1);
   [r2,EE2,rmse2,bias2,N2]=validation(x1,y2);
   RS=[RS;r1,r2];
   RMSES=[RMSES;rmse1,rmse2];
   EES=[EES;EE1,EE2];
  MAODs=[MAODs;mean(x1),mean(y1),mean(y2)];
end
 set (gcf,'Position',[50,50,1450,800], 'color','w')
 set(gca,'FontSize',25,'Fontname','微软雅黑')
 subplot('Position',[0.07,0.62,0.42,0.35]);
 plotzhexian(RS,'R',0.5,1,0.1);
 
legend('Retrieved AOD','JAXA AOD','Location','southwest');
legend('boxoff');
 subplot('Position',[0.07,0.13,0.42,0.35]);
 plotzhexian(EES,'Within EE (%)',30,90,20);
 subplot('Position',[0.56,0.62,0.42,0.35]);
 plotzhexian(RMSES,'RMSE',0,0.5,0.1);
 subplot('Position',[0.56,0.13,0.42,0.35]);
 plotzhexian4(MAODs,'AOD',0,0.8,0.1);
 legend('AERONET AOD','Retrieved AOD','JAXA AOD','Location','northeast');
  legend('boxoff');
 x=1:12;
 y=zeros(1,12);
 %plot(x,y,'--b')
 c=1;
