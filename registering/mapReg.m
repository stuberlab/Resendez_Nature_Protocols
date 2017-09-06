function [reged,coordTF,tform] = mapReg(map,ref,coords)
%Registers cell map to reference map.
% Image of cell map is registered to a reference cell map image. Transform
% is applied to coordinates of orignal cell map to obtain new coordinates
% (coordTF). Conversion factor from reference coordinate system should be
% used.
% 
% Inputs
%  map:         Image data for cell map to be registered. Obtained from
%               mapCells.m.
%  ref:         Image data for cell map to be registered. Obtained from
%               mapCells.m.
%  coordinates: mx2 array of x,y-coordinates for each cell in input 'map'. 
%               Coordinates should have units of pixels. m is the number of
%               cells in input 'map'.
% 
% Outputs
%  reged:       Image data for registered cell map.
%  coordTF:     mx2 array of coordinates for cells in registered cell map.
%  tform:       Transform used for image registration.


%% Define maps
if ~exist('map','var')
    %% Get images
    path = uigetdir(pwd,'Directory of cell images to register');
    if path == 0, return, end
    [map,coords] = mapCells(1,path,'overlay');
    
    path = uigetdir(path,'Directory of reference cell images');
    if path == 0, return, end
    ref = mapCells(1,path,'overlay');
end


%% Register images
[optimizer, ...
 metric] = imregconfig('multimodal');
tform    = imregtform(map,ref,'similarity',optimizer,metric);   % transform - registers map to ref
R1       = imref2d(size(map));
R2       = imref2d(size(ref));
reged    = imwarp(map,R1,tform,'outputView',R2);                % registered map


%% Transform coordinates
coords  = coords(1,size(coords,2)+1);       % add column of zeros to make it "3D"
coordTF = coords * tform.T;                 % transform coordinates based on registration
coordTF = coordTF(:,1:end-1);               % remove 3rd "dimesion"/column

%{
%% Plot
colorPair = [1 0 2];                        % RGB values used for overlay (1 marks colors for first, 2 for second image)

% Create figure showing cell maps before and after registration
figure

subplot(1,2,1)
imshowpair(map,ref,'falsecolor')
title('Original')

subplot(1,2,2)
imshowpair(reged,ref,'falsecolor')
title('Registered')

mapOverlay(reged,ref)
%}
