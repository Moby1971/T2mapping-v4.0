function imagesOut = registerImages(app,imagesIn)

% Registration of multi-echo images

[nEchoes,~,~,nrSlices] = size(imagesIn);


app.TextMessage('Image registration ...');

try

    % Elastix

    if ismac || isunix
        [~, result] = system('echo -n $PATH');
        result = [result ':/usr/local/bin:/usr/local/lib'];
        setenv('PATH', result);
    end

    regParDir = dir(which('regPars.txt'));
    regParFile = strcat(regParDir.folder,filesep,'regPars.txt');

    norm = nrSlices*(nEchoes-1);

    for slice = 1:nrSlices

        for echo = 2:nEchoes

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

    app.TextMessage('Elastix failed, using Matlab ...');

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

            % New registered image
            imagesIn(echo,:,:,slice) = image2;

            % Progress gauge
            app.RegProgressGauge.Value = round(100*((slice-1)*(nEchoes-1) + (echo-1))/norm);
            drawnow;

        end

    end

end

imagesOut = imagesIn;

end