function images = PCAdenoise(images,w)

% Image dimensions (NE, X, Y, Z, NR)
[~, ~, ~, nrSlices, nrDynamics] = size(images);

im = permute(images,[2 3 1 4 5]);

% Denoising window
window = [w w];
if window(1) > size(images,2)/2
    window(1) = round(size(images,2)/2);
end
if window(2) > size(images,3)/2
    window(2) = round(size(images,3)/2);
end

% Loop over all dynamics, echo times
im1 = zeros(size(im));
for dyn = 1:nrDynamics
    for slice = 1:nrSlices  
        im1(:,:,:,slice,dyn) = denoise(double(squeeze(im(:,:,:,slice,dyn))),window);
    end
end

images = ipermute(im1,[2 3 1 4 5]);

end % PCAdenoise