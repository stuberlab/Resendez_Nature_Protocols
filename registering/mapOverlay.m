function mapOverlay(map1,map2)
%Plots overlay of 2 cell maps
% 
% Input
%  map1/2:  Matrices defining cell maps. Values can be obtained from
%           'cellMap.m'.

%% Parameters
colorPair = [1 0 2];                        % RGB values used for overlay (1 marks colors for first, 2 for second image)


%% Define maps
if ~exist('map1','var')
    %% Get images
    path = uigetdir(pwd,'Directory of cell images for first set');
    if path == 0, return, end
    map1 = cellMap(1,path);
    
    path = uigetdir(path,'Directory of cell images for first set');
    if path == 0, return, end
    map2 = cellMap(1,path);
end


%% Plot
blankImg = zeros(size(map1));

figure

subplot(1,3,1)
imshowpair(blankImg,map1,'falsecolor', ...
                         'colorChannels',colorPair)

subplot(1,3,2)
imshowpair(map2,blankImg,'falsecolor', ...
                         'colorChannels',colorPair)

subplot(1,3,3)
imshowpair(map2,map1,'falsecolor', ...
                     'colorChannels',colorPair)
title('Overlay')