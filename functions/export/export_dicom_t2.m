function export_dicom_t2(directory,m0map,t2map,r2map,parameters,tag)

%------------------------------------------------------------
%
% DICOM EXPORT OF T2 MAPS
% DICOM HEADER INFORMATION NOT AVAILABLE
%
% Gustav Strijkers
% Amsterdam UMC
% g.j.strijkers@amsterdamumc.nl
% 29/3/2023
%
%------------------------------------------------------------

scaling = 100; % mulitply T2 values with this factor to prevent discretization

% create folder if not exist, and clear
folder_name1 = strcat(directory,filesep,"DICOM",filesep,"T2map-",tag);
if ~exist(folder_name1, 'dir')
    mkdir(folder_name1); 
end
delete(strcat(folder_name1,filesep,'*'));

folder_name2 = strcat(directory,filesep,"DICOM",filesep,"M0map-",tag);
if ~exist(folder_name2, 'dir')
    mkdir(folder_name2); 
end
delete(strcat(folder_name2,filesep,'*'));

folder_name3 = strcat(directory,filesep,"DICOM",filesep,"R2map-",tag);
if ~exist(folder_name3, 'dir')
    mkdir(folder_name3); 
end
delete(strcat(folder_name3,filesep,'*'));

% Phase orientation correction
if isfield(parameters, 'PHASE_ORIENTATION')
    if parameters.PHASE_ORIENTATION == 1
        t2map = permute(rot90(permute(t2map,[2 1 3 4]),1),[2 1 3 4]);
        m0map = permute(rot90(permute(m0map,[2 1 3 4]),1),[2 1 3 4]);
        r2map = permute(rot90(permute(r2map,[2 1 3 4]),1),[2 1 3 4]);
    end
end


[dimx,dimy,dimz,dimd] = size(t2map);

% export the dicom images
dcmid = dicomuid;   % unique identifier
dcmid = dcmid(1:50);


for dynamic = 1:dimd

    for slice = 1:dimz

        dcm_header = generate_dicomheader_t2(parameters,slice,dynamic,dimx,dimy,dimz,dimd,dcmid);
        dcm_header.ProtocolName = 'T2-map';
        dcm_header.SequenceName = 'T2-map';
        dcm_header.EchoTime = 1.1;

        fn = strcat('0000',num2str(slice));
        fn = fn(size(fn,2)-4:size(fn,2));
        dn = strcat('0000',num2str(dynamic));
        dn = dn(size(dn,2)-4:size(dn,2));

        fname = strcat(folder_name1,filesep,'T2map-slice',fn,'-dynamic',dn,'.dcm');
        image = rot90(squeeze(cast(round(scaling*t2map(:,:,slice,dynamic)),'uint16')));
        dicomwrite(image, fname, dcm_header);

    end

end


m0map = round(32767*m0map/max(m0map(:)));

for dynamic = 1:dimd

    for slice=1:dimz

        dcm_header = generate_dicomheader_t2(parameters,slice,dynamic,dimx,dimy,dimz,dimd,dcmid);
        dcm_header.ProtocolName = 'M0-map';
        dcm_header.SequenceName = 'M0-map';
        dcm_header.EchoTime = 1.2;

        fn = strcat('0000',num2str(slice));
        fn = fn(size(fn,2)-4:size(fn,2));
        dn = strcat('0000',num2str(dynamic));
        dn = dn(size(dn,2)-4:size(dn,2));

        fname = strcat(folder_name2,filesep,'M0map-slice',fn,'-dynamic',dn,'.dcm');
        image = rot90(squeeze(cast(round(m0map(:,:,slice,dynamic)),'uint16')));
        dicomwrite(image, fname, dcm_header);

    end

end



for dynamic = 1:dimd

    for slice=1:dimz

        dcm_header = generate_dicomheader_t2(parameters,slice,dynamic,dimx,dimy,dimz,dimd,dcmid);
        dcm_header.ProtocolName = 'R^2-map';
        dcm_header.SequenceName = 'R^2-map';
        dcm_header.EchoTime = 1.3;

        fn = strcat('0000',num2str(slice));
        fn = fn(size(fn,2)-4:size(fn,2));
        dn = strcat('0000',num2str(dynamic));
        dn = dn(size(dn,2)-4:size(dn,2));

        fname = strcat(folder_name3,filesep,'R2map-slice',fn,'-dynamic',dn,'.dcm');
        image = rot90(squeeze(cast(round(scaling*r2map(:,:,slice,dynamic)),'uint16')));
        dicomwrite(image, fname, dcm_header);

    end

end




end