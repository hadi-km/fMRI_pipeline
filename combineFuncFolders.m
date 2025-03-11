function combineFuncFolders(rootDir)

  % Combine "func" and "func1" folders, merge name-matched subfolders, delete originals, and rename combined to "func".
  %
  % Args:
  %   rootDir: The root directory containing the "func" and "func1" folders.

  % Find the "func" and "func1" folders.
  funcPath = fullfile(rootDir, 'func');
  func1Path = fullfile(rootDir, '1');

  if ~exist(funcPath, 'dir') || ~exist(func1Path, 'dir')
    error('Both "func" and "func1" folders must exist in the root directory.');
  end

  % Get the subfolders in each folder.
  subfoldersFunc = dir(funcPath);
  subfoldersFunc = subfoldersFunc([subfoldersFunc.isdir] & ~strcmp({subfoldersFunc.name}, '.') & ~strcmp({subfoldersFunc.name}, '..'));

  subfoldersFunc1 = dir(func1Path);
  subfoldersFunc1 = subfoldersFunc1([subfoldersFunc1.isdir] & ~strcmp({subfoldersFunc1.name}, '.') & ~strcmp({subfoldersFunc1.name}, '..'));

  % Create a new "func_combined" folder if it doesn't exist.
  combinedPath = fullfile(rootDir, 'func_combined');
  if ~exist(combinedPath, 'dir')
    mkdir(combinedPath);
  end

  % Iterate through subfolders in the "func" folder.
  for i = 1:length(subfoldersFunc)
    subfolderName = subfoldersFunc(i).name;
    subfolderPathFunc = fullfile(funcPath, subfolderName);

    % Check if a matching subfolder exists in the "func1" folder.
    matchingSubfolderIndex = find(strcmp({subfoldersFunc1.name}, subfolderName), 1);

    if ~isempty(matchingSubfolderIndex)
      subfolderPathFunc1 = fullfile(func1Path, subfolderName);
      combinedSubfolderPath = fullfile(combinedPath, subfolderName);

      % Create the combined subfolder if it doesn't exist.
      if ~exist(combinedSubfolderPath, 'dir')
        mkdir(combinedSubfolderPath);
      end

      % Copy files from both subfolders to the combined subfolder.
      copyfile(fullfile(subfolderPathFunc, '*'), combinedSubfolderPath);
      copyfile(fullfile(subfolderPathFunc1, '*'), combinedSubfolderPath);

    else
      % If no matching subfolder, just copy the first folder's contents.
      combinedSubfolderPath = fullfile(combinedPath, subfolderName);
      if ~exist(combinedSubfolderPath, 'dir')
          mkdir(combinedSubfolderPath);
      end
      copyfile(fullfile(subfolderPathFunc, '*'), combinedSubfolderPath);
    end
  end

  %Iterate through remaining subfolders in the "func1" folder, that were not in the "func" folder.
  for i = 1:length(subfoldersFunc1)
     subfolderName = subfoldersFunc1(i).name;
     subfolderPathFunc1 = fullfile(func1Path, subfolderName);
     matchingSubfolderIndex = find(strcmp({subfoldersFunc.name}, subfolderName), 1);
     if isempty(matchingSubfolderIndex)
         combinedSubfolderPath = fullfile(combinedPath, subfolderName);
         if ~exist(combinedSubfolderPath, 'dir')
             mkdir(combinedSubfolderPath);
         end
         copyfile(fullfile(subfolderPathFunc1, '*'), combinedSubfolderPath);
     end
  end

  % Delete the original "func" and "func1" folders.
  rmdir(funcPath, 's'); % 's' means recursively delete
  rmdir(func1Path, 's');

  % Rename "func_combined" to "func".
  movefile(combinedPath, fullfile(rootDir, 'func'));
end

% Example usage:
% Assuming your directory structure is:
% rootDir/
%   func/subfolderA/file1.txt
%   func/subfolderB/file2.txt
%   func1/subfolderA/file3.txt
%   func1/subfolderC/file4.txt
%
% Call the function:
%  
%  combineFuncFolders('/Users/hadi/Desktop/data/sub-79')