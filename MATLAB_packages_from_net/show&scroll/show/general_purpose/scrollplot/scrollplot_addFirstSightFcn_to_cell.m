function fcncell = scrollplot_addFirstSightFcn_to_cell(fcncell, fhandle, current)

% if ~exist('current','var') || isempty(current)
% 	current = getappdata(a, 'CurrentScrollPlot');
% 	if isempty(current)
% 		nbdims = scrollplot_get_nbdims(a);
% 		current = ones(1,nbdims);
% 	end
% end

current_cell = num2cell(coord2unambiguousarrayidx(current));

fcncell{current_cell{:}} = fhandle;
