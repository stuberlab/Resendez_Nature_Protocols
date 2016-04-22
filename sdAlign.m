function sdAlign(h)
%Plots colormap of each neuron's averaged response to the 'aligning variable'
% 
% Organizes data around pre-defined time window of each occurence of chosen
% 'aligning variable'. 

%% Retrieve data

% Calcium imaging data
cellNum = size(h.sd,2);                         % number of cells after filter
binT    = mean(diff(h.imgTS));                  % average length of 'imgTS' bins

% Identify aligning variable
fIXN      = get(h.popData,'value');             % numerical index of aligning variable
varNum    = length(h.names);                    % number of variables
fIX       = false(1,varNum);
fIX(fIXN) = true;                               % logical index of aligning variable
fNum      = nnz(h.data(:,fIX));                 % number of occurences of aligning variable
if fNum == 0
    msgbox('Variable has no occurences to align data to')
end
fName     = h.names{fIX};                       % name of aligning variable

% Parameters for cue window
pre  = str2double(get(h.editPre,'string'));     % start time for window, in relation to cue time
post = str2double(get(h.editPost,'string'));    % end time for window, in relation to cue time

% Smoothing
toSmooth = get(h.checkSmooth,'value');

% Cell IDs and Sorting
cellID = 1:cellNum;
toSort = get(h.checkSort,'value');
toMap  = get(h.checkMap,'value');

% Images for cell map
pMaps = get(h.editMapPath,'string');


%% Smooth data (if called for)
if toSmooth
    smoothWin = str2double(get(h.editSmooth,'string')); % convert string to double
    h.sd      = conv2(h.sd, ...
                      ones(smoothWin,1)/smoothWin, ...
                      'same');                          % smooth data
end


%% Determine window
% Find occurences of aligning variable and determine number of data points for
% cue window.

fTSIXN = find(h.data(:,fIX));                       % numerical indices of aligning variable (in imgTS)
pre1   = h.imgTS(fTSIXN(1)) + pre;                  % lowest time captured by pre window
post1  = h.imgTS(fTSIXN(1)) + post;                 % highest time captured by post window

% In case first event is too close to session start to have full pre 
% window (thus full amount of time points), move to next occurence until 
% full pre window exists.
imgTSlbnd = h.imgTS(1) - binT;                      % lowest time captured by calcium imaging
nn        = 1;                                      % counter index for aligning occurence with full window (first one is probably good for the most part)
while pre1 < imgTSlbnd
    nn    = nn + 1;                                 % increment counter
    if nn > fNum
        msgbox('Variable does not have enough occurences or is clustered near beginning. Try a smaller window.')
        return
    end
    pre1  = h.imgTS(fTSIXN(nn)) + pre;              % define new pre window low time
    post1 = h.imgTS(fTSIXN(nn)) + post;             % define new post window high time
end

% Calculate number of data points in each pre and post window.
pre1Bin   = binData(pre1,h.imgTS);                  % log index of start of example window (in imgTS)
post1Bin  = binData(post1,h.imgTS);                 % log index of end of example window (in imgTS)
prePtNum  = find(pre1Bin) - fTSIXN(nn);             % number of data points within pre window
postPtNum = find(post1Bin) - fTSIXN(nn);            % number of data points within post window
winPtNum  = postPtNum - prePtNum + 1;               % number of data points in entire window

% Determine if aligning variable occurs within user-defined window, e.g., 
% if window is defined as 1 s to 2 s after align variable occurs.
if prePtNum > 0 || postPtNum < 0
    winOut = true;
else
    winOut = false;
end

% Set xtick for plotting
if winOut
    xTick = [1 winPtNum];
    xTLab = [pre post];
else
    xTick = [1 -prePtNum+1 winPtNum];
    xTLab = [pre 0 post];
end


%% Align data

% Define matrices to store data.
% Dimensions
% 1. occurences of aligning variable
% 2. time points (axis)
% 3. [variable]
periResp = nan(fNum,winPtNum,cellNum);                  % matrix for response values around aligning variable
periData = nan(fNum,winPtNum,varNum-1);                 % matrix for data from other variables around aligning variable

% Loop through each occurrence of aligning variable and define window and data
% within window.
for ff = 1:fNum
    % Identify and remove timepoints in window outside calcium recording
    ffWinIX = fTSIXN(ff) + (prePtNum:postPtNum);        % indices of time points in window
    ptsIn   = ffWinIX >= 1 & ...
              ffWinIX <= length(h.imgTS);               % indices of window time points within session as defined by cellular response data
    ffWinIX(~ptsIn) = [];                               % remove indices outside session range
    
    % Arrange response data around current aligning variable occurence
    periResp(ff,ptsIn,:)   = h.sd(ffWinIX,:);           % add traces within current window
    periData(ff,ptsIn,:) = h.data(ffWinIX,~fIX);        % add data from other variables within current window
end

% Average data and determine statistics.
periAvg   = squeeze(nanmean(periResp,1));               % average SD trace across aligning variable occurences for each cell
periErr   = squeeze(nanstd(periResp,1))./ ...
            sqrt(squeeze(sum(~isnan(periResp),1)));     % sem of periSDavg

% Calculate probability of occurences of other variables before and after
% aligning variable occurence. Determine for each occurrence of aligning 
% variable, whether each of other session variables occured in the pre and 
% post windows.
if winOut
    dataWin   = any(periData,2);
    periDataP = squeeze(nansum(dataWin,1)) ./ fNum;
else
    dataWin   = [any(periData(:,1:-prePtNum,:),2), ...
                 any(periData(:,-prePtNum+1:end,:),2)];         % index of pre & post windows where occurence of session variable occured
    periDataP = squeeze(nansum(dataWin,1)) ./ fNum;             % probability for each session variable that it occured within pre or post window; 'reshape' removes first dimension (singleton)
end


%% Determine 'responses' for each cell data (if called for)

if toSort || toMap
    % Determine response window relative to aligning variable occurence
    resp1    = str2double(get(h.editResp1,'string'));           % time of response window start relative to aligning variable
    resp2    = str2double(get(h.editResp2,'string'));           % time of response window end relative to aligning variable
    resp1Bin = binData(h.imgTS(fTSIXN(nn))+resp1,h.imgTS);      % time point of response window start relative to aligning variable data point
    resp2Bin = binData(h.imgTS(fTSIXN(nn))+resp2,h.imgTS);      % time point of response window end relative to aligning variable data point
    respBin  = (find(resp1Bin):find(resp2Bin)) - ...
               (fTSIXN(nn) + prePtNum);                         % index of response window within aligning window
    
    % Determine response for each cell
    respByMax = get(h.radioMax,'value');
    if respByMax
        resp = max(periAvg(respBin,:),[],1)';                 % array of each cells average response to aligning variable
    else
        resp = nanmean(periAvg(respBin,:),1)';                % array of each cells average response to aligning variable
    end
else
    resp = 1;
end

% Sort data (if called for)
if toSort
    % Sort all data by response
    [~,sortIX] = sort(resp);                                    % sorting index by response
    cellID     = cellID(sortIX);
    h.sd       = h.sd(:,sortIX);
    periResp     = periResp(:,:,sortIX);
    periAvg  = periAvg(:,sortIX);
    periErr  = periErr(:,sortIX);
else
    sortIX = true(cellNum,1);                                   % sorting index (standard order)
end


%% Plot

% Gather data
data.label     = get(h.editLabel,'string');             % Dataset label from GUI.
data.cellID    = cellID;
data.imgTS     = h.imgTS;
data.fName     = fName;
data.fIX       = fTSIXN;
data.periSD    = periResp;
data.periSDavg = periAvg;
data.periSDerr = periErr;
data.sortIX    = sortIX;
data.oNames    = h.names(~fIX);                         % names of other variables
data.periData  = periData;
data.periDataP = periDataP;
data.xTick     = xTick;
data.xTLab     = xTLab;

% Plot
sdAvg(data)
sdBrowse(data)
if toMap, alignMap(data,resp,pMaps), end