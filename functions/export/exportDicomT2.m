function exportDicomT2(app, directory)

%------------------------------------------------------------
%
% DICOM EXPORT OF T2 MAPS
% DICOM HEADER INFORMATION NOT AVAILABLE
%
% Gustav Strijkers
% Amsterdam UMC
% g.j.strijkers@amsterdamumc.nl
% Oct 2023
%
%------------------------------------------------------------


% Input
m0map = app.m0map;
t2map = app.t2map;
r2map = app.r2map;
wmap = app.watermap;
fmap = app.fatmap;
parameters = app.parameters;
tag = app.tag;


% Mulitply T2, water, and fat values with this factor to prevent discretization
scaling = 100; 


% Create folder if not exist, and clear
folder_name = strcat(directory,filesep,'T2map-DICOM-',tag);
if ~exist(folder_name, 'dir') 
    mkdir(folder_name); end
delete(strcat(folder_name,filesep,'*'));


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


for dynamic = 1:dimd

    for slice = 1:dimz

        dcm_header = generateDicomHeaderT2(parameters,slice,dynamic,dimx,dimy,dimz,dimd,dcmid);
        dcm_header.ProtocolName = 'T2-map';
        dcm_header.SequenceName = 'T2-map';
        dcm_header.EchoTime = 1.1;

        fn = strcat('0000',num2str(slice));
        fn = fn(size(fn,2)-4:size(fn,2));
        dn = strcat('0000',num2str(dynamic));
        dn = dn(size(dn,2)-4:size(dn,2));

        fname = strcat(folder_name,filesep,'T2map-slice',fn,'-dynamic',dn,'.dcm');
        image = rot90(squeeze(cast(round(scaling*t2map(:,:,slice,dynamic)),'uint16')));
        dicomwrite(image, fname, dcm_header);

    end

end


m0map = round(32767*m0map/max(m0map(:)));

for dynamic = 1:dimd

    for slice=1:dimz

        dcm_header = generateDicomHeaderT2(parameters,slice,dynamic,dimx,dimy,dimz,dimd,dcmid);
        dcm_header.ProtocolName = 'M0-map';
        dcm_header.SequenceName = 'M0-map';
        dcm_header.EchoTime = 1.2;

        fn = strcat('0000',num2str(slice));
        fn = fn(size(fn,2)-4:size(fn,2));
        dn = strcat('0000',num2str(dynamic));
        dn = dn(size(dn,2)-4:size(dn,2));

        fname = strcat(folder_name,filesep,'M0map-slice',fn,'-dynamic',dn,'.dcm');
        image = rot90(squeeze(cast(round(m0map(:,:,slice,dynamic)),'uint16')));
        dicomwrite(image, fname, dcm_header);

    end

end



for dynamic = 1:dimd

    for slice=1:dimz

        dcm_header = generateDicomHeaderT2(parameters,slice,dynamic,dimx,dimy,dimz,dimd,dcmid);
        dcm_header.ProtocolName = 'R2-map';
        dcm_header.SequenceName = 'R2-map';
        dcm_header.EchoTime = 1.3;

        fn = strcat('0000',num2str(slice));
        fn = fn(size(fn,2)-4:size(fn,2));
        dn = strcat('0000',num2str(dynamic));
        dn = dn(size(dn,2)-4:size(dn,2));

        fname = strcat(folder_name,filesep,'R2map-slice',fn,'-dynamic',dn,'.dcm');
        image = rot90(squeeze(cast(round(scaling*r2map(:,:,slice,dynamic)),'uint16')));
        dicomwrite(image, fname, dcm_header);

    end

end


if app.validWaterFatFlag

    for dynamic = 1:dimd

        for slice = 1:dimz

            dcm_header = generateDicomHeaderT2(parameters,slice,dynamic,dimx,dimy,dimz,dimd,dcmid);
            dcm_header.ProtocolName = 'Water-map';
            dcm_header.SequenceName = 'Water-map';
            dcm_header.EchoTime = 1.4;

            fn = strcat('0000',num2str(slice));
            fn = fn(size(fn,2)-4:size(fn,2));
            dn = strcat('0000',num2str(dynamic));
            dn = dn(size(dn,2)-4:size(dn,2));

            fname = strcat(folder_name,filesep,'Watermap-slice',fn,'-dynamic',dn,'.dcm');
            image = rot90(squeeze(cast(round(scaling*wmap(:,:,slice,dynamic)),'uint16')));
            dicomwrite(image, fname, dcm_header);

        end

    end

    for dynamic = 1:dimd

        for slice = 1:dimz

            dcm_header = generateDicomHeaderT2(parameters,slice,dynamic,dimx,dimy,dimz,dimd,dcmid);
            dcm_header.ProtocolName = 'Fat-map';
            dcm_header.SequenceName = 'Fat-map';
            dcm_header.EchoTime = 1.5;

            fn = strcat('0000',num2str(slice));
            fn = fn(size(fn,2)-4:size(fn,2));
            dn = strcat('0000',num2str(dynamic));
            dn = dn(size(dn,2)-4:size(dn,2));

            fname = strcat(folder_name,filesep,'Fatmap-slice',fn,'-dynamic',dn,'.dcm');
            image = rot90(squeeze(cast(round(scaling*fmap(:,:,slice,dynamic)),'uint16')));
            dicomwrite(image, fname, dcm_header);

        end
        
    end

end






end