function dbObs = Historical(dbObs)  % 

% --------Set tune values for normal filter (hist data) or extended filter (prel./nowcast)-----
% do not create Series here! Only assign values to existing series, created in loop above

% avoid that trend bends down before Covid, so we set outputgap low
rngTune = qq(2019, 4);
dbObs.tune_l_y_gap(rngTune) = 1;

% to allow somewhat significant effect of fiscal policies (gdem gap) on output gap in COVID, we allow the govt demand trend/structual bend  down during 2019-2023, 
%so we set gdem_y trend slightly lower
% load results\mat\filter.mat
% dbObs.tune_gdem_y_str = dbFilt.mean.gdem_y_str;
% rngTune = qq(2017, 1): qq(2023,2);
% dbObs.tune_gdem_y_str(rngTune) = dbObs.tune_gdem_y_str-2;

%bend down structural govt demand 2017-2023
%higher expansionary fiscal stance during Covid and lower contractionary stance thereafte
%lower gdem_y_str by 1--1.5 % or tune each Q of that range, by setting gdem_y_str 1-2% below the outcome of the original filter
%QoTunes = [25.7-1,25.8-1,25.7-1,25.7-1,25.7-1,25.9-1.5,25.8-1.5,25.9-1.5, 25.8-1.5,25.8-2,25.6-1,25.5-1,25.5-1,25.8-1.8,25.8-1.8,26.0-2,26.1-2,26.2-2,26.1-2,25.9-2,25.7-1.8,25.6-1.8,25.7-1,25.8-1.8,25.9-2,26-2];
rngTune = qq(2017, 1): qq(2023,2);
dbObs.tune_gdem_y_str(rngTune) = 24.5;

% Extended filter until 2023 Q4
% filtration range set to 2023Q3 (or Q4) with hist tunes for y-on-y GDP growth from Oct nowcast exercise (no s.a. needed)
% filter distributes shocks among other FD, so that movement in GDP not only attributed to cons shock
rngTune = qq(2023,3) : qq(2023,4);
dbObs.tune_d4l_y (rngTune) = 100 * log(1 + [5.2, 5.0]/100); 

% CPI_core soft-tun to ensure NBR-set CPI 4 does not lead to large foodprice shock
% since indications are that food prices are declining
rngTune = qq(2023,4) : qq(2023,4);
dbObs.tune_shock_dl_cpi_core(rngTune) = 6;

% CPI_ener soft-tune Q3-4 for 5.6% tax increase earlyAug ann.* 0.2 share fuels in energy 
% Oct4 11% pumpprice is petr-price-mech,captured in model eq.; spread Q3-4: 3 - 1.5%
rngTune = qq(2023,4) : qq(2023,4);
dbObs.tune_shock_dl_cpi_ener(rngTune) = 1.5;

% exhange rate for Q4 for filter as tuned in the baseline/forecast
rngTune = qq(2023,4);
dbObs.tune_dl_s(rngTune) = 100 * log(1 + 0.15/4-0.01); % tune dl_s, add in model tune_ declaration

% interest rate hard tuned for Q4 for filter as tuned  in the baseline/forecast
rngTune = qq(2023,4);
dbObs.obs_i(rngTune) = 100 * log(1 + 8.0/100);

% fiscal (deficit and govt revenue) hard tune for filter until Q4
% govt revenue (discretional/other revenue)
% rngTune = qq(2023,3) : qq(2023,4);
% dbObs.tune_grev_y_discr(rngTune) = [-1.0, -1.0];

% govt revenue (tax & non-tax) from PCI program in 2023/24 Qo 4-assuming equal quartely distribution 
rngTune = qq(2023, 3) : qq(2023, 4);
dbObs.tune_grev_y(rngTune) = [17.8, 17.8];

% Deficit
rngTune = qq(2023,3) : qq(2023,4);
dbObs.tune_def_y(rngTune) = [10.8-1, 10.8-1];


end
