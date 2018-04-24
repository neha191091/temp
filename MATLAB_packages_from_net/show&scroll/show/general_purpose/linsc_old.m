function [A m t] = linsc(A, from, to)
% Scales data linearly. Examples:
%    linsc(data, [0 1], [0 100]) % scale from [0 1] to [0 100] (equivalent to data*100)
%    linsc(data, [0 1], [-1 1]) % scale from [0 1] to [-1 1]
%    linsc(data, [-1 1]) % scale from [min(data(:)) max(data(:))] to [-1 1]
%    linsc(data) % scale from [min(data(:)) max(data(:))] to [0 1]

if ~exist('from','var') || isempty(from)
	from = [min(A(:)) max(A(:))];
end

if nargin==2
	to = from;
	from = [min(A(:)) max(A(:))];
end

if ~exist('to','var') || isempty(to)
	to = [0 1];
end

if ~(numel(from)==2 && numel(to)==2)
	error('Erroneous limits.')
end

% [x1 x2] := from
% [y1 y2] := to

% m = (to(2)-to(1))/(from(2)-from(1));
m = to(2)/(from(2)-from(1))-to(1)/(from(2)-from(1)); % this is better when we are close to realmax
t = to(1) - m*from(1);

A = m.*A + t;