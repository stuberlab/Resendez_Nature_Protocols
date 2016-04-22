function eventAvg(handles)


%% Gather data

dataNum = size(handles.periData,4);                         % number of data variables


%% Figure setup

label = get(handles.editLabel,'string');                    % user-defined label for data
screen = get(0,'screensize');                               % Screen resolution.
figPos = [25 75 600 screen(4)*3/4];                         % Position of figure to be created

figSession = figure;                                        % create new figure
winTitle   = sprintf('%s - Session data by calcium events', ...
                     label);                                % title for figure window
set(figSession,'position',figPos, ...
               'name',winTitle,'numbertitle','off')         % define figure properties

handles.axCP   = subplot(3,1,[1 2]);
handles.axCell = subplot(3,1,3);


%% Create UI
bgColor = figSession.Color;
x  = 175;
y = 8;

% Sliders
sliderW    = 450;
sliderH    = 25;
sliderStep = [1 10];                                       % minor and major step for sliders
handles.sliderData = ...
    uicontrol('parent',figSession, ...
              'style','slider', ...
              'position',[x,y,sliderW,sliderH], ...
              'value',1, ...
              'min',1, ...
              'max',dataNum, ...
              'sliderStep',sliderStep/(dataNum-1));

% Text labels for edit box
xTxtOffset = 10;
yTxtOffset = -5;
xTxt       = x + sliderW + xTxtOffset;
txtW       = 50;
txtH       = 25;
uicontrol('parent',figSession, ...
          'style','text', ...
          'position',[xTxt,y+yTxtOffset,txtW,txtH], ...
          'string','data var #: ', ...
          'backgroundColor',bgColor, ...
          'horizontalAlignment','right');

% Edit boxes
xEdit     = xTxt + txtW;
editW     = 50;
editH     = 25;
handles.editData = ...
    uicontrol('parent',figSession, ...
              'style','edit', ...
              'position',[xEdit,y,editW,editH], ...
              'String',1, ...
              'backgroundColor',bgColor);

set(handles.sliderData,'callback',{@updateSliderData,handles})
set(handles.editData,'callback',{@updateEditData,handles})

plotCP(handles)
plotCell(handles)


%% Plot

function plotCP(handles)

dataIX = get(handles.sliderData,'value');
titleCP = sprintf('Cell averaged probability of %s around calcium events', ...
                  handles.names{dataIX});

C = squeeze(mean(handles.periData(:,:,:,dataIX),1))';

axes(handles.axCP)
imagesc(C)
title(handles.axCP,titleCP)
set(handles.axCP,'xtick',handles.xTick, ...
                 'xTickLabel',handles.xTickLabel)
colorbar('SouthOutside')
ylabel('cell number')


function plotCell(handles)
