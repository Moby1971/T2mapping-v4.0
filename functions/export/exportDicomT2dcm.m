function exportDicomT2dcm(app, dcmFilesPath)

%------------------------------------------------------------
%
% DICOM EXPORT OF T2 MAPS
% DICOM HEADER INFORMATION AVAILABLE
%
% Gustav Strijkers
% Amsterdam UMC
% g.j.strijkers@amsterdamumc.nl
% Feb 2024
%
%------------------------------------------------------------


% Input
m0map = app.m0map;
t2map = app.t2map;
r2map = app.r2map;
wmap = app.watermap;
fmap = app.fatmap;
parameters = app.parameters;

% Mulitply T2, water and fat map values with this factor to prevent discretization
scaling = 100; 

% Phase orientation correction
if isfield(parameters, 'PHASE_ORIENTATION')
    if parameters.PHASE_ORIENTATION == 1
        t2map = permute(rot90(permute(t2map,[2 1 3 4]),1),[2 1 3 4]);
        m0map = permute(rot90(permute(m0map,[2 1 3 4]),1),[2 1 3 4]);
        r2map = permute(rot90(permute(r2map,[2 1 3 4]),1),[2 1 3 4]);
        wmap = permute(rot90(permute(wmap,[2 1 3 4]),1),[2 1 3 4]);
        fmap = permute(rot90(permute(fmap,[2 1 3 4]),1),[2 1 3 4]);
    end
end

[~,~,dimz,dimd] = size(t2map);
dimr = parameters.NO_ECHOES; % number of echoes

% List of dicom file names
flist = dir(fullfile(dcmFilesPath,'*.dcm'));
files = sort({flist.name});

% Generate new dicom headers
for dynamic = 1:dimd

    for slice = 1:dimz

        % Read the dicom header
        dcmHeader{slice,dynamic} = dicominfo(strcat(dcmFilesPath,filesep,files{ (dynamic-1)*dimz*dimr + (slice-1)*dimr + 1 })); %#ok<*AGROW>

        % Changes some tags
        dcmHeader{slice,dynamic}.ImageType = 'DERIVED\RELAXATION\';
        dcmHeader{slice,dynamic}.InstitutionName = 'Amsterdam UMC';
        dcmHeader{slice,dynamic}.InstitutionAddress = 'Amsterdam, Netherlands';
        dcmHeader{slice,dynamic}.TemporalPositionIdentifier = dynamic;
        dcmHeader{slice,dynamic}.NumberOfTemporalPositions = dimd;
        dcmHeader{slice,dynamic}.TemporalResolution = parameters.TotalAcquisitionTime/dimd;
        
    end

end

% Create new directory
directory = strcat(app.dicomExportPath,filesep,'DICOM',filesep);
ready = false;
cnt = 1;
while ~ready
    folderName = strcat(directory,app.tag,'T2',filesep,num2str(cnt),filesep);
    if ~exist(folderName, 'dir')
        mkdir(folderName);
        ready = true;
    end
    cnt = cnt + 1;
end

dir41 = 'T2';
dir42 = 'M0';
dir43 = 'R2';
dir44 = 'Water';
dir45 = 'Fat';

output_directory1 = strcat(folderName,dir41);
if ~exist(output_directory1, 'dir') 
    mkdir(output_directory1); 
end
delete(strcat(output_directory1,filesep,'*'));

output_directory2 = strcat(folderName,dir42);
if ~exist(output_directory2, 'dir')
    mkdir(output_directory2); 
end
delete(strcat(output_directory2,filesep,'*'));

output_directory3 = strcat(folderName,dir43);
if ~exist(output_directory3, 'dir')
    mkdir(output_directory3); 
end
delete(strcat(output_directory3,filesep,'*'));

if app.validWaterFatFlag

    output_directory4 = strcat(folderName,dir44);
    if ~exist(output_directory4, 'dir')
        mkdir(output_directory4);
    end
    delete(strcat(output_directory4,filesep,'*'));

    output_directory5 = strcat(folderName,dir45);
    if ~exist(output_directory5, 'dir')
        mkdir(output_directory5);
    end
    delete(strcat(output_directory5,filesep,'*'));

end


% Export the T2 map DICOMS
seriesInstanceID = dicomuid;
for dynamic = 1:dimd

    for slice = 1:dimz

        dcmHeader{slice,dynamic}.ProtocolName = 'T2-map';
        dcmHeader{slice,dynamic}.SequenceName = 'T2-map';
        dcmHeader{slice,dynamic}.SeriesInstanceUID = seriesInstanceID;
        dcmHeader{slice,dynamic}.ImageType = 'DERIVED\RELAXATION\T2';

        fn = ['0000',num2str(slice)];
        fn = fn(size(fn,2)-4:size(fn,2));

        dn = ['0000',num2str(dynamic)];
        dn = dn(size(dn,2)-4:size(dn,2));

        fname = [output_directory1,filesep,'T2map-slice',fn,'-dynamic',dn,'.dcm'];
       
        image = rot90(squeeze(cast(round(scaling*t2map(:,:,slice,dynamic)),'uint16')));

        dicomwrite(image, fname, dcmHeader{slice,dynamic});

    end

end



% Export the M0 map Dicoms
m0map = round(32767*m0map/max(m0map(:)));
seriesInstanceID = dicomuid;
for dynamic = 1:dimd

    for slice=1:dimz

        dcmHeader{slice,dynamic}.ProtocolName = 'M0-map';
        dcmHeader{slice,dynamic}.SequenceName = 'M0-map';
        dcmHeader{slice,dynamic}.SeriesInstanceUID = seriesInstanceID;
        dcmHeader{slice,dynamic}.ImageType = 'DERIVED\RELAXATION\M0';

        fn = ['0000',num2str(slice)];
        fn = fn(size(fn,2)-4:size(fn,2));
        dn = ['0000',num2str(dynamic)];
        dn = dn(size(dn,2)-4:size(dn,2));

        fname = [output_directory2,filesep,'M0map-slice',fn,'-dynamic',dn,'.dcm'];
        image = rot90(squeeze(cast(round(m0map(:,:,slice,dynamic)),'uint16')));
    
        dicomwrite(image, fname, dcmHeader{slice,dynamic});

    end

end



% Export the  R^2 map Dicoms
seriesInstanceID = dicomuid;
for dynamic = 1:dimd

    for slice=1:dimz

        dcmHeader{slice,dynamic}.ProtocolName = 'R2-map';
        dcmHeader{slice,dynamic}.SequenceName = 'R2-map';
        dcmHeader{slice,dynamic}.SeriesInstanceUID = seriesInstanceID;
        dcmHeader{slice,dynamic}.ImageType = 'DERIVED\RELAXATION\R2';

        fn = ['0000',num2str(slice)];
        fn = fn(size(fn,2)-4:size(fn,2));
        dn = ['0000',num2str(dynamic)];
        dn = dn(size(dn,2)-4:size(dn,2));

        fname = [output_directory3,filesep,'R2map-slice',fn,'-dynamic',dn,'.dcm'];
        image = rot90(squeeze(cast(round(scaling*r2map(:,:,slice,dynamic)),'uint16')));
     
        dicomwrite(image, fname, dcmHeader{slice,dynamic});

    end

end



% Water / fat images
if app.validWaterFatFlag

    seriesInstanceID = dicomuid;
    for dynamic = 1:dimd

        for slice=1:dimz

            dcmHeader{slice,dynamic}.ProtocolName = 'Water-map';
            dcmHeader{slice,dynamic}.SequenceName = 'Water-map';
            dcmHeader{slice,dynamic}.SeriesInstanceUID = seriesInstanceID;
            dcmHeader{slice,dynamic}.ImageType = 'DERIVED\RELAXATION\R2';

            fn = ['0000',num2str(slice)];
            fn = fn(size(fn,2)-4:size(fn,2));
            dn = ['0000',num2str(dynamic)];
            dn = dn(size(dn,2)-4:size(dn,2));

            fname = [output_directory4,filesep,'Watermap-slice',fn,'-dynamic',dn,'.dcm'];
            image = rot90(squeeze(cast(round(scaling*wmap(:,:,slice,dynamic)),'uint16')));

            dicomwrite(image, fname, dcmHeader{slice,dynamic});

        end

    end

    seriesInstanceID = dicomuid;
    for dynamic = 1:dimd

        for slice=1:dimz

            dcmHeader{slice,dynamic}.ProtocolName = 'Fat-map';
            dcmHeader{slice,dynamic}.SequenceName = 'Fat-map';
            dcmHeader{slice,dynamic}.SeriesInstanceUID = seriesInstanceID;
            dcmHeader{slice,dynamic}.ImageType = 'DERIVED\RELAXATION\R2';

            fn = ['0000',num2str(slice)];
            fn = fn(size(fn,2)-4:size(fn,2));
            dn = ['0000',num2str(dynamic)];
            dn = dn(size(dn,2)-4:size(dn,2));

            fname = [output_directory5,filesep,'Fatmap-slice',fn,'-dynamic',dn,'.dcm'];
            image = rot90(squeeze(cast(round(scaling*fmap(:,:,slice,dynamic)),'uint16')));

            dicomwrite(image, fname, dcmHeader{slice,dynamic});

        end

    end

end


end