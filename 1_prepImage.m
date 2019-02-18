clear all; close all; clc;

num = 200;
slice =70;             % DONT FORGET!!!!
ImPath = 'H:\JCI revision\6dpf\c1\';    % loading path
diaName = 'diastole.tif';
sysName = 'systole.tif';
diaLabel = 'diastole.Labels.tif';
sysLabel = 'systole.Labels.tif';
% trabeculation = 'trabeculation.tif';

resample_dia = [ImPath 'resample_dia\'];
mkdir (resample_dia);

resample_sys = [ImPath 'resample_sys\'];
mkdir (resample_sys);
% 
% diastole  = [ImPath 'diastole\'];
% systole = [ImPath 'systole\'];
% 
% mkdir (diastole);
% mkdir (systole);

 
%%%%%%%%%%%%% test %%%%%%%%%%%%%%%%
test = uint16(zeros(512, 512, num));
test(200:250, 200:300, 90:120)=1;
test(280:300, 250:300, 80:130)=1;
test(320:350, 150:200, 70:110)=1;
% figure; imshow(test(:,:,10));


%%%%%%%%%%%%%%% Image %%%%%%%%%%%%%%%%%%%%
Image1 = uint16(zeros(512,512,num));
Image2 = uint16(zeros(512,512,num));
Image3 = uint16(zeros(512,512,num));
Image4 = uint16(zeros(512,512,num));
Image5 = uint16(zeros(512,512,num));

for i=70:70+slice-1
    Image1(:,:,i) = imread ([ImPath diaName], i-69);
    Image2(:,:,i) = imread ([ImPath sysName], i-69);
    Image3(:,:,i) = imread ([ImPath diaLabel], i-69);
    Image4(:,:,i) = imread ([ImPath sysLabel], i-69);
%     Image5(:,:,i) = imread ([ImPath trabeculation], i-69);
end


for i=1:num
    filename_test = strcat (ImPath, 'test.tif' ) ;
    imwrite (test(:,:,i), filename_test,'WriteMode','append');
    
    filename_dia = strcat (ImPath, 'diastole_200.tif' ) ;
    imwrite (Image1(:,:,i), filename_dia, 'WriteMode','append');
    
    filename_sys = strcat (ImPath, 'systole_200.tif' ) ;
    imwrite (Image2(:,:,i), filename_sys, 'WriteMode','append');
    
    filename_dialabel = strcat (ImPath, 'diaLabel.tif' ) ;
    imwrite (Image3(:,:,i), filename_dialabel, 'WriteMode','append');
    
    filename_syslabel = strcat (ImPath, 'sysLabel.tif' ) ;
    imwrite (Image4(:,:,i), filename_syslabel, 'WriteMode','append');
    
%      filename_tra = strcat (ImPath, 'tralabel.tif' ) ;
%     imwrite (Image5(:,:,i), filename_tra, 'WriteMode','append');
    
end

disp('Finished');
