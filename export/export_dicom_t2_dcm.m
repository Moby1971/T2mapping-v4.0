function export_dicom_t2_dcm(output_directory,dcm_files_path,m0map,t2map,r2map,tag,orientation)


folder_name = [output_directory,[filesep,'T2map-DICOM-',tag]];
if (~exist(folder_name, 'dir')); mkdir(folder_name); end
delete([folder_name,filesep,'*']);


% Flip and rotate in correct orientation
t2map = flip(permute(t2map,[1,3,2]),3);
m0map = flip(permute(m0map,[1,3,2]),3);
r2map = flip(permute(r2map,[1,3,2]),3);

% Rotate the images if phase orienation == 1
number_of_images = size(t2map,1);
if orientation
    for i = 1:number_of_images
        t2mapr(i,:,:) = rot90(squeeze(t2map(i,:,:)),-1);
        m0mapr(i,:,:) = rot90(squeeze(m0map(i,:,:)),-1);
        r2mapr(i,:,:) = rot90(squeeze(r2map(i,:,:)),-1);
    end
    t2map = t2mapr;
    m0map = m0mapr;
    r2map = r2mapr;
end


% List of dicom file names
flist = dir(fullfile(dcm_files_path,'*.dcm'));
files = sort({flist.name});


% Generate new dicom headers
for i = 1:number_of_images
    
    % Read the Dicom header
    dcm_header(i) = dicominfo([dcm_files_path,filesep,files{i}]);
    
    % Changes some tags
    dcm_header(i).ImageType = 'DERIVED\RELAXATION\';
    dcm_header(i).InstitutionName = 'Amsterdam UMC';
    dcm_header(i).InstitutionAddress = 'Amsterdam, Netherlands';
    
end



% Export the T2 map Dicoms
for i=1:number_of_images
    dcm_header(i).ProtocolName = 'T2-map';
    dcm_header(i).SequenceName = 'T2-map';
    dcm_header(i).EchoTime = 1;
    fn = ['0000',num2str(i)];
    fn = fn(size(fn,2)-4:size(fn,2));
    fname = [output_directory,filesep,'T2map-DICOM-',tag,filesep,'T2map_',fn,'.dcm'];
    image = rot90(squeeze(cast(round(t2map(i,:,:)),'uint16')));
    dicomwrite(image, fname, dcm_header(i));
end



% Export the M0 map Dicoms
for i=1:number_of_images
    dcm_header(i).ProtocolName = 'M0-map';
    dcm_header(i).SequenceName = 'M0-map';
    dcm_header(i).EchoTime = 2;
    
    fn = ['0000',num2str(i)];
    fn = fn(size(fn,2)-4:size(fn,2));
    fname = [output_directory,filesep,'T2map-DICOM-',tag,filesep,'M0map_',fn,'.dcm'];
    image = rot90(squeeze(cast(round(m0map(i,:,:)),'uint16')));
    dicomwrite(image, fname, dcm_header(i));
end



% Export the  R^2 map Dicoms
for i=1:number_of_images
    dcm_header(i).ProtocolName = 'R2-map';
    dcm_header(i).SequenceName = 'R2-map';
    dcm_header(i).EchoTime = 3;
    
    fn = ['0000',num2str(i)];
    fn = fn(size(fn,2)-4:size(fn,2));
    fname = [output_directory,filesep,'T2map-DICOM-',tag,filesep,'R2map_',fn,'.dcm'];
    image = rot90(squeeze(cast(round(100*r2map(i,:,:)),'uint16')));
    dicomwrite(image, fname, dcm_header(i));
end




end