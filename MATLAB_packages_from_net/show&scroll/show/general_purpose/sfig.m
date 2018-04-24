function sfig(varargin)
% Switch between figures with arrow keys.
% Author: Vladimir Golkov
%
% Examples:
%
%	sfig				% start making switchable figures
%	figure
%	figure
%	sfig off			% stop making switchable figures
%	figure
%	
%	sfig all			% make all existing figures switchable
%
%	sfig(5,7)			% make figures 5 and 7 switchable
%
%	sfig(1:10,15,'nowraparound')
%						% make figures 1-10 and 15 switchable, w/o wraparound (without going from 15 to 1)
%
%	sfig all off
%
%
%
%
%	sfig dockedonly		% limit functionality to figures docked to the Figures window
%
%	sfig nonexclusive	% allow to switch to figures that don't have this functionality
%

off = false;
wrap_around = true;
docked_only = false;
exclusive = true;
list = [];

for i = 1:numel(varargin)
	if ischar(varargin{i})
		switch varargin{i}
			case 'off'
				off = true;
			case 'nowraparound'
				wrap_around = false;
			case 'dockedonly'
				docked_only = true;
			case 'nonexclusive'
				exclusive = false;
			case 'all'
				list = [list(:); findall(0,'Type','Figure')];
			case 'on'
				off = false;
		end
	else
		list = [list(:); varargin{i}];
	end
end

fhandle = @(obj,evt)switchkeypress(evt, wrap_around, docked_only, exclusive);
if off
% 	popEventFcn(0,'DefaultFigureKeyPressFcn');
% 	popEventFcn(list,'KeyPressFcn');
	% TODO deep remove, not just pop
	removeEventFcn(0,'DefaultFigureKeyPressFcn',func2str(fhandle));
	removeEventFcn(list,'KeyPressFcn',func2str(fhandle));
else
	addEventFcn(0,'DefaultFigureKeyPressFcn',fhandle)
	addEventFcn(list,'KeyPressFcn',fhandle)
end



function switchkeypress(evt, wrap_around, docked_only, exclusive)
list = findall(0,'Type','Figure');
if isempty(list)
	return
end
try
	listmin = min(list);
	listmax = max(list);
catch % hg2
	tmp = cell(numel(list),1);
	[tmp{:}] = list.Number;
	listmin = min(cell2mat(tmp));
	listmax = max(cell2mat(tmp));
end
switch evt.Key
	case 'uparrow'
		offset = -1;
	case 'downarrow'
		offset = +1;
	case 'leftarrow'
		offset = -1;
	case 'rightarrow'
		offset = +1;
	otherwise
		return
end
idx = gcf;
try
	idx = idx.Number;
end
accepted_idx = idx;
if exclusive
	fhandle = @(obj,evt)switchkeypress(evt, wrap_around, docked_only, exclusive);
	fcnstr = func2str(fhandle);
end
while wrap_around || idx+offset>=listmin && idx+offset<=listmax
	idx = idx+offset;
	if wrap_around
		if idx<listmin
			idx = listmax;
		elseif idx>listmax
			idx = listmin;
		end
	end
	if ~ishandle(idx)
		continue
	end
	if (~docked_only || strcmp(get(idx,'windowstyle'),'docked')) && (~exclusive || containsEventFcn(idx, 'KeyPressFcn', fcnstr))
		accepted_idx = idx;
		break
	end
end
figure(accepted_idx)

