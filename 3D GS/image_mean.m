% CODE TO TEST MEAN OF IMAGES %
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

%% Take mean of images 1-9
figure;
for k = 1:length(jpgFiles)
  baseFileName = jpgFiles(k).name;
  fullFileName = fullfile(myFolder, baseFileName);
  fprintf(1, 'Now reading %s\n', fullFileName);
  imageArray{k} = imread(fullFileName);
  imshow(imageArray{k});
  imageArray{k} = double(imageArray{k});
end

sumimage = imageArray{1};
for i = 2:length(jpgFiles)
    sumimage = sumimage + double(imageArray{i});
end
meanimage = sumimage/9;
figure;
imagesc(meanimage); % or imshow(meanimage,[]);
colormap(gray(256));
colorbar;
title('mean of 9 images');

%% Take mean of images 1-9 after putting through Fourier plane and back
figure;
for k = 1:length(jpgFiles)
    fourier_imageArray{k} = fftshift(fft2(fftshift(imageArray{k})));
    nonfourier_imageArray{k} = fftshift(ifft2(fftshift(fourier_imageArray{k})));
    imshow(nonfourier_imageArray{k});
end

sum_fourier = abs(nonfourier_imageArray{1});
for i = 2:length(jpgFiles)
    sum_fourier = sum_fourier + abs(nonfourier_imageArray{i});
end
mean_fourier = sum_fourier/9;
figure;
imagesc(mean_fourier); % or imshow(meanimage,[]);
colormap(gray(256));
colorbar;
title('mean of 9 images after ft and ift');

%% Take mean of images 1-9 after putting through Fourier plane, then Fresnel forward and back, and back
figure;
% try for first image for now
fresnel_forward = fresnelpropagation2(fourier_imageArray{1},150,0.6,0.39,0.39);
focal_fresnel_forward = fftshift(ifft2(fftshift(fresnel_forward)));
subplot(2,1,1);
imagesc(abs(focal_fresnel_forward));
colormap(gray(256));
colorbar;
title('intensity of "1" in focal plane after forward fresnel');

subplot(2,1,2);
fresnel_backward = fresnelpropagation2(conj(fresnel_forward),150,0.6,0.39,0.39);% take complex conjugate and propagate forward
%fresnel_backward = fresnelpropagation2(fresnel_forward,-150,0.6,0.39,0.39);
focal_fresnel_backward = fftshift(ifft2(fftshift(fresnel_backward)));
imagesc(abs(focal_fresnel_backward));
colormap(gray(256));
colorbar;
title('intensity of "1" in focal plane after forward, then backward fresnel');

add_fresnel = fresnel_forward + fresnel_backward;
sub_fresnel = fresnel_forward - fresnel_backward;
figure;
subplot(3,1,1);
imagesc(abs(add_fresnel));
colormap(gray(256));
colorbar;
title('Fresnel forward plus Fresnel backward');
subplot(3,1,2);
imagesc(abs(sub_fresnel));
colormap(gray(256));
colorbar;
title('Fresnel forward minus Fresnel backward');
subplot(3,1,3);
imagesc(abs(add_fresnel)-abs(sub_fresnel));
colormap(gray(256));
colorbar;
title('Subbing the previous 2');