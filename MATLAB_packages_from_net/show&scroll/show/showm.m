function showm(data,varargin)
% show magnitude if data is complex
% if ~isreal(data)
%     show(abs(data),varargin{:});
% else
%     show(data,varargin{:});
% end
show(data,0,varargin{:})
