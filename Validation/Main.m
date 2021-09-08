clear all; clc; close all;
Summary=datalocation_V2();
for i = 1 : size(Summary,1)
    Subjects(i)=Summary{i,2};
end
numsbj=length(unique(Subjects));

for isub = 1 : numsbj %Going through all the subjects
    fprintf('%2.fth Subject\n\n',isub)
    clearvars -except Summary Subjects numsbj isub
    %Loading the first two seizures of each subject
    indx=find(Subjects==isub,1,'first');
    data1=load(['..\Extracter\ExtractedData\all\sbj', ...
        num2str(Summary{indx,2},'%02.f'), 'sess' num2str(Summary{indx,3},...
        '%02.f'), 'seiz01.mat']);
    if Summary{indx,4}>1
    data2=load(['..\Extracter\ExtractedData\all\sbj', ...
        num2str(Summary{indx,2},'%02.f'), 'sess' num2str(Summary{indx,3},...
        '%02.f') 'seiz02.mat']);
    else
        data2=load(['..\Extracter\ExtractedData\all\sbj', ...
        num2str(Summary{indx+1,2},'%02.f'), 'sess' num2str(Summary{indx+1,3},...
        '%02.f') 'seiz01.mat']);
    end
    load(['..\Training\Params\sbj', ...
        num2str(Summary{indx,2},'%02.f'), '.mat']);
    
    [MES,SES]=ValidationRun(data1,data2,params);
    
    proba=MES./SES;
    %Combining the seizure labels of first and second seizure
    labels1=data1.Data.labels; 
    Wind=data1.Data.Wind;
    labels2=data2.Data.labels; 
    temp01=labels1(Wind+1:end);
    temp02=labels2(Wind+1:end);
    labels=[temp01,temp02];

    nonseiz1=find(labels1(Wind+1:end)==0)+Wind; 
    seiz1=find(labels1(Wind+1:end)==1)+Wind;
    nonseiz2=find(labels2(Wind+1:end)==0)+Wind; 
    seiz2=find(labels2(Wind+1:end)==1)+Wind;
    
    nonseiz=[nonseiz1,nonseiz2]; seiz=[seiz1,seiz2]; 
    %For computing the cost of misclassification to take care of imbalancity in the data
    Thresholds.clf=fitcdiscr(MES',labels','Cost',[0,1;length(nonseiz)./length(seiz),0]); 
    %Training a classifier to convert the continuous seizure state into binary seizure state
    

    save(['Thresholds\sbj',num2str( Summary{indx,2},'%02.f')],'Thresholds');
end

