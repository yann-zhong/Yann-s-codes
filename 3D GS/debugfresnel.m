% CODE TO DEBUG FORWARD AND BACKWARD FRESNEL %
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

for k = 1:length(jpgFiles)
  baseFileName = jpgFiles(k).name;
  fullFileName = fullfile(myFolder, baseFileName);
  fprintf(1, 'Now reading %s\n', fullFileName);
  imageArray{k} = imread(fullFileName);
  imageArray{k} = double(imageArray{k}); % does the issue lie in conversion to double???
end

for k = 1:length(jpgFiles)
    fourier_imageArray{k} = fftshift(fft2(fftshift(imageArray{k})));
    nonfourier_imageArray{k} = fftshift(ifft2(fftshift(fourier_imageArray{k})));
end

%% Forward Fresnel + back to focal plane

% In the Fourier plane, forward Fresnel "1" with both propagation functions
ff1 = fresnelpropagation2(fourier_imageArray{1},150,0.6,0.39,0.39); % fresnel_forward_one
ff2 = fresnelpropagateft(fourier_imageArray{1},150,0.6,0.39,0.39); % fresnel_forward_two
% Propagate them back to the focal plane, and compare
fff1 = fftshift(ifft2(fftshift(ff1))); % focal_fresnel_forward_one
fff2 = fftshift(ifft2(fftshift(ff2))); % focal_fresnel_forward_two
figure;
subplot(2,1,1);
imagesc(abs(fff1));
title('Forward, focal, fresnelpropagation2');
subplot(2,1,2);
imagesc(abs(fff2));
title('Forward, focal, fresnelpropagateft');

%% Forward + backward Fresnel + back to focal plane

% In the Fourier plane, backward Fresnel the forward Fresnel "1" with both
% propagation functions
ffb1 = fresnelpropagation2(fff1,-150,0.6,0.39,0.39); % fresnel_forward_backward_one
ffb2 = fresnelpropagateft(fff2,-150,0.6,0.39,0.39); % fresnel_forward_backward_two
%ffb1 = fresnelpropagation2(conj(fff1),150,0.6,0.39,0.39); % fresnel_forward_backward_one
%ffb2 = fresnelpropagateft(conj(fff2),150,0.6,0.39,0.39); % fresnel_forward_backward_two
% Propagate them back to the focal plane, and compare
fffb1 = fftshift(ifft2(fftshift(ffb1))); % focal_fresnel_forward_backward_one
fffb2 = fftshift(ifft2(fftshift(ffb2))); % focal_fresnel_forward_backward_two
figure;
subplot(2,1,1);
imagesc(abs(fffb1));
title('For + back, focal, fresnelpropagation2');
subplot(2,1,2);
imagesc(abs(fffb2));
title('For + back , focal, fresnelpropagateft');

%% Adding and subbing the fresnel planes

% In the Fourier plane, sum and sub the fresnel fields
sum1 = ff1 + ffb1;
sum2 = ff2 + ffb2;
sub1 = ff1 - ffb1;
sub2 = ff2 - ffb2;

% Propagate them back to the focal plane, and compare
focal_sum1 = fftshift(ifft2(fftshift(sum1)));
focal_sum2 = fftshift(ifft2(fftshift(sum2)));
focal_sub1 = fftshift(ifft2(fftshift(sub1)));
focal_sub2 = fftshift(ifft2(fftshift(sub2)));

figure;
subplot(2,2,1);
imagesc(abs(focal_sum1));
title('Sum of for and for + back, fresnelpropagation2');
subplot(2,2,2);
imagesc(abs(focal_sum2));
title('Sum of for and for + back, fresnelpropagateft');
subplot(2,2,3);
imagesc(abs(focal_sub1));
title('Sub of for and for + back, fresnelpropagation2');
subplot(2,2,4);
imagesc(abs(focal_sub2));
title('Sub of for and for + back, fresnelpropagateft');