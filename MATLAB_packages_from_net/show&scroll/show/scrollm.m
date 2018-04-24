function scrollm(data,varargin)
% show magnitude if data is complex
% if ~isreal(data)
%     scroll(abs(data),varargin{:});
% else
%     scroll(data,varargin{:});
% end
scroll(data,0,varargin{:})
