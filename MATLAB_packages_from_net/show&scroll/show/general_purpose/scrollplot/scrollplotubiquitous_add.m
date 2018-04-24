function scrollplotubiquitous_add(a,handles)
ubiquitous_list = getappdata(a, 'ScrollPlotUbiquitousList');
ubiquitous_list = unique([ubiquitous_list; handles(:)]);
setappdata(a, 'ScrollPlotUbiquitousList', ubiquitous_list);
