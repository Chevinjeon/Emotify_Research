addpath('\\fileu\users$\oyakobi\My Documents\eeglab2019_1');
if ~exist('EEG','var');
    eeglab;
end;
dataPath = 'D:\users\EEG_DATA\preprocessed\tasks\';
cd D:\users\EEG_DATA\preprocessed\tasks\;

[files_list, files_dir]=uigetfile(strcat(dataPath,'*GNG_stim*.erp'), 'Pick GNG_stim erps only', 'MultiSelect', 'on'); 
if ~iscell(files_list);
    disp('Warning- you only selected one file');
    ns = 1;	% number of files for analysis is one
else
    ns = length(files_list);	% number of subjects for analysis
end;

ALLERP=buildERPstruct([]);
CURRENTERP = 0;

for i=1:ns;
    ERP = pop_loaderp( 'filename', files_list(i), 'filepath', files_dir );
    ERP = pop_filterp( ERP,  1:35 , 'Cutoff',  25, 'Design', 'butter', 'Filter', 'lowpass', 'Order',  2 );
    CURRENTERP = CURRENTERP + 1;
    ALLERP(CURRENTERP) = ERP;
    erplab redraw;
end;

eeglab redraw;

ERP = pop_gaverager( ALLERP , 'Erpsets',1:length(ALLERP), 'ExcludeNullBin', 'on', 'SEM', 'on' );
ERP.erpname='GNG stim erps';
CURRENTERP = CURRENTERP + 1;
ALLERP(CURRENTERP) = ERP;
erplab redraw;
eeglab redraw;

%OUTPUT MEASUREMENTS TO FILE
ALLERP = pop_geterpvalues( ALLERP, [ 300 600],1:7,1:32 , 'Baseline', 'pre', 'Binlabel', 'on', 'Erpsets',1:length(ALLERP)-1, 'FileFormat', 'long', 'Filename', 'C:\Users\oyakobi\OneDrive\Research_Projects\Boredom\EEG_Experiment2019\data\erp\GNG_P3_amp.txt', 'Fracreplace', 'NaN', 'InterpFactor',1, 'Measure', 'meanbl', 'PeakOnset',1, 'Resolution',3, 'SendtoWorkspace', 'on' );
ALLERP = pop_geterpvalues( ALLERP, [ 300 600],1:7,1:32 , 'Baseline', 'pre', 'Binlabel', 'on', 'Erpsets',1:length(ALLERP)-1, 'FileFormat', 'long', 'Filename', 'C:\Users\oyakobi\OneDrive\Research_Projects\Boredom\EEG_Experiment2019\data\erp\GNG_P3_lat.txt', 'Fracreplace', 'NaN', 'InterpFactor',1, 'Measure', 'peaklatbl', 'Neighborhood',3, 'PeakOnset',1, 'Peakpolarity', 'positive', 'Peakreplace', 'absolute', 'Resolution',3, 'SendtoWorkspace', 'on' );
ALLERP = pop_geterpvalues( ALLERP, [ 200 400],1:7,1:32 , 'Baseline', 'pre', 'Binlabel', 'on', 'Erpsets',1:length(ALLERP)-1, 'FileFormat', 'long', 'Filename', 'C:\Users\oyakobi\OneDrive\Research_Projects\Boredom\EEG_Experiment2019\data\erp\GNG_N2_amp.txt', 'Fracreplace', 'NaN', 'InterpFactor',1, 'Measure', 'meanbl', 'PeakOnset',1, 'Resolution',3, 'SendtoWorkspace', 'on' );
ALLERP = pop_geterpvalues( ALLERP, [ 200 400],1:7,1:32 , 'Baseline', 'pre', 'Binlabel', 'on', 'Erpsets',1:length(ALLERP)-1, 'FileFormat', 'long', 'Filename', 'C:\Users\oyakobi\OneDrive\Research_Projects\Boredom\EEG_Experiment2019\data\erp\GNG_N2_lat.txt', 'Fracreplace', 'NaN', 'InterpFactor',1, 'Measure', 'peaklatbl', 'Neighborhood',3, 'PeakOnset',1, 'Peakpolarity', 'negative', 'Peakreplace', 'absolute', 'Resolution',3, 'SendtoWorkspace', 'on' );

erplab redraw;
eeglab redraw;



% Start with Spectral Analysis (evoked spectra)

ALLERP=buildERPstruct([]);
CURRENTERP = 0;

for i=1:ns;
    ERP = pop_loaderp( 'filename', files_list(i), 'filepath', files_dir );
    ERP = pop_getFFTfromERP( ERP , 'NFFT',  512, 'TaperWindow', 'on' );
    %ERP = pop_binoperator( ERP, {  'nb1 = b1 label Go trials',  'nb2 = b2 label No-go trials',  'nb3 = b1-b2 label go - no-go'});
    CURRENTERP = CURRENTERP + 1;
    ALLERP(CURRENTERP) = ERP;
    erplab redraw;
end;

eeglab redraw;

ERP = pop_gaverager( ALLERP , 'Erpsets',1:length(ALLERP), 'ExcludeNullBin', 'on', 'SEM', 'on' );
ERP.erpname='GNG stim evoked spectra';
CURRENTERP = CURRENTERP + 1;
ALLERP(CURRENTERP) = ERP;
erplab redraw;
eeglab redraw;

%OUTPUT MEASUREMENTS TO FILE
ALLERP = pop_geterpvalues( ALLERP, [ 8 12],  1:7,  1:32 , 'Baseline', 'none', 'Binlabel', 'on', 'Erpsets',  1:length(ALLERP)-1, 'FileFormat', 'long', 'Filename',...
 'C:\Users\oyakobi\OneDrive\Research_Projects\Boredom\EEG_Experiment2019\data\erp\GNG_stim_alpha.csv', 'Fracreplace', 'NaN', 'InterpFactor',...
  1, 'Measure', 'meanbl', 'PeakOnset',  1, 'Resolution',  3, 'SendtoWorkspace', 'on' );

ALLERP = pop_geterpvalues( ALLERP, [ 4 7],  1:7,  1:32 , 'Baseline', 'none', 'Binlabel', 'on', 'Erpsets',  1:length(ALLERP)-1, 'FileFormat', 'long', 'Filename',...
 'C:\Users\oyakobi\OneDrive\Research_Projects\Boredom\EEG_Experiment2019\data\erp\GNG_stim_theta.csv', 'Fracreplace', 'NaN', 'InterpFactor',...
  1, 'Measure', 'meanbl', 'PeakOnset',  1, 'Resolution',  3, 'SendtoWorkspace', 'on' );

copyfile('C:\Users\oyakobi\OneDrive\Research_Projects\Boredom\EEG_Experiment2019\data\erp\GNG_P3_amp.txt','C:\Users\oyakobi\OneDrive\Research_Projects\Boredom\EEG_Experiment2019\data\erp\GNG_goP3_amp.txt')
copyfile('C:\Users\oyakobi\OneDrive\Research_Projects\Boredom\EEG_Experiment2019\data\erp\GNG_P3_lat.txt','C:\Users\oyakobi\OneDrive\Research_Projects\Boredom\EEG_Experiment2019\data\erp\GNG_goP3_lat.txt')
erplab redraw;
eeglab redraw;

disp('Done');
