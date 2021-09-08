function [MES,SES]=ValidationRun(data1,data2,params)
%This code gets the first and second seizures, parameteres found during
%the feature selection (including the trained classifier for binarization)
% This code uses this input, and construct the online normalized continuous 
% and binary feature, then run the forward filter and estimates the 
% continuous seizure state
Data=data1.Data;
aa=257; bb=size(Data.feat,3);
N1 = squeeze(Data.feat(params.bina(1),params.bina(2),:))';
N1 = (N1-min(N1(257:60*256)))./(max(N1(257:60*256)) - min(N1(257:60*256)));
N1 = N1 - mean(N1(257:60*256));
N1=predict(params.bina_cls,N1')';
Z1 = log(squeeze(Data.feat(params.cont(1),params.cont(2),:)))';
Z1 = (Z1-min(Z1(257:60*256)))./(max(Z1(257:60*256)) - min(Z1(257:60*256)));
Z1 = Z1 - mean(Z1(257:60*256));
labels1=Data.labels(aa:bb);
temp = Z1(aa:bb); clear Z; Z1=temp;
temp = N1(aa:bb); clear N; N1=temp;

Data=[]; Data=data2.Data;

aa=257; bb=size(Data.feat,3);
N2 = squeeze(Data.feat(params.bina(1),params.bina(2),:))';
N2 = (N2-min(N2(257:60*256)))./(max(N2(257:60*256)) - min(N2(257:60*256)));
N2 = N2 - mean(N2(257:60*256));
N2=predict(params.bina_cls,N2')';
Z2 = log(squeeze(Data.feat(params.cont(1),params.cont(2),:)))';
Z2 = (Z2-min(Z2(257:60*256)))./(max(Z2(257:60*256)) - min(Z2(257:60*256)));
Z2 = Z2 - mean(Z2(257:60*256));
labels2=Data.labels(aa:bb);
temp = Z2(aa:bb); clear Z; Z2=temp;
temp = N2(aa:bb); clear N; N2=temp;

labels=[labels1,labels2];
N=[N1,N2]; Z=[Z1,Z2];




rho = params.rho;  
beta = params.beta;  
alpha = params.alph;  
sig2e = params.sig2e;                    
sig2v = params.sig2v;  
gamma=params.gamma;
muone = params.muone;

xguess = 0; 

[xfilt, sfilt, xold, sold] ... 
    = recfilter(N, Z, sig2e, sig2v, xguess, muone, rho, beta, alpha, gamma);

MES=xfilt(2:end);%Mean of Estimated Seizure

SES=sfilt(1); 
SES=sfilt(2:end);%Standard deviation of Estimated Seizure
time=0:1/256:(length(N)-1)/256;

samples=1:length(Z); ccc=samples(N==1);
a2=figure; clf; set(a2,'color','w','units','normalized'); hold on;
plot(time, MES)
hold on; plot(time,Z);
tempylim=ylim;
scatter(time(ccc),tempylim(2).*ones(length(ccc),1),'filled', 'MarkerFaceColor',[0 .7 .7]);
plot(time,labels-abs(tempylim(1)),'LineWidth',4)
legend('estimated seizure state','continuous feature', 'binary feature','true seizure state')
box on
xlabel('Time (sec)')
xlim([min(time) max(time)])
set(gca,'LineWidth',4);
ylim(tempylim)
set(gca,'fontsize',12);
end