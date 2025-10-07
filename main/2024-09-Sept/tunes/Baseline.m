function [tunes, pln, m] = Baseline(opts, m)

% -------- Load data --------

tmp = codes.utils.loadResult(opts, "data");

dbObs       = tmp.dbObs;
dbObsTrans  = tmp.dbObsTrans;
dbOrig      = tmp.db;

% -------- Reset model parameters --------

% % Model parameters tunes for the forecast (tuned for future to keep the
% % historical trend intact)
% % interest policy rule response to output gap
m.c3 = 0.2;  % was 0.5, seems NBR less responsive to y_gap; IMF-NBR had 0.5 (for same persistence as we)
m.e5 = 0.1;  % was 0.30 (as BNR) but we need lower ER response to inflation deviation
m.e6 = 0.95; % was 0.85 (as BNR) but we need higher ER response to RER gap

%% Fiscal

m.ss_grev_y_str = 24; % put MTRS target of 23% (before 21%, hist ss was 17-18%)
m.ss_oexp_y_str = 6-0.5; % 1 pps down from historical s-state
m.ss_gdem_y_str = 26; % 0.5 pps down from historical s-state
m.ss_bor_str    =  6-1; % 1 pps down from historical level of borrowing 
m.ss_grants_y   =  5-2.5; % 2.5 pps down form historical level of grants
m.v4            = 0.97; % 0.02 pps down from historical persistence was 0.99

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

%pln = Plan.forModel(m, rngFcast, "anticipate",true);
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
%% CPI core, food, and energy q-o-q (dl) annualized growth hard-tuned using 2024Q2 observed data

%1a. CORE hard-tune 2024Q3 data (note: these are s.a., see readData)
rngExog = qq(2024, 3);
pln = exogenize(pln,  rngExog, 'dl_cpi_core');
pln = endogenize(pln, rngExog, 'shock_dl_cpi_core');
tunes.dl_cpi_core(rngExog) = dbObsTrans.obs_dl_cpi_core(rngExog);

% 1b. CPI_food hard-tune with 2024Q3 data
rngExog = qq(2024, 3);
pln = exogenize(pln,  rngExog, 'dl_cpi_food');
pln = endogenize(pln, rngExog, 'shock_dl_cpi_food');
tunes.dl_cpi_food(rngExog) = dbObsTrans.obs_dl_cpi_food(rngExog);

% 1c. CPI_ener hard-tune with 2024Q3 data 
rngExog = qq(2024, 3);
pln = exogenize(pln,  rngExog, 'dl_cpi_ener');
pln = endogenize(pln, rngExog, 'shock_dl_cpi_ener');
tunes.dl_cpi_ener(rngExog) = dbObsTrans.obs_dl_cpi_ener(rngExog);

% 1a-c. CPI headline can be hard-tuned with prel. 2024Q4 data, but we can only tune 3 of 4 CPIs
% rngExog = qq(2024, 4);
% pln = exogenize(pln,  rngExog, 'dl_cpi');
% pln = endogenize(pln, rngExog, 'shock_dl_cpi_core');
% tunes.dl_cpi(rngExog) = dbObsTrans.obs_dl_cpi(rngExog);

% 2a. option: CPI_core hard-tune also 2024Q4 based on BNR-QPM forecast or judgment NOT YET
% rngExog = qq(2024, 4);
% pln = exogenize(pln,  rngExog, 'dl_cpi_core');
% pln = endogenize(pln, rngExog, 'shock_dl_cpi_core');
% tunes.dl_cpi_core(rngExog) = 100*log(1 + 0/100);

% 2b. option: CPI_food hard-tune with 2024Q4 BNR-QPM forecast NOT YET
% rngExog = qq(2024, 4);
% pln = exogenize(pln,  rngExog, 'dl_cpi_food');
% pln = endogenize(pln, rngExog, 'shock_dl_cpi_food');
% tunes.dl_cpi_food(rngExog) = 100*log(1 + 0/100);

% 2c. option: CPI_ener hard-tune with 2024Q4 BNR-QPM forecast  NOT YET
% rngExog = qq(2024, 4);
% pln = exogenize(pln,  rngExog, 'dl_cpi_ener');
% pln = endogenize(pln, rngExog, 'shock_dl_cpi_ener');
% tunes.dl_cpi_ener(rngExog) = 100*log(1 + 0/100);

% 2a-c. option: CPI headline hard-tune 2024Q4 with BNR-QFM forecast, but we can only tune 3 of 4 CPIs
% rngExog = qq(2024, 3);
% pln = exogenize(pln,  rngExog, 'dl_cpi');
% pln = endogenize(pln, rngExog, 'shock_dl_cpi_core');
% tunes.dl_cpi(rngExog) = 100*log(1 + 0/100);

%% 3.optional: soft-tune shocks if we believe recent past negative shocks fade slowly
% 3a. CPI_core soft-tune 2024Q4 a.f. if further negative shocks expected 
% rngExog = qq(2024, 4) : qq(2024,4);
%tunes.shock_dl_cpi_core = Series(qq(2024,4):qq(2024,4), 0); % any shock for 2024Q4

% further shocks to avoid too low prices thru end-2025 (as we did in Dec 2023)
tunes.shock_dl_cpi_core = Series(qq(2025,4):qq(2026,3), [1.0, 0.5, 0.5, 0.5]); 

% 3b. CPI_food soft-tune 2024Q4 a.f. if further shock expected  
%rngExog = qq(2025, 4): qq(2025,2);
tunes.shock_dl_cpi_food = Series(qq(2024,4):qq(2025,2), [1.5, 0.5, 0.5]);

% 3c. CPI_ener soft-tune 2024Q4 a.f.if shock expected (incl.pumpprice change)(0.2=share fuels in energy) 
%rngExog = qq(2024, 4);
%tunes.shock_dl_cpi_ener = Series(qq(2024,4):qq(2024,4), [0]);

% Option: CPI_headline or CPI_food, CPI_core y-on-y growth (d4l) s.u. (no need for s.a.!) can be hard-tuned for future Q
% using Arima, NBR, extrapolation of 1-2 months, judgement; best: d4l_ as no s.a. needed
% rngExog = qq(2024, 4);
% pln = exogenize(pln,  rngExog, 'd4l_cpi');
% pln = endogenize(pln, rngExog, 'shock_dl_cpi_core');
% tunes.d4l_cpi(rngExog) = 100*log(1 + 0/100);

%% IB rate hard-tuned with full data, partial data (average of 2 mos thru Aug 2024),judgement
% margin of interbank rate (that CBR aims to set) remains at its recent average of 0.7 
% IB rate hard-tune with 2024Q2 data
% rngExog = qq(2024, 2);
% pln = exogenize(pln,  rngExog, 'i');
% pln = endogenize(pln, rngExog, 'shock_i');
% tunes.i(rngExog) = dbObs.obs_i(rngExog);

% IB rate for 2024Q3 hard-tuned with data July-Aug (and CBR rate Aug 2024 to 6.5%, so av.Q3 6.8 + IB margin 0.7)  
rngExog = qq(2024, 3);
pln = exogenize(pln,  rngExog, 'i');
pln = endogenize(pln, rngExog, 'shock_i');
tunes.i(rngExog) = 100 * log(1 + 7.5/100);

%% GDP & FD : recall, we ran ext.filter 2Q beyond data (ie 2024Q3-Q4) with historical tunes for y-on-y GDP growth fr Nowcast
% we 'read' final demand shocks for those Q3-4, then set back filter range to end of data range; soft-tune FD shocks for first 2 Q in forecast
% option to tune 2024Q3 with prel. data if inserted in Rwametric NOT USED this time
% rngExog = qq(2024, 3);
% pln = exogenize(pln,  rngExog, 'd4l_y');
% pln = endogenize(pln, rngExog, 'shock_l_cons_gap');
% tunes.d4l_y(rngExog) = dbObsTrans-obs_d4l_y(rngExog); % prel. actual NA 2024Q3 growth

rngExog = qq(2024, 3) : qq(2024,4);
pln = exogenize(pln,  rngExog, 'd4l_y');
pln = endogenize(pln, rngExog, 'shock_l_cons_gap');
tunes.d4l_y(rngExog) = 100 * log(1 + [ 7.9, 5.1]/100 ); % tune with nowcast of Sept 2024 for Q3-4

% soft-tune other-than-cons FD shocks, 'read' from filter results w.historical tuning of GDP (Nowcast)
% filter distributes shocks among other FD, so that movement in GDP not only attributed to cons shock
rngExog = qq(2024,3) : qq(2024,4);
tunes.shock_l_inv_gap(rngExog) = [ 0.66,  -0.16]; % need to be read from ext.filter results
tunes.shock_l_exp_gap(rngExog) = [ 1.46,  -0.36]; % 
tunes.shock_l_imp_gap(rngExog) = [-0.04,  -0.01]; %

%% Exchange rate: hard-tune 2024Q3 with data 
rngExog = qq(2024, 3);
pln = exogenize(pln,  rngExog, 'l_s');
pln = endogenize(pln, rngExog, 'shock_l_s');
tunes.l_s(rngExog) = dbObs.obs_l_s(rngExog); % dbObs.obs_l_s(rngExog);

% hard-tune ER level (l_s) or QoQ growth (dl_s) for 2024Q4 using NBR=IMF program (11.8% eop 2024)
% or extrapolate actual path 2024 Jan-Sept (9% annualized) or info from NBR; base is log ER end-June 2024
rngExog = qq(2024, 4);
pln = exogenize(pln,  rngExog, 'dl_s');
pln = endogenize(pln, rngExog, 'shock_l_s');
%tunes.l_s(rngExog) = 100*(log(1311.1) + log(1 + 0.08/4)); % ann.depr in 2024Q3 assumed 8% from end-June
tunes.dl_s(rngExog) = 100 * log(1 + 0.09); % equivalent! tune dl_s and also added tune_dl_s to minecofin.model

%% Money demand M3: hard-tune if latest Q data available; NBR-MPC report gives forward info on CBR, i, P, money growth for a few Q
% rngExog = qq(2024, 3);
% pln = exogenize(pln,  rngExog, 'l_md');
% pln = endogenize(pln, rngExog, 'shock_dl_rmd');
% tunes.l_md(rngExog) = dbObs.obs_l_md(rngExog);

%% Fiscal variables (follows FY), esp. deficit (GFS1986), govt demand G&S, revenue (so: other expend implicit)
% forecast: fr Treasury plan but NOT YET; for now: using fiscal targets PCI-program 2024/25-2025/26 (May'24 review)
% in July and Oct 2023 rounds, we didnot yet tune deficit forward assuming renegotiation of PCI

%% hard-tune deficit for a recent Q if prel. data available 
% rngExog = qq(2024,3) : qq(2024, 3);
% pln = exogenize(pln,  rngExog, 'def_y');
% pln = endogenize(pln, rngExog, 'shock_gdem_y_discr');
% tunes.def_y(rngExog) = [11.9] ; % calc fr FISCAL/OUTPUT if latest Q available or can be est.
% tunes.def_y(rngExog) = dbObs.obs_def_y(rngExog);

%% hard-tune deficit next years from PCI program 3d review May'24 (in addition, we could hard-tune gdem)
rngExog = qq(2024,3) : qq(2026, 2);
pln = exogenize(pln,  rngExog, 'def_y');
pln = endogenize(pln, rngExog, 'shock_gdem_y_discr');
tunes.def_y(rngExog) = [8.7, 8.7, 9.1, 9.1, 7.8, 7.7, 7.5, 7.4]; % FYann.8.9, 7.6, 6.5%; bit higher (lower) in 2d half FY2024-25 (2025/26)
% tunes.shock_oexp_y_discr(rngExog) = -3,-3,-3,-3]; % tune only if good info on gdem, oexp NOT USED

%% we could hard-tune discretionary rev/GDP reflecting below-trend non-tax revenue, lag revenue base to inflation, exemptions (for 2023)
% rngExog = qq(2023,3) : qq(2025, 2);
% pln = exogenize(pln,  rngExog, 'grev_y_discr');
% pln = endogenize(pln, rngExog, 'shock_grev_y_discr');
% tunes.grev_y_discr(rngExog) = [-1.0,-1.0,-0.9,-0.9,-0.8,-0.7,-0.6,-0.5]; % grev below trend both years NOT USED

%% hard tune for govt revenue (tax/nontax) from PCI program each Q 2024/25-2025/26, equal distr over Q
rngExog = qq(2024, 3): qq(2027, 1);
pln = exogenize(pln,  rngExog, 'grev_y');
pln = endogenize(pln, rngExog, 'shock_grev_y_discr');
tunes.grev_y(rngExog) = [18.1, 18.3, 18.5, 18.7, 19.1, 19.4, 19.7, 19.8, 19.85, 19.9, 20.0]; % FYannual 18.4, 19.5% [20.1: 19.85,19.9,20.1,20.3%]

% Option: tune Govt demand (gdem/gdp) using fiscal program 2023/24 with discr govt demand shock endogenous
% rngExog = qq(2023, 3);
% pln = exogenize(pln,  rngExog, 'gdem_y');
% pln = endogenize(pln, rngExog, 'shock_gdem_y_discr');
% tunes.gdem_y(rngExog) = 100 * log(1 + 0/100);

end



