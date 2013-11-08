%Low-level rEOG calculation function. Use pop_calcrEOG()
%
%Matt Craddock, 2013
function EEG = calcrEOG(EEG,args)

times = find(EEG.times >= args.window(1) & EEG.times <=args.window(2));

%check if there's already an REOG for this dataset, if so back it up
if ~isfield(EEG,'microS')
    EEG.microS = [];
end

if isfield(EEG.microS,'REOGall')
    EEG.microS.REOGallold = EEG.microS.REOGall;
end

if isfield(EEG.microS,'baseRMS')
    EEG.microS = rmfield(EEG.microS,'baseRMS');
    EEG.microS = rmfield(EEG.microS,'baseRMSfilt');
end

EEG.microS.REOGall=zeros(length(times),EEG.trials);

% find Pz
PzIndex = 0
for iPzIndex = 1:length(EEG.chanlocs)
    if strcmpi(EEG.chanlocs(iPzIndex).labels,'Pz')
        PzIndex = iPzIndex;
    end
end
if PzIndex == 0
    PzIndex = 31;
end

for trials=1:EEG.trials
    eyeChans = [];
    for iEyeChans = 1:length(args.eyechans)
        eyeChans(iEyeChans,:) = squeeze(EEG.data(args.eyechans(iEyeChans),times,trials));
    end
    Pz=squeeze(EEG.data(PzIndex,times,trials));
    EEG.microS.REOGall(:,trials) = mean(eyeChans)-Pz;
end

switch args.filt
    case 1
        EEG.microS.REOGf=filtSRP(EEG.microS.REOGall(:),EEG.srate);
        numedge = 84/(1024/EEG.srate);
        EEG.microS.REOGfilt = 'matched';
        disp('Using Matched Filter.')
    case 2
        locutoff = 30/(EEG.srate/2);
        hicutoff = 100/(EEG.srate/2);
        [b,a] = butter(6,[locutoff hicutoff]);
        EEG.microS.REOGf=filtfilt(b,a,EEG.microS.REOGall(:));
        numedge = length(a);
        EEG.microS.REOGfilt = 'butter';
        disp('Using Butterworth Filter.')
    case 3
        EEG.microS.REOGf = diff(EEG.microS.REOGall);
        EEG.microS.REOGf = EEG.microS.REOGf(:);
        EEG.microS.REOGfilt = '1stDeriv';
        disp('Using first derivative.')
        numedge = 0;
    otherwise
        EEG.microS.REOGf=filtSRP(EEG.microS.REOGall(:),EEG.srate);
        numedge = 84/(1024/EEG.srate);
end

EEG.microS.REOGFne = EEG.microS.REOGf(round(numedge/2)+1:length(EEG.microS.REOGf)-round(numedge/2),:);  % remove edges
EEG.microS.REOGrms = sqrt(mean(EEG.microS.REOGFne.^2));