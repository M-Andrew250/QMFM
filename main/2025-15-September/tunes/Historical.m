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

%% GDP extended filter for Nowcast Q 2025Q3, alternatively tune most recent Q with prel. NA
% filtration range set to a few Q beyond data (here: 2025Q3 with hist tunes for y-on-y GDP growth from Nowcast(no s.a. needed)
% filter distributes shocks among other FD, so movement in GDP not only attributed to cons shock (cf Baseline tune)
rngTune = qq(2025, 3) : qq(2025, 3);
dbObs.tune_d4l_y (rngTune) = 100 * log(1 + (7.7)/100); % Nowcast Sept'25

%%CPI option to soft/hard-tune CPIs Near-Term based on NBR-forecast/judgement, expected shocks
% CPI_core can be soft-tuned to match any NBR or prel. CPI forecast for later Q--not used now
% rngTune = qq(2025, 4) : qq(2025, 4);
% dbObs.tune_shock_dl_cpi_core(rngTune) = 0;
% 
% CPI_core hard-tune 2025Q4 based on NBR forecast/judgment (NB these are s.a. see readData)
% rngTune = qq(2025, 4);
% dbObs.tune_dl_cpi_core(rngTune) = [....] or 100 * log(1+0/100);

% CPI_food hard-tune with 2025Q4 NBR forecast or judgment
%rngTune = qq(2025, 4): qq(2025, 4);
%dbObs.tune_l_cpi_food(rngTune) = [....];
 
% CPI_ener could soft-tune 2025Q4 for pump price effect of any excise tax change--not used now
% (NB 0.2 is share fuels in energy) 
% rngTune = qq(2025, 4) : qq(2025, 4);
% dbObs.tune_shock_dl_cpi_ener(rngTune) = 0;

% CPI_energy hard-tune with 2025Q4 NBR forecast or judgment
% rngTune= qq(2025, 4): qq(2025, 4);
% dbObs.tune_dl_cpi_ener(rngTune) = [....];
 
% CPI headline could be hard-tuned with 2025Q4 forecast or judgment
% we can only tune 3 of 4 CPIs (NB these are s.a.,see readData)
% rngTune = qq(2025, 4);
% dbObs.tune_l_cpi(rngTune) = [....];

% ER hard-tuned for extended filter 2025Q4 if tuned in BL,eg % annualized =PCIeop target
% with realization ER thru 2025Q3 at x% (Q-on-Q), the annualized remainder is x%
% note 2025Q3 is already data, so entered as dbObs.obs.l_s in readData
% rngTune = qq(2025, 4); %for Historical, one wouldn't tune to set equal to data!
% dbObs.tune_l_s(rngTune) = dbObs.obs_l_s; % tune dl_s, added in model tune_ declaration

% rngTune = qq(2025, 4) : qq(2025, 4); % tune to guessed number
% dbObs.tune_dl_s(rngTune) = 100* log(1+0.0x);

% interest IB rate hard-tune for extended filter thru 2025Q3-4 if also tuned in BL
% (e.g. no change CBR, so IB 0.3% above CBR=6.75% 2025Aug)
% rngTune = qq(2025, 4) : qq(2025, 4);
% dbObs.obs_i(rngTune) = 100 * log(1 + 7.05/100);

%% fiscal (deficit and govt revenue) hardtuned for extended filter thru 2024Q3

% govt revenue (discretionary revenue), alternative NOT used
% rngTune = qq(2025,3) : qq(2025,3);
% dbObs.tune_grev_y_discr(rngTune) = [0];

% govt revenue from PCI program in 2025/26 18.3% GDP, semI 17.8%, semII 18.8% 
% rngTune = qq(2025, 2) : qq(2025, 3);
% dbObs.tune_grev_y(rngTune) = [19, 18.6];
% % 
%% deficit GFS1986 tuned for 2025Q1-2 w. PCI target 8.6% for 2024/25, semI 9.4%, semII 7.8%
% rngTune = qq(2025, 2) : qq(2025, 3);
% dbObs.tune_def_y(rngTune) = [7.8, 7.8];

end
