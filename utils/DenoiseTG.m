function x = DenoiseTG(y,lambda,Nit,D,Dt)
% DENOISETG - AUXILIARY FUNCTION
%  Temporal gradident filtering (denoising) using iterative clipping
%  algorithm.
%
%  Function modified from
%
%  Ivan W. Selesnick and Ilker Bayram,
%  "Total variation filtering,"
%  Connexions, August 13, 2009,
%  http://cnx.org/content/m31292/1.1/
% 
%  Inputs:
%   y      : Noisy signal as row vector.
%   lambda : Regularization parameter.
%   Nit    : Number of iterations.
%   [D, Dt] : Matrices needed for TG filtering. Refer to GenD.m for more
%             information on how to generate them.
% 
%  Outputs:
%   x : Denoised signal as row vector.


%  Jose Caballero
%  Biomedical and Image Analysis Group
%  Department of Computing
%  Imperial College London, London SW7 2AZ, UK
%  jose.caballero06@imperial.ac.uk
%
%  October 2012

N = gpuArray(length(y));
z = gpuArray.zeros(1,N); % initialize z
alpha = 4;
T = lambda/2;
for k = 1:Nit
    x = y.' - Dt*z.';
    x = x(:).';
    z = z(:) + 1/alpha * D*x(:);
    z = z(:).';
    z = max(min(z,T),-T); % clip(z,T)
end