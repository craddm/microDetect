% eegplugin_micro
% Detect and correct for microsaccades using eye channels without
% concurrently recorded eye-tracking data. The use of four eye-channel
% montages is recommended; do not use bipolarized eye-channels (i.e.
% VEOG/HEOG).
%
% Authors:
% Matt Craddock, University of Leipzig; Jasna Martinovic, University of
% Aberdeen

function eegplugin_micro (fig, trystrs, catchstrs);

% add folder to path
    vers = 'microDetect';
    % -----------------------
    if ~exist('pop_rEOG')
        p = which('eegplugin_micro');
        p = p(1:findstr(p,'eegplugin_micro.m')-1);
        addpath([p vers]);
    end

%create menu
toolsmenu = findobj(fig,'tag','tools');

% tag can be 
    % 'import data'  -> File > import data menu
    % 'import epoch' -> File > import epoch menu
    % 'import event' -> File > import event menu
    % 'export'       -> File > export
    % 'tools'        -> tools menu
    % 'plot'         -> plot menu
submenu = uimenu(toolsmenu,'label','Microsaccade correction','Separator','on');

%menu callbacks
%-------------- 

comrEOG = [trystrs.no_check '[EEG LASTCOM] = pop_rEOG(EEG);' catchstrs.store_and_hist];
comDetect = [trystrs.no_check '[EEG LASTCOM] = pop_detect(EEG);' catchstrs.store_and_hist];
comsaccICA = [trystrs.no_check '[EEG LASTCOM] = pop_saccICA(EEG);' catchstrs.new_and_hist];
comCorrs = [trystrs.no_check '[LASTCOM] = pop_eyeCorrs(EEG);' catchstrs.store_and_hist];
comPlotMS = [trystrs.no_check '[LASTCOM] = pop_plotMicros(EEG);' catchstrs.store_and_hist];

%create menus
%------------

uimenu(submenu,'Label','Calculate rEOG','CallBack',comrEOG,'Separator','on');
uimenu(submenu,'Label','Detect microsaccades','CallBack',comDetect);
uimenu(submenu,'Label','Run ICA for detection','CallBack',comsaccICA);
uimenu(submenu,'Label','Plot ICA component correlations with eye channels','CallBack',comCorrs);
uimenu(submenu,'Label','Plot detected microsaccades','CallBack',comPlotMS);

%to add
%------
%see indiv functions, but overall:
%allow user to add reference RMS to datasets
%allow user to run functions on multiple datasets