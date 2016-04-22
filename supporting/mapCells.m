function [cellImg,coords] = mapCells(data,imgPath,method)
%Creates cell map data with values for each cell corresponding to input
% 
% Input
%  data:    mx1 array of values to plot for each cell
%  imgPath: Directory of image files for each cell (m files). If empty,
%           function will prompt user for directory.
%  method:  Approach to adding cells. Either 'overlay' or 'add' (add
%           ignores variable 'data' currently).
% 
% Output
%  cellImg: Data for cell map of all cells with values corresponding to
%           input 'data'.
%  coords:  Coordinates for each cell calculated as centroids.

%% Parameters
filt = [3 3];               % parameters for median filter used to create cell maps
if strcmpi(method, 'add')
    toOverlay = false;
else
    if ~strcmpi(method, 'overlay')
        fprint('No valid method defined. Cells will be overlayed.')
    end
    toOverlay = true;
end


%% Retrieve image directory
% If directory of cell images is not defined, prompt user to locate
% directory.
if ~exist('imgPath','var')
    imgPath = uigetdir(pwd,'Select folder with cell images');
    if imgPath == 0
        msgbox('No directory selected')
        return
    end
end

imgFiles  = cellstr(ls([imgPath '\*.tif']));          % identify relevant image files
fileNum   = length(imgFiles);                           % caculate number of files

% Sort files by cell ID
cellID   = zeros(fileNum,1);                            % array of cell IDs for each file
for cc = 1:fileNum
    num = regexp(imgFiles{cc},'\d');                    % retrieve cell ID from file name
    if any(num)
        cellID(cc) = str2double(imgFiles{cc}(num));     % convert ID to type double
    else
        cellID(cc) = 0;                                 % file without number assigned will rank first (0)
    end
end
[~,newOrd] = sort(cellID);                              % order by cell ID
imgFiles   = imgFiles(newOrd);                          % sort files by cell ID


%% Define data
% If 'data' not defined or defined as 1, define data as array of ones so 
% all cells have same weight.
if ~exist('data','var') || isequal(data,1)
    data = ones(fileNum,1);
end


%% Checkpoint
% Verify number of elements in 'data' and number of cells match
if fileNum ~= numel(data)
    msgbox('Mismatch in number of cells')
    return
end


%% Create cell map
% Retrieve dimensions from first file
currFile = [imgPath '/' imgFiles{1}];                   % filename of first image
imgInfo  = imfinfo(currFile);                           % retrieve image info
imgDim   = [imgInfo.Height imgInfo.Width];              % image dimensions

% Define variables
% cellImgs = nan([imgDim fileNum]);                       % matrix for all images
coords   = zeros(fileNum,2);                            % matrix of x,y-coordinates for each cell

if toOverlay
    cellImg = nan(imgDim);                                 % matrix for final image of all cells
    for ff = 1:fileNum
        currFile         = [imgPath '/' imgFiles{ff}];      % current cell image file name
        currImg          = medfilt2(imread(currFile),filt); % load image with median filter
    %     cellImgs(:,:,ff) = currImg;                         % add image to matrix of all cells

        % Find location of cell in image and normalize intensity of cell so the
        % maximum pixel intensity value is 1
        cellIX    = currImg ~= 0; %find(currImg ~= 0);                     % index of cell's pixels in image
        cellFocus = currImg(cellIX);                        % retrieve values from just the cell in image
        cellMax   = max(currImg(:));                        % find maximum value
        cellNorm  = double(cellFocus)/double(cellMax);      % normalized image (max value equals 1)

        % Scale image of cell by 'data'
        cellImg(cellIX) = cellNorm * data(ff);             % scale image by response in food zone task

        % Calculate cell center coordinate
        s = regionprops(uint8(cellIX),currImg,'centroid');  % find centroid of cell; uint8(cellIX) labels cell as "one object"
        coords(ff,:) = s.Centroid;                          % record coordinate
    end
else
    stack = zeros([imgDim fileNum],'uint16');
    for ff = 1:fileNum
        currFile      = [imgPath '/' imgFiles{ff}];      % current cell image file name
        stack(:,:,ff) = medfilt2(imread(currFile),filt);
        
        cellIX       = stack(:,:,ff) ~= 0;
        s            = regionprops(uint8(cellIX),stack(:,:,ff),'centroid');  % find centroid of cell; uint8(cellIX) labels cell as "one object"
        coords(ff,:) = s.Centroid;                          % record coordinate
    end
    cellImg = sum(stack,3);
end