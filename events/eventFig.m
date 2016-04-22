function eventFig(handles)
%Plot focused on (aligned to) calcium events.

%% Define data
cellNum = size(handles.sd,2);


%% Calculate event probabilities
% Calculate probability of session events around calcium events for all
% cells.
periData = handles.periData;
prePtNum = handles.prePtNum;
dataNum  = size(periData,4);

dataWin   = [any(periData(:,1:prePtNum,:,:),2), ...
             any(periData(:,prePtNum+1:end,:,:),2)];    % identify pre/post periods where data event occured
dataProbs = squeeze(nansum(dataWin,1))./ ...
            repmat(handles.caEvNum,2,1,dataNum);        % probability of each session event occuring around a calcium event for all cells

figProb = figure;
winTitle = sprintf('eventProb - %s', ...
                   get(handles.editLabel,'string'));
set(figProb,'name',winTitle,'numbertitle','off');
xTick = [1 2];
xTLab = {'pre' 'post'};
for dd = 1:dataNum+1
    axSub = subplot(1,dataNum+1,dd);
    if dd < dataNum+1
        C = squeeze(dataProbs(:,:,dd))';
        imagesc(C)
        set(axSub,'xTick',xTick, ...
                  'xTickLabel',xTLab, ...
                  'tickDir','out')
        caxis([0 1])
        title(handles.names{dd})
        if dd == 1
            ylabel('Individual cells')
        else
            set(axSub,'yTickLabel',[])
        end
    else
        cBar = colorbar('west');
        cLab = get(cBar,'ylabel');
        set(cLab,'string','Probability')
        set(axSub,'visible','off')
    end
end

handles.dataProbs = dataProbs;


%% Create figure
% Determine position of figure
screen = get(0,'screensize');                               % get screen resolution
figPos = [screen(3)/2+35 ...
          65 ...
          1000 ...
          screen(4)*3/4];                                   % position of figure to be created

% Create figure and subplots
handles.figEvent = figure;
winTitle = sprintf('eventFig - %s', ...
                   get(handles.editLabel,'string'));
set(handles.figEvent,'name',winTitle,'numbertitle','off', ...
                     'position',figPos);

handles.colour = {'b' 'g' 'r' 'c' 'y' 'm' 'k'};                     % color order for raster
colour = [0 0 1;
          0 0 1;
          0 1 0;
          0 1 0;
          1 0 0;
          1 0 0;
          0 1 1;
          0 1 1;
          1 1 0;
          1 1 0;
          1 0 1;
          1 0 1;
          0 0 0;
          0 0 0];
handles.marks  = {'x' 'o'};
marks = {'-' '--'};
set(0,'defaultAxesColorOrder',colour, ...
      'defaultAxesLineStyleOrder',marks)

handles.axRaster = subplot(3,2,[1 3]);
handles.axAvg    = subplot(3,2,5);
handles.axCP     = subplot(3,2,[2 4]);
handles.axBar    = subplot(3,2,6);


%% Create UI
bgColor = handles.figEvent.Color;
x  = 75;
y2 = 8;

% Sliders
sliderW    = 450;
sliderH    = 25;
sliderStep = [1 10];                                       % minor and major step for sliders
handles.sliderCell = ...
    uicontrol('parent',handles.figEvent, ...
              'style','slider', ...
              'position',[x,y2,sliderW,sliderH], ...
              'value',1, ...
              'min',1, ...
              'max',cellNum, ...
              'sliderStep',sliderStep/(cellNum-1));

% Text labels for edit box
xTxtOffset = 10;
yTxtOffset = -5;
xTxt       = x + sliderW + xTxtOffset;
txtW       = 50;
txtH       = 25;
uicontrol('parent',handles.figEvent, ...
          'style','text', ...
          'position',[xTxt,y2+yTxtOffset,txtW,txtH], ...
          'string','cell #: ', ...
          'backgroundColor',bgColor, ...
          'horizontalAlignment','right');

% Edit boxes
xEdit     = xTxt + txtW;
editW     = 50;
editH     = 25;

handles.editCell = ...
    uicontrol('parent',handles.figEvent, ...
              'style','edit', ...
              'position',[xEdit,y2,editW,editH], ...
              'String',1, ...
              'backgroundColor',bgColor);

set(handles.sliderCell,'callback',{@updateSliderCell,handles})
set(handles.editCell,'callback',{@updateEditCell,handles})


%% Plot
plotThat(handles)


function plotRaster(handles)
currCell = get(handles.sliderCell,'value');
periDataCell = squeeze(handles.periData(:,:,currCell,:));
[~, ...
 ~, ...
 dataNum]    = size(periDataCell);
caEvNum      = sum(any(isfinite(handles.periSD(:,:,currCell)),2));

titleRaster = 'Selected cell''s events around calcium events';


%% Plot
ax = handles.axRaster;

colour = handles.colour;                                    % color order for raster
colNum = length(colour);                                    % number of colors available
marks  = handles.marks;
mrkNum = length(marks);
xTick  = handles.xTick;
xTLab  = handles.xTickLabel;
xLim   = xTick([1 end]);

cla(ax)
hold(ax,'on')
title(ax,titleRaster)
set(ax,'ydir','reverse', ...
       'xTick',xTick, ...
       'xTickLabel',xTLab)

plotIX = true(1,dataNum);
for dd = 1:dataNum
    [I,J] = find(periDataCell(:,:,dd) > 0);                 % sub index of where data events occur; excludes NaN (find will index NaN)
    if isempty(I)
        plotIX(dd) = false;                                 % mark data as not plotted
        continue                                            % continue to next data variable
    end
    c = colour{mod(round(dd/2)-1,colNum)+1};
    m = marks{mod(dd-1,mrkNum)+1};
    scatter(ax,J,I,36,c,m)
end

xlim(ax,xLim)
try
    yLim = [0 caEvNum] + 0.5;
    ylim(ax,yLim)
    X = xTick(2) * [1 1];
    line(X,yLim,'color','k', ...
                'lineStyle','--', ...
                'parent',ax)
catch
end
ylabel(ax,'Calcium event number')
legend(ax,handles.names{plotIX})


function plotProb(handles)
ax = handles.axAvg;
currCell = get(handles.sliderCell,'value');


%% Plot
Y  = squeeze(handles.dataProbs(:,currCell,:));                 % probability of session event occuring
bar(ax,Y,1)

lY = ylim(ax);
lX = 1.5 * [1 1];
line(lX,lY,'lineStyle','--', ...
           'color','k', ...
           'parent',ax)

set(ax,'xTickLabel',{'pre' 'post'})
ylabel(ax,'Probability')
legend(ax,handles.names)


function plotTraceAvg(handles)
currCell = get(handles.sliderCell,'value');

periData = handles.periData;

colour = handles.colour;                                    % color order for raster
colNum = length(colour);                                    % number of colors available
marks  = {'-' '--'};
mrkNum = length(marks);
Y = squeeze(nanmean(periData(:,:,currCell,:),1));
X = (1:length(Y))';
Ystd = squeeze(nanstd(periData(:,:,currCell,:),1));
Yct  = squeeze(sum(isfinite(periData(:,:,currCell,:)),1));
% E = repmat(permute(Ystd./Yct,[1 3 2]),1,2,1);
E = Ystd./Yct;

cla(handles.axAvg);
for dd = 1:size(Y,2)
    c = colour{mod(round(dd/2)-1,colNum)+1};
    m = marks{mod(dd-1,mrkNum)+1};
    boundedline(handles.axTraceAvg,X,Y(:,dd),E(:,dd),[m c],'alpha')
end

% title(titleTraceAvg)
set(handles.axTraceAvg,'xTick',handles.xTick, ...
                       'xTickLabel',handles.xTickLabel)
xLim = handles.xTick([1 end]);
xlim(handles.axTraceAvg,xLim)


%% Callbacks

function updateSliderCell(source,callbackdata,handles)
pos = source.Value;
newPos = round(pos);

source.Value = newPos;
set(handles.editCell,'string',num2str(newPos))

plotThat(handles)


function updateEditCell(source,callbackdata,handles)
posStr = source.String;
newPos = str2double(posStr);
if isnan(newPos)
    msgbox('Invalid number')
    return
end

set(handles.sliderCell,'value',newPos)

plotThat(handles)


function plotThat(handles)
plotRaster(handles)
plotProb(handles)
plotDist(handles)