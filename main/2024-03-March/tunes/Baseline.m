function [tunes, pln, m] = Baseline(opts, m)

% -------- Load data --------

tmp = codes.utils.loadResult(opts, "data");

dbObs       = tmp.dbObs;
dbObsTrans  = tmp.dbObsTrans;
dbOrig      = tmp.db;

% -------- Reset model parameters --------

% Model paramters tunes for the forecast (tuned for future to keep the
% historical trend intact)
% interest policy rule response to output gap
m.c3 = 0.2; % was 0.5, seems NBR less responsive to y_gap; IMF-NBR had 0.5 (for same persistence as we)

% Fiscal

m.ss_grev_y_str = 21; % kept same as historical parameter s-state
m.ss_oexp_y_str = 6-1; % 1 pps down from historical s-state
m.ss_gdem_y_str = 26-2; % 2 pps down from historical s-state
m.ss_bor_str    =  6-1;   % 1 pps down from historical level of borrowing 
m.ss_grants_y   =  5-2; % 2 pps down form historical level of grants
m.v4 = 0.97;            % 0.02 pps down from historical persistence was 0.99

% -------- Predefine tunes and the simulation plan --------

tunes = struct;

tuneNames = [
  "l_cpistar"
  "l_ystar_gap"
  "istar"
  "rstar_tnd"
  "l_foodstar"
  "l_enerstar"
  "l_rp_foodstar_gap"
  "l_rp_enerstar_gap"
  "dl_cpi"
  "d4l_cpi"
  "dl_cpi_core"
  "d4l_cpi_core"
  "dl_cpi_food"
  "d4l_cpi_food"
  "dl_cpi_ener"
  "d4l_cpi_ener"
  "i"
  "d4l_y"
  "shock_l_inv_gap"
  "shock_l_exp_gap"
  "shock_l_imp_gap"
  "l_s"
  "dl_s"
  "l_md"
  "d4l_gdem"
  "gdem_y"
  "grev_y"
  "def_y"
  "grev_y_discr"
  "shock_oexp_y_discr"
  ];

for n = tuneNames(:)'
  tunes.(n) = Series();
end

rngFcast = opts.forecast.range;

pln = Plan.forModel(m, rngFcast);

% -------- Set tune values and the simulation plan --------

% Do not create Series here! Only assign values to existing series, created in loop above.

% ----- External variables -----

pln = exogenize(pln,  rngFcast, 'l_cpistar');
pln = endogenize(pln, rngFcast, 'shock_dl_cpistar');

pln = exogenize(pln,  rngFcast, 'l_ystar_gap');
pln = endogenize(pln, rngFcast, 'shock_l_ystar_gap');

pln = exogenize(pln,  rngFcast, 'istar');
pln = endogenize(pln, rngFcast, 'shock_istar');

pln = exogenize(pln,  rngFcast, 'rstar_tnd');
pln = endogenize(pln, rngFcast, 'shock_rstar_tnd');

pln = exogenize(pln,  rngFcast, 'l_rp_foodstar_gap');
pln = endogenize(pln, rngFcast, 'shock_l_rp_foodstar_gap');

pln = exogenize(pln,  rngFcast, 'l_foodstar');
pln = endogenize(pln, rngFcast, 'shock_dl_rp_foodstar_tnd');

pln = exogenize(pln,  rngFcast, 'l_rp_enerstar_gap');
pln = endogenize(pln, rngFcast, 'shock_l_rp_enerstar_gap');

pln = exogenize(pln,  rngFcast, 'l_enerstar');
pln = endogenize(pln, rngFcast, 'shock_dl_rp_enerstar_tnd');

tunes.l_cpistar(rngFcast)         = dbObs.obs_l_cpistar(rngFcast);
tunes.l_ystar_gap(rngFcast)       = dbObs.obs_l_ystar_gap(rngFcast);
tunes.istar(rngFcast)             = dbObs.obs_istar(rngFcast);
tunes.rstar_tnd(rngFcast)         = dbObs.obs_rstar_tnd(rngFcast);
tunes.l_rp_foodstar_gap(rngFcast) = dbObs.obs_l_rp_foodstar_gap(rngFcast);
tunes.l_foodstar(rngFcast)        = dbObs.obs_l_foodstar(rngFcast);
tunes.l_rp_enerstar_gap(rngFcast) = dbObs.obs_l_rp_enerstar_gap(rngFcast);
tunes.l_enerstar(rngFcast)        = dbObs.obs_l_enerstar(rngFcast);

% ----- NTFs ------
%% CPI core, food, and energy q-o-q (dl) annualized growth hard-tuned using 2023Q4 observed data

% 1a. CORE hard-tune 2023Q4 data (note: these are s.a., see readData)
rngExog = qq(2023, 4);
pln = exogenize(pln,  rngExog, 'dl_cpi_core');
pln = endogenize(pln, rngExog, 'shock_dl_cpi_core');
tunes.dl_cpi_core(rngExog) = dbObsTrans.obs_dl_cpi_core(rngExog);

% 1b. CPI_food hard-tune with 2023Q4 data
rngExog = qq(2023, 4);
pln = exogenize(pln,  rngExog, 'dl_cpi_food');
pln = endogenize(pln, rngExog, 'shock_dl_cpi_food');
tunes.dl_cpi_food(rngExog) = dbObsTrans.obs_dl_cpi_food(rngExog);

% 1c. CPI_ener hard-tune with 2023Q4 data 
rngExog = qq(2023, 4);
pln = exogenize(pln,  rngExog, 'dl_cpi_ener');
pln = endogenize(pln, rngExog, 'shock_dl_cpi_ener');
tunes.dl_cpi_ener(rngExog) = dbObsTrans.obs_dl_cpi_ener(rngExog);

% 1a-c. CPI headline hard-tune Q4 with 2023Q4 data, but we can only tune 3 of 4 CPIs
% rngExog = qq(2023, 4);
% pln = exogenize(pln,  rngExog, 'dl_cpi');
% pln = endogenize(pln, rngExog, 'shock_dl_cpi_core');
% tunes.dl_cpi(rngExog) = dbObsTrans.obs_dl_cpi(rngExog);

% 2a. option: CPI_core hard-tune also 2024Q1 based on BNR-QPM forecast NOT YET
% rngExog = qq(2024, 1);
% pln = exogenize(pln,  rngExog, 'dl_cpi_core');
% pln = endogenize(pln, rngExog, 'shock_dl_cpi_core');
% tunes.dl_cpi_core(rngExog) = 100*log(1 + 4.5/100);

% 2b. option: CPI_food hard-tune with 2024Q1 BNR-QPM forecast
% rngExog = qq(2024, 1);
% pln = exogenize(pln,  rngExog, 'dl_cpi_food');
% pln = endogenize(pln, rngExog, 'shock_dl_cpi_food');
% tunes.dl_cpi_food(rngExog) = 100*log(1 + -3.6/100);

% 2c. option: CPI_ener hard-tune with 2024Q1 BNR-QPM forecast 
% rngExog = qq(2024, 1);
% pln = exogenize(pln,  rngExog, 'dl_cpi_ener');
% pln = endogenize(pln, rngExog, 'shock_dl_cpi_ener');
% tunes.dl_cpi_ener(rngExog) = 100*log(1 + 4.9/100);

% 2a-c. option: CPI headline hard-tune 2024Q1 with BNR-QFM forecast, but we can only tune 3 of 4 CPIs
% rngExog = qq(2024, 1);
% pln = exogenize(pln,  rngExog, 'dl_cpi');
% pln = endogenize(pln, rngExog, 'shock_dl_cpi_core');
% tunes.dl_cpi(rngExog) = 100*log(1 + -0.8/100);

% 3.optional: tune shocks if we believe that past shocks fade slowly
% 3a. CPI_core soft-tune 2024Q1 a.f. if further shock expected 
% rngExog = qq(2024, 1) : qq(2024,1);
%tunes.shock_dl_cpi_core = Series(qq(2024,1):qq(2024,1), 0); % 2023 shocks fading in 2024Q1

% further shocks to avoid too large dip in dl_cpi_core around end-2024
% tunes.shock_dl_cpi_core = Series(qq(2024,3):qq(2025,2), [0.3, 0.3, 0.3, 0.3]); 

% 3b. CPI_food soft-tune 2024Q1 a.f. if further shock expected  
%rngExog = qq(2024, 1): qq(2024,1);
%tunes.shock_dl_cpi_food = Series(qq(2024,1):qq(2024,1), [0]); 

% 3c. CPI_ener soft-tune 2024Q1 a.f. if shock (excise and pump price change) expected (0.2=share fuels in energy) 
%rngExog = qq(2023, 4);
%tunes.shock_dl_cpi_ener = Series(qq(2024,1):qq(2024,1), [0]);

% Option: CPI_headline or CPI_food, CPI_core y-on-y growth (d4l) s.u. (no need for s.a.!) can be hard-tuned for future Q
% using Arima, NBR, extrapolation of 1-2 months, judgement; best: d4l_ as no s.a. needed
% rngExog = qq(2024, 1);
% pln = exogenize(pln,  rngExog, 'd4l_cpi');
% pln = endogenize(pln, rngExog, 'shock_dl_cpi_core');
% tunes.d4l_cpi(rngExog) = 100*log(1 + 0/100);

%% IB rate hard-tuned with full data, partial data (average of 2 mos),judgement
% margin of interbank rate (that CBR aims to set) remains at about its recent average of 0.5
% IB rate hard-tune with 2023Q4 data
rngExog = qq(2023, 4);
pln = exogenize(pln,  rngExog, 'i');
pln = endogenize(pln, rngExog, 'shock_i');
tunes.i(rngExog) = dbObs.obs_i(rngExog);

% IB rate for 2024Q1 hard-tuned with data for Jan-Feb (and unchanged CBR rate Feb 2024)  
rngExog = qq(2024, 1);
pln = exogenize(pln,  rngExog, 'i');
pln = endogenize(pln, rngExog, 'shock_i');
tunes.i(rngExog) = 100 * log(1 + 8.0/100);

%% GDP & FD : recall, we ran ext.filter 2Q beyond data (ie 2023Q4 and 2024Q1) with historical tunes for y-on-y GDP growth from Nowcast
% we 'read' final demand shocks for those Q3-4, then set back filter range to end of data range; soft-tune FD shocks for first 2 Q in forecast
% option to tune 2023Q4 with data
% rngExog = qq(2023, 4);
% pln = exogenize(pln,  rngExog, 'd4l_y');
% pln = endogenize(pln, rngExog, 'shock_l_cons_gap');
% tunes.d4l_y(rngExog) = dbObsTrans-obs_d4l_y(rngExog); % prel. actual NA Q4 growth

rngExog = qq(2023, 4) : qq(2024,1);
pln = exogenize(pln,  rngExog, 'd4l_y');
pln = endogenize(pln, rngExog, 'shock_l_cons_gap');
tunes.d4l_y(rngExog) = 100 * log(1 + [10, 9]/100); % tune w prel. NA Q4 growth, and prel. nowcast Q1 11-/-2%

% soft-tune other-than-cons FD shocks, 'read' from filter results w.historical tuning of GDP (Nowcast)
% filter distributes shocks among other FD, so that movement in GDP not only attributed to cons shock
rngExog = qq(2023,4) : qq(2024,1);
tunes.shock_l_inv_gap(rngExog) = [ -1.8725,    0.69251]; % need to be r-read from ext.filter results
tunes.shock_l_exp_gap(rngExog) = [ 6.8181,     -2];      % idem
tunes.shock_l_imp_gap(rngExog) = [ -0.0033446, -0.15674]; % idem

%% Exchange rate: hard-tune 2023Q4 with data 
rngExog = qq(2023, 4);
pln = exogenize(pln,  rngExog, 'l_s');
pln = endogenize(pln, rngExog, 'shock_l_s');
tunes.l_s(rngExog) = dbObs.obs_l_s(rngExog); % dbObs.obs_l_s(rngExog);

% hard-tune exchange rate level (l_s) or QoQ growth (dl_s) for 2024Q1 using NBR=IMF program or judgement
% using path in 2024Q1 and other info from NBR; base is log of eop ER Dec 2023
rngExog = qq(2024, 1);
pln = exogenize(pln,  rngExog, 'l_s');
pln = endogenize(pln, rngExog, 'shock_l_s');
tunes.l_s(rngExog) = 100*(log(1263.93) + log(1 + 0.0825/4)); % ann.depr in 2024Q1 assumed 8.25%
% tunes.dl_s(rngExog) = 100 * log(1 + 0.0825); % equivalent! tune dl_s and also added tune_dl_s to model

%% Money demand M3: hard-tune with 2023Q4 data; NBR-MPC report gives forward info on CBR, i, P, money growth for a few Q
rngExog = qq(2023, 4);
pln = exogenize(pln,  rngExog, 'l_md');
pln = endogenize(pln, rngExog, 'shock_dl_rmd');
tunes.l_md(rngExog) = dbObs.obs_l_md(rngExog);

%% Fiscal variables (follows FY), esp. deficit, govt demand G&S, revenue (so: other expend implicit)
% forecast: from Treasury plan but NOT YET; for now: tuning using fiscal targets in PCI-program w IMF

% Forecast tunes: use PCI Nov2023 Review target GFS1986 def. to tune FY2023/24 and 2024/25
% in July and Oct 2023 rounds, we didnot yet tune deficit forward assuming renegociation of PCI
%% hard-tune deficit next years from PCI program 1st review June'23 (in addition, we could hard-tune gdem)
rngExog = qq(2023,4) : qq(2025, 2);
pln = exogenize(pln,  rngExog, 'def_y');
pln = endogenize(pln, rngExog, 'shock_gdem_y_discr');
tunes.def_y(rngExog) = [9.8, 11.8, 11.8, 9.9, 9.8, 9.6, 9.5]; % ann 10.8 and 9.7%, a bit lower in 2d half FY2024/25
% tunes.shock_oexp_y_discr(rngExog) = -3,-3,-3,-3]; % tune only if good info on gdem, oexp NOT USED

%% hard-tune discretionary revenue/GDP reflecting below-trend non-tax revenue, lag of revenue base to inflation, exemptions 
% rngExog = qq(2023,3) : qq(2025, 2);
% pln = exogenize(pln,  rngExog, 'grev_y_discr');
% pln = endogenize(pln, rngExog, 'shock_grev_y_discr');
% tunes.grev_y_discr(rngExog) = [-1.0, -1.0, -0.9, -0.9, -0.8, -0.7, -0.6, -0.5]; % grev continues proj below trend both years

%% hard tune for govt revenue (tax/nontax) from PCI program each Q 2023/24--2024/25, equal distribution over Q
rngExog = qq(2023, 4): qq(2025, 2);
pln = exogenize(pln,  rngExog, 'grev_y');
pln = endogenize(pln, rngExog, 'shock_grev_y_discr');
tunes.grev_y(rngExog) = [17.7, 17.9, 17.99, 18.1, 18.2, 18.4, 18.5];% ann rev 17.8 and 18.3%

% Option: tune Govt demand (gdem/gdp) using fiscal program 2023/24 with discr govt demand shock endogenous
% rngExog = qq(2023, 3);
% pln = exogenize(pln,  rngExog, 'gdem_y');
% pln = endogenize(pln, rngExog, 'shock_gdem_y_discr');
% tunes.gdem_y(rngExog) = 100 * log(1 + 0/100);



end



