function removed = removeEventFcn(hFigs, PropertyName, funstring)
% Author: Vladimir Golkov
for i = 1:numel(hFigs)
	hFig = hFigs(i);
	[newproperty removed(i)] = removeEventFcnFromProperty(get(hFig, PropertyName), funstring);
	set(hFig, PropertyName, newproperty);
end


function [property removed] = removeEventFcnFromProperty(property, funstring)
removed = 0;
if isa(property,'function_handle')
	if strcmp(funstring, func2str(property))
		property = '';
		removed = 1;
	end
elseif iscell(property)
	[property3 removed3] = removeEventFcnFromProperty(property{3}, funstring);
	[property2 removed2] = removeEventFcnFromProperty(property{2}, funstring);
	property{3} = property3;
	property{2} = property2;
	removed = removed3 + removed2;
	if isempty(property3)
		property = property2;
	end
	if isempty(property2)
		property = property3;
	end
end
