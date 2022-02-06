%Checks if the network needs to erase any synaptic values due to commonly occurring features.
function [master_syn_matrix,erase_memory_points] = erase_check(Lfactorthresh,master_syn_matrix,memory,erase_memory_points,won)
    for i=1:778 %Sweeps all features across all sets.
       if sum(master_syn_matrix(i,:)) > Lfactorthresh*won %Wipes all synaptic connections to a feature if the sum of the programmed pre-synaptic connections to the feature exceeds the erase threshold.
          master_syn_matrix(i,:)=0;
          master_syn_matrix(:,i)=0;
          erase_memory_points = [erase_memory_points; memory;];
       end
    end

end