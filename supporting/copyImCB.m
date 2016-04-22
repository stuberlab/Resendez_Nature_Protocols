function copyImCB(a,b,hObj)

fig = figure;
ax = copyobj(hObj,fig);
set(ax,'position',get(0,'defaultAxesPosition'))

if isa(get(ax,'children'),'matlab.graphics.primitive.Image')
    cb = colorbar(ax,'southOutside');
    xlabel(cb,'Cell response')
end