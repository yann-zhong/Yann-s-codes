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

for k = 1:length(tiffFiles) % 1 - 360. If less data is needed, change length(tiffFiles) to desired value
  baseFileName = tiffFiles(k).name;
  fullFileName = fullfile(myFolder, baseFileName);
  fprintf(1, 'Now reading %s\n', fullFileName);
  
  %%% Uncomment the following section if not putting images in an array.
  
  %imageArray = imread(fullFileName);
  %imageArray = rgb2gray(imageArray); % removes the 512*512*3 - the 3 is colour
  %imshow(imageArray); % display image.
  
  %%% End of section

  imageArray{k} = imread(fullFileName);
  imageArray{k} = rgb2gray(imageArray{k}); % removes the 512*512*3 - the 3 is colour
% However removing the third dimension doesn't allow for visualization in
% the volume viewer
  imshow(imageArray{k}); % display image. Works outside of loop
  drawnow; % force display to update immediately.
end