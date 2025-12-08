clc;
clear all;
load('A9AODNEWnotrain2.mat');
load('JAXAAODnotrain.mat');
sitefile='I:\H9AODretrieval\sitesreal\2023AHIsitesuse.csv';
AERONETdata=importdata(sitefile);
AERONETsites=AERONETdata.textdata;
sitesnums=length(AERONETsites);
matchdata=[];
for i=1:sitesnums
    sitename=AERONETsites{i}
  
    AERONETfile=['I:\AERONET15\2023AHI\csvnew\',sitename,'AOD550.csv'];
    AERdata=importdata(AERONETfile);
    indexs=find(string(sitename)==AHIusedata(:,1));
    A9data=AHIusedata(indexs,:);
    datanums=length(A9data);
    for ii=1:datanums
       tmpdata=A9data(ii,:);
       A9date=tmpdata(1,4);
       A9time=tmpdata(1,5);
       A9AOD=tmpdata(1,6);
       indexsuse=find(str2num(A9date)==AERdata(:,1) & abs(str2num(A9time)-AERdata(:,2))<=30);
       if length(indexsuse) <2
           continue;
       end
      OAERAOD=mean(AERdata(indexsuse,5));
       matchdata=[matchdata;sitename,A9date,A9time,OAERAOD,A9AOD];
      c=1;
    end

    
    c=1;
end
matchdatax=double(matchdata(:,4));
matchdatay=double(matchdata(:,5));

matchdataJAXA=[];
for i=1:sitesnums
    sitename=AERONETsites{i}
  
    AERONETfile=['I:\AERONET15\2023AHI\csvnew\',sitename,'AOD550.csv'];
    AERdata=importdata(AERONETfile);
    indexs=find(string(sitename)==JAXAusedata(:,1));
    A9data=JAXAusedata(indexs,:);
    datanums=length(A9data);
    for ii=1:datanums
       tmpdata=A9data(ii,:);
       A9date=tmpdata(1,2);
       A9time=tmpdata(1,3);
       if str2num(A9time)<200 | str2num(A9time) >850 
           continue
       end
       A9AOD=tmpdata(1,4);
       indexsuse=find(str2num(A9date)==AERdata(:,1) & abs(str2num(A9time)-AERdata(:,2))<=30);
       if length(indexsuse) <2
           continue;
       end
      OAERAOD=mean(AERdata(indexsuse,5));
      AE=mean(AERdata(indexsuse,4));
      A9AOD550=str2num(A9AOD)*((550.0/500)^AE);
       matchdataJAXA=[matchdataJAXA;sitename,A9date,A9time,OAERAOD,A9AOD550];
      c=1;
    end

    
    c=1;
end
matchdataJAXAx=double(matchdataJAXA(:,4));
matchdataJAXAy=double(matchdataJAXA(:,5));


%%反演结果和 JAXA产品匹配
usenums=length(matchdata);
AHIJAXAmatch=[];
for  i=1:usenums
    sitename=matchdata(i,1);
    AHIyymmdd=matchdata(i,2);
    AHImm=matchdata(i,3);
    AERAOD=matchdata(i,4);
    AHIAOD=matchdata(i,5);
    index=find(sitename==matchdataJAXA(:,1) & AHIyymmdd== matchdataJAXA(:,2) & AHImm==matchdataJAXA(:,3)& str2num(AERAOD)<4)
     if isempty(index)
         continue
     end
     AHIJAXAmatch=[AHIJAXAmatch;matchdata(i,:),matchdataJAXA(index,5)];
end
matchdataAERx=double(AHIJAXAmatch(:,4));
matchdataAHIy=double(AHIJAXAmatch(:,5));
matchdataJAXAy=double(AHIJAXAmatch(:,6));

lt1=find(matchdataAERx < 1)
per=length(lt1)/length(matchdataAERx)
%set (gcf,'Position',[100,10,1500,550], 'color','w')
 %subplot('Position',[0.08,0.2,0.4,0.75]);
% plot_density2(matchdataAERx,matchdataAHIy,'AERONET AOD (550 nm)','Retrieved AOD (550 nm)','(c)',' ');
 %subplot('Position',[0.55,0.2,0.4,0.75]);
 %plot_density2(matchdataAERx,matchdataJAXAy,'AERONET AOD (550 nm)','JAXA AOD (550 nm)','(d)',' ');
 %   set(gcf,'Position',[100,50,1600,850], 'color','w')
 % 
 % 
 % subplot('Position',[0.07,0.4,0.4,0.55]);
 % plot_density2(matchdataAERx,matchdataAHIy,'AERONET AOD(550 nm)','Retrieved AOD (550 nm)','');
 % subplot('Position',[0.07,0.1,0.4,0.3]);
 % errorbar2(matchdataAERx,matchdataAHIy,'AERONET AOD(550 nm)','Retrieved AOD (550 nm)','(c)');
 % subplot('Position',[0.54,0.4,0.4365,0.55])
 % plot_density2(matchdataAERx,matchdataJAXAy,'AERONET AOD(550 nm)','JAXA AOD(550 nm)','');
 %  caxis([0,100]);
 %  colorbar;
 % subplot('Position',[0.54,0.1,0.4,0.3]);
 % errorbar2(matchdataAERx,matchdataJAXAy,'AERONET AOD(550 nm)','JAXA AOD bias','(d)');
save('AHIJAXAmatch.mat','AHIJAXAmatch');
save('matchdata.mat','matchdata');
save('matchdataJAXA.mat','matchdataJAXA');

