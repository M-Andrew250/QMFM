function calcHistForecast()

opts    = mainSettings();
optsHF  = opts.histForecast;

codes.writeMessage('calcHistForecast: load model and data ...');

% Load model
tmp = codes.loadResult(opts, "model");
m   = tmp.m;

% Load observed data
tmp = codes.loadResult(opts, "data");
dbObs = tmp.dbObs;

% Load smoothed data (all history)
tmp = codes.loadResult(opts, "filter");
dbFiltFull = tmp.dbFilt;

codes.writeMessage("calcHistForecast: setting historical tunes ...");

% Get variable names and comments

ynamesAll = string(get(m, "ylist"));

paramNum = length(opts.parameterNames);

% Predefine historical tune-s
ind = startsWith(ynamesAll, "tune_");
tnames = ynamesAll(ind);
for i = 1:length(tnames)
  dbObs.(tnames{i}) = Series();
end

% Set historical tunes
cd(fullfile(opts.mainDir, "tunes"))
dbObs = Historical(dbObs);
cd(opts.mainDir)

for n = 1:paramNum
  
  tunes = struct();
  
  % Tune for history/forecast
  
  for i = 1:length(optsHF.exogvars)
    
    exogName  = optsHF.exogvars(i,1);
    obsName   = optsHF.exogvars(i,2);
    
    if startsWith(obsName, "obs_")
      tunes.(exogName) = dbObs.(obsName);
    elseif startsWith(obsName, "tune_")
      tunes.(obsName)   = dbFiltFull.mean.(exogName){:,n}; % For history
      tunes.(exogName)  = dbFiltFull.mean.(exogName){:,n}; % For forecast
    end
    
%     if isfield(dbObs, obsName) % Observations in observed data, call the 'tune_..'
%       tunes.(exogName) = dbObs.(obsName);
%     else % Use full-sample historical filtration for unobserved
%       if obsName ~= ""
%         tunes.("tune_" + exogName) = dbFiltFull.mean.(exogName){:,n}; % For history
%       end
%       tunes.(exogName) = dbFiltFull.mean.(exogName){:,n}; % For forecast
%     end
    
  end
  
  dbObs = dboverlay(dbObs, tunes);
  
%   % Index of exogenized variables in the forecast
%   indExog = optsHF.exogvars(:,3) ~= "";
%   
%   maxLastFcast = databank.range(tunes, "endDate", "minRange");
%   maxLastFcast = maxLastFcast(end);
%   
%   if maxLastFcast <= optsHF.range(end)
%     optsHF.range = optsHF.range(1) : min(optsHF.range(end), maxLastFcast);  
%     warning("The historical forecast range has been trancated to %s : %s", ...
%       dat2char(optsHF.range(1)), dat2char(optsHF.range(end)))
%   end
  
  nper = length(optsHF.range);
  
  cntr = 0;
  for t = 1:length(optsHF.range)
        
    cntr = cntr+1;
    
    codes.writeMessage(...
      "calcHistForecast: forecasting from %s (%2.0f/%2.0f)", ...
      dat2char(optsHF.range(t)), cntr, nper ...
      );
    
    % Set ranges
    firstHist   = opts.filterHistory.range(1);
    lastHist    = optsHF.range(t) - 1;
    lastFcast   = optsHF.range(end);
    
    smootherRange   = firstHist : lastHist;
    forecastRange   = lastHist + 1 : lastFcast;
    
    % Run smoother
    [~, dbFilt] = filter(m(n), dbObs, smootherRange, 'relative', false);
    
    % Add exogens
    dbInit = dbFilt.mean;
    dbInit = dboverlay(dbInit, tunes);
    
    % Exogenize
    pln = Plan(m(n), forecastRange);
    %     pln =  exogenize(pln, forecastRange, optsHF.exogvars(indExog,1));
    %     pln = endogenize(pln, forecastRange, optsHF.exogvars(indExog,3));
    pln =  exogenize(pln, forecastRange, optsHF.exogvars(:,1));
    pln = endogenize(pln, forecastRange, optsHF.exogvars(:,3));
    
    % Run the forecast
    tmp = simulate(m(n), dbInit, forecastRange, 'Plan', pln);
    tmp = dboverlay(dbInit, tmp); 
    dbFcast(t, n) = dbclip(tmp, forecastRange(1)-1 : forecastRange(end)); %#ok<AGROW>
    
  end
  
end

% Save results

codes.writeMessage("calcHistForecast: saving results ...");

fileName = fullfile(opts.mainDir, "results", "histForecast.mat");
save(fileName, "dbFcast")

codes.writeMessage("calcHistForecast: done.");
