% 5-D array of size 10x10x10x10x10 
A=randn([15,15,21,21,300]);

show(A) % visualize using 4-D tiles 
%show(A,'3d') % visualize using 3-D tiles 
%scroll(A) % visualize using 2-D tiles

% complex-valued array 
% (requires FileExchange submission 20292 "hsl2rgb and rgb2hsl conversion") 
%C=randn([10,10,10,10,10]).*exp(2*pi*1i*rand([10,10,10,10,10]));

%show(C) % encode magnitude as brightness and complex phase as color hue 
%showm(C) % show magnitude only 
%show(C,0) % show magnitude only 
%show(C,1) % encode complex phase as color hue 
%show(C,2) % encode magnitude as colormap and phase as brightness 
%show(C,3) % phase only as color hue 
%show(C,4) % phase only as brightness