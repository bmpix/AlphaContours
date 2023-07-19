function seg = readSym(filename)

fileID = fopen(filename, 'r');

s = textscan(fileID, '%d');
seg = double(s{1});
n = length(seg);

if (min(seg) == 0)
    seg = seg + 1;
end

fclose(fileID);