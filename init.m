% Please run once after cloning the repository :

startupFile = fullfile(strrep(userpath, ';', ''), 'startup.m');
packageLoc = pwd;

separator = '/';
if ispc 
    separator = '\';
end

packageLines = [sprintf('\n'), 'addpath(''' ,  packageLoc, separator, 'IGTEOptimizer', separator, ''')'];

if exist(startupFile, 'file')
    disp('Startup file exists - editing!')
    stf = fileread(startupFile);
    stf = [stf, packageLines];
else
    disp('Startup file does not exist - generating!')
    stf = packageLines;
end

fid = fopen(startupFile, 'w');
fprintf(fid, '%s', stf);
fclose(fid);

% Run startup to update current session : 
startup;

disp('')
disp('>> Succesfully added IGTE optimization framework! <<')