%% Second code to open a 3D image (array/image stack) %%
clear all; close all; clc;
tic;

%% Read in images of 1-9
myFolder = 'C:\Users\yannz\OneDrive\Documents\Imperial\Year 4 project\Yann''s codes\3D GS\3D pictures\onetoone';
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
  
  %subplot(1,2,1);
  %imshow(abs(a{k})); % display image. Works outside of loop
  %subplot(1,2,2);
  %imshow(angle(a{k}));
  %drawnow; % force display to update immediately.
end

%% Creation of source beam %%
% figure;
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
% surf(input_intensity);                                         
% shading interp;    

%% GS algorithm loop here

error = [];
planes = length(a); % number of planes (9 for the 1-9 example)
intensity_array = {}; % initialize intensity array for average intensity
amplitude_array = {}; % initialize array to store amplitude before IFT
rng(1);
average_amplitude = a{randi([1 9])}; % first phase is random; then it changes every iteration

for l = 1:50 % arbitrary number of iterations
    
    field_focal = abs(input_intensity).*exp(1i*angle(average_amplitude)); % random phase from the 10 input images
    field_fourier = fftshift(fft2(fftshift(field_focal))); % go from focal plane to Fourier plane
    
    for m = 1:planes % will run once for every plane and store in cell arrays
        field_fresnel = fresnelpropagation2(field_fourier,(100*m),0.500,0.39,0.39); % propagate 100*m um forwards
        image_fresnel = abs(a{k}).*exp(1i*angle(field_fresnel)); % get the "image"
        image_fourier = fresnelpropagation2(image_fresnel,(-100*m),0.500,0.39,0.39); % propagate 100*m um backwards
        
%%% PROPAGATE BACK TO FOCAL PLANE HERE, REMOVE AVERAGE BEFORE PROPAGATION, AND AVERAGE IN FOCAL PLANE %%%

        image_focal = fftshift(ifft2(fftshift(image_fourier))); % go from Fourier plane to focal plane
        intensity_array{m} = abs(image_focal); % holds all 10 (or more, or less) values of intensity
        amplitude_array{m} = image_focal; % holds all focal images (amplitude)
    end
    
    c_intensity_array = cat(3,intensity_array{:}); % concatenates in 3D
    average_intensity = mean(c_intensity_array,3); % average reconstructed intensity
    c_amplitude_array = cat(3,amplitude_array{:}); % concatenates in 3D
    average_amplitude = mean(c_amplitude_array,3); % average amplitude before IFT
    
    phase_hologram = angle(average_amplitude); % phase hologram
    
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

%%

% use implay to display the images in a sequence?