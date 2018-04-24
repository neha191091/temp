function scrollplot(a, dim, offset)
% Create several layers (n-dimensional hierarchy) in current axes object, scroll through the layers using mouse wheel, +/- keys and other predefined keys.
% Author: Vladimir Golkov
% Example:
% scrollplot_init(gca,{'mousewheeldown' 'mousewheelup';'+' '-'})	% initialize and define keys for scrolling along each dimension
% scatter(randn(1,100),randn(1,100))	% draw at layer [1] (later called [1 1])
% scrollplot(gca,1), scatter(randn(1,100),randn(1,100))	% go to next layer along 1st dimension, i.e. [2] (later called [2 1]), and draw at current layer
% scrollplot(gca,1), scatter(randn(1,100),randn(1,100))	% go to next layer along 1st dimension, i.e. [3] (later called [3 1]), and draw at current layer
% scrollplot(gca,2), scatter(randn(1,100),randn(1,100))	% go to next layer along 2nd dimension, starting at layer [1 2], and draw at current layer
% scrollplot(gca,1), scatter(randn(1,100),randn(1,100))	% go to next layer along 1st dimension, i.e. [2 2], and draw at current layer
% scrollplot(gca,1), scatter(randn(1,100),randn(1,100))	% go to next layer along 1st dimension, i.e. [3 2], and draw at current layer
% scrollplot(gca,[],[-1 -1])			% go back from layer [3 2] by [-1 -1] to layer [2 1]
% % now use mousewheeldown/mousewheelup/+/- to scroll through the layers

if nargin==0
	% all inputs missing
	a = gca;
end
nbdims = scrollplot_get_nbdims(a);

if nargin==0
	% all inputs missing
	offset = zeros(1,nbdims);
	offset(1) = +1;
elseif nargin==1
	if ishandle(a) && strcmp(get(a,'Type'),'axes')
		% offset missing: build default offset along 1st dimension
		offset = zeros(1,nbdims);
		offset(1) = +1;
	else
		% axes handle missing: use current axes and interpret the only argument as dim
		dim = a;
		a = gca;
	end
elseif nargin==2 || isempty(offset)
	% offset not given; first build a default offset from dim
	offset = zeros(1,nbdims);
	offset(1:dim-1) = -Inf;
	offset(dim) = +1;
elseif nargin==3
	% offset given, dim not required; calculate current and newcurrent
end

% calculate current and newcurrent from offset
current = getappdata(a, 'CurrentScrollPlot');
if isempty(current)
	current = ones(1,nbdims);
end
if numel(current)<numel(offset) % new dimensions have been added, expand CurrentScrollPlot vector
	current(end+1:numel(offset)) = 1;
end
newcurrent = max(current+offset,1);

current_cell = num2cell(coord2unambiguousarrayidx(current));
newcurrent_cell = num2cell(coord2unambiguousarrayidx(newcurrent));


hold on


% determine unassigned children
c = get(a,'children');
assigned = getappdata(a, 'ScrollPlotAssignedChildren');
try
% 	unassigned = setdiff_noC(c,assigned);
	unassigned = setdiff_sorted(sort(c),sort(assigned));
catch e
	unassigned = setdiff(c,assigned);
end	
% c=sort(c);
% assigned=sort(assigned);

% add unassigned children to current scrollplot
lists = getappdata(a, 'ScrollPlotChildrenLists');
lists_size = size(lists);
lists_size(end+1:numel(current)) = 1;
if any(coord2unambiguousarrayidx(current)>lists_size)
	lists{current_cell{:}} = unassigned(:);
else
	lists{current_cell{:}} = [lists{current_cell{:}}; unassigned];
end

setappdata(a, 'ScrollPlotAssignedChildren', c);
setappdata(a, 'ScrollPlotChildrenLists', lists);


% make current children visible
ubiquitous_list = getappdata(a, 'ScrollPlotUbiquitousList');

if all(coord2unambiguousarrayidx(newcurrent)<=lists_size)
	innewcurrent_boollist = ismember(c,lists{newcurrent_cell{:}});
	ubiquitous_boollist = ismember(c,ubiquitous_list);
	visible_boollist = innewcurrent_boollist | ubiquitous_boollist;
	set(c(visible_boollist),'visible','on')
	set(c(~visible_boollist),'visible','off')
end


setappdata(a, 'CurrentScrollPlot', newcurrent);

% call FirstSightFcn and remove its handle (it should be called only once)
fcncell = getappdata(a, 'ScrollPlotFirstSightFcn');
fcncell_size = size(fcncell);
fcncell_size(end+1:numel(newcurrent)) = 1;
if any(coord2unambiguousarrayidx(newcurrent)>fcncell_size)
	fcncell{newcurrent_cell{:}} = [];
else
	fhandle = fcncell{newcurrent_cell{:}};
	fhandle();
	fcncell{newcurrent_cell{:}} = [];
end
setappdata(a, 'ScrollPlotFirstSightFcn', fcncell);


% for child = c(:)'
% 	innewcurrent = all(coord2unambiguousarrayidx(newcurrent)<=lists_size) && any(child==lists{newcurrent_cell{:}});
% 	ubiquitous = any(child==ubiquitous_list);
% 	if innewcurrent || ubiquitous
% 		set(child,'visible','on')
% 	else
% 		set(child,'visible','off')
% 	end
% end



