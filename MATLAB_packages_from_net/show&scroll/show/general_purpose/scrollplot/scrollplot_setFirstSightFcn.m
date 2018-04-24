function scrollplot_setFirstSightFcn(a, fhandle, current)
% slower than scrollplot_addFirstSightFcn_to_cell due to setappdata

if ~exist('current','var') || isempty(current)
	current = getappdata(a, 'CurrentScrollPlot');
	if isempty(current)
		nbdims = scrollplot_get_nbdims(a);
		current = ones(1,nbdims);
	end
end

fcncell = getappdata(a, 'ScrollPlotFirstSightFcn');

current_cell = num2cell(coord2unambiguousarrayidx(current));

fcncell{current_cell{:}} = fhandle;

setappdata(a, 'ScrollPlotFirstSightFcn', fcncell);
