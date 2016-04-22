function dataBin = sdPrep(h)
%Formats data to be analyzed.
% imgTS
% data
% names

IX      = find(~h.binnedIX);            % numerical index of variables to be binned
dataNum = sum(~h.binnedIX);             % number of data variables to be binned
ptNum   = length(h.imgTS);              % number of time points

dataBin = zeros(ptNum,dataNum);         % matrix of binned data
for dd = 1:dataNum
    dataBin(:,dd) = binData(h.raw{IX(dd)}, ...
                            h.imgTS);
end