%plan b: not creating separate files but renumbewring the EO EC events
%Import, filter, slice all the raw EEG files. Step 1 of pre-processing
addpath('\\fileu\users$\oyakobi\My Documents\eeglab2019_1');
cd D:\users\EEG_DATA\;
eeglab;
pop_editoptions('option_single', 0); 
ref_chans=[33 34]; % Reference channels
keep_files_opened=0;


[fnames, path]=uigetfile('*.bdf','Choose files to pre-process','MultiSelect','on');
fnames = setdiff(fnames,'395941.bdf');
if isa(fnames,'cell');
    nfiles=length(fnames);
else
    nfiles=1;
end;


for j=1:nfiles;
    % EEG=pop_loadset(strcat(path,fnames(j))) % Load EEG file from a .set
    % file
    if isa(fnames,'cell');
        EEG = pop_biosig(strcat(path,fnames{j}),'channels',[1:37], 'ref',ref_chans ,'refoptions',{'keepref' 'off'}); % import only first 37 channels, in case there are more
        subjid=fnames{j}(1:end-4);
    else
        EEG = pop_biosig(strcat(path,fnames),'channels',[1:37], 'ref',ref_chans ,'refoptions',{'keepref' 'off'});
        subjid=fnames(1:end-4);
    end;
    EEG = eeg_checkset( EEG ); % Make sure EEG structure is ok
    %Start pre-processing for file fnames(j)
    EEG = pop_resample( EEG, 256); %resample to 256 Hz (from 2048)
    %Filter: start with 60Hz notch, then 0.1-30hz filter
    EEG  = pop_basicfilter( EEG, 1:EEG.nbchan  , 'Boundary', 'boundary', 'Cutoff',  60, 'Design', 'notch', 'Filter', 'PMnotch', 'Order',  180, 'RemoveDC', 'on' );
    EEG  = pop_basicfilter( EEG,  1:EEG.nbchan , 'Boundary', 'boundary', 'Cutoff', [ 0.1 30], 'Design', 'butter', 'Filter', 'bandpass', 'Order',  4, 'RemoveDC', 'on' ); % GUI: 11-Jun-2019 15:44:56
    EEG = pop_editset(EEG, 'setname', subjid);
    
      %Load locations file:
    EEG=pop_chanedit(EEG, 'lookup','C:\\Users\\oyakobi\\OneDrive\\Research_Projects\\Boredom\\EEG_Experiment2019\\Experiment_protocol_and_electrodes\\OY_CAP.ced');

    %Find the timing for start of resting state 1, EO, EC; file name
    %subjid_rest_EO/EC_1/2
    count_EO=0;
    count_EC=0;
    for i=1:length(EEG.event); % find FIRST EO resting state
        if (EEG.event(i).type=='1' || EEG.event(i).type==1);
            if count_EO==1;
                EEG.event(i).type=EEG.event(i).type+500
            end;
            count_EO=count_EO+1
        elseif (EEG.event(i).type=='2' || EEG.event(i).type==2) && count_EO==2;
            EEG.event(i).type=EEG.event(i).type+500
        end
        
        if (EEG.event(i).type=='3' || EEG.event(i).type==3);
            if count_EC==1;
                EEG.event(i).type=EEG.event(i).type+500
            end;
            count_EC=count_EC+1
        elseif (EEG.event(i).type=='4' || EEG.event(i).type==4) && count_EC==2;
            EEG.event(i).type=EEG.event(i).type+500
        end
    end
    
    %Remove BART events that happen before actual BART task (and not
    %training) start
    BART_STARTED=0;
    remove_events=[];
    for i=1:length(EEG.event)-5;
        if (EEG.event(i).type==20);
            if BART_STARTED==1;
                error('More than one BART start!');
            end;
            BART_STARTED=1;
        end;
        if BART_STARTED==0;
            if (EEG.event(i).type==21 || EEG.event(i).type==22 ||  EEG.event(i).type==23 || EEG.event(i).type==24);
                remove_events=[remove_events i];
            end;
        end;
    end;
    if ~isempty(remove_events);
        EEG = pop_editeventvals(EEG,'delete',remove_events);    
    end;

    %save EEG file: subjid_ds_filtered
    EEG = pop_saveset( EEG, 'filename',strcat(subjid,'_ds_filt','.set'),'filepath',strcat(path,'\preprocessed'));

    %Save resting state files:
    EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' } );
    EEG1=EEG;
    EEG2=EEG;
    EEG3=EEG;
    EEG  = pop_binlister( EEG , 'BDF', 'C:\Users\oyakobi\OneDrive\Research_Projects\Boredom\EEG_Experiment2019\analysis_files\bin_lister_eo1.txt', 'IndexEL',  1, 'SendEL2', 'EEG', 'Voutput', 'EEG' );
    EEG = pop_epochbin( EEG , [0  1000],  'none');
    EEG = pop_saveset( EEG, 'filename',strcat(subjid,'_ds_filt_EO1','.set'),'filepath',strcat(path,'\preprocessed'));
    EEG1  = pop_binlister( EEG1 , 'BDF', 'C:\Users\oyakobi\OneDrive\Research_Projects\Boredom\EEG_Experiment2019\analysis_files\bin_lister_eo2.txt', 'IndexEL',  1, 'SendEL2', 'EEG', 'Voutput', 'EEG' );
    EEG1 = pop_epochbin( EEG1 , [0  1000],  'none');
    EEG1 = pop_saveset( EEG1, 'filename',strcat(subjid,'_ds_filt_EO2','.set'),'filepath',strcat(path,'\preprocessed'));
    EEG2  = pop_binlister( EEG2 , 'BDF', 'C:\Users\oyakobi\OneDrive\Research_Projects\Boredom\EEG_Experiment2019\analysis_files\bin_lister_ec1.txt', 'IndexEL',  1, 'SendEL2', 'EEG', 'Voutput', 'EEG' );
    EEG2 = pop_epochbin( EEG2 , [0  1000],  'none');
    EEG2 = pop_saveset( EEG2, 'filename',strcat(subjid,'_ds_filt_EC1','.set'),'filepath',strcat(path,'\preprocessed'));
    EEG3  = pop_binlister( EEG3 , 'BDF', 'C:\Users\oyakobi\OneDrive\Research_Projects\Boredom\EEG_Experiment2019\analysis_files\bin_lister_ec2.txt', 'IndexEL',  1, 'SendEL2', 'EEG', 'Voutput', 'EEG' );
    EEG3 = pop_epochbin( EEG3 , [0  1000],  'none');
    EEG3 = pop_saveset( EEG3, 'filename',strcat(subjid,'_ds_filt_EC2','.set'),'filepath',strcat(path,'\preprocessed'));
    

    %End of pre-processing
    if keep_files_opened==1; % do we want all the eeg that were loaded saved in memory in eeglab?
        [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG); % Save it in structure
    end
end

% Remove these files because in that participant there is no 2nd recording
% of baseline:
delete(strcat(path,'\preprocessed\','395941_ds_filt_EC2.fdt'))
delete(strcat(path,'\preprocessed\','395941_ds_filt_EC2.set'))
delete(strcat(path,'\preprocessed\','395941_ds_filt_EO2.fdt'))
delete(strcat(path,'\preprocessed\','395941_ds_filt_EO2.set'))

eeglab redraw;
disp('done')