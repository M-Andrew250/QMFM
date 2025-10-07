function reportModel

opts = mainSettings();

codes.utils.writeMessage(mfilename + ": loading model ...");

% Load model
tmp = codes.utils.loadResult(opts, "model");
m = tmp.m;

% Load data to calculate historical/filtered variances

if opts.reportModel.varDecomp.run
  tmp = codes.utils.loadResult(opts, "data");
  dbObsTrans = tmp.dbObsTrans;
end

if opts.reportModel.varDecomp.run || opts.reportModel.stdComp.run
  tmp = codes.utils.loadResult(opts, "filter");
  dbFilt = tmp.dbFilt;
end

% Create report
rprt = report.new('Dynamic behavior of the model');

% Set common model dependent variables

% Legend
legends = codes.reporting.createParamLegend(opts);
legendState = length(legends) > 1;

xnamesAll = string(get(m, "xnames"));
xdescrAll = string(get(m, "xdescript"));

enamesAll = string(get(m, "enames"));
edescrAll = string(get(m, "edescript"));

pnamesAll = string(get(m, "pnames"));
pdescrAll = string(get(m, "pdescript"));

pnamesAll = [pnamesAll, "std_" + enamesAll];
pdescrAll = [pdescrAll, edescrAll];

paramNum = length(opts.parameterNames);

% Comparison of parameters

if 1 < paramNum
  
  rprt.section('Comparing parameters');
  
  p   = get(m, "Parameters");
  p   = structfun(@transpose, p, "Uniformoutput", false);
  p   = table2array(struct2table(p))';
  
  ind = any(abs(p(:,2:end) - repmat(p(:,1), 1, paramNum-1)) > 1e-12, 2);
  ind = ind | any(isnan(p),2);
  p   = p(ind,:);
  
  rn = pdescrAll(ind)' + " [" + pnamesAll(ind)' + "]";
  
  rprt.matrix('Differing parameters', p, ...
    'rownames',       cellstr(rn), ...
    'colnames',       cellstr(opts.parameterLegends), ...
    'rotatecolnames', false);
  rprt.pagebreak;
  
end

% Steady states

if opts.reportModel.steady.run
  
  rprt.section('Steady states');
  
  varNames = opts.reportModel.steady.variables;
  
  data = nan(length(varNames), paramNum);
  colNames = string.empty(0, paramNum);
  
  for n = 1 : paramNum
    
    t = table(m(n), "SteadyLevel");
    data(:, n) = t{varNames,:};
    colNames(n) = legends(n);
    
  end
  
  varDescr = codes.utils.selectFromList(varNames, xnamesAll, xdescrAll);
  rowNames = varDescr + " [" + varNames + "]";
  
  rprt.matrix('', data, ...
    'rownames',       cellstr(rowNames), ...
    'colnames',       cellstr(colNames), ...
    'rotatecolnames', false);
  rprt.pagebreak;
  
end

% Impulse responses

if opts.reportModel.IRF.run
  
  optsIRF = opts.reportModel.IRF;
  
  codes.utils.writeMessage(mfilename + ": adding impulse responses ...");
  
  % Get shock and response variable names
  
  if ~isequal(optsIRF.variables, @all)
    xnames = optsIRF.variables;
    xdescr = codes.utils.selectFromList(xnames, xnamesAll, xdescrAll);
  else
    xnames = xnamesAll;
    xdescr = xdescrAll;
  end
  
  if ~isequal(optsIRF.shocks, @all)
    enames  = optsIRF.shocks;
    edescr  = codes.utils.selectFromList(enames, enamesAll, edescrAll);
  else
    enames = enamesAll;
    edescr = edescrAll;
  end
  
  % Calculate impulse responses
  irf = srf(m, 0:optsIRF.horizon, ...
    "select", enames, ...
    "size",   optsIRF.shockSize);
  
  rprt.section('Impulse response functions');
  rprt.pagebreak;
  
  sty = opts.style;
  sty.legend.orientation  = 'vertical';
  sty.legend.location     = 'best';
  
  % Determine the subplot size
  if isempty(optsIRF.subplot) || prod(optsIRF.subplot) < numel(xnames)
    optsIRF.subplot = codes.utils.calcSubplotSize(numel(xnames));
    warning("Subplot size of the IRF figures adjusted to accomodate all responses. Reset the IRF subplot size in mainSettings to avoid this warning.")
  end
  
  for i = 1:length(enames)
    
    figureTitle = char("Responses to " + edescr(i) + " [" + enames(i) + "]");
    rprt.figure(figureTitle, 'style', sty, opts.style.postProcess{:}, 'subplot', optsIRF.subplot);
    
    for j = 1:length(xnames)
      
     % graphTitle = char(xdescr(j) + " [" + xnames(j) + "]");drop label,too crowded
      graphTitle = char(xdescr(j));
      
      if j == 1
        rprt.graph({graphTitle, ' '}, 'zeroline', true, 'range', 0:optsIRF.horizon, 'legend', legendState);
      else
        rprt.graph({graphTitle, ' '}, 'zeroline', true, 'range', 0:optsIRF.horizon);
      end
      
      rprt.series(legends, irf.(xnames(j)){:,i,:});
      
    end
    
  end
  
end

% Variance decompositions

if opts.reportModel.varDecomp.run
  
  optsVD = opts.reportModel.varDecomp;
  
  codes.utils.writeMessage(mfilename + ": adding variance decompositions ...");
  
  rprt.section('Variance decomposition');
  rprt.pagebreak;
  
  % Get shock and response variable names
  
  if ~isequal(optsVD.variables, @all)
    ind     = ismember(xnamesAll,optsVD.variables);
    xnames  = xnamesAll(ind);
    xdescr  = xdescrAll(ind);
  end
  
  enames = get(m, 'enames');
  
  % Calculate variance decomposition
  vd = fevd(m, optsVD.horizon);
  
  if paramNum > 1
    opts.style.legend.orientation  = 'vertical';
    opts.style.legend.location     = 'SouthEast';
    opts.barOptions    = {'style',opts.style,'zeroline=',true,'figureOptions=',{'colorMap=',opts.barcolormap}};
  end
  
  for i = 1:length(xnames)
    
    % Contribution of shocks
    vdi = double(squeeze(vd(xnames(i),:,:,:))');
    
    % Get important shocks for all models
    shockNames = [];
    for j = 1:paramNum
      %       [~,ind] = sort(sum(vdi(:,:,j)),'descend');
      [~,ind] = sort(vdi(1,:,j), "descend");
      shockNames = union(shockNames, enames(ind(1:optsVD.contribs)));
    end
    
    % Select contribution of these shocks
    vdii = [];
    for k = 1:length(shockNames)
      vdii(:,k,:) = squeeze(vd(xnames(i), shockNames(k), :, :));
    end
    ind = ismember(colnames(vd), shockNames);
    vdii = cat(2, vdii, sum(vdi(:,~ind,:),2));
    
    % Sort according to importance in the first model
    %     [~,ind] = sort(sum(vdii(:,1:end-1,1)),'descend');
    [~,ind] = sort(vdii(1,1:end-1,1), "descend");
    vdii = vdii(:,[ind end],:);
    shockNames = shockNames(ind);
    
    figureTitle = char(xdescr(i) + " [" + xnames(i) + "]");
    rprt.figure(figureTitle, 'subplot', [2 paramNum], opts.barOptions{:});
    
    for j = 1:paramNum
      
      vdirel = 100*bsxfun(@rdivide,vdii(:,:,j),sum(vdii(:,:,j),2));
      vdirel = Series(1:optsVD.horizon, vdirel);
      
      % Standard deviation
      stdi{j} = Series(1:optsVD.horizon, sqrt(sum(vdi(:,:,j),2)));
      
      seriesNames = [shockNames; {'Rest'}];
      seriesNames = strrep(seriesNames,'_','\_');
      
      if paramNum > 1
        rprt.graph(char(legends(j)), 'ylabel', 'Constribution of shocks (%)', 'legend', true);
      else
        rprt.graph('', 'ylabel', 'Constribution of shocks (%)', 'legend', true);
      end
      rprt.series('', vdirel, 'plotFunc', @barcon, 'legendEntry', seriesNames);
      
    end
    
    for j = 1:paramNum
      
      if paramNum > 1
        rprt.graph(legends(j), 'ylabel','Absolute std','legend',true,'postProcess',...
          'yl = get(gca,''ylim'');set(gca,''ylim'',[0 yl(2)]);'...
          );
      else
        rprt.graph('','ylabel','Absolute std','legend',false,'postProcess',...
          'yl = get(gca,''ylim'');set(gca,''ylim'',[0 yl(2)]);'...
          );
      end
      rprt.series('Model', stdi{j});
      
      
      % Historical standard deviation
      obsName = "obs_" + xnames(i);
      if isfield(dbObsTrans, obsName)
        vhist = dbObsTrans.(obsName);
      else
        vhist = dbFilt.mean.(xnames(i)){:,j};
      end
      vhist = nanstd(vhist{optsVD.histRange});
      vhist = Series(1:optsVD.horizon, vhist);
      rprt.series('Hist std', vhist);
      
      
      %       vari  = smoother_db.mean.(xnames{i});
      %       rmsei = zeros(opts.vardecomp_horizon,1);
      %       for l = 1:opts.vardecomp_horizon
      %         rmsei(l) = sqrt(nanmean(diff(vari,l)^2));
      %       end
      %       rmsei_rw = Series(1:opts.vardecomp_horizon,rmsei);
      %
      %       vari  = smoother_db.mean.(xnames{i});
      %       fdi   = startdate(vari);
      %       rmsei = zeros(opts.vardecomp_horizon,1);
      %       for l = 1:opts.vardecomp_horizon
      %         fc_err = Series;
      %         for dt = opts.vardecomp_hist_range
      %           fc_err(dt+l) = vari(dt+l) - nanmean(vari{fdi:dt});
      %         end
      %         rmsei(l) = sqrt(nanmean(fc_err^2));
      %       end
      %       rmsei_st = Series(1:opts.vardecomp_horizon,rmsei);
      %       rprt.series({'Hist std','RW RMSE', 'St RMSE'},[vhist rmsei_rw rmsei_st]);
      
      
    end
    
  end
  
end

% Compare standard deviations

if opts.reportModel.stdComp.run
  
  rprt.section('Standard deviations: asymptotic model vs. data');
  
  compVarNames  = opts.reportModel.stdComp.variables;
  compRange     = opts.reportModel.stdComp.range;
  
  nVars     = length(compVarNames);
  stds      = nan(nVars, 2*paramNum);
  colNames  = string.empty(0, 2*paramNum);
  
  c = 0;
  for n = 1 : paramNum
    
    % Calculate data/filtered std-s
    c = c + 1;
    for i = 1 : nVars
      stds(i, c) = std(dbFilt.mean.(compVarNames(i)){compRange, n});
    end
    colNames(c) = legends(n) + ", data";
    
    % Calculate model implied std-s
    c = c + 1;
    covModel = acf(m(n));
    stds(:, c) = sqrt(diag(covModel(compVarNames, compVarNames)));
    colNames(c) = legends(n) + ", model";
    
  end
  
  compVarDescr = codes.utils.selectFromList(compVarNames, xnamesAll, xdescrAll);
  rowNames = compVarDescr + " [" + compVarNames + "]";
    
  rprt.matrix('', stds, ...
    'rownames',       cellstr(rowNames), ...
    'colnames',       cellstr(colNames), ...
    'rotatecolnames', false, ...
    'long',           true);
  
  rprt.section('Standard deviations: filtered shocks vs. model calibration');
  
  compVarNames  = opts.reportModel.stdComp.shocks;
  compRange     = opts.reportModel.stdComp.range;
  
  nVars     = length(compVarNames);
  stds      = nan(nVars, 2*paramNum);
  colNames  = string.empty(0, 2*paramNum);
  
  c = 0;
  for n = 1 : paramNum
    
    % Calculate data/filtered std-s
    c = c + 1;
    for i = 1 : nVars
      stds(i, c) = sqrt(mean(dbFilt.mean.(compVarNames(i)){compRange, n}^2));
    end
    colNames(c) = legends(n) + ", filtered";
    
    % Calculate model implied std-s
    c = c + 1;
    for i = 1 : nVars
      stds(i, c) = m(n).("std_" + compVarNames(i));
    end
    colNames(c) = legends(n) + ", calibrated";
    
  end
  
  compVarDescr = codes.utils.selectFromList(compVarNames, enamesAll, edescrAll);
  rowNames = compVarDescr + " [" + compVarNames + "]";
    
  rprt.matrix('', stds, ...
    'rownames',       cellstr(rowNames), ...
    'colnames',       cellstr(colNames), ...
    'rotatecolnames', false);
  
end

% Model equations

if opts.reportModel.equations.run
  
  codes.utils.writeMessage(mfilename + ": adding equations ...");
  
  str = "Equations (parameter values taken from " + opts.parameterNames(1) + ".m)";
  
  rprt.modelfile(char(str), char(opts.modelFile), m);
  
end

% Publish report

codes.utils.writeMessage(mfilename + ": compiling ...");
codes.utils.saveReport(opts, "modelReport", rprt);
codes.utils.writeMessage(mfilename + ": done");

end