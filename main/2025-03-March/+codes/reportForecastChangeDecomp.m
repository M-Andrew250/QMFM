function reportForecastChangeDecomp
% codes.reportForecastChangeDecomp() analyses the difference between the current and previous baseline forecasts scenarios.
%
% Usage: codes.reportForecastChangeDecomp()
% 
% codes.reportForecastChangeDecomp loads the forecast results of the
% current and comparison rounds, and decomposes the difference of the
% forecasts into the effect of a) model change, b) initial condition
% change, and c) tune (i.e. shock) change. The latter is further decomposed
% in to the contribution of individual shocks. The decompositions are shown
% in a PDF report.
% 
% The PDF report is saved as opts.resultsDirPdf/forecastChangeDecompReport.pdf
% 
% The contribution are also saved in opts.resultsDirMat/forecastChangeDecomp.mat
% The saved results are:
% - dbPPP: the previous forecast
% - dbCPP:    the forecast with current model/previous initial conditions/preivous shocks
% - dbCCP:    the forecast with current model/current initial conditions/preivous shocks
% - dbCCPc:   the forecast with current model/current initial conditions/current shocks
%             The shocks are added one-by-one, and the i-th column of dbCCPc shows
%             the cumulative effect of using the first i current shocks.
% - dbCCC:    the current forecast
%
% See also: codes.calcForecast, codes.reportFilter,
% codes.reportCompareForecast, codes.reportForecastChangeDecomp

% ------------- Setup -------------

optsCurr  = mainSettings();
optsPrev  = optsCurr.compOpts;

% ------------- Load the forecast results -------------

% -------- Current forecast --------

tmp = codes.utils.loadResult(optsCurr, "forecast");
mCurr         = tmp.m(1);
dbInitCurr    = tmp.dbInit;
dbFcastCurr   = dbcol(tmp.dbFcast, 1);
rngCurr       = optsCurr.forecast.range;

% -------- Previous forecast --------

tmp = codes.utils.loadResult(optsPrev, "forecast");
mPrev         = tmp.m(1);
dbInitPrev    = tmp.dbInit;
dbFcastPrev   = dbcol(tmp.dbFcast, 1);
rngPrev       = optsPrev.forecast.range;

% ------------- Decompose the difference into model/initial/shock contributions -------------

% -------- Collect initial conditions and shocks --------

[~,~,dbInitPrev] = databank.filter(dbInitPrev, "Name", get(mPrev, "xList"));
[~,~,dbInitCurr] = databank.filter(dbInitCurr, "Name", get(mCurr, "xList"));

[~,~,dbShockPrev] = databank.filter(dbFcastPrev, "Name", get(mPrev, "eList"));
[~,~,dbShockCurr] = databank.filter(dbFcastCurr, "Name", get(mCurr, "eList"));

% -------- Step 0: current model / previous init / previous shocks --------

dbPPP = dbFcastPrev;

% -------- Step 1: current model / previous init / previous shocks --------

dbInit = databank.merge("horzcat", dbInitPrev, dbShockPrev, ...
  "missingField", Series([],[]));

dbCPP = simulate(mCurr, dbInit, rngPrev, ...
  "prependInput", true, "method", "firstOrder");

% -------- Step 2: current model / current init / previous shocks --------

dbInit = databank.merge("horzcat", dbInitCurr, dbShockPrev, ...
  "missingField", Series([],[]));

dbCCP = simulate(mCurr, dbInit, rngCurr, ...
  "prependInput", true, "method", "firstOrder");

% -------- Step 3: current model / current init / current shocks --------

dbInit = databank.merge("horzcat", dbInitCurr, dbShockPrev, ...
  "missingField", Series([],[]));

eNames = string(fieldnames(dbShockCurr));

dbCCPc = dbCCP;

for en = eNames(:)'
  codes.utils.writeMessage(mfilename + ": calculating the effect of %s ...", en);
  dbInit.(en) = dbShockCurr.(en);
  dbSim = simulate(mCurr, dbInit, rngCurr, ...
    "prependInput", true, "method", "firstOrder");
  dbCCPc = databank.merge("horzcat", dbCCPc, dbSim);
end

% -------- Step 4: current model / current init / current shocks --------

dbCCC = dbFcastCurr;

% ------------- Create the report -------------

% -------- Create the report object --------

reportTitle = "Forecast change decomposition report";
rprt = report.new(char(reportTitle));

% -------- Add decomposition charts --------

varNames = [
  "l_cons_gap"
  "dl_cpi_core"
  "i"
  "l_s"
  ];

for vn = varNames(:)'

  rprt.figure(char(vn), 'style', optsCurr.style, 'subplot', [2, 1]);

  rprt.graph('Model and initial conditions change', 'range', rngCurr, ...
    'legend', true, 'legendLocation', 'southOutside', ...
    'legendOrientation', 'horizontal');

  rprt.series('Previous forecast', dbPPP.(vn));
  rprt.series('Model change', dbCPP.(vn));
  rprt.series('Model change/current initial conditions', dbCCP.(vn));
  rprt.series('Current forecast', dbCCC.(vn));

  contrAll = dbCCPc.(vn){:,2:end} - dbCCPc.(vn){:,1:end-1};

  maxContr = max(abs(contrAll));
  [~, ind] = sort(maxContr, "descend");
  ind = ind(1:6);
  contrLarge = contrAll{:, ind};
  contrRest = contrAll(:,:);
  contrRest(:,ind) = [];
  contrRest = Series(contrAll.Range, sum(contrRest, 2));
  contr = [contrLarge, contrRest];

  legendEntries = replace([eNames(ind)', "Rest"], "_", "\_");

  rprt.graph('Tunes change', 'range', rngCurr, ...
    'legend', true, 'legendLocation', 'southOutside', ...
    'legendOrientation', 'horizontal');

  rprt.series('', contr, 'plotFunc', @barcon, 'legendEntry', cellstr(legendEntries));

end

% -------- Publish report --------

codes.utils.writeMessage(mfilename + ": compiling the report ...");
codes.utils.saveReport(optsCurr, "forecastChangeDecompReport", rprt);

% -------- Save results to mat file --------

codes.utils.saveResult(optsCurr, "forecastChangeDecomp", "dbPPP", "dbCPP", ...
  "dbCCP", "dbCCPc", "dbCCC")
codes.utils.writeMessage(mfilename + ": done.");

end 