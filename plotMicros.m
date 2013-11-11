%Low-level function for plotting detected eye movements. Please use
%pop_plotMicros().
%
%
%Matt Craddock, 2013

function plotMicros(EEG,args);

   switch args.normRate
       case 1
           bar(EEG.microS.binEdges,EEG.microS.sacRate,'histc');
           ymax = 5*round(max(EEG.microS.sacRate)/5);
           axis ([EEG.microS.binEdges(3) EEG.microS.binEdges(end-1) 0 ymax]);
       case 0
           bar(EEG.microS.binEdges,EEG.microS.binnedSacs,'histc');
           ymax = 10*round(max(EEG.microS.binnedSacs)/10);
           axis ([EEG.microS.binEdges(3) EEG.microS.binEdges(end-1) 0 ymax]);
   end  
    
end