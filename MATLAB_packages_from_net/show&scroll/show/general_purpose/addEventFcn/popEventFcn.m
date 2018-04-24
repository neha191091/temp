function popEventFcn(hFigs, PropertyName)
% remove latest event function added by addEventFcn
% Author: Vladimir Golkov
for hFig = hFigs(:)'
	oldFun = get(hFig, PropertyName);
	if iscell(oldFun) && strcmp(func2str(oldFun{1}),func2str(@EventFcnMultiCaller))
		% if not last: recover previous
		set(hFig, PropertyName, oldFun{2})
	else
		% if last: set to empty
		set(hFig, PropertyName, '')
	end
end

