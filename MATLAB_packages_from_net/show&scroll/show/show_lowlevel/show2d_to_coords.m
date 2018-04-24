function coords = show2d_to_coords(x,y,dims)

% fine scale
coords(2) = round(x);
coords(1) = round(y);

coords(coords<1) = NaN;
coords(coords>dims(1:2)) = NaN;
% if any(coords<1) || any(coords>dims(1:4))
% 	coords = coords*NaN;
% end
% coords = max(1,coords);
% coords = min(coords, dims(1:4));
