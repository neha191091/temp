function show(data,varargin)
% show & scroll: Visualize N-dimensional arrays. Works for any multi-dimensional and complex-valued arrays.
%
% Examples:
%    show(flow) % visualize 3D array
%    scroll(flow) % another way to visualize 3D array
%    show(randn(5,5,5,5,5,5,5)) % visualize 7D array; use mousewheel, +/-, q/a buttons for higher dimensions
%    show(randn(4,4,4,4,2,2),{'A','B'; 'C','D'}) % annotate displayed slices.
%    show(q_mean_nrm,@(coords)hl(get(figure(100),'Children'),squeeze(q(coords(1),coords(2),coords(3),:)))) % show histograms along 4th dimension of q when moving mouse over q_mean_nrm
%    scroll(q_mean_nrm,@(coords)floating_hl(coords,q_nrm))
%    show(flow,'clf') % visualize 3D array, clearing and replacing the contents of the current figure rather than opening a new figure
% 
% Complex data:
%    show(data) % show complex-valued data
%    showm(data) % show magnitude of complex-valued data
%    show(data,2)
%
% Author: Vladimir Golkov

if isempty(getappdata(0,'showNd_preinit'))
	setappdata(0,'showNd_preinit','done')
	addpath(genpath(fileparts(mfilename('fullpath'))))
end

if nargin==0
	showNd_init
	return
end

% if cell passed: transform it to array
if iscell(data)
	data = xcat([],data{:});
end
% TODO also treat cells with numeric contents in non-first arguments

% concatenate several arguments
% (order of commands: first xcat, then permute, then squeeze, only then elementary function showNd which should not squeeze)
I_xcat = cellfun(@(x) ndims(x)>=2 && ~isvector(x) && isnumeric(x), varargin);
data = xcat([],data,varargin{I_xcat});
varargin(I_xcat) = [];

% permute
I_order = cellfun(@(x) isnumeric(x) && isvector(x) && numel(x)>=ndims(data) && numel(x)>2, varargin);
i_order = find(I_order,1,'first');
if ~isempty(i_order)
	order = varargin{i_order};
	varargin(i_order) = [];
	data = permute(data,order);
end

% squeeze
data = squeeze(data);

clf_idx = cellfun(@(x)ischar(x)&strcmpi(x,'clf'),varargin);
if any(clf_idx)
	% don't open new figure if 'clf' argument was passed
	hFig = gcf;
	clf(hFig,'reset') % clear existing figure
	varargin(clf_idx) = [];
else
	% open and maximize figure
	hFig=figure;
	% hFig=figure('Position', get(0,'Screensize'));
	maxfigwin(hFig);
end


% show data
complexmode = showNd(data,varargin{:});


% display array size
siz = size(data);
titl = ['Array dimensions: ' num2str(siz(1))];
for i=2:numel(siz)
	titl = [titl '\times' num2str(siz(i))];
end
clickhide(title(titl))

if isempty(complexmode) || complexmode==0 || complexmode==2
	colorbar('WestOutside')
% 	drawnow
% 	uistack(hColorbar,'bottom')
end

% if complexmode
% 	ax1=axes('Position', [.15, .35, .2, .25]);
% 	show4d(exp(1i*linspace(0,2*pi,100))'*[1:100])
% end

showNd_init % TODO here?


