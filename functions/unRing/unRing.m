function images = unRing(images)

% params - 3x1 array with [minW maxW nsh]
% nsh discretization of subpixel spaceing (default 20)
% minW  left border of window used for TV computation (default 1)
% maxW  right border of window used for TV computation (default 3)
params = [1 3 20];

% Image dimensions (NE, X, Y, Z, NR)
[nrTE, ~, ~, nrSlices, nrDyn] = size(images);

% unRing
for slice = 1:nrSlices
    for dyn = 1:nrDyn
        for te = 1:nrTE
            images(te,:,:,slice,dyn) = ringRm(double(squeeze(images(te,:,:,slice,dyn))),params);
        end
    end
end

end % unRing