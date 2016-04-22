function sdBrowse(data)
%Plots figure with GUI to browse through cells and focus variable
%occurences.
% 
% Input data from sdAlign.m. Data is aligned to occurences of certain focus
% variable.


%% Define data

[fNum, ...
 xNum, ...
 cellNum] = size(data.periSD);


%% Create figure

% Create figure based on screen size. Add window title based on user input
% label.
GUI.figFocus = figure('units','normalized', ...
                      'position',[0.25 0.15 0.5 0.7], ...
                      'name',sprintf('%s raw responses - aligned to %s',data.label,data.fName), ...
                      'numbertitle','off');


% Create subplots for each plot. Leave 'empty' subplot at the bottom for
% slider object.

% Subplot for SD responses for each focus variable occurence for cell
% selected in GUI.
GUI.axFCP = subplot(7,2,1:2:7, ...
                    'xTick',data.xTick, ...
                    'xTickLabel',data.xTLab, ...
                    'xLim',[data.xTick(1) data.xTick(end)] + 0.5*[-1 1], ...
                    'yLim',[0 fNum] + 0.5, ...
                    'yDir','reverse');
hold(GUI.axFCP,'on')
GUI.imFCP = imagesc(1,'parent',GUI.axFCP);
hold(GUI.axFCP,'off')
title(GUI.axFCP, ...
      sprintf('Response to all %ss from selected cell',data.fName))
ylabel(GUI.axFCP,sprintf('%s #',data.fName))
xlabel(GUI.axFCP,sprintf('time from %s',data.fName))
GUI.cbFCP = colorbar(GUI.axFCP,'SouthOutside');
xlabel(GUI.cbFCP,'Response value')

% Right-click menu
rcFCP = uicontextmenu;
uimenu(rcFCP,'label','Send to workspace', ...
             'callback',{@wsCB,GUI.imFCP});
uimenu(rcFCP,'label','Save data', ...
             'callback',{@saveDataCB,GUI.imFCP});
uimenu(rcFCP,'label','Open in new window', ...
             'callback',{@copyImCB,GUI.axFCP});
set(GUI.axFCP,'uicontextmenu',rcFCP)
set(GUI.imFCP,'uicontextmenu',rcFCP)


% Supblot for SD responses for each cell for selected focus variable 
% occurence.
GUI.axCCP = subplot(7,2,2:2:8, ...
                    'xTick',data.xTick, ...
                    'xTickLabel',data.xTLab, ...
                    'xLim',[data.xTick(1) data.xTick(end)] + 0.5*[-1 1], ...
                    'yLim',[0 cellNum] + 0.5, ...
                    'yDir','reverse');
hold(GUI.axCCP,'on')
GUI.imCCP = imagesc(1,'parent',GUI.axCCP);
hold(GUI.axCCP,'off')
title(GUI.axCCP, ...
      sprintf('Response to selected %s from each cell',data.fName))
ylabel(GUI.axCCP,'cell #')
xlabel(GUI.axCCP,sprintf('time from %s',data.fName))
GUI.cbCCP = colorbar(GUI.axCCP,'SouthOutside');
xlabel(GUI.cbCCP,'Response value')

% Right-click menu
rcCCP = uicontextmenu;
uimenu(rcCCP,'label','Send to workspace', ...
            'callback',{@wsCB,GUI.imCCP});
uimenu(rcCCP,'label','Save data', ...
            'callback',{@saveDataCB,GUI.imCCP});
uimenu(rcCCP,'label','Open in new window', ...
            'callback',{@copyImCB,GUI.axCCP});
set(GUI.axCCP,'uicontextmenu',rcCCP)
set(GUI.imCCP,'uicontextmenu',rcCCP)


% SD trace of cell selected in GUI around focus variable occurence selected
% in GUI.
GUI.axTrace = subplot(7,2,[9 10], ...
                      'xTick',data.xTick, ...
                      'xLim',[1 xNum]);
hold(GUI.axTrace,'on')
GUI.line    = plot(GUI.axTrace,1);
hold(GUI.axTrace,'off')
title(GUI.axTrace, ...
      sprintf('Response to %ss from selected cell',data.fName))
ylabel(GUI.axTrace,'cell')

% Right-click menu
rcTrace = uicontextmenu;
uimenu(rcTrace,'label','Send to workspace', ...
               'callback',{@wsCB,GUI.line});
uimenu(rcTrace,'label','Save data', ...
               'callback',{@saveDataCB,GUI.line});
uimenu(rcTrace,'label','Open in new window', ...
               'callback',{@copyImCB,GUI.axTrace});
set(GUI.axTrace,'uicontextmenu',rcTrace)
set(GUI.line,'uicontextmenu',rcTrace)


% Average SD trace of cell selected in GUI for all focus variable
% occurences
GUI.axTraceAvg = subplot(7,2,[11 12], ...
                         'xTick',data.xTick, ...
                         'xTickLabel',data.xTLab, ...
                         'xLim',[1 xNum]);
hold(GUI.axTraceAvg,'on')
GUI.lineAvg  = plot(GUI.axTraceAvg,1);
lineColor    = get(GUI.lineAvg,'color');
GUI.lineErr1 = plot(GUI.axTraceAvg,1,':','color',lineColor);
GUI.lineErr2 = plot(GUI.axTraceAvg,1,':','color',lineColor);
hold(GUI.axTraceAvg,'off')
ylabel(GUI.axTraceAvg,'avg')
xlabel(GUI.axTraceAvg,sprintf('time from %s',data.fName))

% Right-click menu
rcTraceAvg = uicontextmenu;
uimenu(rcTraceAvg,'label','Send to workspace', ...
                  'callback',{@wsCB,GUI.lineAvg});
uimenu(rcTraceAvg,'label','Save data', ...
                  'callback',{@saveDataCB,GUI.lineAvg});
uimenu(rcTraceAvg,'label','Open in new window', ...
                  'callback',{@copyImCB,GUI.axTraceAvg});
set(GUI.axTraceAvg,'uicontextmenu',rcTraceAvg)
set(GUI.lineAvg,'uicontextmenu',rcTraceAvg)
set(GUI.lineErr1,'uicontextmenu',rcTraceAvg)
set(GUI.lineErr2,'uicontextmenu',rcTraceAvg)


%% Create UI
bgColor = GUI.figFocus.Color;
x       = 0;
y1      = 0.10;             % position for first row (focus variable #)
y2      = 0.05;             % position for second row (cell #)
h       = 0.04;             % height of interface items
xTxt    = x;
yTxtOff = -0.014;
wTxt    = 0.14;
xEdit   = x + wTxt;
wEdit   = 0.07;
xSlid   = xEdit + wEdit + 0.025;
wSlid   = 0.675;

% Text labels for edit box
uicontrol('parent',GUI.figFocus, ...
          'style','text', ...
          'units','normalized', ...
          'position',[xTxt,y1+yTxtOff,wTxt,h], ...
          'string',sprintf('%s #: ',data.fName), ...
          'backgroundColor',bgColor, ...
          'horizontalAlignment','right');
uicontrol('parent',GUI.figFocus, ...
          'style','text', ...
          'units','normalized', ...
          'position',[xTxt,y2+yTxtOff,wTxt,h], ...
          'string','cell rank/ID: ', ...
          'backgroundColor',bgColor, ...
          'horizontalAlignment','right');

% Edit boxes
GUI.editFocus = ...
    uicontrol('parent',GUI.figFocus, ...
              'style','edit', ...
              'unit','normalized', ...
              'position',[xEdit,y1,wEdit,h], ...
              'String',1, ...
              'backgroundColor',bgColor);
GUI.editCell = ...
    uicontrol('parent',GUI.figFocus, ...
              'style','edit', ...
              'unit','normalized', ...
              'position',[xEdit,y2,wEdit/2,h], ...
              'String',1, ...
              'backgroundColor',bgColor);
GUI.editID = ...
    uicontrol('parent',GUI.figFocus, ...
              'style','edit', ...
              'unit','normalized', ...
              'position',[xEdit+wEdit/2,y2,wEdit/2,h], ...
              'String',data.cellID(1), ...
              'backgroundColor',bgColor);

% Sliders
sliderStep = [1 10];                                % minor and major step for sliders
GUI.sliderFocus = ...
    uicontrol('parent',GUI.figFocus, ...
              'style','slider', ...
              'units','normalized', ...
              'position',[xSlid,y1,wSlid,h], ...
              'value',1, ...
              'min',1, ...
              'max',fNum, ...
              'sliderStep',sliderStep/(fNum-1));
GUI.sliderCell = ...
    uicontrol('parent',GUI.figFocus, ...
              'style','slider', ...
              'units','normalized', ...
              'position',[xSlid,y2,wSlid,h], ...
              'value',1, ...
              'min',1, ...
              'max',cellNum, ...
              'sliderStep',sliderStep/(cellNum-1));

% Callbacks
set(GUI.sliderFocus,'callback',{@updateSliderFocus,data,GUI})
set(GUI.sliderCell,'callback',{@updateSliderCell,data,GUI})
set(GUI.editFocus,'callback',{@updateEditFocus,data,GUI})
set(GUI.editCell,'callback',{@updateEditCell,data,GUI})
set(GUI.editID,'callback',{@updateEditID,data,GUI})


%% Plot
plotFCP(data,GUI)
plotCCP(data,GUI)
plotTrace(data,GUI)
plotTraceAvg(data,GUI)



%% Plot focus colorplot
function plotFCP(data,GUI)
currCell = get(GUI.sliderCell,'value');
set(GUI.imFCP,'cdata',squeeze(data.periSD(:,:,currCell)))


%% Plot cell colorplot
function plotCCP(data,GUI)
currFocus = get(GUI.sliderFocus,'value');
set(GUI.imCCP,'cdata',squeeze(data.periSD(currFocus,:,:))')


%% Plot cell trace for chosen focus occurence
function plotTrace(data,GUI)
currFocus = get(GUI.sliderFocus,'value');
currCell  = get(GUI.sliderCell,'value');
set(GUI.line,'ydata',data.periSD(currFocus,:,currCell))
set(GUI.axTrace,'xTickLabel',data.xTLab + data.imgTS(data.fIX(currFocus)))


%% Plot cell trace averaged across all focus occurences
function plotTraceAvg(data,GUI)
currCell = get(GUI.sliderCell,'value');
Y = data.periSDavg(:,currCell);
set(GUI.lineAvg,'ydata',Y)
set(GUI.lineErr1,'ydata',Y + data.periSDerr(:,currCell))
set(GUI.lineErr2,'ydata',Y - data.periSDerr(:,currCell))


%% Callbacks
function updateSliderFocus(source,callbackdata,data,GUI)
pos    = source.Value;
newPos = round(pos);

source.Value = newPos;
set(GUI.editFocus,'string',num2str(newPos))

plotCCP(data,GUI)
plotTrace(data,GUI)

function updateSliderCell(source,callbackdata,data,GUI)
pos    = source.Value;
newPos = round(pos);

source.Value = newPos;
set(GUI.editCell,'string',num2str(newPos))
set(GUI.editID,'string',num2str(data.cellID(newPos)))

plotFCP(data,GUI)
plotTrace(data,GUI)
plotTraceAvg(data,GUI)

function updateEditFocus(source,callbackdata,data,GUI)
posStr = source.String;
newPos = str2double(posStr);
if ~ismember(newPos,1:size(data.periSD,2))
    msgbox('Invalid input')
    return
end

set(GUI.sliderFocus,'value',newPos)

plotCCP(data,GUI)
plotTrace(data,GUI)

function updateEditCell(source,callbackdata,data,GUI)
posStr = source.String;
newPos = str2double(posStr);
if ~ismember(newPos,1:size(data.periSD,3))
    msgbox('Invalid input')
    return
end
set(GUI.editID,'string',num2str(data.cellID(newPos)))
set(GUI.sliderCell,'value',newPos)

plotFCP(data,GUI)
plotTrace(data,GUI)
plotTraceAvg(data,GUI)

function updateEditID(source,callbackdata,data,GUI)
posStr = source.String;
newPos = str2double(posStr);
[validID, ...
 IDIX] = ismember(newPos,data.cellID);
if ~validID
    msgbox('Invalid input')
    return
end
set(GUI.editCell,'string',num2str(IDIX))
set(GUI.sliderCell,'value',IDIX)

plotFCP(data,GUI)
plotTrace(data,GUI)
plotTraceAvg(data,GUI)