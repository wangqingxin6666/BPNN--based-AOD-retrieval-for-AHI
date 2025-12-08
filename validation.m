function [r1,EE,rmse,bias,N]=validation(x,y)

       N=length(x);
   %% 线性拟合 计算 r,
    [p,s]=polyfit(x,y,1);
    r=corrcoef(x,y);
    r1=r(1,2);
    %% RMSE
    rmse=sqrt(sum((y-x).^2)/N);
     su=0;
    within=0;
    above=0;
    below=0;
for j=1:N
    su=su+abs(y(j)-x(j))/x(j);
    aboveline=0.05+1.2*x(j);
    below_line=-0.05+0.8*x(j);
    if y(j) >= below_line & y(j) <= aboveline
        within=within+1;
    end
     if y(j) > aboveline
        above=above+1;
     end
     if y(j) < below_line
        below=below+1;
     end 
end
  mre=su/N;
    %% EE
    
  EE=100*within/N;
  aboveperc=100*above/N;
  belowperc=100*below/N;
    %%
    bias=mean(y-x);
end