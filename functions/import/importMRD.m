function validFile = importMRD(app)

validFile = false;

if contains(app.mrdFile,"retro") || contains(app.mrdFile,"p2roud")

    % Data reconstructed by P2ROUD or RETROSPECTIVE app
    app.dataFile = [app.mrdImportPath,app.mrdFile];
    app.p2roudFlag = true;
    flist(1).name = app.mrdFile;
    flist(1).folder = app.mrdImportPath;

else

    % Scanner generated MRD file selected, possibly multiple coils
    app.dataFile = [app.mrdImportPath,app.mrdFile];
    mrdstart = extractBefore(app.mrdFile,'_');
    app.mrdFile = [app.mrdImportPath,app.mrdFile];
    flist = dir(fullfile(app.mrdImportPath,[mrdstart,'*.MRD']));

    % check wether the filelist contains already a reconstructed MRD file, remove this one from the list
    if length(flist) > 1
        for i = length(flist):-1:1
            if contains(flist(i).name,'retro') || contains(flist(i).name,'p2roud')
                flist(i) = [];
            end
        end
    end

end

if ~isempty(flist)

    % check for mulit-receiver-coil data
    app.multiCoilFlag = false;
    app.nrCoils = length(flist);
    if app.nrCoils>1
        app.multiCoilFlag = true;
        app.TextMessage('Multi receiver coil data detected ...');
    end

    % load the data
    app.TextMessage('Loading k-space data ...');
    data1 = [];
    for i=1:app.nrCoils
        app.TextMessage(strcat('Loading coil',{' '},num2str(i)));
        [data1{i},app.dimensions,app.parameters] = Get_mrd_3D4(fullfile(flist(i).folder,flist(i).name),'seq','cen'); %#ok<AGROW>
        app.parameters.scanner = "MRSolutions";
    end

    if isfield(app.parameters,'NO_VIEWS_2') && isfield(app.parameters,'EXPERIMENT_ARRAY')

        if app.parameters.NO_VIEWS_2 > 1

            % 3D data = (echoes, dimx, dimy, slices, dynamics)
            app.data3dFlag = true;
            app.data = {};
            for i=1:app.nrCoils

                % Single 3D volume, single echo (not valid)
                if ndims(data1{i}) == 3 && app.parameters.EXPERIMENT_ARRAY == 1
                    app.data{i}(:,:,:,1,1) = permute(data1{i},[3 1 2]);
                end

                % Single 3D volume, multiple echoes
                if ndims(data1{i}) == 4 && app.parameters.EXPERIMENT_ARRAY == 1
                    app.data{i}(:,:,:,:,1) = permute(data1{i},[1 4 2 3]);
                end

                % Multiple 3D volume, single echo (not valid)
                if ndims(data1{i}) == 4 && app.parameters.EXPERIMENT_ARRAY > 1
                    app.data{i}(:,:,:,1,:) = permute(data1{i},[1 4 2 3]);
                end

                % Multiple 3D volume, multiple echoes
                if ndims(data1{i}) == 5 && app.parameters.EXPERIMENT_ARRAY > 1
                    app.data{i}(:,:,:,:,:) = permute(data1{i},[2 5 3 4 1]);
                end

            end

        else

            % 2D data = (echoes, dimx, dimy, slices, dynamics)
            app.data = {};
            app.data3dFlag = false;
            for i=1:app.nrCoils

                % Single slice, single dynamic data
                if ndims(data1{i}) == 3 && app.parameters.EXPERIMENT_ARRAY == 1
                    app.data{i}(:,:,:,1,1) = permute(data1{i},[1 3 2]);
                end

                % Single slice, multi dynamic data
                if ndims(data1{i}) == 4 && app.parameters.EXPERIMENT_ARRAY > 1
                    app.data{i}(:,:,:,1,:) = permute(data1{i},[2 4 3 1]);
                end

                % Multi slice, single dynamic data
                if ndims(data1{i}) == 4 && app.parameters.EXPERIMENT_ARRAY == 1
                    app.data{i}(:,:,:,:,1) = permute(data1{i},[1,4,3,2]);
                end

                % Multi slice, multi dynamic data
                if ndims(data1{i}) == 5 && app.parameters.EXPERIMENT_ARRAY > 1
                    app.data{i}(:,:,:,:,:) = permute(data1{i},[2,5,4,3,1]);
                end

            end

        end

        % Check for multiple echoes
        if isfield(app.parameters,'NO_ECHOES')

            if app.parameters.NO_ECHOES > 1

                app.TextMessage('Multiple echoes detected ...');
                app.DataFileEditField.Value = app.mrdFile;

                % For multi-gradient-echo type sequence
                if contains(app.parameters.PPL,'flash')
                    if ~app.p2roudFlag
                        for i = 1:app.nrCoils
                            for j = 2:2:app.parameters.NO_ECHOES
                                app.data{i}(j,:,:,:,:) = flip(app.data{i}(j,:,:,:,:),2);
                            end
                        end
                    end
                    app.dataType = "grad-echo";
                else
                    for i = 1:app.nrCoils
                        app.data{i} = flip(app.data{i},2);
                    end
                    app.dataType = "spin-echo";
                end

                validFile = true;

            end

        else

            app.dataType = "not-valid";
        
        end

    end

    % Get some parameters from the RPR file
    try
        rprFile = strrep(app.dataFile,'.MRD','.rpr');
        app.rprPars = readRPRfile(app, rprFile);        
    catch
    end

    try
        if isfield(app.rprPars,"ImagingFrequency")
            app.parameters.imagingFrequency = app.rprPars.ImagingFrequency;
        else
            app.parameters.imagingFrequency = 298.05;
            app.TextMessage('WARNING: Field strength unknown, assuming 7T ...');
        end
        app.TextMessage(strcat("Resonance frequency = ",num2str(app.parameters.imagingFrequency)," MHz ..."));
    catch
    end

end


end