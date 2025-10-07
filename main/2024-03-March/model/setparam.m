function p = setparam_fiscImp()

% -------------------------------
% -------- Steady states --------
% from debt_calc.m (target debt/GDP, grants/GDP--->sust.deficit 11%)
p.ss_grev_y_str = 21; % aver govt rev % of gdp for 2011-2026/27
p.ss_oexp_y_str = 6;  % aver govt other exp % of gdp for 2011-2026/27 
p.ss_gdem_y_str = 26; % aver govt dem G&S % of gdp for 2011-2026/27 

p.ss_dl_y_tnd             =  100*log(1 + 7.5/100);
p.ss_dl_y_agr_tnd         =  100*log(1 + 7.5/100); % as IMF-NBR WP, check seems high
p.ss_d4l_cpi_tar          =  100*log(1 + 5.0/100);
p.ss_dl_rp_cpi_food_tnd   =  100*log(1 + 2.0/100);
p.ss_dl_rp_cpi_ener_tnd   =  0.0;
p.ss_dl_z_tnd             =  0.0; 
p.ss_prem                 =  2; % set at 1 Dec 16 2022; before we used 3
p.ss_prem_d               =  8.5;
p.ss_dl_v                 =  100*log(1 - 2/100);

p.ss_bor_str    =  6; % ss (in % GDP) borr fr debt targets
p.ss_grants_y   =  5; % ss (in % GDP) grants fr expected donor support

p.ss_dl_cpistar           = 100*log(1 + 2/100);
p.ss_dl_rp_foodstar_tnd   = 0;
p.ss_dl_rp_enerstar_tnd   = 0;
p.ss_rstar_tnd            = 0;

% ---------------------------------------
% -------- Cyclical coefficients --------

% ----- Fiscal parameters -----

p.d7  = 0.50; 0.95; % Persistence of fiscal grants, needs to be looked at, too high

p.v1 = 0.012; 0.042; % 0.2*0.06 response cyclical rev (VAT, excises) to consgap times share VAT, excises share in GDP
p.v2 = 0.006; 0.021; % 0.2*0.03 response cyclical rev (import taxes) to importgap times share importatax share in GDP
p.v3 = 0.020; 0.07; % 0.2*0.10 response cyclical rev (income tax, nontax rev) to outputgap times share income tax in GDP

p.v4 = 0.99; % lag coefficient structural rev

p.u1 = 0; 0.9;       % lag coefficient cyclical other exp
p.u2 = 0.012; 0.036; % 0.2*0.06 response cyclical other exp to outputgap times share other exp in GDP (negative coeff in eq)
p.u3 = 0.95;         % lag coefficient structural other exp

p.t1 = 0; 0.9; % lag coefficient cyclical govt dem G&S
p.t2 = 0.023; 0.115; 0.23; % 0.1*0.23 response cyclical govt dem G&S to outputgap times share govt dem in GDP (negative coeff in eq)
p.t3 = 0.95;  % lag coefficient structural govt dem G&S 
p.t4 = 0.7;   % lag coefficient discretionary govt dem G&S 

p.s1 = 1; % gdem_y_discr in fiscal impulse 

% ----- GDP components -----

% --- Consumption gap ---

p.a1_cons   = 0.65; % Lag, close to Hungary and Armenia models
p.a2_cons   = 0.00; % Expectation, less then in the above
p.a3_cons   = 0.1;  % RMCI, btw HU and AM
p.a4_cons   = 0.2; 0.3; % Output gap, in line with AM model
p.a5_cons   = 0.25; 0.1; 0.5; % Fiscal impulse; coeff=impact/cons share GDP=0.4/0.78=0.5
% divide by 2 as fiscal impulse eq. has factor 2: ie sum discr + ch struct def
p.a6_cons   = 1;    % RIR in rmci

% --- Investment gap ---

p.a1_inv   = 0.65;  % Lag
p.a2_inv   = 0.00;  % Expectation
p.a3_inv   = 0.1;   % RMCI
p.a4_inv   = 0.2; 0.3; % Output gap
p.a5_inv   = 0.15; 0.06; 0.3; % Fiscal impulse; coeff=impact/cons share GDP=0.04/0.13=0.3;
% divide by 2 as fiscal impulse eq. has factor 2: ie sum discr + ch struct def
p.a6_inv   = 1;     % RIR in rmci

% --- Export gap ---

p.a1_exp  = 0.65; % Lag ranges: HU = 0.6, AR= 0.5
p.a2_exp  = 0.00; % Expectation
p.a3_exp  = 0.2; 0.1; % RMCI (i.e. RER): HU = 0.075, AR = 0.3
p.a5_exp  = 0.3; 0.5; % Foreign demand, close to HU=0.25 and AM=0.1
p.a6_exp  = 0;    % RIR in rmci

% --- Import gap ---
% (coeff. are import shares (hereunder)* Fdemand weight GDP (below))

p.lam_imp_cons  = 0.20;
p.lam_imp_inv   = 0.42;
p.lam_imp_gdem  = 0.42;
p.a1_imp        = 0.3; % before 0.1; % RER gap, elast is large; Hungary 0.04-0.08 for imp-cons, Armenia 0.2

% --- Agricultural output gap ---

p.r1_y_agr  = 0.40;0.80; % AR(1) in agric output gap,WP-IMF-NBR
p.r2_y_agr  = 0.80; % persistence agric output trend WP-IMF-NBR

% ----- Phillips curves -----

% --- Core inflation --- 
p.b1  = 0.45; % lag,  before 0.35; IMF WP/20/295 has 0.5, but must be tested
p.b2  = 0.20; % RMC, based on IMF WP/20/295
p.b3  = 0.05; % we keep 0.05 as before; direct import share core 0.20 but such passthru unlikely & unstable
p.b4  = 0.80; % Output gap in RMC, close to what we see in the references

% --- Food inflation --- 
% (add l_y_gap to RMC, so that we can test the domestic cost effect)
p.bf1 = 0.35; % lag; before 0.5; lowering a bit makes price adj faster; IMF-BNR WP/20/295: 0.5
p.bf2 = 0.1; % indirect effect, REER_food, smaller<most references, but here fresh food only; IMF-NBR rmc:0.3
p.bf3 = 0.10; 0.03; % before 0.03; now 0.1 ~importshare in fresh food;larger than in SARB WP/17/01
p.bf4 = 1.5;0.48; % agric.output gap, as IMF-BNR WP/20/295 (coeff rmc)*(coeff agric gap)=0.3*1.6

% --- Energy inflation ---
% (need to examine exact content of data; add l_y_gap to rmc and test domestic costs effect
p.be1 = 0.25; % lag, before 0.5; IMF WP/20/295 has 0.8
p.be2 = 0.04;0.2; % RMC, smaller than in IMF WP/20/295 0.3
p.be3 = 0.02;0.20; 0.03; % before 0.3, now 0.2 ~import share in energy; 0.08 in IMF WP/14/159 Charry

% ----- Monetary policy rule -----

p.c1 = 0.8; 0.5; % Smoothing, was 0.5, now close to NBR 0.8 & other references
p.c2 = 0.5; % dl_cpi_dev, lower end of the reference range, but larger then IMF WP/20/295
p.c3 = 0.5; % l_y_gap, most references have similar value, but NBR-IMF WP/20/295 has lower (0.2)
p.c4 = 0.0; % FX target, does not appear in any of the references
p.c5 = 0.9; % CPI target AR
p.c6 = 0.9; % Credit premium AR

% ----- Exchange rate ------

p.e1 = 0.2; 0.5; % we had 0.5 before (pure target 0, pure UIP 1)
p.e2 = 0.2;   % Forward looking: 1
p.e3 = 0.9;   % Premium AR
p.e4 = 0.00;  % Target deprc. AR
p.e5 = 0.30;  % Target deprc. infl. dev.
p.e6 = 0.85;  % Target deprc. REER gap

% ----- Money demand -----

p.m1 = 0.7; % Lag
p.m2 = 0.5; % Interest rate
p.m3 = 0.9; % Persistence of velicity

% -------------------------
% -------- Weights --------

% ----- GDP components -----
% (2020 from NA data)

p.w_y_cons  = 0.78;
p.w_y_gdem  = 0.23;
p.w_y_exp   = 0.21;
p.w_y_imp   = 0.35;
p.w_y_inv   = 1 + p.w_y_imp - p.w_y_cons - p.w_y_gdem - p.w_y_exp;

% ----- Import content of export -----

p.lam_imp_exp = (p.w_y_imp - (p.lam_imp_cons * p.w_y_cons + p.lam_imp_inv * p.w_y_inv ...
  + p.lam_imp_gdem  * p.w_y_gdem) ) / p.w_y_exp;

% for import gap, the coeff. are import shares in FD * Fdemand weight in imports
p.w_imp_cons  = p.lam_imp_cons  * p.w_y_cons  / p.w_y_imp;
p.w_imp_inv   = p.lam_imp_inv   * p.w_y_inv   / p.w_y_imp;
p.w_imp_gdem  = p.lam_imp_gdem  * p.w_y_gdem  / p.w_y_imp;
p.w_imp_exp   = p.lam_imp_exp   * p.w_y_exp   / p.w_y_imp;

% ----- CPI components -----

p.w_core = 7747/10000; % core NISR excl. fresh food/energy; import share is 25%
p.w_food = 1577/10000; % fresh food only; import share is 10%
p.w_ener =  676/10000; % energy; import share is 20%

% ------------------------------------
% -------- Trend persistences --------

p.r_cons      = 0.95;
p.r_inv       = 0.95;
p.r_gdem      = 0.95;
p.r_exp       = 0.95;
p.r_imp       = 0.95;
p.r_z         = 0.95;
p.r_rp_food   = 0.90;
p.r_rp_ener   = 0.90;
p.rho_r_tnd   = 0.9; % AR(1) in real interest rate, toward ss

% ---------------------------------
% -------- Standard errors --------

% ----- Cyclical shocks -----

p.std_shock_grev_y_cyc   = 0.00;
p.std_shock_grev_y_str   = 0.1;0.1732;
p.std_shock_grev_y_discr = 1.7321;

p.std_shock_oexp_y_cyc   = 0.00;
p.std_shock_oexp_y_str   = 0.1732;
p.std_shock_oexp_y_discr = 1.7321;

p.std_shock_gdem_y_cyc   = 0.00;
p.std_shock_gdem_y_str   = 0.075;0.1732;
p.std_shock_gdem_y_discr = 1.7321;

p.std_shock_l_cons_gap    = 2.5;
p.std_shock_l_inv_gap     = 6;
p.std_shock_l_exp_gap     = 6;
p.std_shock_l_imp_gap     = 0.5;

p.std_shock_l_y_agr_gap   = 0.3; % IMF-NBR WP gives no value SD

p.std_shock_dl_cpi_core   = 2;0.95;
p.std_shock_dl_cpi_food   = 9;6;
p.std_shock_dl_cpi_ener   = 7.1;3.5;

p.std_shock_i             = 1;1.7;
p.std_shock_prem_d_gap    = 0.80;

p.std_shock_l_s           = 0.35;

p.std_shock_dl_rmd        = 1;
p.std_shock_dl_v          = 0.1;

% ----- Discrepancy shocks -----

p.std_shock_l_y_gap       = 1e-4;
p.std_shock_l_cpi         = 1e-4;

% ----- Trend shocks -----

p.std_shock_grants_y = 2.5;0.30;

p.std_shock_dl_cons_tnd   = 0.25;
p.std_shock_dl_inv_tnd    = 0.50;
p.std_shock_dl_gdem_tnd   = 0.50; % not needed in new fiscal block
p.std_shock_dl_exp_tnd    = 0.75;
p.std_shock_dl_imp_tnd    = 0.25;

p.std_shock_dl_y_agr_tnd  = 0.06;

p.std_shock_dl_z_tnd  = 0.10;

p.std_shock_prem  = 0.10;

p.std_shock_d4l_cpi_tar   = 0.10;
p.std_shock_dl_s_tar      = 0.30;

p.std_shock_dl_rp_cpi_food_tnd  = 0.50;
p.std_shock_dl_rp_cpi_ener_tnd  = 0.15;

% -------------------------------------
% -------- External parameters --------

p.r_ystar             = 0.94;
p.r_cpistar           = 0.80;
p.r_istar             = 0.95;0.80;
p.r_rstar_tnd         = 0.90;
p.r_rp_foodstar_gap   = 0.62;
p.r_rp_enerstar_gap   = 0.73;
p.r_rp_foodstar_tnd   = 0.90;
p.r_rp_enerstar_tnd   = 0.90;

p.std_shock_l_ystar_gap         = 0.45;0.25;
p.std_shock_dl_cpistar          = 3.8;  
p.std_shock_istar               = 0.45;
p.std_shock_rstar_tnd           = 0.5;
p.std_shock_l_rp_foodstar_gap   = 5.3;
p.std_shock_l_rp_enerstar_gap   = 13.9;
p.std_shock_dl_rp_foodstar_tnd  = 0.5;3.7;
p.std_shock_dl_rp_enerstar_tnd  = 2.5;6;

% --------------------------------------------
% -------- Auxiliary model parameters --------

p.ss_debt_fcy_rat   =  55/65;
% p.ss_prem_debt_fcy  = -0.5; % discount vis-a-vis ss_istar
% p.ss_prem_debt_lcy  =  2.8; % premium above i policy trend

p.mu_pexp = 0.2;   % ak changed from 0.3
p.mu_pimp = 0.35; % ak changed from 0.3

p.r_debt_fcy_rat = 0.9; % 55/65 is steady state, not AR(1) parameter
%ak govt debt interest rate eq., go to ss interest (foreign,domestic) + premium
p.r_debt_fcy_intrate_pers = 0.9; % persistence imterest rate foreign debt
p.r_debt_lcy_intrate_pers = 0.9; % persistence imterest rate domestic debt 

p.gamma_r = 0.5; % was 1.0, we need lower UIP effect
p.gamma_k = 0.5; % 0.8; was 0.5, we need higher persistence
p.gamma_BP_tnd = 0.9; % ak 7/14/23

end
