function reportCompareForecast

optsCurr  = mainSettings();
optsPrev  = optsCurr.compOpts;
optsFR    = optsCurr.forecastReport;

% Load the current forecast
tmp = codes.utils.loadResult(optsCurr, "forecast");
m   = tmp.m;
dbCurr  = tmp.dbFcast;
% dbDecomp  = tmp.dbDecomp;

% Keep only the first column (maybe select by scenario name??)
dbCurr = databank.retrieveColumns(dbCurr,1);

% Load the compared forecast
tmp = codes.utils.loadResult(optsPrev, "forecast");
dbComp  = tmp.dbFcast;
% dbDecompc  = tmp.dbDecomp;

% Merge the current and compare databases
dbCompFcast = databank.merge("horzcat", dbCurr, dbComp, ...
  "missingField", NaN);

% Rescale debt variables
Qshare = dbCompFcast.ny/ (dbCompFcast.ny + dbCompFcast.ny{-1} + dbCompFcast.ny{-2} + dbCompFcast.ny{-3}); %more accurate than 1/4
dbCompFcast.debt_y     = dbCompFcast.debt_y * Qshare;
dbCompFcast.debt_fcy_y = dbCompFcast.debt_fcy_y * Qshare;
dbCompFcast.debt_lcy_y = dbCompFcast.debt_lcy_y * Qshare;
% dbCompFcast.debt_y     = dbCompFcast.debt_y / 4;
% dbCompFcast.debt_fcy_y = dbCompFcast.debt_fcy_y / 4;
% dbCompFcast.debt_lcy_y = dbCompFcast.debt_lcy_y / 4;

legends = [optsCurr.roundId, optsCurr.compRound];

% Create the report
reportTitle = "Forecast report";
rprt = report.new(char(reportTitle));

%%%%%%%%%%%%% Tables %%%%%%%%%%%%%

rprt.section('Forecast tables');
rprt.pagebreak;

% Main indicators table with percent changes

varNames   = [
  "pct4_cpi", "CPI, y-on-y change"
  "pct4_y",   "GDP, y-on-y change"
  "pct_i",    "Interbank rate, pct"; % ak jan 1: needs conversion back
  "pct4_s",   "Exchange rate, y-on-y change"
  "def_y",    "Deficit, pct. of GDP"
  ];

tableTitle = "Main indicators";

rprt = codes.reporting.addTablePage(optsCurr, rprt, m, dbCompFcast, varNames, tableTitle, legends);

% GDP table with yoy percent changes

varNames   = [
  "pct4_y",     "GDP, y-on-y change in %"
  "pct4_cons",  "Consumption, y-on-y change"
  "pct4_inv",   "Investment, y-on-y change"
  "pct4_gdem",  "Gov. dem., y-on-y change"
  "pct4_exp",   "Export, y-on-y change"
  "pct4_imp",   "Import, y-on-y change"
  ];

tableTitle = "GDP growth, y-on-y percentage changes";

rprt = codes.reporting.addTablePage(optsCurr, rprt, m, dbCompFcast, varNames, tableTitle, legends);

% GDP table with qoq percent changes

varNames   = [
  "pct_y",     "GDP, q-on-q change in %"
  "pct_cons",  "Consumption, q-on-q change"
  "pct_inv",   "Investment, q-on-q change"
  "pct_gdem",  "Gov. dem., q-on-q change"
  "pct_exp",   "Export, q-on-q change"
  "pct_imp",   "Import, q-on-q change"
  ];

tableTitle = "GDP growth, q-on-q change in %";

rprt = codes.reporting.addTablePage(optsCurr, rprt, m, dbCompFcast, varNames, tableTitle, legends);

% Inflation table with yoy percent changes

varNames   = [
  "pct4_cpi",       "Headline CPI, y-on-y change"
  "pct4_cpi_core",  "Core CPI, y-on-y change"
  "pct4_cpi_food",  "Food CPI, y-on-y change"
  "pct4_cpi_ener",  "Energy CPI, y-on-y change"
  ];

tableTitle = "CPI, y-on-y change in %";

rprt = codes.reporting.addTablePage(optsCurr, rprt, m, dbCompFcast, varNames, tableTitle, legends);

% Inflation table with qoq percent changes

varNames   = [
  "pct_cpi",       "Headline CPI, q-on-q change"
  "pct_cpi_core",  "Core CPI, q-on-q change"
  "pct_cpi_food",  "Food CPI, q-on-q change"
  "pct_cpi_ener",  "Energy CPI, q-on-q change"
  ];

tableTitle = "CPI, q-on-q change in %";

rprt = codes.reporting.addTablePage(optsCurr, rprt, m, dbCompFcast, varNames, tableTitle, legends);

% Fiscal indicators

varNames   = [
  "def_y",        "Deficit, percent of GDP"
  "def_y_str",    "Str. deficit, percent of GDP"
  "def_y_cyc",    "Cyc. deficit, percent of GDP"
  "def_y_discr",  "Discr. deficit, percent of GDP"
  "gdem_y", "Govt. demand (G&S), % GDP"          
  "oexp_y",       "Other govt. exp., % to GDP"        
  "fisc_imp",     "Fiscal impulse, percent of GDP"
  ];

tableTitle = "Fiscal indicators";

rprt = codes.reporting.addTablePage(optsCurr, rprt, m, dbCompFcast, varNames, tableTitle, legends);


% Auxiliary model results

varNames    =  [
"def_y",      "Deficit, % of GDP"
"grants_y",   "Grants, % of GDP"
"def_fcy_y",  "Deficit in foreign currency, % of GDP"
"def_lcy_y",  "Deficit in local currency, % of GDP"
"debt_fcy_y", "Debt in foreign currency, % of GDP"
"debt_lcy_y", "Debt in local currency, % of GDP"
"tb_rat",     "Resource balance ratio % of GDP";
"dBP_usd",    "Net private capital flows mln USD"
"dl_md",      "Money demand, annualized growth in %"
"dl_py",      "log change GDP deflator (from CPI, PM)"
];
tableTitle = "Auxiliary model results";

rprt = codes.reporting.addTablePage(optsCurr, rprt, m, dbCompFcast, varNames, tableTitle, legends);

%%%%%%%%%%%%% Charts %%%%%%%%%%%%%

rprt.pagebreak;
rprt.section('Forecast charts');
rprt.pagebreak;

% Main indicators

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

rprt = codes.reporting.addPage(optsCurr, rprt, m, dbCompFcast, varNames, figureTitle, legends);

% GDP, yy

varNames   = [
  "d4l_y"
  "d4l_cons"
  "d4l_inv"
  "d4l_gdem"
  "d4l_exp"
  "d4l_imp"
  ];

figureTitle = "GDP growth, y-on-y";

rprt = codes.reporting.addPage(optsCurr, rprt, m, dbCompFcast, varNames, figureTitle, legends);

% GDP, qq

varNames   = [
  "dl_y"
  "dl_cons"
  "dl_inv"
  "dl_gdem"
  "dl_exp"
  "dl_imp"
  ];

figureTitle = "GDP growth, q-on-q";

rprt = codes.reporting.addPage(optsCurr, rprt, m, dbCompFcast, varNames, figureTitle, legends);

% Inflation, yy

varNames   = [
  "d4l_cpi"
  "d4l_cpi_core"
  "d4l_cpi_food"
  "d4l_cpi_ener"
  ];

figureTitle = "Inflation, y-on-y";

rprt = codes.reporting.addPage(optsCurr, rprt, m, dbCompFcast, varNames, figureTitle, legends);

% Inflation, qq

varNames   = [
  "dl_cpi"
  "dl_cpi_core"
  "dl_cpi_food"
  "dl_cpi_ener"
  ];

figureTitle = "Inflation, q-on-q";

rprt = codes.reporting.addPage(optsCurr, rprt, m, dbCompFcast, varNames, figureTitle, legends);

% Deficit

varNames   = [
  "def_y"
  "def_y_str"
  "def_y_cyc"
  "def_y_discr"
  "fisc_imp"
  ];

figureTitle = "Budget deficit";

rprt = codes.reporting.addPage(optsCurr, rprt, m, dbCompFcast, varNames, figureTitle, legends);

% Main cyclical indicators

varNames   = [
  "l_y_gap"
  "l_z_gap"
  "r4_gap"
  ];

figureTitle = "Main cyclical indicators";

rprt = codes.reporting.addPage(optsCurr, rprt, m, dbCompFcast, varNames, figureTitle, legends);

% Cyclical indicators, GDP

varNames   = [
  "l_cons_gap"
  "l_inv_gap"
  "l_gdem_gap"
  "l_exp_gap"
  "l_imp_gap"
  ];

figureTitle = "GDP cyclical indicators";

rprt = codes.reporting.addPage(optsCurr, rprt, m, dbCompFcast, varNames, figureTitle, legends);

% External variables

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

rprt = codes.reporting.addPage(optsCurr, rprt, m, dbCompFcast, varNames, figureTitle, legends);

%%%%%%%%%%%%% Trends and gaps %%%%%%%%%%%%%
    
rprt = codes.reporting.addTrendsAndGaps(optsCurr, rprt, m, dbCompFcast, dbCompFcast, optsFR.plotRange, legends, ...
  "forecast");
   
%%%%%%%%%%%%% Decompositions of equations %%%%%%%%%%%%%

% rprt = codes.reporting.addDecompCharts(opts, rprt, m, dbDecomp, optsFR.plotRange, legends, "forecast");
  
% rprt = codes.reporting.addDecompTables(opts, rprt, m, dbDecomp, optsFR.tableRange, legends);

%%%%%%%%%%%%% Shocks %%%%%%%%%%%%%

rprt = codes.reporting.addShocks(optsCurr, rprt, m, dbCompFcast, optsFR.plotRange, legends, "forecast");

shockNames = string(get(m, "eList"))'; 
varNames = [shockNames, shockNames];

tableTitle = "Shocks";

rprt = codes.reporting.addTablePage(optsCurr, rprt, m, dbCompFcast, varNames, tableTitle, legends);

% Publish report

codes.utils.writeMessage(mfilename + ": compiling the forecast report ...");
codes.utils.saveResult(optsCurr, "forecastCompare", "dbCompFcast");

% ------------- Save the merged database -------------

codes.utils.writeMessage(mfilename + ": saving results ...");
codes.utils.saveReport(optsCurr, "forecastCompareReport", rprt);
codes.utils.writeMessage(mfilename + ": done.");

end