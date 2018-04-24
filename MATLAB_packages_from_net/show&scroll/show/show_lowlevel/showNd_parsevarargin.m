function [annotations, scrollplot_init_keys, clim, dist, ncols, complexmode, mmfun] = showNd_parsevarargin(data, varargin)


% default/empty arguments
annotations = {}; % optional cell array of annotation strings for each 4-D "slice"
scrollplot_init_keys = {}; % optional cell array of keys for scrollplot_init
clim = [];
dist = [];
ncols = [];
complexmode = [];
mmfun = [];

% parse varargin
for i=1:numel(varargin)
	if iscell(varargin{i}) % annotations or scrollplot_init_keys
		if isempty(annotations) % annotations
			annotations = varargin{i};
		else
			if isempty(scrollplot_init_keys) % scrollplot_init_keys
				scrollplot_init_keys = varargin{i};
			end
		end
	end
	if isnumeric(varargin{i})
		if numel(varargin{i})==2 % clim
			clim = varargin{i};
		end
		if numel(varargin{i})==1 % complexmode or dist
			if isempty(complexmode) % complexmode
				complexmode = varargin{i};
			else
				if isempty(dist) % dist
					dist = varargin{i};
				else
					if isempty(ncols) % ncols
						ncols = varargin{i};
					end
				end
			end
		end
	end
	if isa(varargin{i},'function_handle') % mouse motion function handle
		mmfun = varargin{i};
	end
end

% default arguments
if ~isreal(data)
	if isempty(complexmode), complexmode=1; end
end
if isempty(clim), clim=min_max(data(~isinf(data))); end

