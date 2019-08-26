function images_out = register_images(app,images_in)


[ne,ns,~,~] = size(images_in);

[optimizer, metric] = imregconfig('multimodal');

norm = ne*(ns-1);

for i = 1:ne
    
    for j = 2:ns
        
        image0 = squeeze(images_in(1,j,:,:));
        image1 = squeeze(images_in(i,j,:,:));
        
        max0 = max(image0(:));
        max1 = max(image1(:));
        
        [image2] = imregister(image1/max1,image0/max0,'similarity',optimizer, metric,'DisplayOptimization',0);
        
        images_in(i,j,:,:) = image2*max1;
        
        app.RegProgressGauge.Value = round(100*((i-1)*(ns-1) + (j-1))/norm);
        drawnow;
        
    end
    
end

images_out = images_in;

end