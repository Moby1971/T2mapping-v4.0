function export_dicom_t2(directory,m0map,t2map,r2map,parameters,tag,orientation)


% create folder if not exist, and clear
folder_name = [directory,[filesep,'T2map-DICOM-',tag]];
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



[nr_images,dimx,dimy] = size(t2map);

% export the dicom images

dcmid = dicomuid;   % unique identifier
dcmid = dcmid(1:50);




for i=1:nr_images
    dcm_header = generate_dicomheader_t2(parameters,i,dimx,dimy,dcmid);
    dcm_header.ProtocolName = 'T2-map';
    dcm_header.SequenceName = 'T2-map';
    dcm_header.EchoTime = 1;
    
    fn = ['0000',num2str(i)];
    fn = fn(size(fn,2)-4:size(fn,2));
    fname = [directory,filesep,'T2map-DICOM-',tag,filesep,'T2map_',fn,'.dcm'];
    image = rot90(squeeze(cast(round(t2map(i,:,:)),'uint16')));
    dicomwrite(image, fname, dcm_header);
end



for i=1:nr_images
    dcm_header = generate_dicomheader_t2(parameters,i,dimx,dimy,dcmid);
    dcm_header.ProtocolName = 'M0-map';
    dcm_header.SequenceName = 'M0-map';
    dcm_header.EchoTime = 2;
    
    fn = ['0000',num2str(i)];
    fn = fn(size(fn,2)-4:size(fn,2));
    fname = [directory,filesep,'T2map-DICOM-',tag,filesep,'M0map_',fn,'.dcm'];
    image = rot90(squeeze(cast(round(m0map(i,:,:)),'uint16')));
    dicomwrite(image, fname, dcm_header);
end



for i=1:nr_images
    dcm_header = generate_dicomheader_t2(parameters,i,dimx,dimy,dcmid);
    dcm_header.ProtocolName = 'R2-map';
    dcm_header.SequenceName = 'R2-map';
    dcm_header.EchoTime = 3;
    
    fn = ['0000',num2str(i)];
    fn = fn(size(fn,2)-4:size(fn,2));
    fname = [directory,filesep,'T2map-DICOM-',tag,filesep,'R2map_',fn,'.dcm'];
    image = rot90(squeeze(cast(round(100*r2map(i,:,:)),'uint16')));
    dicomwrite(image, fname, dcm_header);
end




end