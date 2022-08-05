function export_dicom_t2_dcm(directory,dcm_files_path,m0map,t2map,r2map,parameters)


% Phase orientation correction
if isfield(parameters, 'PHASE_ORIENTATION')
    if parameters.PHASE_ORIENTATION == 1
        t2map = permute(rot90(permute(t2map,[2 1 3]),1),[2 1 3]);
        m0map = permute(rot90(permute(m0map,[2 1 3]),1),[2 1 3]);
        r2map = permute(rot90(permute(r2map,[2 1 3]),1),[2 1 3]);
    end
end

[~,~,dimz] = size(t2map);


% List of dicom file names
flist = dir(fullfile(dcm_files_path,'*.dcm'));
files = sort({flist.name});


% Generate new dicom headers
for i = 1:dimz
    
    % Read the Dicom header
    dcm_header(i) = dicominfo([dcm_files_path,filesep,files{i}]); %#ok<*AGROW> 
    
    % Changes some tags
    dcm_header(i).ImageType = 'DERIVED\RELAXATION\';
    dcm_header(i).InstitutionName = 'Amsterdam UMC';
    dcm_header(i).InstitutionAddress = 'Amsterdam, Netherlands';
    
end

% create folders if not exist, and delete folders content
dir1 = dcm_header(1).PatientID;
dir2 = 'DICOM';
dir3 = strcat(num2str(dcm_header(1).SeriesNumber),'T2');
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
for i=1:dimz
    dcm_header(i).ProtocolName = 'T2-map';
    dcm_header(i).SequenceName = 'T2-map';
    dcm_header(i).EchoTime = 1.1;
    dcm_header(i).ImageType = 'DERIVED\RELAXATION\T2';
    fn = ['0000',num2str(i)];
    fn = fn(size(fn,2)-4:size(fn,2));
    fname = [output_directory1,filesep,'T2',fn,'.dcm'];
    image = rot90(squeeze(cast(round(t2map(:,:,i)),'uint16')));
    dicomwrite(image, fname, dcm_header(i));
end



% Export the M0 map Dicoms
for i=1:dimz
    dcm_header(i).ProtocolName = 'M0-map';
    dcm_header(i).SequenceName = 'M0-map';
    dcm_header(i).EchoTime = 1.2;
    dcm_header(i).ImageType = 'DERIVED\RELAXATION\M0';
    
    fn = ['0000',num2str(i)];
    fn = fn(size(fn,2)-4:size(fn,2));
    fname = [output_directory2,filesep,'M0',fn,'.dcm'];
    image = rot90(squeeze(cast(round(m0map(:,:,i)),'uint16')));
    dicomwrite(image, fname, dcm_header(i));
end



% Export the  R^2 map Dicoms
for i=1:dimz
    dcm_header(i).ProtocolName = 'R2-map';
    dcm_header(i).SequenceName = 'R2-map';
    dcm_header(i).EchoTime = 1.3;
    dcm_header(i).ImageType = 'DERIVED\RELAXATION\R2';
    
    fn = ['0000',num2str(i)];
    fn = fn(size(fn,2)-4:size(fn,2));
    fname = [output_directory3,filesep,'R2',fn,'.dcm'];
    image = rot90(squeeze(cast(round(100*r2map(:,:,i)),'uint16')));
    dicomwrite(image, fname, dcm_header(i));
end




end