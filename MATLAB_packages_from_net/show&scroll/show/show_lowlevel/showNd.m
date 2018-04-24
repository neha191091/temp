function varargout = showNd(data,varargin)
% Author: Vladimir Golkov

ax = gca;
fig = gcf;

siz = size(data);

lazy_varargin = strcmp('lazy',varargin);
lazy = any(lazy_varargin);
varargin(lazy_varargin) = [];

triD_varargin = strcmpi('3d',varargin); if any(triD_varargin), tilemode_or_ncols = '3d'; end, varargin(triD_varargin) = [];
twoD_varargin = strcmpi('2d',varargin); if any(twoD_varargin), tilemode_or_ncols = '2d'; end, varargin(twoD_varargin) = [];

box = false;
box_varargin = strcmpi('box',varargin); if any(box_varargin), box = true; end, varargin(box_varargin) = [];

% TODO http://stackoverflow.com/questions/8481324/contrasting-color-for-nans-in-imagesc
[annotations, scrollplot_init_keys, clim, dist, ncols, complexmode, mmfun] = showNd_parsevarargin(data, varargin{:});
% clim(isinf(clim)) = sign(clim(isinf(clim))) .* 1e30; % prevent Inf in data range
clim_firstsight = clim;
if isempty(complexmode) || complexmode==0
    clim_firstsight = 'current';
end
if ~isempty(ncols)
	ncols = min(ncols,siz(3)); % TODO 3 or 4?
	tilemode_or_ncols = ncols;
end

% default tilemode
if ~exist('tilemode_or_ncols','var')
	if ndims(data)>3
		tilemode_or_ncols = '4d';
	else
		tilemode_or_ncols = '3d';
	end
end

% set firstscrolldim
switch tilemode_or_ncols 
	case '4d'
		firstscrolldim = 5;
	case '2d'
		firstscrolldim = 3;
	otherwise
		firstscrolldim = 4;
end

% default to lazy mode if too many slices (along 5th and further dimensions)
nsl = prod(siz(firstscrolldim:end));
if nsl >= 3000
	if strcmp('No',questdlg(sprintf('Number of scroll layers: %d. Visualization might be slow. Continue anyways?',nsl),'show/scroll','Yes','No','No'))
		varargout = {-1};
		return
	end
end
if nsl > 25 && ~lazy
    warning('Number of scroll layers: %d. Using lazy rendering.',nsl);
    lazy = true;
end

% initialize scrollplot
scrollplot_init_keys = scrollplot_init(ax,scrollplot_init_keys);
fcncell = {};

coordlists={};
for d=firstscrolldim:ndims(data)
	coordlists{d-(firstscrolldim-1)} = 1:size(data,d);
end
if isempty(coordlists)
	coordlists = {1};
end
b = cell(1,numel(coordlists));
[b{:}] = ndgrid(coordlists{:}); % http://www.mathworks.com/matlabcentral/answers/5827
% problem: [X1,X2,...] = ndgrid(x) is the same as [X1,X2,...] = ndgrid(x,x,...)
% solution:
if numel(coordlists)==1
	b = coordlists;
end
for i=1:numel(b{1}) % for each coordinate in dimensions 5 to N...
	for c=1:numel(b)
		coordvec(c) = b{c}(i);
	end
	coordvec_cell = num2cell(coordvec);
	try
		mode = 'nocoords'; % don't display mouse-hover coordinates in every show4d slice since we do it here using one "scrollplot-ubiquitous" text object (hText)
		if lazy && i~=1 % hold on can be problematic in case we haven't drawn anything yet, so call show4d if i==1 even in lazy mode
			switch tilemode_or_ncols
				case '4d'
					fcncell = scrollplot_addFirstSightFcn_to_cell(fcncell,@()show4d(data(:,:,:,:,coordvec_cell{:}),clim_firstsight,dist,complexmode,mode,tilemode_or_ncols,[],isreal(data),box),coordvec);
				case '2d'
					fcncell = scrollplot_addFirstSightFcn_to_cell(fcncell,@()show4d(data(:,:,coordvec_cell{:}),clim_firstsight,dist,complexmode,mode,tilemode_or_ncols,[],isreal(data),box),coordvec);
				otherwise
					fcncell = scrollplot_addFirstSightFcn_to_cell(fcncell,@()show4d(data(:,:,:,coordvec_cell{:}),clim_firstsight,dist,complexmode,mode,tilemode_or_ncols,[],isreal(data),box),coordvec);
			end
% 	 		fcncell = scrollplot_addFirstSightFcn_to_cell(fcncell,@()lazymode_show4d_caller(ax,coordvec_cell,clim,dist,complexmode,mode),coordvec);
		else
			switch tilemode_or_ncols
				case '4d'
					show4d(data(:,:,:,:,coordvec_cell{:}),clim,dist,complexmode,mode,tilemode_or_ncols,[],isreal(data),box) % we have to pass isreal(data) because it can happen that data is complex while the passed portion data(:,:,:,:,coordvec_cell{:}) is real
				case '2d'
					show4d(data(:,:,coordvec_cell{:}),clim,dist,complexmode,mode,tilemode_or_ncols,[],isreal(data),box)
				otherwise
					show4d(data(:,:,:,coordvec_cell{:}),clim,dist,complexmode,mode,tilemode_or_ncols,[],isreal(data),box)
			end
		end
		if i==1
			hold on % scrollplot_fast does not do this
		end
		% imagesc(reshape(permute(abs(qspace1(:,:,:,:,6)),[1 4 2 3]),128*11,128*11))
		annotation = '';
		if ~isempty(annotations)
			coordvec_cell_annotation = coordvec_cell;
			for ai=1:numel(coordvec_cell_annotation)
				if size(annotations,ai)==1
					coordvec_cell_annotation{ai} = 1;
					warning('Singleton-dimension expansion of annotation cellarray.')
				end
			end
			annotation = annotations{coordvec_cell_annotation{:}};
		end
		if numel(siz)>(firstscrolldim-1)
			slicecoordstr = 'Displayed slice:\newline';
			for c=1:numel(b)
				% TODO move this functionality to scrollplot?
				if (strcmpi(scrollplot_init_keys{c}{1},'mousewheeldown') && strcmpi(scrollplot_init_keys{c}{2},'mousewheelup'))
					slicecoordstr = [slicecoordstr sprintf('%i{\\fontsize{6} / %i}   [mousewheel]',coordvec(c),siz(c+(firstscrolldim-1)))];
				else
					slicecoordstr = [slicecoordstr sprintf('%i{\\fontsize{6} / %i}   [%s;%s]',coordvec(c),siz(c+(firstscrolldim-1)),scrollplot_init_keys{c}{1},scrollplot_init_keys{c}{2})];
				end
				if c==1, slicecoordstr = [slicecoordstr '{\bf 0-9}']; end;
				if c==2, slicecoordstr = [slicecoordstr '{\bf num0-9}']; end
				if iscell(annotation)
					slicecoordstr = [slicecoordstr annotation{c}];
				end
				slicecoordstr = [slicecoordstr sprintf('\n')];
			end
			slicecoordstr = slicecoordstr(1:end-1);
		else
			slicecoordstr = '';
		end
		if ischar(annotation)
			slicecoordstr = [slicecoordstr '\newline' annotation];
		end
		clickhide(text(1,0,slicecoordstr,'Units','normalized'))
	catch e
		warning(e.getReport)
	end
	% scrollplot along first unfull dimension
	bump = coordvec==siz(firstscrolldim:end);
	unfull_dims = find(~bump);
	if ~isempty(unfull_dims)
		scrollplot_fast(ax,unfull_dims(1))
	end
end
setappdata(ax, 'ScrollPlotFirstSightFcn', fcncell); % do this before first call to scrollplot, so that scrollplot calls the needed FirstSightFcn
scrollplot(ax,[],-floor(siz(firstscrolldim:end)/2))
axis equal off


% set(ax,'Unit','normalized','Position',[0 0 1 1])
cbscroll


hText = text(1,.5,'Move cursor to explore values.\newlineClick on any text to hide it.\newlineAlso try:\newlineShift + Mousewheel\newlineCtrl + Mousewheel\newlineCtrl + Shift + Mousewheel\newlineAlt + Mousewheel','Units','normalized','Tag','showNd_text_right');
hRect = rectangle('Position',[0 0 1 1],'Visible','off','EdgeColor','w','Tag','showNd_rectangle');
% for i=1:siz(3)
% 	for j=1:siz(4)
% 		hRect(i,j) = rectangle('Position',[0 0 1 1],'Visible','off','EdgeColor','w','Tag','showNd_rectangle');
% 	end
% end
scrollplotubiquitous_add(ax,hText);
scrollplotubiquitous_add(ax,hRect);

siz = size(data);
siz(end+1:(firstscrolldim-1)) = 1; % trailing singleton dimensions
siz(firstscrolldim:end) = []; % too many dimensions

setappdata(ax,'showNd_slicedims',siz)

areDuplicatesOK = false;
addEventFcn(fig,'WindowButtonMotionFcn',@(hFig,evnt)showNdMouseMotion(hFig,evnt,hText,hRect,siz,dist,complexmode,tilemode_or_ncols,mmfun),areDuplicatesOK)

% additionally: update data cursor value for the case of scrollplot scrolling
addEventFcn(fig,'KeyPressFcn',@(hFig,evnt)showNdMouseMotion(hFig,evnt,hText,hRect,siz,dist,complexmode,tilemode_or_ncols,mmfun),areDuplicatesOK)
addEventFcn(fig,'WindowScrollWheelFcn',@(hFig,evnt)showNdMouseMotion(hFig,evnt,hText,hRect,siz,dist,complexmode,tilemode_or_ncols,mmfun),areDuplicatesOK)

% TODO:
% if data-values-show mode (useful for complex data!) then
% addEventFcn(fig,'WindowButtonMotionFcn',@(hFig,evnt)showNdMouseMotion(hFig,evnt,hText,hRect,siz,dist,complexmode,tilemode_or_ncols,mmfun,data))

if nargout>0
	varargout{1} = complexmode;
end




function string = number2string_mapping(n,numbers_array,strings_cellarray,otherwise_string)
idx = find(numbers_array==n);
if ~isempty(idx)
	string = strings_cellarray{idx(1)};
else
	string = otherwise_string;
end


% function lazymode_setdata(ax, data)
% setappdata(ax, 'showNd_lazymode_data',data);
% 
% function slice = lazymode_getslice(ax, coordvec_cell)
% data = getappdata(ax, 'showNd_lazymode_data');
% slice = data(:,:,:,:,coordvec_cell{:});
% 
% function lazymode_show4d_caller(ax,coordvec_cell,clim,dist,complexmode,mode)
% show4d(lazymode_getslice(ax, coordvec_cell),clim,dist,complexmode,mode);
