clc
clear all
load('AHIJAXAmatch.mat');
AEROAOD=double(AHIJAXAmatch(:,4));
AHIAOD=double(AHIJAXAmatch(:,5));
JAXAAOD=double(AHIJAXAmatch(:,6));
sitenames=unique(AHIJAXAmatch(:,1));
nums=length(sitenames);
resultAHI=[];
resultJAXA=[];
AERONETsites=importdata('2023AHIsitesuse.csv');

AERONETsitenames=AERONETsites.textdata;
AERONETsitelonlats=AERONETsites.data;

for i=1:nums
    index=find(sitenames(i)==AHIJAXAmatch(:,1));
    index1=find(sitenames(i)==AERONETsitenames);
    lon=AERONETsitelonlats(index1,1);
    lat=AERONETsitelonlats(index1,2);
    N=length(index);
    if N <10 
        continue
    end
    X=AHIJAXAmatch(index,4);
    X=double(X);
    YAHI=AHIJAXAmatch(index,5);
    YJAXA=AHIJAXAmatch(index,6);
    YAHI=double(YAHI);
    YJAXA=double(YJAXA);

    rAHI=corrcoef(double(YAHI),double(X));
    rJAXA=corrcoef(double(YJAXA),double(X));

    MAEAHI=mean(abs(double(YAHI)-double(X)));
    MAEJAXA=mean(abs(double(YJAXA)-double(X)));

    biasAHI=mean(double(YAHI)-double(X));
    biasJAXA=mean(double(YJAXA)-double(X));

    rmseAHI=sqrt(sum((double(YAHI)-double(X)).^2)/N);
     rmseJAXA=sqrt(sum((double(YJAXA)-double(X)).^2)/N);
    mAOD=mean(X);
withinAHI=0;
withinJAXA=0;
    for j=1:N
   
    aboveline=0.05+1.2*X(j);
    below_line=-0.05+0.8*X(j);
    if YAHI(j) >= below_line & YAHI(j) <= aboveline
        withinAHI=withinAHI+1;
    end
     if YJAXA(j) >= below_line & YJAXA(j) <= aboveline
        withinJAXA=withinJAXA+1;
    end
    
end


withinpercAHI=100*withinAHI/N;
withinpercJAXA=100*withinJAXA/N;
resultJAXA= [resultJAXA;sitenames(i),num2str(lon),num2str(lat),num2str(N),num2str(rJAXA(2,1)),num2str(rmseJAXA),num2str(MAEJAXA),num2str(biasJAXA),num2str(withinpercJAXA),num2str(mAOD)];  
resultAHI= [resultAHI;sitenames(i),num2str(lon),num2str(lat),num2str(N),num2str(rAHI(2,1)),num2str(rmseAHI),num2str(MAEAHI),num2str(biasAHI),num2str(withinpercAHI),num2str(mAOD)];
end
writematrix(resultAHI,'resultAHI.csv');
writematrix(resultJAXA,'resultJAXA.csv');