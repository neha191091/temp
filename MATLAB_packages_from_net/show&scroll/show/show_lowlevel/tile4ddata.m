function tile = tile4ddata(data,dist,box)

% dist
if ~exist('dist','var') || isempty(dist), dist=1; end

% dims
dims=size(data);
if length(dims)~=4
% 	error('Data must be 4D!')
	dims(numel(dims)+1:4)=1;
end

% tile
tile=nan([dims(1)*dims(3)+dist*(dims(3)-1) dims(2)*dims(4)+dist*(dims(4)-1)]);
for n1=1:dims(3)
	X=(n1-1)*(dims(1)+dist)+[1:dims(1)];
	for n2=1:dims(4)
		Y=(n2-1)*(dims(2)+dist)+[1:dims(2)];
		tile(X,Y) = data(:,:,n1,n2);
	end
end

% outer box of NaNs
if exist('box','var') && box
	tile = padarray(tile,[1 1],NaN);
end
