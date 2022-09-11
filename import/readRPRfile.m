function rprPars = readRPRfile(filename)

% Read the RPR file
fid = fopen(filename,'r');
rprData = char(fread(fid,Inf,'uchar')');
fclose(fid);


% Extract some parameters

% Total acquisition time
pos1 = strfind(rprData,":IM_TEXT_DCM_AcquisitionDuration");
pos2 = strfind(rprData(pos1+34:pos1+40),char(34));
entry = rprData(pos1+34:pos1+34+pos2-2);

rprPars.TotalAcquisitionTime = str2num(entry); %#ok<ST2NM> 

end
