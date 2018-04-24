function nbdims = scrollplot_get_nbdims(a)
current = getappdata(a, 'CurrentScrollPlot');
nbdims = max(numel(current),1);
% lists = getappdata(a, 'ScrollPlotChildrenLists');
% nbdims = ndims(lists);
% if nbdims==2 && size(lists,2)<2
% 	nbdims = 1;
% end