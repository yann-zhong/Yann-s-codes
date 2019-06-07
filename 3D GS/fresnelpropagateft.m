    function out = fresnelpropagateft(U0, z, lambda, dx, dy)
    % input is U0 at wavelength lambda and returns field U after distance z
    % using Fresnel approximation. dx and dy are spatial resolutions.
    
    k = 2*pi/lambda; % wavenumber
    [nx,ny] = size(U0); % nx = x dimension of U0, ny = y dimension of U0.
    
    Lx = dx*nx; 
    Ly = dy*ny;
    
    dfx = 1./Lx; % ./ is element wise division A./B divides each element of A by the corresponding element of B
    dfy = 1./Ly;
    
    u = ones(nx,1)*((1:nx)-nx/2)*dfx;
    v = ((1:ny)-ny/2)'*ones(1,ny)*dfy;   

    O = fftshift(fft2(ifftshift((U0))));

    H = exp(1i*k*z).*exp(-1i*pi*lambda*z*(u.^2+v.^2));  

    out = fftshift(ifft2(ifftshift(O.*H))); % .* is element wise multiplication. Element 1 of O is multiplied by element 1 of H, etc.
    
end

% https://stackoverflow.com/questions/20971945/fresnel-diffraction-in-two-steps