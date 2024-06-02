% Mass Univariate Analyses
addpath('\\fileu\users$\oyakobi\My Documents\eeglab2019_1\plugins\mass_univ03272017')
addpath('\\fileu\users$\oyakobi\My Documents\eeglab2019_1');
if ~exist('EEG','var');
    eeglab;
end;

%BART
lowbp= {'319678_BART.erp', '320830_BART.erp', '321538_BART.erp', '322990_BART.erp', '337285_BART.erp', '337672_BART.erp', '349117_BART.erp', '349429_BART.erp', '349681_BART.erp', '351427_BART.erp', '353689_BART.erp', '353701_BART.erp', '360400_BART.erp', '360943_BART.erp', '361117_BART.erp', '362713_BART.erp', '365695_BART.erp', '366298_BART.erp', '367723_BART.erp', '368125_BART.erp', '368773_BART.erp', '369421_BART.erp', '370720_BART.erp', '371311_BART.erp', '373345_BART.erp', '381931_BART.erp', '381991_BART.erp', '382024_BART.erp', '382132_BART.erp', '382144_BART.erp', '384187_BART.erp', '384355_BART.erp', '384379_BART.erp', '384577_BART.erp', '386686_BART.erp', '389143_BART.erp', '391963_BART.erp', '392212_BART.erp', '392458_BART.erp', '392488_BART.erp', '392686_BART.erp', '393880_BART.erp', '395941_BART.erp'}
highbp= {'321880_BART.erp', '331282_BART.erp', '337270_BART.erp', '338920_BART.erp', '345286_BART.erp', '347995_BART.erp', '348109_BART.erp', '349600_BART.erp', '352633_BART.erp', '357940_BART.erp', '361156_BART.erp', '367219_BART.erp', '367747_BART.erp', '368014_BART.erp', '368446_BART.erp', '368740_BART.erp', '369439_BART.erp', '373276_BART.erp', '375025_BART.erp', '375397_BART.erp', '381856_BART.erp', '381946_BART.erp', '382174_BART.erp', '384058_BART.erp', '384658_BART.erp', '384895_BART.erp', '385897_BART.erp', '385909_BART.erp', '387244_BART.erp', '387337_BART.erp', '387343_BART.erp', '388048_BART.erp', '392542_BART.erp', '392554_BART.erp', '393490_BART.erp', '393961_BART.erp', '394084_BART.erp', '394792_BART.erp', '395041_BART.erp', '397576_BART.erp'}
%GNG Stim
lowbp= {'319678_GNG_stim.erp', '337270_GNG_stim.erp', '337285_GNG_stim.erp', '338920_GNG_stim.erp', '345286_GNG_stim.erp', '348109_GNG_stim.erp', '349429_GNG_stim.erp', '349600_GNG_stim.erp', '349681_GNG_stim.erp', '357940_GNG_stim.erp', '360400_GNG_stim.erp', '361117_GNG_stim.erp', '362713_GNG_stim.erp', '366298_GNG_stim.erp', '367747_GNG_stim.erp', '368125_GNG_stim.erp', '368773_GNG_stim.erp', '371311_GNG_stim.erp', '373276_GNG_stim.erp', '375025_GNG_stim.erp', '381856_GNG_stim.erp', '381931_GNG_stim.erp', '382024_GNG_stim.erp', '382144_GNG_stim.erp', '382174_GNG_stim.erp', '384355_GNG_stim.erp', '384379_GNG_stim.erp', '387244_GNG_stim.erp', '388048_GNG_stim.erp', '395941_GNG_stim.erp'}
highbp= {'320830_GNG_stim.erp', '321538_GNG_stim.erp', '321880_GNG_stim.erp', '322990_GNG_stim.erp', '331282_GNG_stim.erp', '337672_GNG_stim.erp', '347995_GNG_stim.erp', '349117_GNG_stim.erp', '351427_GNG_stim.erp', '352633_GNG_stim.erp', '353701_GNG_stim.erp', '360943_GNG_stim.erp', '361156_GNG_stim.erp', '367219_GNG_stim.erp', '367723_GNG_stim.erp', '368740_GNG_stim.erp', '369439_GNG_stim.erp', '375397_GNG_stim.erp', '381946_GNG_stim.erp', '381991_GNG_stim.erp', '382132_GNG_stim.erp', '384058_GNG_stim.erp', '384187_GNG_stim.erp', '384658_GNG_stim.erp', '384895_GNG_stim.erp', '385909_GNG_stim.erp', '386686_GNG_stim.erp', '387337_GNG_stim.erp', '387343_GNG_stim.erp', '389143_GNG_stim.erp'}
%GNG resp
lowbp= {'319678_GNG_resp.erp', '320830_GNG_resp.erp', '321538_GNG_resp.erp', '322990_GNG_resp.erp', '337285_GNG_resp.erp', '337672_GNG_resp.erp', '349117_GNG_resp.erp', '349429_GNG_resp.erp', '349681_GNG_resp.erp', '351427_GNG_resp.erp', '353701_GNG_resp.erp', '360400_GNG_resp.erp', '360943_GNG_resp.erp', '361117_GNG_resp.erp', '362713_GNG_resp.erp', '367723_GNG_resp.erp', '368773_GNG_resp.erp', '371311_GNG_resp.erp', '381991_GNG_resp.erp', '382132_GNG_resp.erp', '382144_GNG_resp.erp', '384187_GNG_resp.erp', '384355_GNG_resp.erp', '384379_GNG_resp.erp', '385909_GNG_resp.erp', '386686_GNG_resp.erp', '389143_GNG_resp.erp'}
highbp={'321880_GNG_resp.erp', '331282_GNG_resp.erp', '337270_GNG_resp.erp', '338920_GNG_resp.erp', '345286_GNG_resp.erp', '347995_GNG_resp.erp', '348109_GNG_resp.erp', '349600_GNG_resp.erp', '352633_GNG_resp.erp', '357940_GNG_resp.erp', '361156_GNG_resp.erp', '366298_GNG_resp.erp', '367219_GNG_resp.erp', '367747_GNG_resp.erp', '368125_GNG_resp.erp', '368740_GNG_resp.erp', '373276_GNG_resp.erp', '375025_GNG_resp.erp', '375397_GNG_resp.erp', '381856_GNG_resp.erp', '381931_GNG_resp.erp', '381946_GNG_resp.erp', '382024_GNG_resp.erp', '382174_GNG_resp.erp', '384058_GNG_resp.erp', '384658_GNG_resp.erp', '384895_GNG_resp.erp', '387244_GNG_resp.erp', '387337_GNG_resp.erp', '387343_GNG_resp.erp', '388048_GNG_resp.erp'}

cd 'D:\users\EEG_DATA\preprocessed\tasks\';
%GND=erplab2GND('gui','exclude_chans',{'VEOG','LhEOG','RhEOG'}); % All participants
GND_low=erplab2GND(lowbp,'exclude_chans',{'VEOG','LhEOG','RhEOG'}); % Low BP participants
GND_high=erplab2GND(highbp,'exclude_chans',{'VEOG','LhEOG','RhEOG'}); % High BP participants
GRP=GNDs2GRP('gui','create_difs','yes'); % Create differences GND
GRP=tmaxGRP(GRP,3,'time_wind',[100 700],'include_chans',{'Fz','Cz','Pz','Oz'});
GRP=tfdrGRP(GRP,3,'method','by','time_wind',[100 700],'exclude_chans',{'VEOG','LhEOG','RhEOG'});
GRP=clustGRP(GRP,1,'time_wind',[100 700],'exclude_chans',{'VEOG','LhEOG','RhEOG'},'chan_hood',.61,'thresh_p',.05);
GRP=tmaxGRP(GRP,1,'time_wind',[150 250],'mean_wind','yes');
load BART_64sub.GND -MAT;
gui_erp(GND);
GND=tmaxGND(GND,3,'time_wind',[100 500],'output_file','none.txt');  % 3 is the bin number
GND=tfdrGND(GND,3,'method','by','time_wind',[100 500],'output_file','none.txt'); % Another method (control of the false discovery rate)
GND=clustGND(GND,3,'time_wind',[100 500],'chan_hood',.61,'thresh_p',.05); %Another method - clustring
%print -f1 -depsc odblXO_raster   % To save a copy of the figure (say to include in a manuscript) enter something like the following command:
