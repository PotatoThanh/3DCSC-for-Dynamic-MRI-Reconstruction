%  Thanh Nguyen-Duc
%  Ulsan National Institute of Science and Technology
%  thanhnguyen.cse@gmail.com
%
%  Septembet 2018

clear all; close all; clc;
addpath(genpath('./'));

%% Choose a GPU device (we used Titan X with 12GB memory)
gpu_id = 1;
g = gpuDevice(gpu_id);
reset(g);

%%  Options Dictionary
opt.numAtoms = 3; % Total number of filters (it must be divided by 3) 
opt.numTypes = 3; % We only support 3 sizes of filters

% Atom 1 size
opt.atomSize1X = 15;
opt.atomSize1Y = 15;
opt.atomSize1Z = 20;

% Atom 2 size
opt.atomSize2X = 20;
opt.atomSize2Y = 20;
opt.atomSize2Z = 25;

% Atom 3 size
opt.atomSize3X = 25;
opt.atomSize3Y = 25;
opt.atomSize3Z = 30;

%% Load TV matrices
file_TV = './TV_matrix/cardiac/TV.mat';
load(file_TV);
opt.D = D;
opt.Dt = Dt;

%% Run GA for searching parameters
runGA = 0;
%% Search parameter using Genetic Algorithm (require installed Matlab optimization toolbox)
if runGA
    %% This data input for researching params
    % Load data
    load('data_tmi.mat')
    full = seq;
    full = scale_img(full);
    clear D Dt mask
    
    % Load mask
    file_mask = './data/mask_cardiac_25.mat';
    load(file_mask);
    mask = mask;

    % Undersample using mask
    undersample = undersample_func(full, mask);

    % options
    opt.isDisplay = 0; % show figures
    opt.isConsole = 0; % show outputs on console

    % options data size
    [x, y, z] = size(undersample);
    opt.dataSizeX = x; 
    opt.dataSizeY = y;
    opt.dataSizeZ = z;

    % Plot fullsample, undersample, mask
    figure(1);
    subplot(1,3,1);
    imshow(abs(full(:,:,1)),[0 1]);
    title('Fullsample');

    temp = ifft2(undersample);
    subplot(1,3,2);
    imshow(abs(temp(:,:,1)),[0 1]);
    title('Undersample');

    subplot(1,3,3);
    imshow(abs(mask(:,:,1)),[0 1]);
    title('Mask');
    drawnow();
    
    % lower bound and upper bound for parameter searching 
    lb = [0.001 0.001  0.001   0.001    1      1     0.001  1   1];
    ub = [ 5     5      5       5       100    100    1     5   5];
    %    alpha  gamma  lambda1 lambda2  rho   sigma  theta  D0  n
    
    % GA set up
    generation = 4;
    population = 120;
    num_params = 9;
    opt.num_iters = 100; % number of iterations
    opt.saveIntermediate = 1; % if this opt is on, the best parameter will be saved in temp_params folder

    fprintf('Genetic Algorith is running, it will take long time!\n');
    ga = main_GA(full, mask, undersample, generation, population, num_params, lb, ub, opt);
    
    % File save name
    file_ga = './searched_params/GA_param25.mat';
    
    % save result
    save(file_ga, 'ga'); 
    
end % End of GA


%% Reconstruction using searched parameters

% Load 3D MRI
load('data_tmi.mat')
full = seq;
full = scale_img(full);
clear D Dt mask

% Load mask
file_mask = './data/mask_cardiac_25.mat';
load(file_mask);
mask = mask;

% Load searched parameters
GA_result_name = './searched_params/GA_param25.mat';
load(GA_result_name);
ga = ga;

% Undersample using mask
undersample = undersample_func(full, mask);

% options
opt.num_iters = 199; % number of iterations
opt.isDisplay = 1; % show figures
opt.isConsole = 1; % show outputs on console

% options data size
[x, y, z] = size(undersample);
opt.dataSizeX = x; 
opt.dataSizeY = y;
opt.dataSizeZ = z;

% Plot fullsample, undersample, mask
figure(1);
subplot(1,3,1);
imshow(abs(full(:,:,1)),[0 1]);
title('Fullsample');

temp = ifft2(undersample);
subplot(1,3,2);
imshow(abs(temp(:,:,1)),[0 1]);
title('Undersample');

subplot(1,3,3);
imshow(abs(mask(:,:,1)),[0 1]);
title('Mask');
drawnow();

% File save name
file_save = './result/recon_cardiac.mat';

%  Recontruct process
result = split_3DCSC_TV(full, mask, undersample, ga, opt);

% save result
save(file_save,'result'); 

