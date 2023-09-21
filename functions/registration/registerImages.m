function registerImages(app)

% Registration of multi-echo images

imagesIn = app.images;

[nEchoes,~,~,nrSlices] = size(imagesIn);


app.TextMessage('Image registration ...');

try

    switch app.RegistrationDropDown.Value
        case 'Translation'
            fileName = 'regParsTrans.txt';
        case 'Rigid'
            fileName = 'regParsRigid.txt';
        case 'Affine'
            fileName = 'regParsAffine.txt';
        case 'B-Spline'
            fileName = 'regParsBSpline.txt';
    end
    [regParDir , ~] = fileparts(which(fileName));
    regParFile = strcat(regParDir,filesep,fileName);

    norm = nrSlices*(nEchoes-1);

    slice = 0;

    while slice<nrSlices && ~app.abortRegFlag
    
        slice = slice + 1;

        echo = 1;

        while echo<nEchoes  && ~app.abortRegFlag

            echo = echo + 1;

            % Fixed and moving image
            image0 = squeeze(imagesIn(1,:,:,slice));
            image1 = squeeze(imagesIn(echo,:,:,slice));

            % Register
            image2 = elastix(image1,image0,[],regParFile);
            
            % New registered image
            imagesIn(echo,:,:,slice) = image2;

            % Progress gauge
            app.RegProgressGauge.Value = round(100*((slice-1)*(nEchoes-1) + (echo-1))/norm);
            drawnow;

        end

    end


catch ME

    app.TextMessage(ME.message)

    % Matlab

    app.TextMessage('Elastix failed, registering images using Matlab ...');

    [optimizer, metric] = imregconfig('multimodal');

    switch app.RegistrationDropDown.Value
        case 'Translation'
            method = 'translation';
        case 'Rigid'
            method = 'rigid';
        case 'Affine'
            method = 'similarity';
        case 'B-Spline'
            method = 'affine';
    end

    norm = nrSlices*(nEchoes-1);

    slice = 0;

    while slice<nrSlices && ~app.abortRegFlag

        slice = slice + 1;

        echo = 1;

        while echo<nEchoes  && ~app.abortRegFlag

            echo = echo + 1;

            % Fixed and moving image
            image0 = squeeze(imagesIn(1,:,:,slice));
            image1 = squeeze(imagesIn(echo,:,:,slice));

            % Threshold
            threshold = graythresh(mat2gray(image0)) * max(image0(:));
            image0(image0 < threshold) = 0;
            image1(image0 < threshold) = 0;

            % Register
            image2 = imregister(image1,image0,method,optimizer, metric,'DisplayOptimization',0);

            % New registered image
            imagesIn(echo,:,:,slice) = image2;

            % Progress gauge
            app.RegProgressGauge.Value = round(100*((slice-1)*(nEchoes-1) + (echo-1))/norm);
            drawnow;

        end

    end

end

app.images = imagesIn;

end