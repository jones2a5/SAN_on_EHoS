%Checks if a winning set exists within the SAN.
function [wincheck,tied_idxs,winset] = winchk(neurons,set_anchors,cnts,wincheck,winset)
    allwin=0;
    tied_idxs = [];
    %Steps through each set.
    for i=1:8
        %Checks for max values in each set.
        val = max(neurons(1+set_anchors(i):cnts(i)+set_anchors(i)));
        if val == 0
            winset(i) = 0;
            allwin = allwin + 1;
        else
            idx = find( neurons(1+set_anchors(i):cnts(i)+set_anchors(i)) == val );
            if length(idx) == 1
                allwin = allwin + 1;
                winset(i) = idx;
            else
                tied_idxs = [tied_idxs idx+set_anchors(i)];
            end
        end
    end

    %If a single winner is found in each set, the network's state is determined to be found.
    if allwin == 8 || isempty(tied_idxs)
        wincheck=true;
    end

end