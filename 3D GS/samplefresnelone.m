close all; clear all; clc;
% send a sample code to Chris - use one and see what both Fresnel codes do.

%% Open folder and put all images in arrayofones
myFolder = 'C:\Users\yannz\OneDrive\Documents\Imperial\Year 4 project\Yann''s codes\3D GS\3D pictures\onetoone';
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
  arrayofones{k} = imread(fullFileName);
  
  a{k} = double(arrayofones{k}); % put images into new Array for processing purposes
  a{k} = fftshift(ifft2(fftshift(a{k}))); % A is now an array with 9 elements with phase and amplitude info
  
  subplot(1,2,1);
  imshow(abs(a{k})); % display image. Works outside of loop
  subplot(1,2,2);
  imshow(angle(a{k}));
  drawnow; % force display to update immediately.
end

%% Test for one single jpg

one = a{1};
one = double(one);

comparefresnel(one,100,0.682,0.39,0.39); % no fft2

one_ifft=fftshift(ifft2(fftshift(one))); % apply ifft2
one_fft=fftshift(fft2(fftshift(one))); % apply fft2

comparefresnel(one_fft,100,0.682,0.39,0.39);
comparefresnel(one_ifft,100,0.682,0.39,0.39);