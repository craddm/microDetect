function EEG = calcrEOG(EEG,args)

times = find(EEG.times >= args.window(1) & EEG.times <=args.window(2));

if isfield(EEG,'REOGall')
    EEG.REOGallold = EEG.REOGall;
end
EEG.REOGall=zeros(length(times),EEG.trials);

% find Pz
for iPzIndex = 1:length(EEG.chanlocs)
    if strcmpi(EEG.chanlocs(iPzIndex).labels,'Pz')
        PzIndex = iPzIndex;
    end
end

for trials=1:EEG.trials
    eyeChans = [];
    for iEyeChans = 1:length(args.eyechans)
        eyeChans(iEyeChans,:) = squeeze(EEG.data(args.eyechans(iEyeChans),times,trials));
    end
%     HEOGL=squeeze(EEG.data(args.eyechans(1),times,trials));
%     HEOGR=squeeze(EEG.data(68,times,trials));
%     VEOGS=squeeze(EEG.data(65,times,trials));
%     VEOGI=squeeze(EEG.data(66,times,trials));
     Pz=squeeze(EEG.data(PzIndex,times,trials));        
     EEG.REOGall(:,trials) = mean(eyeChans)-Pz;
     %EEG.REOGall(:,trials) = (HEOGL+HEOGR+VEOGS+VEOGI)/4 - Pz;
end
numedge = 84/(1024/EEG.srate);

EEG.REOGf=filtSRP(EEG.REOGall(:),EEG.srate);
EEG.REOGFne=EEG.REOGf(numedge/2+1:length(EEG.REOGf)-numedge/2,:);  % remove edges

%calculate RMS error of REOG
EEG.REOGrms = sqrt(mean(EEG.REOGFne.^2));

clear HEOGL HEOGR VEOGS VEOGI Pz numedge

