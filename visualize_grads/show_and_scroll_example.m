% 5-D array of size 10x10x10x10x10 
%A=randn([15,15,21,21,87,87],'single');
G = load('/media/neha/ubuntu/data/dl4cv_prakt/experiments/1ABA_A.mat');
G = G.gradients;

C = load('/home/neha/Documents/repo/dl4cv_prak/experiments/1ABA_A/1ABA_A_Coevolution.mat');
C = C.coev;

D_G_T = load('/home/neha/Documents/repo/dl4cv_prak/experiments/1ABA_A/1ABA_A_distance_ground_truth.mat');
D_G_T = D_G_T.dist;

D_I = load('/home/neha/Documents/repo/dl4cv_prak/experiments/1ABA_A/1ABA_A_distance_inference.mat');
D_I = D_I.dist;

disp(size(G));

index = abs(D_G_T(:,:,4) - D_I(:,:,4)) < 4;

G = G(:,:,:,:,index);

disp(size(G));


S = G;

show(S) % visualize using 4-D tiles 

%crbrewer

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