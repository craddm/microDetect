%eegplugin_micro
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
comICAtran = [trystrs.no_check '[EEG LASTCOM] = pop_ICAtran(EEG);' catchstrs.store_and_hist];

%create menus
%------------

uimenu(submenu,'Label','Calculate rEOG','CallBack',comrEOG,'Separator','on');
uimenu(submenu,'Label','Detect microsaccades','CallBack',comDetect);
uimenu(submenu,'Label','Run ICA for detection','CallBack',comsaccICA);
uimenu(submenu,'Label','Transfer ICA to full dataset','CallBack',comICAtran);

%to add
%------
%see indiv functions, but overall:
%allow user to specify filtering method (filtSRP or butterworth)
%allow user to plot previously detected microsaccades without redetection
%allow user to add reference RMS to datasets
%allow user to run functions on multiple datasets