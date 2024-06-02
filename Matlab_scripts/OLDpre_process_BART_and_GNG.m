addpath('\\fileu\users$\oyakobi\My Documents\eeglab14_1_2b');
cd N:\EEG_DATA\preprocessed\;
if ~exist('EEG','var');
    eeglab;
end;

[files_list, files_dir]=uigetfile(strcat('N:\EEG_DATA\preprocessed\*','*.set'), 'Pick resting state data', 'MultiSelect', 'on'); 
if ~iscell(files_list);
    disp('Warning- you only selected one file');
    ns = 1;	% number of files for analysis is one
else
    ns = length(files_list);	% number of subjects for analysis
end;

% define path to the data files -- useful if files not stored in current
% path; redundant here (note syntax conventions may differ across systems) 
dataPath = 'N:\EEG_DATA\preprocessed\tasks\';

%% Analysis loops
rownumber=0; %Number of VALID file (containing EO or EC), for proper indexing of data_struct
for ix = 1:ns;	% for each i-th file
    if ns==1;
        fileName = fullfile(files_list); 
    else
        fileName = fullfile(files_list(ix)); 
    end
    k1=strfind(fileName,'EO');
    k2=strfind(fileName,'EC');
    if ~isempty(k1{1}) || ~isempty(k2{1}); % If that's a resting state file
        disp(strcat('That is a resting state file :  ', fileName))
    else
        rownumber = rownumber + 1;
        % load pre-processed data file
        EEG = pop_loadset('filename', fileName, 'filepath', files_dir); 
        [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
        %RUN ICA
        EEG = pop_runica(EEG, 'extended',1,'interupt','on');
        [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
        %Run adjust
        [ALLEEG,EEG,CURRENTSET,com] = pop_ADJUST_interface (ALLEEG,EEG,CURRENTSET );

        rej=[]
        for iii=1:length(EEG.reject.gcompreject);
            if EEG.reject.gcompreject(iii);
                rej=[rej iii];
            end;
        end;
        EEG = pop_subcomp( EEG, rej, 0); % Remove selected components
        
        trsh=inputdlg('Enter threshold for artifact removal (e.g. 100)');
        trsh=str2num(trsh{1})
        go_on='Cancel';
        while go_on=='Cancel';
            EEG  = pop_artmwppth( EEG , 'Channel',  1:32, 'Flag',  1, 'Threshold',  trsh, 'Twindow', [ 0 996.1], 'Windowsize',  200, 'Windowstep',100 );
            go_on=questdlg('Continue');
        end;
        
        rej=[]
        for iii=1:length(EEG.reject.rejmanual);
            if EEG.reject.rejmanual(iii);
                rej=[rej iii];
            end;
        end;
        disp(length(rej));
        EEG = pop_rejepoch( EEG, rej ,0);
        EEG = pop_saveset( EEG, 'filename',fileName{1},'filepath','N:\EEG_DATA\preprocessed\AR_free\');
        ALLEEG=pop_delset(ALLEEG,1:length(ALLEEG)); % Release EEG datasets from memory
    end;
end;

eeglab redraw;






