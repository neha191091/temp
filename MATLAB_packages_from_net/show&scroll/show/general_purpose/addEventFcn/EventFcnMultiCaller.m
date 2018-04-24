function EventFcnMultiCaller(obj, event, oldFun, newFun)
% Author: Vladimir Golkov
if isa(oldFun,'function_handle')
	oldFun(obj, event);
end
if iscell(oldFun)
	% recursively call all added functions
	EventFcnMultiCaller(obj, event, oldFun{2:end})
end
newFun(obj, event);

