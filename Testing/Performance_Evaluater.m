function Performance_Evaluater(subjects)
%This function loads the binary seizure state of all seizures for each
%subject, concatenates them subject wise, and compute the metrics for each
%subject separately.
    Summary=datalocation_V2();
    for i = 1 : size(Summary,1)
        Subjects(i)=Summary{i,2};
    end
    numsbj=length(unique(Subjects));

    for itempsub = 1 : length(subjects)
        isub = subjects(itempsub);
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
        gtemp=[];
        for isessions = indx1 : indx2
            if isessions == indx1
                for jseiz = seiz1 : Summary{isessions,4}
                    clearvars -except isession subjects gtemp Summary Subjects numsbj isub indx1 indx2 seiz1  isessions jseiz
                    ltemp=load(['Prediction_Label\sbj',num2str(Summary{isessions,2},'%02.f'), ...
                    'sess', num2str(Summary{isessions,3}, '%02.f'), 'seiz' ,num2str(jseiz,'%02.f'), '.mat']);
                    gtemp=[gtemp,ltemp.Performance];
                end
            else
                for jseiz = 1 : Summary{isessions,4}
                    clearvars -except isession subjects  gtemp Summary Subjects numsbj isub indx1 indx2 seiz1  isessions jseiz
                    ltemp=load(['Prediction_Label\sbj',num2str(Summary{isessions,2},'%02.f'), ...
                    'sess', num2str(Summary{isessions,3}, '%02.f'), 'seiz' ,num2str(jseiz,'%02.f'), '.mat']);
                    gtemp=[gtemp,ltemp.Prediction_Label];
                end
            end
        end
        thresholded=gtemp(1,:); 
        Data.labels=gtemp(2,:);
        Performance.accuracy=sum(thresholded==Data.labels)./length(Data.labels);
        tp = sum((thresholded == 1) & (Data.labels == 1));
        fp = sum((thresholded == 1) & (Data.labels == 0));
        fn = sum((thresholded == 0) & (Data.labels == 1));
        tn = sum((thresholded == 0) & (Data.labels == 0));
        Performance.Specificity = tn ./ (tn+fp);
        Performance.precision = tp / (tp + fp);
        Performance.recall = tp / (tp + fn);
        Performance.F1 = (2 * Performance.precision * Performance.recall) / (Performance.precision + Performance.recall);
        Performance.dur=length(thresholded)./256./3600;
        Performance.fprate=fp./(fp+tn);
        Performance.fnrate=fn./(fn+tp);
        prev=(sum(Data.labels == 1))./(sum(Data.labels == 0));
        Performance.fprateperhour=(1-Performance.Specificity)*(1-prev)./Performance.dur;
        save(['Performance\sbj',num2str(Summary{isessions,2},'%02.f'), '.mat'],'Performance');
    end
    
        
        