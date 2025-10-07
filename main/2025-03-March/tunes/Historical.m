function dbObs = Historical(dbObs)  % 

% Sept 10'24: tuned INV gap (NISR INV data ignored 2023Q3-2024Q2) as shock huge (+60%)
% rngTune = qq(2024, 1);
% dbObs.tune_l_inv_gap(rngTune) = 25;
%% Evariste alt. scenario (INV, E-M suppressed for last 2Q and 4Q resp., requires tuning E
% rngTune = qq(2024, 1): qq(2024, 1);
% dbObs.tune_l_exp_gap(rngTune) = [-10];

% --------Set tune values for normal filter (hist data) or extended filter (prel./nowcast)-----
% do not create Series here! Only assign values to existing series, created in loop above

% avoid that trend bends down before Covid, so we set up outputgap low
% rngTune = qq(2019, 4);
% dbObs.tune_l_y_gap(rngTune) = 1;

% the outgap is set low to allow GDP level move close to trend to
% incoporate the assumption that COVID-19 outbreak has had a potential
% effect in GDP growth
rngTune = qq(2022, 4);
dbObs.tune_l_y_gap(rngTune) = -2;

% to allow somewhat significant effect of fiscal policies (gdem gap) on output gap in COVID, we allow the govt demand trend/structual bend  down during 2019-2023, 
% so we set gdem_y trend slightly lower y 2% points of GDP: bend down structural govt demand 2017-2023
% load results\mat\filter.mat
% dbObs.tune_gdem_y_str = dbFilt.mean.gdem_y_str;
%rngTune = qq(2017, 1): qq(2023,3);
%dbObs.tune_gdem_y_str(rngTune) = dbObs.tune_gdem_y_str-2;

%% easier: set structural level of govt demand
rngTune = qq(2017, 1): qq(2024, 2);
dbObs.tune_gdem_y_str(rngTune) = 24.5;

%% GDP extended filter for 2 Nowcast Q 2024Q3-4, possibly tune most recent Q with prel. NA
% filtration range set to a few Q beyond data (here: 2024Q2-2024Q3) with hist tunes for y-on-y GDP growth from Nowcast(no s.a. needed)
% filter distributes shocks among other FD, so movement in GDP not only attributed to cons shock (cf Baseline tune)
rngTune = qq(2025, 1) : qq(2025, 2);
dbObs.tune_d4l_y (rngTune) = 100 * log(1 + [8.6, 9.2]/100); % Nowcast March'25

%% CPI option to hard- or soft-tune CPIs based on NBR estimate or judgement and expected shocks
% CPI_core can be hard-tuned to match any NBR or prel. CPI forecast for 2024Q3--not used now
%rngTune = qq(2024, 3) : qq(2024, 3);
%dbObs.tune_shock_dl_cpi_core(rngTune) = 0;

% CPI_core hard-tune 2024Q3 based on NBR QPM forecast; not used now (NB these are s.a. see readData)
% rngTune = qq(2024, 3);
% dbObs.tune_dl_cpi_core(rngTune) = 100 * log(1 + 0/100);

% CPI_food could hard-tune with 2024Q3 BNR-FPAS-QPM forecast
rngTune = qq(2025, 1);
dbObs.tune_l_cpi_food(rngTune) = dbObs.obs_l_cpi_food;

% CPI_ener could soft-tune 2024Q3 for pump price effect of any excise tax change--not used now
% (NB 0.2 is share fuels in energy) 
% rngTune = qq(2024,3) : qq(2024,3);
% dbObs.tune_shock_dl_cpi_ener(rngTune) = 0;

% CPI_energy hard-tune with 24Q1 BNR-FPAS-QPM forecast--not used now
rngTune= qq(2025, 1);
dbObs.tune_l_cpi_ener(rngTune) = dbObs.obs_l_cpi_ener;

% CPI headline could be hard-tuned 2024Q3 based on NBR QPM forecast; not used now
% we can only tune 3 of 4 CPIs (NB these are s.a.,see readData)
rngTune = qq(2025, 1);
dbObs.tune_l_cpi(rngTune) = dbObs.obs_l_cpi;

%% exchange rate 2024Q3-4 for extended filter if tuned in BL forecast, eg with 11.8% annualized =PCI eop "target"
% or extrapolate ER path so far in 2024, ie 9% annualized lower than PCI target
% note Q1 2025 is already data, so entered dbObs.obs.l_s
% rngTune = qq(2025, 1);
% dbObs.tune_l_s(rngTune) = dbObs.obs_l_s; % tune dl_s, add in model tune_ declaration

rngTune = qq(2025, 2);
dbObs.tune_dl_s(rngTune) = 100 * log(1 + 0.08);

%% interest IB rate hard-tune 2024Q3 for extended filter as also tuned in BL forecast
%% (no change CBR, so IB 0.7% above av. CBR=6.8% 2024Q3)
rngTune = qq(2025, 2): qq(2025, 3);
dbObs.obs_i(rngTune) = dbObs.obs_i;

%% fiscal (deficit and govt revenue) hardtuned for extendedfilter thru 2024Q3

% govt revenue (discretionary revenue), alternative NOT used
% rngTune = qq(2024,3) : qq(2024,3);
% dbObs.tune_grev_y_discr(rngTune) = [0];

% govt revenue from PCI program in 2024/25 18.4% GDP assuming backloading for Q distr,FISCAL team to provide sem 
rngTune = qq(2025, 1) : qq(2025, 2);
dbObs.tune_grev_y(rngTune) = [18.6, 18.6];
% 
% % deficit GFS1986 tuned for 2024Q3-2024Q3 using PCI target 8.9% for 2024/25, but lower Q3 (not yet by sem,FISCAL team to provide..)
rngTune = qq(2025, 2) : qq(2025, 3);
dbObs.tune_def_y(rngTune) = [8.3, 8.3];

end
