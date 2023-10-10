function registerImages(app)



% Registration of multi-echo images

imagesIn = app.images;
complexImagesIn = app.complexImages;

[nEchoes,~,~,nrSlices] = size(imagesIn);

app.EstimatedRegTimeViewField.Value = 'Calculating ...';
app.TextMessage('Image registration ...');

try

    % Temp directory for storing registration files
    if ispc
        outputDir = 'C:\tmp\';
        if ~exist(outputDir, 'dir')
            mkdir(outputDir);
        end
    else
        outputDir = [];
    end

    [~,elastix_version] = system('elastix --version');
    [~,transformix_version] = system('transformix --version');
    app.TextMessage(elastix_version);
    app.TextMessage(transformix_version);

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

    % Timing parameters
    elapsedTime = 0;
    totalNumberOfSteps = nrSlices*(nEchoes-1);
    app.RegProgressGauge.Value = 0;
    app.abortRegFlag = false;
    cnt = 1;

    slice = 0;

    while slice<nrSlices && ~app.abortRegFlag

        slice = slice + 1;

        echo = 1;

        while echo<nEchoes  && ~app.abortRegFlag

            echo = echo + 1;

            tic;

            % Fixed and moving image
            image0 = squeeze(imagesIn(1,:,:,slice));
            image1 = squeeze(imagesIn(echo,:,:,slice));
            
            imageReal = real(squeeze(complexImagesIn(echo,:,:,slice)));
            imageImag = imag(squeeze(complexImagesIn(echo,:,:,slice)));

            % Register
            [imageReg,pars] = elastix(app,image1,image0,outputDir,regParFile); 
            
            % Apply also to complex image, real and imaginary part separately
            realImageReg = transformix(imageReal,pars);
            imagImageReg = transformix(imageImag,pars);
            complexImageReg = double(realImageReg) + 1i*double(imagImageReg);

            % New registered images
            imagesIn(echo,:,:,slice) = imageReg;
            complexImagesIn(echo,:,:,slice) = complexImageReg;

            % Update the registration progress gauge
            app.RegProgressGauge.Value = round(100*(cnt/totalNumberOfSteps));

            % Update the timing indicator
            elapsedTime = elapsedTime + toc;
            estimatedtotaltime = elapsedTime * totalNumberOfSteps / cnt;
            timeRemaining = estimatedtotaltime * (totalNumberOfSteps - cnt) / totalNumberOfSteps;
            timeRemaining(timeRemaining<0) = 0;
            app.EstimatedRegTimeViewField.Value = strcat(datestr(seconds(timeRemaining),'MM:SS')," min:sec"); %#ok<*DATST>
            drawnow;

            cnt = cnt+1;

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

    % Timing parameters
    elapsedTime = 0;
    totalNumberOfSteps = nrSlices*(nEchoes-1);
    app.RegProgressGauge.Value = 0;
    app.abortRegFlag = false;
    cnt = 1;

    slice = 0;

    while slice<nrSlices && ~app.abortRegFlag

        slice = slice + 1;

        echo = 1;

        while echo<nEchoes  && ~app.abortRegFlag

            echo = echo + 1;

            tic;

            % Fixed and moving image
            image0 = squeeze(imagesIn(1,:,:,slice));
            image1 = squeeze(imagesIn(echo,:,:,slice));

            imageReal = real(squeeze(complexImagesIn(echo,:,:,slice)));
            imageImag = imag(squeeze(complexImagesIn(echo,:,:,slice)));

            % Threshold
            threshold = 0.7 * graythresh(mat2gray(image0)) * max(image0(:));
            image0(image0 < threshold) = 0;
            image1(image0 < threshold) = 0;

            % Determine transformation matrix
            pars = imregtform(image1,image0,method,optimizer, metric,'DisplayOptimization',0);

            sameAsInput = affineOutputView(size(image0),pars,"BoundsStyle","SameAsInput");
            
            % Apply the transformation
            imageReg = imwarp(image1,pars,"OutputView",sameAsInput);

            % Apply also to complex image, real and imaginary part separately
            realImageReg = imwarp(imageReal,pars,"OutputView",sameAsInput);
            imagImageReg = imwarp(imageImag,pars,"OutputView",sameAsInput);
            complexImageReg = double(realImageReg) + 1i*double(imagImageReg);

            % New registered image
            imagesIn(echo,:,:,slice) = imageReg;
            complexImagesIn(echo,:,:,slice) = complexImageReg;

            % Update the registration progress gauge
            app.RegProgressGauge.Value = round(100*(cnt/totalNumberOfSteps));

            % Update the timing indicator
            elapsedTime = elapsedTime + toc;
            estimatedtotaltime = elapsedTime * totalNumberOfSteps / cnt;
            timeRemaining = estimatedtotaltime * (totalNumberOfSteps - cnt) / totalNumberOfSteps;
            timeRemaining(timeRemaining<0) = 0;
            app.EstimatedRegTimeViewField.Value = strcat(datestr(seconds(timeRemaining),'MM:SS')," min:sec"); %#ok<*DATST>
            drawnow;

            cnt = cnt+1;

        end

    end

end

app.EstimatedRegTimeViewField.Value = 'Finished ...';
app.TextMessage('Finished ... ');

% Renormalize
imagesIn = 32767*imagesIn/max(imagesIn(:));

app.images = imagesIn;
app.complexImages = complexImagesIn;

end