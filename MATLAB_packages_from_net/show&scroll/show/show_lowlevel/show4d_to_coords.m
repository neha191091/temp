function coords = show4d_to_coords(x,y,dims,dist)

if ~exist('dist','var') || isempty(dist), dist=1; end

% coarse scale
coords(4) = ceil(x / (dims(2)+dist));
coords(3) = ceil(y / (dims(1)+dist));

% fine scale
coords(2) = round(mod(x, (dims(2)+dist)));
coords(1) = round(mod(y, (dims(1)+dist)));

coords(coords<1) = NaN;
coords(coords>dims(1:4)) = NaN;
% if any(coords<1) || any(coords>dims(1:4))
% 	coords = coords*NaN;
% end
% coords = max(1,coords);
% coords = min(coords, dims(1:4));
