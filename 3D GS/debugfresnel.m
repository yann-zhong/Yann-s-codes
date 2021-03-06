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
    fourier_imageArray{k} = fftshift(fft2(ifftshift(imageArray{k})));
    log_fourier{k} = 2*log(1 + (fourier_imageArray{k}));
    nonfourier_imageArray{k} = fftshift(ifft2(ifftshift(fourier_imageArray{k})));
end

% figure;
% subplot(3,1,1);
% imagesc(abs(fourier_imageArray{1}));
% subplot(3,1,2);
% imagesc(abs(log_fourier{1}));
% subplot(3,1,3);
% imagesc(abs(nonfourier_imageArray{1}));

%% Forward Fresnel + back to focal plane

% In the Fourier plane, forward Fresnel "1" with both propagation functions
ff1 = fresnelpropagation2(imageArray{1},150,0.6,0.39,0.39); % fresnel_forward_one
ff2 = fresnelpropagateft(imageArray{1},150,0.6,0.39,0.39); % fresnel_forward_two
% Propagate them back to the focal plane, and compare
fff1 = fftshift(ifft2(ifftshift(ff1))); % focal_fresnel_forward_one
fff2 = fftshift(ifft2(ifftshift(ff2))); % focal_fresnel_forward_two

figure;
subplot(2,1,1);
imagesc(abs(fff1));
title('Forward, focal, fresnelpropagation2');
colormap(gray(256));
colorbar;
subplot(2,1,2);
imagesc(abs(fff2));
title('Forward, focal, fresnelpropagateft');
colormap(gray(256));
colorbar;

%% Forward + backward Fresnel + back to focal plane

% In the Fourier plane, backward Fresnel the forward Fresnel "1" with both
% propagation functions
ffb1 = fresnelpropagation2(conj(ff1),150,0.6,0.39,0.39); % fresnel_forward_backward_one
ffb2 = fresnelpropagateft(conj(ff2),150,0.6,0.39,0.39); % fresnel_forward_backward_two

% Propagate them back to the focal plane, and compare
fffb1 = fftshift(ifft2(ifftshift(ffb1))); % focal_fresnel_forward_backward_one
fffb2 = fftshift(ifft2(ifftshift(ffb2))); % focal_fresnel_forward_backward_two

figure;
subplot(2,1,1);
imagesc(abs(fffb1));
title('For + back, focal, fresnelpropagation2');
colormap(gray(256));
colorbar;
subplot(2,1,2);
imagesc(abs(fffb2));
title('For + back , focal, fresnelpropagateft');
colormap(gray(256));
colorbar;

%% Adding and subbing the fresnel planes
for j = 1:1
%     % In the Fourier plane, sum and sub the fresnel fields
%     sum1 = ff1 + ffb1;
%     sum2 = ff2 + ffb2;
%     sub1 = ff1 - ffb1;
%     sub2 = ff2 - ffb2;
% 
%     % Propagate them back to the focal plane, and compare
%     focal_sum1 = fftshift(ifft2(fftshift(sum1)));
%     focal_sum2 = fftshift(ifft2(fftshift(sum2)));
%     focal_sub1 = fftshift(ifft2(fftshift(sub1)));
%     focal_sub2 = fftshift(ifft2(fftshift(sub2)));
% 
%     figure;
%     subplot(2,2,1);
%     imagesc(abs(focal_sum1));
%     title('Sum of for and for + back, fresnelpropagation2');
%     colormap(gray(256));
%     colorbar;
%     subplot(2,2,2);
%     imagesc(abs(focal_sum2));
%     title('Sum of for and for + back, fresnelpropagateft');
%     colormap(gray(256));
%     colorbar;
%     subplot(2,2,3);
%     imagesc(abs(focal_sub1));
%     title('Sub of for and for + back, fresnelpropagation2');
%     colormap(gray(256));
%     colorbar;
%     subplot(2,2,4);
%     imagesc(abs(focal_sub2));
%     title('Sub of for and for + back, fresnelpropagateft');
%     colormap(gray(256));
%     colorbar;
end

%% Fourier plane forward Fresnel transforms
for k = 1:1
%     figure;
%     subplot(3,1,1);
%     imagesc(abs(fourier_imageArray{1}));
%     title('Fourier plane no diffraction');
%     colormap(gray(256));
%     colorbar;
%     
%     subplot(3,1,2);
%     imagesc(abs(ff1));
%     title('Fourier plane, forward fresnelpropagation2');
%     colormap(gray(256));
%     colorbar;
%     
%     subplot(3,1,3);
%     imagesc(abs(ff2));
%     title('Fourier plane, forward fresnelpropagateft');
%     colormap(gray(256));
%     colorbar;
end

%% Fresnel propagation at different values 

close all;

figure;
imagesc(abs(imageArray{1}));
title('Original image, double');
colormap(gray(256));
colorbar;

for l = 1:10
%    FRESNEL PROPAGATE IN FOCAL PLANE, FOR + BACK, LOOK IN FOCAL PLANE
   figure;
   fresnel_forward = fresnelpropagateft(imageArray{1},100*l,0.6,0.39,0.39);
   fresnel_backward = fresnelpropagateft(fresnel_forward,-100*l,0.6,0.39,0.39);
   imagesc(abs(fresnel_forward));
   drawnow;
   title("Fresnel forward propagation of "+ 100*l+ " PU");
   colormap(gray(256));
   colorbar;
%     
end

for m = 1:10
%    FRESNEL PROPAGATE IN FOURIER PLANE (LOG), FOR + BACK, LOOK IN FOURIER
%    PLANE
%    figure;
%    fourier_fresnel_forward = fresnelpropagateft(log_fourier{1},100*m,0.6,0.39,0.39);
%    fourier_fresnel_backward = fresnelpropagateft(fourier_fresnel_forward,-100*m,0.6,0.39,0.39);
%    imagesc(abs(fourier_fresnel_backward));
%    drawnow;
%    title('Fourier Fresnel forward+backward');
%    colormap(gray(256));
%    colorbar;
    
end

for n = 1:10
%  FRESNEL PROPAGATE IN FOURIER PLANE (NON LOG), FOR + BACK, LOOK IN FOCAL   
%    figure;
%    fourier_fresnel_forward = fresnelpropagateft(fourier_imageArray{1},100*n,0.6,0.39,0.39);
%    fourier_fresnel_backward = fresnelpropagateft(fourier_fresnel_forward,-100*n,0.6,0.39,0.39);
%    focal_forward = fftshift(ifft2(ifftshift(fourier_fresnel_forward)));
%    focal_backward = fftshift(ifft2(ifftshift(fourier_fresnel_backward)));
% 
%    imagesc(abs(focal_forward));
%    drawnow;
%    title('Focal Fourier Fresnel forward+backward');
%    colormap(gray(256));
%    colorbar;
    
end