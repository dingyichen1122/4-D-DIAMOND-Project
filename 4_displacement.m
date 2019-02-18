clear all; close all; clc; 

% raw data root folder
ImPath = 'F:\JCI insight revision 12212018\6dpf\4dd6\'; %keep the last slash; keep it the same as VF_divider
DiaPath = [ImPath 'dia8_reg\'];  %Saving data path; keep the last slash
SysPath = [ImPath 'sys8\'];  %Saving data path; keep the last slash

pixelSize_x=1; %um
pixelSize_y=1;
pixelSize_z=1;

rows = 167; 
cols = 167;
num = 400;
 NewPath = [ImPath 'vectors\' ];
 mkdir(NewPath);
 
 for GroupNo = 1:8
    
%     NewPath = [ImPath 'reg\' num2str(GroupNo) '\'];
%     mkdir(NewPath);

    fixedPath = [DiaPath num2str(GroupNo) '\']; % diastolic data path; keep the last slash
    movingPath = [SysPath num2str(GroupNo) '\']; % systolic data path; keep the last slash

    % Read fixed and moving 3D images from file
fixed3D = zeros(rows, cols, num);
    moving3D = zeros(rows, cols, num);
    for i = 1:num
        fixed = im2bw(imread([fixedPath 'D' num2str(GroupNo) '_' int2str(i) '.tif']), 0.00001);
%         fixed = imread([DiaPath 'dia.tif'], i);
        fixed3D(:,:,i) = fixed;
        
        moving = im2bw(imread([movingPath 'D' num2str(GroupNo) '_' int2str(i) '.tif']), 0.00001);
%         moving = imread([SysPath 'sys.tif'], i);
        moving3D(:,:,i) = moving;
    end
    
    k1 = find(fixed3D);
    [total_fix, ~] = size(k1);

    k2 = find(moving3D);
    [total_mov, ~] = size(k2);

    [x,y,z] = meshgrid(1:cols, 1:rows, 1:num);

    fix_cx = sum(sum(sum(fixed3D.*x)))/total_fix/pixelSize_x;   %um in the physical space
    fix_cy = sum(sum(sum(fixed3D.*y)))/total_fix/pixelSize_y;   %um
    fix_cz = sum(sum(sum(fixed3D.*z)))/total_fix/pixelSize_z;      %um
    cent_fix = [fix_cx, fix_cy, fix_cz];

    mov_cx = sum(sum(sum(moving3D.*x)))/total_mov/pixelSize_x;   
    mov_cy = sum(sum(sum(moving3D.*y)))/total_mov/pixelSize_y;  
    mov_cz = sum(sum(sum(moving3D.*z)))/total_mov/pixelSize_z;
    cent_mov = [mov_cx, mov_cy, mov_cz];

    disVec = cent_mov - cent_fix;
    sum_all = (disVec(1)^2+disVec(2)^2+disVec(3)^2)^0.5;
    vector = [disVec sum_all];
    %save([NewPath 'vector.txt'],'vector','-ascii');
      if GroupNo == 1
      save([NewPath 'vector8.txt'],'vector','-ascii');
      else
          save([NewPath 'vector8.txt'],'vector','-ascii', '-append');
      end 
scale = 1;
fontsize = 12;
fontname = 'Arial';

figure
hq_x = quiver3(fix_cx,fix_cy,fix_cz,disVec(1),0,0,scale);
% hq_x.LineWidth = 2;
% hq_x.MaxHeadSize = 0.3;
hold on
hq_y = quiver3(fix_cx,fix_cy,fix_cz,0,disVec(2),0,scale);
% hq_y.LineWidth = 2;
% hq_y.MaxHeadSize = 0.3;
hq_z = quiver3(fix_cx,fix_cy,fix_cz,0,0,disVec(3),scale);
% hq_z.LineWidth = 2;
% hq_z.MaxHeadSize = 0.3;
hq_mag = quiver3(fix_cx,fix_cy,fix_cz,disVec(1),disVec(2),disVec(3),scale);
% hq_mag.LineWidth = 2;
ax = gca;
% ax.XLim = [-0.5,u+0.5];
% ax.YLim = [-0.5,v+0.5];
% ax.ZLim = [-0.5,w+0.5];
ax.Color = [0.95,0.95,0.95];
ax.Box = 'on';
ax.BoxStyle = 'back';
ax.XColor = 'k';
ax.YColor = 'k';
ax.ZColor = 'k';
ax.GridLineStyle = '--';
ax.FontSize = fontsize;
ax.FontName = fontname;
% ax.XLabel.String = 'x (\mum)';
% ax.XLabel.Rotation = 15;
% ax.YLabel.String = 'y (\mum)';
% ax.YLabel.Rotation = 335;
% ax.ZLabel.String = 'z (\mum)';
% quiver3(0,0,0,sum(abs(u(:))),sum(abs(v(:))),0,scale,'LineWidth',2, 'LineStyle',':','ShowArrowHead','off');
hold off

 end
       

disp('Finished');



