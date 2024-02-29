function exportDicomT2(app, directory)

%------------------------------------------------------------
%
% DICOM EXPORT OF T2 MAPS
% DICOM HEADER INFORMATION NOT AVAILABLE
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


% Mulitply T2, water, and fat values with this factor to prevent discretization
scaling = 100;


% Create new directory
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


[dimx,dimy,dimz,dimd] = size(t2map);

% export the dicom images
dcmid = dicomuid;   % unique identifier
dcmid = dcmid(1:50);

seriesInstanceID = dicomuid;
for dynamic = 1:dimd

    for slice = 1:dimz

        dcmHeader = generateDicomHeaderT2(parameters,slice,dynamic,dimx,dimy,dimz,dimd,dcmid);
        dcmHeader.ProtocolName = 'T2-map';
        dcmHeader.SequenceName = 'T2-map';
        dcmHeader.SeriesInstanceUID = seriesInstanceID;

        fn = strcat('0000',num2str(slice));
        fn = fn(size(fn,2)-4:size(fn,2));
        dn = strcat('0000',num2str(dynamic));
        dn = dn(size(dn,2)-4:size(dn,2));

        fname = strcat(output_directory1,filesep,'T2map-slice',fn,'-dynamic',dn,'.dcm');
        image = rot90(squeeze(cast(round(scaling*t2map(:,:,slice,dynamic)),'uint16')));
        dicomwrite(image, fname, dcmHeader);

    end

end


m0map = round(32767*m0map/max(m0map(:)));
seriesInstanceID = dicomuid;
for dynamic = 1:dimd

    for slice=1:dimz

        dcmHeader = generateDicomHeaderT2(parameters,slice,dynamic,dimx,dimy,dimz,dimd,dcmid);
        dcmHeader.ProtocolName = 'M0-map';
        dcmHeader.SequenceName = 'M0-map';
        dcmHeader.SeriesInstanceUID = seriesInstanceID;

        fn = strcat('0000',num2str(slice));
        fn = fn(size(fn,2)-4:size(fn,2));
        dn = strcat('0000',num2str(dynamic));
        dn = dn(size(dn,2)-4:size(dn,2));

        fname = strcat(output_directory2,filesep,'M0map-slice',fn,'-dynamic',dn,'.dcm');
        image = rot90(squeeze(cast(round(m0map(:,:,slice,dynamic)),'uint16')));
        dicomwrite(image, fname, dcmHeader);

    end

end


seriesInstanceID = dicomuid;
for dynamic = 1:dimd

    for slice=1:dimz

        dcmHeader = generateDicomHeaderT2(parameters,slice,dynamic,dimx,dimy,dimz,dimd,dcmid);
        dcmHeader.ProtocolName = 'R2-map';
        dcmHeader.SequenceName = 'R2-map';
        dcmHeader.SeriesInstanceUID = seriesInstanceID;

        fn = strcat('0000',num2str(slice));
        fn = fn(size(fn,2)-4:size(fn,2));
        dn = strcat('0000',num2str(dynamic));
        dn = dn(size(dn,2)-4:size(dn,2));

        fname = strcat(output_directory3,filesep,'R2map-slice',fn,'-dynamic',dn,'.dcm');
        image = rot90(squeeze(cast(round(scaling*r2map(:,:,slice,dynamic)),'uint16')));
        dicomwrite(image, fname, dcmHeader);

    end

end


if app.validWaterFatFlag

    seriesInstanceID = dicomuid;
    for dynamic = 1:dimd

        for slice = 1:dimz

            dcmHeader = generateDicomHeaderT2(parameters,slice,dynamic,dimx,dimy,dimz,dimd,dcmid);
            dcmHeader.ProtocolName = 'Water-map';
            dcmHeader.SequenceName = 'Water-map';
            dcmHeader.SeriesInstanceUID = seriesInstanceID;

            fn = strcat('0000',num2str(slice));
            fn = fn(size(fn,2)-4:size(fn,2));
            dn = strcat('0000',num2str(dynamic));
            dn = dn(size(dn,2)-4:size(dn,2));

            fname = strcat(output_directory4,filesep,'Watermap-slice',fn,'-dynamic',dn,'.dcm');
            image = rot90(squeeze(cast(round(scaling*wmap(:,:,slice,dynamic)),'uint16')));
            dicomwrite(image, fname, dcmHeader);

        end

    end

    seriesInstanceID = dicomuid;
    for dynamic = 1:dimd

        for slice = 1:dimz

            dcmHeader = generateDicomHeaderT2(parameters,slice,dynamic,dimx,dimy,dimz,dimd,dcmid);
            dcmHeader.ProtocolName = 'Fat-map';
            dcmHeader.SequenceName = 'Fat-map';
            dcmHeader.SeriesInstanceUID = seriesInstanceID;

            fn = strcat('0000',num2str(slice));
            fn = fn(size(fn,2)-4:size(fn,2));
            dn = strcat('0000',num2str(dynamic));
            dn = dn(size(dn,2)-4:size(dn,2));

            fname = strcat(output_directory5,filesep,'Fatmap-slice',fn,'-dynamic',dn,'.dcm');
            image = rot90(squeeze(cast(round(scaling*fmap(:,:,slice,dynamic)),'uint16')));
            dicomwrite(image, fname, dcmHeader);

        end

    end

end


    function dicom_header = generateDicomHeaderT2(parameters,slice,dynamic,dimx,dimy,dimz,dimd,dcmid)

        % GENERATES DICOM HEADER FOR EXPORT
        %
        % parameters = parameters from MRD file
        % i = current image/slice number
        % dimy = y dimension (phase encoding, views)
        % dimx = x dimension (readout, samples)
        %

        try
            studyname = str2num(parameters.filename(end-9:end-6)); %#ok<ST2NM>
        catch
            studyname = 111;
        end

        aspectratio = parameters.FOVf/8;  % apect ratio, needs to be checked

        pixelx = parameters.FOV/dimx;
        pixely = parameters.FOV/dimy;

        fn = ['0000',num2str(slice)];
        fn = fn(size(fn,2)-4:size(fn,2));
        dn = ['0000',num2str(dynamic)];
        dn = dn(size(dn,2)-4:size(dn,2));
        fname = ['T2-slice',fn,'-dynamic',dn,'.dcm'];

        dt = datetime(parameters.date,'InputFormat','dd-MMM-yyyy HH:mm:ss');
        year = num2str(dt.Year);
        month = ['0',num2str(dt.Month)]; month = month(end-1:end);
        day = ['0',num2str(dt.Day)]; day = day(end-1:end);
        date = [year,month,day];

        hour = ['0',num2str(dt.Hour)]; hour = hour(end-1:end);
        minute = ['0',num2str(dt.Minute)]; minute = minute(end-1:end);
        seconds = ['0',num2str(dt.Second)]; seconds = seconds(end-1:end);
        time = [hour,minute,seconds];

        dcmhead.Filename = fname;
        dcmhead.FileModDate = parameters.date;
        dcmhead.FileSize = dimy*dimx*2;
        dcmhead.Format = 'DICOM';
        dcmhead.FormatVersion = 3;
        dcmhead.Width = dimy;
        dcmhead.Height = dimx;
        dcmhead.BitDepth = 15;
        dcmhead.ColorType = 'grayscale';
        dcmhead.FileMetaInformationGroupLength = 178;
        dcmhead.FileMetaInformationVersion = uint8([0, 1])';
        dcmhead.MediaStorageSOPClassUID = '1.2.840.10008.5.1.4.1.1.4';
        dcmhead.TransferSyntaxUID = '1.2.840.10008.1.2.1';
        dcmhead.ImplementationClassUID = '1.2.826.0.9717382.3.0.3.6.0';
        dcmhead.ImplementationVersionName = 'OFFIS_DCMTK_360';
        dcmhead.SpecificCharacterSet = 'ISO_IR 100';
        dcmhead.ImageType = 'DERIVED\RELAXATION\';
        dcmhead.SOPClassUID = '1.2.840.10008.5.1.4.1.1.4';
        dcmhead.StudyDate = date;
        dcmhead.SeriesDate = date;
        dcmhead.AcquisitionDate = date;
        dcmhead.StudyTime = time;
        dcmhead.SeriesTime = time;
        dcmhead.AcquisitionTime = time;
        dcmhead.ContentTime = time;
        dcmhead.Modality = 'MR';
        dcmhead.Manufacturer = 'MR Solutions Ltd';
        dcmhead.InstitutionName = 'Amsterdam UMC';
        dcmhead.InstitutionAddress = 'Amsterdam, Netherlands';
        dcmhead.ReferringPhysicianName.FamilyName = 'Amsterdam UMC preclinical MRI';
        dcmhead.ReferringPhysicianName.GivenName = '';
        dcmhead.ReferringPhysicianName.MiddleName = '';
        dcmhead.ReferringPhysicianName.NamePrefix = '';
        dcmhead.ReferringPhysicianName.NameSuffix = '';
        dcmhead.StationName = 'MRI Scanner';
        dcmhead.StudyDescription = 'Relaxation time mapping';
        dcmhead.SeriesDescription = '';
        dcmhead.InstitutionalDepartmentName = 'Amsterdam UMC preclinical MRI';
        dcmhead.PhysicianOfRecord.FamilyName = 'Amsterdam UMC preclinical MRI';
        dcmhead.PhysicianOfRecord.GivenName = '';
        dcmhead.PhysicianOfRecord.MiddleName = '';
        dcmhead.PhysicianOfRecord.NamePrefix = '';
        dcmhead.PhysicianOfRecord.NameSuffix = '';
        dcmhead.PerformingPhysicianName.FamilyName = 'Amsterdam UMC preclinical MRI';
        dcmhead.PerformingPhysicianName.GivenName = '';
        dcmhead.PerformingPhysicianName.MiddleName = '';
        dcmhead.PerformingPhysicianName.NamePrefix = '';
        dcmhead.PerformingPhysicianName.NameSuffix = '';
        dcmhead.PhysicianReadingStudy.FamilyName = 'Amsterdam UMC preclinical MRI';
        dcmhead.PhysicianReadingStudy.GivenName = '';
        dcmhead.PhysicianReadingStudy.MiddleName = '';
        dcmhead.PhysicianReadingStudy.NamePrefix = '';
        dcmhead.PhysicianReadingStudy.NameSuffix = '';
        dcmhead.OperatorName.FamilyName = 'manager';
        dcmhead.AdmittingDiagnosesDescription = '';
        dcmhead.ManufacturerModelName = 'MRS7024';
        dcmhead.ReferencedSOPClassUID = '';
        dcmhead.ReferencedSOPInstanceUID = '';
        dcmhead.ReferencedFrameNumber = [];
        dcmhead.DerivationDescription = '';
        dcmhead.FrameType = '';
        dcmhead.PatientName.FamilyName = 'Amsterdam UMC preclinical MRI';
        dcmhead.PatientID = app.tag;
        dcmhead.PatientBirthDate = date;
        dcmhead.PatientBirthTime = '';
        dcmhead.PatientSex = 'F';
        dcmhead.OtherPatientID = '';
        dcmhead.OtherPatientName.FamilyName = 'Amsterdam UMC preclinical MRI';
        dcmhead.OtherPatientName.GivenName = '';
        dcmhead.OtherPatientName.MiddleName = '';
        dcmhead.OtherPatientName.NamePrefix = '';
        dcmhead.OtherPatientName.NameSuffix = '';
        dcmhead.PatientAge = '1';
        dcmhead.PatientSize = [];
        dcmhead.PatientWeight = 0.0300;
        dcmhead.Occupation = '';
        dcmhead.AdditionalPatientHistory = '';
        dcmhead.PatientComments = '';
        dcmhead.BodyPartExamined = '';
        dcmhead.SequenceName = parameters.PPL;
        dcmhead.SliceThickness = parameters.SLICE_THICKNESS;
        dcmhead.KVP = 0;
        dcmhead.RepetitionTime = parameters.tr;
        dcmhead.EchoTime = parameters.te;
        dcmhead.InversionTime = 0;
        dcmhead.NumberOfAverages = parameters.NO_AVERAGES;
        dcmhead.ImagedNucleus = '1H';
        dcmhead.MagneticFieldStrength = 7;
        dcmhead.SpacingBetweenSlices = parameters.SLICE_SEPARATION/parameters.SLICE_INTERLEAVE;
        dcmhead.EchoTrainLength = parameters.NO_ECHOES;
        dcmhead.DeviceSerialNumber = '0034';
        dcmhead.PlateID = '';
        dcmhead.SoftwareVersion = '1.0.0.0';
        dcmhead.ProtocolName = '';
        dcmhead.SpatialResolution = [];
        dcmhead.TriggerTime = 0;
        dcmhead.DistanceSourceToDetector = [];
        dcmhead.DistanceSourceToPatient = [];
        dcmhead.FieldofViewDimensions = [aspectratio*parameters.FOV parameters.FOV parameters.SLICE_THICKNESS];
        dcmhead.ExposureTime = [];
        dcmhead.XrayTubeCurrent = [];
        dcmhead.Exposure = [];
        dcmhead.ExposureInuAs = [];
        dcmhead.FilterType = '';
        dcmhead.GeneratorPower = [];
        dcmhead.CollimatorGridName = '';
        dcmhead.FocalSpot = [];
        dcmhead.DateOfLastCalibration = '';
        dcmhead.TimeOfLastCalibration = '';
        dcmhead.PlateType = '';
        dcmhead.PhosphorType = '';
        dcmhead.AcquisitionMatrix = uint16([dimy 0 0 dimx])';
        dcmhead.FlipAngle = parameters.alpha;
        dcmhead.AcquisitionDeviceProcessingDescription = '';
        dcmhead.CassetteOrientation = 'PORTRAIT';
        dcmhead.CassetteSize = '25CMX25CM';
        dcmhead.ExposuresOnPlate = 0;
        dcmhead.RelativeXrayExposure = [];
        dcmhead.AcquisitionComments = '';
        dcmhead.PatientPosition = 'HFS';
        dcmhead.Sensitivity = [];
        dcmhead.FieldOfViewOrigin = [];
        dcmhead.FieldOfViewRotation = [];
        dcmhead.AcquisitionDuration = parameters.TotalAcquisitionTime;
        dcmhead.StudyInstanceUID = dcmid(1:18);
        dcmhead.StudyID = '01';
        dcmhead.SeriesNumber = studyname;
        dcmhead.AcquisitionNumber = 1;
        dcmhead.InstanceNumber = (dynamic-1)*dimz + slice;
        dcmhead.ImagePositionPatient = [-(aspectratio*parameters.FOV/2), -parameters.FOV/2 (slice-round(parameters.NO_SLICES/2))*(parameters.SLICE_SEPARATION/parameters.SLICE_INTERLEAVE)]';
        dcmhead.ImageOrientationPatient = [1.0, 0.0, 0.0, 0.0, 1.0, 0.0]';
        dcmhead.FrameOfReferenceUID = '';
        dcmhead.TemporalPositionIdentifier = dynamic;
        dcmhead.NumberOfTemporalPositions = dimd;
        dcmhead.TemporalResolution = parameters.TotalAcquisitionTime/dimd;
        dcmhead.SliceLocation = (slice-round(parameters.NO_SLICES/2))*(parameters.SLICE_SEPARATION/parameters.SLICE_INTERLEAVE);
        dcmhead.ImageComments = '';
        dcmhead.TemporalPositionIndex = uint32([]);
        dcmhead.SamplesPerPixel = 1;
        dcmhead.PhotometricInterpretation = 'MONOCHROME2';
        dcmhead.PlanarConfiguration = 0;
        dcmhead.Rows = dimy;
        dcmhead.Columns = dimx;
        dcmhead.PixelSpacing = [pixely pixelx]';
        dcmhead.PixelAspectRatio = 1;
        dcmhead.BitsAllocated = 16;
        dcmhead.BitsStored = 15;
        dcmhead.HighBit = 14;
        dcmhead.PixelRepresentation = 0;
        dcmhead.PixelPaddingValue = 0;
        dcmhead.RescaleIntercept = 0;
        dcmhead.RescaleSlope = 1;
        dcmhead.HeartRate = 0;
        dcmhead.NumberOfSlices = parameters.NO_SLICES;
        dcmhead.CardiacNumberOfImages = 1;
        dcmhead.MRAcquisitionType = '2D';
        dcmhead.ScanOptions = 'CG';
        dcmhead.BodyPartExamined = '';

        dicom_header = dcmhead;

    end % GenerateDicomHeaderT2



end