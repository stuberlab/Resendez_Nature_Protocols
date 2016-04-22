function [binned,trim] = binData(data,imgTS)
%Sorts timestamps into defined time bins.
% 
% Bins timestamps in 'data' into bins defined by 'imgTS'. Assumes 
% 'imgTS' timestamps mark end of frame.
% 
% Inputs
%  data:    Array of timestamps to be binned.
%  ref:     Array of timestamps corresponding to bins for data
% 
% Outputs
%  binned:  Data binned by 'imgTS'.
%  trim:    Logical index of timestamps in 'data' within scope of 'imgTS'.
% 


% Calculate average length of 'imgTS' bins
binT = mean(diff(imgTS));

% Trim data outside scope of 'imgTS'
lbnd     = imgTS(1) - binT;         % lowest time captured by first frame
ubnd     = imgTS(end);              % highest time captured by last frame
trim     = data >= lbnd & ...
           data < ubnd;             % data within imaging timestamps
dataTrim = data(trim);              % get data within imaging

% Bin data
centers = imgTS - binT/2;           % calculate bin centers
binned  = hist(dataTrim,centers);   % bin data
binned  = reshape(binned,[],1);     % make it a column vector. NOT SURE WHY I PUT THIS HERE