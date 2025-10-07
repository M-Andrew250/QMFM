function reportForecast
% codes.reportForecast() creates a report of the forecasts for all scenarios.
%
% Usage: codes.reportForecast()
%
% codes.reportForecasts loads the forecast results, and creates a PDF
% report with tables and charts of selected variables, together with the
% extended versions of the trend/gap charts, equations decompositions, and
% shock charts which are shown in the history report. The charts/tables
% show the forecasts for al scenarios.
%
% Relevant options are:
% - opts.forecast.plotRange:        range of the charts
% - opts.forecast.tableRange:       range of the tables
% - opts.forecast.highlightRange:   range of highlighted (by a backround
%                                   shadow) data points
%
% The PDF report is saved as opts.resultsDirPdf/forecastReport.pdf
% 
% See also: codes.calcForecast, codes.reportFilter,
% codes.reportCompareForecast, codes.reportForecastChangeDecomp

% -------- Setup --------

opts    = mainSettings();

% --- Load the forecast ---
tmp = codes.utils.loadResult(opts, "forecast");
m   = tmp.m;
db  = tmp.dbFcast;
dbEqDecomp  = tmp.dbEqDecomp;

% --- Rescale debt variables ---Qshare resinsrted AK Jan 4
Qshare = db.ny/(db.ny+db.ny{-1}+db.ny{-2}+db.ny{-3}); % more accurate than 1/4
db.debt_y     = db.debt_y * Qshare;
db.debt_fcy_y = db.debt_fcy_y * Qshare;
db.debt_lcy_y = db.debt_lcy_y * Qshare;

% --- Set legends ---
legends = codes.reporting.createScenarioLegend(opts);

% --- Get the range of tables and charts ---
tableRange      = opts.forecast.tableRange;
plotRange       = opts.forecast.plotRange;
highlightRange  = opts.forecast.highlightRange;
vLine           = opts.forecast.range(1) - 1;

% --- Create the report ---
reportTitle = "Forecast report";
rprt = report.new(char(reportTitle));

% -------- Forecast tables --------

rprt.section('Forecast tables');
rprt.pagebreak;

% ----- Main indicators table with percent changes -----

varNames   = [
  "pct4_cpi", "CPI, y-on-y change"
  "pct4_y",   "GDP, y-on-y change"
  "pct_i",    "Interbank rate, pct"; % ak jan 1: needs conversion back
  "pct4_s",   "Exchange rate, y-on-y change"
  "def_y",    "Deficit, % of GDP"
  "grev_y",   "Govt revenue, % of GDP"
  "gdem_y",   "Govt demand G&S % of GDP"
  "oexp_y"    "Other spending, % of GDP"
  ];

tableTitle = "Main indicators";

nextTablePage();

% ----- GDP table with yoy percent changes -----

varNames   = [
  "pct4_y",     "GDP, y-on-y change in %"
  "pct4_cons",  "Consumption, y-on-y change"
  "pct4_inv",   "Investment, y-on-y change"
  "pct4_gdem",  "Gov. dem., y-on-y change"
  "pct4_exp",   "Export, y-on-y change"
  "pct4_imp",   "Import, y-on-y change"
  ];

tableTitle = "GDP growth, y-on-y percentage changes";

nextTablePage();

% ----- GDP table with qoq percent changes -----

varNames   = [
  "pct_y",     "GDP, q-on-q change in %"
  "pct_cons",  "Consumption, q-on-q change"
  "pct_inv",   "Investment, q-on-q change"
  "pct_gdem",  "Gov. dem., q-on-q change"
  "pct_exp",   "Export, q-on-q change"
  "pct_imp",   "Import, q-on-q change"
  ];

tableTitle = "GDP growth, q-on-q change in %";

nextTablePage();

% ----- Inflation table with yoy percent changes -----

varNames   = [
  "pct4_cpi",       "Headline CPI, y-on-y change"
  "pct4_cpi_core",  "Core CPI, y-on-y change"
  "pct4_cpi_food",  "Food CPI, y-on-y change"
  "pct4_cpi_ener",  "Energy CPI, y-on-y change"
  ];

tableTitle = "CPI, y-on-y change in %";

nextTablePage();

% ----- Inflation table with qoq percent changes -----

varNames   = [
  "pct_cpi",       "Headline CPI, q-on-q change"
  "pct_cpi_core",  "Core CPI, q-on-q change"
  "pct_cpi_food",  "Food CPI, q-on-q change"
  "pct_cpi_ener",  "Energy CPI, q-on-q change"
  ];

tableTitle = "CPI, q-on-q change in %";

nextTablePage();

% ----- Fiscal indicators -----

varNames   = [
  "def_y",        "Deficit, percent of GDP"
  "def_y_str",    "Str. deficit, percent of GDP"
  "def_y_cyc",    "Cyc. deficit, percent of GDP"
  "def_y_discr",  "Discr. deficit, percent of GDP"
  "fisc_imp",     "Fiscal impulse, percent of GDP"
  ];

tableTitle = "Fiscal indicators";

nextTablePage();

% ----- Auxiliary model results -----

varNames    =  [
"def_y",      "Deficit, % of GDP"
"grants_y",   "Grants, % of GDP"
"def_fcy_y",  "Net foreign financing deficit, % of GDP"
"def_lcy_y",  "Net domestic financing deficit, % of GDP"
"debt_fcy_y", "Debt in foreign currency, % of GDP"
"debt_lcy_y", "Debt in local currency, % of GDP"
"tb_rat",     "Resource balance ratio % of GDP";
"dBP_usd",    "Net private capital flows, mln USD"
"dl_md",      "Money demand, annualized growth, in %"
"dl_py",      "log change GDP deflator (from CPI, PM)"
];
tableTitle = "Auxiliary model results";

nextTablePage();

% -------- Forecast charts --------

rprt.pagebreak;
rprt.section('Forecast charts');
rprt.pagebreak;

% ----- Main indicators -----

varNames   = [
  "d4l_cpi"
  "d4l_y"
  "i"
  "r" ; % ak added Dec 29
  "d4l_s"
  "d4l_z" ; % ak added Dec 29
  "def_y"
  ];

figureTitle = "Main indicators";

nextChartPage();

% ----- GDP, yy -----

varNames   = [
  "d4l_y"
  "d4l_cons"
  "d4l_inv"
  "d4l_gdem"
  "d4l_exp"
  "d4l_imp"
  ];

figureTitle = "GDP growth, y-on-y";

nextChartPage();

% ----- GDP, qq -----

varNames   = [
  "dl_y"
  "dl_cons"
  "dl_inv"
  "dl_gdem"
  "dl_exp"
  "dl_imp"
  ];

figureTitle = "GDP growth, q-on-q";

nextChartPage();

% ----- Inflation, yy -----

varNames   = [
  "d4l_cpi"
  "d4l_cpi_core"
  "d4l_cpi_food"
  "d4l_cpi_ener"
  ];

figureTitle = "Inflation, y-on-y";

nextChartPage();

% ----- Inflation, qq -----

varNames   = [
  "dl_cpi"
  "dl_cpi_core"
  "dl_cpi_food"
  "dl_cpi_ener"
  ];

figureTitle = "Inflation, q-on-q";

nextChartPage();

% ----- Deficit -----

varNames   = [
  "def_y"
  "def_y_str"
  "def_y_cyc"
  "def_y_discr"
  "fisc_imp"
  ];

figureTitle = "Budget deficit";

nextChartPage();

% ----- Main cyclical indicators -----

varNames   = [
  "l_y_gap"
  "l_z_gap"
  "r4_gap"
  ];

figureTitle = "Main cyclical indicators";

nextChartPage();

% ----- Cyclical indicators, GDP -----

varNames   = [
  "l_cons_gap"
  "l_inv_gap"
  "l_gdem_gap"
  "l_exp_gap"
  "l_imp_gap"
  ];

figureTitle = "GDP cyclical indicators";

nextChartPage();

% ----- External variables -----

varNames   = [
  "l_ystar_gap"
  "istar"
  "rstar_tnd"
  "d4l_cpistar" ; % ak add dec 29
  "d4l_foodstar"
  "l_rp_foodstar_gap"
  "d4l_enerstar"
  "l_rp_enerstar_gap"
  ];

figureTitle = "External variables";

nextChartPage();

% -------- Trends and gaps --------
    
rprt = codes.reporting.addTrendsAndGaps(opts, rprt, m, db, plotRange, legends, "forecast");
   
% -------- Decompositions of equations --------

rprt = codes.reporting.addDecompCharts(opts, rprt, m, dbEqDecomp, plotRange, legends, highlightRange);
  
rprt = codes.reporting.addDecompTables(opts, rprt, m, dbEqDecomp, tableRange, legends, vLine);

% -------- Shocks --------

% --- Shock charts ---

varNames      = string(get(m, "eList"));
figureTitle   = "Shocks";

rprt = codes.reporting.addVariableCharts(opts, rprt, m, db, plotRange, ...
  varNames, figureTitle, legends, highlightRange);

% --- Shock table ---

shockNames  = string(get(m, "eList"))';
varNames    = [shockNames, shockNames];
tableTitle  = "Shocks";

rprt = codes.reporting.addTablePage(opts, rprt, m, db, tableRange, varNames, tableTitle, ...
  legends, vLine);

% ------- Publish report --------

codes.utils.writeMessage(mfilename + ": compiling the forecast report ...");
codes.utils.saveReport(opts, "forecastReport", rprt);
codes.utils.writeMessage(mfilename + ": done.");

% ------- Subfunctions --------

  function nextTablePage

   rprt = codes.reporting.addTablePage(opts, rprt, m, db, tableRange, varNames, ...
     tableTitle, legends, vLine); 

  end

  function nextChartPage
  
    rprt = codes.reporting.addChartPage(opts, rprt, m, db, plotRange, varNames, ...
      figureTitle, legends, highlightRange);

  end

end