function d = dataDir()
% dataDir returns the absolute path of the repository's data folder.
d = fullfile(fileparts(mfilename('fullpath')), '..', 'data');
end
