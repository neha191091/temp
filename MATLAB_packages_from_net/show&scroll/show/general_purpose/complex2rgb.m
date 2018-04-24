function rgb = complex2rgb(data2d, complexmode, clim)
% Author: Vladimir Golkov

if nargin<2
	complexmode = 1;
end

% rgb = zeros([size(data2d), 3]);

phase01 = (angle(data2d)/pi+1)/2;		% phase scaled to [0 1]
phasemod = linsc(phase01,[0 1],[.15 .85]);
absd = abs(data2d);
if exist('clim','var')
	magnitude01 = linsc(absd, clim, [0 1]);
else
	magnitude01 = absd/max(absd(:));		% normalized magnitude (highest value is 1)
end

switch complexmode
	case 1 % magnitude=lightness, phase=color
% 		rgb = hsv2rgb(cat(3,phase01,min(2*(1-magnitude01),1),min(magnitude01*2,1)));
		rgb = hsl2rgb(cat(3,phase01,ones(size(data2d)),magnitude01));
		rgb(isnan(rgb))=0;
	case 2 % magnitude=colormap, phase=lightness
		ncol = 256;
		J = jet(ncol);
		colidx = ceil(magnitude01*ncol);
		
		in = isnan(colidx);
		colidx(in) = 1;
		colidx = max(min(colidx,ncol),1);
		
		rgb = reshape(J(colidx,:),[size(data2d) 3]);
		hsl = rgb2hsl(rgb);
		rgb = hsl2rgb(cat(3, hsl(:,:,1), hsl(:,:,2), phasemod));
		
		r = rgb(:,:,1); r(in) = 0;
		g = rgb(:,:,2); g(in) = 0;
		b = rgb(:,:,3); b(in) = 0;
		rgb = cat(3,r,g,b);
	case 3 % phase=color
		rgb = hsv2rgb(cat(3,phase01,ones(size(data2d)),ones(size(data2d))));
	case 4 % phase=lightness
		rgb = hsv2rgb(cat(3,ones(size(data2d)),zeros(size(data2d)),phase01));
	case 5 % magnitude=value, phase=color
		rgb = hsv2rgb(cat(3,phase01,ones(size(data2d)),magnitude01));
end

rgb = max(min(rgb,1),0);

