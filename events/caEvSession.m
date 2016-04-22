function caEvSession(handles)
%Calcium events version


%% Gather data
imgTS     = handles.imgTS;
sd        = handles.sd;
caEv      = handles.caEv;
data      = handles.data;
pre       = str2double(get(handles.editPre,'string'));   % set start time for cue window, in relation to cue time
post      = str2double(get(handles.editPost,'string'));  % set end time for cue window, in relation to cue time
[ptNum, ...
 cellNum] = size(sd);
dataNum   = size(data,2);

% Retrieve fps if defined
fpsDef = exist('handles.fps','var');                    % determine if variable 'fps' is defined
if fpsDef
    fps = handles.fps;
else
    fps = 1/mean(diff(imgTS));
end

%% Data processing
% Smooth data
toSmooth = get(handles.checkSmooth,'value');
if toSmooth
    winNumStr = get(handles.editSmooth,'string');   % get string for window width for smoothing average window
    winNum    = str2double(winNumStr);              % convert string to double
    avgWin    = ones(winNum,1)/winNum;              % define moving average window
    sdSmooth  = conv2(sd,avgWin,'same');            % smooth data
else
    sdSmooth = sd;                                  % no smoothing
end


%% Find number of data points in window
% Find occurences of focus variable and determine number of data points for
% window defined by user (converting window from seconds to data points).

evIX   = find(caEv);                             % indices of calcium events
evIXn  = 1;                                      % counter index for calcium with full window (first one is probably good for the most part)
ev1IX  = evIX(evIXn);                              % index of first calcium event (from frist cell)
[ev1I,~] = ind2sub(size(caEv),ev1IX);             % row index of calcium event (index corresponds to time point in imgTS)
pre1  = imgTS(ev1I) + pre;                       % define first pre event window as an example to setup data
post1 = imgTS(ev1I) + post;                      % define first post event window as an example to setup data
binT  = mean(diff(imgTS));

% In case first event is too close to session start to have full pre event
% window, move to next event until full window exists
imgTSlbnd = imgTS(1) - (binT + 1/fps)/2;        % lowest time point recorded by calcium imaging
while pre1 < imgTSlbnd
    evIXn    = evIXn + 1;                         % increment counter
    ev1IX    = evIX(evIXn);                        % define next focused session event
    [ev1I,~] = ind2sub(size(caEv),ev1IX);
    pre1    = imgTS(ev1I) + pre;                 % define new pre window example
    post1   = imgTS(ev1I) + post;                % define new post window example
end

% Calculate number of data points in each pre- and post-event window.
pre1Binned  = timebin(pre1,imgTS,fps);          % log index of start of window time point
post1Binned = timebin(post1,imgTS,fps);         % log index of end of window time point
pre1IX      = find(pre1Binned);                 % index of pre event window example start
post1IX     = find(post1Binned);                % index of post event window example end
prePtNum    = abs(ev1I - pre1IX);                % number of data points within pre event window
postPtNum   = abs(ev1I - post1IX);               % number of data points within post event window
winPtNum    = prePtNum + postPtNum;             % number of data points in whole event window


%% Align data to selected each focus variable occurence

% Initialize matrices to store data
caEvNum  = sum(logical(caEv));                              % number of events for each cell
caEvMax  = max(caEvNum);                                    % count of events from cell with most events
periSD   = nan(caEvMax,winPtNum,cellNum);                   % initialize matrix for not-binned data
periData = nan(caEvMax,winPtNum,cellNum,dataNum);           % initialize matrix for other session events around cue

for cc = 1:cellNum
    cIX = find(caEv(:,cc));                                 % index of calcium events for current cell
    for ee = 1:caEvNum(cc)
        % Identify and remove timepoints in window outside calcium recording
        ccIX    = cIX(ee);                                  % current focus index (in imgTS)
        ccWinIX = ccIX + (-prePtNum:postPtNum-1);           % indices of points in cue window
        ptsB4   = ccWinIX < 1;                              % current window indices before session start
        ptsAft  = ccWinIX > ptNum;                          % cue window indices after session end
        
        ccWinIX(ptsB4|ptsAft) = [];                         % remove data points indices outside session range
        ffWinIXperi = ~(ptsB4|ptsAft);                      % index of window in periSDtrace (those not before or after Ca imaging)
        
        % Arrange SD data around current focus variable occurence
        periSD(ee,ffWinIXperi,cc) = sdSmooth(ccWinIX,cc);   % add SD trace within current window
        periData(ee,ffWinIXperi,cc,:) = data(ccWinIX,:);    % add data within current window
    end
end

periSDavg   = squeeze(nanmean(periSD,1));                   % average SD data across focused session event
semCt       = squeeze(sum(~isnan(periSD),1));               % number of non-NaN for each set to be averaged (for SEM calculation)
periSDerr   = squeeze(nanstd(periSD,1))./semCt;             % sem of periSDavg

xTick      = 0.5 + [0 prePtNum prePtNum+postPtNum];         % x-ticks positioned at ends of color blocks
xTickLabel = [pre 0 post];


%% Gather extra data
handles.periSD     = periSD;
handles.periSDavg  = periSDavg;
handles.periSDerr  = periSDerr;
handles.periData   = periData;
handles.xTick      = xTick;
handles.xTickLabel = xTickLabel;
handles.pre        = pre;
handles.post       = post;
handles.prePtNum   = prePtNum;
handles.postPtNum  = postPtNum;
handles.caEvNum    = caEvNum;


%% Plot
% eventAvg(handles)
eventFig(handles)
eventSort(handles)