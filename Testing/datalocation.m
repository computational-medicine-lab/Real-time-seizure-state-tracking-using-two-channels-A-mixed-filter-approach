function [PathDirectory,SSID,SS]=datalocation()
    fileID1=fopen('..\Extracter\DownloadedData\RECORDS-WITH-SEIZURES','r');
    counter=1;
    while ~feof(fileID1) && counter < 51   
        if counter==51
            1;
        end
        PathDirectory{counter,1}=fscanf(fileID1,'%str');
        SSID(counter,1)=str2num(PathDirectory{counter,1}(10:11)); % Subject Session ID
        SSID(counter,2)=str2num(PathDirectory{counter,1}(13:14)); 
        
        
        fileID2=fopen(['..\Extracter\DownloadedData\chb',num2str(SSID(counter,1),'%02.f'), '\chb' ,num2str(SSID(counter,1),'%02.f'), '-summary.txt'],'r');
        
        s = textscan(fileID2, '%s', 'delimiter', '\n');
        idx1 = find(strcmp(s{1},  ['File Name: chb' ,num2str(SSID(counter,1),'%02.f'), '_',num2str(SSID(counter,2),'%02.f'),'.edf']), 1, 'first')+4;
        if counter==9
            idx1 = find(strcmp(s{1},  ['File Name: chb' ,num2str(SSID(counter,1),'%02.f'), '_',num2str(SSID(counter,2)-1,'%02.f'),'+.edf']), 1, 'first')+4;
        end
        SS(counter,1)=str2num(s{1,1}{idx1}(regexp(s{1,1}{idx1},'\d'))); %Seizure State
        SS(counter,2)=str2num(s{1,1}{idx1+1}(regexp(s{1,1}{idx1+1},'\d')));
        clear s
        
        counter=counter+1;
        
        fclose(fileID2);
    end
    fclose(fileID1);
    