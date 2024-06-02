% This script splits the tasks (GNG, BART) into first and second halves, to
% test effects of time on task
types=[12,13,14,15, 23,24];

for j=1:length(types)
    type=types(j);

    count1=0;
    for i=1:length(EEG.event)
        if EEG.event(i).type==type
            count1=count1+1;
        end
    end

    count2=0;
    for i=1:length(EEG.event)
        if EEG.event(i).type==type
            count2=count2+1;
            if count2<=round(count1/2)
                EEG.event(i).type=type*10+1;
            elseif count2>round(count1/2)
                EEG.event(i).type=type*10+2;
            end
        end
    end
end