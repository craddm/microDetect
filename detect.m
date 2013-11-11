%Low-level function for microsaccade detection, please use pop_detect()
%
%Matt Craddock, 2013
function EEG = detect(EEG,args)

binsize = 20;
sacs_new = [];

times = find(EEG.times >= args.window(1) & EEG.times <=args.window(2));

if ~isfield(EEG,'microS')
    EEG.microS = [];
end

if ~isfield(EEG.microS,'baseRMS')
    EEG.microS.baseRMS = evalin('base',['ALLEEG(' num2str(args.dataset) ').microS.REOGrms']);    %get the RMS from the specified dataset    
    EEG.microS.baseRMSfilt = evalin('base',['ALLEEG(' num2str(args.dataset) ').microS.REOGfilt']);    %check which filter method was used to derive this RMS
end

switch EEG.microS.baseRMSfilt
    case 'matched'
        disp('Matched template used for detection')
    case 'butter'
        disp('Butterworth filter used for detection')
    case '1st deriv'
        disp('First derivative used for detection')
end

% find Pz
PzIndex = 0;
for iPzIndex = 1:length(EEG.chanlocs)
    if strcmpi(EEG.chanlocs(iPzIndex).labels,'Pz')
        PzIndex = iPzIndex;
    end
end

if PzIndex == 0
    PzIndex = 31;
end

%Remove existing saccade events

% if args.addsacs == 1
     if sum(unique((strcmp({EEG.event(:).type},'sac')))) == 1
%         drawnow;
%         uigeom = {[1] [1] [1]};
%         uilist = {{'Style' 'text' 'String' 'This dataset already has recorded microsaccades.'} ...
%             {'Style' 'checkbox','value',1, 'String' 'Remove existing microsaccade triggers?','Tag','removesacs'}...
%             {'Style' 'text','String' 'Unchecking the box will return you to the menu.'}...
%          %   {'Style' 'pushbutton','String','Okay!' 'callback' 'close(gcbf);'} 
%             };
%         result = inputgui(uigeom, uilist, 'pophelp(''pop_detect'')', ' detecting microsaccades -- pop_detect()');
%         if isempty(result)
%             return;
%         elseif result{1} == 0
%             return;
%         else
            EEG = pop_selectevent(EEG,'type','sac','select','inverse','deleteevents','on');
         end        
%     end
% end
        

for trials=1:EEG.trials
    
    eyeChans = [];    
    for iEyeChans = 1:length(args.eyechans)
        eyeChans(iEyeChans,:) = squeeze(EEG.data(args.eyechans(iEyeChans),times,trials));
    end
    
    Pz = squeeze(EEG.data(PzIndex,times,trials));

    REOG = mean(eyeChans)-Pz;
    REOG = double(REOG);
    
    switch EEG.microS.baseRMSfilt
        case 'matched'
            numedge = 84/(1024/EEG.srate);
            REOGf= filtSRP(REOG',EEG.srate);
        case 'butter'
            locutoff = 30/(EEG.srate/2);
            hicutoff = 100/(EEG.srate/2);
            [b,a] = butter(6,[locutoff hicutoff]); %creates a bandpass butterworth filter of 6th order
            REOGf=filtfilt(b,a,REOG');
            numedge = length(a);
            filtDelay = grpdelay(b,a,EEG.srate/2); %get grpdelay for the filter
            minDelay = round(min(filtDelay(30:100))); %finds the minimum grpdelay in the passband (in samples) (approximately in the middle). note that butterworth filters have a non-linear phase response, thus have different delays at different frequencies.
        case '1stDeriv'
            REOGf = diff(REOG');
            numedge = 0;
    end
   
    REOGFne= REOGf(round(numedge/2)+1:length(REOGf)-round(numedge/2));  % remove edges
    mpd=round(20/(1000/EEG.srate)); %minimum peak distance - in samples, 10 is 20ms at 512Hz
    REOGfzero=[zeros(mpd+1,1); REOGFne; zeros(mpd+1,1)]; %i need to zeropad it for the mpd=10 to work
    switch EEG.microS.threshold
        case 'adaptive'
            mpd = 10;
            [pks,locs] = findpeaks(REOGfzero,'minpeakheight',EEG.microS.adaptThresh*EEG.microS.REOGstdMed,'minpeakdistance',mpd); %change REOGrms multiplier to change sensitivity.            
            %run twice to find maxmia *and* minima
            [minpks,minlocs] = findpeaks(-REOGfzero,'minpeakheight',EEG.microS.adaptThresh*EEG.microS.REOGstdMed,'minpeakdistance',mpd); %change REOGrms multiplier to change sensitivity.
            
        otherwise
            [pks,locs] = findpeaks(REOGfzero,'minpeakheight',args.thresh*EEG.microS.baseRMS,'minpeakdistance',mpd); %change REOGrms multiplier to change sensitivity.
    end
    
    locs = locs(:); %these two lines are for compatibility  - locs is a row in Matlab <2010a, but a column in later versions
    locs = locs';   %so here i'm just forcing it to be a row.
    
    switch EEG.microS.baseRMSfilt
        case 'butter'
            locs=locs-(mpd+1)+round(numedge/2)-minDelay; %now get rid of zeropad,edge removal distortion, and shift the locations back by the (approximate) delay caused by the filter
        otherwise
            locs=locs-(mpd+1)+round(numedge/2);
    end
                
    sacs_new = [sacs_new locs];       
    fullTrialLocs = times(locs);
    
     for i = 1:length(fullTrialLocs)
virtChan(1,(fullTrialLocs(i)-8):(fullTrialLocs(i)+8),1) = EEG.data(1,(fullTrialLocs(i)-8):(fullTrialLocs(i)+8),1);
end
    if args.addsacs == 1
        for iLocs = 1:length(locs)
            EEG.event(end+1).type = 'sac';
            EEG.event(end).latency = (EEG.pnts*(trials-1))+fullTrialLocs(iLocs);
            EEG.event(end).epoch = trials;               
        end
    end
end

if args.addsacs == 1
    EEG = pop_editeventvals( EEG, 'sort', { 'epoch', 0 } ); % resort fields
    EEG = eeg_checkset(EEG, 'eventconsistency');
    EEG = eeg_checkset(EEG, 'makeur');
end


    %Bin the data and plot for the participant
    %----------------------------------------

    xbin=args.window(1):binsize:args.window(2);
    
    %do the binning
    [EEG.microS.binnedSacs,EEG.microS.times]=histc(EEG.times(times(sacs_new)),xbin);
    EEG.microS.binEdges = xbin;
    EEG.microS.sacRate = EEG.microS.binnedSacs./EEG.trials.*(1000/binsize);%normalize to give mean saccade rate/s
    
    if args.plot == 1
        plotMicros(EEG,args)        
    end
end
