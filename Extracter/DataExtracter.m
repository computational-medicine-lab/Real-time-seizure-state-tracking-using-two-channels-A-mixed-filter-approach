function FinalData_V2=DataExtracter(filepath,SS)
%This code goes through each session, and first splits sessions into
%subsession with one seizure (if the session had more than one seizure),
%and then extract the band power for each seizure. At the end, it will
%outputs n dataset, when n is number of seizures in the session.
numofseiz=size(SS,1);
E = pop_biosig(['DownloadedData\' filepath(1:18)]);
E.times=E.times./1000;
if str2double(filepath(4:5))==9
    E.data([24],:)=[];
E.chanlocs([24],:)=[];
end
E.data([19,23:end],:)=[];
E.chanlocs([19,23:end],:)=[];
E.nbchan=21;


E.data=(E.data - mean(E.data(:,1:10*E.srate),2))./(std(E.data(:,1:10*E.srate),[],2));




Wind=1*E.srate;
N=256;
nyquist=E.srate/2;
frequencies=linspace(0,nyquist,floor(N/2)+1);
FOI{1}=[1,4];
FOI{2}=[4,8];
FOI{3}=[8,13];
FOI{4}=[13,30];
FOI{5}=[30,E.srate/2];

for i = 1 : length(FOI)
    FOI_indx{i}(1)=find(abs(frequencies-FOI{i}(1))==min(abs(frequencies-FOI{i}(1))));
    FOI_indx{i}(2)=find(abs(frequencies-FOI{i}(2))==min(abs(frequencies-FOI{i}(2))));
end

FinalData=[];
% Delta=[]; Theta=[]; Alpha=[]; Beta=[];

S_P=Wind+1;
FinalData.feat=zeros(21,5,E.pnts);
for i = S_P : E.pnts
    temp=[];
    temp=Mo_FFT(E.data(:,i-Wind:i),N);

    FinalData.feat(:,1,i)=mean([sum(temp(:,FOI_indx{1}(1):FOI_indx{1}(2)),2),squeeze(FinalData.feat(:,1,i-20:i-1))],2);
    FinalData.feat(:,2,i)=mean([sum(temp(:,FOI_indx{2}(1):FOI_indx{2}(2)),2),squeeze(FinalData.feat(:,2,i-20:i-1))],2);
    FinalData.feat(:,3,i)=mean([sum(temp(:,FOI_indx{3}(1):FOI_indx{3}(2)),2),squeeze(FinalData.feat(:,3,i-20:i-1))],2);
    FinalData.feat(:,4,i)=mean([sum(temp(:,FOI_indx{4}(1):FOI_indx{4}(2)),2),squeeze(FinalData.feat(:,4,i-20:i-1))],2);
    FinalData.feat(:,5,i)=mean([sum(temp(:,FOI_indx{5}(1):FOI_indx{5}(2)),2),squeeze(FinalData.feat(:,5,i-20:i-1))],2);

end
for i = 1: 21
    figure; 
    subplot(411); plot(squeeze(FinalData.feat(i,1,:))); subplot(412); plot(squeeze(FinalData.feat(i,2,:))); subplot(413);plot(squeeze(FinalData.feat(i,3,:))); subplot(414);plot(squeeze(FinalData.feat(i,4,:)))
end
% for i = 1 : 5
%     temp=[]; temp=squeeze(FinalData.feat(:,i,:));
%     FinalData.feat(:,i,:)=(temp - mean(temp(:,1:10*E.srate),2))./(std(temp(:,1:10*E.srate),[],2));
% end
FinalData.labels=zeros(1,length(E.times));
for i = 1 : numofseiz
    sssp=find(abs(E.times-SS(i,1))==min(abs(E.times-SS(i,1))));
    ssep=find(abs(E.times-SS(i,2))==min(abs(E.times-SS(i,2))));
    FinalData.labels(sssp:ssep)=1;
end
FinalData.Wind=Wind;




for i = 1 : numofseiz
    if i == 1 
        sp=1; 
    else
        temp=[]; temp=mean([SS(i-1,2) SS(i,1)]);
        sp=find(abs(E.times-temp)==min(abs(E.times-temp)))+1;
    end
    if i==numofseiz
        ep=length(FinalData.labels);
    else
        temp=[]; temp=mean([SS(i,2) SS(i+1,1)]);
        ep=find(abs(E.times-temp)==min(abs(E.times-temp)));
    end
    
    Data=[]; 
    Data.feat=FinalData.feat(:,:,sp:ep);
    Data.labels=FinalData.labels(sp:ep);
    Data.Wind=FinalData.Wind;
    FinalData_V2{i}=Data;
end
    
fprintf('\n')