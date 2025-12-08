clc;
clear all;
%% 功能：基于站点的整体验证
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

sitenames=MatchdataAddERA5F(:,29);
sitenumbers=MatchdataAddERA5F(:,1);
sitenumbersA=MatchdataAddERA5A(:,1);
usitenumbers=unique(sitenumbers);
usiteAER=unique(MatchdataAddERA5A(:,1));

siteallnum=length(usitenumbers);
siteAERnum=length(usiteAER);

% MatchdataAddERA5F   traindata  sitenames
% 和 sitenumbers   顺序一致  后面datain和以上顺序一致


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



%% 训练样本
Allline=length(datain(:,1));
cv = cvpartition(usitenumbers, 'KFold', 5);  % 站点随机分成五等份
cv2= cvpartition(usiteAER, 'KFold', 5);  % AERONET站点随机分成五等份

%% 2. 以MODIS AOD为目标

valInd= test(cv, 1);
num1index=find(valInd==1);
datasizes=length(num1index);

AERONETsitedata=[];
BPoutputRawsm=[];
ValALLrawsm=[];
    for fold=1:5
        trainInd = training(cv, fold);
        valInd= test(cv, fold);
        
        trainsites=usitenumbers(trainInd);
        testsites =usitenumbers(valInd);
        trainsiteindexs=[];
        testsiteindexs=[];
        for ss=1:length(trainsites)
              trainsiteindex=find(sitenumbers==trainsites(ss));
              trainsiteindexs=[trainsiteindexs;trainsiteindex];
        end
        for ss=1:length(testsites)
            testsiteindex=find(sitenumbers==testsites(ss));
            testsiteindexs=[testsiteindexs;testsiteindex];
        end


        input_train=datain(trainsiteindexs,:)';
        output_train=datao(trainsiteindexs,:)';

        Traindataloc=sitenames(trainsiteindexs,:)';
        Outdataloc=sitenames(testsiteindexs,:)';

        input_val=datain(testsiteindexs,:)';
        output_val=datao(testsiteindexs,:)';

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

%% 画图
% set (gcf,'Position',[100,10,1500,550], 'color','w')
% %subplot('Position',[0.08,0.2,0.4,0.7]);
% %plot_densityT(ValALLm(:,featureToRemovet),BPoutputALLm(:,featureToRemovet),'MODIS AOD','Trained-AOD(Final)','(a)',num2str(featureToRemovet));
%  subplot('Position',[0.08,0.2,0.4,0.75]);
%  plot_densityT(AERONETsitedata(:,1),AERONETsitedata(:,2),'AERONET AOD (550 nm)','MAIAC-Trained AOD (550 nm)','(c)',' ');
%  subplot('Position',[0.55,0.2,0.4,0.75]);
%  plot_densityT(AERONETsitedata(:,1),AERONETsitedata(:,3),'AERONET AOD (550 nm)','MAIAC AOD (550 nm) ','(d)',' ');
% 


%% 以AERONET AOD为目标
BPoutputRawsA=[];
ValALLrawsA=[];
    for fold=1:5

        trainInd = training(cv2, fold);
        valInd= test(cv2, fold);
        
        trainsites=usiteAER(trainInd);
        testsites =usiteAER(valInd);
        trainsiteindexs=[];
        testsiteindexs=[];
        for ss=1:length(trainsites)
              trainsiteindex=find(sitenumbersA==trainsites(ss));
              trainsiteindexs=[trainsiteindexs;trainsiteindex];
        end
        for ss=1:length(testsites)
            testsiteindex=find(sitenumbersA==testsites(ss));
            testsiteindexs=[testsiteindexs;testsiteindex];
        end

        input_train=datain2(trainsiteindexs,:)';
        output_train=datao2(trainsiteindexs,:)';

        input_val=datain2(testsiteindexs,:)';
        output_val=datao2(testsiteindexs,:)';

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

% 测试集评估

% set (gcf,'Position',[100,10,1500,550], 'color','w')
% %subplot('Position',[0.08,0.2,0.4,0.7]);
% %plot_densityT(ValALLm(:,featureToRemovet),BPoutputALLm(:,featureToRemovet),'MODIS AOD','Trained-AOD(Final)','(a)',num2str(featureToRemovet));
%  subplot('Position',[0.08,0.2,0.4,0.75]);
%  plot_densityT(ValALLrawsm,BPoutputRawsm,'MAIAC AOD (550 nm)','MAIAC-Trained AOD (550 nm)','(a)',' ');
%  subplot('Position',[0.55,0.2,0.4,0.75]);
%  plot_densityT(ValALLrawsA,BPoutputRawsA,'AERONET AOD (550 nm)','AERONET-Trained AOD (550 nm)','(b)',' ');

 set (gcf,'Position',[100,10,1500,450], 'color','w')
 subplot('Position',[0.05,0.2,0.26,0.75]);
 plot_densityTMP(ValALLrawsm,BPoutputRawsm,'MAIAC AOD (550 nm)','MAIAC-Trained AOD (550 nm)','(a)',' ');
 subplot('Position',[0.37,0.2,0.26,0.75]);
 plot_densityTMP(ValALLrawsA,BPoutputRawsA,'AERONET AOD (550 nm)','AERONET-Trained AOD (550 nm)','(b)',' ');

 OresultMAIAC=[ValALLrawsm,BPoutputRawsm];
 OresultAERONET=[ValALLrawsA,BPoutputRawsA];
 subplot('Position',[0.69,0.2,0.307,0.75]);
 plot_densityTM(AERONETsitedata(:,1),AERONETsitedata(:,2),'AERONET AOD (550 nm)','MAIAC-Trained AOD (550 nm)','(c)',' ');




 % OresultMAIAC=[ValALLrawsm,BPoutputRawsm];
 % OresultAERONET=[ValALLrawsA,BPoutputRawsA];
 % save('OresultMAIAC.mat','OresultMAIAC');
 %  save('OresultAERONET.mat','OresultAERONET');



 