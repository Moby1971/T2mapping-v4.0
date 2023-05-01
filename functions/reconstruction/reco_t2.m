function images_out = reco(kspace_in,dimy,dimx,ns,ne)


image = zeros(ne,ns,dimx,dimy);

for v = 1:ns
    for w = 1:ne
        kspace = squeeze(kspace_in(w,v,:,:));
        image(w,v,:,:) = abs(bart('fft 7',kspace));
    end
end

images_out = image;

end



