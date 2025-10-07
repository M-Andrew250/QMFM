
% Setup

clear, close all

% load data
opts = mainSettings();
tmp = codes.utils.loadResult(opts, "data");

%tmp = load('results\data.mat');
%db = tmp.dbObsTrans;

% load model
tmp = codes.utils.loadResult(opts, "model");
%tmp = load('results\model.mat');
m = tmp.m;

% load forecast results
tmp = codes.utils.loadResult(opts, "forecast");
%tmp = load('results\forecast.mat');
dbFcast = tmp.dbFcast;

% Assuming the you have the model object m in your workspace, and you want
% to two-year-ahead confidence interval(8 stand for 8 quarters made up 2
% years.
opts = mainSettings;
[X, Y, List, A, B] = fevd(m, opts.forecast.range);

% all return will be saved in database x with the contribution of each shock 
%to the forecast uncertainty of each model variable.we do insert variabe we
%want to see its forecast errors. here we used CPI headline

fcVarContrAbs = A.dl_cpi{:,:,1};
shockNames = comment(fcVarContrAbs);

%since we're after the overall confidence interval, so we have to sum the contributions, 
%which we do by

fcVar = sum(fcVarContrAbs, 2);

%This returns the variance of forecast error; but for the confidence interval 
%we need the standard deviation

fcStd = sqrt(fcVar);

% Get the mean forecast

fcMean = dbFcast.dl_cpi;

% Display the mean and 1-std confidence interval

% disp([fcMean - fcStd, fcMean, fcMean + fcStd])

% Display contribution std-contribution of important shocks

nContr = 10;

% Select important shocks based on contribution in the first period

firstContr = fcVarContrAbs{opts.forecast.range(1), :};
[~, ind] = sort(firstContr, 'max');

fcVarContrRel = B.d4l_cpi{:,:,1};
% disp([fcVarContrAbs{:, ind(1:nContr)}, sum(fcVarContrRel{:, ind(1:nContr)}, 2)])
% disp(shockNames(ind(1:nContr))')

% Select important shocks based on average contribution over the forecast
% horizon

% firstContr = fcVarContrAbs{opts.forecast.range(1), :};
[~, ind] = sort(fcVarContrRel, 'sumabs');

fcVarContrRel = B.d4l_cpi{:,:,1};
% disp([fcVarContrAbs{:, ind(1:nContr)}, sum(fcVarContrRel{:, ind(1:nContr)}, 2)])
% disp(shockNames(ind(1:nContr))')

% Draw a fan chart

plotRange = qq(2006,1) : opts.forecast.range(end);

prob = [0.3, 0.6, 0.9]; % 0.1 : 0.1 : 0.9;

codes.utils.fanchart(plotRange, fcMean, fcStd, prob)
