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
% CPI core, food, and energy q-o-q (dl) annualized growth hard-tuned using 2023Q3 observed data
% CORE hard-tune Q3 data (note: these are s.a., see readData)
rngExog = qq(2023, 3);
pln = exogenize(pln,  rngExog, 'dl_cpi_core');
pln = endogenize(pln, rngExog, 'shock_dl_cpi_core');
tunes.dl_cpi_core(rngExog) = dbObsTrans.obs_dl_cpi_core(rngExog);

% HEADLINE hard-tune Q4 from NBR est. for eop Dec'23 (this variable is s.a.,see readData)
rngExog = qq(2023, 4) : qq(2023, 4);
pln = exogenize(pln,  rngExog, 'dl_cpi');
pln = endogenize(pln, rngExog, 'shock_dl_cpi_core');
tunes.dl_cpi(rngExog) = dbObsTrans.obs_dl_cpi(rngExog);

% CPI_core soft-tune 2023Q4 to ensure dl_cpi incr (NBR) goes to core, not food
%rngExog = qq(2023, 4) : qq(2024,1);
tunes.shock_dl_cpi_core = Series(qq(2023,4):qq(2024,1),[6, 1]); %shock 2023Q4 fading in 2024Q1

% further shocks to avoid too large dip in dl_cpi_core around end-2024
tunes.shock_dl_cpi_core = Series(qq(2024,3):qq(2025,2), [0.3, 0.3, 0.3, 0.3]); 

% CPI_food hard-tune with Q3 data
rngExog = qq(2023, 3) : qq(2023, 3);
pln = exogenize(pln,  rngExog, 'dl_cpi_food');
pln = endogenize(pln, rngExog, 'shock_dl_cpi_food');
tunes.dl_cpi_food(rngExog) = dbObsTrans.obs_dl_cpi_food(rngExog); 

% CPI_food soft-tune 2023Q4-2024Q1 no longer needed;we tune core 2023Q4,almost no food price shock 
%rngExog = qq(2024, 1): qq(2024,1);
%tunes.shock_dl_cpi_food = Series(qq(2024,1):qq(2024,1), [0]); % Dec12: 13.6,6.5; Dec7:7.8,3.8

% CPI_ener hard-tune with Q3 data 
rngExog = qq(2023, 3) : qq(2023, 3);
pln = exogenize(pln,  rngExog, 'dl_cpi_ener');
pln = endogenize(pln, rngExog, 'shock_dl_cpi_ener');
tunes.dl_cpi_ener(rngExog) = dbObsTrans.obs_dl_cpi_ener(rngExog);

% CPI_ener soft-tune Q3-4 for 5.6% tax increase early Aug ann.* 0.2 share fuels in energy 
% Oct4 11% pumpprice is petr-price-mech,captured in model eq.; spread Q3-4: 3 - 1.5%
rngExog = qq(2023, 4);
tunes.shock_dl_cpi_ener = Series(qq(2023,4):qq(2024,1), [1.5, 0]);

% CPI_headline or CPI_food, _core y-on-y growth (d4l) s.u. (no need for s.a.!) can be hard-tuned for 2023Q4
% using Arima, NBR, extraploation of 1-2 months, judgement; best: d4l_ as no s.a. needed
% rngExog = qq(2023, 3);
% pln = exogenize(pln,  rngExog, 'd4l_cpi');
% pln = endogenize(pln, rngExog, 'shock_dl_cpi_core');
% tunes.d4l_cpi(rngExog) = 100*log(1 + 13.3/100);

% IB rate tuned if partial data for a Q, taking average of 2 months
% 2023Q3 was based on guess that BNR CBR stays at 7% as y-o-y inflation falling (14.1 % Q2 fr 18.4 Q1 2023) 
% but NBR raised to 7.5% in Aug 2023; % for Nov we assumed CBR unchanged,proved correct
% margin of interbank rate (that CBR aims to set) remains at about its recent average of 0.5

% IB rate hard-tune Q3 from NBR monthly data thru Sepr 2023
rngExog = qq(2023, 3) : qq(2023, 3);
pln = exogenize(pln,  rngExog, 'i');
pln = endogenize(pln, rngExog, 'shock_i');
tunes.i(rngExog) = dbObs.obs_i(rngExog);

% 2023Q4 CBR unchanged from Q4 rate as inflation falls, IB 0.5% above  
rngExog = qq(2023, 4);
pln = exogenize(pln,  rngExog, 'i');
pln = endogenize(pln, rngExog, 'shock_i');
tunes.i(rngExog) = 100 * log(1 + 8.0/100);

% % hardtune GDP 2023Q2 data if forecasting from Q2 but GDP data available
% rngExog = qq(2023, 2);
% pln = exogenize(pln,  rngExog, 'd4l_y');
% pln = endogenize(pln, rngExog, 'shock_l_cons_gap');
% % tunes.l_y(rngExog) = dbObs.obs_l_y(rngExog);
% tunes.d4l_y(rngExog) = dbObsTrans.obs_d4l_y(rngExog);

% NB we ran filter thru 2023Q4 with historical tunes for y-on-y GDP growth of 5.2% in Q3 (5.0% in Q4)
% from Oct nowcasting (no s.a. needed) and we 'read' final demand shocks for those Q3-4
% then set back filter range to end of data range; soft-tune thw shocks for forecast from the Q after
rngExog = qq(2023,3) : qq(2023,4);
pln = exogenize(pln,  rngExog, 'd4l_y');
pln = endogenize(pln, rngExog, 'shock_l_cons_gap');
tunes.d4l_y(rngExog) = 100 * log(1 + [5.2, 5.0]/100);

% soft-tune other-than-cons final demand shocks, 'read' from filter results w.historical tuning of GDP
% filter distributes shocks among other FD, so that movement in GDP not only attributed to cons shock
rngExog = qq(2023,3) : qq(2023,4);
tunes.shock_l_inv_gap(rngExog) = [ 0.5, -1.2]; % May-July [-1,   -2];
tunes.shock_l_exp_gap(rngExog) = [ 1.2, -2.6]; % May-July [-1.5, -4];
tunes.shock_l_imp_gap(rngExog) = [-0.1,  0.1]; % May-July [-0.055, 0.054];

% Exchange rate: hard-tune 2023Q2-Q3 using database (readData and put in "observed" database, dbObs) 
rngExog = qq(2023, 3) : qq(2023, 3);
pln = exogenize(pln,  rngExog, 'l_s');
pln = endogenize(pln, rngExog, 'shock_l_s');
tunes.l_s(rngExog) = dbObs.obs_l_s(rngExog); % dbObs.obs_l_s(rngExog);

% hard-tune exchange rate level (l_s) or Qo growth (dls) for 2023Q4 using NBR=IMFprogram forecast (15% eopER depr in2023,quarterlized-applied to Q3 p.a.
% after verification that for first seven months of 2023, NBR was on ER depreciation path of 15%
rngExog = qq(2023, 4);
pln = exogenize(pln,  rngExog, 'l_s');
pln = endogenize(pln, rngExog, 'shock_l_s');
tunes.l_s(rngExog) = 100*(708.63/100 + log(1 + 0.15/4-0.01)); % depr in Q4 was 4.6%: faster than 15/4% p.Q.
%tunes.dl_s(rngExog) = 100 * log(1 + 0.15/4-0.01); % tune dl_s and also added tune_dl_s to the model


% Money demand M3: hard-tune Q2 2023 using database (observed in dbObs); NBR-MPC report gives forward
% info on interest rates, prices, and money growth for next few Q, usable for tuning these variables
rngExog = qq(2023, 3) : qq(2023, 3);
pln = exogenize(pln,  rngExog, 'l_md');
pln = endogenize(pln, rngExog, 'shock_dl_rmd');
tunes.l_md(rngExog) = dbObs.obs_l_md(rngExog);

% Fiscal variables (follows FY), esp. deficit, govt demand G&S, revenue (so: other expend implicit)
% forecast: from Treasury plan but NOT YET; for now: tuning using fiscal targets in PCI-program w IMF

% ----- Forecast tunes: use PCI Nov Review target GFS1986def. to tune FY2023/24 and 2024/25)-----
% in July and Oct 2023 rounds, we didnot yet tune deficit forward assuming renegociation of PCI
% hard-tune deficit next years from PCI program 1st review June'23 (in addition, we could hard-tune gdem)

rngExog = qq(2023,3) : qq(2025, 2);
pln = exogenize(pln,  rngExog, 'def_y');
pln = endogenize(pln, rngExog, 'shock_gdem_y_discr');
tunes.def_y(rngExog) = [9.8, 9.8, 11.8, 11.8, 9.9, 9.8, 9.6, 9.5]; % ann 10.8 and 9.7% lower in Q3-4

% tunes.shock_oexp_y_discr(rngExog) = -3,-3,-3,-3]; % tune only if good info on gdem, oexp

% hard-tune discretionary revenue/GDP reflecting below-trend non-tax revenue, lag of revenue base to inflation, exemptions 
% rngExog = qq(2023,3) : qq(2025, 2);
% pln = exogenize(pln,  rngExog, 'grev_y_discr');
% pln = endogenize(pln, rngExog, 'shock_grev_y_discr');
% tunes.grev_y_discr(rngExog) = [-1.0, -1.0, -0.9, -0.9, -0.8, -0.7, -0.6, -0.5]; % grev continues proj below trend both years

% hard tune for govt revenue (tax & non-tax) frm PCI program each Q 2023/24--2024/25
% assuming equal distribution in quarters

rngExog = qq(2023, 3): qq(2025, 2);
pln = exogenize(pln,  rngExog, 'grev_y');
pln = endogenize(pln, rngExog, 'shock_grev_y_discr');
tunes.grev_y(rngExog) = [17.6, 17.7, 17.9, 17.99, 18.1, 18.2, 18.4, 18.5];% ann rev 17.8 and 18.3%

% Government demand (gdem/gdp) using fiscal program 2022/23, tune/guess for 2023Q2 is 25% (after trying 19.1%)
% with discretionary govt demand shock as endogenous
% rngExog = qq(2023, 3);
% pln = exogenize(pln,  rngExog, 'gdem_y');
% pln = endogenize(pln, rngExog, 'shock_gdem_y_discr');
% tunes.gdem_y(rngExog) = 100 * log(1 + 25.0/100);



end



