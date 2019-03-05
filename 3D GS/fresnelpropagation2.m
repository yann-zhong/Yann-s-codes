function Aout=fresnelpropagation2( Ain ,z , lambda, dx , dy )
    
    [nx, ny] = size(Ain);
    k = 2*pi / lambda;
    
    %dx and dy in distance z
    dx2 = z*lambda/(nx  * dx);
    dy2 = z*lambda/(ny  * dy);

    %"coordinates" of matrix Ain
    x1 = (-nx/2*dx2 + dx2/2 : dx2 : nx/2*dx2 - dx2/2);
    y1 = (-ny/2*dy2 + dy2/2 : dy2 : ny/2*dy2 - dy2/2);
    [X1, Y1] = meshgrid(x1 *dx,y1 *dy);

    %Phase of matrix Ain and FFT of Ain
    AFtPart = Ain.*exp(1i*k*z + (1i*k/(2*z)).*(X1.^2 + Y1.^2)); 
    AFt = fftshift(fft2(ifftshift(AFtPart)));
    
    %"coordinates" of matrix Aout
    x2 = (-nx/2*dx2 + dx2/2 : dx2 : nx/2*dx2 - dx2/2);
    y2 = (-ny/2*dy2 + dy2/2 : dy2 : ny/2*dy2 - dy2/2);
    [X2, Y2] = meshgrid(x2, y2);
    
    %compare Sf(x,y) in formula
    AFoldCore = (1i*k /(2*pi*z)).*exp((1i*k/(2*z)).*(X2.^2 + Y2.^2));
    Aout = AFoldCore.*AFt;
end

% https://uk.mathworks.com/matlabcentral/answers/312801-unexpected-phases-in-fresnel-diffraction-using-fft2
% A = zeros(256,256);
% A(119:138, 119:138) = 100;
% fresnelpropagation2(A, 100, 0.682, 0.39, 0.39); %function call
% imagesc(abs(ans))
% imagesc(angle(ans))