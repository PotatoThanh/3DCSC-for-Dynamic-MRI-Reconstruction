function [x,fval,exitflag,output,population,score] = GA_func(nvars,lb,ub, Generation, Population)
%  Thanh Nguyen-Duc
%  Ulsan National Institute of Science and Technology
%  thanhnguyen.cse@gmail.com
%
%  Septembet 2018

%% This is an auto generated MATLAB file from Optimization Tool.

%% Start with the default options
options = optimoptions('ga');
%% Modify options setting
options = optimoptions(options,'PopulationSize', Population);
options = optimoptions(options,'Generation', Generation);
options = optimoptions(options,'Display', 'off');
%options = optimoptions(options,'UseVectorized', true);
options = optimoptions(options,'PlotFcn', {  @gaplotbestf @gaplotbestindiv @gaplotdistance @gaplotstopping });
[x,fval,exitflag,output,population,score] = ...
ga(@fitness_func,nvars,[],[],[],[],lb,ub,[],[],options);
