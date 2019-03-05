                  %% GS algorithm with different constraint: discard phase, keep intensity information %%
clear all; close all; clc;    
tic;                                                           % use toc at the end to measure run time

                                            %% Creation of source beam %%
x = linspace(-10,10,379);                                      % linearly spaced vector for x dimension 
                                                               % (change last value if image dimensions are different)
y = linspace(-10,10,682);                                      % linearly spaced vector for y dimension 
                                                               % (change last value if image dimensions are different)
[X,Y] = meshgrid(x,y);                                         % uses the vectors x and y to generate a rectangular grid

% Use Gaussian beam or other beam? What defines a good light source?
x0 = 0;                                                        % center
y0 = 0;                                                        % center
sigma = 2;                                                     % beam waist
A = 1;                                                         % beam peak
res = ((X-x0).^2 + (Y-y0).^2)./(2*sigma^2);                     
input_intensity = A  * exp(-res);                              % Gaussian beam definitions
surf(input_intensity);                                         
shading interp;                                                                             

                          %% Reading in of image and initialisation of parameters %%
target = rgb2gray(imread('Obi_wan.png'));                      % Why rgb2gray? only grayscale?
target = imbinarize(target,0.5);                               % convert to binary black and white to emulate DMD
target = double(target);                                       % reconversion for using fftshift
A = fftshift(ifft2(fftshift(target)));                         % outside of GS loop
error = [];                                                    % creates an empty array for error
% iteration_count;                                             % can specify number if wished

                        %% Iterate with the GS algorithm (pseudo code from Wikipedia %%
figure;
subplot(2,3,1);
imshow('Obi_wan.png');                                         % Shows OG image

for i = 1:100
    B = abs() .* exp(1i*angle());                              % .* for element wise multiplication
    C = fftshift(fft2(fftshift(B)));                        
    D = abs() .* exp(1i*angle());                      
    A = fftshift(ifft2(fftshift(D)));                        
    error = [error; sum(sum(abs(abs(C) - abs(target))))]; 
    if i == 3                                                  % 3 iterations
        subplot(2,3,2);
        imshow(target);
        title('Obi-Wan original PNG');
        subplot(2,3,3);
        imagesc(abs(C));
        title('Reconstructed image after 3 iterations');
    end
    if i == 6                                                 % 6 iterations
        subplot(2,3,4);
        imagesc(abs(C));
        title('Reconstructed image after 6 iterations');
    end
    if i == 10                                                % 10 iterations
        subplot(2,3,5);
        imagesc(abs(C));
        title('Reconstructed image after 10 iterations');
    end
    if i == 100                                               % 100 iterations
        subplot(2,3,6);
        imagesc(abs(C));
        title('Reconstructed image after 100 iterations');
    end
end
                                   %% Print out error criterion evolution %%
figure;
i = 1:1:i;                                                     % creation of a regularly spaced vector using i as the increment
plot(i,(error'));
title('Error');
    
toc;                                                           % ends the timer started by tic