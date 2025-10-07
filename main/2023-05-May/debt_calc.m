% 
% b_lcy = b_lcy{-1} / dNOM + d_lcy
% b_fcy = b_fcy{-1} / dNOM * dS + d_fcy
% b_fcy = r_fcy * b
% 
% (1 - r_fcy) * b = (1 - r_fcy) * b{-1} / dNOM + d_lcy
%      r_fcy  * b =      r_fcy  * b{-1} / dNOM * dS + d_fcy
%      
% b = (1 - r_fcy) * b{-1} / dNOM + d_lcy + r_fcy  * b{-1} / dNOM * dS + d_fcy
% 
% b = (1 - r_fcy) * b{-1} / dNOM + r_fcy  * b{-1} / dNOM * dS + d
% 
% b = (1 - r_fcy) * b / dNOM + r_fcy  * b / dNOM * dS + d
% 
% b - (1 - r_fcy) * b / dNOM - r_fcy  * b / dNOM * dS = d
% 
% b * (1 - (1 - r_fcy) / dNOM - r_fcy / dNOM * dS) = d

b     = 4*65;
r_fcy = 55/65;
dNOM  = 1.075^0.25 * 1.05^0.25;
dS    = 1.05^0.25 / 1.02^0.25;

d = b * (1 - (1 - r_fcy) / dNOM - r_fcy / dNOM * dS)

d + 5 % Grants