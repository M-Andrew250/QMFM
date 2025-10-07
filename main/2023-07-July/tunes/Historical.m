function dbObs = Historical(dbObs)  % changes Oct 28 2022

% -------- Predefine tunes --------

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
  dbObs.(n) = Series();
end

% -------- Set tune values -----

% Do not create Series here! Only assign values to existing series, created
% in the loop above.

% avoid that trend bends down before Covid, so we set outputgap low
rngTune = qq(2019, 4);
dbObs.tune_l_y_gap(rngTune) = 1;

% To distribute the GDP nowcast into the shocks of components
rngTune = qq(2023,2) : qq(2023,3);
dbObs.tune_d4l_y(rngTune) = 100 * log(1 + [5.1, 4.3]/100);

end
