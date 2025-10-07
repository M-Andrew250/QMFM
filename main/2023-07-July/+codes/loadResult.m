function res = loadResult(opts, what)

evalstr = "load('" + fullfile(opts.mainDir, "results", what + ".mat") + "')";
res = eval(evalstr);

end