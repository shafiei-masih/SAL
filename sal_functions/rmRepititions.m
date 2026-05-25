function kin = rmRepititions(kinematics, repititions)
% This function place NaNs for the kinematics data of those trials that are
% repititive. The idea is to keep the appearance of trials in
% the data consistent across conditions. The repititions are spotted and
% labelled using another custom-made script
% (~/Functions/markRepititions.m). Here, we just remove their corresponding
% data from the pool.
%
% All kinematic features belongings to those trials labelled "2" 
% (repititive within a sequence) are discarded.
%
% For those with the label "3" (end trial in a sequence), all kinematics
% are discarded expect those that belong to the corrective saccade. This
% allows us to later study the influence of their error on the next
% performance.

kin = kinematics;
fnames = fieldnames(kin);
for triali = 1:size(repititions,1)
    if repititions(triali) == 2
        for vari = 1:11
            kin(triali).(fnames{vari}) = NaN;
        end
    elseif repititions(triali) == 3
        for vari = 1:8
            kin(triali).(fnames{vari}) = NaN;
        end
    end
end

end