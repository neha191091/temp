function show4d(data,clim,dist,complexmode,mode,tilemode_or_ncols,hRect,isreal_data,box)
% TODO rename this file and make an easy-to-use wrapper called show4d

if ndims(data)>4
	data=squeeze(data);
end



if ~exist('dist','var') || isempty(dist), dist=1; end
if ~exist('isreal_data','var') || isempty(isreal_data), isreal_data=isreal(data); end
if ~exist('complexmode','var') || isempty(complexmode)
	if isreal_data
		complexmode=0;
	else
		complexmode=1;
	end
end
if isreal_data || complexmode==0 % if simply taking absolute values of complex data
	if ~isreal_data
		data = abs(data);
	end
	if ~exist('clim','var') || isempty(clim)
		clim=[min(data(:)), max(data(:))];
	end
else
	if ~exist('clim','var') || isempty(clim)
		clim=[min(abs(data(:))), max(abs(data(:)))];
	end
end
if ~islogical(clim)
    clim(isinf(clim)) = realmax .* sign(clim(isinf(clim)));
end

% default tilemode
if ~exist('tilemode_or_ncols','var')
% 	if ndims(data)>3
		tilemode_or_ncols = '4d';
% 	else
% 		tilemode_or_ncols = '3d';
% 	end
end

% tile
if strcmpi(tilemode_or_ncols,'3d')
	tile = tile3ddata(data,dist); % TODO move box to 3rd argument and include here
elseif isnumeric(tilemode_or_ncols)
	tile = tile3ddata(data,dist,tilemode_or_ncols,box);
else
	tile = tile4ddata(data,dist,box);
end

% save to image file with original resolution
% imwrite(linsc(tile,[1 256]),gray(256),'h:\output.png')
% for i=[1 2 3 4 5 6 7 8 9 10];imwrite(min(linsc(drep,[0 i],[1 64]),64),jet,['0' num2str(i) '_ASSET.png']),end

siz = size(data);
siz(end+1:4) = 1;

tag = showNd_currentimgtag();

if complexmode==0
	if clim(1)~=clim(2) && ~strcmp(clim,'current') % clim='current' means do not change current clim; useful for lazy mode
		imagesc(tile,'Tag',tag,clim);
	else
		imagesc(tile,'Tag',tag);
	end
else
	image(complex2rgb(tile,complexmode,clim),'Tag',tag); % don't pass clim if same scale for different slices is not important
end

if ~exist('mode','var') || ~strcmp(mode,'nocoords')
	axis equal off

	% set(gca,'Unit','normalized','Position',[0 0 1 1])
	cbscroll

	hText = text(1,.5,'move cursor','Units','normalized');
	hRect = rectangle('Position',[0 0 1 1],'Visible','off','EdgeColor','w');
	
% 	addEventFcn(gcf,'WindowButtonMotionFcn',@(hFig,evnt)show4dMouseMotion(hFig,evnt,hText,hRect,size(data),dist))
	addEventFcn(gcf,'WindowButtonMotionFcn',@(hFig,evnt)showNdMouseMotion(hFig,evnt,hText,hRect,siz,dist,complexmode,tilemode_or_ncols))
elseif exist('hRect','var') && ~isempty(hRect)
	uistack(hRect,'top')
end




% function show4dMouseMotion(hFig,evnt,hText,hRect,dims,dist)
% cp = get(gca,'CurrentPoint');
% coords = show4d_to_coords(cp(1,1),cp(1,2),dims,dist);
% str = sprintf('%i\n%i\n%i\n%i',coords(1),coords(2),coords(3),coords(4));
% if any(isnan(coords))
% 	str = '';
% 	set(hRect,'Visible','off')
% else
% 	set(hRect,'Visible','on','Position',[floor(cp(1,1:2)+.5)-.5 1 1])
% end
% set(hText,'String',str)

