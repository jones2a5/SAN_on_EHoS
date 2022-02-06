# SAN_on_EHoS
MATLAB code that runs a segmented attractor network on the EHoS dataset with various learning techniques.

Simulation is ran from the SAN_master.m file. There is a set of hyperparameters at the start of the file that can be adjusted to change the simulation.

decay_type=1;              %Can adjust the decay rate between linear (0), or exponential/state-based (1, which is what is observed in published synaptic devices)

decay_rate=0.000;          %rstp, decay rate at which synapses decay their current state between each time step.

predictionthresh=0.000;    %Pth, prediction threshold that determines when predictive synaptic connections should be formed.

Lfactorthresh=1e9;         %Eth, threshold value for an erasure event to occur.

min_iters = 3;             %Number of passes performed on SAN during recall to determine if a winning set exists or not.

memory_count_track = true; %For record-keeping purposes.

won = 0.001;               %Programmed weight of synapses when activated.


The postanalysisfigures.m file runs some results on creating the figures from the data and can be ran once the SAN_master is finished with its simulation. 



