function chk = checkFile(fname)

ifok = false;

while ~ifok
  
  fid = fopen(fname,'a');
  
  if fid == -1
    
    btn = questdlg(['The file "', fname, '" is open outside of MATLAB. Please close it and press Continue.'],'File locked for writing','Continue','Cancel','Cancel');
    switch btn
      case 'Continue'
        chk = true;
      case 'Cancel'
        chk = false;
        ifok = true;
    end
    
  else
    
    fclose(fid);
    delete(fname);
    chk = true;
    ifok = true;
    
  end
  
end