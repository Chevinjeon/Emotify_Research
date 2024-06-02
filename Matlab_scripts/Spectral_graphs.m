%% Using Corcoran's IAF algorithm restingIAF, calculate IAF (by Ofir Yakobi)

%% Preliminary setup
addpath('\\fileu\users$\oyakobi\My Documents\eeglab2019_1');
addpath('\\fileu\users$\oyakobi\My Documents\restingIAF-master');
% this command ensures restinglAF functions and tutorial files are
% accessible to my path (NB: may not work with all operating systems) %addpath(genpath('../.))
% fire up eeglab (may also need to add to path) 
if ~exist('EEG','var');
    eeglab;
end;

% ensure double precision is switched on 
pop_editoptions('option_single', 0);

% Use GUI to load files:
%open_closed=questd1g('Eyes open or closed?','Choose eyes closed or open','open','closed',[]); % Open or closed eyes?
[files_list, files_dir]=uigetfile(strcat('D:\users\EEG_DATA\preprocessed\AR_free\*','*.set'), 'Pick resting state data', 'MultiSelect', 'on'); 
if ~iscell(files_list);
    disp('Warning- you only selected one file');
    ns = 1;	% number of files for analysis is one
else
    ns = length(files_list);	% number of subjects for analysis
end;

% define path to the data files -- useful if files not stored in current
% path; redundant here (note syntax conventions may differ across systems) 
dataPath = 'D:\users\EEG_DATA\preprocessed\';
  
% Create data structure
datastruct=struct('subjectid',[]);
RegionNames={'AntLeft', 'AntMid', 'AntRight', 'CentLeft', 'CentMid', 'CentRight', 'PostLeft', 'PostMid', 'PostRight'}; 
BandNames={'Theta','LowAlpha1','LowAlpha2','UpAlpha','ExtendedAlpha','Beta'};
%Electrodes Array - which electrodes to analyze
%Ant=Anterior, Post=Posterior, Cent Central; Left, Right, Midline4
%Define regions structure
Electrodes_struct=struct();
Electrodes_struct.AntLeft=[2:4]; 
Electrodes_struct.AntMid=[31];
Electrodes_struct.AntRight=[27:29]; 
Electrodes_struct.CentLeft=[6,8,10]; 
Electrodes_struct.CentMid=[5,9,26,22,32]; 
Electrodes_struct.CentRight=[21,23,25]; 
Electrodes_struct.PostLeft=[11,12,14,15]; 
Electrodes_struct.PostMid=[13,16]; 
Electrodes_struct.PostRight=[17:20];
AllElectrodes=[Electrodes_struct.AntLeft Electrodes_struct.AntMid Electrodes_struct.AntRight Electrodes_struct.CentLeft...
    Electrodes_struct.CentMid Electrodes_struct.CentRight Electrodes_struct.PostRight Electrodes_struct.PostMid Electrodes_struct.PostLeft];

%% Analysis loops
rownumber=0; %Number of VALID file (containing EO or EC), for proper indexing of data_struct
for ix = 1:ns;	% for each i-th file
    % setup filename / path
    if ns==1;
        fileName = fullfile(files_list); 
    else
        fileName = fullfile(files_list(ix)); 
    end
    k1=strfind(fileName,'EO1');
    k2=strfind(fileName,'EC1');
    if isempty(k1{1}) && isempty(k2{1});
        disp(strcat('There is no EO or EC in the file name :  ', fileName))
    else
        rownumber = rownumber + 1;
        % load pre-processed data file
        EEG = pop_loadset('filename', fileName, 'filepath', files_dir); 
        [ALLEEG, EEG, CDRRENTSET] = eeg_store( ALLEEG, EEG, 1 );
        % select data, set remaining params 
        data = EEG.data;
        nchan = EEG.nbchan;
        Fs = EEG.srate;
        % if data are epoched, concatenate 
        if length(size(data)) == 3;
            data = reshape(data, nchan, []);
        end

         %Calculat power for all relevant channels 
        [pxx, ff]=pwelch(data(1,:),EEG.srate*2,[],EEG.srate*4,256);
        pxx=nan(length(ff),max(AllElectrodes)); % each row is a frequency; col=electrodes
        for i=1:max(AllElectrodes);
            if ismember(i,AllElectrodes);
                [pxx(:,i), ff]=pwelch(data(i,:),EEG.srate*2,[],EEG.srate*4,256);
            end;
        end;
    fields_names={'ID','Recording'};
    write_data={fileName{1}(1:6),fileName{1}(16:18)};
    for i=3:145;
        fields_names(i)={num2str(ff(i-2))};
        write_data(i)={num2str(pxx(i-2,16))};
    end;
    cd C:\\Users\\oyakobi\\OneDrive\\Research_Projects\\Boredom\\EEG_Experiment2019\\data\\eeg\\;
    xls_file_name=strcat('spectral_data','.xlsx');
    if rownumber==1;
        xlswrite(xls_file_name, fields_names, 'Sheet1','A1');
    end;
    xlswrite(xls_file_name, write_data, 'Sheet1',strcat('A',num2str(rownumber+1)));
    end;
end
disp('done')

