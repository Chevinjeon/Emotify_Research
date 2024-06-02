%Import, filter, slice all the raw EEG files. Step 1 of pre-processing
addpath('\\fileu\users$\oyakobi\My Documents\eeglab14_1_2b');
cd N:\EEG_DATA;
eeglab;
pop_editoptions('option_single', 0); 
ref_chans=[33 34]; % Reference channels
keep_files_opened=0;


[fnames, path]=uigetfile('*.bdf','Choose files to pre-process','MultiSelect','on');
if isa(fnames,'cell');
    nfiles=length(fnames);
else;
    nfiles=1;
end;

for j=1:nfiles;
    % EEG=pop_loadset(strcat(path,fnames(j))) % Load EEG file from a .set
    % file
    if isa(fnames,'cell');
        EEG = pop_biosig(strcat(path,fnames{j}),'channels',[1:37], 'ref',ref_chans ,'refoptions',{'keepref' 'off'}); % import only first 37 channels, in case there are more
        subjid=fnames{j}(1:end-4)
    else
        EEG = pop_biosig(strcat(path,fnames),'channels',[1:37], 'ref',ref_chans ,'refoptions',{'keepref' 'off'});
        subjid=fnames(1:end-4)
    end
    EEG = eeg_checkset( EEG ); % Make sure EEG structure is ok
    %Start pre-processing for file fnames(j)
    EEG = pop_resample( EEG, 256); %resample to 256 Hz (from 2048)
    %Filter: start with 60Hz notch, than 0.1-30hz filter
    EEG  = pop_basicfilter( EEG, 1:EEG.nbchan  , 'Boundary', 'boundary', 'Cutoff',  60, 'Design', 'notch', 'Filter', 'PMnotch', 'Order',  180, 'RemoveDC', 'on' );
    EEG  = pop_basicfilter( EEG,  1:EEG.nbchan , 'Boundary', 'boundary', 'Cutoff', [ 0.1 30], 'Design', 'butter', 'Filter', 'bandpass', 'Order',  4, 'RemoveDC', 'on' ); % GUI: 11-Jun-2019 15:44:56
    EEG = pop_editset(EEG, 'setname', subjid);
    
      %Load locations file:
    EEG=pop_chanedit(EEG, 'lookup','C:\\Users\\oyakobi\\OneDrive\\Research_Projects\\Boredom\\EEG_Experiment2019\\Experiment_protocol_and_electrodes\\OY_CAP.ced');

    %save EEG file: subjid_ds_filtered
    EEG = pop_saveset( EEG, 'filename',strcat(subjid,'_ds_filt','.set'),'filepath',strcat(path,'\preprocessed'));
    %Find the timing for start of resting state 1, EO, EC; file name
    %subjid_rest_EO/EC_1/2/3
    %Slice the first one, save it and then remove it from file, save file; go on to the second and third
    
    for i=1:length(EEG.event); % find FIRST EO resting state
        if EEG.event(i).type=='1' || EEG.event(i).type==1;
            first_EO_latency=EEG.event(i).latency/EEG.srate;
            disp(strcat('First EO latency was found'));
            EEG1 = pop_select( EEG,'time',[first_EO_latency-1 first_EO_latency+121] ); % from a sec before to a second after two minutes from beginning
            EEG1 = pop_saveset( EEG1, 'filename',strcat(subjid,'_ds_filt_EO1','.set'),'filepath',strcat(path,'\preprocessed'));
            EEG = pop_select( EEG,'notime',[first_EO_latency-1 first_EO_latency+121] ); % remove the first EO from the EEG file
            break;
        end;
        if i==length(EEG.event);
            disp(' *************   Could not find first EO!  ************');
        end;
    end;
    
    for i=1:length(EEG.event); % remove all boundray markers
        try
            if strcmp(EEG.event(i).type,'boundary');
                EEG = pop_editeventvals(EEG,'delete',i);  
            end;
        catch
            
        end;
    end;
        
    for i=1:length(EEG.event); % find FIRST EC resting state
        if EEG.event(i).type=='3' || EEG.event(i).type==3;
            first_EC_latency=EEG.event(i).latency/EEG.srate;
            disp(strcat('First EC latency was found'));
            EEG1 = pop_select( EEG,'time',[first_EC_latency-1 first_EC_latency+121] ); % from a sec before to a second after two minutes from beginning
            EEG1 = pop_saveset( EEG1, 'filename',strcat(subjid,'_ds_filt_EC1','.set'),'filepath',strcat(path,'\preprocessed'));
            EEG = pop_select( EEG,'notime',[first_EC_latency first_EC_latency+121] ); % remove the first EC from the EEG file
            break;
        end;
        if i==length(EEG.event);
            disp('Could not find first EC!');
        end;
    end;

    for i=1:length(EEG.event); % remove all boundray markers
        try
            if strcmp(EEG.event(i).type,'boundary');
                EEG = pop_editeventvals(EEG,'delete',i);  
            end;
        catch
            
        end;
    end;
    
    for i=1:length(EEG.event); % change all event types to string
        try
            if isa(EEG.event(i).type,'char') && length(EEG.event(i).type)<4;
                EEG.event(i).type=str2num(EEG.event(i).type);
            end;
        catch
            
        end;
    end;
    for i=1:length(EEG.event); % find SECOND EO resting state
        if EEG.event(i).type=='1' || EEG.event(i).type==1;
            second_EO_latency=EEG.event(i).latency/EEG.srate;
            disp(strcat('Second EO latency was found'));
            EEG1 = pop_select( EEG,'time',[second_EO_latency-1 second_EO_latency+121] ); % from a sec before to a second after two minutes from beginning
            EEG1 = pop_saveset( EEG1, 'filename',strcat(subjid,'_ds_filt_EO2','.set'),'filepath',strcat(path,'\preprocessed'));
            EEG = pop_select( EEG,'notime',[second_EO_latency-1 second_EO_latency+121] ); % remove the second EO from the EEG file
            break;
        end;
        if i==length(EEG.event);
            disp('Could not find second EO!');
        end;
    end;

    for i=1:length(EEG.event); % remove all boundray markers
        try
            if strcmp(EEG.event(i).type,'boundary');
                EEG = pop_editeventvals(EEG,'delete',i);  
            end;
        catch
            
        end;
    end;

    for i=1:length(EEG.event); % change all event types to string
        try
            if isa(EEG.event(i).type,'char') && length(EEG.event(i).type)<4;
                EEG.event(i).type=str2num(EEG.event(i).type);
            end;
        catch
            
        end;
    end;
    for i=1:length(EEG.event); % find SECOND EC resting state
        if EEG.event(i).type=='3' || EEG.event(i).type==3;
            second_EC_latency=EEG.event(i).latency/EEG.srate;
            disp(strcat('Second EC latency was found'));
            EEG1 = pop_select( EEG,'time',[second_EC_latency-1 second_EC_latency+121] ); % from a sec before to a second after two minutes from beginning
            EEG1 = pop_saveset( EEG1, 'filename',strcat(subjid,'_ds_filt_EC2','.set'),'filepath',strcat(path,'\preprocessed'));
            EEG = pop_select( EEG,'notime',[second_EC_latency-1 second_EC_latency+121] ); % remove the second EO from the EEG file
            break;
        end;
        if i==length(EEG.event);
            disp('Could not find second EC!');
        end;
    end;

    for i=1:length(EEG.event); % remove all boundray markers
        try
            if strcmp(EEG.event(i).type,'boundary');
                EEG = pop_editeventvals(EEG,'delete',i);  
            end;
        catch
            
        end;
    end;
    for i=1:length(EEG.event); % change all event types to string
        try
            if isa(EEG.event(i).type,'char') && length(EEG.event(i).type)<4;
                EEG.event(i).type=str2num(EEG.event(i).type);
            end;
        catch
            
        end;
    end;
    %Find the GNG task, slice save and remove
    GNG_start_latency=-1;
    GNG_end_latency=-1;
    for i=1:length(EEG.event);
        if strcmp(EEG.event(i).type,'10') || EEG.event(i).type==10;
            GNG_start_latency=EEG.event(i).latency/EEG.srate;
            disp('Go/no-go task start was found');
        end;
        if strcmp(EEG.event(i).type,'17') || EEG.event(i).type==17;
            GNG_end_latency=EEG.event(i).latency/EEG.srate;
            disp('Go/no-go task end was found');
        end;
        if GNG_start_latency>0 && GNG_end_latency>0;
            EEG1 = pop_select( EEG,'time',[GNG_start_latency-1 GNG_end_latency+1] );
            EEG1 = pop_saveset( EEG1, 'filename',strcat(subjid,'_ds_filt_GNG','.set'),'filepath',strcat(path,'\preprocessed'));
            EEG = pop_select( EEG,'notime',[GNG_start_latency-1 GNG_end_latency+1] ); % remove the GNG task from the EEG file
            break;
        end;
    end;

    for i=1:length(EEG.event); % remove all boundray markers
        try
            if strcmp(EEG.event(i).type,'boundary');
                EEG = pop_editeventvals(EEG,'delete',i);  
            end;
        catch
        end;
    end;

    for i=1:length(EEG.event); % change all event types to string
        try
            if isa(EEG.event(i).type,'char') && length(EEG.event(i).type)<4;
                EEG.event(i).type=str2num(EEG.event(i).type);
            end;
        catch
            
        end;
    end;
    
    %Find the BART task, save slice and remove
    BART_start_latency=-1;
    BART_end_latency=-1;
    for i=1:length(EEG.event);
        
        if strcmp(EEG.event(i).type,'20') || EEG.event(i).type==20;
            BART_start_latency=EEG.event(i).latency/EEG.srate;
            disp('BART start was found');
        end;
        if strcmp(EEG.event(i).type,'25') || EEG.event(i).type==25;
            BART_end_latency=EEG.event(i).latency/EEG.srate;
            disp('BART task end was found');
        end;
        if BART_start_latency>0 && BART_end_latency>0;
            EEG1 = pop_select( EEG,'time',[BART_start_latency-1 BART_end_latency+1] );
            EEG1 = pop_saveset( EEG1, 'filename',strcat(subjid,'_ds_filt_BART','.set'),'filepath',strcat(path,'\preprocessed'));
            EEG = pop_select( EEG,'notime',[BART_start_latency-1 BART_end_latency+1] ); % remove the GNG task from the EEG file
            break;
        end;
    end; 
    
    %End of pre-processing
    if keep_files_opened==1; % do we want all the eeg that were loaded saved in memory in eeglab?
        [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG); % Save it in structure
    end
end


eeglab redraw;