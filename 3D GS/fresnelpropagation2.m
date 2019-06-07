function Aout=fresnelpropagation2( Ain ,z , lambda, dx , dy )
    % Ain = input field/image, z = total distance in pixel units, lambda = pixel size, dx and dy = resolution
    % This method of Fresnel propagation utilises the Fourier definition
    % for it, which is taken from Wikipedia and expanded in my logbook
    
    [nx, ny] = size(Ain); % for example, nx = 540 pixels, ny = 540 pixels
    k = 2*pi / lambda; % wavenumber definition
    
    %dx and dy in distance z ==> step sizes for row vectors
    dx2 = z*lambda/(nx  * dx); % (distance propagated*pixel size)/(x dim size*x resolution)
    dy2 = z*lambda/(ny  * dy); % (distance propagated*pixel size)/(y dim size*y resolution)

    %"coordinates" of matrix Ain = input grid
    x1 = (-nx/2*dx2 + dx2/2 : dx2 : nx/2*dx2 - dx2/2); % row vector with step size dx2
    y1 = (-ny/2*dy2 + dy2/2 : dy2 : ny/2*dy2 - dy2/2); % row vector with step size dy2
    [X1, Y1] = meshgrid(x1 *dx,y1 *dy); %  produces coordinates of rectangular grid (X,Y), from the previously defined row vectors

    %Phase of matrix Ain and FFT of Ain
    AFtPart = Ain.*exp(1i*k*z + (1i*k/(2*z)).*(X1.^2 + Y1.^2)); 
    AFt = fftshift(fft2(ifftshift(AFtPart)));
    
    %"coordinates" of matrix Aout = output grid
    x2 = (-nx/2*dx2 + dx2/2 : dx2 : nx/2*dx2 - dx2/2);
    y2 = (-ny/2*dy2 + dy2/2 : dy2 : ny/2*dy2 - dy2/2);
    [X2, Y2] = meshgrid(x2, y2); % x2 and y2 are not multiplied by resolution
    
    %compare Sf(x,y) in formula
    AFoldCore = (1i*k /(2*pi*z)).*exp((1i*k/(2*z)).*(X2.^2 + Y2.^2));
    Aout = AFoldCore.*AFt; % full Fresnel diffraction
end

% https://uk.mathworks.com/matlabcentral/answers/312801-unexpected-phases-in-fresnel-diffraction-using-fft2
% A = zeros(256,256);
% A(119:138, 119:138) = 100;
% fresnelpropagation2(A, 100, 0.682, 0.39, 0.39); %function call
% imagesc(abs(ans))
% imagesc(angle(ans))