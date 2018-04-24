function c = coord2unambiguousarrayidx(c)
% The problem is that saying newvar(2)=10 creates a 1x2 array, and not a 2x1 array
% Therefore we need instead to say explicitly newvar(2,1)=10.
% This function does this replacement for the coordinate vector c, so that later we can say:
% c_cell=num2cell(c), newvar(c_cell{:})=value.
if numel(c)==1
	c(2) = 1;
end

