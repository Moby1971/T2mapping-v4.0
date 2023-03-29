function export_dicom_t2_dcm(directory,dcm_files_path,m0map,t2map,r2map,parameters)

%------------------------------------------------------------
%
% DICOM EXPORT OF T2 MAPS
% DICOM HEADER INFORMATION AVAILABLE
%
% Gustav Strijkers
% Amsterdam UMC
% g.j.strijkers@amsterdamumc.nl
% 10/09/2022
%
%------------------------------------------------------------

scaling = 100; % mulitply T2 values with this factor to prevent discretization

% Phase orientation correction
if isfield(parameters, 'PHASE_ORIENTATION')
    if parameters.PHASE_ORIENTATION == 1
        t2map = permute(rot90(permute(t2map,[2 1 3 4]),1),[2 1 3 4]);
        m0map = permute(rot90(permute(m0map,[2 1 3 4]),1),[2 1 3 4]);
        r2map = permute(rot90(permute(r2map,[2 1 3 4]),1),[2 1 3 4]);
    end
end

[~,~,dimz,dimd] = size(t2map);
dimr = parameters.NO_ECHOES; % number of echoes

% List of dicom file names
flist = dir(fullfile(dcm_files_path,'*.dcm'));
files = sort({flist.name});

% Generate new dicom headers
for dynamic = 1:dimd

    for slice = 1:dimz

        % Read the Dicom header
        dcm_header{slice,dynamic} = dicominfo([dcm_files_path,filesep,files{ (dynamic-1)*dimz*dimr + (slice-1)*dimr + 1 }]); %#ok<*AGROW>

        % Changes some tags
        dcm_header{slice,dynamic}.ImageType = 'DERIVED\RELAXATION\';
        dcm_header{slice,dynamic}.InstitutionName = 'Amsterdam UMC';
        dcm_header{slice,dynamic}.InstitutionAddress = 'Amsterdam, Netherlands';
        dcm_header{slice,dynamic}.TemporalPositionIdentifier = dynamic;
        dcm_header{slice,dynamic}.NumberOfTemporalPositions = dimd;
        dcm_header{slice,dynamic}.TemporalResolution = parameters.TotalAcquisitionTime/dimd;
        
    end

end

% create folders if not exist, and delete folders content
dir1 = dcm_header{1,1}.PatientID;
dir2 = 'DICOM';
dir3 = strcat(num2str(dcm_header{1,1}.SeriesNumber),'T2');
dir41 = '1';
dir42 = '2';
dir43 = '3';

output_directory1 = strcat(directory,filesep,dir1,filesep,dir2,filesep,dir3,filesep,dir41);
if (~exist(output_directory1, 'dir')) 
    mkdir(fullfile(directory, dir1,dir2,dir3,dir41)); 
end
delete([output_directory1,filesep,'*']);

output_directory2 = strcat(directory,filesep,dir1,filesep,dir2,filesep,dir3,filesep,dir42);
if (~exist(output_directory2, 'dir')) 
    mkdir(fullfile(directory, dir1,dir2,dir3,dir42)); 
end
delete([output_directory2,filesep,'*']);

output_directory3 = strcat(directory,filesep,dir1,filesep,dir2,filesep,dir3,filesep,dir43);
if (~exist(output_directory3, 'dir')) 
    mkdir(fullfile(directory, dir1,dir2,dir3,dir43)); 
end
delete([output_directory3,filesep,'*']);



% Export the T2 map Dicoms
for dynamic = 1:dimd

    for slice = 1:dimz

        dcm_header{slice,dynamic}.ProtocolName = 'T2-map';
        dcm_header{slice,dynamic}.SequenceName = 'T2-map';
        dcm_header{slice,dynamic}.EchoTime = 1.1;
        dcm_header{slice,dynamic}.ImageType = 'DERIVED\RELAXATION\T2';

        fn = ['0000',num2str(slice)];
        fn = fn(size(fn,2)-4:size(fn,2));

        dn = ['0000',num2str(dynamic)];
        dn = dn(size(dn,2)-4:size(dn,2));

        fname = [output_directory1,filesep,'T2-slice',fn,'-dynamic',dn,'.dcm'];
       
        image = rot90(squeeze(cast(round(scaling*t2map(:,:,slice,dynamic)),'uint16')));

        dicomwrite(image, fname, dcm_header{slice,dynamic});

    end

end



% Export the M0 map Dicoms
m0map = round(32767*m0map/max(m0map(:)));

for dynamic = 1:dimd

    for slice=1:dimz

        dcm_header{slice,dynamic}.ProtocolName = 'M0-map';
        dcm_header{slice,dynamic}.SequenceName = 'M0-map';
        dcm_header{slice,dynamic}.EchoTime = 1.2;
        dcm_header{slice,dynamic}.ImageType = 'DERIVED\RELAXATION\M0';

        fn = ['0000',num2str(slice)];
        fn = fn(size(fn,2)-4:size(fn,2));
        dn = ['0000',num2str(dynamic)];
        dn = dn(size(dn,2)-4:size(dn,2));

        fname = [output_directory2,filesep,'M0-slice',fn,'-dynamic',dn,'.dcm'];
        image = rot90(squeeze(cast(round(m0map(:,:,slice,dynamic)),'uint16')));
    
        dicomwrite(image, fname, dcm_header{slice,dynamic});

    end

end



% Export the  R^2 map Dicoms
for dynamic = 1:dimd

    for slice=1:dimz

        dcm_header{slice,dynamic}.ProtocolName = 'R^2-map';
        dcm_header{slice,dynamic}.SequenceName = 'R^2-map';
        dcm_header{slice,dynamic}.EchoTime = 1.3;
        dcm_header{slice,dynamic}.ImageType = 'DERIVED\RELAXATION\R2';

        fn = ['0000',num2str(slice)];
        fn = fn(size(fn,2)-4:size(fn,2));
        dn = ['0000',num2str(dynamic)];
        dn = dn(size(dn,2)-4:size(dn,2));

        fname = [output_directory3,filesep,'R2-slice',fn,'-dynamic',dn,'.dcm'];
        image = rot90(squeeze(cast(round(scaling*r2map(:,:,slice,dynamic)),'uint16')));
     
        dicomwrite(image, fname, dcm_header{slice,dynamic});

    end

end




end