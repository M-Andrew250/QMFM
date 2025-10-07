function dbObs = Historical(dbObs)  % 

% --------Set tune values for normal filter (hist data) or extended filter (prel./nowcast)-----
% do not create Series here! Only assign values to existing series, created in loop above

% avoid that trend bends down before Covid, so we set outputgap low
rngTune = qq(2019, 4);
dbObs.tune_l_y_gap(rngTune) = 1;

% to allow somewhat significant effect of fiscal policies (gdem gap) on output gap in COVID, we allow the govt demand trend/structual bend  down during 2019-2023, 
% so we set gdem_y trend slightly lower y 2% points of GDP: bend down structural govt demand 2017-2023
% load results\mat\filter.mat
% dbObs.tune_gdem_y_str = dbFilt.mean.gdem_y_str;
%rngTune = qq(2017, 1): qq(2023,3);
%dbObs.tune_gdem_y_str(rngTune) = dbObs.tune_gdem_y_str-2;
%% easier: set structural level of govt demand
rngTune = qq(2017, 1): qq(2023,3);
dbObs.tune_gdem_y_str(rngTune) = 24.5;

%% GDP extended filter for 2 Nowcast Q thru 2024Q1, tune 2023Q4 with prel. NA
% filtration range set to a few Q beyond data (here: 2023Q4-2024Q1) with hist tunes for y-on-y GDP growth from Nowcast(no s.a. needed)
% filter distributes shocks among other FD, so that movement in GDP not only attributed to cons shock
rngTune = qq(2023,4) : qq(2024,1);
dbObs.tune_d4l_y (rngTune) = 100 * log(1 + [10, 9]/100); 

%% CPI option to hard- or soft-tune CPIs based on NBR estimates/judgement and expected shocks
% CPI_core hard tune to match any NBR CPI forecast for 2024Q1--not used now
%rngTune = qq(2024,1) : qq(2024,1);
%dbObs.tune_shock_dl_cpi_core(rngTune) = 0;
% CPI_core hard-tune 2024Q1 based on NBR QPM forecast; not used now  
% (NB these are s.a., see readData)
% rngTune = qq(2024, 1);
% dbObs.tune_dl_cpi_core(rngTune) = 100*log(1 + 4.5/100);

% CPI_food hard-tune with 24Q1 BNR-FPAS-QPM forecast
% rngTune = qq(2024, 1);
% dbObs.tune_dl_cpi_food(rngTune) = 100*log(1 + -3.6/100);

% CPI_ener soft-tune 2024Q1 for pump price effect of any excise tax change--not used now
% (NB 0.2 is share fuels in energy) 
%rngTune = qq(2024,1) : qq(2024,1);
%dbObs.tune_shock_dl_cpi_ener(rngTune) = 0;

% CPI_energy hard-tune with 24Q1 BNR-FPAS-QPM forecast 
% rngTune= qq(2024, 1);
% dbObs.tune_dl_cpi_ener(rngTune) = 100*log(1 + 4.9/100);

% CPI headline hard-tune 2024Q1 based on NBR QPM forecast; not used now
% we can only tune 3 of 4 CPIs (NB these are s.a.,see readData)
% rngTune = qq(2024, 1);
% dbObs.tune_dl_cpi(rngTune) = 100*log(1 + -0.8/100);

%% exchange rate for 2024Q1 for ext.filter if tuned in BL forecast, eg with 8.25% annualized
rngTune = qq(2024,1);
dbObs.tune_dl_s(rngTune) = 100 * log(1 + 0.0825); % tune dl_s, add in model tune_ declaration

%% interest IB rate hard-tune 2024Q1 for ext.filter as also tuned in BL forecast (no change CBR, so IB 8%)
rngTune = qq(2024, 1);
dbObs.obs_i(rngTune) = 100 * log(1 + 8.0/100);

%% fiscal (deficit and govt revenue) hardtuned for ext.filter thru 2024Q1

% govt revenue (discretionary revenue), alternative NOT used
% rngTune = qq(2023,4) : qq(2024,1);
% dbObs.tune_grev_y_discr(rngTune) = [-1.0, -1.0];

% govt revenue from PCI program in 2023/24 assuming more or less equal Q distribution 
rngTune = qq(2023, 4) : qq(2024, 1);
dbObs.tune_grev_y(rngTune) = [17.7, 17.9];

% deficit tuned for 2023Q4-2024Q1 as Nov2023 round but now thru 2024Q1
rngTune = qq(2023, 4) : qq(2024, 1);
dbObs.tune_def_y(rngTune) = [10.8-1, 11.8];

end
