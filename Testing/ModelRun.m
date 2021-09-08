function [a2,thresholded]=ModelRun(Data,Params,Thresholds)
%This code gets the data, parameteres found during the feature selection
%(including the trained classifier for binarization), and the trained 
%classifier during training for classification of binary seizure state
%using continuous seizure state. 
% This code uses this input, and construct the online normalized continuous 
% and binary feature, then run the forward filter and estimates the 
% continuous seizure state, then it uses the trained classifier and outputs 
% the binary seizure state as well as the figure.


aa=(Data.Wind)+1; bb=length(Data.labels);
N = squeeze(Data.feat(Params.bina(1),Params.bina(2),:))';
N = (N-min(N(257:60*256)))./(max(N(257:60*256)) - min(N(257:60*256)));
N = N - mean(N(257:60*256));
N=predict(Params.bina_cls,N')';
Z = log(squeeze(Data.feat(Params.cont(1),Params.cont(2),:)))';
Z = (Z-min(Z(257:60*256)))./(max(Z(257:60*256)) - min(Z(257:60*256)));
Z = Z - mean(Z(257:60*256));




rho = Params.rho;  
beta = Params.beta;  
alpha = Params.alph;  
sig2e = Params.sig2e;                    
sig2v = Params.sig2v;  
gamma=Params.gamma;
muone = Params.muone;

xguess = 0; 

[xfilt, sfilt, xold, sold] ... 
    = recfilter(N(aa:bb), Z(aa:bb), sig2e, sig2v, xguess, muone, rho, beta, alpha, gamma);
MES(1:aa-1)=xfilt(1); %Mean of Estimated Seizure
MES(aa:length(xfilt)+aa-2)=xfilt(2:end);
% 
% SES(1:aa-1)=sfilt(1); %Standard deviation of Estimated Seizure
% SES(aa:length(sfilt)+aa-2)=sfilt(2:end);
% 
% proba=MES./SES;
thresholded = predict(Thresholds.clf,(MES)')';

N = squeeze(Data.feat(Params.bina(1),Params.bina(2),:))';
N = (N-min(N(257:60*256)))./(max(N(257:60*256)) - min(N(257:60*256)));
N = N - mean(N(257:60*256));
N = predict(Params.bina_cls,N')';
Z = log(squeeze(Data.feat(Params.cont(1),Params.cont(2),:)))';
Z = (Z-min(Z(257:60*256)))./(max(Z(257:60*256)) - min(Z(257:60*256)));
Z = Z - mean(Z(257:60*256));
Z (1:aa-1) = Z (aa);
time = 0:1/256:(length(N)-1)/256;

samples = 1:length(Z); 
ccc = samples(N==1);



%Ploting
a2=figure;
l1=line(time,Z,'Color',[0,0.45,0.55],'LineWidth',1);
xlim([min(time) max(time)])
ax1 = gca;
xlabel(ax1,'Time (Sec)','Color','k','FontName','Times New Roman')
ylabel(ax1,'Normalized Continuous Feature (Unitless)','Color',[0,0.45,0.55],'FontName','Times New Roman')
set(gca,'FontSize',11)
set(gca,'LineWidth',1)
ax1.YColor = [0,0.45,0.55];
ax1_pos = ax1.Position;
ax2 = axes('Position',ax1_pos,...
    'XAxisLocation','top',...
    'YAxisLocation','right',...
    'Color','none');
l2=line(time,MES,'Parent',ax2,'Color','r','LineWidth',1);
ax2.YColor = 'r';
ylabel(ax2,'Estimated Seizure State (Unitless)','Color','r','FontName','Times New Roman')
set(gca,'FontSize',11)
set(gca,'LineWidth',1)
xticks([])
xlim([min(time) max(time)])
hold on;
tempylim=ylim;
seizuretime=time(find(Data.labels==1));
ttime=[seizuretime, fliplr(seizuretime)];
inbetween=[tempylim(1).*ones(1,length(seizuretime)),fliplr(tempylim(2).*ones(1,length(seizuretime)))];
h=fill(ttime,inbetween,[0.5,0.5,0.5]);
set(h,'edgecolor',[0.5,0.5,0.5])
set(h,'facealpha',.3)
l3=scatter(time(ccc),tempylim(2).*ones(length(ccc),1),'filled', 'MarkerFaceColor',[0 .7 .7],'LineWidth',1);
legend([l3],{'Binary Feature'},'Location','southeast','FontName','Times New Roman');

end