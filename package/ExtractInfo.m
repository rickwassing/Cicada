function [infoStruct] = ExtractInfo( infoTxtFullFilename )
    fid = fopen(infoTxtFullFilename,'r');
    pat = '(?<field>[^:]+):\s+(?<values>[^\r\n]+)\s*';
    fileText = fscanf(fid,'%c');
    result = regexp(fileText,pat,'names');
    infoStruct = [];
    for f=1:numel(result)
        fieldName = strrep(result(f).field,' ','_');
        infoStruct.(fieldName)=result(f).values;
    end
    if(isfield(infoStruct,'Firmware'))
        firmware = infoStruct.Firmware;
    else
        firmware = '';
    end
    fclose(fid);
end