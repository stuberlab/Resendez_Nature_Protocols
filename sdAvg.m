function sdAvg(data)
%Plots average response from each cell around focus variable

%% Setup
% Setup figure
figure('units','normalized', ...
       'position',[0.20 0.15 0.35 0.7], ...
       'name',sprintf('%s averaged responses - aligned to %s',data.label,data.fName), ...
       'numbertitle','off');


%% Color map of averages
% Color plot of each cell's average response to focus variable.
axCP = subplot(4,1,1:3,'xtick',data.xTick, ...
                       'xticklabel',data.xTLab, ...
                       'tickDir','out', ...
                       'xLim',[data.xTick(1) data.xTick(end)] + 0.5*[-1 1], ...
                       'yLim',[0 size(data.periSDavg,2)] + 0.5, ...
                       'yDir','reverse');
hold(axCP,'on')
imCP = imagesc(data.periSDavg','parent',axCP);
hold(axCP,'off')
title(axCP,sprintf('%s - averaged response to %s from each cell',data.label,data.fName))
ylabel(axCP,'cell number')
xlabel(axCP,sprintf('time from %s',data.fName))
hCB = colorbar('SouthOutside');
xlabel(hCB,'Average response value')

% Right-click menu
rcCP = uicontextmenu;                               % create uicontextmenu (right-click menu)
uimenu(rcCP,'label','Send to workspace', ...
            'callback',{@wsCB,imCP});               % create first menu item - 'Send to workspace'
uimenu(rcCP,'label','Save data', ...
            'callback',{@saveDataCB,imCP});         % create second menu item - 'Save data'
uimenu(rcCP,'label','Open in new window', ...
            'callback',{@copyImCB,axCP});           % create third menu item - 'Open in new window'
set(axCP,'uicontextmenu',rcCP)                      % assign right click menu to colorplot axes
set(imCP,'uicontextmenu',rcCP)                      % assign right click menu to colorplot image


%% Bar graph
% Bar graph of probability of occurence of other variables during window
% before and after focus variable occurence.
if isempty(data.periDataP)
    return
end
axSR = subplot(4,1,4,'xTick',[1 2], ...
                     'xTickLabel',{'pre' 'post'}, ...
                     'tickDir','out');
title(axSR,sprintf('Probability of occurence before and after %s',data.fName))
ylabel(axSR,'Probability')
hold(axSR,'on')
brSR = bar(axSR,data.periDataP,1);
hold(axSR,'off')
legend(axSR,data.oNames)

% Right-click menu
rcSR = uicontextmenu;
uimenu(rcSR,'label','Send to workspace', ...
            'callback',{@wsCB,brSR});
uimenu(rcSR,'label','Save data', ...
            'callback',{@saveDataCB,brSR});
uimenu(rcSR,'label','Open in new window', ...
            'callback',{@copyImCB,axSR});
set(axSR,'uicontextmenu',rcSR)
set(brSR,'uicontextmenu',rcSR)