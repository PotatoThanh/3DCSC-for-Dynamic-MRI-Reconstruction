function [ undersample ] = undersample_func( full, mask )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    % scale from 0 to 1
    full = scale_img(full);
    full = single(full);
    
    mask = fftshift(mask, 1);
    mask = fftshift(mask, 2);
    
    undersample = mask.*fft2(full);    
end

