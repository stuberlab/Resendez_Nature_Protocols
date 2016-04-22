function [refMatch,pairD] = pair(ref,X,maxDist)
%Pair points from X with ref (reference map) by nearest neighbor under set distance
% 
% Find nearest neighbor of each point in X from ref. If any point in ref is
% paired to multiple points in X, find closest pair and reassign other
% points in X to unpaired points in ref.


%% Parameters



%% Setup



%% Find distances between all pairs
xNum   = length(X);                     % number of points in X
refNum = length(ref);                   % number of points in Y

dists      = pdist2(ref,X);             % distance between each point in ref to each point in X
bad        = dists > maxDist;           % distances too large
dists(bad) = NaN;                       % "remove" distances too large

% dists = bsxfun(@plus,dot(X,X,1)',dot(Y,Y,1))-2*(X'*Y);  % alternate method


%% Find matches
refMatch = zeros(xNum,1);               % initialize array for matches to reference
pairD    = zeros(xNum,1);               % initialize array to record pair distances

while any(isfinite(dists(:)))
    [pairDMin, ...                      % distances from every X to closest ref
     refPairs  ] = min(dists);          % index of ref pt closest to each x in X
    [Dmin, ...                          % shortest pair distance
     XPair]      = min(pairDMin);       % index of X pt with closest X-ref pairing
    refPair      = refPairs(XPair);     % index of ref pt of closest X-ref pairing
    
    refMatch(XPair)  = refPair;         % record match
    pairD(XPair)     = Dmin;            % record pair distance
    dists(refPair,:) = NaN;             % "remove" matched ref pt from dists (so it cannot be paired to another X)
    dists(:,XPair)   = NaN;             % "remove" matched X pt from dists (so it cannot be paired again)
end

noMatch = refMatch == 0;
noMNum  = sum(noMatch);
newIDs  = refNum + (1:noMNum);

refMatch(noMatch) = newIDs;