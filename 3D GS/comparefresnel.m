function comparefresnel(U0, z, lambda, dx, dy)
    % input is U0 at wavelength lambda and returns field U after distance z
    % using Fresnel approximation. dx and dy are spatial resolutions.
    
    % close all;
    figure;
    subplot(3,2,1);
    imagesc(abs(U0));
    title('Amplitude/intensity of input plane');
    subplot(3,2,2);
    imagesc(angle(U0));
    title('Phase of input plane');
    
    %%
    k = 2*pi/lambda; % wavenumber
    [nx,ny] = size(U0); % nx = x dimension of U0, ny = y dimension of U0.
    
    Lx = dx*nx; 
    Ly = dy*ny;
    
    dfx = 1./Lx; % ./ is element wise division A./B divides each element of A by the corresponding element of B
    dfy = 1./Ly;
    
    u = ones(nx,1)*((1:nx)-nx/2)*dfx;
    v = ((1:ny)-ny/2)'*ones(1,ny)*dfy;   

    O = fftshift(fft2(U0));

    H = exp(1i*k*z).*exp(-1i*pi*lambda*z*(u.^2+v.^2));  

    out = ifft2(ifftshift(O.*H)); % .* is element wise multiplication. Element 1 of O is multiplied by element 1 of H, etc.
    
    %%
    [nx, ny] = size(U0);
    k = 2*pi / lambda;
    
    %dx and dy in distance z
    dx2 = z*lambda/(nx  * dx);
    dy2 = z*lambda/(ny  * dy);

    %"coordinates" of matrix Ain
    x1 = (-nx/2*dx2 + dx2/2 : dx2 : nx/2*dx2 - dx2/2);
    y1 = (-ny/2*dy2 + dy2/2 : dy2 : ny/2*dy2 - dy2/2);
    [X1, Y1] = meshgrid(x1 *dx,y1 *dy);

    %Phase of matrix Ain and FFT of Ain
    AFtPart = U0.*exp(1i*k*z + (1i*k/(2*z)).*(X1.^2 + Y1.^2)); 
    AFt = fftshift(fft2(ifftshift(AFtPart)));
    
    %"coordinates" of matrix Aout
    x2 = (-nx/2*dx2 + dx2/2 : dx2 : nx/2*dx2 - dx2/2);
    y2 = (-ny/2*dy2 + dy2/2 : dy2 : ny/2*dy2 - dy2/2);
    [X2, Y2] = meshgrid(x2, y2);
    
    %compare Sf(x,y) in formula
    AFoldCore = (1i*k /(2*pi*z)).*exp((1i*k/(2*z)).*(X2.^2 + Y2.^2));
    Aout = AFoldCore.*AFt;
    
    %%
    subplot(3,2,3);
    imagesc(abs(out));
    %colorbar;
    title('Amplitude, method 1');
    
    subplot(3,2,4);
    imagesc(angle(out));
    %colorbar;
    title('Phase, method 1');
    
    subplot(3,2,5);
    imagesc(abs(Aout));
    %colorbar;
    title('Amplitude, method 2');
    
    subplot(3,2,6);
    imagesc(angle(Aout));
    %colorbar;
    title('Phase, method 2');
    
end

%%
% A = zeros(256,256);
% A(119:138, 119:138) = 100;
% comparefresnel(A, 100, 0.682, 0.39, 0.39);