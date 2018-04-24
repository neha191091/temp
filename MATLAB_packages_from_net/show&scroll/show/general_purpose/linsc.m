function [A, m, t] = linsc(A, from, to, dims)
% Scale data linearly. Optionally only along specified dimensions.
% Author: Vladimir Golkov
% Examples:
%    linsc(data, [0 1], [0 100]) % scale from [0 1] to [0 100] (equivalent to data*100)
%    linsc(data, [0 1], [-1 1]) % scale from [0 1] to [-1 1]
%    linsc(data, [-1 1]) % scale from [min(data(:)) max(data(:))] to [-1 1]
%    linsc(data) % scale from [min(data(:)) max(data(:))] to [0 1]

if ~exist('dims','var') || isempty(dims)
	dims = 1:ndims(A);
end

if ~exist('from','var') || isempty(from)
	from = {dimfun(@(x,dims)min(x,[],dims),A,dims), dimfun(@(x,dims)max(x,[],dims),A,dims)};
end
if ~iscell(from)
	from = num2cell(from);
end

if nargin==2
	to = from;
	from = {dimfun(@(x,dims)min(x,[],dims),A,dims), dimfun(@(x,dims)max(x,[],dims),A,dims)};
end

if ~exist('to','var') || isempty(to)
	to = {0, 1};
end
if ~iscell(to)
	to = num2cell(to);
end

if ~(numel(from)==2 && numel(to)==2)
	error('Erroneous limits.')
end

% [x1 x2] := from
% [y1 y2] := to

% m = (to(2)-to(1))/(from(2)-from(1));
m = to{2}./(from{2}-from{1})-to{1}./(from{2}-from{1}); % this is better when we are close to realmax
t = to{1} - m.*from{1};

% apply m,t to A
A = linsc_mt(A, m, t);
