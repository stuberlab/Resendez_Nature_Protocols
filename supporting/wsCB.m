function wsCB(a,b,hObj)

switch class(hObj)
    case 'matlab.graphics.primitive.Image'
        data = get(hObj,'cData');
    otherwise
        data = get(hObj,'yData');
end

varName = inputdlg('Variable name:','Import to workspace');
assignin('base',varName{:},data)