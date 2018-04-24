function xy = coords_to_show4d(coords,dims,dist)

if ~exist('dist','var') || isempty(dist), dist=1; end

xy = ...
[ coords(2) + (coords(4)-1)*(dims(2)+dist),...
  coords(1) + (coords(3)-1)*(dims(1)+dist)];

