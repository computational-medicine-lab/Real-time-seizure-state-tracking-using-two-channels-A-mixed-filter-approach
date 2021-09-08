clear all; clc; close all;
Summary=datalocation_V2(); 
n_sessions=size(Summary,1);
for i= 1 : length(n_sessions) %Number of sessions
    temp=[];
    fprintf(['Subject : ', num2str(Summary{i,2}), '; Session : ', num2str(Summary{i,3}), '\n'])
    temp=DataExtracter(Summary{i,1},Summary{i,5});
    mkdir(['ExtractedData\sbj',num2str( Summary{i,2},'%02.f')]);
    for j = 1 : Summary{i,4} %Number of seizrues in one session
        Data=[]; Data=temp{j};
    save(['ExtractedData\sbj',num2str( Summary{i,2},'%02.f'),'\sess',num2str( Summary{i,3},'%02.f'),'sess',num2str( j,'%02.f')],'Data','-v7.3');
    save(['ExtractedData\all\sbj',num2str( Summary{i,2},'%02.f'),'sess',num2str( Summary{i,3},'%02.f'),'seiz',num2str( j,'%02.f')],'Data','-v7.3');
    end
    fprintf('\n\n');
end