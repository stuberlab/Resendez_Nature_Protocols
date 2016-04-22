function [events,imgTS] = collectEvents(evPath)

if ~exist('path','var')
    evPath = [uigetdir('D:\Dropbox (Stuber Lab)\data for Randall','Select events directory') '/'];
end
evFiles = dir([evPath '*event*.txt']);              % retrieve files containing "Events" in name
evFiles = {evFiles.name}';                          % name of cells (c arry of text)
cellNum = length(evFiles);                          % number of cells (dbl)

data    = importdata([evPath evFiles{1}]);          % load sample data to find number of time points
pts     = size(data,1);                             % number of time points
events  = zeros(pts,cellNum);                       % matrix of events data for each cell
eventID = zeros(cellNum,1);                         % array of cell ID numbers

for cc = 1:cellNum
    data         = importdata([evPath evFiles{cc}]);% load each event file
    events(:,cc) = data(:,2);                       % save into 'events' matrix
    
    num = regexp(evFiles{cc},'\d');                 % retrieve cell number assigned from file name
    if any(num)
        eventID(cc) = str2double(evFiles{cc}(num)); % convert to dbl and save
    else
        eventID(cc) = 0;                            % file without number assigned will rank first (0)
    end
end

[~,newOrd] = sort(eventID);                         % determine order
events     = events(:,newOrd);                      % rearrange

imgTS = data(:,1);                                  % retrieve timestamps