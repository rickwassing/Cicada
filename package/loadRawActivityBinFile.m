function recordCount = loadRawActivityBinFile(fullFilename,firmwareVersion)
if(exist(fullFilename,'file'))

    recordCount = 0;
    packetCodeList = [];

    % fid = fopen(fullFilename,'r','b');  %I'm going with a big endian format here.
    fid = fopen(fullFilename,'r','l'); % Change to little endian
    if(fid>0)

        encodingEPS = 1/341; %from trial and error - or math:  341*3 == 1023; this is 10 bits across three vlues
        precision = 'ubit12=>double';


        % Testing for ver 2.5.0
        % fullRawActivityBinFilename = '/Volumes/SeaG 1TB/sampledata_reveng/700851.activity.bin'
        %                sleepmoore:T1_GT3X_Files $ head -n 15 ../../sampleData/raw/700851t00c1.raw.csv
        %                 ------------ Data File Created By ActiGraph GT3X+ ActiLife v6.11.1 Firmware v2.5.0 date format M/d/yyyy at 40 Hz  Filter Normal -----------
        %                 Serial Number: NEO1C15110103
        %                 Start Time 00:00:00
        %                 Start Date 10/25/2012
        %                 Epoch Period (hh:mm:ss) 00:00:00
        %                 Download Time 16:48:59
        %                 Download Date 11/2/2012
        %                 Current Memory Address: 0
        %                 Current Battery Voltage: 3.74     Mode = 12
        %                 --------------------------------------------------
        %                 Timestamp,Axis1,Axis2,Axis3
        %                 10/25/2012 00:00:00.000,-0.044,0.361,-0.915
        %                 10/25/2012 00:00:00.025,-0.044,0.358,-0.915
        %                 10/25/2012 00:00:00.050,-0.047,0.361,-0.915
        %                 10/25/2012 00:00:00.075,-0.044,0.361,-0.915
        % Use big endian format
        try
            % both fw 2.5 and 3.1.0 use same packet format for
            % acceleration data.
            if(strcmp(firmwareVersion,'2.5.0')||strcmp(firmwareVersion,'3.1.0')||strcmp(firmwareVersion,'2.2.1')||strcmp(firmwareVersion,'1.5.0') || strcmp(firmwareVersion,'1.7.2'))
                tic
                axesPerRecord = 3;
                checksumSizeBytes = 1;
                if(strcmp(firmwareVersion,'2.5.0'))


                    % The following, commented code is for determining
                    % expected record count.  However, the [] notation
                    % is used as a shortcut below.
                    % bitsPerByte = 8;
                    % fileSizeInBits = ftell(fid)*bitsPerByte;
                    % bitsPerRecord = 36;  %size in number of bits
                    % numberOfRecords = floor(fileSizeInBits/bitsPerRecord);
                    % axesUBitData = fread(fid,[axesPerRecord,numberOfRecords],precision)';
                    % recordCount = numberOfRecords;

                    % reads are stored column wise (one column, then the
                    % next) so we have to transpose twice to get the
                    % desired result here.
                    axesUBitData = fread(fid,[axesPerRecord,inf],precision)';

                elseif(strcmp(firmwareVersion,'3.1.0')||strcmp(firmwareVersion,'2.2.1') || strcmp(firmwareVersion,'1.5.0') || strcmp(firmwareVersion,'1.7.2'))
                    % endian format: big
                    % global header: none
                    % packet encoding:
                    %   header:  8 bytes  [packet code: 2][time stamp: 4][packet size (in bytes): 2]
                    %   accel packets:  36 bits each (format: see ver 2.5.0) + 1 byte for checksum

                    triaxialAccelCodeBigEndian = 7680;
                    trixaialAccelCodeLittleEndian = 7686; %?
                    triaxialAccelCodeLittleEndian = 30;
                    triaxialAccelCode = triaxialAccelCodeLittleEndian;
                    %                                packetCode = 7686 (popped up in a firmware version 1.5
                    bitsPerByte = 8;
                    bitsPerAccelRecord = 36;  %size in number of bits (12 bits per acceleration axis)
                    recordsPerByte = bitsPerByte/bitsPerAccelRecord;
                    timeStampSizeBytes = 4;
                    % packetHeader.size = 8;
                    % go through once to determine how many
                    % records I have in order to preallocate memory
                    % - should look at meta data record to see if I can
                    % shortcut obj.
                    while(~feof(fid)) 

                        packetCode = fread(fid,1,'uint16=>double');
                        packetCodeList = unique([packetCodeList; packetCode]);
                        fseek(fid,timeStampSizeBytes,0);
                        packetSizeBytes = fread(fid,2,'uint8');  % This works for firmware version 1.5 packetSizeBytes = fread(fid,1,'uint16','l');
                        if(~feof(fid))
                            packetSizeBytes = [1 256]*packetSizeBytes;
                            if(packetCode == triaxialAccelCode)  % This is for the triaxial accelerometers
                                packetRecordCount = packetSizeBytes*recordsPerByte;
                                if(packetRecordCount>1)
                                    recordCount = recordCount+packetRecordCount;
                                else
                                    fprintf('Record count <=1 at file position %u\n',ftell(fid));
                                end
                            end
                            if(packetSizeBytes~=0)
                                fseek(fid,packetSizeBytes+checksumSizeBytes,0);
                            else
                                fprintf('Packet size is 0 bytes at file position %u\n',ftell(fid));
                            end
                        end
                    end

                    frewind(fid);
                    curRecord = 1;
                    axesUBitData = zeros(recordCount,axesPerRecord);
                    timeStamp = zeros(recordCount,1);
                    while(~feof(fid) && curRecord<=recordCount)
                        packetCode = fread(fid,1,'uint16=>double');
                        if(packetCode==triaxialAccelCode)  % This is for the triaxial accelerometers
                            timeStamp(curRecord) = fread(fid,1,'uint32=>double');
                            packetSizeBytes = [1 256]*fread(fid,2,'uint8');

                            packetRecordCount = packetSizeBytes*recordsPerByte;

                            axesUBitData(curRecord:curRecord+packetRecordCount-1,:) = fread(fid,[axesPerRecord,packetRecordCount],precision)';
                            curRecord = curRecord+packetRecordCount;
                            checkSum = fread(fid,checksumSizeBytes,'uint8');
                        elseif(packetCode==0)

                        else
                            fseek(fid,timeStampSizeBytes,0);
                            packetSizeBytes = fread(fid,2,'uint8');
                            if(~feof(fid))
                                packetSizeBytes = [1 256]*packetSizeBytes;
                                fseek(fid,packetSizeBytes+checksumSizeBytes,0);
                            end
                        end
                    end

                    curRecord = curRecord -1;  %adjust for the 1 base offset matlab uses.
                    if(recordCount~=curRecord)
                        fprintf(1,'There is a mismatch between the number of records expected and the number of records found.\n\tPlease check your data for corruption.\n');
                    end
                end


                axesFloatData = (-bitand(axesUBitData,2048)+bitand(axesUBitData,2047))*encodingEPS;

                toc;
            end
            fclose(fid);

            fprintf('Skipping resample count data step\n');
            %                        obj.resampleCountData();

        catch me
            getReport(me);
            fclose(fid);
        end
    else
        fprintf('Warning - could not open %s for reading!\n',fullFilename);
    end
else
    fprintf('Warning - %s does not exist!\n',fullFilename);
end
end