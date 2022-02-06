clear all

%Reads EHoS data into cell matrices to prepare for preprocessing.
[num,txt,raw] = xlsread('EHoS_Dataset.xlsx','B2:I701');
fulldata = raw;

[num,txt,raw] = xlsread('EHoS_Dataset.xlsx','AB2:AD329');
fname_stats = raw;
[num,txt,raw] = xlsread('EHoS_Dataset.xlsx','AE2:AG191');
lname_stats = raw;
[num,txt,raw] = xlsread('EHoS_Dataset.xlsx','M2:O30');
century_stats = raw;
[num,txt,raw] = xlsread('EHoS_Dataset.xlsx','P2:R23');
state_stats = raw;
[num,txt,raw] = xlsread('EHoS_Dataset.xlsx','S2:U25');
position_stats = raw;
[num,txt,raw] = xlsread('EHoS_Dataset.xlsx','AH2:AJ118');
dynasty_stats = raw;
[num,txt,raw] = xlsread('EHoS_Dataset.xlsx','V2:X10');
death_stats = raw;
[num,txt,raw] = xlsread('EHoS_Dataset.xlsx','Y2:AA60');
reign_stats = raw;
reign_stats = cell2mat(reign_stats);
reign_data = cell2mat(fulldata(:,8));

%Constant Definitions
datasize=700;
sets=8;
data_list = zeros(datasize,sets);
endterm=1000;

%Converts EHoS dataset text into numerical values for easier processing.
for i=1:datasize
    for j=1:sets
        switch j
            case 1
                for k=1:328
                    if isempty((setdiff(fulldata(i,j),fname_stats(k,1))))
                        data_list(i,j)=k;
                        k=endterm;
                    end
                end
            case 2
                for k=1:190
                    if isempty((setdiff(fulldata(i,j),lname_stats(k,1))))
                        data_list(i,j)=k;
                        k=endterm;
                    end
                end
            case 3
                for k=1:29
                    if isempty((setdiff(fulldata(i,j),century_stats(k,1))))
                        data_list(i,j)=k;
                        k=endterm;
                    end
                end
            case 4
                for k=1:22
                    if isempty((setdiff(fulldata(i,j),state_stats(k,1))))
                        data_list(i,j)=k;
                        k=endterm;
                    end
                end
            case 5
                for k=1:24
                    if isempty((setdiff(fulldata(i,j),position_stats(k,1))))
                        data_list(i,j)=k;
                        k=endterm;
                    end
                end
            case 6
                for k=1:117
                    if isempty((setdiff(fulldata(i,j),dynasty_stats(k,1))))
                        data_list(i,j)=k;
                        k=endterm;
                    end
                end
            case 7
                for k=1:9
                    if isempty((setdiff(fulldata(i,j),death_stats(k,1))))
                        data_list(i,j)=k;
                        k=endterm;
                    end
                end
            case 8
                for k=1:59
                    if reign_data(i)==reign_stats(k,1)
                        data_list(i,j)=k;
                        k=endterm;
                    end
                end
            otherwise
                
        end
    end
end

%Writes Data to preprocessed Excel file for primary simulation to run.
xlswrite('EHoS_Dataset_preprocessed.xlsx',data_list);