function chk = checkFile(fileName)
% codes.utils.chekcFile checks if a file can be overwritten.
%
% Usage: chk = codes.utils.chekcFile(fileName)
%
% codes.utils.chekcFile checks if a file can be overwritten. If not, a
% modal dialogue box is created, requiring the user to close the file, or
% to abort the current operation.
% 
% Iputs:
% - fileName: the file to be created/overwritten
%
% Outputs:
% - chk: a boolean indicating whether operation can continue

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