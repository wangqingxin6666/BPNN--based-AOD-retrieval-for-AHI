clc;
clear all;
%% 功能：不分季节，每次一个月份留下作为验证
rng(42, 'twister');%固定随机种子 减小结果随机性
load('ALLdatamatchA.mat');%AERONET站点处提取的数据
load("ALLdatamatchF.mat");

%% 基于全部站点的试验，MAIAC AOD为训练目标
datanums0=length(MatchdataAddERA5F);
datanums00=length(MatchdataAddERA5A);

dataindex1s=1:datanums00;

dataindex2s=datanums00+1:datanums0+datanums00;


MatchdataAddERA5F=[MatchdataAddERA5F,dataindex2s';MatchdataAddERA5A(:,1:25),MatchdataAddERA5A(:,27:29),dataindex1s'];
AERONETAODraw=MatchdataAddERA5A(:,26);

datanums=length(MatchdataAddERA5F);
datanums2=length(MatchdataAddERA5A);

randindex=randperm(datanums);
randindex2=randperm(datanums2);

tempdata=MatchdataAddERA5F;
MatchdataAddERA5F(randindex,:)=MatchdataAddERA5F;

MatchdataAddERA5A(randindex2,:)=MatchdataAddERA5A;

traindata=MatchdataAddERA5F(:,6:28);
traindata2=[MatchdataAddERA5A(:,6:25),MatchdataAddERA5A(:,27:29)];

datesF=MatchdataAddERA5F(:,2);
datesA=MatchdataAddERA5A(:,2);

monsF=floor((datesF-20230000)/100);
monsA=floor((datesA-20230000)/100);
sitenames=MatchdataAddERA5F(:,29);
% 
springmon=[3,4,5];
summermon=[6,7,8];
fallmon=[9,10,11];
wintermon=[1,2,12];


% 6-9 ：angle1 angle2 angle3 angle4
% 10-15： albedo 1-6
% 16-25：TBB 07-16
% 26-28： DEM, O3,water

%% 输入数据
%datain=[traindata(:,1:10),traindata(:,21:23),bandrato1,bandrato2,NDVI86];
%datain=[traindata(:,1:10),traindata(:,21:23)];
datain=[traindata(:,1:4),traindata(:,5)./cosd(traindata(:,4)),traindata(:,6)./cosd(traindata(:,4)),traindata(:,7)./cosd(traindata(:,4)),traindata(:,8)./cosd(traindata(:,4)),...
        traindata(:,9)./cosd(traindata(:,4)),traindata(:,10)./cosd(traindata(:,4)),traindata(:,21:23)];% albedo变reflectance
datain2=[traindata2(:,1:4),traindata2(:,5)./cosd(traindata2(:,4)),traindata2(:,6)./cosd(traindata2(:,4)),traindata2(:,7)./cosd(traindata2(:,4)),traindata2(:,8)./cosd(traindata2(:,4)),...
        traindata2(:,9)./cosd(traindata2(:,4)),traindata2(:,10)./cosd(traindata2(:,4)),traindata2(:,21:23)];% albedo变reflectance

% 1-4 角度 | 5-10： albedo 1-6 | 11-13： DEM O3 water | 14-16： BR1 BR2 NDVI
%% 目标数据
datao=[MatchdataAddERA5F(:,5)];% MODIS  AOD
datao2=[MatchdataAddERA5A(:,26)];% AERONET  AOD



seasonmons=[3,4,5;6,7,8,;9,10,11;12,1,2];


%% 2. 以MODIS AOD为目标
numFeatures=length(datao);
AERONETsitedata=[];
BPoutputRawsm=[];
ValALLrawsm=[];
    for fold=1:4
        selectedFeatures = true(1, numFeatures);

        index2valid1=find(monsF==seasonmons(fold,1));
        index2valid2=find(monsF==seasonmons(fold,2));
        index2valid3=find(monsF==seasonmons(fold,3));

        index2valids=[index2valid1;index2valid2;index2valid3];%;index2valid4;index2valid5;index2valid6];
        


       % index2valids=find(monsF==fold);
        selectedFeatures(index2valids)=false;

        
        traind= find(selectedFeatures);
        valInd=find(selectedFeatures==0);
 
        input_train=datain(traind,:)';
        output_train=datao(traind,:)';

        input_val=datain(valInd,:)';
        output_val=datao(valInd,:)';


        Outdataloc=sitenames(valInd,:)';

        [inputn,inputps]=mapminmax(input_train(:,:));
        [outputn,outputps]=mapminmax(output_train(:,:));
        inputn_test=mapminmax('apply',input_val(:,:),inputps);
        %初始化网络
        net=newff(inputn,outputn,[20,20,20,20,20]);
        net.trainParam.epochs=200;
        net.trainParam.lr=0.01;
        net.trainParam.goal=0.0001;
        net.trainParam.showWindow=false;
        net=train(net,inputn,outputn);

        % 测试集上进行评估
        an=sim(net,inputn_test);
        % 反归一化
        BPoutputRaw=mapminmax('reverse',an,outputps);
        BPoutputRawsm=[BPoutputRawsm;BPoutputRaw'];
        ValALLrawsm=[ValALLrawsm;output_val'];

     AEORindex=find(Outdataloc<=datanums00);
       if ~isempty(AEORindex)
            AERONETsitedata=[AERONETsitedata;Outdataloc(AEORindex)',BPoutputRaw(AEORindex)',output_val(AEORindex)'];

       end
    
    end


 %% 匹配AERONET AOD
for pp=1:datanums00
     flag=AERONETsitedata(pp,1);
     AERONETAOD=AERONETAODraw(flag);
    AERONETsitedata(pp,1)=AERONETAOD;% AERONET pred MODIS
end


%% 以AERONET AOD为目标
numFeatures=length(datao2);
BPoutputRawsA=[];
ValALLrawsA=[];
    for fold=1:4


        selectedFeatures = true(1, numFeatures);

        index2valid1=find(monsA==seasonmons(fold,1));
        index2valid2=find(monsA==seasonmons(fold,2));
        index2valid3=find(monsA==seasonmons(fold,3));
         % index2valid4=find(monsA==halfyear(fold,4));
         %  index2valid5=find(monsA==halfyear(fold,5));
         %   index2valid6=find(monsA==halfyear(fold,6));
        
        
        
        index2valids=[index2valid1;index2valid2;index2valid3];%index2valid4;index2valid5;index2valid6];
        

       % index2valids=find(monsA==fold);
        selectedFeatures(index2valids)=false;

        
        traind= find(selectedFeatures);
        valInd=find(selectedFeatures==0);
 
        input_train=datain2(traind,:)';
        output_train=datao2(traind,:)';

        input_val=datain2(valInd,:)';
        output_val=datao2(valInd,:)';


        [inputn,inputps]=mapminmax(input_train(:,:));
        [outputn,outputps]=mapminmax(output_train(:,:));
        inputn_test=mapminmax('apply',input_val(:,:),inputps);
        %初始化网络
        net=newff(inputn,outputn,[20,20,20,20,20]);
        net.trainParam.epochs=200;
        net.trainParam.lr=0.01;
        net.trainParam.goal=0.0001;
        net.trainParam.showWindow=false;
        net=train(net,inputn,outputn);

        % 测试集上进行评估
        an=sim(net,inputn_test);
        % 反归一化
        BPoutputRaw=mapminmax('reverse',an,outputps);
        BPoutputRawsA=[BPoutputRawsA;BPoutputRaw'];
        ValALLrawsA=[ValALLrawsA;output_val'];

    end


%% 画图


 set (gcf,'Position',[100,10,1500,450], 'color','w')
 subplot('Position',[0.05,0.2,0.26,0.75]);
 plot_densityTMP(ValALLrawsm,BPoutputRawsm,'MAIAC AOD (550 nm)','MAIAC-Trained AOD (550 nm)','(d)',' ');
 subplot('Position',[0.37,0.2,0.26,0.75]);
 plot_densityTMP(ValALLrawsA,BPoutputRawsA,'AERONET AOD (550 nm)','AERONET-Trained AOD (550 nm)','(e)',' ');

 OresultMAIAC=[ValALLrawsm,BPoutputRawsm];
 OresultAERONET=[ValALLrawsA,BPoutputRawsA];
 subplot('Position',[0.69,0.2,0.307,0.75]);
 plot_densityTM(AERONETsitedata(:,1),AERONETsitedata(:,2),'AERONET AOD (550 nm)','MAIAC-Trained AOD (550 nm)','(f)',' ');




 