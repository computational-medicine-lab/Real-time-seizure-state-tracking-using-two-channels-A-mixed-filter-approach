function [Summary]=datalocation_V2()
    fileID1=fopen('..\Extracter\DownloadedData\RECORDS-WITH-SEIZURES','r');
    counter=1;
    while ~feof(fileID1) && counter < 51   
        if counter==51
            1;
        end
        Summary{counter,1}=fscanf(fileID1,'%str');
        Summary{counter,2}=str2num(Summary{counter,1}(10:11)); % Subject Session ID
        Summary{counter,3}=str2num(Summary{counter,1}(13:14)); 
        
        
        fileID2=fopen(['..\Extracter\DownloadedData\chb',num2str(Summary{counter,2},'%02.f'), '\chb' ,num2str(Summary{counter,2},'%02.f'), '-summary.txt'],'r');
        
        s = textscan(fileID2, '%s', 'delimiter', '\n');
        idx1 = find(strcmp(s{1},  ['File Name: chb' ,num2str(Summary{counter,2},'%02.f'), '_',num2str(Summary{counter,3},'%02.f'),'.edf']), 1, 'first')+4;
        if counter==9
            idx1 = find(strcmp(s{1},  ['File Name: chb' ,num2str(Summary{counter,2},'%02.f'), '_',num2str(Summary{counter,3}-1,'%02.f'),'+.edf']), 1, 'first')+4;
        end
        Summary{counter,4}=str2num(s{1,1}{idx1-1}(regexp(s{1,1}{idx1-1},'\d')));
        tempmat=[];
        for i = 1 : Summary{counter,4}
            if Summary{counter,2}>5 || Summary{counter,4}>1
                temp=(s{1,1}{idx1}(regexp(s{1,1}{idx1},'\d')));
                tempmat(i,1)=str2num(temp(2:end)); %Seizure State
                temp=(s{1,1}{idx1+1}(regexp(s{1,1}{idx1+1},'\d')));
                tempmat(i,2)=str2num(temp(2:end)); %Seizure State
                idx1=idx1+2;
            else
                temp=(s{1,1}{idx1}(regexp(s{1,1}{idx1},'\d')));
                tempmat(i,1)=str2num(temp(1:end)); %Seizure State
                temp=(s{1,1}{idx1+1}(regexp(s{1,1}{idx1+1},'\d')));
                tempmat(i,2)=str2num(temp(1:end)); %Seizure State
                idx1=idx1+2;
            end
        end
        Summary{counter,5}=tempmat;

        clear s
        
        counter=counter+1;
        fclose(fileID2);
        
    end
    fclose(fileID1);
    