%% Registration of systole and diastole
clear all; close all; clc;

ImPath = 'H:\JCI revision\6dpf\c1\';    % loading path
diaPath = [ImPath 'resample_dia\'];
sysPath = [ImPath 'resample_sys\'];
GroupNo = 8; 
% TestTform = [ImPath 'test_tform_0.65\'];
% mCPath = [ImPath 'mcherry_0.65\'];
% mCPathTform = [ImPath 'mcherry_tform_0.65\'];

cols =167;
rows =167;
num =400;    % # of resampled images

fixedVolume = uint16(zeros(rows,cols,num));
movingVolume = uint16(zeros(rows,cols,num));
image = uint16(zeros(rows,cols,num));
imageTform1 = uint16(zeros(rows,cols,num));
imageTform2 = uint16(zeros(rows,cols,num));
imageTform3 = uint16(zeros(rows,cols,num));
imageTform4 = uint16(zeros(rows,cols,num));
imageTform5 = uint16(zeros(rows,cols,num));
imageTform6 = uint16(zeros(rows,cols,num));
imageTform7 = uint16(zeros(rows,cols,num));
imageTform8 = uint16(zeros(rows,cols,num));
% Rmoving = imref3d(size(movingVolume));
% Rfixed = imref3d(size(fixedVolume));

    for n = 1:num 
         fixedVolume(:,:,n) = imread ([sysPath 'test2.resampled.tif'], n) ;    %diastole
         movingVolume(:,:,n) = imread ([diaPath 'test.resampled.tif'], n);  %systole
         image(:,:,n) = imread ([sysPath 'sysLabel.resampled.tif'], n);   %diastole  
          imageTform1(:,:,n) = imread ([ImPath, 'dia8\', num2str(1), '\D', num2str(1), '_', num2str(n), '.tif']); 
          imageTform2(:,:,n) = imread ([ImPath, 'dia8\', num2str(2), '\D', num2str(2), '_', num2str(n), '.tif']); 
          imageTform3(:,:,n) = imread ([ImPath, 'dia8\', num2str(3), '\D', num2str(3), '_', num2str(n), '.tif']); 
          imageTform4(:,:,n) = imread ([ImPath, 'dia8\', num2str(4), '\D', num2str(4), '_', num2str(n), '.tif']); 
          imageTform5(:,:,n) = imread ([ImPath, 'dia8\', num2str(5), '\D', num2str(5), '_', num2str(n), '.tif']); 
          imageTform6(:,:,n) = imread ([ImPath, 'dia8\', num2str(6), '\D', num2str(6), '_', num2str(n), '.tif']); 
          imageTform7(:,:,n) = imread ([ImPath, 'dia8\', num2str(7), '\D', num2str(7), '_', num2str(n), '.tif']); 
          imageTform8(:,:,n) = imread ([ImPath, 'dia8\', num2str(8), '\D', num2str(8), '_', num2str(n), '.tif']); 
    end
    
          


centerFixed = size(fixedVolume)/2;
centerMoving = size(movingVolume)/2;
figure
imshowpair(movingVolume(:,:,200), fixedVolume(:,:,200));
title('Unregistered Axial slice')

[optimizer,metric] = imregconfig('multimodal');

optimizer.InitialRadius = 0.0005;
optimizer.Epsilon = 1.5e-4;
optimizer.GrowthFactor = 1.01;
optimizer.MaximumIterations = 1000;

tform = imregtform(movingVolume, fixedVolume, 'rigid', optimizer, metric) ;

% centerXWorld = mean(Rmoving.XWorldLimits);
% centerYWorld = mean(Rmoving.YWorldLimits);
% centerZWorld = mean(Rmoving.ZWorldLimits);
% [xWorld,yWorld,zWorld] = transformPointsForward(tform,centerXWorld,centerYWorld,centerZWorld);
% 
% [r,c,p] = worldToSubscript(Rfixed,xWorld,yWorld,zWorld)

movingRegisteredVolume = imwarp(movingVolume, tform, 'OutputView', imref3d(size(fixedVolume)));
% movingRegisteredVolume = imregister(movingVolume, fixedVolume, 'rigid', optimizer, metric);

figure
imshowpair(movingRegisteredVolume(:,:,round(centerFixed(3))), fixedVolume(:,:,round(centerFixed(3))),...
    'Scaling', 'joint');
title('Axial slice of registered volume.')

% helperVolumeRegistration(fixedVolume,movingRegisteredVolume);

imageRegistered1 = imwarp(imageTform1, tform, 'OutputView', imref3d(size(fixedVolume)));  % systole
imageRegistered2 = imwarp(imageTform2, tform, 'OutputView', imref3d(size(fixedVolume))); 
imageRegistered3 = imwarp(imageTform3, tform, 'OutputView', imref3d(size(fixedVolume))); 
imageRegistered4 = imwarp(imageTform4, tform, 'OutputView', imref3d(size(fixedVolume))); 
imageRegistered5 = imwarp(imageTform5, tform, 'OutputView', imref3d(size(fixedVolume))); 
imageRegistered6 = imwarp(imageTform6, tform, 'OutputView', imref3d(size(fixedVolume))); 
imageRegistered7 = imwarp(imageTform7, tform, 'OutputView', imref3d(size(fixedVolume))); 
imageRegistered8 = imwarp(imageTform8, tform, 'OutputView', imref3d(size(fixedVolume))); 

NewPath_dia = [ImPath 'dia8_reg\'];
NewFolder = cell(1,GroupNo);
for i = 1:GroupNo
    NewFolder{i} = [NewPath_dia num2str(i)];
    mkdir (NewFolder{i});
end

    for i=1:num
        filename1 = strcat (NewPath_dia, '1\D1' , '_', num2str(i), '.tif') ;
        imwrite (imageRegistered1(:,:,i), filename1);
        
        filename2 = strcat (NewPath_dia, '2\D2' , '_', num2str(i), '.tif') ;
        imwrite (imageRegistered2(:,:,i), filename2);
        
        filename3 = strcat (NewPath_dia, '3\D3' , '_', num2str(i), '.tif') ;
        imwrite (imageRegistered3(:,:,i), filename3);
        
        filename4 = strcat (NewPath_dia, '4\D4' , '_', num2str(i), '.tif') ;
        imwrite (imageRegistered4(:,:,i), filename4);
        
        filename5 = strcat (NewPath_dia, '5\D5' , '_', num2str(i), '.tif') ;
        imwrite (imageRegistered5(:,:,i), filename5);
        
        filename6= strcat (NewPath_dia, '6\D6' , '_', num2str(i), '.tif') ;
        imwrite (imageRegistered6(:,:,i), filename6);
        
        filename7 = strcat (NewPath_dia, '7\D7' , '_', num2str(i), '.tif') ;
        imwrite (imageRegistered7(:,:,i), filename7);
        
        filename8 = strcat (NewPath_dia, '8\D8' , '_', num2str(i), '.tif') ;
        imwrite (imageRegistered8(:,:,i), filename8);
    end
% save([ImPath 'systole.mat'],'image');
% save([ImPath 'diastole.mat'],'imageRegistered');
% 
% systole = image;
% diastole = imageRegistered;

%helperVolumeRegistration(image,imageRegistered);

 %figure; imshowpair(image(:,:,200), imageRegistered(:,:,200));

% figure; imshowpair(image(:,:,200), imageTform(:,:,200));

disp('Finished');