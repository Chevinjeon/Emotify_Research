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
 
cmin = 1;  % minimum number of channel estimates required for
            % cross-channel averages (for tutorial data: min == 1, max == 6) 
fRange = [1 30];  % spectral range (set to filter passband)
w = [7 13]; % alpha peak search window (Hz)
Fw = 11; % SGF frame width (11 for -0.24 Hz resolution)
k= 5; % SGF polynomial order

 
% initialise data matrices / structures 
pSpec = struct('chans', [], 'sums', []); 
nchan = nan(1, 2);
muPaf = nan(ns, 1);
muCog = nan(ns, 1);
% Create data structure
BandNames={'Theta','LowAlpha1','LowAlpha2','UpAlpha','Alpha','Beta'};

%% Analysis loops
rownumber=0; %Number of VALID file (containing EO or EC), for proper indexing of data_struct
for ix = 1:ns;	% for each i-th file
    % setup filename / path
    if ns==1;
        fileName = fullfile(files_list); 
    else
        fileName = fullfile(files_list(ix)); 
    end
    k1=strfind(fileName,'EO');
    k2=strfind(fileName,'EC');
    if isempty(k1(1)) && isempty(k2(1));
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
        num_of_electrodes=length({EEG.chanlocs.labels})-3;
        % run 'restinglAF'
        % NOTE: only required inputs specified, further optional inputs 
        % are also available (see 'restinglAF' help)
        [pSpec.sums, pSpec.chans, f]...
            = restingIAF(data, nchan, cmin, fRange, Fs, w, Fw, k);

        %Save in data_struct the frequencies data (not power) 
        data_struct(rownumber).file=fileName;
        data_struct(rownumber).IAF=pSpec.sums.paf;
        data_struct(rownumber).CoG=pSpec.sums.cog;
        if isnan(data_struct(rownumber).IAF); % If couldn't calculate IAF - use CoG instead; If neither IAF=10 and cue is added
            if isnan(data_struct(rownumber).CoG);
                data_struct(rownumber).IAF=10;
                data_struct(rownumber).CoG='X'; %Cue for Python script to ignore data
            else
                data_struct(rownumber).IAF=data_struct(rownumber).CoG;
            end;
        end;
        data_struct(rownumber).lowAlpha1Freq=data_struct(rownumber).IAF-3; 
        data_struct(rownumber).lowAlpha2Freq=data_struct(rownumber).IAF-1; 
        data_struct(rownumber).upAlphaFreq=data_struct(rownumber).IAF+1; 
        data_struct(rownumber).ThetaFreq=data_struct(rownumber).IAF-5; %Klimesch 1999 p15	, Babiloni et al 2012 
        data_struct(rownumber).BetaFreq=data_struct(rownumber).IAF+6; % Beta is wider, for example 13-20 Hz
        %Calculat power for all relevant channels 
        [pxx, ff]=pwelch(data(1,:),EEG.srate*2,[],EEG.srate*4,256);
        pxx=nan(length(ff),num_of_electrodes); % each row is a frequency; col=electrodes
        for i=1:num_of_electrodes;
            [pxx(:,i), ff]=pwelch(data(i,:),EEG.srate*2,[],EEG.srate*4,256);
        end;
        %Now pxx has a column for each electrode.

        % Calculate the index of the closest frequency in ff array. e.g., 
        % if IAF is 10.1 and in ff array there is 10.09 only, it will give 
        % the index for this value. Find the ranges for all frequencies. 


        [d, Thetal_ind]=min( abs(ff-(data_struct(rownumber).ThetaFreq-1)));
        [d, Theta2ind]=min( abs(ff-(data_struct(rownumber).ThetaFreq+1)));
        for h=1:num_of_electrodes;
            data_struct(rownumber).ThetaPower.(char(EEG.chanlocs(h).labels))=mean(mean(pxx(Thetal_ind:Theta2ind,h))); 
        end;

        [d, lowAlpha1_1]=min( abs(ff -(data_struct(rownumber).lowAlpha1Freq-1)) ); 
        [d, lowAlpha1_2]=min( abs(ff -(data_struct(rownumber).lowAlpha1Freq+1)) ); 
        for h=1:num_of_electrodes;
            data_struct(rownumber).lowAlpha1Power.(char(EEG.chanlocs(h).labels))=mean(mean(pxx(lowAlpha1_1:lowAlpha1_2,h))) ;
        end

        [d, lowAlpha2_1]=min( abs(ff -(data_struct(rownumber).lowAlpha2Freq-1)) ); 
        [d, lowAlpha2_2]=min( abs(ff -(data_struct(rownumber).lowAlpha2Freq+1)) ); 
        for h=1:num_of_electrodes;
            data_struct(rownumber).lowAlpha2Power.(char(EEG.chanlocs(h).labels))=mean(mean(pxx(lowAlpha2_1:lowAlpha2_2,h))) ;
        end

        [d, UpAlpha_1]=min( abs(ff -(data_struct(rownumber).upAlphaFreq -1)) ); 
        [d, UpAlpha_2]=min( abs(ff-(data_struct(rownumber).upAlphaFreq+1)) ); 
        for h=1:num_of_electrodes;
            data_struct(rownumber).UpAlphaPower.(char(EEG.chanlocs(h).labels))=mean(mean(pxx(UpAlpha_1:UpAlpha_2,h)));
        end

        [d, Alpha_1]=min( abs(ff-(data_struct(rownumber).IAF-4))); % EXTENDED ALPHA, e.g. 7-13
        [d, Alpha_2]=min( abs(ff-(data_struct(rownumber).IAF+2)) );
        for h=1:num_of_electrodes; 
            data_struct(rownumber).AlphaPower.(char(EEG.chanlocs(h).labels))=mean(mean(pxx(Alpha_1:Alpha_2,h))); 
        end

        [d, Beta_1]=min( abs(ff-(data_struct(rownumber).BetaFreq-4)) ); 
        [d, Beta_2]=min( abs(ff-(data_struct(rownumber).BetaFreq+4)) ); 
        for h=1:num_of_electrodes;
            data_struct(rownumber).BetaPower.(char(EEG.chanlocs(h).labels))=mean(mean(pxx(Beta_1:Beta_2,h)));
        end
        ALLEEG=pop_delset(ALLEEG,1:length(ALLEEG)); % Release EEG datasets from memory
    end;
end
disp('Writing xlsx file.. (could take some time)')
%Output excel file
fields_names=[fieldnames(data_struct)];
cd C:\\Users\\oyakobi\\OneDrive\\Research_Projects\\Boredom\\EEG_Experiment2019\\data\\eeg\\;
xls_file_name=strcat('EEG_Absolute_power_electrodes',num2str(round(now*1000)),'.xlsx');
xlswrite(xls_file_name, fields_names(1:8)', 'Sheet1','A1');
temparr={};
for ii=9:length(fields_names);
    for jj=1:num_of_electrodes; 
        temparr{(ii-9)*num_of_electrodes+jj}=strcat(fields_names{ii},'_',EEG.chanlocs(jj).labels); 
    end;
end
xlswrite(xls_file_name, temparr, 'Sheet1','I1');

for i=1:length(data_struct);
    xlswrite(xls_file_name, data_struct(i).file, 'Sheet1', strcat('A' , num2str(i+1)));
    for j=2:8;
        xlswrite(xls_file_name, data_struct(i).(fields_names{j}), 'Sheet1' , strcat(char('B'+j-2) , num2str(i+1))); 
        pause(0.05);
    end
    temparr={};
    for k=9:length(fields_names);
        for jj=1:num_of_electrodes; 
            temparr{(k-9)*num_of_electrodes+jj}=num2str(data_struct(i).(fields_names{k}).(EEG.chanlocs(jj).labels));
        end
    end
    xlswrite(xls_file_name, temparr, 'Sheet1',strcat('I',num2str(1+i)));
end
disp('done')

