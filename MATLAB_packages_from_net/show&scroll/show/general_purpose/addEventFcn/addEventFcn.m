function addEventFcn(hFigs, PropertyName, newFun, areDuplicatesOK)
% Author: Vladimir Golkov
for hFig = hFigs(:)'
	oldFun = get(hFig, PropertyName);
	if isempty(oldFun)
		set(hFig, PropertyName, newFun)
	else
		if ~containsEventFcn(hFig, PropertyName, newFun) || (exist('areDuplicatesOK','var') && areDuplicatesOK) % only if not already added, or if multiple instances are ok
			set(hFig, PropertyName, {@EventFcnMultiCaller, oldFun, newFun})
		end
	end
end

