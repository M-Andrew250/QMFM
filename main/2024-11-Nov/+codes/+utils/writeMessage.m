function writeMessage(msg, varargin)
% codes.utils.writeMessage write a formatted message to the command window.
%
% Usage: writeMessage(msg, varargin).

fprintf(msg + "\n", varargin{:});

end