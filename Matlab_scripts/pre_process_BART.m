addpath('\\fileu\users$\oyakobi\My Documents\eeglab2019_1');
cd 'D:\users\EEG_DATA\preprocessed\'
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
dataPath = 'D:\users\EEG_DATA\preprocessed\tasks\';
BART_Artifact_rejected=struct('subjectid',[],'Rejected_artifacts_count',[],'Rejected_artifacts_percent',[],'Rejected_channel_count',[]);
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
    try
        flag=~isempty(k1{1}) || ~isempty(k2{1});
    catch
        flag=~isempty(k1) || ~isempty(k2);
    end;
    if flag; % If that's a resting state file
        disp(strcat('That is a resting state file :  ', fileName))
    else
        rownumber = rownumber + 1;
        % load pre-processed data file
        EEG = pop_loadset('filename', fileName, 'filepath', files_dir); 
        [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 1 );

        % The followingsplits the tasks (GNG, BART) into first and second halves, to
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

        % Create events
        EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' } );
        % Create bins
        EEG  = pop_binlister( EEG , 'BDF', 'C:\Users\oyakobi\OneDrive\Research_Projects\Boredom\EEG_Experiment2019\analysis_files\bin_lister_BART.txt', 'IndexEL',  1, 'SendEL2', 'EEG', 'Voutput', 'EEG' );
        % Create ephoched file
        
        [scrap,rej_chn1] = pop_rejchan(EEG, 'elec',[1:32] ,'threshold',5,'norm','on','measure','kurt');
        [scrap,rej_chn2] = pop_rejchan(EEG, 'elec',[1:32] ,'threshold',5,'norm','on','measure','prob');
        BART_Artifact_rejected(rownumber).Rejected_channel_count=length(unique([rej_chn1 rej_chn2]));
        EEG = pop_interp(EEG, unique([rej_chn1 rej_chn2]), 'spherical'); % Interpolate channels
        EEG = pop_epochbin( EEG , [-200.0  600.0],  'pre'); % -200 to 600 for fFRN        
        EEG = pop_runica(EEG, 'extended',1,'interupt','on'); %RUN ICA
        EEG = pop_iclabel(EEG, 'default'); % Run ICLabel
        EEG = eeg_checkset( EEG );
        EEG = pop_icflag(EEG, [NaN NaN;0.8 1;0.8 1;0.8 1;NaN NaN;0.8 1;NaN NaN]); % FLAG ARTIFCAT AUTOMATICALLY USING ICLabel
        if ~isempty(EEG.reject.gcompreject); % If there are components to subtract, do that
            EEG = pop_subcomp( EEG, find(EEG.reject.gcompreject == 1), 0); % Subtract components
        end
        EEG = eeg_checkset( EEG );
        %[scrap,rej_chn1] = pop_rejchan(EEG, 'elec',[1:32] ,'threshold',5,'norm','on','measure','kurt');
        %[scrap,rej_chn2] = pop_rejchan(EEG, 'elec',[1:32] ,'threshold',5,'norm','on','measure','prob');
        %BART_Artifact_rejected(rownumber).Rejected_channel_count=length(unique([rej_chn1 rej_chn2]));
        %EEG = pop_interp(EEG, unique([rej_chn1 rej_chn2]), 'spherical'); % Interpolate channels
        EEG  = pop_artmwppth( EEG , 'Channel',  1:32, 'Flag',  1, 'Threshold',  200, 'Twindow', [ 0 1000*length(EEG.data(1,:,1))*(1/EEG.srate)]-200, 'Windowsize',  200, 'Windowstep',100 ); %remove artifacts
        BART_Artifact_rejected(rownumber).subjectid=EEG.filename(1:6);
        BART_Artifact_rejected(rownumber).Rejected_artifacts_count=length(find(EEG.reject.rejmanual == 1));
        BART_Artifact_rejected(rownumber).Rejected_artifacts_percent=length(find(EEG.reject.rejmanual == 1))/length(EEG.epoch);
        if ~isempty(EEG.reject.rejmanual); % If there are epoches to remove
            EEG = pop_rejepoch( EEG, find(EEG.reject.rejmanual == 1), 0); % remove components
        end        
        EEG = eeg_checkset( EEG ); 
        EEG = pop_saveset( EEG, 'filename',strcat(EEG.filename(1:14),'_BART_ICA-removed_AR','.set'),'filepath',dataPath); % Save ICA'ed and AR removed eeg file
        eeglab redraw;
        
        %Create ERP file
        ERP = pop_averager( ALLEEG , 'Criterion', 'good','DQ_flag', 0 , 'DSindex',CURRENTSET, 'ExcludeBoundary', 'on', 'SEM', 'on' )
        %Create new diff bin
        ERP = pop_binoperator( ERP, {  'nb1 = b1 label Loss feedback',  'nb2 = b2 label Win feedback',  'nb3 = b1-b2 label FRN',  'nb4 = b3-b5 label FRN first half',  'nb5 = b4-b6 label FRN second half'});
        %Save ERP
        ERP = pop_savemyerp(ERP, 'erpname', strcat(EEG.filename(1:6),'_BART'), 'filename',strcat(EEG.filename(1:6),'_BART.erp'), 'filepath', dataPath);
        
        ALLEEG=pop_delset(ALLEEG,1:length(ALLEEG)); % Release EEG datasets from memory
        eeglab redraw;
        erplab redraw;
    end;
end;

eeglab redraw;
disp('done')

%Output excel file
cd C:\\Users\\oyakobi\\OneDrive\\Research_Projects\\Boredom\\EEG_Experiment2019\\data\\eeg\\;
xls_file_name=strcat('BART_preprocessing_summary','.xlsx');
writetable(struct2table(BART_Artifact_rejected), xls_file_name)

