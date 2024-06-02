addpath('\\fileu\users$\oyakobi\My Documents\eeglab2019_1');
if ~exist('EEG','var');
    eeglab;
end;
dataPath = 'D:\users\EEG_DATA\preprocessed\tasks\';
cd 'D:\users\EEG_DATA\preprocessed\tasks\';

%BPS split - IRRELEVANT HERE DUE TO NO CORRELATION OF BPS AND GNG ERPs
Low_BPS= {'319678', '320830', '321538', '322990', '337285', '337672', '349117', '349429', '349681', '351427', '353701', '360400', '360943', '361117', '362713', '367723', '368773', '371311', '381991', '382132', '382144', '384187', '384355', '384379', '385909', '386686', '389143'};
High_BPS= {'321880', '331282', '337270', '338920', '345286', '347995', '348109', '349600', '352633', '357940', '361156', '366298', '367219', '367747', '368125', '368740', '373276', '375025', '375397', '381856', '381931', '381946', '382024', '382174', '384058', '384658', '384895', '387244', '387337', '387343', '388048'};
%GNG Boredom split
Low_BPS= {'319678_GNG_stim.erp', '337270_GNG_stim.erp', '337285_GNG_stim.erp', '338920_GNG_stim.erp', '345286_GNG_stim.erp', '348109_GNG_stim.erp', '349429_GNG_stim.erp', '349600_GNG_stim.erp', '349681_GNG_stim.erp', '357940_GNG_stim.erp', '360400_GNG_stim.erp', '361117_GNG_stim.erp', '362713_GNG_stim.erp', '366298_GNG_stim.erp', '367747_GNG_stim.erp', '368014_GNG_stim.erp', '368125_GNG_stim.erp', '368446_GNG_stim.erp', '368773_GNG_stim.erp', '371311_GNG_stim.erp', '373276_GNG_stim.erp', '375025_GNG_stim.erp', '381856_GNG_stim.erp', '381931_GNG_stim.erp', '382024_GNG_stim.erp', '382144_GNG_stim.erp', '382174_GNG_stim.erp', '384355_GNG_stim.erp', '384379_GNG_stim.erp', '387244_GNG_stim.erp', '388048_GNG_stim.erp', '392212_GNG_stim.erp', '392542_GNG_stim.erp', '392686_GNG_stim.erp', '393490_GNG_stim.erp', '393880_GNG_stim.erp', '394084_GNG_stim.erp', '394792_GNG_stim.erp', '397576_GNG_stim.erp'};
High_BPS= {'320830_GNG_stim.erp', '321538_GNG_stim.erp', '321880_GNG_stim.erp', '322990_GNG_stim.erp', '331282_GNG_stim.erp', '337672_GNG_stim.erp', '347995_GNG_stim.erp', '349117_GNG_stim.erp', '351427_GNG_stim.erp', '352633_GNG_stim.erp', '353689_GNG_stim.erp', '353701_GNG_stim.erp', '360943_GNG_stim.erp', '361156_GNG_stim.erp', '365695_GNG_stim.erp', '367219_GNG_stim.erp', '367723_GNG_stim.erp', '368740_GNG_stim.erp', '370720_GNG_stim.erp', '375397_GNG_stim.erp', '381946_GNG_stim.erp', '381991_GNG_stim.erp', '382132_GNG_stim.erp', '384058_GNG_stim.erp', '384187_GNG_stim.erp', '384577_GNG_stim.erp', '384658_GNG_stim.erp', '384895_GNG_stim.erp', '385909_GNG_stim.erp', '386686_GNG_stim.erp', '387337_GNG_stim.erp', '387343_GNG_stim.erp', '389143_GNG_stim.erp', '391963_GNG_stim.erp', '392458_GNG_stim.erp', '392488_GNG_stim.erp', '392554_GNG_stim.erp', '393961_GNG_stim.erp', '395041_GNG_stim.erp'};

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
ERP.erpname='GNG stim ERPs (Low-BPS)';
ERP_low=ERP;
CURRENTERP = CURRENTERP + 1;
ALLERP(CURRENTERP) = ERP;

ERP = pop_gaverager( ALLERP , 'Erpsets',length(Low_BPS)+1:length(Low_BPS)+length(High_BPS), 'ExcludeNullBin', 'on', 'SEM', 'on' );
ERP.erpname='GNG stim ERPs (High-BPS)';
CURRENTERP = CURRENTERP + 1;
ALLERP(CURRENTERP) = ERP;

ERP.nbin=4;
ERP.bindata(:,:,4)=ERP_low.bindata(:,:,2);
ERP.binerror(:,:,4)=ERP_low.binerror(:,:,2);
ERP.bindescr(2)={'High BPS go-P3'};
ERP.bindescr(4)={'Low BPS go-P3'};
ERP.ntrials.accepted(4)=0;
ERP.ntrials.rejected(4)=0;
ERP.ntrials.invalid(4)=0;
ERP.ntrials.arflags(4,:)=ERP.ntrials.arflags(2,:);
ALLERP(CURRENTERP) = ERP;
ERP = pop_binoperator( ERP, {  'nb1 = b1 label irrelevant',  'nb2 = b2 label High BPS nogo-P3',  'nb3 = b3 label irrelevant','nb4 = b4 label Low BPS nogo-P3','nb5 = b1-b4 label High minus Low BPS'});
ALLERP(CURRENTERP) = ERP;

erplab redraw;
eeglab redraw;

%PLOTS
ERP = pop_scalplot( ERP,  [ 5],  450 , 'Blc', 'pre', 'Colorbar', 'on', 'Colormap', 'jet', 'FontName', 'Courier New', 'FontSize',  10, 'Maplimit',...
 'maxmin', 'Mapstyle', 'both', 'Maptype', '2D', 'Mapview', '+X', 'Plotrad',  0.55, 'Value', 'insta' );
ERP = pop_ploterps( ERP, [ 2 4],  1:35 , 'AutoYlim', 'on', 'Axsize', [ 0.05 0.08], 'Blc', 'pre', 'Box', [ 6 6], 'ChLabel', 'on', 'FontSizeChan',...
  18, 'FontSizeLeg',  19, 'FontSizeTicks',  19, 'LegPos', 'bottom', 'Linespec', {'k-' , 'r-' }, 'LineWidth',  1, 'Maximize', 'on',...
 'Position', [ 53 6.88235 106.857 32], 'Style', 'Classic', 'Tag', 'ERP_figure', 'Transparency',  0, 'xscale', [ -199.0 796.0   -100 0:200:600 ],...
 'YDir', 'normal' );
erplab redraw;
