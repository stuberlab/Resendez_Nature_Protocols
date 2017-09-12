function neighbors(X,Y)
%Finds distances between cells of TWO different sessions.
% X & Y are optionally defined.



%% Parameters
binSz = 1;


%% Data
% Prompt for files with coordinate data if not defined when function
% called.

if ~exist('X','var')
    [fName,pName] = uigetfile('*.mat', ...
                              'Select coordinate data (2 files)', ...
                              'MultiSelect','on');      % prompt user for files
    X = load([pName fName{1}],'coordinates');           % load data from first file into structure
    X = X.coordinates;                                  % save coordinate data
    Y = load([pName fName{2}],'coordinates');           % load data from second file into structure
    Y = Y.coordinates;                                  % save coordinate data
end


%% Distances within
% For each point in each set, find distance to nearest point from within
% same set (excluding self).

[~,dX] = knnsearch(X,X,'k',2);      % find nearest neighbor for points within X
[~,dY] = knnsearch(Y,Y,'k',2);      % find nearest neighbor for points within X
dWI    = [dX(:,2);dY(:,2)];         % compile data - ignore first column (pairing with self)
% fprintf('Distances within min: %d\n', ...
%         min(dWI))                   % print minimum distance to command window


%% Distances between
% For each point in each set, find distance to nearest point from other
% set.

[~,d1] = knnsearch(X,Y);            % find nearest neighbor from X for all points in Y
[~,d2] = knnsearch(Y,X);            % find nearest neighbor from Y for all points in X
dBW    = [d1;d2];                   % compile data
% fprintf('Distances between min: %d', ...
%         min(dBW))                   % print minimum distance to command window


%% Plot
figure
ctr = (0:binSz:max([dWI;dBW])) + binSz/2;   % define center points for bins

subplot(1,2,1)
hist(dBW,ctr)
title('Nearest neighbor distances BETWEEN sessions')

subplot(1,2,2)
hist(dWI,ctr)
title('Nearest neighbor distances WITHIN sessions')