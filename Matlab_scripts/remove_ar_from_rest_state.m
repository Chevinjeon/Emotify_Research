%REMOVE  AR from resting state data; including ICA correction and channel,interpolation
%updated 23/10/2019
%

addpath('\\fileu\users$\oyakobi\My Documents\eeglab2019_1');
cd D:\users\EEG_DATA\preprocessed\;
if ~exist('EEG','var');
    eeglab;
end;

[files_list, files_dir]=uigetfile(strcat('D:\users\EEG_DATA\preprocessed\*','*.set'), 'Pick resting state data', 'MultiSelect', 'on'); 
if ~iscell(files_list);
    disp('Warning- you only selected one file');
    ns = 1;	% number of files for analysis is one
else
    ns = length(files_list);	% number of subjects for analysis
end;

% define path to the data files -- useful if files not stored in current
% path; redundant here (note syntax conventions may differ across systems) 
dataPath = 'D:\users\EEG_DATA\preprocessed\AR_free\';

%% Analysis loops
rownumber=0; %Number of VALID file (containing EO or EC), for proper indexing of data_struct
RestingState_Artifact_rejected=struct('subjectid',[],'Rejected_artifacts_count',[],'Rejected_artifacts_percent',[],'Rejected_channel_count',[]);
startFrom=1;
for ix = startFrom:ns;	% for each i-th file
    if ns==1;
        fileName = fullfile(files_list); 
    else
        fileName = fullfile(files_list(ix)); 
    end
    k1=strfind(fileName,'EO');
    k2=strfind(fileName,'EC');
    if isempty(k1{1}) && isempty(k2{1});
        disp(strcat('There is no EO or EC in the file name :  ', fileName))
    else
        rownumber = rownumber + 1;
        % load pre-processed data file
        EEG = pop_loadset('filename', fileName, 'filepath', files_dir); 
        [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 1 );
        for lll=1:3 % Remove bad channels - three times to it doesnt miss
            [scrap,rej_chn1] = pop_rejchan(EEG, 'elec',[1:32] ,'threshold',5,'norm','on','measure','kurt');
            [scrap,rej_chn2] = pop_rejchan(EEG, 'elec',[1:32] ,'threshold',5,'norm','on','measure','prob');
            RestingState_Artifact_rejected(rownumber).Rejected_channel_count=length(unique([rej_chn1 rej_chn2]));
            EEG = pop_interp(EEG, unique([rej_chn1 rej_chn2]), 'spherical'); % Interpolate channels
        end
        EEG = pop_runica(EEG, 'extended',1,'interupt','on'); %RUN ICA
        EEG = pop_iclabel(EEG, 'default'); % Run ICLabel
        EEG = eeg_checkset( EEG )
        EEG = pop_icflag(EEG, [NaN NaN;0.8 1;0.8 1;0.8 1;NaN NaN;0.8 1;NaN NaN]); % FLAG ARTIFCAT AUTOMATICALLY USING ICLabel
        if ~isempty(EEG.reject.gcompreject); % If there are components to subtract, do that
            EEG = pop_subcomp( EEG, find(EEG.reject.gcompreject == 1), 0); % Subtract components
        end
        EEG = eeg_checkset( EEG );
        EEG  = pop_artmwppth( EEG , 'Channel',  1:32, 'Flag',  1, 'Threshold',  150, 'Twindow', [ 0 996.1], 'Windowsize',  200, 'Windowstep',100 ); %remove artifacts
        RestingState_Artifact_rejected(rownumber).subjectid=EEG.filename;
        RestingState_Artifact_rejected(rownumber).Rejected_artifacts_count=length(find(EEG.reject.rejmanual == 1));
        RestingState_Artifact_rejected(rownumber).Rejected_artifacts_percent=length(find(EEG.reject.rejmanual == 1))/length(EEG.epoch);
        
        if ~isempty(EEG.reject.rejmanual); % If there are epoches to remove
            EEG = pop_rejepoch( EEG, find(EEG.reject.rejmanual == 1), 0); % Subtract components
        end
        EEG = eeg_checkset( EEG );
        EEG = pop_saveset( EEG, 'filename',fileName{1},'filepath','D:\users\EEG_DATA\preprocessed\AR_free\');
        ALLEEG=pop_delset(ALLEEG,1:length(ALLEEG)); % Release EEG datasets from memory
    end;
end;

eeglab redraw;



cd C:\\Users\\oyakobi\\OneDrive\\Research_Projects\\Boredom\\EEG_Experiment2019\\data\\eeg\\;
xls_file_name=strcat('RestingState_preprocessing_summary','.xlsx');
writetable(struct2table(RestingState_Artifact_rejected), xls_file_name)

disp('done')

