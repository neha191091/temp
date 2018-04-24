function data = dimfun(fun, data, dims)
% Apply function along several dimensions. Example:
% dimfun(@sum, data, [1 3 4]) % sum along dimensions 1 3 4
%
% NB:
% For flipdim, fftshift, ifftshift etc., their variants flipdims, fftshift_dims, ifftshift_dims are faster than dimfun!
% For min and max, use @(x,dims)min(x,[],dims) which is probably what you want.

for i=1:numel(dims)
	data = fun(data, dims(i));
end
