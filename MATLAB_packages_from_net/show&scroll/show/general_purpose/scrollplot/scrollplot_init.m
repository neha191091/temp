function varargout = scrollplot_init(a,keys)
% Author: Vladimir Golkov
if nargin==0
	a = gca;
end
if nargin<2 || isempty(keys)
	keys = {...
		{'mousewheeldown' 'mousewheelup'}; % TODO this way around?
		{'+' '-'};
		{'q' 'a'};
		{'w' 's'};
		{'e' 'd'};
		{'r' 'f'};
		{'t' 'g'};
		{'y' 'h'};
		{'u' 'j'};
		{'i' 'k'};
		{'o' 'l'};
		};
end
if nargout>0
	varargout{1} = keys;
end
setappdata(a, 'CurrentScrollPlot', [])
setappdata(a, 'ScrollPlotAssignedChildren', [])
setappdata(a, 'ScrollPlotChildrenLists', [])
setappdata(a, 'ScrollPlotFirstSightFcn', [])
setappdata(a, 'ScrollPlotUbiquitousList', [])
setappdata(a, 'ScrollPlotKeys', keys)
setappdata(a, 'ScrollPlotNumTypewriterDim', 1) % TODO are these defaults OK?
setappdata(a, 'ScrollPlotNumPadDim', 2) % TODO are these defaults OK?
cla(a)


keys = getappdata(a, 'ScrollPlotKeys');

hFig = get(a, 'Parent');

setappdata(hFig, 'isAltKeyDown', false);
setappdata(hFig, 'isControlKeyDown', false);
setappdata(hFig, 'isShiftKeyDown', false);

areDuplicatesOK = false;
addEventFcn(hFig,'KeyPressFcn',@ModifierKeyPressFcn)
addEventFcn(hFig,'KeyPressFcn',@(hFig,evnt)spKeyPressFcn(hFig,evnt,a,keys),areDuplicatesOK)
addEventFcn(hFig,'KeyReleaseFcn',@ModifierKeyReleaseFcn)
addEventFcn(hFig,'WindowScrollWheelFcn',@(hFig,evnt)spScroll(hFig,evnt,a,keys),areDuplicatesOK)



function spScroll(hFig,evnt,a,keys)
if ~getappdata(hFig, 'isAltKeyDown') && ~getappdata(hFig, 'isShiftKeyDown') && ~getappdata(hFig, 'isControlKeyDown')
	switch sign(evnt.VerticalScrollCount)
		case -1
			key_alias = 'mousewheelup';
		case +1
			key_alias = 'mousewheeldown';
		case 0
			key_alias = '';
	end
	keyEvent.Character = key_alias;
	keyEvent.Key = key_alias;
	spKeyPressFcn(hFig, keyEvent, a, keys)
end


function spKeyPressFcn(hFig, keyEvent, a, keys)
a = fixaxeshandle(a);
if a~=gca
	return
end
nbdims = scrollplot_get_nbdims(a);
offset = zeros(1,nbdims);

num = str2num(keyEvent.Character);
if ~isempty(num)
	% a number key was pressed - jump to according slice
	if length(keyEvent.Key) > 1
		% numeric keypad
		dim = getappdata(a, 'ScrollPlotNumPadDim');
	else
		% character keys / typewriter keys - above the letters
		dim = getappdata(a, 'ScrollPlotNumTypewriterDim');
	end
	
	current = getappdata(a, 'CurrentScrollPlot');
	if dim==2 && numel(current)==1
		dim = 1; % use numpad for 1st scrollable dimension in case 2nd doesn't exist (i.e. all above 1st are singleton)
	end
	if dim<=numel(current)
		spsize = size(getappdata(a, 'ScrollPlotChildrenLists'));
		if num==0
			% jump to last slice
			offset(dim) = spsize(dim) - current(dim);
		else
			% jump to specified slice
			offset(dim) = num - current(dim);
		end

		newcoord = getappdata(a, 'CurrentScrollPlot')+offset;
		if all(coord2unambiguousarrayidx(newcoord) <= spsize)
			scrollplot(a, [], offset);
		end
	end
else
	% [dim offset_idx] = find(strcmp(key_alias, keys)); % for the format keys={'mousewheeldown' 'mousewheelup'; '+' '-'; 'q' 'a'; 'w' 's'; 'e' 'd'; 'r' 'f'; 't' 'g'; 'y' 'h'; 'u' 'j'; 'i' 'k'; 'o' 'l';};

	match_bool = cellfun(@(x)(strcmp(keyEvent.Character, x) | strcmp(keyEvent.Key, x)),keys,'UniformOutput',false);
	match_idx = cellfun(@find,match_bool,'UniformOutput',false);
	dim_unique = find(~cellfun(@isempty,match_idx)); % does not count double matches
	dim=[]; for i=1:numel(dim_unique), dim = [dim repmat(dim_unique(i), [1 numel(match_idx{dim_unique(i)})])]; end
	offset_idx = cell2mat(match_idx');

	if ~isempty(dim) % if a matching key definition was found
		for i=1:numel(dim) % for every match
			switch offset_idx(i)
				case 1
					o = +1;
				case 2
					o = -1;
			end
			if dim(i)<=nbdims
				offset(dim(i)) = o;
			end
		end

		newcoord = getappdata(a, 'CurrentScrollPlot')+offset;
		if all(coord2unambiguousarrayidx(newcoord) <= size(getappdata(a, 'ScrollPlotChildrenLists')))
			scrollplot(a, [], offset);
		end
	end
end


function ModifierKeyPressFcn(hFig, keyEvent)
switch (keyEvent.Key)
	case 'alt'
		setappdata(hFig, 'isAltKeyDown', true);
	case 'control'
		setappdata(hFig, 'isControlKeyDown', true);
	case 'shift'
		setappdata(hFig, 'isShiftKeyDown', true);
end


function ModifierKeyReleaseFcn(hFig, keyEvent)
switch (keyEvent.Key)
	case 'alt'
		setappdata(hFig, 'isAltKeyDown', false);
	case 'control'
		setappdata(hFig, 'isControlKeyDown', false);
	case 'shift'
		setappdata(hFig, 'isShiftKeyDown', false);
end


function a = fixaxeshandle(a)
% if ~ishandle(a)
	a = gca;
% end
