function [tunes, pln, m] = Alternative(opts, m)

% NTF tuning of Q3 2022 thru Q1 2023(NB function name is tunes file name)
% version ZR Oct 28, adjustments SI and cleaning, updating cts AK
tmp = codes.loadResult(opts, "data");
dbObs = tmp.dbObs;
dbObsTrans = tmp.dbObsTrans;
dbOrig = tmp.dbOrig;

% Change model para, here for interest policy rule response to output gap
m.c3 = 0.2; % was 0.5, seems NBR less responsive to y_gap; IMF-NBR had 0.5 (for same persistence as we)
% m = solve(m);

rngFcast = opts.forecast.range;

tunes = struct;
pln   = Plan.forModel(m,rngFcast);

% External variables

pln = exogenize(pln,  rngFcast, 'dl_cpistar');
pln = endogenize(pln, rngFcast, 'shock_dl_cpistar');

pln = exogenize(pln,  rngFcast, 'l_ystar_gap');
pln = endogenize(pln, rngFcast, 'shock_l_ystar_gap');

pln = exogenize(pln,  rngFcast, 'istar');
pln = endogenize(pln, rngFcast, 'shock_istar');

pln = exogenize(pln,  rngFcast, 'rstar_tnd');
pln = endogenize(pln, rngFcast, 'shock_rstar_tnd');

%tune slower drop in energy and food prices in 23Q1 to 24Q4
%FOOD
%pln = exogenize(pln,  rngFcast, 'l_rp_foodstar_gap');
%pln = endogenize(pln, rngFcast, 'shock_dl_rp_foodstar_tnd');
% FOODSIM: 5,15,25,25,20,15,10,5% higher-than-BL foreign food price index for 2023-24 (8Q)
pln = exogenize(pln,  rngFcast, 'l_foodstar');
pln = endogenize(pln, rngFcast, 'shock_l_rp_foodstar_gap'); %shock rp gap endogenous!
rngFcastSIM = (qq(2023,1):qq(2024,4)); %range of simulated higher prices
foodsim = Series(rngFcastSIM, [log(1+0.05)*100,log(1+0.15)*100,log(1+0.25)*100,...
    log(1+0.25)*100,log(1+0.20)*100,log(1+0.15)*100,log(1+0.10)*100,log(1+0.05)*100]);
dbObs.obs_l_foodstar(rngFcastSIM) = dbObs.obs_l_foodstar + foodsim;  % "marks up" selected Q
%ENER
% pln = exogenize(pln,  rngFcast, 'l_rp_enerstar_gap');
% pln = endogenize(pln, rngFcast, 'shock_dl_rp_enerstar_tnd');
% ENERSIM: 5,15,25,25,20,15,10,5% higher than BL foreign energy price index for 2023-24 (8Q)
pln = exogenize(pln,  rngFcast, 'l_enerstar');
pln = endogenize(pln, rngFcast, 'shock_l_rp_enerstar_gap'); %shock rp gap endogenous!
rngFcastSIM = (qq(2023,1):qq(2024,4));
enersim = Series(rngFcastSIM, [log(1+0.05)*100,log(1+0.15)*100,log(1+0.25)*100,...
    log(1+0.25)*100,log(1+0.20)*100,log(1+0.15)*100,log(1+0.10)*100,log(1+0.05)*100]);
dbObs.obs_l_enerstar(rngFcastSIM) = dbObs.obs_l_enerstar + enersim; % "marks up" selected Q

tunes.dl_cpistar        = 4*diff(dbObs.obs_l_cpistar);
tunes.l_ystar_gap       = dbObs.obs_l_ystar_gap;
tunes.istar             = dbObs.obs_istar;
tunes.rstar_tnd         = dbObs.obs_rstar_tnd;
%tunes.l_rp_foodstar_gap = dbObs.obs_l_rp_foodstar_gap; %gap should give in, not be tuned
tunes.l_foodstar        = dbObs.obs_l_foodstar; %incl. price jumps for selected Q
%tunes.l_rp_enerstar_gap = dbObs.obs_l_rp_enerstar_gap; %gap should give in, not be tuned
tunes.l_enerstar        = dbObs.obs_l_enerstar; %incl. price jumps for selected Q

% Tune actual observed data, NTF or judgemnet forecast early in forecast horizon

% CPI: NBR QPM forecasts all CPI components a few Q ahead;as NBR has different CPI_food (incl. all food/bever)
% and different NTF for CPI_ener, so its CPI_core not comparable; so we use QMFM CPI_food, ener, core,
% our weights; we tune Q3-4 2022, using Q3 data and prel. Oct-Nov data for Q4. NBR has different numbers!) with expected further, declining shocks 
% We should not use shock_l_cpi (discrepancy shock!), but instead shock_dl_cpi_core as endogenous
%
% CORE hard tune Q3 data
rngExog = qq(2022, 3);
pln = exogenize(pln,  rngExog, 'dl_cpi_core');
pln = endogenize(pln, rngExog, 'shock_dl_cpi_core');
tunes.dl_cpi_core = dbObsTrans.obs_dl_cpi_core{rngExog};

% Core hard tune with prel. Oct-Nov data 14.6% Y-o-Y CPI core change
rngExog = qq(2022, 4);
pln = exogenize(pln,  rngExog, 'd4l_cpi_core');
pln = endogenize(pln, rngExog, 'shock_dl_cpi_core');
tunes.d4l_cpi_core = Series(rngExog, 100*log(1+14.6/100)); 
% we could soft-tune 2023 Q1 by imposing further shocks, if believed to continue
% tunes.shock_dl_cpi_core = Series(qq(2023,1), 5);

% CPI_food hard tune Q3 data
rngExog = qq(2022, 3);
pln = exogenize(pln,  rngExog, 'dl_cpi_food');
pln = endogenize(pln, rngExog, 'shock_dl_cpi_food');
tunes.dl_cpi_food = dbObsTrans.obs_dl_cpi_food{rngExog}; 

% CPI_food hard-tune with prel.Oct-Nov data 42.5% Y-o-Y change
rngExog = qq(2022, 4);
pln = exogenize(pln,  rngExog, 'd4l_cpi_food');
pln = endogenize(pln, rngExog, 'shock_dl_cpi_food');
tunes.d4l_cpi_food = Series(rngExog, 100*log(1+42.5/100)); 
% CPI_food soft-tune with further shock Q1, as pricing behavior believed to continue
tunes.shock_dl_cpi_food = Series(qq(2023,1), 5);
% other example of soft-tune continuing shocks: 
% tunes.shock_dl_cpi_food = Series(qq(2023,1):qq(2023,2), [0, 0]); 

% CPI_ener hard-tune Q3 data 
rngExog = qq(2022, 3);
pln = exogenize(pln,  rngExog, 'dl_cpi_ener');
pln = endogenize(pln, rngExog, 'shock_dl_cpi_ener');
tunes.dl_cpi_ener = dbObsTrans.obs_dl_cpi_ener{rngExog};

%  CPI_ener hard-tune with pre. Oct-Nov data  21.4% Y-o-Y change
rngExog = qq(2022, 4);
pln = exogenize(pln,  rngExog, 'd4l_cpi_ener');
pln = endogenize(pln, rngExog, 'shock_dl_cpi_ener');
tunes.d4l_cpi_ener = Series(rngExog, 100*log(1+21.4/100));
% CPI_ener soft-tune with further shock Q1, as pricing behavior believed to continue
% prices may fall less than WEO-GAS as govt may restore waived fuel excises
tunes.shock_dl_cpi_ener = Series(qq(2023,1), 3);
% other examp eof soft-tune continuing shocks:
% tunes.shock_dl_cpi_ener = Series(qq(2023,1):qq(2023,2), [0, 0]); 

% observed Interbank rate (IB) Q3 some 0.5% point above NBR policy rate (increased to 6% Aug 2022)
% Nov 20 another 0.5% increase keep same distance for IB. We did not use BNR QPM for IB, i, as it has huge response to high inflation. 
% ZR: given output gap and low expected inflation (one-time shocks),interest rate is smoothed (no further increase) for a few Q; 
% then, model forecasts slow rise to neutral rate (higher due to rising rstar) 
% IB (interbank) hard-tune Q3
rngExog = qq(2022, 3);
pln = exogenize(pln,  rngExog, 'i');
pln = endogenize(pln, rngExog, 'shock_i');
tunes.i = dbObs.obs_i{rngExog};

%IB hard-tune Q4 prel.data Q4 (increase in Nov) and Q1 based on judgement
% add two values to tunes.i, that series gets overlaid with i in calcForecast
% if we set interest rate, so logconversion as model variable i is logconversion
rngExog = qq(2022, 4): qq(2023, 1);
pln = exogenize(pln,  rngExog, 'i');
pln = endogenize(pln, rngExog, 'shock_i');
tunes.i(rngExog) = [100*log(1 + 6.5/100), 100*log(1+7.0/100)];

% GDP hard tune using Now/Forecasting real GDP Q3-4 (Sept 2022); if levels uses, must s.a.
% hard tune dl_y  but we could also tune l_y or l_y_gap; we should not endogenize shock_l_y_gap!

% if levels used: calculate seasonally adjusted (s.a.) NTF
% y = dbOrig.y;
% y(qq(2022,3):qq(2022,4)) = [2650, 2683];
% l_y = x12(100*log(y));
% dl_y = 4*diff(l_y);
% dl_y_su = 4*diff(100*log(y));
% then tune s.a. dl_y:  tunes.dl_y = Series(rngExog, dl_y_su(rngExog));
% 
% tuning Y-on-Y growth directly obtained from nowcasting or prel.data (no s.a. needed)
rngExog = qq(2022, 3);
pln = exogenize(pln,  rngExog, 'd4l_y');
pln = endogenize(pln, rngExog, 'shock_l_cons_gap');
tunes.d4l_y = Series(rngExog, 100*log(1+8.3/100));
% we have a now/forecast for Q4 (5% Y-on-Y) but not used

% soft-tune other final demand shocks, read from filter w/.historical tuning of output
tunes.shock_l_inv_gap = Series(rngExog, -1.2);
tunes.shock_l_exp_gap = Series(rngExog, -2.65);

% Exchange rate: hard-tune Q3 2022 using observed from dbObs 
rngExog = qq(2022, 3);
pln = exogenize(pln,  rngExog, 'l_s');
pln = endogenize(pln, rngExog, 'shock_l_s');
tunes.l_s = dbObs.obs_l_s{rngExog};

% hard-tune Q4 2022 and Q1'23 using NBR = IMF-program forecast (1060 end-2022, 7% depr 2023
% o/w one-fourth in Q1; we did not use BNR QPM results, has sharp appreciation!
rngExog = qq(2022, 4): qq(2023, 1);
pln = exogenize(pln,  rngExog, 'l_s');
pln = endogenize(pln, rngExog, 'shock_l_s');
tunes.l_s(rngExog) = [100*log(1056), 100*log(1056*(1+(0.07/4)))];

% Fiscal variables, esp. govt demand and deficit

% govt demand (G+IG) should come from Treasury plan Q3-4, Q1-2 but NOT YET; for now, tentative
% some 1-2% Q GDP spending impulse in Q3-4 to counter food/energy prices & slowdown (~IMF review)
% deficit 2022/23 excl (incl) grants is 13 (8)% of GDP, above structural deficit of 11% 
% govt demand gap hard tune (so deficit Q3-4 2022 close to 13% program FY2022/23)
% soft-tune Q3-4 2022 (no need to exogenize or endogenize)
rngExog = qq(2022, 3): qq(2022, 4);
tunes.shock_l_gdem_gap = Series(rngExog, [2, 0.7]);
% if you hard tune
% pln = exogenize(pln,  rngExog, 'l_gdem_gap');
% pln = endogenize(pln, rngExog, 'shock_l_gdem_gap');
% tunes.l_gdem_gap = Series(rngExog, [2, 2]);

% govt deficit in % GDP could come from Treasury plan Q3-4, Q1-2 but NOT YET, for now
% govt deficit hard tune
rngExog = qq(2022, 3) : qq(2023, 2);
pln = exogenize(pln,  rngExog, 'def');
pln = endogenize(pln, rngExog, 'shock_def_discr');
tunes.def = Series(rngExog, [13, 13, 13, 13]);
% alternative soft tune: tunes.shock_discr_def = Series(rngExog, [2, 2]);

end
