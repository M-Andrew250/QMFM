function reportDataRaw
clear, clc, close all

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
  "TextType", "string"); % optional'VariableNamingRule','preserve'---

rngPlot = qq(2006, 3) : qq(2025, 2);
rngTable = qq(2021, 3) : qq(2025, 2);
% --------- Copy variables into db as time series ---------

varNames = [
  "ystar"
  "cpistar"
  "enerstar"  % is GAS projection (in $) fr Rwametric
  "enerGEEstar"  % is GEE projection for Rwanda ($ in % change) fr Rwametric; see cumsum below
  "foodstar"
  "istar"
  "pexpstar"
  "pimpstar"
  "s"
  "s_eoq" % end of quarter ER added 12/12/23
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
  "nfg_usd_cur"
  "nfg_usd_cap"
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
  "dBG_bop_usd"
  "dBnbf"
  "dBbf"
  "ny_agric"
  "nexp_usd_goods"
  "nimp_usd_goods"
  "ngexp_WS" 
  "ngexp_GS"
  "nNLB"
   "nda"
   "s_eoq"
   "ngexp_currexp"
    "ngexp_WS"
    "ngexp_GS"
  ];

for v = varNames(:)'
  ind     = t{:,1} == v;
  values  = double(t{ind, 3:end}');
  dbRaw.(v)  = Series(qq(1995, 1), values);
  
end

% -------- Read the additional data file --------
codes.utils.writeMessage(mfilename + ": reading data from " + opts.addDataFile + "...");

gpm = databank.fromCSV(addDataFullFile); % reads addData that has gpm for RIR, Poil and BERfiscal

dbRaw = dboverlay(gpm, dbRaw);

% ------------- Save results -------------

codes.utils.writeMessage(mfilename + ": saving results ...");
codes.utils.saveResult(opts, "dataRaw", "dbRaw");
codes.utils.writeMessage(mfilename + ": done");
%%=====================================================================================================
%%
%-------Generate a report for raw data----------------
%-------load data---------------------
tmp = codes.utils.loadResult(opts, "dataRaw");

% ------------- Create the report -------------
% ------------- Publish report -------------

reportTitle = "Data screening report";
rprt = report.new(char(reportTitle));

rprt.section('National Account (NA)');
rprt.pagebreak;  
varNames =  [        
        "ny"
        "ngcons"
        "ncons"
        "ninv"
        "nexp"
        "nimp"
        "ny_agric"
        "y"
        "gcons"
        "cons"
        "inv"
        "exp"
        "imp"
        "y_agr"
        ];

varDescr = [
        "GDP, current prices (CP)"
        "Govt. consumption expenditure, CP"
        "Private consumption expenditure, CP"
        "Gross capital formation, CP"
        "Export of G&S, CP"
        "Import of G&S, CP"
        "Agric GDP, current prices (CP)"
        "GDP, Constant prices (KP)"
        "Govt. consumption expenditure, KP"
        "Private consumption expenditure, KP"
        "Gross capital formation, KP"
        "Export of G&S, KP"
        "Import of G&S, KP"
        "Agric GDP, constant prices (KP)"
        ];


rprt = addVariableCharts(rprt, dbRaw, varNames, varDescr, opts);
tableTitle = 'National Accounts (NA)';
rprt.table(char(tableTitle), 'range', rngTable, 'typeface', '\small', 'long', true, ...
  'vline', rngTable(1) -1);

for i = 1:size(varNames)
    rprt.series(char(varDescr(i)), dbRaw.(varNames(i)));
end
%%
% ------------ Price Indices ------------

rprt.section('Price indices');
rprt.pagebreak;
varNames = [
        "cpi"
        "cpi_core"
        "cpi_food"
        "cpi_ener"
        ];

varDescr = [
        "Headline CPI, index"
        "Core CPI, index"
        "Fresh food CPI, index"
        "Energy CPI, index"
        ];

rprt = addVariableCharts(rprt, dbRaw, varNames, varDescr, opts);

tableTitle = 'Price indices';
rprt.table(char(tableTitle), 'range', rngTable, 'typeface', '\small', 'long', true, ...
  'vline', rngTable(1) -1);

for i = 1:size(varNames)
    rprt.series(char(varDescr(i)), dbRaw.(varNames(i)));
end 

%%
% ----------------- External(BOP)---------------

rprt.section('External (BOP) indicators');
rprt.pagebreak;
varNames = [
        "nexp_usd_goods"
        "nimp_usd_goods"
        "dBP1_usd"
        "nfg_usd_cur"
        "nfg_usd_cap"
        ];

varDescr = [
        "Export of goods, Mln USD"
        "Imports of goods, Mln USD"
        "Direct investment, Mln USD"
        "Govt budgetary grants, Mln USD"
        "Capital grants, Mln USD"
        ];

rprt = addVariableCharts(rprt, dbRaw, varNames, varDescr, opts);

tableTitle = 'Price indices';
rprt.table(char(tableTitle), 'range', rngTable, 'typeface', '\small', 'long', true, ...
  'vline', rngTable(1) -1);

for i = 1:size(varNames)
    rprt.series(char(varDescr(i)), dbRaw.(varNames(i)));
end

%%
% ----------------- Fiscal indicators---------------------

rprt.section('Fiscal indicators');
rprt.pagebreak;
varNames = [
        "ngrev"
        "nfg"
        "ngexp"
        "nginv"
        "ngexp_currexp"
        "ngexp_WS"
        "ngexp_GS"
        "nintp_lcy"
        "nintp_fcy"
        ];

varDescr = [
        "Total revenue, Mln USD"
        "Total grants, Mln USD"
        "Total expenditure, Mln USD"
        "Capital expenditure, Mln USD"
        "Current expenditure, Mln USD"
        "Wages (Incl.LG&EBUs), Mln USD"
        "Purchases of G&S, Mln USD"
        "Interest payments domestic, Mln RWF"
        "Interest payments foreign, Mln USD"

        ];
rprt = addVariableCharts(rprt, dbRaw, varNames, varDescr, opts);

tableTitle = 'Fiscal indicators';
rprt.table(char(tableTitle), 'range', rngTable, 'typeface', '\small', 'long', true, ...
  'vline', rngTable(1) -1);

for i = 1:size(varNames)
    rprt.series(char(varDescr(i)), dbRaw.(varNames(i)));
end
%%
%-------------------Monetary indicators------------------------------------
rprt.section('Monetary indicators');
rprt.pagebreak;
varNames = [
        "nfa"
        "nda"
        "ncg"
        "md"
        "s"
        "s_eoq"
        "i_pol"
        "i_lend"
        "i_repo"
        "i_rev_repo"
        "i_ib"
        ];

varDescr = [
        "Net foreign assets, Mln USD"
        "Net domestic assets, Mln USD"
        "Net Credit government, Mln USD"
        "Broad money M3, Mln USD"
        "Exchange rate, USD, pa"
        "Exchange rate, USD, eop"
        "Central Bank Rate, %"
        "Lending rate, %"
        "Repo rate, %"
        "Reserve repo rate, %"
        "Interbank rate, %"
        ];

rprt = addVariableCharts(rprt, dbRaw, varNames, varDescr, opts);

tableTitle = 'Monetary indicators';
rprt.table(char(tableTitle), 'range', rngTable, 'typeface', '\small', 'long', true, ...
  'vline', rngTable(1) -1);

for i = 1:size(varNames)
    rprt.series(char(varDescr(i)), dbRaw.(varNames(i)));
end

codes.utils.writeMessage(mfilename + ": compiling Data screening report ...");
codes.utils.saveReport(opts, "dataScreeningReport", rprt);
codes.utils.writeMessage(mfilename + ": dataScreeningReport" + ": done");
%%

end

function rprt = addVariableCharts(rprt, dbRaw, varNames, varDescr, opts)

style = opts.style;
style.legend.orientation  = "vertical";
style.legend.location     = "best";

cntr = 0;
while ~isempty(varNames)

  nVars = min(6, numel(varNames));
  varNamesCurrPage = varNames(1 : nVars);

  cntr = cntr+1;
  figureTitle = "Observed variables (page " + cntr + ")";

  opts.style.line.marker = '*';
  opts.style.line.markerSize = 4;

  rprt.figure(char(figureTitle), 'range', opts.filterHistory.range, ...
   'style', style, 'zeroline', true, 'subplot', [2, 3]);

  
  c = 0;
  for v = varNamesCurrPage(:)'

      w = find(varNames == v);

      if ~isempty(w)
          varDescrCurr = varDescr(w);
      else
          varDescrCurr = "";
      end

    c = c + 1;
    if c == 0
            rprt.graph(char(varDescrCurr + " [" + v + "]"), 'legend', true);
    else
            rprt.graph(char(varDescrCurr + " [" + v + "]"), 'legend', false);
    end
    rprt.series('', dbRaw.(v));

  end

  varNames(1 : nVars) = [];
  varDescr(1 : nVars) = [];

end

end