function readData

% -------------------------------------------------------------------------
% ------------- Setup -------------

opts = mainSettings();

% -------------------------------------------------------------------------
% ------------- Read data -------------

% -------- Read from RWAMETRIC --------

mainDataFullFile  = fullfile(opts.QMFMDir, "data", opts.mainDataFile);
addDataFullFile   = fullfile(opts.QMFMDir, "data", opts.addDataFile);

% -------- Read the Excel database --------

codes.utils.writeMessage(mfilename ...
  + ": reading data from " + opts.mainDataFile + "...");

t = readtable(mainDataFullFile, ...
  "Sheet",    "Quarterly data", ...
  "TextType", "string"); %optional'VariableNamingRule','preserve'---

% --------- Copy variables into db as time series ---------

varNames = [
  "ystar"
  "cpistar"
  "foodstar"
  "istar"
  "pexpstar"
  "pimpstar"
  "s"
  "y"
  "y_agr"
  "cons"
  "inv"
  "gcons"
  "exp"
  "imp"
  "ny"
  "ncons"
  "ninv"
  "ngcons"
  "nexp"
  "nimp"
  "nginv"
  "cpi"
  "cpi_core"
  "cpi_food"
  "cpi_ener"
  "i_ib"
  "i_pol"
  "i_repo"
  "i_rev_repo"
  "i_lend"
  "ngrev"
  "ngexp"
  "nfg"
  "md"
  "rm"
  "nfa"
  "nfa_nbr"
  "ncg"
  "ncg_nbr"
  "ndebt_fcy"
  "ndebt_lcy"
  "nintp_fcy"
  "nintp_lcy"
  "dBP1_usd"
  "dBP2_usd"
  "dBPG_usd_eurobond"
  "dBG"
  "dBG_usd"
  "dBnbf"
  "dBbf"
  ];

for v = varNames(:)'
  ind     = t{:,1} == v;
  values  = double(t{ind, 3:end}');
  db.(v)  = Series(qq(1995, 1), values);
end

% -------- Read the additional data file --------

codes.utils.writeMessage(mfilename + ": reading data from " + opts.addDataFile + "...");

gpm = databank.fromCSV(addDataFullFile);

db = dboverlay(gpm, db);

% -------------------------------------------------------------------------
% ------------- Adjust series in db -------------

% -------- adj 80% for GFS1986 data <2019 --------

rngAdj = qq(1995, 1) : qq(2019,2);
db.nginv(rngAdj) = 0.8 * db.nginv(rngAdj);

% -------- Correct with discrepancy between deficit and debt data --------

db.stat_discrp = db.ngrev + db.nfg - db.ngexp + db.dBG + db.dBbf + db.dBnbf;
db.ngexp = db.ngexp + db.stat_discrp / 2;

% -------- Convert to LCY/FCY --------

db.ndebt_fcy  = db.ndebt_fcy * db.s / 1000;
db.dBG_usd    = db.dBG / db.s * 1000; % ??? it is loaded directly
db.NFG_usd    = db.nfg / db.s * 1000;
db.NFA_usd    = db.nfa / db.s * 1000;

% -------- Smooth foreign interest payments -------

db.nintp_fcy = convert(convert(db.nintp_fcy, 'a', 'method', @mean), 'q');

% -------- Redefine debt --------

% db.ndebt_fcy_orig = db.ndebt_fcy;
%
% initDate      = qq(2022,4);
% initVal_fcy   = 6555.1;
% db.ndebt_fcy  = cumsum(db.dBG); % ??? statistical discrepancy ???
% db.ndebt_fcy  = db.ndebt_fcy + initVal_fcy - db.ndebt_fcy(initDate);
%
% db.ndebt_lcy_orig = db.ndebt_lcy;
%
% initDate      = qq(2022,4);
% initVal_lcy   = 2523;
% db.ndebt_lcy  = cumsum(db.dBbf + db.dBnbf); % ??? statistical discrepancy ???
% db.ndebt_lcy  = db.ndebt_lcy + initVal_lcy - db.ndebt_lcy(initDate);
%
% plot([db.ndebt_lcy, db.ndebt_lcy_orig], '*-')
% grid
% legend 'new' 'orig'

% -------------------------------------------------------------------------
% ------------- Calculate new series -------------

% -------- Calculate prices --------

w_core = 7747/10000;
w_food = 1577/10000; %NBR has 0.28 incl. all food, beverages
w_ener =  676/10000;

db.cpi_core_orig = db.cpi_core;
db.cpi_core = exp((log(db.cpi) - w_food * log(db.cpi_food) ...
  - w_ener * log(db.cpi_ener)) / w_core);

% GDP deflator
db.py = db.ny / db.y;

% -------- Calculate cumulated levels --------

varNames = [
  "ystar"
  "cpistar"
  "pexpstar"
  "pimpstar"
  ];

for v = varNames(:)'
  db.(v) = exp(cumsum(log(1 + db.(v)) / 4));
end

% -------- Calculate foreign relative prices --------

varNames = [
  "pexpstar"
  "pimpstar"
  "foodstar"
  "enerstar"
  ];

for v = varNames(:)'
  db.("rp_" + v) = db.(v) / db.cpistar;
end

db.z = db.s * db.cpistar / db.cpi;

% -------- Calculate domestic relative prices --------

varNames = [
  "cpi_core"
  "cpi_food"
  "cpi_ener"
  ];

for v = varNames(:)'
  db.("rp_" + v) = db.(v) / db.cpi;
end

% -------- Government and private investment --------

pinv      = db.ninv / db.inv;   % Calc overall investment deflator from NA
db.ninv   = db.ninv - db.nginv; % Remove govt inv to get private inv, residual

db.ginv   = db.nginv / pinv;
db.inv    = db.ninv / pinv;  % Calc real private inv using overall inv deflator

% -------- Fiscal/BOP variables --------

db.ngdem    = db.ngcons     + db.nginv;
db.gdem     = db.gcons      + db.ginv;
db.ndef     = db.ngexp      - db.ngrev;
db.noexp    = db.ngexp      - db.ngdem;
db.ntb      = db.nexp       - db.nimp;

db.ndef_lcy = db.ndebt_lcy  - db.ndebt_lcy{-1};
db.ndef_fcy = db.ndebt_fcy  - db.ndebt_fcy{-1};
db.ndebt    = db.ndebt_fcy  + db.ndebt_lcy;

db.i_debt_fcy = 400 * db.nintp_fcy / db.ndebt_fcy{-1};
db.i_debt_lcy = 400 * db.nintp_lcy / db.ndebt_lcy{-1};

% private flows excl eurobonds going to Budget
db.dBP_usd = db.dBP1_usd + db.dBP2_usd - db.dBPG_usd_eurobond;

db.BP = 1650 + cumsum(db.dBP_usd);

% -------- GDP ratios --------

db.grev_y       = 100 * db.ngrev      / db.ny;
db.gexp_y       = 100 * db.ngexp      / db.ny;
db.def_y        = 100 * db.ndef       / db.ny;
db.def_lcy_y    = 100 * db.ndef_lcy   / db.ny;
db.def_fcy_y    = 100 * db.ndef_fcy   / db.ny;
db.grants_y     = 100 * db.nfg        / db.ny;
db.gdem_y       = 100 * db.ngdem      / db.ny;
db.oexp_y       = 100 * db.noexp      / db.ny;
db.intp_lcy_y   = 100 * db.nintp_lcy  / db.ny;
db.intp_fcy_y   = 100 * db.nintp_fcy  / db.ny;
db.debt_fcy_y   = 100 * db.ndebt_fcy  / db.ny;
db.debt_lcy_y   = 100 * db.ndebt_lcy  / db.ny;
db.tb_y         = 100 * db.ntb        / db.ny;
db.debt_y       = 100 * db.ndebt      / db.ny;

% -------- Calculate transformations --------

% ----- Seasonal adjustment -----

codes.utils.writeMessage(mfilename ...
  + ": seasonally adjusting varibales" + "...");

varNames = [
  "ystar"
  "cpistar"
  "foodstar"
  "enerstar"
  "pexpstar"
  "pimpstar"
  "rp_foodstar"
  "rp_enerstar"
  "rp_pexpstar"
  "rp_pimpstar"
  "s"
  "z"
  "y"
  "y_agr"
  "cons"
  "inv"
  "ginv"
  "gcons"
  "gdem"
  "exp"
  "imp"
  "ny"
  "ncons"
  "ninv"
  "ngcons"
  "nexp"
  "nimp"
  "nginv"
  "py"
  "cpi"
  "cpi_core"
  "cpi_food"
  "cpi_ener"
  "rp_cpi_core"
  "rp_cpi_food"
  "rp_cpi_ener"
  "grants_y"
  "grev_y"
  "gexp_y"
  "gdem_y"
  "def_y"
  "ngrev"
  "ngexp"
  "nfg"
  "md"
  "rm"
  "nfa"
  "nfa_nbr"
  "ncg"
  "ncg_nbr"
  "nintp_fcy"
  "nintp_lcy"
  "dBP2_usd"
  "dBPG_usd_eurobond"
  "dBG"
  "dBG_usd"
  "dBnbf"
  "dBbf"
  "BP"
  ];

for v = varNames(:)'
  db.(v + "_sa") = x12(db.(v), "Missing", true);
end

% ----- Logarithm, growth rates -----

varNames_sa = varNames + "_sa";

db = calcLogGrowth(db, union(varNames, varNames_sa));

varNames = [
  "NFA_usd"
  "ndebt_fcy"
  "ndebt_lcy"
  "dBP1_usd"
  ];

db = calcLogGrowth(db, varNames);

% ----- Interest rates in log-approximation -----

db.l_istar        = 100*log(1 + db.istar/100);
db.l_i_lend       = 100*log(1 + db.i_lend/100);
db.l_i_ib         = 100*log(1 + db.i_ib/100);
db.l_i_pol        = 100*log(1 + db.i_pol/100);
db.l_i_repo       = 100*log(1 + db.i_repo/100);
db.l_i_rev_repo   = 100*log(1 + db.i_rev_repo/100);

db.l_i            = db.l_i_ib;

% -------------------------------------------------------------------------
% ------------ Create the observed database for the filter -------------

dbObs.obs_l_ystar_gap = hpf2(db.l_ystar);
dbObs.obs_rstar_tnd   = db.rstar_tnd;

dbObs.obs_l_cpistar   = db.l_cpistar;
dbObs.obs_l_enerstar  = db.l_enerstar;
dbObs.obs_l_foodstar  = db.l_foodstar;

dbObs.obs_l_rp_enerstar_gap = hpf2(db.l_rp_enerstar);
dbObs.obs_l_rp_foodstar_gap = hpf2(db.l_rp_foodstar);

dbObs.obs_istar = db.l_istar;

dbObs.obs_l_s = db.l_s;

dbObs.obs_l_y       = db.l_y_sa;
dbObs.obs_l_y_agr   = db.l_y_agr_sa;
dbObs.obs_l_cons    = db.l_cons_sa;
dbObs.obs_l_inv     = db.l_inv_sa;
dbObs.obs_l_gdem    = db.l_gdem_sa;
dbObs.obs_l_exp     = db.l_exp_sa;
dbObs.obs_l_imp     = db.l_imp_sa;

dbObs.obs_l_cpi       = db.l_cpi_sa;
dbObs.obs_l_cpi_food  = db.l_cpi_food_sa;
dbObs.obs_l_cpi_ener  = db.l_cpi_ener_sa;
dbObs.obs_l_cpi_core  = (db.l_cpi_sa - w_food * db.l_cpi_food_sa ...
  - w_ener * db.l_cpi_ener_sa) / w_core;

dbObs.obs_i = db.l_i_ib;

dbObs.obs_prem_d = db.l_i_lend - dbObs.obs_i;

dbObs.obs_l_md = db.l_md_sa;

dbObs.obs_grants_y  = db.grants_y_sa;
dbObs.obs_grev_y    = db.grev_y_sa;
dbObs.obs_def_y     = db.def_y_sa;

% ------------------------------------------------------------------------
% ------------- Create the database for the auxiliary model -------------

dbAux.dl_pexpstar   = db.dl_pexpstar;
dbAux.dl_pimpstar   = db.dl_pimpstar;

dbAux.ncons   = db.ncons;
dbAux.ninv    = db.ninv;
dbAux.nexp    = db.nexp;
dbAux.nimp    = db.nimp;
dbAux.ny      = db.ny;
dbAux.tb_rat  = db.tb_y;
dbAux.ngdem   = db.ngdem;
dbAux.nginv   = db.nginv;

dbAux.ngrev    = db.ngrev;
dbAux.ngrev_ny = db.grev_y_sa;
dbAux.ngexp    = db.ngexp;
dbAux.ngexp_ny = db.gexp_y_sa;

% dbAux.NFG     = db.grants_y_sa;
dbAux.md      = db.md_sa;
dbAux.dl_md   = db.dl_md_sa;

dbAux.dl_py = db.dl_py_sa;

dbAux.l_rm      = db.l_rm_sa;
dbAux.nfa_nbr   = db.nfa_nbr_sa;
dbAux.ncg_nbr   = db.ncg_nbr_sa;
dbAux.NFA       = db.nfa_sa;
dbAux.dNFA_usd  = db.NFA_usd - db.NFA_usd{-1}; % rz: can not be seasonally adjusted
dbAux.NCG       = db.ncg_sa;

dbAux.intp_lcy_y  = db.intp_lcy_y;
dbAux.intp_fcy_y  = db.intp_fcy_y;
dbAux.debt_fcy_y  = db.debt_fcy_y;
dbAux.debt_lcy_y  = db.debt_lcy_y;
dbAux.debt_y      = db.debt_y;

dbAux.def_lcy_y = db.def_lcy_y;
dbAux.def_fcy_y = db.def_fcy_y;

dbAux.i_debt_fcy = db.i_debt_fcy;
dbAux.i_debt_lcy = db.i_debt_lcy;

dbAux.dBP_usd       = db.dBP_usd;
dbAux.dBPG_eurobond = db.dBPG_usd_eurobond;

% initial stock mln$: 1650 end-1997 (70% of GDP)
dbAux.l_BP      = db.l_BP;
dbAux.dl_BP     = db.dl_BP;
dbAux.l_BP_tnd  = hpf(db.l_BP);

dbAux.dBG_usd     = db.dBG_usd;
dbAux.dBG_bop_usd = db.dBG_usd;
dbAux.NFG_usd     = db.NFG_usd;

dbAux.dBnbf = db.dBnbf;
dbAux.dBbf  = db.dBbf;

varNames = [
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
  "s"
  "z"
  ];

for v = varNames(:)'

  dbAux.("pct_"  + v)   = db.("pct_"  + v + "_sa");
  dbAux.("pct4_" + v)   = db.("pct4_"  + v);

end

dbAux.pct_i = 100* (exp(dbObs.obs_i/100) - 1);

% -------------------------------------------------------------------------
% ------------- Create dbObsTrans -------------

dbObsTrans = dbObs;

dbObsTrans.obs_grev_y = db.grev_y_sa;
dbObsTrans.obs_gexp_y = db.gexp_y_sa;
dbObsTrans.obs_gdem_y = db.gdem_y_sa;

dbObsTrans.obs_oexp_y = dbObsTrans.obs_gexp_y - dbObsTrans.obs_gdem_y;

dbObsTrans.obs_l_ystar_tnd = hpf(db.l_ystar);

dbObsTrans.obs_l_y_agr_gap = hpf2(db.l_y_agr);

dbObsTrans.obs_i_ib        = db.l_i_ib;
dbObsTrans.obs_i_pol       = db.l_i_pol;
dbObsTrans.obs_i_repo      = db.l_i_repo;
dbObsTrans.obs_i_rev_repo  = db.l_i_rev_repo;

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

% -------------------------------------------------------------------------
% ------------- Save results -------------

codes.utils.writeMessage(mfilename + ": saving results ...");
codes.utils.saveResult(opts, "data", "db", "dbObs", "dbAux", "dbObsTrans");
codes.utils.writeMessage(mfilename + ": done");

end

% -------------------------------------------------------------------------
% ------------- End of main function -------------

function db = calcLogGrowth(db, varNames)

for v = varNames(:)'

  db.("l_" + v)      = 100 * log(db.(v));
  db.("dl_" + v)     = 4 * (db.("l_" + v) - db.("l_" + v){-1});
  db.("d4l_" + v)    = db.("l_" + v) - db.("l_" + v){-4};
  db.("pct_"  + v)   = 100 * ((db.(v) / db.(v){-1})^4 - 1);
  db.("pct4_" + v)   = 100 * (db.(v) / db.(v){-4} - 1);

end

end
