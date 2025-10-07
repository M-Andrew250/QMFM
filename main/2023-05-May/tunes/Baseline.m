function [tunes, pln, m] = Baseline(opts, m)

% -------- Load data --------

tmp = codes.loadResult(opts, "data");

dbObs       = tmp.dbObs;
dbObsTrans  = tmp.dbObsTrans;
dbOrig      = tmp.dbOrig;

% -------- Reset model parameters --------

% Change model para, here for interest policy rule response to output gap
m.c3 = 0.2; % was 0.5, seems NBR less responsive to y_gap; IMF-NBR had 0.5 (for same persistence as we)

% -------- Predefine tunes and the simulataion plan --------

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
  "d4l_gdem"
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

% Do not create Series here! Only assign values to existing series, created
% in the loop above.

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

% ----- NTF-s ------

% CORE hard tune Q1 data
rngExog = qq(2023, 1);
pln = exogenize(pln,  rngExog, 'dl_cpi_core');
pln = endogenize(pln, rngExog, 'shock_dl_cpi_core');
tunes.dl_cpi_core(rngExog) = dbObsTrans.obs_dl_cpi_core(rngExog);

% Core hard tune with prel. april data 11.4% Y-o-Y CPI core change
rngExog = qq(2023, 2);
pln = exogenize(pln,  rngExog, 'd4l_cpi_core');
pln = endogenize(pln, rngExog, 'shock_dl_cpi_core');
tunes.d4l_cpi_core(rngExog) = 100*log(1+11.4/100); 

% CPI_food hard tune Q1 data
rngExog = qq(2023, 1);
pln = exogenize(pln,  rngExog, 'dl_cpi_food');
pln = endogenize(pln, rngExog, 'shock_dl_cpi_food');
tunes.dl_cpi_food(rngExog) = dbObsTrans.obs_dl_cpi_food(rngExog); 

% CPI_food hard-tune with prel.April data 48.4% Y-o-Y change
rngExog = qq(2023, 2);
pln = exogenize(pln,  rngExog, 'd4l_cpi_food');
pln = endogenize(pln, rngExog, 'shock_dl_cpi_food');
tunes.d4l_cpi_food(rngExog) = 100*log(1+48.4/100); 

% CPI_ener hard-tune Q1 data 
rngExog = qq(2023, 1);
pln = exogenize(pln,  rngExog, 'dl_cpi_ener');
pln = endogenize(pln, rngExog, 'shock_dl_cpi_ener');
tunes.dl_cpi_ener(rngExog) = dbObsTrans.obs_dl_cpi_ener(rngExog);

%  CPI_ener hard-tune with pre. April data  4.4% Y-o-Y change
rngExog = qq(2023, 2);
pln = exogenize(pln,  rngExog, 'd4l_cpi_ener');
pln = endogenize(pln, rngExog, 'shock_dl_cpi_ener');
tunes.d4l_cpi_ener(rngExog) = 100*log(1+4.4/100);

% IB (interbank) hard-tune Q3
rngExog = qq(2023, 1);
pln = exogenize(pln,  rngExog, 'i');
pln = endogenize(pln, rngExog, 'shock_i');
tunes.i(rngExog) = dbObs.obs_i(rngExog);

rngExog = qq(2023, 2);
pln = exogenize(pln,  rngExog, 'i');
pln = endogenize(pln, rngExog, 'shock_i');
tunes.i(rngExog) = 100*log(1+7.0/100);

% tuning Y-on-Y growth directly obtained from May nowcasting/Forecasting Q1/Q2 or prel.data (no s.a. needed)
rngExog = qq(2023, 1): qq(2023,2);
pln = exogenize(pln,  rngExog, 'd4l_y');
pln = endogenize(pln, rngExog, 'shock_l_cons_gap');
tunes.d4l_y(rngExog) = [100*log(1+9.1/100), 100*log(1+6.1/100)];

% soft-tune other final demand shocks, read from filter w/.historical tuning of output
rngExog = qq(2023, 1);
tunes.shock_l_inv_gap(rngExog) = 1.1;
tunes.shock_l_exp_gap(rngExog) = 2.4;
tunes.shock_l_imp_gap(rngExog) = -0.04;

% Exchange rate: hard-tune Q1 2023 using observed from dbObs 
rngExog = qq(2023, 1);
pln = exogenize(pln,  rngExog, 'l_s');
pln = endogenize(pln, rngExog, 'shock_l_s');
tunes.l_s(rngExog) = dbObs.obs_l_s(rngExog);

% hard-tune Q2 2023 using NBR = IMF-program forecast ( 15%/4 depr 2023
% applied to   Q1 2023 observed)
rngExog = qq(2023, 2);
pln = exogenize(pln,  rngExog, 'l_s');
pln = endogenize(pln, rngExog, 'shock_l_s');
tunes.l_s(rngExog) = 100*log(1092.8 * (1+0.15/4));

% Fiscal variables, esp. govt demand and deficit

% govt demand (G+IG) should come from Treasury plan Q3-4, Q1-2 but NOT YET; for now, tentative
% govt demand is based on gvt demand g&s in Fiscal agreed with IMF Program
% sem 2 2022/23 over 2021/22 found nominal growth of 12%, discounted using
% 12% NA deflator extrapolated to 2023 using ann. gdem deflator of 2023....
rngExog = qq(2023, 1): qq(2023, 2);
pln = exogenize(pln,  rngExog, 'd4l_gdem');
pln = endogenize(pln, rngExog, 'shock_gdem_y_discr');
tunes.d4l_gdem(rngExog) = [0, 0];

% govt deficit in % GDP could come from Treasury plan 2022/23 sem 2 - 2023/24 but NOT YET, for now
% govt deficit hard tune for PCI/RSF first sem beakdown of 2023 fiscal deficit of PCI
% Shock choosen from one of three shocks indirectly affect Deficit(
% remaining shock w/c is not used was oexp shock).
rngExog = qq(2023,1) : qq(2023, 2);
pln = exogenize(pln,  rngExog, 'def_y');
pln = endogenize(pln, rngExog, 'shock_oexp_y_discr');
tunes.def_y(rngExog) = [12.1, 12.1];

% ----- Forecast tunes -----

% Tune the deficit in the IMF program: partially by a hard tune on gdem, and
% partially by a soft tune on oexp
rngExog = qq(2023,3) : qq(2024, 2);
pln = exogenize(pln,  rngExog, 'def_y');
pln = endogenize(pln, rngExog, 'shock_gdem_y_discr');
tunes.def_y(rngExog) = [9.6, 9.6, 9.6, 9.6];
tunes.shock_oexp_y_discr(rngExog) = [-3, -3, -3, -3];

% Hard tunes discretionary revenue to GDP reflecting drop in non-tax revenue and lagging of  revenue base relative to inflation. 
rngExog = qq(2023,1) : qq(2024, 2);
pln = exogenize(pln,  rngExog, 'grev_y_discr');
pln = endogenize(pln, rngExog, 'shock_grev_y_discr');
tunes.grev_y_discr(rngExog) = [-1, -1, -0.9, -0.9, -0.8, -0.8];

end
