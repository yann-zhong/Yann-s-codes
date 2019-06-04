% CODE TO EXPERIMENT WITH FOURIER THEORY ON IMAGES
% https://homepages.inf.ed.ac.uk/rbf/HIPR2/fourier.htm
% http://cns-alumni.bu.edu/~slehar/fourier/fourier.html
% https://www.cs.unm.edu/~brayer/vision/fourier.html
% http://www.ysbl.york.ac.uk/~cowtan/fourier/coeff.html
clear all; close all; clc;
tic;

%% Read in images 1-9

myFolder = 'C:\Users\yannz\OneDrive\Documents\Imperial\Year 4 project\Yann''s codes\3D GS\3D pictures\onetoten';
if ~isdir(myFolder)
  errorMessage = sprintf('Error: The following folder does not exist:\n%s', myFolder);
  uiwait(warndlg(errorMessage));
  return;
end
    
filePattern = fullfile(myFolder, '*.jpg'); % builds a file specification from any file ending in tiff
jpgFiles = dir(filePattern); % dir lists all files in the current folder
figure;
for k = 1:length(jpgFiles)
  baseFileName = jpgFiles(k).name;
  fullFileName = fullfile(myFolder, baseFileName);
  fprintf(1, 'Now reading %s\n', fullFileName);
  imageArray{k} = imread(fullFileName);
  imageArray{k} = double(imageArray{k})/255; % normalize image by dividing by 255
  imshow(abs(imageArray{k}));
end

%% Fourier transform manipulation of image

fourier = fftshift(fft2(fftshift(imageArray{1}))); % normal FT transform
log_fourier = 2*log(1 + (fourier)); % log transform of FT transform
% the log transform is required as the dynamic range is too large to be
% displayed on screen ==> enhances low pixel values.

figure;
subplot(3,1,1);
imagesc(abs(fourier));
colormap(gray(256));
colorbar;
title('intensity of FT of image');
subplot(3,1,2);
imagesc(abs(log_fourier));
colormap(gray(256));
colorbar;
title('intensity of log of FT of image');
subplot(3,1,3);
imagesc(angle(fourier));
colormap(gray(256));
colorbar;
title('phase of FT of image');

%% Amplitude manipulations

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

figure;

new_amplitude = abs(input_intensity).*exp(1i*angle(imageArray{1}));
imagesc(abs(new_amplitude));
colormap(gray(256));
colorbar;
title('Intensity of input beam .* exp(phase of 1)');