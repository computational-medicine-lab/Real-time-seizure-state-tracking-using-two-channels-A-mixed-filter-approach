clear all; clc; close all;
Summary=datalocation_V2();
for i = 1 : size(Summary,1)
    Subjects(i)=Summary{i,2};
end
numsbj=length(unique(Subjects));

for isub = 1 : 1 %Going through all subjects
    fprintf('%2.fth Subject\n\n',isub)
    clearvars -except Summary numsbj isub Subjects
    indx=find(Subjects==isub,1,'first');
    %Extracting the first (training) and second (validation) seizures.
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
    feat1=data1.Data.feat; labels1=data1.Data.labels; Wind=data1.Data.Wind; srate=256; clear data1; 
    feat2=data2.Data.feat; labels2=data2.Data.labels; clear data2; 
    
    %Defining cost of misclassification in order to take care of
    %imbalancity.
    nonseiz1=find(labels1(Wind+1:end)==0)+Wind; seiz1=find(labels1(Wind+1:end)==1)+Wind;
    nonseiz2=find(labels2(Wind+1:end)==0)+Wind; seiz2=find(labels2(Wind+1:end)==1)+Wind;
    
    nonseiz=[nonseiz1,nonseiz2]; seiz=[seiz1,seiz2];
    cost=[0,1;length(nonseiz)./length(seiz),0];
    %% Feature Selection
    countcorr=[];
    
    counter=1;
    for i = 1 : size(feat1,1) %channels
        for j = 1 : size(feat1,2) %Frequency bands      
            %Training, normalization
            confeat1=[];confeat1=squeeze(log(feat1(i,j,Wind+1:end)));
            confeat1=(confeat1-min(confeat1(1:59*srate)))./(max(confeat1(1:59*srate))-min(confeat1(1:59*srate))); %
            confeat1=confeat1-mean(confeat1(1:59*srate));
            
            %Testing, normalization
            confeat2=[];confeat2=squeeze(log(feat2(i,j,Wind+1:end)));
            confeat2=(confeat2-min(confeat2(1:59*srate)))./(max(confeat2(1:59*srate))-min(confeat2(1:59*srate)));
            confeat2=confeat2-mean(confeat2(1:59*srate));
            
            confeat=[]; confeat=[confeat1;confeat2];
            
            temp01=labels1(Wind+1:end);
            temp02=labels2(Wind+1:end);
            temp0=[temp01,temp02];
            
            temp1{counter}=fitcdiscr(confeat1,temp01,'Cost',cost); %Training 
            temp2=[]; temp2=predict(temp1{counter},confeat2)'; %prediction
            tp = sum((temp2 == 1) & (temp02 == 1)); %true positive
            fp (counter) = sum((temp2 == 1) & (temp02 == 0)); %false positive
            fn(counter) = sum((temp2 == 0) & (temp02 == 1)); %false negative
            acc(counter)=sum(temp2==temp02)/length(temp2);%accuracy 
            precision(counter) = tp / (tp + fp(counter));%precision
            recall(counter) = tp / (tp + fn(counter));%recall
            F1(counter) = (2 * precision(counter) * recall(counter)) / (precision(counter) + recall(counter)); %F1
            if isnan(F1(counter)), F1(counter)=0; end
            countcorr_info{counter} = i;
            countcorr_info1{counter} = j;
%             countcorr_info{counter}=['Channel : ', num2str(i,'%02.f'),...
%                 ' ; Frequency Band : ', num2str(j,'%02.f')]; %Storing info about the corresponding channel and freq band.
            counter=counter+1;
        end
    end
    contF1Score=[];contF1Score_idx=[]; [contF1Score, contF1Score_idx]=sort(F1); %sorting based on F1 score 
    contBestFeat{1,1}=countcorr_info{contF1Score_idx(end)}; %Continuous Feature
    contBestFeat{1,2}=countcorr_info1{contF1Score_idx(end)};
    contBestFeat{1,3}=contF1Score(contF1Score_idx(end)); %F1 Score of Continuous Feature
    contBestFeat{1,4}='CONT';
    
    
    clearvars -except Subjects feat1 feat2 feat labels1 labels2 labels bestfeat isub Summary numsbj indx Wind srate cost contBestFeat
    counter= 1;
    %The exact same procedure for binary feature, except we won't take log
    %from features, instead we use just amp^2 unit.
    for i = 1 : size(feat1,1)
        for j = 1 : size(feat1,2)
            confeat1=[];confeat1=squeeze((feat1(i,j,Wind+1:end)));
            
            confeat1=(confeat1-min(confeat1(1:59*srate)))./(max(confeat1(1:59*srate))-min(confeat1(1:59*srate)));
            confeat1=confeat1-mean(confeat1(1:59*srate));    
            
            confeat2=[];confeat2=squeeze((feat2(i,j,Wind+1:end)));
            confeat2=(confeat2-min(confeat2(1:59*srate)))./(max(confeat2(1:59*srate))-min(confeat2(1:59*srate)));
            confeat2=confeat2-mean(confeat2(1:59*srate));
            
            confeat=[]; confeat=[confeat1;confeat2];
            
            temp01=labels1(Wind+1:end);
            temp02=labels2(Wind+1:end);
            temp0=[temp01,temp02];
            
            temp1{counter}=fitcdiscr(confeat1,temp01,'Cost',cost);
            temp2=[]; temp2=predict(temp1{counter},confeat2)';
            tp = sum((temp2 == 1) & (temp02 == 1));
            fp = sum((temp2 == 1) & (temp02 == 0));
            fn = sum((temp2 == 0) & (temp02 == 1));
            acc(counter)=sum(temp2==temp02)/length(temp2);
            precision(counter) = tp / (tp + fp);
            recall(counter) = tp / (tp + fn);
            F1(counter) = (2 * precision(counter) * recall(counter)) / (precision(counter) + recall(counter));
            if isnan(F1(counter)), F1(counter)=0; end
            binarycorr_info{counter} = i;
            binarycorr_info1{counter} = j;
%             binarycorr_info{counter}=['Channel : ', num2str(i,'%02.f'),...
%                 ' ; Frequency Band : ', num2str(j,'%02.f')];
            counter=counter+1;
        end
    end
    temp=[]; [~,temp]=sort(F1); 
    
    BinF1Score=[];BinF1Score_idx=[]; [BinF1Score, BinF1Score_idx]=sort(F1); %sorting based on F1 score 
    BinBestFeat{1,1}=binarycorr_info{BinF1Score_idx(end)}; %Continuous Feature
    BinBestFeat{1,2}=binarycorr_info1{BinF1Score_idx(end)};
    BinBestFeat{1,3}=BinF1Score(BinF1Score_idx(end)); %F1 Score of Continuous Feature
    BinBestFeat{1,4}='BIN';
    
   counter=0;
   
   %bestfeat{2,1}=binarycorr_info{temp(end-counter)};
   if (BinBestFeat{1,3} > contBestFeat{1,3})
       BestofBest = BinBestFeat;
   else
       BestofBest = contBestFeat;
   end
   BestofBest;
   
  counter = 1; 
   for i = 1 : size(feat1,1)
        for j = 1 : size(feat1,2)
            if (strcmp(BestofBest{1,4}, 'CONT') && i~= BestofBest{1,1})
                confeat1=[];
                confeat1=squeeze((feat1(i,j,Wind+1:end)));
                confeat1=[confeat1 squeeze(log(feat1(BestofBest{1,1},BestofBest{1,2},Wind+1:end)))];


                confeat1=(confeat1-min(confeat1(1:59*srate)))./(max(confeat1(1:59*srate))-min(confeat1(1:59*srate)));
                confeat1=confeat1-mean(confeat1(1:59*srate));    

                confeat2=[];
                confeat2=squeeze((feat2(i,j,Wind+1:end)));
                confeat2=[confeat2 squeeze(log(feat2(BestofBest{1,1},BestofBest{1,2},Wind+1:end)))];
                confeat2=(confeat2-min(confeat2(1:59*srate)))./(max(confeat2(1:59*srate))-min(confeat2(1:59*srate)));
                confeat2=confeat2-mean(confeat2(1:59*srate));

                confeat=[]; confeat=[confeat1;confeat2];

                temp01=labels1(Wind+1:end);
                temp02=labels2(Wind+1:end);
                temp0=[temp01,temp02];

                temp1{counter}=fitcdiscr(confeat1,temp01,'Cost',cost);
                temp2=[]; temp2=predict(temp1{counter},confeat2)';
                tp = sum((temp2 == 1) & (temp02 == 1));
                fp = sum((temp2 == 1) & (temp02 == 0));
                fn = sum((temp2 == 0) & (temp02 == 1));
                acc(counter)=sum(temp2==temp02)/length(temp2);
                precision(counter) = tp / (tp + fp);
                recall(counter) = tp / (tp + fn);
                F1(counter) = (2 * precision(counter) * recall(counter)) / (precision(counter) + recall(counter));
                if isnan(F1(counter)), F1(counter)=0; end
                finalcorr_info{counter} = i;
                finalcorr_info1{counter} = j;
                finalcorr_info2{counter} = 'BIN';
                counter=counter+1;
            end
            if (strcmp(BestofBest{1,4}, 'BIN') && i~= BestofBest{1,1})
                confeat1=[];
                confeat1=squeeze(log(feat1(i,j,Wind+1:end)));
                confeat1=[confeat1 squeeze((feat1(BestofBest{1,1},BestofBest{1,2},Wind+1:end)))];


                confeat1=(confeat1-min(confeat1(1:59*srate)))./(max(confeat1(1:59*srate))-min(confeat1(1:59*srate)));
                confeat1=confeat1-mean(confeat1(1:59*srate));    

                confeat2=[];
                confeat2=squeeze(log(feat2(i,j,Wind+1:end)));
                confeat2=[confeat2 squeeze((feat2(BestofBest{1,1},BestofBest{1,2},Wind+1:end)))];
                confeat2=(confeat2-min(confeat2(1:59*srate)))./(max(confeat2(1:59*srate))-min(confeat2(1:59*srate)));
                confeat2=confeat2-mean(confeat2(1:59*srate));

                confeat=[]; confeat=[confeat1;confeat2];

                temp01=labels1(Wind+1:end);
                temp02=labels2(Wind+1:end);
                temp0=[temp01,temp02];

                temp1{counter}=fitcdiscr(confeat1,temp01,'Cost',cost);
                temp2=[]; temp2=predict(temp1{counter},confeat2)';
                tp = sum((temp2 == 1) & (temp02 == 1));
                fp = sum((temp2 == 1) & (temp02 == 0));
                fn = sum((temp2 == 0) & (temp02 == 1));
                acc(counter)=sum(temp2==temp02)/length(temp2);
                precision(counter) = tp / (tp + fp);
                recall(counter) = tp / (tp + fn);
                F1(counter) = (2 * precision(counter) * recall(counter)) / (precision(counter) + recall(counter));
                if isnan(F1(counter)), F1(counter)=0; end
                finalcorr_info{counter} = i;
                finalcorr_info1{counter} = j;
                finalcorr_info2{counter} = 'CONT';
%                finalcorr_info{counter}=['Channel : ', num2str(i,'%02.f'),...
%                    ' ; Frequency Band : ', num2str(j,'%02.f')];
                counter=counter+1;
            end    
        end
    end
   
   
     FinalF1Score=[];FinalF1Score_idx=[]; [FinalF1Score, FinalF1Score_idx]=sort(F1); %sorting based on F1 score 
%     %FinalF1Score{1,1}=
%     finalcorr_info{FinalF1Score_idx(end)} %Continuous Feature
%    % FinalF1Score{1,2}=
%     finalcorr_info1{FinalF1Score_idx(end)}
%     %FinalF1Score{1,3}=
%     FinalF1Score(FinalF1Score_idx(end)) %F1 Score of Continuous Feature
    
   
    
 %BestofBest
 %FinalF1Score
   
       %The exact same procedure for binary feature, except we won't take log
    %from features, instead we use just amp^2 unit.
    
   
   
   
   %Making sure it is not the same feature as the continuous feature
%    while (str2num(bestfeat{2,1}(10:12))==str2num(bestfeat{1,1}(10:12))) && (str2num(bestfeat{2,1}(32:34))==str2num(bestfeat{1,1}(32:34)))  
%        counter=counter+1;
%        bestfeat{2,1}=binarycorr_info{temp(end-counter)};
%     end  

bestfeat = {};
% bestfeat = [BestofBest{1,1}, BestofBest{1,2}, BestofBest{1,3}, BestofBest{1,4} ; finalcorr_info{FinalF1Score_idx(end)},  finalcorr_info1{FinalF1Score_idx(end)}, FinalF1Score(FinalF1Score_idx(end)), finalcorr_info2{FinalF1Score_idx(end)}]
     %'Channel' 'Band' 'FSscore' 'Type'; 
     A = BestofBest{1,1}
     B = BestofBest{1,2}
     C = BestofBest{1,3}
     D = BestofBest{1,4}
     E = finalcorr_info{FinalF1Score_idx(end)}
     F = finalcorr_info1{FinalF1Score_idx(end)}
     G = FinalF1Score(FinalF1Score_idx(end))
     H = finalcorr_info2{FinalF1Score_idx(end)}
     bestfeat = {'Channel' 'Band' 'FSscore' 'Type';A B C D; E F G H}
     save(['BestFeatures\sbj',num2str( Summary{indx,2},'%02.f')],'bestfeat')
 end
