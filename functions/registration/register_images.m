function imagesOut = register_images(app,imagesIn)

% Registration of multi-echo images

[nEchoes,~,~,nrSlices] = size(imagesIn);

[optimizer, metric] = imregconfig('multimodal');

norm = nrSlices*(nEchoes-1);

for slice = 1:nrSlices

    for echo = 2:nEchoes

        % Fixed and moving image
        image0 = squeeze(imagesIn(1,:,:,slice));
        image1 = squeeze(imagesIn(echo,:,:,slice));

        % Threshold
        threshold = graythresh(mat2gray(image0)) * max(image0(:));
        image0(image0 < threshold) = 0;
        image1(image0 < threshold) = 0;

        % Register
        image2 = imregister(image1,image0,'rigid',optimizer, metric,'DisplayOptimization',0);
        imagesIn(echo,:,:,slice) = image2;

        % Progress gauge
        app.RegProgressGauge.Value = round(100*((slice-1)*(nEchoes-1) + (echo-1))/norm);
        drawnow;

    end

end

imagesOut = imagesIn;

end