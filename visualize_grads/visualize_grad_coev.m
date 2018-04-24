% Scripts to visualize gradient and coevolution matrices and their
% relationship in MATLAB
% Authors: Neha Das, Sumit Dugar, Vladimir Golkov

gradients = load('/media/neha/ubuntu/data/dl4cv_prakt/experiments/1ABA_A.mat');
gradients = gradients.gradients;

coev = load('/home/neha/Documents/repo/dl4cv_prak/experiments/1ABA_A/1ABA_A_Coevolution.mat');
coev = coev.coev;

% Visualize the gradients for a particular col position - 32
scroll(gradients(ceil(end/2),ceil(end/2),:,:,:,32))
set(gca,'clim',max(abs(get(gca,'clim')))*[-1 1]),bwr

% Visualize the correlation values for a particuar column position -32
scroll(coev(:,32,:,:),[3 4 1 2])
set(gca,'clim',max(abs(get(gca,'clim')))*[-1 1]),bwr


% Correlation between coevolution and gradients (for the subset 20:32,20:32)
figure
corr_coev_grad = zeros(87,87,21,21);
for i =20:32
    for j =20:32
        for k=1:21
            for l=1:21
                ud = 7;
                lr = 7;
                ud_u = max(1, i - ud);
                ud_d = min(i + ud, 87);
                lr_l = max(1, j - lr);
                lr_r = min(j + lr, 87);
                ud_u, ud_d, lr_l, lr_r, i, j, k ,l
                corr_coev_grad(i,j,k,l) = corr(reshape(permute((coev(ud_u:ud_d,lr_l:lr_r,k,l)),[3 4 1 2]),1,[])',reshape(gradients(:,:,k,l,i,j),1,[])');
            end
        end
    end
end
show(corr_coev_grad(20:32,20:32,:,:))
size(corr_coev_grad)
set(gca,'clim',max(abs(get(gca,'clim')))*[-1 1]),bwr

% Correlation between coevolution and gradients (for 20,32)
figure
corr_coev_grad = zeros(21,21);
i =20;
j =32;
for k=1:21
    for l=1:21
        ud = 7;
        lr = 7;
        ud_u = max(1, i - ud);
        ud_d = min(i + ud, 87);
        lr_l = max(1, j - lr);
        lr_r = min(j + lr, 87);
        ud_u, ud_d, lr_l, lr_r, i, j, k ,l
        corr_coev_grad(k,l) = corr(reshape(permute((coev(ud_u:ud_d,lr_l:lr_r,k,l)),[3 4 1 2]),1,[])',reshape(gradients(:,:,k,l,i,j),1,[])');
    end
end

show(corr_coev_grad)
size(corr_coev_grad)
set(gca,'clim',max(abs(get(gca,'clim')))*[-1 1]),bwr

% Scatter Plot coev vs gradient for 20,32
figure
i=32;
j=20;
spl(10*10)
for k=1:10
    for l=1:10
        ud = 7;
        lr = 7;
        ud_u = max(1, i - ud);
        ud_d = min(i + ud, 87);
        lr_l = max(1, j - lr);
        lr_r = min(j + lr, 87);
        %array = array[:, ud_u:ud_d, lr_l:lr_r]
        ud_u, ud_d, lr_l, lr_r, i, j, k ,l
        spl
        scatter(...
        reshape(permute(coev(ud_u:ud_d,lr_l:lr_r,k,l),[3 4 1 2]),1,[]),...
        reshape(gradients(:,:,k,l,32,20),1,[]),...
        1)
    end
end

% Scatter plot of coev vs gradient single plot
figure
i=32;
j=20;
ud = 7;
lr = 7;
ud_u = max(1, i - ud);
ud_d = min(i + ud, 87);
lr_l = max(1, j - lr);
lr_r = min(j + lr, 87);
%array = array[:, ud_u:ud_d, lr_l:lr_r]
ud_u, ud_d, lr_l, lr_r, i, j, k ,l
spl
scatter(...
reshape(permute(coev(ud_u:ud_d,lr_l:lr_r,:,:),[3 4 1 2]),1,[]),...
reshape(gradients(:,:,:,:,32,20),1,[]),...
1)

% Just check whether coev_sign_invariance works the same as python script
coev_sign_20_32 = sign(coev(13:27,25:39,:,:));
grad_20_32 = gradients(:,:,:,:,20,32);
mul_grad_20_32 = grad_20_32 .* coev_sign_20_32;
show(mul_grad_20_32);
set(gca,'clim',max(abs(get(gca,'clim')))*[-1 1]),bwr
% Get the number of negatives and positives in the weighted gradients
tabulate(reshape(sign(mul_grad_20_32),1,[]))

% Corr test_2: Check correlation between gradients and coevolution at 20,32
corr_coev_grad_20_32 = zeros(21,21);
coev_20_32 = coev(13:27,25:39,:,:);
grad_20_32 = gradients(:,:,:,:,20,32);
for k=1:21
    for l=1:21
       corr_coev_grad_20_32(k,l)  = corr(reshape(coev_20_32(:,:,k,l),1,[])', reshape(grad_20_32(:,:,k,l),1,[])');
    end
end
size(corr_coev_grad_20_32)
show(corr_coev_grad_20_32);
set(gca,'clim',max(abs(get(gca,'clim')))*[-1 1]),bwr

%Test Corr - test how the corr function works
A=randn([15,15,21,21],'single');
B = 1 - A; % Should get negative correlation
corr_A_B = corr(reshape(A,1,[])',reshape(B,1,[])');
show(corr_A_B);
set(gca,'clim',max(abs(get(gca,'clim')))*[-1 1]),bwr

% Scatter plot for gradients vs coev 20_32
gradients = load('/home/neha/Documents/repo/dl4cv_prak/experiments/1ABA_A/1ABA_A_3_20_32.mat');
gradients = gradients.gradients;
coev = load('/home/neha/Documents/repo/dl4cv_prak/experiments/1ABA_A/1ABA_A_3_20_Coevolution.mat');
coev = coev.coev;
figure
scatter(...
reshape(coev,1,[]),...
reshape(gradients,1,[]),...
1)

%Get scatter plots
figure
i=32;
j=20;
spl(5*5)
for k=1:5
    for l=1:5
        spl
        scatter(...
        reshape(coev(:,:,k,l),1,[]),...
        reshape(gradients(:,:,k,l),1,[]),...
        1)
    end
end

show(sign(coev));
set(gca,'clim',max(abs(get(gca,'clim')))*[-1 1]),bwr