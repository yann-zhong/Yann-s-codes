close all; clear all; clc;
% send a sample code to Chris - use one and see what both Fresnel codes do.

one = double(one);
comparefresnel(one,100,0.682,0.39,0.39)
one_ifft=fftshift(ifft2(fftshift(one)));
one_fft=fftshift(fft2(fftshift(one)));
comparefresnel(one_fft,100,0.682,0.39,0.39)
comparefresnel(one_ifft,100,0.682,0.39,0.39)
close all
comparefresnel(one_ifft,100,0.682,0.39,0.39)