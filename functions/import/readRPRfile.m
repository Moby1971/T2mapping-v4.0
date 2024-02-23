function rprPars = readRPRfile(app,rprFolder, rprName)

% Read the RPR file

try

    rprFilename{1} = strcat(rprFolder,filesep,rprName,'.rpr');
    rprFilename{2} = strcat(rprFolder,filesep,'Recon_001',filesep,rprName,'.rpr');

    for cnt = 1:length(rprFilename)

        if isfile(rprFilename{cnt})
            app.TextMessage(strcat("RPR file = ",rprFilename{cnt}));
            fid = fopen(rprFilename{cnt},'r');
            rprData = char(fread(fid,Inf,'uchar')');
            fclose(fid);
            break;
        end

    end

catch ME
    app.TextMessage(ME.message);
end



% Extract some parameters

if contains(rprData,":IM_TEXT_DCM_ImagingFrequency")
    pos1 = strfind(rprData,":IM_TEXT_DCM_ImagingFrequency");
    pos2 = strfind(rprData(pos1:pos1+45),char(34));
    entry = rprData(pos1+pos2(1):pos1+pos2(2)-2);
    rprPars.ImagingFrequency = str2num(entry); %#ok<*ST2NM>
end

if contains(rprData,":IM_TEXT_DCM_AcquisitionTime")
    pos1 = strfind(rprData,":IM_TEXT_DCM_AcquisitionTime");
    pos2 = strfind(rprData(pos1:pos1+45),char(34));
    entry = rprData(pos1+pos2(1):pos1+pos2(2)-2);
    rprPars.TotalAcquisitionTime = str2num(entry);
end

end
