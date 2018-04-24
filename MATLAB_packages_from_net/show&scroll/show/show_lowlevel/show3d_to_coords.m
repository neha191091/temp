function coords = show3d_to_coords(x,y,dims,dist,ncols)

dims(end+1 : 3)=1;

if ~exist('dist','var') || isempty(dist), dist=1; end
if ~exist('ncols','var') || isempty(ncols), ncols=floor(sqrt(dims(3))); end
nrows=ceil(dims(3)/ncols);


dims4d = [dims(1) dims(2) ncols nrows];
coords4d = show4d_to_coords(x,y,dims4d,dist);

coords = [coords4d(1) coords4d(2) coords4d(4)+(coords4d(3)-1)*nrows];

coords(coords<1) = NaN;
coords(coords>dims(1:3)) = NaN;
