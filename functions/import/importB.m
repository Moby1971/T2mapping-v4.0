% ---------------------------------------------------------------------------------
% Import B-type scanner data
% ---------------------------------------------------------------------------------
function [rawData, rawImages, parameters] = importB(importPath) %#ok<*INUSL>


% Parameters
info1 = jCampRead(strcat(importPath,'acqp'));
info2 = jCampRead(strcat(importPath,'method'));


% Scanner type
parameters.scanner = 'b-type';
parameters.filename = '111';



% Check if MGE pulse program
if contains(info1.PULPROG,"MGE")
    parameters.PPL = 'flash';
else
    parameters.PPL = 'noncompatible';
end


% Slices
parameters.NO_SLICES = str2num(info1.NSLICES);
parameters.SLICE_THICKNESS = str2num(info2.pvm.slicethick);
parameters.SLICE_SEPARATION = info2.pvm.spackarrslicegap;
parameters.SLICE_INTERLEAVE = 1;


% Matrix in readout direction
parameters.NO_SAMPLES = double(info2.pvm.matrix(1));


% Matrix in phase encoding direction
parameters.NO_VIEWS = double(info2.pvm.matrix(2));


% Phase encoding orientation
parameters.PHASE_ORIENTATION = 1;
pm1 = -1;
pm2 = -1;

% Determine how to flip the data for different orientations
if isfield(info2.pvm,'spackarrreadorient')
    if strcmp(info2.pvm.spackarrreadorient(1:3),'L_R')
        parameters.PHASE_ORIENTATION = 0;
        flr =  0;
        pm1 = +1;
        pm2 = -1;
    end
    if strcmp(info2.pvm.spackarrreadorient(1:3),'A_P')
        parameters.PHASE_ORIENTATION = 0;
        flr =  0;
        pm1 = -1;
        pm2 = -1;
    end
    if strcmp(info2.pvm.spackarrreadorient(1:3),'H_F')
        parameters.PHASE_ORIENTATION = 1;
        flr =  0;
        pm1 = -1;
        pm2 = -1;
    end
end



% Matrix in 2nd phase encoding direction
parameters.NO_VIEWS_2 = 1;
parameters.pe2_centric_on = 0;


% FOV
parameters.FOV = info1.acq.fov(1)*10;
parameters.FOV2 = info1.acq.fov(2)*10;
parameters.FOVf = round(8*(parameters.FOV2/parameters.FOV)*(parameters.NO_SAMPLES/parameters.NO_VIEWS));


% Sequence parameters
parameters.tr = info1.acq.repetition_time;
parameters.echotimes = info2.EffectiveTE';
parameters.te = parameters.echotimes(1);
parameters.NO_ECHOES = length(parameters.echotimes);
parameters.alpha = str2num(info1.acq.flip_angle);
parameters.NO_AVERAGES = str2num(info1.NA);
parameters.tr_extra_us = 0;


% Other parameters
parameters.date = datetime;
parameters.nucleus = '1H';
parameters.filename = 'Proton';
parameters.field_strength = str2num(info1.BF1)/42.58; %#ok<*ST2NM>
parameters.imagingFrequency = str2num(info1.BF1);
parameters.filename = 111;
parameters.pe1_order = 2;
parameters.radial_on = 0;
parameters.slice_nav = 0;


% Number of receiver coils
parameters.nr_coils = 1;

% Assuming only 1 dynamic
parameters.EXPERIMENT_ARRAY = 1;


% Data type
datatype = 'int32';
if isfield(info1.acq,'word_size')
    if strcmp(info1.acq.word_size,'_32_BIT')
        datatype = 'int32';
    end
    if strcmp(info1.acq.word_size,'_16_BIT')
        datatype = 'int16';
    end
end


% Read data
if isfile(strcat(importPath,'fid'))
    fileID = fopen(strcat(importPath,filesep,'pdata',filesep,'1',filesep,'2dseq'));
end
dataRaw = fread(fileID,datatype);
fclose(fileID);


% Images
rawImages = reshape(dataRaw,[parameters.NO_SAMPLES,parameters.NO_VIEWS,parameters.NO_SLICES,parameters.NO_ECHOES]);
rawImages = permute(rawImages,[4 1 2 3]);
rawImages = flip(rawImages,3);


% normalize to convenient range
norm = 16384/max(rawImages(:));
rawImages = round(norm*rawImages);


% Make new k-space
for i = 1:size(rawImages,1)
    for j = 1:size(rawImages,4)
        rawData{1}(i,:,:,j) = ifft2reco(squeeze(rawImages(i,:,:,j)));
    end
end





    %--------------------------------------------------------
    %
    % Read reco files to a structure
    %
    %--------------------------------------------------------

    function struct = jCampRead(filename) %#ok<STOUT>

        % Open file read-only big-endian
        fid = fopen(filename,'r','b');
        skipLine = 0;

        % Loop through separate lines
        if fid~=-1

            while 1

                if skipLine
                    line = nextLine;
                    skipLine = 0;
                else
                    line = fgetl(fid);
                end

                % Testing the text lines
                while length(line) < 2
                    line = fgetl(fid);
                end

                % Parameters and optional size of parameter are on lines starting with '##'
                if line(1:2) == '##' %#ok<*BDSCA>

                    % Parameter extracting and formatting
                    % Read parameter name
                    paramName = fliplr(strtok(fliplr(strtok(line,'=')),'#'));

                    % Check for illegal parameter names starting with '$' and correct (Matlab does not accepts variable names starting with $)
                    if paramName(1) == '$'
                        paramName = paramName(2:length(paramName));
                        % Check if EOF, if true return
                    elseif paramName(1:3) == 'END'
                        break
                    end

                    % Parameter value formatting
                    paramValue = fliplr(strtok(fliplr(line),'='));

                    % Check if parameter values are in a matrix and read the next line
                    if paramValue(1) == '('

                        paramValueSize = str2num(fliplr(strtok(fliplr(strtok(paramValue,')')),'(')));

                        % Create an empty matrix with size 'paramvaluesize' check if only one dimension
                        if ~isempty(paramValueSize)

                            if size(paramValueSize,2) == 1
                                paramValueSize = [paramValueSize,1]; %#ok<AGROW>
                            end

                            % Read the next line
                            nextLine = fgetl(fid);

                            % See whether next line contains a character array
                            if nextLine(1) == '<'
                                paramValue = fliplr(strtok(fliplr(strtok(nextLine,'>')),'<')); %#ok<*NASGU>
                            elseif strcmp(nextLine(1),'L') || strcmp(nextLine(1),'A') || strcmp(nextLine(1),'H')
                                paramValue = nextLine;
                            else

                                % Check if matrix has more then one dimension
                                if paramValueSize(2) ~= 1

                                    paramValueLong = str2num(nextLine);
                                    while (length(paramValueLong)<(paramValueSize(1)*paramValueSize(2))) & (nextLine(1:2) ~= '##') %#ok<*AND2>
                                        nextLine = fgetl(fid);
                                        paramValueLong = [paramValueLong str2num(nextLine)]; %#ok<AGROW>
                                    end

                                    if (length(paramValueLong) == (paramValueSize(1)*paramValueSize(2))) & (~isempty(paramValueLong))
                                        paramValue=reshape(paramValueLong,paramValueSize(1),paramValueSize(2));
                                    else
                                        paramValue = paramValueLong;
                                    end

                                    if length(nextLine) > 1
                                        if (nextLine(1:2) ~= '##')
                                            skipLine = 1;
                                        end
                                    end

                                else

                                    % If only 1 dimension just assign whole line to paramvalue
                                    paramValue = str2num(nextLine);
                                    if ~isempty(str2num(nextLine))
                                        while length(paramValue)<paramValueSize(1)
                                            line = fgetl(fid);
                                            paramValue = [paramValue str2num(line)]; %#ok<AGROW>
                                        end
                                    end

                                end

                            end

                        else
                            paramValue = '';
                        end

                    end

                    % Add paramvalue to structure.paramname
                    if isempty(findstr(paramName,'_'))
                        eval(['struct.' paramName '= paramValue;']); %#ok<*EVLDOT>
                    else
                        try
                            eval(['struct.' lower(paramName(1:findstr(paramName,'_')-1)) '.' lower(paramName(findstr(paramName,'_')+1:length(paramName))) '= paramValue;']);
                        catch
                            eval(['struct.' lower(paramName(1:findstr(paramName,'_')-1)) '.' datestr(str2num(paramName(findstr(paramName,'_')+1:findstr(paramName,'_')+2)),9) ...
                                paramName(findstr(paramName,'_')+2:length(paramName)) '= paramValue;']); %#ok<DATST,*FSTR>
                        end
                    end

                elseif line(1:2) == '$$'
                    % The two $$ lines are not parsed for now
                end

            end

            % Close file
            fclose(fid);

        end

    end % jCampRead

end % ImportB
