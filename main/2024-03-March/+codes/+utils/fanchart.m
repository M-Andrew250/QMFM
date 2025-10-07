function fanchart(plotRange, fcMean, fcStd, prob)

% ----- Calulcate ranges -----

fcastRange  = fcStd.Range;
lastHist    = fcastRange(1)-1;
histRange   = plotRange(1) : lastHist;

% ----- Get mean forcast and actual historical observation ----- 

actual = fcMean{histRange};
fcMean = fcMean{fcastRange};

% ----- Define the colors of the bands -----

nBands = numel(prob);

bandColors = zeros(nBands, 3);
for i = 1 : nBands
  bandColors(i,:) = [1, 1, 1] - i/(2*nBands-1);
end
bandColors = [bandColors; flipud(bandColors)];

% ----- Calculate the bands corresponding to the given probabilities (i.e.
% percentiles) -----

prob = sort(prob);

prctLow   = fcMean + fcStd * sqrt(2) * erfinv(-prob);
prctHigh  = fcMean + fcStd * sqrt(2) * erfinv(prob);

edges = [prctLow{:, end:-1:1}, prctHigh];
edges(lastHist,:) = actual(lastHist);

% ----- Create the fan chart -----

baseValue = floor(min(min(edges)));

for i = 2*numel(prob) : -1 : 1
  area(plotRange, edges{:, i}, "baseValue", baseValue, ...
    "faceColor", bandColors(i,:), ...
    "edgeColor", "none", ...
    "showBaseLine", false);
  hold on
end

area(plotRange, edges{:, 1}, "baseValue", baseValue, ...
  "faceColor", "w", ...
  "edgeColor", "none", ...
  "showBaseLine", false);

plot(actual, "k", "lineWidth", 2);

grid on

set(gca, "layer", "top")

end