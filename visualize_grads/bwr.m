% Author: Vladimir Golkov
function varargout = bwr(ax)
% blue-white-red colormap
% ax: axes handle (optional)

cmap = flipud(cbrewer('div','RdBu',64));

if nargout>0
    varargout{1} = cmap;
else
    if ~exist('ax','var') || isempty(ax)
        ax = gca;
    end

    colormap(ax, cmap)
end