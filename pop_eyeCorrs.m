% Plot the correlation of each ICA component and the rEOG, VEOG, and HEOG
% eye channels. Enter non-bipolarized eye channels as used during calculation of rEOG
% and which should also have been used for the calculation of the ICA. Note
% that the eye channels should be entered in as [VEOG1 VEOG2 HEOG1 HEOG2]
% (e.g. [65 66 67 68]/[65:68] on a Biosemi 64 system). 
%
% The resulting bar plots label and highlight in red the 3 highest
% correlated components. The topography of the highest correlated component
% for each of rEOG, HEOG, and VEOG is also shown.
%
%Usage:
%>>pop_eyeCorrs(EEG,'key1',value...)
%
%Inputs:
% EEG           - EEG data structure
% eyechans      - vector of eye channel indices (default = 65:68)
%
% Matt Craddock, 2013

function [com] = pop_eyeCorrs(EEG,varargin)
    com = '';
    if nargin <1 
        help pop_eyeCorrs;
        return;
    end
    
    if isempty(EEG.data)
        error('Cannot process empty dataset');
    end
    
    if nargin <3
        drawnow;
        uigeom = { [1 0.75]};
        uilist = {{'Style' 'text','string','Eye channel indices (default = 65:68):'}...
            {'Style' 'edit' 'String' '' 'Tag' 'eyechans'}};             
            
        result = inputgui(uigeom, uilist, 'pophelp(''pop_eyeCorrs'')', ' plotting correlations -- pop_eyeCorrs()');
        args = {};
        if ~isempty(result{1})
            args = [args {'eyechans'} {str2num(result{1})}];
        else
            args = [args {'eyechans'} {[65 66 67 68]} ];
        end
        args = struct(args{:});
    else    
    p = inputParser;
    p.addParamValue('eyechans',[65:68],@isvector);
    p.parse(varargin{:});
    args = p.Results;
    end
    
    eyeCorrs(EEG,args);
    % History string
    com = sprintf('pop_eyeCorrs(%s', inputname(1), inputname(1));
    for c = fieldnames(args)'
        if ischar(args.(c{:}))
            com = [com sprintf(', ''%s'', ''%s''', c{:}, args.(c{:}))];
        else
            com = [com sprintf(', ''%s'', %s', c{:}, mat2str(args.(c{:})))];
        end
    end
    com = [com ');'];
end