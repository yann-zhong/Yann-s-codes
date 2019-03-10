%% Second code to open a 3D image (array/image stack) %%
clear all; close all; clc;
tic;

%% Read in images of 1-9
myFolder = 'C:\Users\yannz\OneDrive\Documents\Imperial\Year 4 project\Yann''s codes\Opening and visualising 3D image\onetoten';
if ~isdir(myFolder)
  errorMessage = sprintf('Error: The following folder does not exist:\n%s', myFolder);
  uiwait(warndlg(errorMessage));
  return;
end

filePattern = fullfile(myFolder, '*.jpg'); % builds a file specification from any file ending in tiff
jpgFiles = dir(filePattern); % dir lists all files in the current folder

% for k = 1:length(tiffFiles) % 1 - 360. If less data is needed, change length(tiffFiles) to desired value
for k = 1:length(jpgFiles)
  baseFileName = jpgFiles(k).name;
  fullFileName = fullfile(myFolder, baseFileName);
  fprintf(1, 'Now reading %s\n', fullFileName);
  imageArray{k} = imread(fullFileName);
  
  % imageArray{k} = rgb2gray(imageArray{k}); only for color image
  a{k} = double(imageArray{k}); % put images into new Array for processing purposes
  a{k} = fftshift(ifft2(fftshift(a{k}))); % A is now an array with 9 elements with phase and amplitude info
  
  subplot(1,2,1);
  imshow(abs(a{k})); % display image. Works outside of loop
  subplot(1,2,2);
  imshow(angle(a{k}));
  drawnow; % force display to update immediately.
end

%% Creation of source beam %%
figure;
x = linspace(-10,10,540); % linearly spaced vector for x dimension
                          % (change last value if image dimensions are different)
y = linspace(-10,10,540); % linearly spaced vector for y dimension 
                          % (change last value if image dimensions are different)
[X,Y] = meshgrid(x,y);

% Use Gaussian beam
x0 = 0; % center
y0 = 0; % center
sigma = 2; % beam waist
bp = 1; % beam peak
res = ((X-x0).^2 + (Y-y0).^2)./(2*sigma^2);                     
input_intensity = bp  * exp(-res); % Gaussian beam definitions
surf(input_intensity);                                         
shading interp;    

%% GS algorithm loop here

error = [];
planes = length(a); % number of planes (9 for the 1-9 example)
intensity_array = {}; % initialize intensity array for average intensity
new_F = {}; % initialize array to store amplitude before IFT
rng(1);
A = a{randi([1 9])}; % first phase is random

for l = 1:50 % arbitrary number of iterations
    
    B = abs(input_intensity).*exp(1i*angle(A)); % random phase from the 10 input images
    C = fftshift(fft2(fftshift(B)));
    
    for m = 1:planes % will run once for every plane and store in cell arrays
        D = fresnelpropagation2(C,(100*m),0.450,0.39,0.39);
        E = abs(a{k}).*exp(1i*angle(D));
        F = fresnelpropagation2(E,(-100*m),0.450,0.39,0.39);
        
        intensity_array{m} = abs(F); % Reconstructed intensity array
        new_F{m} = F; % Amplitude before IFT array
    end
    
    c_intensity_array = cat(3,intensity_array{:}); % concatenates in 3D
    average_intensity = mean(c_intensity_array,3); % average reconstructed intensity
    c_F = cat(3,new_F{:}); % concatenates in 3D
    average_amplitude = mean(c_F,3); % average amplitude before IFT
    
    A = fftshift(ifft2(fftshift(average_amplitude)));
    phase_hologram = angle(A); % phase hologram
    
end
% error = avg of errors?

%% Display of avg intensity and phase hologram

figure;
subplot(2,1,1);
imagesc(average_intensity); % use to display average of 1-9
title('Average intensity');

subplot(2,1,2);
imagesc(phase_hologram); % use to display phase hologram
title('Phase hologram');

toc;