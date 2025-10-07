function chk = checkFile(fileName)

if ~exist(fileName, "file")
  chk = true;
  return
end

ifOk = false;

while ~ifOk
  
  fid = fopen(fileName, 'a');
  
  if fid == -1
    
    btn = questdlg(['The file "', fileName, '" is open outside of MATLAB. Please close it and press Continue.'],'File locked for writing','Continue','Cancel','Cancel');
    switch btn
      case 'Continue'
        chk = true;
      case 'Cancel'
        chk = false;
        ifOk = true;
    end
    
  else
    
    fclose(fid);
    delete(fileName);
    chk = true;
    ifOk = true;
    
  end
  
end