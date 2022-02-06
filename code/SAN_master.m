clear all

%Data importing for SAN analysis from Excel file.
[num,txt,raw] = xlsread('/data/EHoS_Dataset_preprocessed.xlsx','A1:H700');
fulldata = num;

[num,txt,raw] = xlsread('/data/EHoS_Dataset.xlsx','AB2:AD329');
fname_stats = raw;
[num,txt,raw] = xlsread('/data/EHoS_Dataset.xlsx','AE2:AG191');
lname_stats = raw;
[num,txt,raw] = xlsread('/data/EHoS_Dataset.xlsx','M2:O30');
century_stats = raw;
[num,txt,raw] = xlsread('/data/EHoS_Dataset.xlsx','P2:R23');
state_stats = raw;
[num,txt,raw] = xlsread('/data/EHoS_Dataset.xlsx','S2:U25');
position_stats = raw;
[num,txt,raw] = xlsread('/data/EHoS_Dataset.xlsx','AH2:AJ118');
dynasty_stats = raw;
[num,txt,raw] = xlsread('/data/EHoS_Dataset.xlsx','V2:X10');
death_stats = raw;
[num,txt,raw] = xlsread('/data/EHoS_Dataset.xlsx','Y2:AA60');
reign_stats = raw;


%Simulation parameters.
minruns=0;                 %Not used.
recalledsets=0;            %Not used.
decay_type=1;              %Can adjust the decay rate between linear (0), or exponential/state-based (1, which is what is observed in published synaptic devices)
decay_rate=0.000;          %rstp, decay rate at which synapses decay their current state between each time step.
predictionthresh=0.000;    %Pth, prediction threshold that determines when predictive synaptic connections should be formed.
Lfactorthresh=1e9;         %Eth, threshold value for an erasure event to occur.
min_iters = 3;             %Number of passes performed on SAN during recall to determine if a winning set exists or not.
memory_count_track = true; %For record-keeping purposes.
won = 0.001;               %Programmed weight of synapses when activated.

%EHoS information.
fname_cnt=328;
lname_cnt=190;
century_cnt=29;
state_cnt=22;
position_cnt=24;
dynasty_cnt=117;
death_cnt=9;
reign_cnt=59;

fname_ufact=0.469;
lname_ufact=0.271;
century_ufact=0.041;
state_ufact=0.031;
position_ufact=0.034;
dynasty_ufact=0.167;
death_ufact=0.013;
reign_ufact=0.084;

set_labels ={'fname';'lname';'century';'state';'position';'dynasty';'death';'reign'};
set_anchors = [0 fname_cnt fname_cnt+lname_cnt fname_cnt+lname_cnt+century_cnt fname_cnt+lname_cnt+century_cnt+state_cnt fname_cnt+lname_cnt+century_cnt+state_cnt+position_cnt fname_cnt+lname_cnt+century_cnt+state_cnt+position_cnt+dynasty_cnt fname_cnt+lname_cnt+century_cnt+state_cnt+position_cnt+dynasty_cnt+death_cnt]; 

cnts = [fname_cnt lname_cnt century_cnt state_cnt position_cnt dynasty_cnt death_cnt reign_cnt];
ufacts = [fname_ufact lname_ufact century_ufact state_ufact position_ufact dynasty_ufact death_ufact reign_ufact];

setidxs = 1:8;
setidx_combo4 = combnk(setidxs,4);
setidx_combo5 = combnk(setidxs,5);
setidx_combo6 = combnk(setidxs,6);
setidx_combo7 = combnk(setidxs,7);

cnts_combo2 = combnk(cnts,2);
cnts_combo3 = combnk(cnts,3);
cnts_combo4 = combnk(cnts,4);   %One normally used.
cnts_combo5 = combnk(cnts,5);
cnts_combo6 = combnk(cnts,6);
cnts_combo7 = combnk(cnts,7);

ufacts_combo2 = combnk(ufacts,2);
ufacts_combo3 = combnk(ufacts,3);
ufacts_combo4 = combnk(ufacts,4);
ufacts_combo5 = combnk(ufacts,5);
ufacts_combo6 = combnk(ufacts,6);
ufacts_combo7 = combnk(ufacts,7);

ufacts_combo2_avg = mean(transpose(ufacts_combo2));
ufacts_combo3_avg = mean(transpose(ufacts_combo3));
ufacts_combo4_avg = mean(transpose(ufacts_combo4));
ufacts_combo5_avg = mean(transpose(ufacts_combo5));
ufacts_combo6_avg = mean(transpose(ufacts_combo6));
ufacts_combo7_avg = mean(transpose(ufacts_combo7));

%Initialization of analysis matrices.
master_syn_matrix = zeros(sum(cnts),sum(cnts));
sequence = 1:700;
%curr_sequence = sequence(randperm(length(sequence)));
curr_sequence = xlsread('/data/desired_sequence.xlsx','A1:ZX1');
winset = zeros(1,8);
hitrates = zeros(length(ufacts_combo4),700);
prediction_points = [];
erase_memory_points = [];
memtime_sums = zeros(1,700);
false_mems = zeros(1,700);
memory_frequency = zeros(700,700);
%Use "sequence(randperm(length(sequence))) to generate new array of randomly placed memories."

for i=1:length(sequence)
    unique_mems_recalled = zeros(1,700);
    i
    if decay_rate > 0
        master_syn_matrix = decaysyns(decay_type,decay_rate,master_syn_matrix);     %Decays synapses according to decay rate.
    end
    memory = fulldata(curr_sequence(i),:);                                      %Selects next memory to be inserted.
    master_syn_matrix = placemem(memory,set_anchors,master_syn_matrix,won);         %Places next memory into network.
    if predictionthresh > 0
        [master_syn_matrix,prediction_points] = predict(memory,master_syn_matrix,cnts,set_anchors,predictionthresh,prediction_points,won); %Checks for predictions to be made.
    end
    if Lfactorthresh < 1e9
        [master_syn_matrix,erase_memory_points] = erase_check(Lfactorthresh,master_syn_matrix,memory,erase_memory_points,won);           %Checks if the network needs any memories erased.
    end
    
    %Recall on everything currently within the network.
    for j=1:i %Steps through currently placed memories.
        
        memory = fulldata(curr_sequence(j),:);
        for k=1:70 %Steps through set input combos.
           
           recall_input = zeros(1,8);
           recall_input_setidxs = setidx_combo4(k,:);
           for l=1:4
              recall_input(recall_input_setidxs(l)) = memory(recall_input_setidxs(l)); 
           end
           winset = recallpt(recall_input,master_syn_matrix,winset,set_anchors,cnts,min_iters);
           if winset == memory
               hitrates(k,i) = hitrates(k,i) + 1;
           elseif min(winset) == 0
               for l=1:8
                  if winset(l) > 0 && winset(l) ~= memory(l)
                      break;
                  elseif l==8 && winset(l) == memory(l) || l==8 && winset(l) == 0
                      hitrates(k,i) = hitrates(k,i) + 1;
                  end
               end
           end
           
           %Memory Count Tracker
           if memory_count_track == true
               for l=1:700
                  if winset == fulldata(curr_sequence(l),:)
                      unique_mems_recalled(curr_sequence(l)) = 1; 
                      memory_frequency(l,i) = memory_frequency(l,i) + 1; 
                  end

               end
           end
           
           
        end       
    end
    
    %Data tracking.
    if memory_count_track == true
       memtime_sums(i) = sum(unique_mems_recalled); 
    end
    hitrates(:,i) = hitrates(:,i)./i;
    
end

%Setup for some of the post-simulation result output.
ufacts_wlabels = [1:70; ufacts_combo4_avg];
hitrate_sorted = zeros(length(ufacts_combo4),700);

for i=1:70
       minufact = find( ufacts_wlabels(2,:) == min(ufacts_wlabels(2,:)));
       hitrate_sorted(i,:) = hitrates(minufact,:);
       ufacts_wlabels(2,minufact) = 1;
end

%Post-simulation results output.
xlswrite('/results/memory_frequency.xlsx',memory_frequency);
xlswrite('/results/hitrate_sorted.xlsx',hitrate_sorted);
xlswrite('/results/memtime_sums.xlsx',memtime_sums);
xlswrite('/results/memory_frequency.xlsx',memory_frequency);
if ~isempty(prediction_points)
    xlswrite('/results/prediction_points.xlsx',prediction_points);
end
if ~isempty(erase_memory_points)
   xlswrite('/results/erase_memory_points.xlsx',erase_memory_points); 
end
xlswrite('/results/false_mems.xlsx',false_mems);
xlswrite('/results/params.xlsx',[decay_rate predictionthresh Lfactorthresh won]);