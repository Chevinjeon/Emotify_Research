% This is an old script. Refer to process_GNG_stim or process_GNG_resp,
% etc.




% Create events
EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' } );

% Create bins for response locked
EEG  = pop_binlister( EEG , 'BDF', 'C:\Users\oyakobi\OneDrive\Research_Projects\Boredom\EEG_Experiment2019\analysis_files\bin_lister_GNG_Response-locked.txt', 'IndexEL',  1, 'SendEL2', 'EEG', 'Voutput', 'EEG' );

% Create ephoched file
EEG = pop_epochbin( EEG , [-100.0  300.0],  'pre');

EEG = pop_runica(EEG, 'extended',1,'interupt','on');
eeglab redraw;

% Create diff bin
ERP = pop_binoperator( ERP, {  'nb1 = b1 label Correct HIT',  'nb2 = b2 label Error FA',  'nb3 = b2-b1 label ERN'});


%For stimuli locked:

% Create events
EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' } );

% Create bins
EEG  = pop_binlister( EEG , 'BDF', 'C:\Users\oyakobi\OneDrive\Research_Projects\Boredom\EEG_Experiment2019\analysis_files\bin_lister_GNG_Stimuli-locked.txt', 'IndexEL',  1, 'SendEL2', 'EEG', 'Voutput', 'EEG' );

% Create ephoched file
EEG = pop_epochbin( EEG , [-200.0  600.0],  'pre');

eeglab redraw;
%run ICA
EEG = pop_runica(EEG, 'extended',1,'interupt','on');


% Create diff bin
ERP = pop_binoperator( ERP, {  'nb1 = b1 label Go trials',  'nb2 = b2 label No-go trials',  'nb3 = b1-b2 label go - no-go'});

