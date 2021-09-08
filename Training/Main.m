clear all; clc; close all;
Summary=datalocation_V2();
for i = 1 : size(Summary,1)
    Subjects(i)=Summary{i,2};
end
numsbj=length(unique(Subjects));

for isub = 1 : numsbj %Suject
    fprintf('%2.fth Subject',isub)
    clearvars -except Summary Subjects numsbj isub
    indx=find(Subjects==isub,1,'first');
    %Loading first and second seizure of each subject
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
    load(['..\Feature Finder\BestFeatures\sbj', ...
        num2str(Summary{indx,2},'%02.f'), '.mat']);
    
    
    [params,a2]=ModelTraining(data1,data2,bestfeat);
    
    
    save(['Params\sbj',num2str( Summary{indx,2},'%02.f')],'params');
    saveas(a2,['Figures\sbj',num2str( Summary{indx,2},'%02.f'),'.jpg']);
    close(a2);
end