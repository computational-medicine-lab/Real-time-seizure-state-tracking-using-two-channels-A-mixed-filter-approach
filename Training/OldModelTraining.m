function [params,a2]=ModelTraining(Data,bestfeat)

eval('pathnow= what;');
addpath([pathnow.path '\mixed']);
params.bina=[str2double(bestfeat{2,1}(10:12)),str2double(bestfeat{2,1}(32:34))];
params.bina_cls=bestfeat{3,1};
params.cont=[str2double(bestfeat{1,1}(10:12)),str2double(bestfeat{1,1}(32:34))];


szst=find(Data.labels==1,1,'first'); szen=find(Data.labels==1,1,'last'); szdu=szen-szst+1;
aa=szst-ceil(10*szdu); bb=szen+ceil(10*szdu);
aa=257; bb=size(Data.feat,3);
N = squeeze(Data.feat(params.bina(1),params.bina(2),:))';
N = (N-min(N(257:60*256)))./(max(N(257:60*256)) - min(N(257:60*256)));
N = N - mean(N(257:60*256));
N=predict(params.bina_cls,N')';
Z = log(squeeze(Data.feat(params.cont(1),params.cont(2),:)))';
Z = (Z-min(Z(257:60*256)))./(max(Z(257:60*256)) - min(Z(257:60*256)));
Z = Z - mean(Z(257:60*256));


temp = Z(aa:bb); clear Z; Z=temp;
temp = N(aa:bb); clear N; N=temp;
pcrit = 0.95;
backprobg = sum(Data.labels(aa:bb))/(bb-aa); %starting probability of correct
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



N = squeeze(Data.feat(params.bina(1),params.bina(2),:))';
N = (N-min(N(257:60*256)))./(max(N(257:60*256)) - min(N(257:60*256)));
N = N - mean(N(257:60*256));
N=predict(bestfeat{3,1},N')';
Z = log(squeeze(Data.feat(params.cont(1),params.cont(2),:)))';
Z = (Z-min(Z(257:60*256)))./(max(Z(257:60*256)) - min(Z(257:60*256)));
Z = Z - mean(Z(257:60*256));
Z (1:aa-1)=Z (aa);

finalxnew=zeros(length(Z),1);
finalxnew(1:aa-1)=xnew(1);
finalxnew(aa:length(xnew)+aa-2)=xnew(2:end);
finalxnew(length(xnew)+aa-1:end)=xnew(end);

time=0:1/256:(length(N)-1)/256;

samples=1:length(Z); ccc=samples(N==1);
a2=figure; clf; set(a2,'color','w','units','normalized'); hold on;
plot(time, finalxnew)
hold on; plot(time,Z);
tempylim=ylim;
scatter(time(ccc),tempylim(2).*ones(length(ccc),1),'filled', 'MarkerFaceColor',[0 .7 .7]);
plot(time,Data.labels-abs(tempylim(1)),'LineWidth',4)
legend('estimated seizure state','continuous feature', 'binary feature','true seizure state')
box on
xlabel('Time (sec)')
xlim([min(time) max(time)])
set(gca,'LineWidth',4);
ylim(tempylim)
set(gca,'fontsize',12);