clc
clearvars
close all
addpath(genpath(fullfile('filepath of directory')));
PRECISION    = 'float';
OFFSET       = 0 ;
INTERLEAVE   = 'bsq';
BYTEORDER    = 'ieee-le';
SIZE     = [836,836,128];
FILENAME = fullfile('filepath of hyperspectral dataset');
M = multibandread(FILENAME, SIZE, PRECISION, OFFSET, INTERLEAVE, BYTEORDER);
if (ndims(M)>3 || ndims(M)<2)
    error('Input image must be m x n x p or m x n');
end
if (ndims(M) == 2)
    numBands = 1;
    [h, w] = size(M);
else
    [h, w, numBands] = size(M);
end
M = reshape(M, w*h, numBands);
% tic
% q = round(intrinsic_dim(M, 'MLE'));
q = 14; 													%can be user-defined or computed using an intrinsic dimensionality estimation method such as Maximum Likelihood Estimation 
% toc
tic
M = M.';
[p, N] = size(M);
% u = mean(M.').';
% M = M - (u*ones(1,N));
% C = (M*M.')/N;
R = (M*M.')/N;
[U, S, V] = svd(R);
% [U, S, V] = svd(C);
V_1 = V(:,1:q);
% M_pct = (M.').* V(:,1:q);
lambda = diag(S);
writematrix(lambda,'filepath of storing singular value spreadsheet in .csv format');
M_1 = M.';
M_pct = M_1*V_1;
toc
tic
M_pct = M_pct.';
if (ndims(M_pct) ~= 2)
error('Input image must be p x N.');
end
[numBands1, N1] = size(M_pct);
if (1 == N1)
M_pct = reshape(M_pct, h, w);
else
M_pct = reshape(M_pct.', h, w, numBands1);
end
toc
tic
multibandwrite(M_pct,'filepath of storing the dimensionally reduced dataset','bsq');
toc