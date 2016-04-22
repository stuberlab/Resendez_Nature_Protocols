function plotDist(handles)

%% Parameters
dB = 5;
binNum = 5;
caEvBnds = (0:binNum) * dB;
caEvBndN = length(caEvBnds);

cellN = get(handles.sliderCell,'value');

imgTS    = handles.imgTS;
caEvN    = handles.caEv(:,cellN);
data     = handles.data;
dataNum  = size(data,2);
names    = handles.names;

caEvTS      = cell(1,caEvBndN+1);                       % initialize matrix to store indices of calcium events based on amplitude
caEvIX      = caEvN > 0;                              % index of all calcium events
[~,sortIX]  = sort(caEvN(caEvIX));                   % order of all calcium events by magnitude                       
caEvTS{end} = imgTS(caEvIX);                          % timestamp of all calcium events
for bb = 1:caEvBndN
    if bb ~= caEvBndN
        caEvIX     = caEvN >  caEvBnds(bb) & ...
                     caEvN <= caEvBnds(bb+1);     % index of all calcium events with appropriate amplitude
        caEvTS{bb} = imgTS(caEvIX);               % timestamp of all calcium events with appropriate amplitude
    else
        caEvIX     = caEvN > caEvBnds(bb);        % index of all calcium events with appropriate amplitude
        caEvTS{bb} = imgTS(caEvIX);               % timestamp of all calcium events with appropriate amplitude
    end
end

dataTS = cell(1,dataNum);
for dd = 1:dataNum
    dataTS{dd} = imgTS(data(:,dd) > 0);             % timestamps of occurences of current data variable
end

tDiff = cell(1,caEvBndN+1);                         % initialize cell of differences between each calcium event and each session event
                                                    % (arranged by calcium event magnitude - the different cell elements)
for bb = 1:caEvBndN+1
    if isempty(caEvTS{bb})
        tDiff{bb} = nan(length(sortIX),dataNum); % CHECK %%%%%
    else
        for dd = 1:dataNum
            if isempty(dataTS{dd})
                tDiff{bb}(:,dd) = nan(length(sortIX),1);        % CHECK %%%%%%%%%%%%%
            else
                [~,tDiff{bb}(:,dd)] = knnsearch(dataTS{dd},caEvTS{bb});
            end
        end
    end
end

sem      = @(x) std(x,0,1)/sqrt(size(x,1));           % anonymous function for standard erro
tDiffAvg = cellfun(@(x) mean(x,1),tDiff, ...
                   'uniformOutput',0);              % mean difference between timestamps of each calcium event and neearest behavioral event
tDiffSEM = cellfun(sem,tDiff, ...
                   'uniformOutput',0);              % std error "
               
               %%%%%%%%%%% CHECK %%%%%%%%%%%%%%%%%


%% Plot

% Figure setup
axCP    = handles.axCP;
axBar   = handles.axBar;

% Color plot
Cbnd = tDiff(1:end-1);
Call = tDiff{end};

C = Call(sortIX,:);
bndCts = cellfun(@(x) size(x,1),Cbnd);

axes(axCP)
imagesc(C)
cBar = colorbar('southOutside');
cLab = get(cBar,'ylabel');
set(cLab,'string','Time difference (s)')
maxTime = max(handles.pre,handles.post);            % greater value of pre and post times
caxis([0 maxTime*2])                                % set color axis to twice of maxTime (previous value)

xLim = xlim;
Y    = cumsum(bndCts)' * [1 1] + 0.5;               % y bounds for line to mark time of calcium event
for bb = 1:caEvBndN
    line(xLim,Y(bb,:),[1 1],'lineStyle','--', ...
                            'color','k')
end
title(axCP,'Time difference between calcium event and session event')
ylabel('Individual calcium events')
set(axCP,'xTick',1:dataNum, ...
         'xTickLabel',names, ...
         'xTickLabelRotation',45)

% Average bar graph
Y = cell2mat(tDiffAvg');
E = cell2mat(tDiffSEM');

xTLab = cell(1,caEvBndN+1);
xTLab{end} = 'all';
for cc = 1:caEvBndN
    if cc < caEvBndN
        xTLab{cc} = sprintf('%u-%u',caEvBnds(cc),caEvBnds(cc+1));
    elseif cc == caEvBndN
        xTLab{cc} = sprintf('>%u',caEvBnds(cc));
    end
end

axes(axBar)
bar(axBar,Y,1)
hold(axBar,'on')
errorbar(Y,E,'.')   % DOESN'T WORK :(
ylabel(axBar,'Mean time (s)')
xlabel(axBar,'Calcium event magnitude (s.d.)')
set(axBar,'xTick',1:caEvBndN+1, ...
          'xTickLabel',xTLab, ...
          'tickDir','out')
legend(axBar,names)
hold(axBar,'off')