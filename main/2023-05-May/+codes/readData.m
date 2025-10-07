function readData

opts = mainSettings();

codes.writeMessage("readData: reading XLS data files ...");

% Read foreign real interest rate trend and oil from GPM database
gpm = databank.fromCSV(fullfile("data", "gpm_forecast_20221026.csv"));
dbObs.obs_rstar_tnd   = gpm.RR_BAR_US;
dbObs.obs_l_enerstar  = 100*log(gpm.OIL_US);

% Read the Excel database

t = readtable("data/Rwametric.xlsm", ...
  "Sheet",    "Quarterly data", ...
  "TextType", "string"); %optional'VariableNamingRule','preserve'

% WEO-GEE/GAS data

% External demand: trade weighted GDP growth Q/Q(-4) all tradpartners,
% WEO-GEE needs correction i.e. give annualized Q/Q(-1) instead
ind                   = t{:,1} == "ystar";
values                = t{ind, 3:end}';
ystar                 = Series(qq(1995, 1), values);
dl_ystar              = log(1 + ystar);
l_ystar               = cumsum(dl_ystar/4); % l_ystar{0} ystar=level missing
% Calc foreign outputgap from WEO-GEE all of Rwanda's trading partners, 
l_ystar_gap           = hpf2(l_ystar);
dbObs.obs_l_ystar_gap = 100*l_ystar_gap;
% AK optional also get trend from hpf
l_ystar_tnd           = hpf(l_ystar);
dbObs.obs_l_ystar_tnd = 100*l_ystar_tnd;

% Foreign CPI trade weighted CPI growth (t/t-4) adv tradpartner (needs correction)
ind                 = t{:,1} == "cpistar";
dl_cpistar          = Series(qq(1995,1), log(1 + t{ind, 3:end})');
dbObs.obs_l_cpistar = 100*cumsum(dl_cpistar/4);

% Foreign oil prices: WEO-GAS petroleum spot priceUS$
% ind                   = t{:,1} == "enerstar";
% dbObs.obs_l_enerstar  = Series(qq(1995,1), 100*log(t{ind, 3:end})');
% before and alternative: WEO-GEE petrol spot price %change, provided it's Q/Q(-1)
% dl_enerGEEstar       = Series(qq(1995,1), log(1 + t{ind, 3:end})');
% dbObs.obs_l_enerstar = 100*cumsum(dl_enerGEEstar/4);

% Foreign relative oil price gap
dbObs.obs_l_rp_enerstar_gap = hpf2(dbObs.obs_l_enerstar - dbObs.obs_l_cpistar);

% Foreign food prices: WEO-GAS food prices in US$
ind                   = t{:,1} == "foodstar";
dbObs.obs_l_foodstar  = Series(qq(1995,1), 100*log(t{ind, 3:end})');

% Foreign relative food price gap
dbObs.obs_l_rp_foodstar_gap = hpf2(dbObs.obs_l_foodstar - dbObs.obs_l_cpistar);

% Foreign nominal interest rate WEO-GAS 6-mos LIBOR $deposits
ind = t{:,1} == "istar";
dbObs.obs_istar = Series(qq(1995, 1), 100*log(1 + t{ind, 3:end}/100)');

% Export price WEO-GEE import-nonoil deflator all tradpartners US$(~intMF)
ind                 = t{:,1} == "pexpstar";
dbAux.dl_pexpstar   = Series(qq(1995,1), 100*log(1 + t{ind, 3:end})');

% Import price WEO-GEE export-nonoil deflator all tradpartners US$(~intMF)
ind                 = t{:,1} == "pimpstar";
dbAux.dl_pimpstar   = Series(qq(1995,1), 100*log(1 + t{ind, 3:end})');

% Domestic data

% Exchange rate RWF/US$ three-mos average NBR data
ind = t{:,1} == "s";
s = Series(qq(1995, 1), t{ind, 3:end}');
dbObs.obs_l_s = 100*log(s);

% GDP, real NatActs constant prices KP (cons=privateC, gcons=govtC)

ind = t{:,1} == "y";
y   = Series(qq(1995, 1), t{ind, 3:end}');
% add agric GDP for possible inclusion in food inflation eq.
ind = t{:,1} == "y_agr";
y_agr = Series(qq(1995, 1), t{ind, 3:end}');

ind   = t{:,1} == "cons";
cons  = Series(qq(1995, 1), t{ind, 3:end}');

ind   = t{:,1} == "inv";
inv   = Series(qq(1995, 1), t{ind, 3:end}');

ind     = t{:,1} == "gcons";
gcons   = Series(qq(1995, 1), t{ind, 3:end}');

ind   = t{:,1} == "exp";
exp   = Series(qq(1995, 1), t{ind, 3:end}');

ind   = t{:,1} == "imp";
imp   = Series(qq(1995, 1), t{ind, 3:end}');

% GDP, nominal NatActs current prices (not transition variables)

ind     = t{:,1} == "ny";
ny      = Series(qq(1995, 1), t{ind, 3:end}');
% add agricultural GDP for possible inclusion in food inflation
ind = t{:,1} == "ny_agr";
ny_agr = Series(qq(1995, 1), t{ind, 3:end}');

ind     = t{:,1} == "ncons";
ncons   = Series(qq(1995, 1), t{ind, 3:end}');

ind     = t{:,1} == "ninv";
ninv    = Series(qq(1995, 1), t{ind, 3:end}');

ind     = t{:,1} == "ngcons";
ngcons  = Series(qq(1995, 1), t{ind, 3:end}');

ind     = t{:,1} == "nexp";
nexp    = Series(qq(1995, 1), t{ind, 3:end}');

ind     = t{:,1} == "nimp";
nimp    = Series(qq(1995, 1), t{ind, 3:end}');

% Government investment, deduct govt inv from Fiscal--> only private

ind   = t{:,1} == "nginv";
%nginv  = Series(qq(1995, 1), t{ind, 3:end}');
nginv1  = Series(qq(1995, 1):qq(2019,2), t{ind, 3:100}'); %GFS1986 needs adj factor
nginv2  = Series(qq(2019, 3), t{ind, 101:end}'); % GFS2014, column# database
nginv   = [nginv1 * 0.8 ; nginv2 * 1.0]; % adj 80% for GFS1986 data <2019

pinv  = ninv / inv;   % Calc overall investment deflator from NA
ninv  = ninv - nginv; % Remove govt inv to get private inv, residual
inv   = ninv / pinv;  % Calc real private inv using overall inv deflator
ginv  = nginv / pinv;
% Name 'gov demand' (NA) = gov cons+inv (ngexp Fiscal: add transf/subs/int)
ngdem = ngcons + nginv;

% adjust NA data for real cons and inv in 2020 Q2-Q3 CHECK
cons(qq(2020,2))=cons(qq(2020,2)) + 100; % seems cons drop was overestimated
inv(qq(2020,2))=inv(qq(2020,2)) - 100; % seems cons rise was overestimated
cons(qq(2020,3))=cons(qq(2020,3)) - 100;
inv(qq(2020,3))=inv(qq(2020,3)) + 100;

dbObs.obs_l_y       = x12(100*log(y));
dbObs.obs_l_y_agr   = x12(100*log(y_agr));
% for agric output gap (we do AR(1) eq): to enter food inflation
dbObs.obs_l_y_agr_gap   = hpf2(100*log(y_agr));

dbObs.obs_l_cons    = x12(100*log(cons));
dbObs.obs_l_inv     = x12(100*log(inv));
dbObs.obs_l_gdem    = x12(100*log(gcons + ginv));% addition
dbObs.obs_l_exp     = x12(100*log(exp));
dbObs.obs_l_imp     = x12(100*log(imp));

dbOrig.y      = y;
dbOrig.cons   = cons;
dbOrig.inv    = inv;
dbOrig.gcons  = gcons;
dbOrig.ginv   = ginv;
dbOrig.gdem   = gcons + ginv;
dbOrig.exp    = exp;
dbOrig.imp    = imp;

% save nominal levels in auxiliary database
dbAux.ncons    = ncons; %added AK 4/19/2023
dbAux.ninv     = ninv;  %added AK 4/19/2023
dbAux.nexp    = nexp;
dbAux.nimp    = nimp;
dbAux.ny      = ny;
dbAux.tb_rat  = 100*(nexp - nimp) / ny;
%ak include govt ependiture (demand NA; nominal bln RWF) in dbAux 
dbAux.ngdem   = ngdem;
dbAux.nginv   = nginv;

% CPI from quarterly data XLS, nb column 3 has weights
ind   = t{:,1} == "cpi";
dbOrig.l_cpi_su = Series(qq(1995,2), 100*log(t{ind, 4:end})');
%ak also put CPI in dbObs, compare with dbObsTrans.obs_l_cpi
dbObs.obs_l_cpi  =  x12(dbOrig.l_cpi_su);

% CPI food
ind                   = t{:,1} == "cpi_food";
dbOrig.l_cpi_food_su  = Series(qq(1995,2), 100*log(t{ind, 4:end})');
dbObs.obs_l_cpi_food  = x12(dbOrig.l_cpi_food_su);

% CPI energy
ind                   = t{:,1} == "cpi_ener";
dbOrig.l_cpi_ener_su  = Series(qq(1995,2), 100*log(t{ind, 4:end})');
dbObs.obs_l_cpi_ener  = x12(dbOrig.l_cpi_ener_su);

% CPI core not used from data but calc (missing <2009); CPI comp missing <2004
 
% ind         = t{:,1} == "cpi_core";
% l_cpi_core  = x12(Series(qq(1995,2), 100*log(t{ind, 4:end})'));
% weights from Rwametric-CPI, not read (can adapt to NBR's choice)
w_core = 7747/10000;
w_food = 1577/10000; %NBR has 0.28 incl. all food, beverages
w_ener =  676/10000;

dbOrig.l_cpi_core = (dbOrig.l_cpi_su - w_food * dbOrig.l_cpi_food_su - w_ener * dbOrig.l_cpi_ener_su) / w_core;
dbObs.obs_l_cpi_core  = (dbObs.obs_l_cpi - w_food * dbObs.obs_l_cpi_food - w_ener * dbObs.obs_l_cpi_ener) / w_core;

% Nominal interest rate (interbank rate)
ind         = t{:,1} == "i_ib";
dbObs.obs_i_ib = Series(qq(1995, 1), 100*log(1 + t{ind, 3:end}/100)');

% Nominal interest rate (NBR dbObs.i_ib policy rate) not used; alt: reverse/repo 
ind         = t{:,1} == "i_pol";
dbObs.obs_i_pol = Series(qq(1995, 1), 100*log(1 + t{ind, 3:end}/100)');

% Nominal interest rate (NBR repo rate)
ind         = t{:,1} == "i_repo";
dbObs.obs_i_repo = Series(qq(1995, 1), 100*log(1 + t{ind, 3:end}/100)');

% Nominal interest rate (NBR reverse repo rate)
ind         = t{:,1} == "i_rev_repo";
dbObs.obs_i_rev_repo = Series(qq(1995, 1), 100*log(1 + t{ind, 3:end}/100)');
dbObs.obs_i = dbObs.obs_i_ib;

% Deficit ratio from Fiscal revenue and expenditure nominal data
ind   = t{:,1} == "ngrev";
ngrev  = Series(qq(1995, 1), t{ind, 3:end}');
grev_y = x12(100*ngrev/ny); % EvM added to save govt revenue % GDP in dbObs
dbObs.obs_grev_y = grev_y; % EvM added to save govt revenue % GDP in dbObs

ind   = t{:,1} == "ngexp";
ngexp  = Series(qq(1995, 1), t{ind, 3:end}');
gexp_y = x12(100*ngexp/ny); % EvM added to save gexp % GDP in dbObs

% def = (gdem_y + oexp_y) - grev_y, gexp_y = (gdem_y + oexp_y)
%other expense % GDP (AK corrected 5/6/2023)
gdem_y = x12(100*ngdem/ny); % EvM/AK added to read gdem % GDP in dbObs
oexp_y = gexp_y - gdem_y; % EvM added to read oexp % GDP in dbObs

%ak include govt rev and exp FISCAL (nom. bln RWF) in dbAux database
dbAux.ngrev    = ngrev;
dbAux.ngrev_ny = x12(100*ngrev/ny);
dbAux.ngexp    =  ngexp;
dbAux.ngexp_ny = x12(100*ngexp/ny);

% deficit before grants (incl netlending, GFS1986, s.a., % nom GDP
%dbObs.obs_def_y = x12(100*(ngexp - ngrev)/ny);

% total govt ("net foreign") grants from Fiscal bln RWF, is transition variable
% see also below: in $mln from BOP put in dbAux BOP auxiliary variable
ind   = t{:,1} == "nfg";
nfg  = Series(qq(1995, 1), t{ind, 3:end}');
dbObs.obs_grants = x12(100*nfg/ny);

% Money stock or demand 
ind = t{:,1} == "md";
dbObs.obs_l_md = x12(Series(qq(1995, 1), 100*log(t{ind, 3:end})'));

% Monetary aux.stock variables: reserve money rm, nfa_nbr, ncg_nbr
ind = t{:,1} == "rm";
dbAux.l_rm = x12(Series(qq(1995, 1), 100*log(t{ind, 3:end})'));
ind = t{:,1} == "nfa_nbr";
dbAux.nfa_nbr = x12(Series(qq(1995, 1),t{ind, 3:end}'));
ind = t{:,1} == "ncg_nbr";
dbAux.ncg_nbr = x12(Series(qq(1995, 1),t{ind, 3:end}'));

% Monetary aux. stock variables mon survey (ms): nfa, nda, ncg_ms

% Interest rate lending premium, vis-a-vis interbank rate
% note IMF-NBR-WP define premium of interbank rate vis-a-vis reverse/repo rate
ind = t{:,1} == "i_lend";
i_lend = Series(qq(1995, 1), 100*log(1 + t{ind, 3:end}/100)');
dbObs.obs_prem_d = i_lend - dbObs.obs_i;

% Government debt (fcy external, read in mln$, lcy domestic, read in blnRWF)
% external debt converted to bln RWF; interest read in bln RWF FISCAL

ind = t{:,1} == "ndebt_fcy";
ndebt_fcy = Series(qq(1995, 1), t{ind, 3:end}');
ndebt_fcy = ndebt_fcy * s / 1000;

ind = t{:,1} == "ndebt_lcy";
ndebt_lcy = Series(qq(1995, 1), t{ind, 3:end}');

ind = t{:,1} == "nintp_fcy";
nintp_fcy = Series(qq(1995, 1), t{ind, 3:end}');

nintp_fcy_smooth = convert(convert(nintp_fcy,'a','method', @mean), 'q');

ind = t{:,1} == "nintp_lcy";
nintp_lcy = Series(qq(1995, 1), t{ind, 3:end}');

% Q interest payments in % of Quarterly nominal GDP
dbAux.intp_fcy = 100 * nintp_fcy_smooth / ny;
dbAux.intp_lcy = 100 * nintp_lcy / ny;
% debts in % of quarterly nominal GDP (debt ratio blownup by *4)
dbAux.debt_fcy = 100 * ndebt_fcy / ny;
dbAux.debt_lcy = 100 * ndebt_lcy / ny;
% add debt, else problem in Forecast, as debt previous Q doesnot exist
dbAux.debt = dbAux.debt_fcy + dbAux.debt_lcy;

% interest rates (interest payments over nominal debt (interests blownup)
dbAux.i_debt_fcy = 400 * nintp_fcy / ndebt_fcy{-1};
dbAux.i_debt_lcy = 400 * nintp_lcy / ndebt_lcy{-1};

% BOP capital and monetary stocks/flows

% Foreign DI and other net private flows, from BOPdata mln$, used in aux.BOP mln$
% (d = difference, B = owed stock)
ind = t{:,1} == "dBP1$";
dBP1 = Series(qq(1995, 1), t{ind, 3:end}');

ind = t{:,1} == "dBP2$";
dBP2 = Series(qq(1995, 1), t{ind, 3:end}');

ind = t{:,1} == "dBPG$_eurobond"; % BoP includes it under private, need correct for this
dBPG_eurobond = Series(qq(1995, 1), t{ind, 3:end}');

dbAux.dBP_usd = dBP1 + dBP2 - dBPG_eurobond; % private flows excl eurobonds going to Budget
dbAux.dBPG_eurobond = dBPG_eurobond;

dbAux.BP = 1650 + cumsum(dBP1+dBP2-dBPG_eurobond); % initial stock mln $ end-1997
dbAux.l_BP = 100 * log(dbAux.BP); 

% Foreign government borrowing, (from 1 Fiscal, 3 debt stock, or 2 BOP)
% from 1 Fiscal flow (bln RWF, includes Eurobonds; still problem with BNR buyback....)
% (d = difference, B = owed stock G or P is Govt or Private)
ind = t{:,1} == "dBG";
dBG = Series(qq(1995, 1), t{ind, 3:end}');
dbAux.dBG_usd = dBG /s * 1000;

% 3 debt stock (bln RWF) NOT USED
%dbAux.dBG_usd = diff(ndebt_fcy / s * 1000);

% 2 net borrowing from BOP (mln$)used for comparison only
ind = t{:,1} == "dBG$";
dbAux.dBG_bop_usd = Series(qq(1995, 1), t{ind, 3:end}');

% Foreign grants govt ("net foreign grants" from 1 Fiscal,to mln$)
dbAux.NFG_usd = nfg / s * 1000;

%NOT used: Foreign grants govt curr and cap from 2 BOP mln$
% ind = t{:,1} == "nfg$_cur";
% nfg_usd_cur = Series(qq(1995, 1), t{ind, 3:end}');
% ind = t{:,1} == "nfg$_cap";
% nfg_usd_cap = Series(qq(1995, 1), t{ind, 3:end}');
% dbAux.NFG_bop_usd = nfg_usd_cur + nfg_usd_cap;

% Domestic non-bank and bank financing (net, bln RWF)
ind = t{:,1} == "dBnbf";
dBnbf = Series(qq(1995, 1), t{ind, 3:end}');
dbAux.dBnbf = dBnbf;

ind = t{:,1} == "dBbf";
dBbf = Series(qq(1995, 1), t{ind, 3:end}');
dbAux.dBbf = dBbf;
% Use fiscal bank financing data/proj as NCG in monetary flow equilibrium
dbAux.NCG = Series(qq(1995, 1), t{ind, 3:end}');

% statistical dicrepancy ( (rev+grants) - (gov.exp + net financing))
% + over financing and - under financing
stat_discrp = ngrev + nfg - ngexp + dBG + dBbf + dBnbf;

ngexp_adj = ngexp + stat_discrp/2;

%ak include govt rev and exp FISCAL (nom. bln RWF) in dbAux database
dbAux.ngrev    = ngrev;
dbAux.ngrev_ny = x12(100*ngrev/ny);
dbAux.ngexp    =  ngexp;
dbAux.ngexp_adj    =  ngexp_adj; % adjusted on stast discrepancy
%dbAux.ngexp_ny = x12(100*ngexp/ny);
dbAux.ngexp_ny = x12(100*ngexp_adj/ny);

dbObs.obs_def_y = x12(100*(ngexp_adj - ngrev)/ny);


% Transform all variables

dbObsTrans = dbObs;

% Fiscal

dbObsTrans.obs_gdem_y = gdem_y;
dbObsTrans.obs_oexp_y = oexp_y;
dbObsTrans.obs_grev_y = grev_y;
dbObsTrans.obs_gexp_y = gexp_y;

% RER not observed, there is no obs_l_z in .model, so add "Transformed"
dbObsTrans.obs_l_z   = dbObsTrans.obs_l_s + dbObsTrans.obs_l_cpistar - dbObsTrans.obs_l_cpi_core;

% obs_l_cpi exists already in .model, but here "Transformed" back:
dbObsTrans.obs_l_cpi  = ...
  + w_core * dbObsTrans.obs_l_cpi_core ...
  + w_food * dbObsTrans.obs_l_cpi_food ...
  + w_ener * dbObsTrans.obs_l_cpi_ener;
% real money demand
dbObsTrans.obs_l_rmd  = dbObsTrans.obs_l_md - dbObsTrans.obs_l_cpi;

% Relative dom prices core/food/ener are derived in model (specified price
% eq.), hence the observed relative prices can be in dbObsTrans
% trend rel. prices (changes) also specified (AR(1), ss, shock): rel.price gaps residual

varNames = [
  "cpi_core"
  "cpi_food"
  "cpi_ener"
  ];

for v = varNames(:)'
  dbObsTrans.("obs_l_rp_" + v)  = dbObsTrans.("obs_l_" + v) - dbObsTrans.obs_l_cpi;
end

% Components of rel.foreign prices food/ener are observed (see above) and rel. price 
% gaps directly derived (hpf2), used in model; 
% but rel.foreign prices have no eq. in model both rel.price trends
% (changes)and gaps specified (AR(1),ss,shock) to determine rel.prices

varNames = [
  "foodstar"
  "enerstar"
  ];

for v = varNames(:)'
  dbObsTrans.("obs_l_rp_" + v)  = dbObsTrans.("obs_l_" + v) - dbObsTrans.obs_l_cpistar;
end

varNames = [
  "cpistar"
  "foodstar"
  "enerstar"
  "rp_foodstar"
  "rp_enerstar"
  "s"
  "z"
  "y"
  "cons"
  "inv"
  "gdem"
  "exp"
  "imp"
  "cpi"
  "cpi_core"
  "cpi_food"
  "cpi_ener"
  "rp_cpi_core"
  "rp_cpi_food"
  "rp_cpi_ener"
  "md"
  "rmd"
  "y_agr"
  ];

for v = varNames(:)'
  dbObsTrans.("obs_dl_" + v)  = 4*diff(dbObsTrans.("obs_l_" + v));
  dbObsTrans.("obs_d4l_" + v) = diff(dbObsTrans.("obs_l_" + v), -4);
end

codes.writeMessage("readData: saving results ...");

fileName = fullfile(opts.mainDir, "results", "data.mat");
save(fileName, "dbObs", "dbObsTrans", "dbAux", "dbOrig");

codes.writeMessage("readData: done");

end
