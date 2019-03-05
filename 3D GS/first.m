%% Code to open a 3D image (array/image stack) %%
clear all; close all; clc;

%% Open folder containing TIFF images and store in %%
myFolder = 'C:\Users\yannz\OneDrive\Documents\Imperial\Year 4 project\Yann''s codes\Opening and visualising 3D image\headctscan3d';
if ~isdir(myFolder)
  errorMessage = sprintf('Error: The following folder does not exist:\n%s', myFolder);
  uiwait(warndlg(errorMessage));
  return;
end

filePattern = fullfile(myFolder, '*.tiff'); % builds a file specification from any file ending in tiff
tiffFiles = dir(filePattern); % dir lists all files in the current folder

% for k = 1:length(tiffFiles) % 1 - 360. If less data is needed, change length(tiffFiles) to desired value
for k = 1:4
  baseFileName = tiffFiles(k).name;
  fullFileName = fullfile(myFolder, baseFileName);
  fprintf(1, 'Now reading %s\n', fullFileName);
  
  %%% Uncomment the following section if not putting images in an array.
  %|
  %imageArray = imread(fullFileName);
  %imageArray = rgb2gray(imageArray); % removes the 512*512*3 - the 3 is colour
  %imshow(imageArray); % display image.
  %|
  %%% End of section

  imageArray{k} = imread(fullFileName);
  %imageArray{k} = rgb2gray(imageArray{k}); % removes the 512*512*3 - the 3 is colour
% However removing the third dimension doesn't allow for visualization in
% the volume viewer
  imshow(imageArray{k}); % display image. Works outside of loop
  drawnow; % force display to update immediately.
end

%% Creation of source beam %%
x = linspace(-10,10,512); % linearly spaced vector for x dimension 
                          % (change last value if image dimensions are different)
y = linspace(-10,10,512); % linearly spaced vector for y dimension 
                          % (change last value if image dimensions are different)
[X,Y] = meshgrid(x,y);

% Use Gaussian beam
x0 = 0; % center
y0 = 0; % center
sigma = 2; % beam waist
A = 1; % beam peak
res = ((X-x0).^2 + (Y-y0).^2)./(2*sigma^2);                     
input_intensity = A  * exp(-res); % Gaussian beam definitions
surf(input_intensity);                                         
shading interp;    

%% 2D GS FOR ONE PLANE

% Reading in of image and initialisation of parameters %%
% test with imagearray{1} first
imshow(imageArray{1});
target = rgb2gray(imageArray{1}); % Why rgb2gray? only grayscale?
target = double(target); % reconversion for using fftshift
imshow(target);
A = fftshift(ifft2(fftshift(target))); % outside of GS loop
error = []; % creates an empty array for error
% iteration_count; % can specify number if wished

% Iterate with the GS algorithm (pseudo code from Wikipedia)
figure;
subplot(2,3,1);
imshow(imageArray{1}); % Shows OG image (in color)  

for i = 1:200
    B = abs(input_intensity) .* exp(1i*angle(A)); % .* for element wise multiplication
    C = fftshift(fft2(fftshift(B)));                           
    D = abs(target) .* exp(1i*angle(C));                       
    A = fftshift(ifft2(fftshift(D)));                          
    error = [error; sum(sum(abs(abs(C) - abs(target))))]; 
    
    if i == 3 % 3 iterations
        subplot(2,3,2);
        imshow(target);
        title('Original');
        subplot(2,3,3);
        imagesc(abs(C));
        title('Reconstruction, 3 iterations');
    end
    if i == 6 % 6 iterations
        subplot(2,3,4);
        imagesc(abs(C));
        title('Reconstruction, 6 iterations');
    end
    if i == 10 % 10 iterations
        subplot(2,3,5);
        imagesc(abs(C));
        title('Reconstruction, 10 iterations');
    end
    if i == 100 % 100 iterations
        subplot(2,3,6);
        imagesc(abs(C));
        title('Reconstruction, 100 iterations');
    end
end

% Print out error criterion evolution
figure;
i = 1:1:i; % creation of a regularly spaced vector using i as the increment
plot(i,(error'));
title('Error over 200 iterations');

%% 2D GS of all 4 planes

figure;
for k = 1:4
   
   target = rgb2gray(imageArray{k});
   target = double(target);
   A = fftshift(ifft2(fftshift(target)));
   error = [];
  
   for i = 1:100
        B = abs(input_intensity) .* exp(1i*angle(A)); % .* for element wise multiplication
        C = fftshift(fft2(fftshift(B)));
        % fresnelpropagateft(C, 100 , 0.450, dx, dy); ==> need to find the
        % correct parameters:
        % C is input, 
        D = abs(target) .* exp(1i*angle(C));                       
        A = fftshift(ifft2(fftshift(D)));
   end
   error = [error; sum(sum(abs(abs(C) - abs(target))))];
   
   subplot(2,2,k);
   imagesc(abs(C)); % displays with scaled colors and abs is needed for
   % the complex values (amplitude) - otherwise we get an error
   title(['GS of layer ', num2str(k)]);
   
end

%% Visualization with Volumeviewer or other tool

% volumeViewer(V); % need to combine stacks to make it into one volume V?

%% What I'm trying to do:

% A very quick overview – you can superimpose multiple holograms to create a single hologram which will 
% generate both intensity patterns you want at different planes, but with poorer image fidelity than a 
% ‘dedicated’ hologram for each plane. Say you have two planes; you can create a hologram for plane A, 
% and a separate one for plane B. If you sum hologram A and hologram B, you get hologram AB, which 
% produces plane A and plane B, but with more speckle and additional stuff compared to hologram A 
% generating plane A, or hologram B generating plane B. We can use this to create a 3D stack 
% (which I’ve done already) by using a Fresnel propagation to ‘move’ plane A to z=0, 
% and plane B to z=100um, for example. You just add an extra step in the middle of the GS algorithm 
% where you find the field after the lens, then you add a step to do a Fresnel propagation, 
% replace the phase as before, Fresnel propagate back to the original plane, and take the inverse 
% Fourier transform as normal. I’ve done this for 10 separate planes, and it seems to work OK.

% Now we can be more clever with the Weighted GS, because we can decide that some parts of the image 
% are more important than others. In the context of optogenetics, if the light passes through a cell 
% that doesn’t express an opsin, we don’t care whether it’s light or dark – it’s not going to have an 
% effect anyway. This ‘frees up’ the degrees of freedom we have, in order to suppress the speckle in 
% the bits of the hologram we do care about. Hence why weighted GS is useful in this context.
