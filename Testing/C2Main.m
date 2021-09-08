clear all; clc; close all;
Summary=datalocation_V2();
for i = 1 : size(Summary,1)
    Subjects(i)=Summary{i,2};
end
numsbj=length(unique(Subjects));

for isub = 8 : 8
    fprintf('%2.fth Subject\n\n',isub) 
    indx1=find(Subjects==isub,1,'first');
    temp=0; Counter=0;
    while temp<3
        temp=temp + Summary{indx1+Counter,4};
        Counter=Counter+1;
    end
    indx1=indx1+Counter-1;
    temp2=temp-Summary{indx1,4};
    seiz1=3-temp2;
    indx2=find(Subjects==isub,1,'last');
    load(['..\Training\Params\sbj', ...
        num2str(Summary{indx1,2},'%02.f'), '.mat']);
    load(['..\Validation\Thresholds\sbj', ...
        num2str(Summary{indx1,2},'%02.f'), '.mat']);
    for isessions = indx1 : indx2
        if isessions ==indx1
            for jseiz = seiz1 : Summary{isessions,4}
            clearvars -except Summary Subjects numsbj isub indx1 indx2 seiz1  params Thresholds isessions jseiz
            load(['..\Extracter\ExtractedData\all\sbj', ...
            num2str(Summary{isessions,2},'%02.f'), 'sess' num2str(Summary{isessions,3},...
            '%02.f'), 'seiz' ,num2str(jseiz,'%02.f'), '.mat']);
            [figtosave,thresholded]=ModelRun(Data,params,Thresholds);
            Performance(1,:)=thresholded; Performance(2,:)=Data.labels;
            save(['Prediction_Label\sbj',num2str(Summary{isessions,2},'%02.f'), ...
                'sess', num2str(Summary{isessions,3}, '%02.f'), 'seiz' ,num2str(jseiz,'%02.f'), '.mat'],'Performance');
            saveas(figtosave,['Figures\sbj',num2str(Summary{isessions,2},'%02.f'), ...
                'sess', num2str(Summary{isessions,3}, '%02.f'), 'seiz' ,num2str(jseiz,'%02.f'),'.jpg']);
            close(figtosave);
            end
        else
            for jseiz = 1 : Summary{isessions,4}
            clearvars -except Summary Subjects numsbj isub indx1 indx2 seiz1  params Thresholds isessions jseiz
            load(['..\Extracter\ExtractedData\all\sbj', ...
            num2str(Summary{isessions,2},'%02.f'), 'sess' num2str(Summary{isessions,3},...
            '%02.f'), 'seiz' ,num2str(jseiz,'%02.f'), '.mat']);
            [figtosave,thresholded]=ModelRun(Data,params,Thresholds);

            Prediction_Label(1,:)=thresholded; Prediction_Label(2,:)=Data.labels;
            save(['Prediction_Label\sbj',num2str(Summary{isessions,2},'%02.f'), ...
                'sess', num2str(Summary{isessions,3}, '%02.f'), 'seiz' ,num2str(jseiz,'%02.f'), '.mat'],'Prediction_Label');
            saveas(figtosave,['Figures\sbj',num2str(Summary{isessions,2},'%02.f'), ...
                'sess', num2str(Summary{isessions,3}, '%02.f'), 'seiz' ,num2str(jseiz,'%02.f'),'.jpg']);
            close(figtosave);
            end
        end
    end
end
Performance_Evaluater(8);