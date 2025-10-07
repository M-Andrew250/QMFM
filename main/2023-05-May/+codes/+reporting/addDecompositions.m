function rprt = addDecompositions(opts, rprt, m, dc, range, legends)

xnamesAll = string(get(m, "xnames"));
xdescrAll = string(get(m, "xdescript"));

rprt.section('Decomposition of equations');
rprt.pagebreak;

paramNum = length(m);

% Consumption gap

seriesName    = "l_cons_gap";

figureName = xdescrAll(strcmp(xnamesAll,seriesName)) + " [" + seriesName + "]";
rprt.figure(char(figureName), opts.barconOptions{:}, 'subplot', [paramNum 1]);

for i = 1:paramNum
  
  rprt = codes.reporting.barContrib(rprt, range, ...
    dc.(seriesName).decompSeries{i}, dc.(seriesName).decompContribs{i}, legends(i), ...
    dc.(seriesName).legendEntries, parula());
  
end

for i = 1:paramNum
  
  rprt = codes.reporting.tableContrib(rprt, range, ...
    dc.(seriesName).decompSeries{i}, dc.(seriesName).decompContribs{i}, legends(i), ...
    dc.(seriesName).legendEntries);
  
end

% % Investment gap
% 
% seriesName    = "l_inv_gap";
% legendEntries = ["Lag", "Expectation", "RIR gap", "REER gap", "Income", "Fisc. imp.", "Shock"];
% 
% figureName = xdescrAll(strcmp(xnamesAll,seriesName)) + " [" + seriesName + "]";
% rprt.figure(char(figureName), opts.barconOptions{:}, 'subplot', [paramNum 1]);
% 
% for i = 1:paramNum
%   
%   decompContribs = [ ...
%     + db.a1_inv(i) * db.l_inv_gap{:,i}{-1}, ...
%     + db.a2_inv(i) * db.e_l_inv_gap{:,i}, ...
%     - db.a3_inv(i) * db.a6_inv(i)       * db.r4_gap{:,i}, ...
%     - db.a3_inv(i) * (1 - db.a6_inv(i)) * - db.l_z_gap{:,i}, ...
%     + db.a4_inv(i) * db.l_y_gap{:,i}, ...
%     + db.a5_inv(i) * db.fisc_imp{:,i}, ...
%     + db.shock_l_inv_gap{:,i} ...
%     ];
%   
%   decompSeries = db.(seriesName){:,i};
%   rprt = codes.reporting.barContrib(rprt, range, decompSeries, decompContribs, legends(i), legendEntries, parula());
%   
% end
% 
% % Government expenditure gap
% 
% seriesName    = "l_gdem_gap";
% legendEntries = ["Lag", "Income", "Shock"];
% 
% figureName = xdescrAll(strcmp(xnamesAll,seriesName)) + " [" + seriesName + "]";
% rprt.figure(char(figureName), opts.barconOptions{:}, 'subplot', [paramNum 1]);
% 
% for i = 1:paramNum
%   
%   decompContribs = [ ...
%     + db.a1_gdem(i) * db.l_gdem_gap{:,i}{-1}, ...
%     + db.shock_l_gdem_gap{:,i} ...
%     ];
%   
%   decompSeries = db.(seriesName){:,i};
%   rprt = codes.reporting.barContrib(rprt, range, decompSeries, decompContribs, legends(i), legendEntries, parula());
%   
% end
% 
% % Export gap
% 
% seriesName    = "l_exp_gap";
% legendEntries = ["Lag", "Expectation", "RIR gap", "REER gap", "Foreign demand", "Shock"];
% 
% figureName = xdescrAll(strcmp(xnamesAll,seriesName)) + " [" + seriesName + "]";
% rprt.figure(char(figureName), opts.barconOptions{:}, 'subplot', [paramNum 1]);
% 
% for i = 1:paramNum
%   
%   decompContribs = [ ...
%     + db.a1_exp(i) * db.l_exp_gap{:,i}{-1}, ...
%     + db.a2_exp(i) * db.e_l_exp_gap{:,i}, ...
%     - db.a3_exp(i) * db.a6_exp(i)       * db.r4_gap{:,i}, ...
%     - db.a3_exp(i) * (1 - db.a6_exp(i)) * -db.l_z_gap{:,i}, ...
%     + db.a5_exp(i) * db.l_ystar_gap{:,i}, ...
%     + db.shock_l_exp_gap{:,i} ...
%     ];
%   
%   decompSeries = db.(seriesName){:,i};
%   rprt = codes.reporting.barContrib(rprt, range, decompSeries, decompContribs, legends(i), legendEntries, parula());
%   
% end
% 
% % Import gap
% 
% seriesName    = "l_imp_gap";
% legendEntries = ["Consumption gap", "Investment gap", "Gov.demand gap", "Export gap", "REER gap", "Shock"];
% 
% figureName = xdescrAll(strcmp(xnamesAll,seriesName)) + " [" + seriesName + "]";
% rprt.figure(char(figureName), opts.barconOptions{:}, 'subplot', [paramNum 1]);
% 
% for i = 1:paramNum
%   
%   decompContribs = [ ...
%     + db.w_imp_cons(i)  * db.l_cons_gap{:,i}, ...
%     + db.w_imp_inv(i)   * db.l_inv_gap{:,i}, ...
%     + db.w_imp_gdem(i)  * db.l_gdem_gap{:,i}, ...
%     + db.w_imp_exp(i)   * db.l_exp_gap{:,i}, ...
%     + db.a1_imp(i)      * db.l_z_gap{:,i}, ...
%     + db.shock_l_imp_gap{:,i};
%     ];
%   
%   decompSeries = db.(seriesName){:,i};
%   rprt = codes.reporting.barContrib(rprt, range, decompSeries, decompContribs, legends(i), legendEntries, parula());
%   
% end
% 
% % Output gap
% 
% seriesName    = "l_y_gap";
% legendEntries = ["Consumption gap", "Investment gap", "Gov.demand gap", "Export gap", ...
%   "Import gap", "Shock"];
% 
% figureName = xdescrAll(strcmp(xnamesAll,seriesName)) + " [" + seriesName + "]";
% rprt.figure(char(figureName), opts.barconOptions{:}, 'subplot', [paramNum 1]);
% 
% for i = 1:paramNum
%   
%   decompContribs = [ ...
%     + db.w_y_cons(i)  * db.l_cons_gap{:,i}, ...
%     + db.w_y_inv(i)   * db.l_inv_gap{:,i}, ...
%     + db.w_y_gdem(i)  * db.l_gdem_gap{:,i}, ...
%     + db.w_y_exp(i)   * db.l_exp_gap{:,i}, ...
%     - db.w_y_imp(i)   * db.l_imp_gap{:,i}, ...
%     + db.shock_l_y_gap{:,i};
%     ];
%   
%   decompSeries = db.(seriesName){:,i};
%   rprt = codes.reporting.barContrib(rprt, range, decompSeries, decompContribs, legends(i), legendEntries, parula());
%   
% end
% 
% % Core Phillips curve
% 
% seriesName    = "dl_cpi_core";
% legendEntries = ["Lag", "Expectation", "Direct", "Output gap", "REER gap", "Shock"];
% 
% figureName = xdescrAll(strcmp(xnamesAll,seriesName)) + " [" + seriesName + "]";
% rprt.figure(char(figureName), opts.barconOptions{:}, 'subplot', [paramNum 1]);
% 
% for i = 1:paramNum
%   
%   decompContribs = [ ...
%     + db.b1(i) * db.dl_cpi_core{:,i}{-1}, ...
%     + (1 - db.b1(i) - db.b3(i)) * (db.e_dl_cpi_core{:,i}), ...
%     + db.b3(i) * (db.dl_cpistar{:,i} + db.dl_s{:,i} - db.dl_z_tnd{:,i}), ...
%     + db.b2(i) * db.b4(i) * db.l_y_gap{:,i}, ...
%     + db.b2(i) * (1 - db.b4(i)) * db.l_z_gap{:,i}, ...
%     + db.shock_dl_cpi_core{:,i}
%     ];
%   
%   decompSeries = db.(seriesName){:,i};
%   rprt = codes.reporting.barContrib(rprt, range, decompSeries, decompContribs, legends(i), legendEntries, parula());
%   
% end
% 
% % Food Phillips curve
% 
% seriesName    = "dl_cpi_food";
% legendEntries = ["Lag", "Expectation", "Direct", "RER gap", "Shock"];
% 
% figureName = xdescrAll(strcmp(xnamesAll,seriesName)) + " [" + seriesName + "]";
% rprt.figure(char(figureName), opts.barconOptions{:}, 'subplot', [paramNum 1]);
% 
% for i = 1:paramNum
%   
%   decompContribs = [ ...
%     + db.bf1(i) * db.dl_cpi_food{:,i}{-1}, ...
%     + (1 - db.bf1(i) - db.bf3(i)) * (db.e_dl_cpi_food{:,i}), ...
%     + db.bf3(i) * (db.dl_foodstar{:,i} - db.dl_rp_foodstar_tnd{:,i} + db.dl_s{:,i} - db.dl_z_tnd{:,i} ...
%     - db.dl_rp_cpi_core_tnd{:,i} + db.dl_rp_cpi_food_tnd{:,i}), ...
%     + db.bf2(i) * (db.l_rp_foodstar_gap{:,i} + db.l_z_gap{:,i} + db.l_rp_cpi_core_gap{:,i} - db.l_rp_cpi_food_gap{:,i}), ...
%     + db.shock_dl_cpi_food{:,i}
%     ];
%   
%   decompSeries = db.(seriesName){:,i};
%   rprt = codes.reporting.barContrib(rprt, range, decompSeries, decompContribs, legends(i), legendEntries, parula());
%   
% end
% 
% % Energy Phillips curve
% 
% seriesName    = "dl_cpi_ener";
% legendEntries = ["Lag", "Expectation", "Direct", "RER gap", "Shock"];
% 
% figureName = xdescrAll(strcmp(xnamesAll,seriesName)) + " [" + seriesName + "]";
% rprt.figure(char(figureName), opts.barconOptions{:}, 'subplot', [paramNum 1]);
% 
% for i = 1:paramNum
%   
%   decompContribs = [ ...
%     + db.be1(i) * db.dl_cpi_ener{:,i}{-1}, ...
%     + (1 - db.be1(i) - db.be3(i)) * (db.e_dl_cpi_ener{:,i}), ...
%     + db.be3(i) * (db.dl_enerstar{:,i} - db.dl_rp_enerstar_tnd{:,i} + db.dl_s{:,i} - db.dl_z_tnd{:,i} ...
%     - db.dl_rp_cpi_core_tnd{:,i} + db.dl_rp_cpi_ener_tnd{:,i}), ...
%     + db.be2(i) * (db.l_rp_enerstar_gap{:,i} + db.l_z_gap{:,i} + db.l_rp_cpi_core_gap{:,i} - db.l_rp_cpi_ener_gap{:,i}), ...
%     + db.shock_dl_cpi_ener{:,i}
%     ];
%   
%   decompSeries = db.(seriesName){:,i};
%   rprt = codes.reporting.barContrib(rprt, range, decompSeries, decompContribs, legends(i), legendEntries, parula());
%   
% end
% 
% % Policy rule
% 
% seriesName    = "i";
% legendEntries = ["Lag", "Natural rate", "Inflation reaction", "Output gap", ...
%   "FX traget", "Shock"];
% 
% figureName = xdescrAll(strcmp(xnamesAll,seriesName)) + " [" + seriesName + "]";
% rprt.figure(char(figureName), opts.barconOptions{:}, 'subplot', [paramNum 1]);
% 
% for i = 1:paramNum
%   
%   decompContribs = [ ...
%     + db.c1(i) * db.i{:,i}{-1}, ...
%     + (1 - db.c1(i)) * db.i_tnd{:,i}, ...
%     + (1 - db.c1(i)) * db.c2(i) * db.d4l_cpi_dev{:,i}, ...
%     + (1 - db.c1(i)) * db.c3(i) * db.l_y_gap{:,i}, ...
%     + (1 - db.c1(i)) * db.c4(i) * (db.dl_s{:,i} - db.dl_s_tar{:,i}), ...
%     + db.shock_i{:,i}, ...
%     ];
%   
%   decompSeries = db.(seriesName){:,i};
%   rprt = codes.reporting.barContrib(rprt, range, decompSeries, decompContribs, legends(i), legendEntries, parula());
%   
% end
% 
% % Exchange rate
% 
% seriesName    = "l_s";
% legendEntries = ["Expectation", "IR differential", "Premium", "Target", "Shock"];
% 
% figureName = "Exchange rate, QQ %" + " [dl_s/4]";
% rprt.figure(char(figureName), opts.barconOptions{:}, 'subplot', [paramNum 1]);
% 
% for i = 1:paramNum
%   
%   decompContribs = [ ...
%     + db.e1(i) * (db.e_l_s{:,i} - db.l_s{:,i}{-1}), ...
%     - db.e1(i) * (db.i{:,i} - db.istar{:,i})/4, ...
%     + db.e1(i) * db.prem{:,i}/4, ...
%     + (1 - db.e1(i)) * db.dl_s_tar{:,i}/4, ...
%     + db.shock_l_s{:,i} ...
%     ];
%   
%   decompSeries = db.(seriesName){:,i} - db.(seriesName){:,i}{-1};
%   rprt = codes.reporting.barContrib(rprt, range, decompSeries, decompContribs, legends(i), legendEntries, parula());
%   
% end
% 
% % RIR trend
% 
% seriesName    = "r_tnd";
% legendEntries = ["Foreign RIR", "Premium", "Expected RER trend depr."];
% 
% figureName = xdescrAll(strcmp(xnamesAll,seriesName)) + " [" + seriesName + "]";
% rprt.figure(char(figureName), opts.barconOptions{:}, 'subplot', [paramNum 1]);
% 
% for i = 1:paramNum
%   
%   decompContribs = [ ...
%     db.rstar_tnd{:,i}, ...
%     db.prem{:,i}, ...
%     db.e_dl_z_tnd{:,i} ...
%     ];
%   
%   decompSeries = db.(seriesName){:,i};
%   rprt = codes.reporting.barContrib(rprt, range, decompSeries, decompContribs, legends(i), legendEntries, lines());
%   
% end
% 
% % Deficit
% 
% seriesName    = "def";
% legendEntries = ["Structural", "Cyclical", "Discretionary"];
% 
% figureName = xdescrAll(strcmp(xnamesAll,seriesName)) + " [" + seriesName + "]";
% rprt.figure(char(figureName), opts.barconOptions{:}, 'subplot', [paramNum 1]);
% 
% for i = 1:paramNum
%   
%   decompContribs = [ ...
%     db.def_str{:,i}, ...
%     db.def_cyc{:,i}, ...
%     db.def_discr{:,i} ...
%     ];
%   
%   decompSeries = db.(seriesName){:,i};
%   rprt = codes.reporting.barContrib(rprt, range, decompSeries, decompContribs, legends(i), legendEntries, lines());
%   
% end
% 
% % Discretionary deficit
% 
% seriesName    = "def_discr";
% legendEntries = ["Lag", "Gov. cons.", "Shock"];
% 
% figureName = xdescrAll(strcmp(xnamesAll,seriesName)) + " [" + seriesName + "]";
% rprt.figure(char(figureName), opts.barconOptions{:}, 'subplot', [paramNum 1]);
% 
% for i = 1:paramNum
%   
%   decompContribs = [ ...
%     + db.d2(i) * db.def_discr{:,i}{-1}, ...
%     + db.d5(i) * db.l_gdem_gap{:,i}, ...
%     + db.shock_def_discr{:,i} ...
%     ];
%   
%   decompSeries = db.(seriesName){:,i};
%   rprt = codes.reporting.barContrib(rprt, range, decompSeries, decompContribs, legends(i), legendEntries, parula());
%   
% end
% 
% % Structural deficit
% 
% seriesName    = "def_str";
% legendEntries = ["Lag", "Gov. cons.", "Shock"];
% 
% figureName = xdescrAll(strcmp(xnamesAll,seriesName)) + " [" + seriesName + "]" + " (deviation from SS)";
% rprt.figure(char(figureName), opts.barconOptions{:}, 'subplot', [paramNum 1]);
% 
% for i = 1:paramNum
%   
%   decompContribs = [ ...
%     + db.d4(i) * (db.def_str{:,i}{-1} - db.ss_def_str(i)), ...
%     + db.d6(i) * (db.dl_gdem_tnd{:,i} - db.dl_y_tnd{:,i}), ...
%     + db.shock_def_str{:,i};
%     ];
%   
%   decompSeries = db.(seriesName){:,i} - db.ss_def_str(i);
%   rprt = codes.reporting.barContrib(rprt, range, decompSeries, decompContribs, legends(i), legendEntries, parula());
%   
% end
% 
% % Money
% 
% seriesName    = "dl_rmd";
% legendEntries = ["Chg. of velocity", "Lag", "GDP growth", "Interest rate", "Shock"];
% 
% figureName = xdescrAll(strcmp(xnamesAll,seriesName)) + " [" + seriesName + "]";
% rprt.figure(char(figureName), opts.barconOptions{:}, 'subplot', [paramNum 1]);
% 
% for i = 1:paramNum
%   
%   decompContribs = [ ...
%     - (1 - db.m1(i)) * db.dl_v{:,i}, ...
%     + db.m1(i) * db.dl_rmd{:,i}{-1}, ...
%     + (1 - db.m1(i)) * db.dl_y{:,i}, ...
%     + (1 - db.m1(i)) * db.m2(i) * (db.i{:,i} - db.i_tnd{:,i}), ...
%     + db.shock_dl_rmd{:,i};
%     ];
%   
%   decompSeries = db.(seriesName){:,i};
%   rprt = codes.reporting.barContrib(rprt, range, decompSeries, decompContribs, legends(i), legendEntries, parula());
%   
% end

end
