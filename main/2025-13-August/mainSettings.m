function opts = mainSettings

% To do:
% - improve tables in the histforecast report (parametrizations in the same
%   table)

%% General options

opts.roundId        = "2025 Sept Forecast";
opts.modelFile      = "minecofin";
opts.mainDataFile   = "2025-18-09"; % name of data/Rwametric file 
opts.addDataFile    = "2025-09-15"; % has CBO proj RIR-US and old GTM numbers
opts.compRound      = "main/2025-03-March"; % comparison round

opts.resultsOutside = 0;

%% Name of the parameters; 

% opts.parameterNames   = "setparamOrig";
% opts.parameterLegends = "Original";

opts.parameterNames   = ["setparam"];%, "setparamOrig"];
opts.parameterLegends = ["Nov'24 recalibrated"];%, "Sept'24 Original"];

%% Actions to run

% If 'true' or =1 , the whole program runs

opts.readModel.run                    = 1;

opts.readData.run                     = 1;

opts.filterHistory.run                = 1;

opts.reportModel.run                  = 1;
opts.reportModel.steady.run           = 1;
opts.reportModel.IRF.run              = 1;
opts.reportModel.varDecomp.run        = 1;
opts.reportModel.stdComp.run          = 1;
opts.reportModel.equations.run        = 1;

opts.reportHistory.run                = 1;
opts.reportHistory.obs.run            = 1;
opts.reportHistory.trends.run         = 1;
opts.reportHistory.eqDecomps.run      = 1;
opts.reportHistory.shockDecomps.run   = 1;
opts.reportHistory.shocks.run         = 1;

opts.calcHistForecast.run             = 0;

opts.reportHistForecast.run           = 0;

opts.calcForecast.run                 = 1;

opts.reportForecast.run               = 0;

opts.reportCompareData.run            = 1;

opts.reportCompareForecast.run        = 0;

opts.reportForecastChangeDecomp.run   = 0;

%% Steady state report

opts.reportModel.steady.variables = [
  "l_cons_gap"
  "l_inv_gap"
  "l_gdem_gap"
  "l_exp_gap"
  "l_y_gap"
  "l_z_gap"
  "r_gap"
  "rmc"
  "def_y"
  "def_y_str"
  "def_y_discr"
  "grants_y"
  "l_rp_cpi_core_gap"
  "l_rp_cpi_food_gap"
  "l_rp_cpi_ener_gap"
  "prem_d_gap"
  "d4l_cpi_tar"
  "dl_cpi"
  "dl_cpi_core"
  "dl_cpi_food"
  "dl_cpi_ener"
  "i"
  "i_tnd"
  "r"
  "r_tnd"
  "dl_rp_cpi_core_tnd"
  "dl_rp_cpi_food_tnd"
  "dl_rp_cpi_ener_tnd"
  ];

%% IRF options

% Length of IRF
opts.reportModel.IRF.horizon    = 24;

% List of the shocks. If it is set to @all, all of them will be in the report
opts.reportModel.IRF.shocks     = [
  "shock_l_cons_gap"
  "shock_l_inv_gap"
  "shock_l_exp_gap"
  "shock_dl_cpi_core"
  "shock_i"
  "shock_l_s"
  "shock_grev_y_discr"
  "shock_gdem_y_discr"
  "shock_oexp_y_discr"
  "shock_grants_y"
  "shock_istar"
  "shock_dl_cpistar"
  "shock_l_rp_foodstar_gap"
  "shock_l_rp_enerstar_gap"
  ];

% Size of the shock, percentage point
opts.reportModel.IRF.shockSize = 1;

% Variables in the report
opts.reportModel.IRF.variables  = [
  "l_cons_gap"
  "l_inv_gap"
  "l_gdem_gap"
  "l_exp_gap"
  "l_imp_gap"
  "l_y_gap"
  "dl_cpi_core"
  "dl_cpi_ener"
  "dl_cpi_food"
  "r4_gap"
  "l_z_gap"
  "rmc"
  "i"
  "l_s"
  "l_z"
  "def_y"
  "grants_y"
  "fisc_imp"
  "dl_s"
  ];

% Setting the subplot
opts.reportModel.IRF.subplot = [4, 5];

%% VD options

% Length of vardecomp
opts.reportModel.varDecomp.horizon    = 20;

% Variables in the report
opts.reportModel.varDecomp.variables  = [...
  "dl_cons"
  "dl_inv"
  "dl_gdem"
  "dl_exp"
  "dl_imp"
  "dl_y"
  "dl_cpi"
  "dl_cpi_core"
  "dl_cpi_food"
  "dl_cpi_ener"
  "i"
  "l_s"
  "l_cons_gap"
  "l_inv_gap"
  "l_gdem_gap"
  "l_exp_gap"
  "l_imp_gap"
  "l_y_gap"
  "l_z_gap"
  "r_gap"
  "l_rp_cpi_core_gap"
  "l_rp_cpi_food_gap"
  "l_rp_cpi_ener_gap"
  "def_y"
  "gdem_y"
  "oexp_y"
  "grev_y"
  "grants_y"
  "dl_cpistar"
  "rstar_tnd"
  "l_rp_foodstar_gap"
  "l_rp_enerstar_gap"
  "l_ystar_gap"
  ];

% Number of the variables in the contribution
opts.reportModel.varDecomp.contribs   = 6;

% Historical range of vardecomp
opts.reportModel.varDecomp.histRange = qq(2006, 1) : qq(2023, 2);

% Variables in the standard deviation comparison
opts.reportModel.stdComp.variables  = [
  "dl_cons"
  "d4l_cons"
  "dl_inv"
  "d4l_inv"
  "dl_gdem"
  "d4l_gdem"
  "dl_exp"
  "d4l_exp"
  "dl_imp"
  "d4l_imp"
  "dl_y"
  "d4l_y"
  "def_y"
  "grev_y"
  "gdem_y"
  "oexp_y"
  "grants_y"
  "dl_cpi"
  "d4l_cpi"
  "dl_cpi_core"
  "d4l_cpi_core"
  "dl_cpi_food"
  "d4l_cpi_food"
  "dl_cpi_ener"
  "d4l_cpi_ener"
  "i"
  "prem_d_gap"
  "dl_s"
  "d4l_s"
  "l_cons_gap"
  "l_inv_gap"
  "l_gdem_gap"
  "l_exp_gap"
  "l_imp_gap"
  "l_y_gap"
  "l_z_gap"
  "r_gap"
  "l_rp_cpi_core_gap"
  "l_rp_cpi_food_gap"
  "l_rp_cpi_ener_gap"
  "l_ystar_gap"
  "dl_cpistar"
  "istar"
  "rstar_tnd"
  "dl_foodstar"
  "l_rp_foodstar_gap"
  "dl_rp_foodstar_tnd"
  "dl_enerstar"
  "l_rp_enerstar_gap"
  "dl_rp_enerstar_tnd"
  ];

% Shock in the standard deviations comparison
opts.reportModel.stdComp.shocks = [
  "shock_l_cons_gap"
  "shock_l_inv_gap"
  "shock_l_exp_gap"
  "shock_l_y_gap"
  "shock_dl_cpi_core"
  "shock_dl_cpi_food"
  "shock_dl_cpi_ener"
  "shock_i"
  "shock_prem_d_gap"
  "shock_l_s"
  "shock_grev_y_discr"
  "shock_gdem_y_discr"
  "shock_oexp_y_discr"
  "shock_grants_y"
  ];

% Range of comparison
opts.reportModel.stdComp.range = qq(2006, 1) : qq(2023, 2);

%% Historical filter options

% Filtered range
opts.filterHistory.range = qq(2006, 1) : qq(2024, 4); % default 2024Q2 if data; extend filter for shocktuning +2Q

% Variables whose trend/gap decomposition is plotted; AK: can't add variables w/o changing reporting codes
opts.filterHistory.trendGapVars = [
  "l_cons",         "l_cons_tnd",         "l_cons_gap"; ...
  "l_inv",          "l_inv_tnd",          "l_inv_gap"; ...
  "l_gdem",         "l_gdem_tnd",         "l_gdem_gap"; ...
  "l_exp",          "l_exp_tnd",          "l_exp_gap"; ...
  "l_imp",          "l_imp_tnd",          "l_imp_gap"; ...
  "l_y",            "l_y_tnd",            "l_y_gap"; ...
  "d4l_cpi",        "d4l_cpi_tar",        ""; ...
  "d4l_cpi_core",   "d4l_cpi_core_tar",   ""; ...
  "d4l_cpi_food",   "d4l_cpi_food_tar",   ""; ...
  "d4l_cpi_ener",   "d4l_cpi_ener_tar",   ""; ...
  "l_z",            "l_z_tnd",            "l_z_gap"; ...
  "i",              "i_tnd",              ""; ...
  "r",              "r_tnd",              "r_gap"; ...
  "l_rp_cpi_core",  "l_rp_cpi_core_tnd",  "l_rp_cpi_core_gap"; ...
  "l_rp_cpi_food",  "l_rp_cpi_food_tnd",  "l_rp_cpi_food_gap"; ...
  "l_rp_cpi_ener",  "l_rp_cpi_ener_tnd",  "l_rp_cpi_ener_gap"; ...
  "l_rp_enerstar",  "l_rp_enerstar_tnd",  "l_rp_enerstar_gap"; ...
  "l_rp_foodstar",  "l_rp_foodstar_tnd",  "l_rp_foodstar_gap"; ...
  "l_y_agr",        "l_y_agr_tnd",        "l_y_agr_gap"; ...
  "prem_d",         "",                   "prem_d_gap"; ...
  "def_y",          "def_y_str",          ""; ...
  "gdem_y",         "gdem_y_str",         ""; ...
  "oexp_y",         "oexp_y_str",         ""; ...
  "grev_y",         "grev_y_str",         ""; ...
  ];

% Variables with equation decompositions in the report; AK: can add variables!
% used in both filter/reportHistory and calc/reportForecast
opts.filterHistory.eqDecompVars = [
    "l_cons_gap"
    "l_inv_gap"
    "l_gdem_gap"
    "l_exp_gap"
    "l_imp_gap"
    "l_y_gap"
    "dl_y_tnd"
    "dl_cpi_core"
    "dl_cpi_core_direct"
    "dl_cpi_food"
    "dl_cpi_food_direct"
    "dl_cpi_ener"
    "dl_cpi_ener_direct"
    "l_y_agr_gap"
    "i"
    "l_s"
    "dl_s_tar"
    "r_tnd"
    "grev_y"
    "grev_y_cyc"
    "grev_y_str"
    "gdem_y"
    "gdem_y_discr"
    "gdem_y_cyc"
    "gdem_y_str"
    "oexp_y"
    "oexp_y_cyc"
    "oexp_y_str"
    "def_y"
    "def_y_cyc"
    "def_y_discr"
    "def_y_str"
    "def_y_scd"
    "fisc_imp"
    "dl_rmd"
    ];

% Variables with shock decompositions in the report, AK: can add variables!
opts.filterHistory.shockDecompVars = [
  "dl_cons"
  "dl_inv"
  "dl_gdem"
  "dl_exp"
  "dl_imp"
  "dl_y"
  "dl_cpi_core"
  "dl_cpi_food"
  "dl_cpi_ener"
  "i"
  "dl_s"
  "l_cons_gap"
  "l_inv_gap"
  "l_gdem_gap"
  "l_exp_gap"
  "l_imp_gap"
  "l_y_gap"
  "r4_gap"
  "l_z_gap"
  "def_y"
  "grants_y"
  ];

% Table range
opts.filterHistory.rangeTable = qq(2019, 4) : opts.filterHistory.range(end); % default 2024Q2; extend filter for shocktuning, +2Q

% Plot range
opts.filterHistory.rangePlot = qq(2015, 1) : opts.filterHistory.range(end); % same

% Highlight range for recent period after COVID for reportHistory
opts.reportHistory.highlightRange = qq(2021, 1) : opts.filterHistory.rangePlot(end);

% Grouping of shocks in the shock decomposition

opts.filterHistory.shockDecompGroups.Demand = [
  "shock_l_cons_gap"
  "shock_l_inv_gap"
  "shock_l_exp_gap"
  ];

opts.filterHistory.shockDecompGroups.Supply = [
  "shock_dl_cpi_core"
  "shock_dl_cpi_food"
  "shock_dl_cpi_ener"
  "shock_l_y_agr_gap"
  ];

opts.filterHistory.shockDecompGroups.Fiscal = [
  "shock_gdem_y_cyc"
  "shock_grev_y_cyc"
  "shock_oexp_y_cyc"
  "shock_gdem_y_discr"
  "shock_grev_y_discr"
  "shock_oexp_y_discr"
  "shock_grants_y"
  ];

opts.filterHistory.shockDecompGroups.MonPol = [
  "shock_i"
  "shock_dl_s_tar"
  "shock_d4l_cpi_tar"
  "shock_prem_d_gap"
  ];

opts.filterHistory.shockDecompGroups.UIP = [
  "shock_prem"
  "shock_l_s"
  ];

opts.filterHistory.shockDecompGroups.Money = [
  "shock_dl_rmd"
  "shock_dl_v"
  ];

opts.filterHistory.shockDecompGroups.Commodity = [
  "shock_l_rp_foodstar_gap"
  "shock_l_rp_enerstar_gap"
  "shock_dl_rp_foodstar_tnd"
  "shock_dl_rp_enerstar_tnd"
  ];

opts.filterHistory.shockDecompGroups.External = [
  "shock_l_ystar_gap"
  "shock_dl_cpistar"
  "shock_istar"
  "shock_rstar_tnd"
  ];

opts.filterHistory.shockDecompGroups.Trends = [
  "shock_dl_cons_tnd"
  "shock_dl_inv_tnd"
  "shock_dl_exp_tnd"
  "shock_dl_imp_tnd"
  "shock_dl_z_tnd"
  "shock_dl_rp_cpi_food_tnd"
  "shock_dl_rp_cpi_ener_tnd"
  "shock_dl_y_agr_tnd"
  "shock_gdem_y_str"
  "shock_grev_y_str"
  "shock_oexp_y_str"
  ];

opts.filterHistory.shockDecompGroups.Discr = [
  "shock_l_y_gap"
  "shock_l_imp_gap"
  ];

opts.filterHistory.shockDecompGroups.Rest = "Init/determ.";

%% Historical forecast options

% Range of historical forecast
opts.histForecast.range = qq(2022, 4) : qq(2023, 2);

% Horizon of historical forecast
opts.histForecast.horizon = 8;

% Variables in the report
opts.histForecast.variables = [
  "dl_cons"
  "dl_inv"
  "dl_gdem"
  "dl_exp"
  "dl_imp"
  "dl_y"
  "dl_y_agr"
  "dl_cpi_core"
  "dl_cpi_food"
  "dl_cpi_ener"
  "i"
  "l_s"
  "dl_s"
  "def_y"
  "grants_y"
  "dl_rmd"
  "l_cons_gap"
  "l_inv_gap"
  "l_gdem_gap"
  "l_exp_gap"
  "l_imp_gap"
  "l_y_gap"
  "l_y_agr_gap"
  "l_z_gap"
  "r4_gap"
  "gdem_y_cyc"
  "gdem_y_discr"
  "fisc_imp"
  "prem_d_gap"
  "i_tnd"
  "r_tnd"
  "d4l_cpi_tar"
  "prem"
  "e_dl_z_tnd"
  ];

% Observed exogenous variables

% opts.histForecast.exogvars = [
%   "l_ystar_gap",        "obs_l_ystar_gap",        "shock_l_ystar_gap"; ...
%   "l_cpistar",          "obs_l_cpistar",          "shock_dl_cpistar"; ...
%   "istar",              "obs_istar",              "shock_istar"; ...
%   "rstar_tnd",          "obs_rstar_tnd",          "shock_rstar_tnd"; ...
%   "l_rp_foodstar_gap",  "obs_l_rp_foodstar_gap",  "shock_l_rp_foodstar_gap"; ...
%   "l_rp_enerstar_gap",  "obs_l_rp_enerstar_gap",  "shock_l_rp_enerstar_gap"; ...
%   "l_foodstar",         "obs_l_foodstar",         "shock_dl_rp_foodstar_tnd"; ...
%   "l_enerstar",         "obs_l_enerstar",         "shock_dl_rp_enerstar_tnd"; ...
%   ];

opts.histForecast.exogvars = [
  "l_ystar_gap",        "obs_l_ystar_gap",          "shock_l_ystar_gap"; ...
  "l_cpistar",          "obs_l_cpistar",            "shock_dl_cpistar"; ...
  "istar",              "obs_istar",                "shock_istar"; ...
  "rstar_tnd",          "obs_rstar_tnd",            "shock_rstar_tnd"; ...
  "l_rp_foodstar_gap",  "obs_l_rp_foodstar_gap",    "shock_l_rp_foodstar_gap"; ...
  "l_rp_enerstar_gap",  "obs_l_rp_enerstar_gap",    "shock_l_rp_enerstar_gap"; ...
  "l_foodstar",         "obs_l_foodstar",           "shock_dl_rp_foodstar_tnd"; ...
  "l_enerstar",         "obs_l_enerstar",           "shock_dl_rp_enerstar_tnd"; ...
  "l_cons_tnd",         "tune_l_cons_tnd",          "shock_dl_cons_tnd"; ...
  "l_inv_tnd",          "tune_l_inv_tnd",           "shock_dl_inv_tnd"; ...
  "l_exp_tnd",          "tune_l_exp_tnd",           "shock_dl_exp_tnd"; ...
  "l_imp_tnd",          "tune_l_imp_tnd",           "shock_dl_imp_tnd"; ...
  "d4l_cpi_tar",        "tune_d4l_cpi_tar",         "shock_d4l_cpi_tar"; ...
  "l_rp_cpi_food_tnd",  "tune_l_rp_cpi_food_tnd",   "shock_dl_rp_cpi_food_tnd"; ...
  "l_rp_cpi_ener_tnd",  "tune_l_rp_cpi_ener_tnd",   "shock_dl_rp_cpi_ener_tnd"; ...
  "l_z_tnd",            "tune_l_z_tnd",             "shock_dl_z_tnd"; ...
  "prem",               "tune_prem",                "shock_prem"; ...
  "dl_s_tar",           "tune_dl_s_tar",            "shock_dl_s_tar"; ...
  "grev_y_str",         "tune_grev_y_str",          "shock_grev_y_str"; ...
  "gdem_y_str",         "tune_gdem_y_str",          "shock_gdem_y_str"; ...
  "oexp_y_str",         "tune_oexp_y_str",          "shock_oexp_y_str"; ...
  ];

%% Forecast options

% Horizon of forecast
opts.forecast.range = qq(2025, 1) : qq(2029, 4); % extended forward each Q if new data
 
opts.forecast.scenarioNames = ...
    ["Baseline"];%, "Alternative"];

opts.forecast.scenarioLegends = []; % scenarioNames will be used if this is empty

% Forecast shock decomposition range
opts.forecast.shockDecompRange = qq(2006, 1) : qq(2028, 4);

%% Report forecast options

% Range of the graphs in the forecast report
opts.forecastReport.plotRange = qq(2017, 1) : opts.forecast.range(end); % extended 2028Q4

% Range of the highlighted area i.e. highlight recent past
opts.forecastReport.highlightRange = opts.forecast.range; 

% Range of the tables in the forecast report
opts.forecastReport.tableRange = qq(2025, 1) : opts.forecast.range(end); % extend 2028Q4

% Range for annualized series
opts.forecastReport.tableRange_ann = yy(2021) : yy(2028);
%% Process options

opts.mainDir = string(fileparts(mfilename("fullpath")));
opts = codes.utils.processOptions(opts);

end