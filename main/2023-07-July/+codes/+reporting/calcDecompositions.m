function dc = calcDecompositions(m, db, checkRange)

xnamesAll = string(get(m, "xnames"));
xdescrAll = string(get(m, "xdescript"));

paramNum = length(m);

dc = struct();

% Consumption gap

seriesName    = "l_cons_gap";
legendEntries = ["Lag", "Expectation", "RIR gap", "REER gap", "Income", "Fisc. imp.", "Shock"];

% l_cons_gap = ...
%   + a1_cons * l_cons_gap{-1} ...
%   + a2_cons * e_l_cons_gap ...
%   - a3_cons * rmci_cons ...
%   + a4_cons * l_y_gap ...
%   + a5_cons * fisc_imp ...  
%   + shock_l_cons_gap;

for i = 1:paramNum
  
  decompContribs = [ ...
    + db.a1_cons(i) * db.l_cons_gap{:,i}{-1}, ...
    + db.a2_cons(i) * db.e_l_cons_gap{:,i}, ...
    - db.a3_cons(i) * db.a6_cons(i)       * db.r4_gap{:,i}, ...
    - db.a3_cons(i) * (1 - db.a6_cons(i)) * - db.l_z_gap{:,i}, ...
    + db.a4_cons(i) * db.l_y_gap{:,i}, ...
    + db.a5_cons(i) * db.fisc_imp{:,i}, ...
    + db.shock_l_cons_gap{:,i} ...
    ];
  
  figureName = xdescrAll(xnamesAll == seriesName) + " [" + seriesName + "]";
  
  decompSeries = db.(seriesName){:,i};
  
  colorMap = "parula";
  
  addDecompositions();
  
end

% Investment gap

seriesName    = "l_inv_gap";
legendEntries = ["Lag", "Expectation", "RIR gap", "REER gap", "Income", "Fisc. imp.", "Shock"];

for i = 1:paramNum
  
  decompContribs = [ ...
    + db.a1_inv(i) * db.l_inv_gap{:,i}{-1}, ...
    + db.a2_inv(i) * db.e_l_inv_gap{:,i}, ...
    - db.a3_inv(i) * db.a6_inv(i)       * db.r4_gap{:,i}, ...
    - db.a3_inv(i) * (1 - db.a6_inv(i)) * - db.l_z_gap{:,i}, ...
    + db.a4_inv(i) * db.l_y_gap{:,i}, ...
    + db.a5_inv(i) * db.fisc_imp{:,i}, ...
    + db.shock_l_inv_gap{:,i} ...
    ];
  
  figureName = xdescrAll(xnamesAll == seriesName) + " [" + seriesName + "]";
  
  decompSeries = db.(seriesName){:,i};
  
  colorMap = "parula";
  
  addDecompositions();
  
end

% Government demand (expenditure) gap

seriesName    = "l_gdem_gap";
legendEntries = ["Output gap", "Cyclical", "Discretionary", "Approx. error"];

for i = 1:paramNum
  
  decompContribs = [ ...
    + db.l_y_gap{:,i}, ...
    + 100 * db.gdem_y_cyc{:,i} / db.gdem_y{:,i}, ...
    + 100 * db.gdem_y_discr{:,i} / db.gdem_y{:,i}, ...
    + db.l_gdem_gap{:,i} - ( ...
      + db.l_y_gap{:,i} ...
      + 100 * db.gdem_y_cyc{:,i} / db.gdem_y{:,i} ...
      + 100 * db.gdem_y_discr{:,i} / db.gdem_y{:,i} ...
      ) ...
    ];
  
  figureName = xdescrAll(xnamesAll == seriesName) + " [" + seriesName + "]";
  
  decompSeries = db.(seriesName){:,i};
  
  colorMap = "parula";
  
  addDecompositions();
  
end

% Export gap

seriesName    = "l_exp_gap";
legendEntries = ["Lag", "Expectation", "RIR gap", "REER gap", "Foreign demand", "Shock"];

for i = 1:paramNum
  
  decompContribs = [ ...
    + db.a1_exp(i) * db.l_exp_gap{:,i}{-1}, ...
    + db.a2_exp(i) * db.e_l_exp_gap{:,i}, ...
    - db.a3_exp(i) * db.a6_exp(i)       * db.r4_gap{:,i}, ...
    - db.a3_exp(i) * (1 - db.a6_exp(i)) * -db.l_z_gap{:,i}, ...
    + db.a5_exp(i) * db.l_ystar_gap{:,i}, ...
    + db.shock_l_exp_gap{:,i} ...
    ];
  
  figureName = xdescrAll(xnamesAll == seriesName) + " [" + seriesName + "]";
  
  decompSeries = db.(seriesName){:,i};
  
  colorMap = "parula";
  
  addDecompositions();
  
end

% Import gap

seriesName    = "l_imp_gap";
legendEntries = ["Cons. gap", "Invest. gap", "Gov.demand gap", "Export gap", "REER gap", "Shock"];

for i = 1:paramNum
  
  decompContribs = [ ...
    + db.w_imp_cons(i)  * db.l_cons_gap{:,i}, ...
    + db.w_imp_inv(i)   * db.l_inv_gap{:,i}, ...
    + db.w_imp_gdem(i)  * db.l_gdem_gap{:,i}, ...
    + db.w_imp_exp(i)   * db.l_exp_gap{:,i}, ...
    - db.a1_imp(i)      * db.l_z_gap{:,i}, ...
    + db.shock_l_imp_gap{:,i};
    ];
  
  figureName = xdescrAll(xnamesAll == seriesName) + " [" + seriesName + "]";
  
  decompSeries = db.(seriesName){:,i};
  
  colorMap = "parula";
  
  addDecompositions();
  
end

% Output gap

seriesName    = "l_y_gap";
legendEntries = ["Cons. gap", "Invest. gap", "Gov.demand gap", "Export gap", ...
  "Import gap", "Shock"];

for i = 1:paramNum
  
  decompContribs = [ ...
    + db.w_y_cons(i)  * db.l_cons_gap{:,i}, ...
    + db.w_y_inv(i)   * db.l_inv_gap{:,i}, ...
    + db.w_y_gdem(i)  * db.l_gdem_gap{:,i}, ...
    + db.w_y_exp(i)   * db.l_exp_gap{:,i}, ...
    - db.w_y_imp(i)   * db.l_imp_gap{:,i}, ...
    + db.shock_l_y_gap{:,i};
    ];
  
  figureName = xdescrAll(xnamesAll == seriesName) + " [" + seriesName + "]";
  
  decompSeries = db.(seriesName){:,i};
  
  colorMap = "parula";
  
  addDecompositions();
  
end

% Potential GDP growth

seriesName    = "dl_y_tnd";
legendEntries = ["Cons.", "Invest.", "Gov.demand", "Export", "Import"];

for i = 1:paramNum
  
  decompContribs = [ ...
    + db.w_y_cons(i)   * db.dl_cons_tnd{:,i}, ...
    + db.w_y_inv(i)    * db.dl_inv_tnd{:,i}, ...
    + db.w_y_gdem(i)  * db.dl_gdem_tnd{:,i}, ...
    + db.w_y_exp(i)    * db.dl_exp_tnd{:,i}, ...
    - db.w_y_imp(i)    * db.dl_imp_tnd{:,i} ...
    ];
  
  figureName = xdescrAll(xnamesAll == seriesName) + " [" + seriesName + "]";
  
  decompSeries = db.(seriesName){:,i};
  
  colorMap = "lines";
  
  addDecompositions();
  
end

% Core Phillips curve

seriesName    = "dl_cpi_core";
legendEntries = ["Lag", "Expectation", "Direct", "Output gap", "REER gap", "Shock"];

for i = 1:paramNum
  
  decompContribs = [ ...
    + db.b1(i) * db.dl_cpi_core{:,i}{-1}, ...
    + (1 - db.b1(i) - db.b3(i)) * (db.e_dl_cpi_core{:,i}), ...
    + db.b3(i) * db.dl_cpi_core_direct{:,i}, ...
    + db.b2(i) * db.b4(i) * db.l_y_gap{:,i}, ...
    + db.b2(i) * (1 - db.b4(i)) * db.l_z_gap{:,i}, ...
    + db.shock_dl_cpi_core{:,i}
    ];
  
  figureName = xdescrAll(xnamesAll == seriesName) + " [" + seriesName + "]";
  
  decompSeries = db.(seriesName){:,i};
  
  colorMap = "parula";
  
  addDecompositions();
  
end

% Core Phillips curve, direct external effect

seriesName    = "dl_cpi_core_direct";
legendEntries = ["Foreign CPI", "Exchange rate", "Trend adjustment"];

for i = 1:paramNum
  
  decompContribs = [ ...
    + db.dl_cpistar{:,i}, ...
    + db.dl_s{:,i}, ...
    - db.dl_z_tnd{:,i}
    ];
  
  figureName = xdescrAll(xnamesAll == seriesName) + " [" + seriesName + "]";
  
  decompSeries = db.(seriesName){:,i};
  
  colorMap = "lines";
  
  addDecompositions();
  
end

% Food Phillips curve

seriesName    = "dl_cpi_food";
legendEntries = ["Lag", "Expectation", "Direct", "RER gap", "AgrOutp gap", "Shock"];

for i = 1:paramNum
  
  decompContribs = [ ...
    + db.bf1(i) * db.dl_cpi_food{:,i}{-1}, ...
    + (1 - db.bf1(i) - db.bf3(i)) * (db.e_dl_cpi_food{:,i}), ...
    + db.bf3(i) * db.dl_cpi_food_direct{:,i}, ...
    + db.bf2(i) * (db.l_rp_foodstar_gap{:,i} + db.l_z_gap{:,i} + db.l_rp_cpi_core_gap{:,i} - db.l_rp_cpi_food_gap{:,i}), ...
    - db.bf4(i) * db.l_y_agr_gap{:,i},...
    + db.shock_dl_cpi_food{:,i}
    ];
  
  figureName = xdescrAll(xnamesAll == seriesName) + " [" + seriesName + "]";
  
  decompSeries = db.(seriesName){:,i};
  
  colorMap = "parula";
  
  addDecompositions();
  
end

% Food Phillips curve, direct external effect

seriesName    = "dl_cpi_food_direct";
legendEntries = ["Foreign food inflation", "Exchange rate", "Trend adjustment"];

for i = 1:paramNum
  
  decompContribs = [ ...
    + db.dl_foodstar{:,i}, ...
    + db.dl_s{:,i}, ...
    - (db.dl_rp_foodstar_tnd{:,i} + db.dl_z_tnd{:,i} ...
    + db.dl_rp_cpi_core_tnd{:,i} - db.dl_rp_cpi_food_tnd{:,i})
    ];
  
  figureName = xdescrAll(xnamesAll == seriesName) + " [" + seriesName + "]";
  
  decompSeries = db.(seriesName){:,i};
  
  colorMap = "lines";
  
  addDecompositions();
  
end

% Energy Phillips curve

seriesName    = "dl_cpi_ener";
legendEntries = ["Lag", "Expectation", "Direct", "RER gap", "Shock"];

for i = 1:paramNum
  
  decompContribs = [ ...
    + db.be1(i) * db.dl_cpi_ener{:,i}{-1}, ...
    + (1 - db.be1(i) - db.be3(i)) * (db.e_dl_cpi_ener{:,i}), ...
    + db.be3(i) * db.dl_cpi_ener_direct{:,i}, ...
    + db.be2(i) * (db.l_rp_enerstar_gap{:,i} + db.l_z_gap{:,i} + db.l_rp_cpi_core_gap{:,i} - db.l_rp_cpi_ener_gap{:,i}), ...
    + db.shock_dl_cpi_ener{:,i}
    ];
  
  figureName = xdescrAll(xnamesAll == seriesName) + " [" + seriesName + "]";
  
  decompSeries = db.(seriesName){:,i};
  
  colorMap = "parula";
  
  addDecompositions();
  
end

% Energy Phillips curve, direct external effect

seriesName    = "dl_cpi_ener_direct";
legendEntries = ["Foreign energy inflation", "Exchange rate", "Trend adjustment"];

for i = 1:paramNum
  
  decompContribs = [ ...
    + db.dl_enerstar{:,i}, ...
    + db.dl_s{:,i}, ...
    - (db.dl_rp_enerstar_tnd{:,i} + db.dl_z_tnd{:,i} ...
    + db.dl_rp_cpi_core_tnd{:,i} - db.dl_rp_cpi_ener_tnd{:,i})
    ];
  
  figureName = xdescrAll(xnamesAll == seriesName) + " [" + seriesName + "]";
  
  decompSeries = db.(seriesName){:,i};
  
  colorMap = "lines";
  
  addDecompositions();
  
end

% Agriculture output gap

seriesName    = "l_y_agr_gap";
legendEntries = ["Lag", "Shock"];

for i = 1:paramNum
  
  decompContribs = [ ...
    + db.r1_y_agr(i) * db.l_y_agr_gap{:,i}{-1}, ...
    + db.shock_l_y_agr_gap{:,i}
    ];
  
  figureName = xdescrAll(xnamesAll == seriesName) + " [" + seriesName + "]";
  
  decompSeries = db.(seriesName){:,i};
  
  colorMap = "parula";
  
  addDecompositions();
  
end

% Policy rule

seriesName    = "i";
legendEntries = ["Lag", "Neutral rate", "Inflation reaction", "Output gap", ...
  "FX target", "Shock"]; %the ss-rate is 'neutral' not 'natural' rate

for i = 1:paramNum
  
  decompContribs = [ ...
    + db.c1(i) * db.i{:,i}{-1}, ...
    + (1 - db.c1(i)) * db.i_tnd{:,i}, ...
    + (1 - db.c1(i)) * db.c2(i) * db.d4l_cpi_dev{:,i}, ...
    + (1 - db.c1(i)) * db.c3(i) * db.l_y_gap{:,i}, ...
    + (1 - db.c1(i)) * db.c4(i) * (db.dl_s{:,i} - db.dl_s_tar{:,i}), ...
    + db.shock_i{:,i}, ...
    ];
  
  figureName = xdescrAll(xnamesAll == seriesName) + " [" + seriesName + "]";
  
  decompSeries = db.(seriesName){:,i};
  
  colorMap = "parula";
  
  addDecompositions();
  
end

% Exchange rate (was q-on-q, make q-on-q annualized)

seriesName    = "l_s";
legendEntries = ["Expectation", "IR differential", "Premium", "Target", "Shock"];
for i = 1:paramNum
  
  decompContribs = [ ...
    + 4*db.e1(i) * (db.e_l_s{:,i} - db.l_s{:,i}{-1}), ...
    - 4*db.e1(i) * (db.i{:,i} - db.istar{:,i})/4, ...
    + 4*db.e1(i) * db.prem{:,i}/4, ...
    + 4*(1 - db.e1(i)) * db.dl_s_tar{:,i}/4, ...
    + 4*db.shock_l_s{:,i} ...
    ];
  
  figureName = "Exchange rate, QQ annualized %" + " [dl_s]";
  
  decompSeries = 4*(db.(seriesName){:,i} - db.(seriesName){:,i}{-1});
  
  colorMap = "parula";
  
  addDecompositions();
  
end

% Exchange rate target

seriesName    = "dl_s_tar";
legendEntries = ["Lag", "RER trend", "CPI target", "Core RP trend", "Foreign CPI", ...
  "Inflation", "RER gap", "Shock"];

for i = 1:paramNum
  
  decompContribs = [ ...
    + db.e4(i) * db.dl_s_tar{:,i}{-1}, ...
    + (1 - db.e4(i)) * db.dl_z_tnd{:,i}, ...
    + (1 - db.e4(i)) * db.d4l_cpi_tar{:,i}, ...
    + (1 - db.e4(i)) * db.dl_rp_cpi_core_tnd{:,i}, ...
    - (1 - db.e4(i)) * db.ss_dl_cpistar(i), ...
    - (1 - db.e4(i)) * db.e5(i) * db.d4l_cpi_dev{:,i}, ...
    - (1 - db.e4(i)) * db.e6(i) * db.l_z_gap{:,i}, ...
    + db.shock_dl_s_tar{:,i}
    ];
  
  figureName = "Exchange rate target, QQ %" + " [dl_s_tar]";
  
  decompSeries = db.(seriesName){:,i};
  
  colorMap = "parula";
  
  addDecompositions();
  
end

% RIR trend

seriesName    = "r_tnd";
legendEntries = ["Foreign RIR", "Premium", "Exp. RER trend depr."];

for i = 1:paramNum
  
  decompContribs = [ ...
    db.rstar_tnd{:,i}, ...
    db.prem{:,i}, ...
    db.e_dl_z_tnd{:,i} ...
    ];
  
  figureName = xdescrAll(xnamesAll == seriesName) + " [" + seriesName + "]";
  
  decompSeries = db.(seriesName){:,i};
  
  colorMap = "lines";
  
  addDecompositions();
  
end

% Revenues

seriesName    = "grev_y";
legendEntries = ["Structural", "Cyclical", "Discretionary"];

for i = 1:paramNum
  
  decompContribs = [ ...
    + db.grev_y_str{:,i}, ...
    + db.grev_y_cyc{:,i}, ...
    + db.grev_y_discr{:,i} ...
    ];
  
  figureName = xdescrAll(xnamesAll == seriesName) + " [" + seriesName + "]";
  
  decompSeries = db.(seriesName){:,i};
  
  colorMap = "lines";
  
  addDecompositions();
  
end

% Cyclical revenues

seriesName    = "grev_y_cyc";
legendEntries = ["Cons. gap", "Imp. gap", "Ouput gap", "Shock"];

for i = 1:paramNum
  
  decompContribs = [ ...
    + db.v1(i) * db.l_cons_gap{:,i}, ...
    + db.v2(i) * db.l_imp_gap{:,i}, ...
    + db.v3(i) * db.l_y_gap{:,i}, ...
    + db.shock_grev_y_cyc{:,i} ...
    ];
  
  figureName = xdescrAll(xnamesAll == seriesName) + " [" + seriesName + "]";
  
  decompSeries = db.(seriesName){:,i};
  
  colorMap = "parula";
  
  addDecompositions();
  
end

% Structural revenues

seriesName    = "grev_y_str";
legendEntries = ["Lag", "Steady state", "Shock"];

for i = 1:paramNum
  
  decompContribs = [ ...
    + db.v4(i) * db.grev_y_str{:,i}{-1}, ...
    + (1 - db.v4(i)) * db.ss_grev_y_str(i), ...
    + db.shock_grev_y_str{:,i};
    ];
  
  figureName = xdescrAll(xnamesAll == seriesName) + " [" + seriesName + "]";
  
  decompSeries = db.(seriesName){:,i};
  
  colorMap = "lines";
  
  addDecompositions();
  
end

% Demand

seriesName    = "gdem_y";
legendEntries = ["Structural", "Cyclical", "Discretionary"];

for i = 1:paramNum
  
  decompContribs = [ ...
    + db.gdem_y_str{:,i}, ...
    + db.gdem_y_cyc{:,i}, ...
    + db.gdem_y_discr{:,i} ...
    ];
  
  figureName = xdescrAll(xnamesAll == seriesName) + " [" + seriesName + "]";
  
  decompSeries = db.(seriesName){:,i};
  
  colorMap = "lines";
  
  addDecompositions();
  
end

% Discretionary demand

seriesName    = "gdem_y_discr";
legendEntries = ["Lag", "Shock"];

for i = 1:paramNum
  
  decompContribs = [ ...
    + db.t4(i)*db.gdem_y_discr{:,i}{-1}, ...
    + db.shock_gdem_y_discr{:,i}
    ];
  
  figureName = xdescrAll(xnamesAll == seriesName) + " [" + seriesName + "]";
  
  decompSeries = db.(seriesName){:,i};
  
  colorMap = "parula";
  
  addDecompositions();
  
end

% Cyclical demand

seriesName    = "gdem_y_cyc";
legendEntries = ["Lag", "Output gap", "Shock"];

for i = 1:paramNum
  
  decompContribs = [ ...
    + db.t1(i) * db.gdem_y_cyc{:,i}{-1}, ...
    - db.t2(i) * db.l_y_gap{:,i}, ...
    + db.shock_gdem_y_cyc{:,i} ...
    ];
  
  figureName = xdescrAll(xnamesAll == seriesName) + " [" + seriesName + "]";
  
  decompSeries = db.(seriesName){:,i};
  
  colorMap = "parula";
  
  addDecompositions();
  
end

% Structural demand

seriesName    = "gdem_y_str";
legendEntries = ["Lag", "Steady state", "Shock"];

for i = 1:paramNum
  
  decompContribs = [ ...
    + db.t3(i) * db.gdem_y_str{:,i}{-1}, ...
    + (1 - db.t3(i)) * db.ss_gdem_y_str(i), ...
    + db.shock_gdem_y_str{:,i};
    ];
  
  figureName = xdescrAll(xnamesAll == seriesName) + " [" + seriesName + "]";
  
  decompSeries = db.(seriesName){:,i};
  
  colorMap = "parula";
  
  addDecompositions();
  
end

% Other expenditures

seriesName    = "oexp_y";
legendEntries = ["Structural", "Cyclical", "Discretionary"];

for i = 1:paramNum
  
  decompContribs = [ ...
    + db.oexp_y_str{:,i}, ...
    + db.oexp_y_cyc{:,i}, ...
    + db.oexp_y_discr{:,i} ...
    ];
  
  figureName = xdescrAll(xnamesAll == seriesName) + " [" + seriesName + "]";
  
  decompSeries = db.(seriesName){:,i};
  
  colorMap = "lines";
  
  addDecompositions();
  
end

% Cyclical other expenditures

seriesName    = "oexp_y_cyc";
legendEntries = ["Lag", "Output gap", "Shock"];

for i = 1:paramNum
  
  decompContribs = [ ...
    + db.u1(i) * db.oexp_y_cyc{:,i}{-1}, ...
    - db.u2(i) * db.l_y_gap{:,i}, ...
    + db.shock_oexp_y_cyc{:,i} ...
    ];
  
  figureName = xdescrAll(xnamesAll == seriesName) + " [" + seriesName + "]";
  
  decompSeries = db.(seriesName){:,i};
  
  colorMap = "parula";
  
  addDecompositions();
  
end

% Structural other expenditures

seriesName    = "oexp_y_str";
legendEntries = ["Lag", "Steady state", "Shock"];

for i = 1:paramNum
  
  decompContribs = [ ...
    + db.u3(i) * db.oexp_y_str{:,i}{-1}, ...
    + (1 - db.u3(i)) * db.ss_oexp_y_str(i), ...
    + db.shock_oexp_y_str{:,i};
    ];
  
  figureName = xdescrAll(xnamesAll == seriesName) + " [" + seriesName + "]";
  
  decompSeries = db.(seriesName){:,i};
  
  colorMap = "parula";
  
  addDecompositions();
  
end

% Deficit decomposed by revenue, gdemand G&S and other expenditure

seriesName    = "def_y";
legendEntries = ["Demand", "Other expenditures", "Revenues"];

for i = 1:paramNum
  
  decompContribs = [ ...
    + db.gdem_y{:,i}, ...
    + db.oexp_y{:,i}, ...
    - db.grev_y{:,i} ...
    ];
  
  figureName = xdescrAll(xnamesAll == seriesName) + " [" + seriesName + "]";
  
  decompSeries = db.(seriesName){:,i};
  
  colorMap = "lines";
  
  addDecompositions();
  
end

% Deficit decomposed by structural, discretionary, cyclical deficits

seriesName    = "def_y_scd";
legendEntries = ["Structural", "Discretionary", "Cyclical"];

for i = 1:paramNum
  
  decompContribs = [ ...
    + db.def_y_str{:,i}, ...
    + db.def_y_discr{:,i}, ...
    + db.def_y_cyc{:,i} ...
    ];
  
  figureName = xdescrAll(xnamesAll == "def_y") + " [" + seriesName + "]";
  
  decompSeries = db.def_y{:,i};
  
  colorMap = "lines";
  
  addDecompositions();
  
 end

% Cyclical deficit

seriesName    = "def_y_cyc";
legendEntries = ["Demand", "Other expenditures", "Revenues"];

for i = 1:paramNum
  
  decompContribs = [ ...
    + db.gdem_y_cyc{:,i}, ...
    + db.oexp_y_cyc{:,i}, ...
    - db.grev_y_cyc{:,i} ...
    ];
  
  figureName = xdescrAll(xnamesAll == seriesName) + " [" + seriesName + "]";
  
  decompSeries = db.(seriesName){:,i};
  
  colorMap = "lines";
  
  addDecompositions();
  
end

% Discretionary deficit

seriesName    = "def_y_discr";
legendEntries = ["Demand", "Other expenditures", "Revenues"];

for i = 1:paramNum
  
  decompContribs = [ ...
    + db.gdem_y_discr{:,i}, ...
    + db.oexp_y_discr{:,i}, ...
    - db.grev_y_discr{:,i} ...
    ];
  
  figureName = xdescrAll(xnamesAll == seriesName) + " [" + seriesName + "]";
  
  decompSeries = db.(seriesName){:,i};
  
  colorMap = "lines";
  
  addDecompositions();
  
end

% Structural deficit

seriesName    = "def_y_str";
legendEntries = ["Demand", "Other expenditures", "Revenues"];

for i = 1:paramNum
  
  decompContribs = [ ...
    + db.gdem_y_str{:,i}, ...
    + db.oexp_y_str{:,i}, ...
    - db.grev_y_str{:,i} ...
    ];
  
  figureName = xdescrAll(xnamesAll == seriesName) + " [" + seriesName + "]";
  
  decompSeries = db.(seriesName){:,i};
  
  colorMap = "lines";
  
  addDecompositions();
  
end

% Fiscal impulse

seriesName    = "fisc_imp";
legendEntries = ["Discr. deficit", "Change in struct. deficit"];

for i = 1:paramNum
  
  decompContribs = [ ...
    + db.def_y_discr{:,i}, ...
    + db.def_y_str{:,i} - db.def_y_str{:,i}{-1}
    ];
  
  figureName = xdescrAll(xnamesAll == seriesName) + " [" + seriesName + "]";
  
  decompSeries = db.(seriesName){:,i};
  
  colorMap = "lines";
  
  addDecompositions();
  
end

% Money

seriesName    = "dl_rmd";
legendEntries = ["Chg. of velocity", "Lag", "GDP growth", "Interest rate", "Shock"];

for i = 1:paramNum
  
  decompContribs = [ ...
    - (1 - db.m1(i)) * db.dl_v{:,i}, ...
    + db.m1(i) * db.dl_rmd{:,i}{-1}, ...
    + (1 - db.m1(i)) * db.dl_y{:,i}, ...
    + (1 - db.m1(i)) * db.m2(i) * (db.i{:,i} - db.i_tnd{:,i}), ...
    + db.shock_dl_rmd{:,i};
    ];
  
  figureName = xdescrAll(xnamesAll == seriesName) + " [" + seriesName + "]";
  
  decompSeries = db.(seriesName){:,i};
  
  colorMap = "parula";
  
  addDecompositions();
  
end

  function addDecompositions
    
    difi = max(abs(sum(decompContribs{checkRange, :}, 2) - decompSeries{checkRange}));
    if difi > 5e-3
      warning("Contributions don't add up to total for %s; max. abs. discr: %0.2e", ...
        figureName, difi)
    end
    
    dc.(seriesName).figureName        = figureName;
    dc.(seriesName).legendEntries     = legendEntries;
    dc.(seriesName).decompContribs{i} = decompContribs;
    dc.(seriesName).decompSeries{i}   = decompSeries;
    dc.(seriesName).colorMap          = colorMap;
    
  end

end
