%Creates the radial electrooculogram (rEOG) used to define the threshold
%for detection of miniature eye movements from EEG eye channels. Returns
%both the rEOG and the RMS of the rEOG. 
%
%Usage:
%>>[EEGOUT] = pop_rEOG(EEG,'key1',value,'key2',value...)
%
%Inputs:
% EEG           - EEGLAB data structure
% eyechans      - vector of eye channel indices (default = 65:68)
% window        - [mintime maxtime] (ms) e.g.[-500 700] default = whole
%                    epoch
% filt          - Filtering type to use:
%                  1 - matched filter. Requires filtSRP.m: 
%                        (http://hcnl.huji.ac.il/Leon/Lab/tools/filtSRP.m)
%                  2 - Butterworth filter, 6th order, bandpass from 30-100
%                        Hz (requires Signal Processing Toolbox)
%                  3 - First derivative.
% method        - Determine the RMS of rEOG for subsequent use with a fixed
%                 threshold, or the median-based standard deviation and 
%                 adaptively determine a thresholding constant.
%                  1 - fixed (determine RMS only)
%                  2 - adaptive (threshold + median-based stdev)
%
%Outputs:
% EEGOUT           - EEGLAB data structure with additional rEOG channel
%
% Authors:
%   Matt Craddock (University of Leipzig), Jasna Martinovic (University of
%   Aberdeen), 2013.

function [EEG com] = pop_rEOG(EEG,varargin)

    com = '';
    if nargin < 1
        help pop_rEOG;
        return;
    end
    if isempty(EEG.data)
        error('Cannot process empty dataset');
    end
    
    if nargin <3
        drawnow;
        uigeom = {[1 0.75] [1 0.75] [1 0.75] [1 0.75]};
        uilist = {{'Style' 'text' 'String' 'Eye channel indices (default = 65:68):'} ...
            {'Style' 'edit' 'String' '' 'Tag' 'eyechans'} ...
            {'Style' 'text' 'String' 'Time window (milliseconds; default = whole epoch):'} ...
            {'Style' 'edit' 'String' '' 'Tag' 'window'} ...
            {'Style' 'text' 'String' 'Filter type (default = matched template):'}...
            {'Style' 'popupmenu' 'String', 'Matched template|Butterworth|1st derivative' 'Tag' 'filt'}...
            {'Style' 'text' 'String' 'Threshold method (default = fixed):'}...
            {'Style' 'popupmenu' 'String', 'fixed|adaptive' 'Tag' 'method'}...
            };
        
        result = inputgui(uigeom, uilist, 'pophelp(''pop_rEOG'')', ' creating rEOG channel -- pop_rEOG()');
        if isempty(result), return; end
        
        args = {};
        if ~isempty(result{1})
            args = [args {'eyechans'} {str2num(result{1})}];
        else
            args = [args {'eyechans'} {[65 66 67 68]} ];
        end
        if ~isempty(result{2})
            args = [args {'window'} {str2num(result{2})}];
        else
            args = [args {'window'} {[EEG.times(1) EEG.times(end)]}];
        end
        if ~isempty(result{3})
            args = [args {'filt'} result{3}];
        else
            args = [args {'filt'} {1}];
        end
        if ~isempty(result{4})
            args = [args {'method'} result{4}];
        else
            args = [args {'method'} {1}];
        end
        args = struct(args{:});
    else
        p = inputParser;
        p.addParamValue('eyechans',[65:68],@isvector);
        p.addParamValue('window',[EEG.times(1) EEG.times(end)],@checkwin);
        p.addParamValue('filt',1,@checkfilt);
        p.addParamValue('method','fixed');
        p.parse(varargin{:});
        args = p.Results;
    end
        
    %create rEOG
    EEG = calcrEOG(EEG,args);
    
    % History string
    com = sprintf('%s = pop_rEOG(%s', inputname(1), inputname(1));
    for c = fieldnames(args)'
        if ischar(args.(c{:}))
            com = [com sprintf(', ''%s'', ''%s''', c{:}, args.(c{:}))];
        else
            com = [com sprintf(', ''%s'', %s', c{:}, mat2str(args.(c{:})))];
        end
    end
    com = [com ');'];
end
        
function check = checkwin(x)
    check = false;
    if length(x)~=2
        error('Window parameter must be a vector of form [start end] e.g. [-500 700]');
    elseif ~isvector(x)
        error('Window parameter must be a vector of form [start end] e.g. [-500 700]');
    else
        check = true;
    end
end

function check = checkfilt(x)
check = false;
    if ~isvector(x)
        error('Filter type should be [1] (matched), [2] (butterworth), or [3] (1st derivative).');
    elseif x>3
        error('Filter type should be [1] (matched), [2] (butterworth) or [3] (1st derivative).');
    else
        check = true;
    end
end
    
    