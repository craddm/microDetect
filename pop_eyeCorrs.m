% Function for checking correlations of ICA components with REOG/other chans
% just basic test version at the moment, only usable with eye chans 65:68

% Matt Craddock, 2013

function [EEGOUT com] = pop_eyeCorrs(EEG,varargin)
    com = '';
    if nargin <1 
        help pop_eyeCorrs;
        return;
    end
   
    if isempty(EEG.data)
        error('Cannot process empty dataset');
    end
    
    EEGOUT = EEG;
    
    EEGOUT = eyeCorrs(EEG);
    % History string
    com = sprintf('%s = pop_eyeCorrs(%s', inputname(1), inputname(1));
    for c = fieldnames(args)'
        if ischar(args.(c{:}))
            com = [com sprintf(', ''%s'', ''%s''', c{:}, args.(c{:}))];
        else
            com = [com sprintf(', ''%s'', %s', c{:}, mat2str(args.(c{:})))];
        end
    end
    com = [com ');'];
end