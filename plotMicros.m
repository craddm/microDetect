%Plot detected eye movements.
%Matt Craddock, 2013

function plotMicros(EEG,args);

   switch args.normRate
       case 1
           bar(EEG.microS.binEdges,EEG.microS.sacRate,'histc');
           axis tight;
       case 0
           bar(EEG.microS.binEdges,EEG.microS.binnedSacs,'histc');
           axis tight;
   end  
    
end