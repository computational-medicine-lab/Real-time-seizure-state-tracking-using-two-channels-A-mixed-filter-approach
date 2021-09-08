function [params,a2]=ModelTraining(data1,data2,bestfeat)
%This code uses seizure one and seizure two (Combines them) and chosen
%binary and continuous features (online normalized) and trains EM. Outputs
%the State-Space parameters estimated using EM, and one figure. Also,
%chosen binary and continuous as well as the classifier for constructing
%binary feature is saved in params for simplicity of further loading
%variables (we won't need to load the bestfeat variable anymore)
%
%One very important point here is that this code uses only (3*seizure
%duration) pre and post seizure. By doing this, we are fastening the
%computation cost a lot. Also, the first second of the Z is -Inf, because
%we never computed the first second band powers (Since we used a window of
%1 second before each data point to compute band powers for that point), so
%we are just subtituting whatever value we have at second 1 for bandpowers
%from 0 to 1.
eval('pathnow= what;');
addpath([pathnow.path '\mixed']);
params.bina=[str2double(bestfeat{2,1}(10:12)),str2double(bestfeat{2,1}(32:34))];
params.bina_cls=bestfeat{3,1};
params.cont=[str2double(bestfeat{1,1}(10:12)),str2double(bestfeat{1,1}(32:34))];

Data=data1.Data;
szst=find(Data.labels==1,1,'first'); szen=find(Data.labels==1,1,'last'); szdu=szen-szst+1;
aa=max([Data.Wind+1,szst-ceil(3*szdu)]); bb=min([szen+ceil(3*szdu),length(Data.labels)]);
% aa=257; bb=size(Data.feat,3);
N1 = squeeze(Data.feat(params.bina(1),params.bina(2),:))';
N1 = (N1-min(N1(257:60*256)))./(max(N1(257:60*256)) - min(N1(257:60*256)));
N1 = N1 - mean(N1(257:60*256));
N1 = predict(params.bina_cls,N1')';
	
Z1 = (Z1-min(Z1(257:60*256)))./(max(Z1(257:60*256)) - min(Z1(257:60*256)));
Z1 = Z1 - mean(Z1(257:60*256));
labels1=Data.labels(aa:bb);
temp = Z1(aa:bb); clear Z1; Z1=temp;
temp = N1(aa:bb); clear N1; N1=temp;

Data=[]; Data=data2.Data;
szst=find(Data.labels==1,1,'first'); szen=find(Data.labels==1,1,'last'); szdu=szen-szst+1;
aa=max([Data.Wind+1,szst-ceil(3*szdu)]); bb=min([szen+ceil(3*szdu),length(Data.labels)]);
% aa=257; bb=size(Data.feat,3);
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


pcrit = 0.95;
backprobg = sum(labels==1)/length(labels); %starting probability of correct
startflag = 2;  %this can take values 0 or 2
                %0 fixes the initial condition at backprobg
                %2 initial condition is estimated

%these are all starting guesses
ialpha = Z(1); %guess it's the first value of Z
ibeta  = 1;
isig2e = 5;
isig2v = 5;
irho = 1; %fixed in this code
[params.alph, params.beta, params.gamma, params.rho, params.sig2e, params.sig2v, xnew, signewsq, params.muone, a] ...
                                 = mixedlearningcurve2(N, Z, backprobg, irho, ialpha, ibeta, isig2e, isig2v, startflag);


time=0:1/256:(length(N)-1)/256;

samples=1:length(Z); ccc=samples(N==1);
a2=figure; clf; set(a2,'color','w','units','normalized'); hold on;
% plot(time, xnew(2:end))
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