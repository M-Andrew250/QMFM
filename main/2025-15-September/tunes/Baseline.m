function [tunes, pln, m] = Baseline_ak(opts, m)

% -------- Load data --------

tmp = codes.utils.loadResult(opts, "data");

dbObs       = tmp.dbObs;
dbObsTrans  = tmp.dbObsTrans;
dbOrig      = tmp.db;

% -------- Reset model parameters --------

% % Model parameters tunes for the forecast (tuned for future to keep the
% % historical trend intact)
% % interest policy rule response to output gap

%% Fiscal

m.ss_grev_y_str =  24; % put MTRS target of 23% (before 21%, hist ss was 17-18%)
m.ss_oexp_y_str =  6-0.5; % 1 pps down from historical s-state
m.ss_gdem_y_str =  26; % 0.5 pps down from historical s-state
m.ss_bor_str    =  6-1; % 1 pps down from historical level of borrowing 
m.ss_grants_y   =  5-2.5; % 2.5 pps down form historical level of grants
m.v4            =  0.97; % 0.02 pps down from historical persistence was 0.99

%% -------- Predefine tunes and the simulation plan --------

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
  "oexp_y"
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

%% ----- External variables -----

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
%% CPI core, food, energy q-o-q (dl) annualized growth hard-tuned using 2025Q3 observed

%1a. CORE hard-tune 2025Q3 data (note: these are s.a., see readData)
rngExog = qq(2025, 3);
pln = exogenize(pln,  rngExog, 'dl_cpi');
pln = endogenize(pln, rngExog, 'shock_dl_cpi_core');
tunes.dl_cpi(rngExog) = dbObsTrans.obs_dl_cpi(rngExog);

% 1b. CPI_food hard-tune with 2025Q3 data
rngExog = qq(2025, 3);
pln = exogenize(pln,  rngExog, 'dl_cpi_food');
pln = endogenize(pln, rngExog, 'shock_dl_cpi_food');
tunes.dl_cpi_food(rngExog) = dbObsTrans.obs_dl_cpi_food(rngExog);

%1c. CPI_ener hard-tune with 2025Q3 data 
rngExog = qq(2025, 3);
pln = exogenize(pln,  rngExog, 'dl_cpi_ener');
pln = endogenize(pln, rngExog, 'shock_dl_cpi_ener');
tunes.dl_cpi_ener(rngExog) = dbObsTrans.obs_dl_cpi_ener(rngExog);

%% IB rate hard-tuned with full or partial data (average last 2-3 mos thru 2025Q3), judgement for Q4
% margin of IB rate (CBR has as intermediate target) was 0.5-0.7%, dropped recently to 0.3%
% IB rate for 2025Q3 hard-tuned with data; next Q judgement: assumed CBR rate unchanged 6.75 Q3 + IB margin 
rngExog = qq(2025, 3);
pln = exogenize(pln,  rngExog, 'i');
pln = endogenize(pln, rngExog, 'shock_i');
tunes.i(rngExog) = dbObs.obs_i(rngExog);
%
rngExog = qq(2025, 4);
pln = exogenize(pln,  rngExog, 'i');
pln = endogenize(pln, rngExog, 'shock_i');
tunes.i(rngExog) = 100 * log(1 + (6.75+0.3)/100);

%% GDP & demand: recall we run ext.filter 1-2 Q beyond data (2025Q3-4) with hist tunes y-on-y GDP growth fr Nowcast
% we 'read' demand shocks for Q3-4, then set back filter-range to end datarange; soft-tune demand shocks 1-2Q ahead
rngExog = qq(2025, 3) : qq(2025, 3);
pln = exogenize(pln,  rngExog, 'd4l_y');
pln = endogenize(pln, rngExog, 'shock_l_cons_gap');
tunes.d4l_y(rngExog) = 100 * log(1 + 7.7/100); % tune with nowcast of Sept 2025 for Q3

% soft-tune other-than-cons FD shocks, 'read' from filter results w.historical tuning of GDP (Nowcast)
% filter distributes shocks among other FD, so that movement in GDP not only attributed to cons shock
% rngExog = qq(2025, 2) : qq(2025, 3);
% tunes.shock_l_inv_gap(rngExog) = [ 0.38,    0.18]; % Need to be read from ext.filter results
% tunes.shock_l_exp_gap(rngExog) = [ 0.83,    0.39]; % 
% tunes.shock_l_imp_gap(rngExog) = [-0.02,   -0.01]; % 

% soft-tune private investment shock, to reflect Bugesera (govt netLending, oexp) sum 5.6 GDP 2025/26-2026/27
% but effect spread over 8Q, markup 1(investment/GDP)=1/0.15=6,take half
rngExog = qq(2025, 3) : qq(2027, 2);
tunes.shock_l_inv_gap(rngExog) = [3, 6, 7, 10, 10, 7, 6, 3];

%% Exchange rate: hard-tune with data for 2025Q3
rngExog = qq(2025, 3);
pln = exogenize(pln,  rngExog, 'l_s');
pln = endogenize(pln, rngExog, 'shock_l_s');
tunes.l_s(rngExog) = dbObs.obs_l_s(rngExog); %dbObs.obs_l_s(rngExog);

% hard-tune ER (l_s) or QoQ growth (dl_s) for 2025Q4 using NBR=IMF program (8.3% eop2025, May'25Review)
% or extrapolate path realized 2025Q1-3, ie 5.2% at end-Q3 over 2024Q4 (1372.7), so 2.9% remains for 2025Q4;
rngExog = qq(2025, 4);
pln = exogenize(pln,  rngExog, 'dl_s');
pln = endogenize(pln, rngExog, 'shock_l_s');
%tunes.l_s(rngExog) = 100*(log(1372.7) + log(1 + 0.083)); % if level is tuned,eg w. annualized assumed depr.rate from last observed
tunes.dl_s(rngExog) = 100 * log(1 + 0.029*4); % equivalent! tune dl_s (annualized!) we had to add tune_dl_s to minecofin.model

%% Fiscal variables (follows FY), esp. deficit (GFS1986), govt demand G&S, revenue (so: other expend implicit)
% forecast: fr Treasury plan but NOT YET; for now: using fiscal targets PCI-program 2025/26 a.f.(May25 review)
% in July-Oct 2023 rounds, we didnot yet tune deficit forward assuming renegotiation of PCI

%% hard-tune deficit from PCI program 5th review May'25 (NB in addition, we could hard-tune gdem)
% PCI deficits: 2025/26: 10%; 2026/27: 8%; 2027/28: 6.1% of GDP and
% semester breakdown
rngExog = qq(2025, 3) : qq(2027, 4);
pln = exogenize(pln,  rngExog, 'def_y');
pln = endogenize(pln, rngExog, 'shock_gdem_y_discr');
tunes.def_y(rngExog) = [14.2, 14.0, 6.0, 5.8, 9.3, 9.0, 7.2, 6.9, 6.4, 6.3];

%% hard tune for govt other exp from FISCAL 2025/26-2027/28,for Q w. airport netLending, equal distr over Q
rngExog = qq(2025, 3) : qq(2027, 4);
pln = exogenize(pln,  rngExog, 'oexp_y');
pln = endogenize(pln, rngExog, 'shock_oexp_y_discr');
tunes.oexp_y(rngExog) = [12.5, 12.5, 4.6, 4.6, 7.5, 7.5, 5.8, 5.8, 4.8, 4.8];
%% we could hard-tune discretionary rev/GDP reflecting below-trend non-tax revenue, lag revenue base to inflation, exemptions (for 2023)
% rngExog = qq(2025, 3) : qq(2025, 4);
% pln = exogenize(pln,  rngExog, 'grev_y_discr');
% pln = endogenize(pln, rngExog, 'shock_grev_y_discr');
% tunes.grev_y_discr(rngExog) = [-1.0,-1.0,-0.9,-0.9,-0.8,-0.7,-0.6,-0.5]; % grev below trend both years NOT USED

%% hard tune for govt revenue (tax/nontax) from PCI program each Q 2024/25-2027/28, smoothen increase over all Q
% PCI revenue: 2025/26: 18.8%; 2026/27: 19.7%; 2027/28: 20.3% of GDP
rngExog = qq(2025, 3) : qq(2027, 4);
pln = exogenize(pln,  rngExog, 'grev_y');
pln = endogenize(pln, rngExog, 'shock_grev_y_discr');
tunes.grev_y(rngExog) = [18.5, 18.7, 18.9, 19.1, 19.3, 19.6, 19.8, 20.1, 20.2, 20.3];
%
% Optional: tune Govt demand (gdem/gdp) using PCI program with discr govt demand shock endogenous
% rngExog = qq(2025, 1): qq(2027, 4);
% pln = exogenize(pln,  rngExog, 'gdem_y');
% pln = endogenize(pln, rngExog, 'shock_gdem_y_discr');
% tunes.gdem_y(rngExog) = [20.9,20.9,22.5,22.5,18.1,18.1,21.7,21.7,20.0,20.0,20.8,20.8]);%calc resiudally from def, rev, oexp

end



