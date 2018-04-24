function answer = containsEventFcn(hFigs, PropertyName, funHandle)
% Author: Vladimir Golkov
for i = 1:numel(hFigs)
	hFig = hFigs(i);
	oldFun = get(hFig, PropertyName);
	answer(i) = propertyContainsEventFcn(oldFun, funHandle);
end


function answer = propertyContainsEventFcn(property, funHandle)
if isa(property,'function_handle')
	if isa(funHandle,'function_handle')
		a = functions(funHandle);
		b = functions(property);
		answer = isequal(a.function, b.function);
	else
		answer = strcmp(funHandle, func2str(property));
	end
elseif iscell(property) && numel(property)==3 % FIXME check whether this is EventFcnMultiCaller and not the image zoom mode or so
	answer = propertyContainsEventFcn(property{3}, funHandle) || propertyContainsEventFcn(property{2}, funHandle);
else
	answer = 0;
end
