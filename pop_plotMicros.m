%Plot detected eye movements. Must be run after microsaccade detection.
%
%Usage:
%>>pop_plotMicros(EEG,'key1',value,'key2',value...);
%
%Inputs:
% EEG           - EEG data structure
% normRate      - 1 = Plot peaks per second/saccade rate
%                 0 = Plot saccade count per bin
% ---to be implemented
%   Allow (optional) labelling of axes
%Authors:
%Matt Craddock, 2013

function com = pop_plotMicros(EEG,varargin);
    com = '';
    if nargin < 1
        help pop_detect;
        return;
    end
    
    if isempty(EEG.data)
        error('Cannot process empty dataset');
    end
    if ~isfield(EEG,'microS')
        error('Run microsaccade detection first!');
    end
    
    if nargin < 3
        drawnow;
        uigeom = { [1]};
        uilist = {{'Style' 'checkbox','value',1,'string','Normalized saccade rate?','Tag','normRate'}} ;             
            
        result = inputgui(uigeom, uilist, 'pophelp(''pop_plotMicros'')', ' plotting microsaccades -- pop_plotMicros()');
        args = {};
        args = [args {'normRate'} {(result{1})}];
        args = struct(args{:});
    else
        p = inputParser;
        p.addParamValue('normRate',1);
        p.parse(varargin{:})
        args = p.Results;
    end
    
    plotMicros(EEG,args);
    
    % History string
    com = sprintf('pop_plotMicros(%s', inputname(1));
    for c = fieldnames(args)'
        if ischar(args.(c{:}))
            com = [com sprintf(', ''%s'', ''%s''', c{:}, args.(c{:}))];
        else
            com = [com sprintf(', ''%s'', %s', c{:}, mat2str(args.(c{:})))];
        end
    end
    com = [com ');'];

end