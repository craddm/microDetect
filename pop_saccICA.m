%Combines and reorganizes multiple datasets in one of several ways and 
%runs ICA as required.
%
%Matt Craddock, 2013

function [EEGOUT com] = pop_saccICA(EEG,varargin)
    
    com = '';
    if nargin < 1
        help pop_saccICA;
        return;
    end
    
    if isempty(EEG.data)
        error('Cannot process empty dataset');
    end
    
    EEGOUT = EEG;
    
    if nargin <3
        drawnow;
        uigeom = {[1 0.75] [1 0.75]}
        uilist = {{'Style' 'text' 'String' 'Datasets (default = current):'} ...
                  {'Style' 'edit' 'String' '' 'Tag' 'datasets'} ...
                  {'Style' 'popupmenu' 'String' 'sacconly|addsaccs' 'Tag' 'method'} ...
                  };
            
        result = inputgui(uigeom, uilist, 'pophelp(''pop_saccICA'')', ' running ICA -- pop_saccICA()');
        if isempty(result), return; end

        args = {};
        if ~isempty(result{1})
            args = [args {'datasets'} {str2num(result{1})}];
        else
            args = [args {'datasets'} {evalin('base','CURRENTSET')} ];
        end
        args = [args {'method'} result{2}];
    else
        args = varargin;
    end
    args = struct(args{:});
    if length(args.datasets) >1
        %to add - check all datasets actually have saccades
%         for iSaccCheck = 1:length(args.datasets)
%             if sum(unique((strcmp({EEG.event(:).type},'sac')))) == 1
%                 (evalin('base','ALLEEG'),args.datasets(iSaccCheck));
            EEGMERGED = pop_mergeset(evalin('base','ALLEEG'),args.datasets);
    else
        EEGMERGED = EEG;
    end
    EEGOUT = saccICA(EEGMERGED);
    % History string
    com = sprintf('%s = pop_saccICA(%s', inputname(1), inputname(1));
    for c = fieldnames(args)'
        if ischar(args.(c{:}))
            com = [com sprintf(', ''%s'', ''%s''', c{:}, args.(c{:}))];
        else
            com = [com sprintf(', ''%s'', %s', c{:}, mat2str(args.(c{:})))];
        end
    end
    com = [com ');'];