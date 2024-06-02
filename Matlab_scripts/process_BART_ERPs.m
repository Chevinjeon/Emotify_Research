addpath('\\fileu\users$\oyakobi\My Documents\eeglab2019_1');
if ~exist('EEG','var');
    eeglab;
end;
dataPath = 'D:\users\EEG_DATA\preprocessed\tasks\';
cd 'D:\users\EEG_DATA\preprocessed\tasks\';

[files_list, files_dir]=uigetfile(strcat(dataPath,'*BART*.erp'), 'Pick BART erps only', 'MultiSelect', 'on'); 
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
erplab redraw;

ERP = pop_gaverager( ALLERP , 'Erpsets',1:length(ALLERP), 'ExcludeNullBin', 'on', 'SEM', 'on' );
ERP.erpname='BART erps';
CURRENTERP = CURRENTERP + 1;
ALLERP(CURRENTERP) = ERP;
erplab redraw;
eeglab redraw;
%OUTPUT MEASUREMENTS TO FILE
ALLERP = pop_geterpvalues( ALLERP, [ 220 320],  3:5,  1:32 , 'Baseline', 'none', 'Binlabel', 'on','Erpsets',1:length(ALLERP)-1, 'FileFormat', 'long', 'Filename','C:\Users\oyakobi\OneDrive\Research_Projects\Boredom\EEG_Experiment2019\data\erp\BART_amp.csv', 'Fracreplace', 'NaN', 'InterpFactor',  1, 'Measure', 'peakampbl', 'Neighborhood',  3, 'PeakOnset',  1, 'Peakpolarity', 'negative', 'Peakreplace', 'absolute', 'Resolution',  3, 'SendtoWorkspace', 'off' );
ALLERP = pop_geterpvalues( ALLERP, [ 220 320],  3:5,  1:32 , 'Baseline', 'pre', 'Binlabel', 'on', 'Erpsets',1:length(ALLERP)-1, 'FileFormat', 'long', 'Filename', 'C:\Users\oyakobi\OneDrive\Research_Projects\Boredom\EEG_Experiment2019\data\erp\BART_lat.txt', 'Fracreplace', 'NaN', 'InterpFactor',1, 'Measure', 'peaklatbl', 'Neighborhood',3, 'PeakOnset',1,'Peakpolarity', 'negative', 'Peakreplace', 'absolute', 'Resolution',3, 'SendtoWorkspace', 'off' );

ALLERP = pop_geterpvalues( ALLERP, [ 350 450],  3:5,  1:32 , 'Baseline', 'none', 'Binlabel', 'on','Erpsets',1:length(ALLERP)-1, 'FileFormat', 'long', 'Filename','C:\Users\oyakobi\OneDrive\Research_Projects\Boredom\EEG_Experiment2019\data\erp\BART_P3_amp.txt', 'Fracreplace', 'NaN', 'InterpFactor',  1, 'Measure', 'peakampbl', 'Neighborhood',  3, 'PeakOnset',  1, 'Peakpolarity', 'positive', 'Peakreplace', 'absolute', 'Resolution',  3, 'SendtoWorkspace', 'off' );
ALLERP = pop_geterpvalues( ALLERP, [ 350 450],  3:5,  1:32 , 'Baseline', 'pre', 'Binlabel', 'on', 'Erpsets',1:length(ALLERP)-1, 'FileFormat', 'long', 'Filename', 'C:\Users\oyakobi\OneDrive\Research_Projects\Boredom\EEG_Experiment2019\data\erp\BART_P3_lat.txt', 'Fracreplace', 'NaN', 'InterpFactor',1, 'Measure', 'peaklatbl', 'Neighborhood',3, 'PeakOnset',1, 'Peakpolarity', 'positive', 'Peakreplace', 'absolute', 'Resolution',3, 'SendtoWorkspace', 'off' );

erplab redraw;
eeglab redraw;


% Start with Spectral Analysis (evoked spectra)

ALLERP=buildERPstruct([]);
CURRENTERP = 0;

for i=1:ns;
    ERP = pop_loaderp( 'filename', files_list(i), 'filepath', files_dir );
    ERP = pop_getFFTfromERP( ERP , 'NFFT',  512, 'TaperWindow', 'on' );
    %ERP = pop_binoperator( ERP, {  'nb1 = b1 label Loss feedback',  'nb2 = b2 label Win feedback',  'nb3 = b1-b2 label FRN'});
    CURRENTERP = CURRENTERP + 1;
    ALLERP(CURRENTERP) = ERP;
    erplab redraw;
    
end;
eeglab redraw;
erplab redraw;

ERP = pop_gaverager( ALLERP , 'Erpsets',1:length(ALLERP), 'ExcludeNullBin', 'on', 'SEM', 'on' );
ERP.erpname='BART erps - spectral';
CURRENTERP = CURRENTERP + 1;
ALLERP(CURRENTERP) = ERP;
erplab redraw;
eeglab redraw;
%OUTPUT MEASUREMENTS TO FILE
ALLERP = pop_geterpvalues( ALLERP, [ 8 12],  3:5,  1:32 , 'Baseline', 'none', 'Binlabel', 'on', 'Erpsets',  1:length(ALLERP)-1, 'FileFormat', 'long', 'Filename',...
 'C:\Users\oyakobi\OneDrive\Research_Projects\Boredom\EEG_Experiment2019\data\erp\BART_alpha.csv', 'Fracreplace', 'NaN', 'InterpFactor',...
  1, 'Measure', 'meanbl', 'PeakOnset',  1, 'Resolution',  3, 'SendtoWorkspace', 'on' );

ALLERP = pop_geterpvalues( ALLERP, [ 4 7],  3:5,  1:32 , 'Baseline', 'none', 'Binlabel', 'on', 'Erpsets',  1:length(ALLERP)-1, 'FileFormat', 'long', 'Filename',...
 'C:\Users\oyakobi\OneDrive\Research_Projects\Boredom\EEG_Experiment2019\data\erp\BART_theta.csv', 'Fracreplace', 'NaN', 'InterpFactor',...
  1, 'Measure', 'meanbl', 'PeakOnset',  1, 'Resolution',  3, 'SendtoWorkspace', 'on' );

erplab redraw;
eeglab redraw;

disp('Done');
