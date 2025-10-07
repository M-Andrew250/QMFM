function opts = processOptions(opts)

% ------------- Directories and files -------------

folders = split(opts.mainDir, filesep);

opts.QMFMDir = join(folders(1:end-2), filesep);

opts.modelFile      = fullfile(opts.mainDir, "model", opts.modelFile + ".model");
opts.mainDataFile   = fullfile("Rwametric_" + opts.mainDataFile + ".xlsm");
opts.addDataFile    = fullfile("addData_"   + opts.addDataFile + ".csv");

opts.tunesDir = fullfile(opts.mainDir, "tunes");

resultsDir = fullfile(opts.mainDir, "results");
% resultsDir = fullfile(opts.QMFMDir, "results", opts.roundId);

opts.resultsDirMat = fullfile(resultsDir, "mat");
opts.resultsDirPdf = fullfile(resultsDir, "pdf");
opts.resultsDirEmf = fullfile(resultsDir, "emf");
opts.resultsDirCsv = fullfile(resultsDir, "csv");

% ------------- Create directories -------------

if ~exist(opts.resultsDirMat, "dir")
  mkdir(opts.resultsDirMat)
end

if ~exist(opts.resultsDirPdf, "dir")
  mkdir(opts.resultsDirPdf)
end

if ~exist(opts.resultsDirEmf, "dir")
  mkdir(opts.resultsDirEmf)
end

if ~exist(opts.resultsDirCsv, "dir")
  mkdir(opts.resultsDirCsv)
end

% ------------- Options of the comparison round -------------

if opts.compRound ~= ""
  opts.compDir = fullfile(opts.QMFMDir, opts.compRound);  
  cd(opts.compDir)
  opts.compOpts = mainSettings;
  cd(opts.mainDir)
end

% ------------- Style options ------------

red     = [232 139 009]/255;
blue    = [004 090 209]/255;
green   = [113 177 080]/255;
yellow  = [247 250 013]/255;

cmp0 = [red;blue;green;yellow];

sty.figure.visible      = {'off'};

sty.axes.box            = {'off'};
sty.axes.FontSize       = 9;

sty.xlabel.String       = ' ';

sty.line.linewidth      = {2,2,2,1.5,1.5,1.5};
sty.line.linestyle      = {'-','-','-','--','--','--',':',':',':'};
sty.line.color          = {red,blue,green};

sty.fanchart.basecolor  = {[0,0.3,0.9]};
sty.fanchart.edgeColor  = 'none';

sty.legend.orientation  = 'horizontal';
sty.legend.location     = 'SouthOutside';
sty.legend.box          = 'on';

sty.title.color         = 'black';
sty.title.FontWeight    = 'normal';
sty.title.FontName      = 'Helvetica';

% sty.postProcess  = {'postProcess','set(gca,''YTickLabel'',num2str(get(gca,''YTick'')''))'};
sty.postProcess  = {};

opts.style = sty;

opts.barcolormap = ogrcolormap(cmp0);

opts.barOptions    = {'style',sty,'zeroline=',true,'figureOptions=',{'colorMap=',opts.barcolormap}};

% ----- Modify the style for bar graphs showing bars of contributions +line of total -----

barconsty = sty;
barconsty.line.linewidth      = {3,1.5};
barconsty.line.linestyle      = {'-','-'};
barconsty.line.color          = {[1 1 1], [0 0 0]};

opts.barconOptions    = {'style',barconsty,'zeroline=',true,'figureOptions=',{'colorMap=',opts.barcolormap}};

opts.tableOptions  = {...
  'decimal',1,'dateformat','YYFP', ...
  'long',true,'longfoot','---continued','longfootposition','right',...
  'arrayStretch',1.25,'typeface','\small'};

opts.style_hist_actual = {...
  'linewidth',  2,...
  'linestyle',  '-',...
  'color',      red};

opts.style_hist_forecast = {...
  'linewidth',  0.75,...
  'linestyle',  '--',...
  'color',      blue};

opts.style_hist_mark = {...
  'linestyle',        'none',...
  'marker',           '*',...
  'markersize',       9,...
  'markerfacecolor',  red,...
  'markeredgecolor',  red,...
  };

opts.publishOptions = {...
  'maketitle',true,...
  'display',false,...
  'preamble','\usepackage[latin2]{inputenc}',...
  'timeStamp',['Round: ', char(opts.roundId), ', time: ',datestr(now()), '.'],...
  'papersize','a4paper'...
  };

end

function cmp = ogrcolormap(cmp0)

cmpp = cmp0;
for i = 1:3
  cmpn = nan(2*i-1,3);
  c = 1;
  for j = 1:2*size(cmpp,1)-1
    if rem(j,2) == 1
      cmpn(j,:) = cmpp(c,:);
    else
      cmpn(j,:) = cmpp(c,:)/2 + cmpp(c+1,:)/2;
      c = c+1;
    end
  end
  cmpp = cmpn;
end
cmp = cmpp;

end