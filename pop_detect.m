%Detect microsaccades from the EEG channel using a previously calculated
%RMS. Define the threshold for detection of local peaks and subsequently
%plot a histogram showing peak rate/number of detected peaks.
%
%Usage:
%>>[EEGOUT] = pop_detect(EEG,'key1',value,'key2',value...)
%
%Inputs:
% EEG           - EEGLAB data structure
% eyechans      - vector of eye channel indices. (default = 65:68)
% dataset       - Number of the dataset which contains the rEOG RMS to be 
%                 used to calculate the threshold. Default = current.
% thresh        - The multiplier for the RMS, which will determine the
%                 threshold for detection of local peaks in the data.
%                 Default = 3.
% window        - [mintime maxtime] (ms) e.g.[-500 700]. Default = whole
%                 epoch.
% addsacs       - 1 = add markers at the locations of detected peaks
%                 0 = don't add markers (useful when you only want to plot
%                 detected peaks)
% normRate      - 1 = Get the peaks per sec rate
%                 0 = Get raw number of detected peaks in each bin.
% plot          - 1 = plot
%                 0 = don't plot
%
%Outputs:
% EEGOUT           - EEGLAB data structure with additional rEOG channel
%
% Authors:
%   Matt Craddock (University of Leipzig,) Jasna Martinovic (University of
%   Aberdeen), 2013.

function [EEGOUT com] = pop_detect(EEG,varargin)

    com = '';
    if nargin < 1
        help pop_detect;
        return;
    end
    
    if isempty(EEG.data)
        error('Cannot process empty dataset');
    end
    
    EEGOUT = EEG;
    if nargin <3
        drawnow;
        uigeom = {[1 0.5] [1 0.5] [1 0.5] [1 0.5] [1 1 1]};
        uilist = {{'Style' 'text' 'String' 'Eye channel indices (default = 65:68):'} ...
                  {'Style' 'edit' 'String' '' 'Tag' 'eyechans'} ...
                  {'Style' 'text' 'String' 'Reference REOGrms dataset (default = current):'} ...
                  {'Style' 'edit' 'String' '' 'Tag' 'dataset'}...
                  {'Style' 'text' 'String' 'RMS threshold (default = 3):'}...
                  {'Style' 'edit' 'String' '' 'Tag' 'thresh'}...
                  {'Style' 'text' 'String' 'Time window (milliseconds; default = whole epoch):'}...
                  {'Style' 'edit' 'String' '' 'Tag' 'window'}...
                  {'Style' 'checkbox','value',0,'string','Add saccades to event channel','Tag','addsacs'}...
                  {'Style' 'checkbox','value',1,'string','Normalized saccade rate?','Tag','normRate'}...
                  {'Style' 'checkbox','value',1,'string','Draw plot?','Tag','plot'}...
                  } ;             
            
        result = inputgui(uigeom, uilist, 'pophelp(''pop_detect'')', ' detecting microsaccades -- pop_detect()');
        
        if isempty(result), return; end
        
        args = {};
        if ~isempty(result{1})
            args = [args {'eyechans'} {str2num(result{1})}];
        else
            args = [args {'eyechans'} {[65 66 67 68]} ];
        end
        if ~isempty(result{2})
            args = [args {'dataset'} {str2num(result{2})}];
        else
            args = [args {'dataset'} evalin('base','CURRENTSET')];
        end
        if ~isempty(result{3})
            args = [args {'thresh'} {str2num(result{3})}];
        else
            args = [args {'thresh'} {[3]}];
        end
        if ~isempty(result{4})
            args = [args {'window'} {str2num(result{4})}];
        else
            args = [args {'window'} {[EEG.times(1) EEG.times(end)]}];
        end
        args = [args {'addsacs'} {(result{5})}];
        args = [args {'normRate'} {(result{6})}];
        args = [args {'plot'} {(result{7})}];
    else
        %args = varargin;
        p = inputParser;
        p.addRequired('EEG');
        p.addParamValue('eyechans',[65:68],@isvector);
        p.addParamValue('window',[EEG.times(1) EEG.times(end)],@checkwin);
        p.addParamValue('thresh',3,@checkthresh);
        %p.addParamValue('addsacs',1,@checksacs);
        p.addParamValue('addsacs',1);
        %p.addParamValue('normRate',1,@checknorm);
        p.addParamValue('normRate',1);
%         p.addParamValue('plot',1,@checkplot);        
        p.addParamValue('plot',1);
        p.addParamValue('dataset',[evalin('base','CURRENTSET')],@checkdata);
        p.parse(EEG,varargin{:});
        args = p.Results;
        args = rmfield(args,'EEG');
    end
    
    %args = struct(args{:});
    
    EEGOUT = detect(EEG,args);   
    
    % History string
    com = sprintf('%s = pop_detect(%s', inputname(1), inputname(1));
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
    if length(x)~=2 | ~isvector(x)
        error('Window parameter must be a vector of form [start end] e.g. [-500 700]');
    else
        check = true;
    end
end

function check = checkfilt(x)
    check = false;
    if ~isvector(x) | x>2
        error('Filter type should be [1] (matched) or [2] (butterworth).');
    else
        check = true;
    end
end
    
function check = checkthresh(x)
    check = false;
    if ~isvector(x) | length(x)>1
        error('Threshold must be a single digit vector e.g. 3');
    else
        check = true;
    end
end

function check = checkdata(x)
    check = false;
    if ~isvector(x) | length(x)>1
        error('dataset must be a single digit vector e.g. 3');
    else
        check = true;
    end
end
