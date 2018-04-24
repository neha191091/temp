function result = xcat(dim,varargin)
% Array concatenation with singleton expansion.
% Author: Vladimir Golkov

if ~isscalar(dim) && ~isempty(dim)
	% dim not provided, first argument is array
	varargin(2:end+1) = varargin; % TODO is this fast?
	varargin{1} = dim;
end
sizelist = [];
for i=1:numel(varargin)
	siz = size(varargin{i});
	sizelist(:,end+1 : numel(siz)) = 1; % in case ndims(varargin{i}) is larger than largest previous ndims
	sizelist(i,1:numel(siz)) = siz;
	sizelist(i,numel(siz)+1 : end) = 1; % in case ndims(varargin{i}) is smaller than largest previous ndims
end
if isempty(dim)
	dim = size(sizelist,2)+1; % determine dim automatically: choose next higher dimension
end
sizelist(:,end+1 : dim) = 1; % in case every ndims(varargin{i}) is smaller than concatenation dimension

resultsize = max(sizelist,[],1);
resultsize(dim) = sum(sizelist(:,dim));

e_dim = false(1,size(resultsize,2));
e_dim(dim) = true; % disregard concatenation dimension when checking dimension consistency
if ~all(all(bsxfun(@eq,sizelist,resultsize) | sizelist==1) | e_dim)
	error('xcat:InsonsistentDimensions','Inconsistent dimensions. For each dimension, array sizes must either match or be equal to one.');
end

for i=1:numel(varargin)
	newsize = resultsize./sizelist(i,:);
	newsize(dim) = 1; % don't repeat along concatenation dimension
	varargin{i} = repmat(varargin{i},newsize);
	% TODO alternative to save working memory: in each loop iteration, do repmat, cat, discard
end

% prevent "Error using cat: Dimension for sparse matrix concatenation must be <= 2."
if dim>2 && any(cellfun(@issparse,varargin))
	warning('Converting sparse to full...')
	varargin = full(varargin); % this uses @cell/full.m
end

result = cat(dim,varargin{:});

