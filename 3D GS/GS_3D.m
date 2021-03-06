%% COMPLETE 3D GS (I hope this works)

clear all; close all; clc;
tic;

%% Read in images of 1-9

myFolder = 'C:\Users\yannz\OneDrive\Documents\Imperial\Year 4 project\Yann''s codes\3D GS\3D pictures\onetoten';
if ~isdir(myFolder) % define folder to look into
  errorMessage = sprintf('Error: The following folder does not exist:\n%s', myFolder);
  uiwait(warndlg(errorMessage));
  return;
end
    
filePattern = fullfile(myFolder, '*.jpg'); % builds a file specification from any file ending in tiff
jpgFiles = dir(filePattern); % dir lists all files in the current folder
imageArray = cell(1,10); % preallocate for speed. Include a dummy 10th dimension to account for false reconstruction

for k = 1:length(jpgFiles)
  baseFileName = jpgFiles(k).name;
  fullFileName = fullfile(myFolder, baseFileName);
  fprintf(1, 'Now reading %s\n', fullFileName);
  imageArray{k} = imread(fullFileName);
  imageArray{k} = double(imageArray{k})/255; % normalize image by dividing double by 255
end

%% Creation of coherent source beam

x = linspace(-10,10,540); % linearly spaced vector for x dimension
                          % (change last value if image dimensions are different)
y = linspace(-10,10,540); % linearly spaced vector for y dimension 
                          % (change last value if image dimensions are different)
[X,Y] = meshgrid(x,y);

% Use Gaussian beam
x0 = 0; % center
y0 = 0; % center
sigma = 10; % beam waist
bp = 1; % beam peak
res = ((X-x0).^2 + (Y-y0).^2)./(2*sigma^2);                     
input_intensity = bp  * exp(-res); % Gaussian beam definitions
% surf(input_intensity);                                         
% shading interp;    

%% Gerchberg Saxton - Fresnel forward, backward, then come back to focal plane

error = [];
planes = length(imageArray);
intensity_array = cell(1,planes); % initialize intensity array for average intensity
amplitude_array = cell(1,planes); % amplitude is intensity * e^(1i*phase)
rng(1);
%average_amplitude = ifft2(ifftshift(imageArray{randi([1 9])})); % first phase is random; then it changes every iteration
average_amplitude = ifft2(ifftshift(imageArray{1})); 

figure;

for iterations = 1:50 % usually converges in less than 10, but increase if more precision is desired
    
  focal_amplitude = abs(input_intensity).*exp(1i*angle(average_amplitude)); % FOCAL PLANE AMPLITUDE
  lens_field = fftshift(fft2(focal_amplitude)); % finding field after "lens"
   
  for m = 1:planes
      fresnel_forward = fresnelpropagateft(lens_field,m,0.6,0.39,0.39); % forward Fresnel propagate
      
      intensity_approximation = abs(fresnel_forward/mean(fresnel_forward(:))); % Get normalized approximation
      intensity_array{m} = intensity_approximation;
      
%       if iterations == 2
%           if m == 2
%             subplot(2,1,1);
%             imagesc(intensity_array{m});
%           end
%       end
%       
%       if iterations == 50
%           if m == 2
%             subplot(2,1,2);
%             imagesc(intensity_array{m});
%           end
%       end
      
      fourier_amplitude = abs(imageArray{m}).*exp(1i*angle(fresnel_forward)); % get amplitude
      
      lens_field = fresnelpropagateft(fourier_amplitude,-m,0.6,0.39,0.39); % propagate back to original field
      
      focal_amplitude = ifft2(ifftshift(lens_field));
      amplitude_array{m} = focal_amplitude;

  end
  
  % Average all ten amplitudes to get phase hologram and new phase value %
  sum_amplitude = amplitude_array{2};
  for i = 3:planes
      sum_amplitude = sum_amplitude + amplitude_array{i};
  end
  focal_average = sum_amplitude/9; % the phase of this amplitude will be plugged back to the start of the next iteration
  average_amplitude = ifft2(ifftshift(focal_average)); % needs to be back in Fourier plane to get phase information
  
  phase_hologram = exp(1i*angle(average_amplitude)); % phase term is the phase hologram
    
  % Average all ten intensitites to get average intensity reconstruction %
  sum_intensity = intensity_array{2};
  for i = 3:planes
      sum_intensity = sum_intensity + intensity_array{i};
  end
  average_intensity = sum_intensity/9;
  
end

%% Display phase hologram and reconstructions

figure;

subplot(2,1,1);
imagesc(abs(fftshift(fft2(phase_hologram))));
colormap(gray(256));
colorbar;
title("Phase hologram after " + iterations + " iterations");

subplot(2,1,2);
imagesc(average_intensity);
colormap(gray(256));
colorbar;
title("Average of all reconstructions after " + iterations + " iterations");
    
toc;

%% Display individual reconstructions

figure;

for i = 2:planes
   imagesc(intensity_array{i});
   title("Reconstruction of plane " + (i-1));
   drawnow;
   pause; % to check planes individually
end