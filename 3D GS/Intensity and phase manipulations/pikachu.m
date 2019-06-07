clear all; close all; clc;
tic;
% http://www.ysbl.york.ac.uk/~cowtan/fourier/coeff.html

%% Read in images of Pikachu(s)
pikachu1 = double(rgb2gray(imread('pikachu.png')));
pikachu2 = double(rgb2gray(imread('pikachu_no_tail.png')));

figure;
subplot(2,1,1);
imagesc(pikachu1);
subplot(2,1,2);
imagesc(pikachu2);

%% FT to get amplitude and phase information

ft_pikachu1 = fftshift(fft2(pikachu1));
ft_pikachu2 = fftshift(fft2(pikachu2));

intensity_p1 = abs(ft_pikachu1);
intensity_p2 = abs(ft_pikachu2);
phase_p1 = exp(1i*angle(ft_pikachu1));
phase_p2 = exp(1i*angle(ft_pikachu2));

%% Reconstruction

% Intensity only
pikachu1_i = ifft2(ifftshift(intensity_p1));
pikachu2_i = ifft2(ifftshift(intensity_p2));

% log to show values that might be out of range
pikachu1_i = 2*log(1 + (pikachu1_i));
pikachu2_i = 2*log(1 + (pikachu2_i));

figure;
subplot(2,1,1);
imagesc(abs(pikachu1_i));
subplot(2,1,2);
imagesc(abs(pikachu2_i));

% Phase only
pikachu1_p = ifft2(ifftshift(phase_p1));
pikachu2_p = ifft2(ifftshift(phase_p2));

figure;
subplot(2,1,1);
imagesc(abs(pikachu1_p));
subplot(2,1,2);
imagesc(abs(pikachu2_p));

% Mixing up phase and intensity of both
pikachu12 = intensity_p1.*phase_p2;
pikachu21 = intensity_p2.*phase_p1;

pikachu12_r = ifft2(ifftshift(pikachu12)); % need to go back to focal plane to see reconstruction!
pikachu21_r = ifft2(ifftshift(pikachu21));

figure;
subplot(2,1,1);
imagesc(abs(pikachu12_r));
title('Intensity of p1, phase of p2');
subplot(2,1,2);
imagesc(abs(pikachu21_r));
title('Intensity of p2, phase of p1');

%% Error

error12 = [];
error12 = [error12; sum(sum(abs(abs(pikachu12_r) - abs(pikachu1))))]; 

error21 = [];
error21 = [error21; sum(sum(abs(abs(pikachu21_r) - abs(pikachu1))))]; 

% error 12 is higher than error 21, meaning that the phase element of the
% tail is more important in reconstruction? Not sure what the value tells
% us, however.