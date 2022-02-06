%Places memories into the synaptic grid in accordance to the external input provided to the network.
function [master_syn_matrix] = placemem(memory,set_anchors,master_syn_matrix,won)
    adjusted_mem = memory + set_anchors;
    for j=1:length(adjusted_mem)          %Steps through each set pre-synaptically
        for k=1:length(adjusted_mem)       %Steps through each set post-synaptically
            if j~=k        %If statements rids of the diagonal
                master_syn_matrix(adjusted_mem(j),adjusted_mem(k)) = won;
            end
        end
    end
end