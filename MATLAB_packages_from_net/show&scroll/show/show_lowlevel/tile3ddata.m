function tile = tile3ddata(data,dist,ncols,box)

% dist
if ~exist('dist','var') || isempty(dist), dist=1; end

% dims
dims=size(data);
if length(dims)~=4
% 	error('Data must be 4D!')
	dims(numel(dims)+1:4)=1;
end

% ncols, nrows
if ~exist('ncols','var') || isempty(ncols), ncols=floor(sqrt(dims(3))); end
nrows=ceil(dims(3)/ncols);

% tile
tile=nan([dims(1)*ncols+dist*(ncols-1) dims(2)*nrows+dist*(nrows-1)]);
ind=1;
for n1=1:ncols
	for n2=1:nrows
		if ind<=dims(3)
			tile((n1-1)*(dims(1)+dist)+[1:dims(1)],(n2-1)*(dims(2)+dist)+[1:dims(2)]) = data(:,:,ind);
		end
		ind=ind+1;
	end
end

% outer box of NaNs
if exist('box','var') && box
	tile = padarray(tile,[1 1],NaN);
end
