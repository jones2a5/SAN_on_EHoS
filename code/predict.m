%Checks if any predictive connections need made in the synaptic grid.
function [master_syn_matrix,prediction_points] = predict(memory,master_syn_matrix,cnts,set_anchors,predictionthresh,prediction_points,won)  
    neurons = zeros(1,778);
    %External Input Application
    for i=1:8
           neurons(memory(i)+set_anchors(i)) = 1;
    end

    %One-Pass Feedback
    neuron_feedback = repmat(neurons,778,1).*master_syn_matrix; %Passes neuron output through synapses.
    syn_feedback = sum(neuron_feedback,2); %Sums up each neuron's synaptic input.
    neurons = neurons + transpose(syn_feedback); %Applies synaptic feedback to neurons.
    
    if sum(neurons >= predictionthresh & neurons < 1) > 0
        prediction_points = [prediction_points; memory;];
    end
    
    %Forming Predictive Connections
    adj_neurons = neurons >= predictionthresh; %Finds which neurons should be used to form predictions
    A = repmat(adj_neurons,778,1);
    B = repmat(transpose(adj_neurons),1,778);
    new_syns = A.*B.*won; %Creates synaptic matrix predictions
    master_syn_matrix = master_syn_matrix + new_syns; %Adds predictions to synaptic matrix
    syn_cap = find(master_syn_matrix > won); %Determines where synapses above 0.01 are.
    master_syn_matrix(syn_cap) = won; %Sets matrix elements above 0.01 to 0.01.
    
    %Wipes Diagonal
    for i=1:8
        master_syn_matrix(1+set_anchors(i):cnts(i)+set_anchors(i),1+set_anchors(i):cnts(i)+set_anchors(i)) = 0;
    end
end