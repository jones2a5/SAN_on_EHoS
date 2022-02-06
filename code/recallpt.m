function [winset] = recallpt(recall_input,master_syn_matrix,winset,set_anchors,cnts,min_iters)
    start_neurons = zeros(1,778);
    syn_feedback = zeros(1,778);
    neuron_feedback = zeros(778,778);
    wincheck = false;
    
    %External Input Application
    for i=1:8
       if recall_input(i) ~= 0 
           start_neurons(recall_input(i)+set_anchors(i)) = 1;
       end
    end
   
    finish_neurons = start_neurons;
    
   iters = 0;
   %Synaptic Feedback and Wincheck Iteration
   while wincheck == false && iters < min_iters
       neuron_feedback = repmat(start_neurons,778,1).*master_syn_matrix; %Passes neuron output through synapses.
       syn_feedback = sum(neuron_feedback,2); %Sums up each neuron's synaptic input.
       finish_neurons = finish_neurons + transpose(syn_feedback); %Applies synaptic feedback to neurons.
       [wincheck,tied_idxs,winset] = winchk(finish_neurons,set_anchors,cnts,wincheck,winset);
       neuron_feedback = 0;
       syn_feedback = 0;
       start_neurons = finish_neurons - start_neurons;
       iters = iters + 1;
   end
   
   %Setup and Recursive Function Call if a Winning Set is not found to evaluate the SAN once more with a new random external input given from tied max results.
   if wincheck == false %&& ~isempty(tied_idxs)
       neidx = datasample(tied_idxs,1);
       i=0;
       while i<9
           if i == 8
               break;
           elseif set_anchors(i+1) < neidx
                i = i + 1;
           else
               break;
           end
       end       
       recall_input(i) = neidx-set_anchors(i);
       winset = recallpt(recall_input,master_syn_matrix,winset,set_anchors,cnts,min_iters);
   end
   
end