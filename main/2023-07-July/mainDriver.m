%% Setup

tic;

close all

opts = mainSettings();

%% Read model

if opts.readModel.run
  codes.readModel()
end

%% Read and transform data

if opts.readData.run
  codes.readData()
end 

%% Run historical filtration

if opts.filterHistory.run
  codes.filterHistory()
end

%% Report model properties

if opts.reportModel.run
  codes.reportModel()
end

%% Report filtration

if opts.reportHistory.run
  codes.reportHistory()
end

%% Calculate historical forecasts

if opts.calcHistForecast.run
  codes.calcHistForecast()
end

%% Report historical forecasts

if opts.reportHistForecast.run
  codes.reportHistForecast()
end

%% Calculate forecast

if opts.calcForecast.run
  codes.calcForecast()
end

%% Report forecast

if opts.reportForecast.run
  codes.reportForecast()
end

%% Finish off

fprintf("mainDriver.m finished at %s\nElapsed time: %0.2f seconds.\n", datestr(now), toc)
 