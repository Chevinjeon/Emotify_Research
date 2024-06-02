addpath('\\fileu\users$\oyakobi\My Documents\eeglab2019_1');
if ~exist('EEG','var');
    eeglab;
end;
dataPath = 'D:\users\EEG_DATA\preprocessed\tasks\';
cd 'D:\users\EEG_DATA\preprocessed\tasks\';

%BPS split
Low_BPS= {'319678_BART.erp', '320830_BART.erp', '321538_BART.erp', '322990_BART.erp', '337285_BART.erp', '337672_BART.erp', '349117_BART.erp', '349429_BART.erp', '349681_BART.erp', '351427_BART.erp', '353689_BART.erp', '353701_BART.erp', '360400_BART.erp', '360943_BART.erp', '361117_BART.erp', '362713_BART.erp', '365695_BART.erp', '366298_BART.erp', '367723_BART.erp', '368125_BART.erp', '368773_BART.erp', '369421_BART.erp', '370720_BART.erp', '371311_BART.erp', '373345_BART.erp', '381931_BART.erp', '381991_BART.erp', '382024_BART.erp', '382132_BART.erp', '382144_BART.erp', '384187_BART.erp', '384355_BART.erp', '384379_BART.erp', '384577_BART.erp', '386686_BART.erp', '389143_BART.erp', '391963_BART.erp', '392212_BART.erp', '392458_BART.erp', '392488_BART.erp', '392686_BART.erp', '393880_BART.erp', '395941_BART.erp'}
High_BPS= {'321880_BART.erp', '331282_BART.erp', '337270_BART.erp', '338920_BART.erp', '345286_BART.erp', '347995_BART.erp', '348109_BART.erp', '349600_BART.erp', '352633_BART.erp', '357940_BART.erp', '361156_BART.erp', '367219_BART.erp', '367747_BART.erp', '368014_BART.erp', '368446_BART.erp', '368740_BART.erp', '369439_BART.erp', '373276_BART.erp', '375025_BART.erp', '375397_BART.erp', '381856_BART.erp', '381946_BART.erp', '382174_BART.erp', '384058_BART.erp', '384658_BART.erp', '384895_BART.erp', '385897_BART.erp', '385909_BART.erp', '387244_BART.erp', '387337_BART.erp', '387343_BART.erp', '388048_BART.erp', '392542_BART.erp', '392554_BART.erp', '393490_BART.erp', '393961_BART.erp', '394084_BART.erp', '394792_BART.erp', '395041_BART.erp', '397576_BART.erp'};
%BART Boredom split


for i=1:length(Low_BPS);
    Low_BPS(i)=strcat(Low_BPS(i),'');
end; 
for i=1:length(High_BPS);
    High_BPS(i)=strcat(High_BPS(i),'');
end; 
[ERP ALLERP] = pop_loaderp( 'filename',Low_BPS , 'filepath', dataPath,'multiload','on' );
[ERP ALLERP] = pop_loaderp( 'filename',High_BPS , 'filepath', dataPath,'multiload','on' );
erplab redraw;
eeglab redraw;
ERP = pop_gaverager( ALLERP , 'Erpsets',1:length(Low_BPS), 'ExcludeNullBin', 'on', 'SEM', 'on' );
ERP.erpname='BART ERPs (Low-BPS)';
ERP_low=ERP;
CURRENTERP = CURRENTERP + 1;
ALLERP(CURRENTERP) = ERP;

ERP = pop_gaverager( ALLERP , 'Erpsets',length(Low_BPS)+1:length(Low_BPS)+length(High_BPS), 'ExcludeNullBin', 'on', 'SEM', 'on' );
ERP.erpname='BART ERPs (High-BPS)';
CURRENTERP = CURRENTERP + 1;
ALLERP(CURRENTERP) = ERP;

ERP.bindata(:,:,4)=ERP_low.bindata(:,:,1); % new b4 is loss feedback for low BP
ERP.binerror(:,:,4)=ERP_low.binerror(:,:,1);
ERP.bindata(:,:,5)=ERP_low.bindata(:,:,2); % new b5 is win feedback for low BP
ERP.binerror(:,:,5)=ERP_low.binerror(:,:,2);
ERP.bindata(:,:,6)=ERP_low.bindata(:,:,3); % new b6 is diff wave for low BP
ERP.binerror(:,:,6)=ERP_low.binerror(:,:,3);
ERP.bindescr(1)={'Loss - high BP'};
ERP.bindescr(2)={'Win - high BP'};
ERP.bindescr(3)={'Difference wave - high BP'};
ERP.bindescr(4)={'Loss - low BP'};
ERP.bindescr(5)={'Win - low BP'};
ERP.bindescr(6)={'Difference wave - low BP'};
ERP.ntrials.accepted(4)=0;
ERP.ntrials.rejected(4)=0;
ERP.ntrials.invalid(4)=0;
ERP.ntrials.arflags(4,:)=ERP.ntrials.arflags(3,:);
ALLERP(CURRENTERP) = ERP;
ERP = pop_binoperator( ERP, {'nb1 = b1 label Loss high BP',  'nb2 = b2 label Win Feedback',  'nb3 = b3 label High BPS FRN','nb4 = b4 label Low BPS FRN','nb5 = b3-b4 label High minus Low BPS'});
ALLERP(CURRENTERP) = ERP;

erplab redraw;
eeglab redraw;

%plots
%first: two difference maps for P3
ERP = pop_scalplot( ERP, [ 3 6],  360 , 'Blc', 'pre', 'Colorbar', 'on', 'Colormap', 'jet', 'FontName', 'Courier New', 'FontSize',  10, 'Legend',...
 'bn-la', 'Maplimit', [ -3.0 5.0   ], 'Mapstyle', 'both', 'Maptype', '2D', 'Mapview', '+X', 'Plotrad',  0.55, 'Position', [ 11 26 1920 963],...
 'Value', 'insta' );

ERP = pop_scalplot( ERP, 5,  360 , 'Blc', 'pre', 'Colorbar', 'on', 'Colormap', 'jet', 'FontName', 'Courier New', 'FontSize',  10, 'Legend',...
 'bn-la', 'Mapstyle', 'both', 'Maptype', '2D', 'Mapview', '+X', 'Plotrad',  0.55, 'Position', [ 11 26 1920 963],...
 'Value', 'insta' );

