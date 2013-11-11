% Low-level function for plotting ICA/eye channel correlations. Please call
% pop_eyeCorrs.

% Matt Craddock, 2013

% to add
% ------
% error checking for presence of eye channels/bipolarized eye channels.
% allow flexible correlation thresholds instead of taking top three
% allow plotting of more than just the highest correlation IC

function eyeCorrs(EEG,args)

numComps = length(EEG.icaweights);
ICacts = eeg_getdatact(EEG,'component',1:numComps);
ICacts = ICacts(:,:)';

eyeChannels = zeros(length(ICacts),3);
eyeChannels(:,1) = mean(EEG.data(65:68,:),1)'; %create an rEOG by averaging across all 4 eye chans
eyeChannels(:,2) = (EEG.data(65,:)-EEG.data(66,:))';
eyeChannels(:,3) = (EEG.data(67,:)-EEG.data(68,:))';
titles = {'REOG';'VEOG';'HEOG'};

figure
for iCorrs = 1:3
    eyeICcorrs = abs(corr(ICacts,eyeChannels(:,iCorrs)));
    [corrSort,index] = sort(eyeICcorrs,'descend');
    barColourMap(1:numComps,1:3) = repmat([0 0 1],[numComps 1]);
    barColourMap(index(1:3),1:3) = repmat([1 0 0],[3 1]);
    handle = subplot(2,3,iCorrs);
    for iComps = 1:numComps
        h(iComps) = bar(iComps,eyeICcorrs(iComps),'BarWidth',0.9);
        set(h(iComps),'FaceColor',barColourMap(iComps,:))
        if ismember(iComps,index(1:3))
            text(double(iComps),double(eyeICcorrs(iComps)),num2str(iComps));
        end
        hold on
    end
    
    set(gca, 'XTickMode', 'Auto');
    axis([1 numComps 0 1])
    
    title(handle,titles{iCorrs})
    subplot(2,3,iCorrs+3);
    pop_topoplot(EEG,0,index(1),'',0,'colorbar','off');
end

end