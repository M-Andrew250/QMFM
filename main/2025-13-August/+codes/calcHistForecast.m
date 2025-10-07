function calcHistForecast()
% codes.calcHistForecast() calculates historical forecasts for all model parametrizations.
%
% Usage: codes.calcHistForecast()
%
% codes.calcHistForecast loads the model, the observed and filtered data,
% and calculates historical forecasts for all model parametrizations.
% Tunes in tunes/Historical.m are applied in the calculations.
% 
% Relevant settings are:
% - opts.histForecast.range:  the range of the historical forecast exercise.
%                             In the first iteration, the forecast is
%                             calculated from the first period in this
%                             range, and so on. In each iteration, the
%                             forecast is calculated until the last period
%                             in this range, i.e. the forecast ranges are
%                             one period shorter in each iteration.
% - opts.exogvars:            the list of variables to fix during the
%                             historical forecast exercise. It must a
%                             two-dimensional strign array with three
%                             columns: the (transition) variable name in
%                             the first column, the corresponsing
%                             measurement variable name in the second, and
%                             the corresponding shock name in the last.
%
% Results are saved in opts.resultDirMat/histForecast.m; the results are:
% - dbFcast:  a T-by-n array of forecast databases; dbFcast(t, n) is the
%             forecast database starting in the the t-th period in the
%             range, using the n-th parametrizations.
% 
% See also: codes.readModel, codes.filterHistory, codes.reportHistForecast

opts    = mainSettings();
optsHF  = opts.histForecast;

codes.utils.writeMessage(mfilename + ": load model and data ...");

% Load model
tmp = codes.utils.loadResult(opts, "model");
m   = tmp.m;

% Load observed data
tmp = codes.utils.loadResult(opts, "data");
dbObs = tmp.dbObs;

% Load smoothed data (all history)
tmp = codes.utils.loadResult(opts, "filter");
dbFiltFull = tmp.dbFilt;

codes.utils.writeMessage(mfilename + ": setting historical tunes ...");

% Get variable names and comments

ynamesAll = string(get(m, "ylist"));

paramNum = length(opts.parameterNames);

% Predefine historical tune-s
ind = startsWith(ynamesAll, "tune_");
tnames = ynamesAll(ind);
for i = 1:length(tnames)
  dbObs.(tnames{i}) = Series();
end

% Evaluate to the tune function (from mainDir)
dbObs = opts.tunes.Historical(dbObs);

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
    
    codes.utils.writeMessage(mfilename + ": forecasting from %s (%2.0f/%2.0f)", ...
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

codes.utils.writeMessage(mfilename + ": saving results ...");
codes.utils.saveResult(opts, "histForecast", "dbFcast")
codes.utils.writeMessage(mfilename + ": done.");
