function eventSort(handles)

% periData dimensions: caEvMax x winPtNum x cellNum x dataNum

%% Parameters
dB = 5;
binNum = 5;
bnds = (0:binNum) * dB;
bndNum = length(bnds);

%% Gather data
caEv = handles.caEv;
periData = handles.periData;
[~, ...
 ptNum, ...
 cellNum, ...
 dataNum] = size(periData);                                 % number of data points in window and session events

[caEvI,caEvJ] = find(caEv);                                 % sub indices of calcium events
caEvIX = caEv > 0;
caEvNum = length(caEvIX);
bndCt  = hist(caEv(caEvIX),bnds+dB/2);                      % number of calcium events per grouping


%% Tally calcium events for each cell

cellCt = zeros(cellNum,bndNum+1);                           % initialize matrix to tally number of calcium events per amplitude range for each cell
cellCt(:,end) = sum(caEv > 0)';
bndIX = false([size(caEv) bndNum]);
for bb = 1:bndNum
    if bb ~= bndNum
        bndIX(:,:,bb) = caEv >  bnds(bb) & ...
                        caEv <= bnds(bb+1);
    else
        bndIX(:,:,bb) = caEv > bnds(bb);
    end
    cellCt(:,bb) = sum(bndIX(:,:,bb),1)';
end

% Initialize variable to store name of amplitude groups
tabVarNames = cell(1,bndNum+1);
tabVarNames{end} = 'all';


%% Plot thing.
figSort = figure;
winTitle = 'eventSort - Probability of session events (by Ca event amplitude)';
figPos   = get(figSort,'position');                         % get position/dimensions of figure window
figPos   = figPos .* [1 1/4 1 2];                           % make figure window twice as tall
set(figSort,'name',winTitle,'numbertitle','off', ...
            'position',figPos);
for bb = 1:bndNum+1
    % Find subscript index for all calcium events within current amp bounds
    if bb < bndNum
        [tsIX,cellIX] = find(caEv >  bnds(bb) & ...
                             caEv <= bnds(bb+1));
    elseif bb == bndNum
        [tsIX,cellIX] = find(caEv > bnds(bb));              % tsIX = timestamp index of event, cellIX = cell index of event
    elseif bb == bndNum+1
        [tsIX,cellIX] = find(caEv);
    end
    
    % Match each calcium event with its index for the cell it came from
    % i.e., Is it the 1st, 2nd, 3rd... calcium event for the cell
    caEvIX = zeros(size(tsIX));
    for ii = 1:length(tsIX)
        iiCellIX   = cellIX(ii);                            % cell of current calcium event
        iiCaEvJ    = caEvJ == iiCellIX;                     % indices of current cell (among all calcium events
        iiCaEvI    = caEvI(iiCaEvJ);                        % time indices of current cell's calcium events
        caEvIX(ii) = find(iiCaEvI == tsIX(ii));             % index of matching calcium event from cell to current calcium event
    end
    
    %%%% There has to be a better way %%%%%%%%%%%%%
    % Calculate timestamps of window for each calcium event within current
    % amp bounds.
    dataProbAll = zeros(ptNum,dataNum,length(tsIX));        % initialize matrix to store windows from each calcium event in current bounds
    for ii = 1:length(tsIX)
        caEvWin = squeeze(periData(caEvIX(ii),:,cellIX(ii),:));% window for current calcium event
        dataProbAll(:,:,ii) = caEvWin;
    end
    
    prePtNum = handles.prePtNum;                            % number of data points in pre period
    prePost = [any(dataProbAll(1:prePtNum,:,:),1); ...      % pre windows with occurence for each data event
               any(dataProbAll(prePtNum+1:end,:,:),1)];     % post windows with occurence for each data event
    prePostProb = squeeze(nanmean(prePost,3));              % probability of occurence for each data event (calculated by averaging 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Plot
    axSub = subplot(bndNum+1,1,bb);
    xTLab = {'pre' 'post'};
    
    Y = prePostProb;               % identify pre/post periods where data event occurs
    bar(axSub,Y)
    lX = 1.5 * [1 1];
    lY = ylim;
    line(lX,lY,'lineStyle','--', ...
               'color','k', ...
               'parent',axSub)
    
    if bb < bndNum
        set(axSub,'tickdir','out', ...
                  'xTickLabel',[])
        titleSub = sprintf('%u-%u sd calcium events, %u events', ...
                           bnds(bb),bnds(bb+1),bndCt(bb));
        tabVarNames{bb} = sprintf('sd%uto%u', ...
                           bnds(bb),bnds(bb+1));
    elseif bb == bndNum
        set(axSub,'tickdir','out', ...
                  'xTickLabel',[])
        titleSub = sprintf('> %u sd calcium events, %u events', ...
                           bnds(bb),bndCt(bb));
        tabVarNames{bb} = sprintf('sd%uplus', ...
                                  bnds(bb));
    elseif bb == bndNum+1
        set(axSub,'tickdir','out', ...
                  'xTickLabel',xTLab)
        titleSub = sprintf('all calcium events, %u events', ...
                           caEvNum);
        ylabel('Probability')
    end
    title(axSub,titleSub)
    
    
end

legend(axSub,handles.names)


%% Distribution

array2table(cellCt,'variableNames',tabVarNames, ...
                   'rowNames',cellstr(num2str((1:cellNum)')))
assignin('base','cellCt',cellCt)