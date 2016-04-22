function saveDataCB(a,b,hObj)

switch class(hObj)
    case 'matlab.graphics.primitive.Image'
        data = get(hObj,'cData');
    otherwise
        data = get(hObj,'yData');
end

[fName,pName] = uiputfile({'*.mat' 'Matlab file (*.mat)';
                           '*.txt' 'Text file (*.txt)'},'Save as...');
[~,~,ext] = fileparts(fName);
switch ext
    case '.txt'
        save([pName fName],'data','-ascii')
    case '.mat'
        save([pName fName],'data','-mat')
    otherwise
        msgbox('Extension is not recognized')
        return
end