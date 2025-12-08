clc;
clear all;
%% 数据处理：ERA5、DEM重采样至0.02°
     core_number=8;
    parpool('local',core_number);
% DEM数据处理
DEMfile='I:\DEM\SRTM_AHI_2km.tif';
[DEMdataALL,R1]=geotiffread(DEMfile);
% DEMlonlimits=R1.LongitudeLimits;
% DEMlatlimits=R1.LatitudeLimits;
% line1=
DEMdata=DEMdataALL(:,1:3501);
% H9数据
H9dir='L:\H9NC\';
H9files=dir([H9dir,'*.nc']);

H9filenums=length(H9files);

H9dates=strings(H9filenums,1);
H9mons=zeros(H9filenums,1);
H9days=zeros(H9filenums,1);
H9times=zeros(H9filenums,1);
H9hours=zeros(H9filenums,1);
H9filenames=strings(H9filenums,1);
for h=1:H9filenums
        tmpname=H9files(h);
        name=tmpname.name;
     H9dates(h,1)=name(8:15);
     H9mons(h,1)=str2num(string(name(12:13)));
     H9days(h,1)=str2num(string(name(14:15)));
     H9hours(h,1)=str2num(string(name(18)));
     H9time=str2num(string(name(17:20)));
     H9times(h,1)=H9time;
     H9filenames(h,1)=[H9dir,tmpname.name];
end

load("AHIAODnet.mat");
load("inputps.mat");
load("outputps.mat");


for i=1:12
    if i<10 
       mon=num2str(i);
       ERA5file=strcat("I:\H9AODretrieval\ERA5\20230",mon,".nc");
    else
       mon=num2str(i);
       ERA5file=strcat("I:\H9AODretrieval\ERA5\2023",mon,".nc");
    end
    datatco3=ncread(ERA5file,'tco3');% lon lat  time 2:00 -9:00
    datastcwv=ncread(ERA5file,'tcwv');
    days=[31,29,31,30,31,30,31,31,30,31,30,31];
    hours=[2,3,4,5,6,7,8,9];
    udays=days(i);
    for j=1:udays% 日
       
           tday=j-1;
      
    for h=1:8% 每日8小时
            % 提取第tday天，第h+1小时的数据
            
            loc=tday*8+h;
            disp(strcat(num2str(i),"/",num2str(j),"/",num2str(h+1),"/","位次：",num2str(loc)))
            datatco3u=datatco3(:,:,loc);
            datastcwvu=datastcwv(:,:,loc);
            datatco3u=datatco3u';
            datastcwvu=datastcwvu';
            
          % lat 0-60  lon 80-150
            resampledO3 = imresize(datatco3u, [3001,3501], 'bilinear');
            resampledwv = imresize(datastcwvu, [3001,3501], 'bilinear');
            outdata=zeros(3001,3501);
            H9findex=find(H9mons==i & j==H9days & h+1==H9hours);
            UH9files=H9filenames(H9findex);
            ufilenum=length(H9findex);
            for ff=1:ufilenum
           %% 
             infile=UH9files(ff);
             Outnames=strsplit(infile,'\');
             outname=char(Outnames(3));
             uname=outname(1:20);
             Ofile1=['L:\outtif\',uname,'.tif']
             if exist(Ofile1, 'file') == 2
               continue
             end
               %% 读取数据
        SAA=ncread(infile,'SAA');
        SAZ=ncread(infile,'SAZ');
        SOA=ncread(infile,'SOA');
        SOZ=ncread(infile,'SOZ');
        albedo1=ncread(infile,'albedo_01');
        albedo2=ncread(infile,'albedo_02');
        albedo3=ncread(infile,'albedo_03');
        albedo4=ncread(infile,'albedo_04');
        albedo5=ncread(infile,'albedo_05');
        albedo6=ncread(infile,'albedo_06');
        TBB14=ncread(infile,'tbb_14');

        albedo1=albedo1' ; albedo2=albedo2';albedo3=albedo3';albedo4=albedo4';albedo5=albedo5';
        albedo6=albedo6' ;  SAA=SAA';  SAZ=SAZ'; SOA=SOA'; SOZ=SOZ';
        TBB14=TBB14';

        %% 数据截取
        albedo1=albedo1(1:3005,1:3505);albedo2=albedo2(1:3005,1:3505);albedo3=albedo3(1:3005,1:3505);
        albedo4=albedo4(1:3005,1:3505);albedo5=albedo5(1:3005,1:3505);albedo6=albedo6(1:3005,1:3505);
        SAA=SAA(1:3005,1:3505);SAZ=SAZ(1:3005,1:3505);SOA=SOA(1:3005,1:3505);SOZ=SOZ(1:3005,1:3505);
        TBB14=TBB14(1:3005,1:3505);
        
               %%
           
               parfor ppp=3:10 
                      read_H9_2(DEMdata,resampledO3,resampledwv,SAA,SAZ,SOA,SOZ,...
                       albedo1,albedo2,albedo3,albedo4,albedo5,albedo6,TBB14,ppp);
               end
               % parfor ppp=9:13 
               %        read_H9(DEMdata,resampledO3,resampledwv,SAA,SAZ,SOA,SOZ,...
               %         albedo1,albedo2,albedo3,albedo4,albedo5,albedo6,TBB14,ppp );
               % end
               parfor ppp=11:18 
                      read_H9_2(DEMdata,resampledO3,resampledwv,SAA,SAZ,SOA,SOZ,...
                       albedo1,albedo2,albedo3,albedo4,albedo5,albedo6,TBB14,ppp);
               end
                
               out=[];

                for fff=3:18 
                    oname=['temp.',num2str(fff),'.mat'];
                    load(oname);
                    out=[out;out1];
                    delete(oname);
                end
                
                inputdata=out(:,3:end)';
             inputn_test=mapminmax('apply',inputdata(:,:),inputps);
             an=sim(net,inputn_test);
             BPoutput=mapminmax('reverse',an,outputps);
              for ooo=1:length(BPoutput)
                  oline=out(ooo,1);
                  ocol=out(ooo,2);
                  outdata(oline,ocol)=BPoutput(ooo);
              end

               R = georasterref('RasterSize',size(outdata),'LatitudeLimits',[0,60],...
   'LongitudeLimits',[80,150]);
               geotiffwrite(Ofile1,flip(outdata),R);
             c=1;
            end
   
%        Ofile1=['I:\H9AODretrieval\ERA5\tif\O3.',mon,'.',num2str(j),'.',num2str(h+1),'.tif']
%        Ofile2=['I:\H9AODretrieval\ERA5\tif\WV.',mon,'.',num2str(j),'.',num2str(h+1),'.tif']
%    R = georasterref('RasterSize',size(resampledO3),'LatitudeLimits',[0,60],...
%        'LongitudeLimits',[80,150]);
% geotiffwrite(Ofile1,flip(resampledO3),R);
% geotiffwrite(Ofile2,flip(resampledwv),R);

         c=1;
        end
        
    end
    
end
delete(gcp('nocreate'));
function []=read_H9(DEMdata,resampledO3,resampledwv,SAA,SAZ,SOA,SOZ,...
                       albedo1,albedo2,albedo3,albedo4,albedo5,albedo6,TBB14,number)




        %% 左上点 80，60    lat 0-60  lon 80-150
        line=fix((60-0)./0.02)+1;% 3001
        col=fix((150-80)./0.02)+1;% 3501
          out1=[];
          t=tic;
       
        for ii=(number-1)*150+2:(number-1)*150+151 %2:3001
            for kk=2:col-200
          if DEMdata(ii,kk)<-2000
              continue
          end
          if TBB14(ii,kk) <273 
              continue
          end
            tepblue=  albedo1(ii,kk)./cosd(SOZ(ii,kk)) ;
          if tepblue<=0.001 | tepblue > 0.38 | SOZ(ii,kk) >=70 |SAZ(ii,kk) >=70;
              
              continue
          end
          tempmtrix=albedo1(ii-1:ii+1,kk-1:kk+1)./cosd(SOZ(ii-1:ii+1,kk-1:kk+1));
          sigmab=std([tempmtrix(:,1);tempmtrix(:,2);tempmtrix(:,3)]);
          Qsigmab=sigmab.*mean([tempmtrix(:,1);tempmtrix(:,2);tempmtrix(:,3)])./3;
          %Qsigmab=mean(TQsigmab);
          NDSI=(albedo2(ii,kk)-albedo5(ii,kk))./...
               (albedo2(ii,kk)+albedo5(ii,kk));
          if ((sigmab > 0.0065) & (Qsigmab > 0.002) )
            continue
          end
          if sigmab >0.01
           continue
          end

          if NDSI>0.35 
                continue
          end 
  

     out1=[out1;ii,kk,SAA(ii,kk),SAZ(ii,kk),SOA(ii,kk),SOZ(ii,kk),...
          albedo1(ii,kk)./cosd(SOZ(ii,kk)),albedo2(ii,kk)./cosd(SOZ(ii,kk)),albedo3(ii,kk)./cosd(SOZ(ii,kk)),albedo4(ii,kk)./cosd(SOZ(ii,kk)),albedo5(ii,kk)./cosd(SOZ(ii,kk)),albedo6(ii,kk)./cosd(SOZ(ii,kk)),...
          double(DEMdata(ii,kk)),resampledO3(ii,kk),resampledwv(ii,kk)];
    c=2;
            end
        end
        
     oname=['temp.',num2str(number),'.mat'];
         save(oname,'out1');
     %      costtime=toc(t)


end
function []=read_H9_2(DEMdata,resampledO3,resampledwv,SAA,SAZ,SOA,SOZ,...
                       albedo1,albedo2,albedo3,albedo4,albedo5,albedo6,TBB14,number)
%%二维数组转一维



        %% 左上点 80，60    lat 0-60  lon 80-150
         line=fix((60-0)./0.02)+1;% 3001
         col=fix((150-80)./0.02)+1;% 3501
         out1=[];
         
             %% 切块
               subDEM=DEMdata((number-1)*150+2:(number-1)*150+151,2:col-200);
               subTBB14=TBB14((number-1)*150+2:(number-1)*150+151,2:col-200);

               subSOZ=SOZ((number-1)*150+2:(number-1)*150+151,2:col-200);
               subSAZ=SAZ((number-1)*150+2:(number-1)*150+151,2:col-200);
               subSAA=SAA((number-1)*150+2:(number-1)*150+151,2:col-200);
               subSOA=SOA((number-1)*150+2:(number-1)*150+151,2:col-200);

               subalbedo1=albedo1((number-1)*150+2:(number-1)*150+151,2:col-200);
               subalbedo2=albedo2((number-1)*150+2:(number-1)*150+151,2:col-200);
               subalbedo3=albedo3((number-1)*150+2:(number-1)*150+151,2:col-200);
               subalbedo4=albedo4((number-1)*150+2:(number-1)*150+151,2:col-200);
               subalbedo5=albedo5((number-1)*150+2:(number-1)*150+151,2:col-200);
               subalbedo6=albedo6((number-1)*150+2:(number-1)*150+151,2:col-200);

               subresampledO3=resampledO3((number-1)*150+2:(number-1)*150+151,2:col-200);
               subresampledwv=resampledwv((number-1)*150+2:(number-1)*150+151,2:col-200);
             
              %% 二维转一维
               subsizes=size(subDEM);
               subnumbs=subsizes(1).*subsizes(2);

               subDEM1=reshape(subDEM,1,subnumbs); subresampledwv1=reshape(subresampledwv,1,subnumbs);
               subresampledO31=reshape(subresampledO3,1,subnumbs);subTBB141=reshape(subTBB14,1,subnumbs);
               subSOZ1=reshape(subSOZ,1,subnumbs); subSAZ1=reshape(subSAZ,1,subnumbs);
               subSAA1=reshape(subSAA,1,subnumbs); subSOA1=reshape(subSOA,1,subnumbs);

               subalbedo1_1=reshape(subalbedo1,1,subnumbs);subalbedo2_1=reshape(subalbedo2,1,subnumbs);
               subalbedo3_1=reshape(subalbedo3,1,subnumbs);subalbedo4_1=reshape(subalbedo4,1,subnumbs);
               subalbedo5_1=reshape(subalbedo5,1,subnumbs);subalbedo6_1=reshape(subalbedo6,1,subnumbs);

               for ii=1:subnumbs
               
          if subDEM1(ii)<-2000
             continue
          end
          if subTBB141(ii) <273 
              continue
          end
            tepblue=  subalbedo1_1(ii)./cosd(subSOZ1(ii)) ;
          if tepblue<=0.001 | tepblue > 0.38 | subSOZ1(ii) >=70 |subSAZ1(ii) >=70;
              continue
          end

          %% 计算ii位置对应的行列号   ii/hang 的余数(0时为行数) 为行号  ii/hang 向上取整为列号
          iii=mod(ii,subsizes(1));
          kkk=ceil(ii/subsizes(1));
          if iii==0 
              iii=subsizes(1);
          end

          tempmtrix=albedo1((iii+(number-1)*150+1)-1:(iii+(number-1)*150+1)+1,kkk:kkk+2)./cosd(SOZ((iii+(number-1)*150+1)-1:(iii+(number-1)*150+1)+1,kkk:kkk+2));
          sigmab=std([tempmtrix(:,1);tempmtrix(:,2);tempmtrix(:,3)]);
          Qsigmab=sigmab.*mean([tempmtrix(:,1);tempmtrix(:,2);tempmtrix(:,3)])./3;
          %Qsigmab=mean(TQsigmab);
          NDSI=(subalbedo2_1(ii)-subalbedo5_1(ii))./...
               (subalbedo2_1(ii)+subalbedo5_1(ii));
          if ((sigmab > 0.0065) & (Qsigmab > 0.002) )
            continue
          end
          if sigmab >0.01
           continue
          end

          if NDSI>0.35 
                continue
          end 
    
      % iii+(number-1)*150+1,kkk+1是在初始数组里的行列号
      %test=[albedo1(iii+(number-1)*150+1,kkk+1);subalbedo1_1(ii)];
     out1=[out1;iii+(number-1)*150+1,kkk+1,subSAA1(ii),subSAZ1(ii),subSOA1(ii),subSOZ1(ii),...
          subalbedo1_1(ii)./cosd(subSOZ1(ii)),subalbedo2_1(ii)./cosd(subSOZ1(ii)),subalbedo3_1(ii)./cosd(subSOZ1(ii)),...
          subalbedo4_1(ii)./cosd(subSOZ1(ii)),subalbedo5_1(ii)./cosd(subSOZ1(ii)),subalbedo6_1(ii)./cosd(subSOZ1(ii)),...
          double(subDEM1(ii)),subresampledO31(ii),subresampledwv1(ii)];
    c=2;
            end
    
        
     oname=['temp.',num2str(number),'.mat'];
         t=tic;
         save(oname,'out1');
         costtime=toc(t);
         disp(['保存/',oname,'用时：',num2str(costtime)]);


end


