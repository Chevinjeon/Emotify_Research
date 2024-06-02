%% Using TRADITIONAL frequency bands (not individual) (by Ofir Yakobi)

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

BandNames={'Theta','LowAlpha1','LowAlpha2','UpAlpha','Alpha','Beta'};
% Create data structure for spectral power 
power_data=struct();
power_data(1)=[];
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

        %Save in data_struct the frequencies data (not power) 
        data_struct(rownumber).file=fileName;
        data_struct(rownumber).IAF=10; % 7 - 12 hz
        data_struct(rownumber).CoG=10;
        data_struct(rownumber).lowAlpha1Freq=data_struct(rownumber).IAF-3; 
        data_struct(rownumber).lowAlpha2Freq=data_struct(rownumber).IAF-1; 
        data_struct(rownumber).upAlphaFreq=data_struct(rownumber).IAF+1; 
        data_struct(rownumber).ThetaFreq=6; % 4-7Hz
        data_struct(rownumber).BetaFreq=16; % Beta is wider, for example 12-20 Hz
        %Calculat power for all relevant channels 
        [pxx, ff]=pwelch(data(1,:),EEG.srate*2,[],EEG.srate*4,256);
        pxx=nan(length(ff),num_of_electrodes); % each row is a frequency; col=electrodes
        for i=1:num_of_electrodes;
            [pxx(:,i), ff]=pwelch(data(i,:),EEG.srate*2,[],EEG.srate*4,256);
        end;
        %Now pxx has a column for each electrode.
        
        %Create a data structue with all the elctrodes and power data - to
        %use for example for spectral figures
        pxxi=pxx';
        [d, maxfreq]=min( abs(ff-30));
        for i=1:num_of_electrodes;
            power_data(end+1).file=fileName;
            current_row=length(power_data);
            power_data(current_row).electrode=i;
            for ji=1:maxfreq;
                power_data(current_row).(strrep(strcat('e',num2str(ff(ji))),'.','_'))=pxxi(i,ji);
            end;
        end;
        
        % Calculate the index of the closest frequency in ff array. e.g., 
        % if IAF is 10.1 and in ff array there is 10.09 only, it will give 
        % the index for this value. Find the ranges for all frequencies. 


        [d, Thetal_ind]=min( abs(ff-(data_struct(rownumber).ThetaFreq-2)));
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

        [d, Alpha_1]=min( abs(ff-(data_struct(rownumber).IAF-3))); %  ALPHA, e.g. 8-12
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
end;

disp('Save spectral power file');
writetable(struct2table(power_data), 'C:\\Users\\oyakobi\\OneDrive\\Research_Projects\\Boredom\\EEG_Experiment2019\\data\\eeg\\spectral_power.xlsx');

disp('Writing xlsx file.. (could take some time)')
%Output excel file
fields_names=[fieldnames(data_struct)];
cd C:\\Users\\oyakobi\\OneDrive\\Research_Projects\\Boredom\\EEG_Experiment2019\\data\\eeg\\;
xls_file_name=strcat('EEG_Absolute_power_electrodes_GLOBAL_FREQUENCY',num2str(round(now*1000)),'.xlsx');
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

