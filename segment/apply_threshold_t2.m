function output_mask = apply_threshold(input_image,th)

% creates a binary image from input_image, based on treshold = th

[dimx,dimy] = size(input_image);
mask = zeros(dimx,dimy);

for j=1:dimx
    for k=1:dimy
        if input_image(j,k) > th
            mask(j,k)=1;
        end
    end
end

output_mask = mask;

end