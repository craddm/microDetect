% Function for checking correlations of ICA components with REOG/other chans
% just basic test version at the moment, only usable with eye chans 65:68

% Matt Craddock
function EEG = eyeCorrs(EEG)
    
    numComps = length(EEG.icaweights);
    ICacts = eeg_getdatact(EEG,'component',1:numComps);
    rEOG = mean(EEG.data(65:68,:),1)'; %create an rEOG by averaging across all 4 eye chans
    VEOG = (EEG.data(65,:)-EEG.data(66,:))';%create bipolarized eye chans
    HEOG = (EEG.data(67,:)-EEG.data(68,:))';
    ICacts = ICacts(:,:)';
    figure
    REOGcorrs = abs(corr(ICacts,rEOG));
    [corrSort,index] = sort(REOGcorrs,'descend');
    barColourMap(1:numComps,1:3) = repmat([0 0 1],[numComps 1]);
    barColourMap(index(1:3),1:3) = repmat([1 0 0],[3 1]);
    handle = subplot(1,3,1);
    
    for iComps = 1:numComps
        h(iComps) = bar(iComps,REOGcorrs(iComps),'BarWidth',0.9);
        set(h(iComps),'FaceColor',barColourMap(iComps,:))
        hold on
    end  
    set(gca, 'XTickMode', 'Auto');
    axis([1 numComps 0 1])
    title(handle,'REOG')
    
    VEOGcorrs = abs(corr(ICacts,VEOG));
    HEOGcorrs = abs(corr(ICacts,HEOG));
    subplot(1,3,2),bar(HEOGcorrs),title('HEOG'),axis([1 numComps 0 1])
    subplot(1,3,3),bar(VEOGcorrs),title('VEOG'),axis([1 numComps 0 1])
    
end