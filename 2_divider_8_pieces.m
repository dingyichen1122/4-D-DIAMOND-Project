clear all; close all; clc; 

%%%%%%%%%%%%%%%%%%%% load data %%%%%%%%%%%%%%%%%%%%%%%%%%%
% raw data root folder
ImPath = 'H:\JCI revision\6dpf\c1\'; %keep the last slash
% load([ImPath 'systole.mat']);

RawPath = [ImPath 'resample_sys\']; %Raw data path; keep the last slash
% SegPath = [ImPath 'crop_label_dia\']; %Segmentation data path; keep the last slash
NewPath = [ImPath 'sys8\'];  %Saving data path; keep the last slash
TraPath = [ImPath 'Tra8\'];
% list_raw = dir([RawPath '*.tif']);
% list_seg = dir([SegPath '*.tif']);
% [num, ~] = size(list_raw);
rawName = 'systole_200.resampled.tif';  %registered image
dataName = 'sysLabel.resampled.tif';  %registered Label image
% trabeculationName = 'tralabel.resampled.tif';

cols = 167;
rows = 167;
num = 400;
middle =206; %AV canal needs to be clear in both SYS and DIA
GroupNo = 8; % # of divisions
RawData = zeros([rows,cols,num]);
SegData = zeros([rows,cols,num]);
% TraData = zeros([rows,cols,num]);
for n = 1:num 
    RawData(:,:,n) = imread([RawPath rawName], n);  %raw data
    SegData(:,:,n) = imread([RawPath dataName], n); %segmentation
%     TraData(:,:,n) = imread([RawPath trabeculationName], n);
end


% 
% create new folder

NewFolder = cell(1,GroupNo);
for i = 1:GroupNo
    NewFolder{i} = [NewPath num2str(i)];
    mkdir (NewFolder{i});
end

% TraFolder = cell(1,GroupNo);
% for i = 1:GroupNo
%     TraFolder{i} = [TraPath num2str(i)];
%     mkdir (TraFolder{i});
% end

% % re-order Raw
% Temp = cell(num,1);
% for i = 1:num
%     Temp(i)= {list_raw(i).name};
% end
% [list_rawNat, ~] = sort_nat(Temp);
% 
% % re-order Seg
% Temp = cell(num,1);
% for i = 1:num
%     Temp(i)= {list_seg(i).name};
% end
% [list_segNat, ~] = sort_nat(Temp);
% 
% % load data in natural order
% RawData = zeros([rows,cols,num]);
% SegData = zeros([rows,cols,num]);
% for i = 1:num
%     RawData(:,:,i) = double(imread([RawPath list_rawNat{i}])); % 32-bit raw data 
%     temp = double(imread([SegPath list_segNat{i}])); % RGB data
%     [s1,s2] = find(temp(:,:,3)>=0.8*255);
%     if s1 >0
%         for j=1:size(s1)
%             SegData(s1(j),s2(j),i) = 1;
%         end
%     end
%     disp(['loading #' num2str(i)])
% end
CarData = SegData .* RawData; % Segmented ventricle
% save([NewPath 'CarData.mat'],'CarData');



%%%%%%%%%%%%%%%%%%%% divide ventricle %%%%%%%%%%%%%%%%%%%
% pick up the central axis
sample = RawData(:,:,middle);
figure; imshow(sample,[]);
[x,y] = ginputc(2, 'Color','w'); % 1st: center; 2nd: point to the atrium
p = polyfit(x,y,1);
save([NewPath 'xCenter.mat'], 'x');
save([NewPath 'yCenter.mat'], 'y');

% generate lines
step = 2*pi/GroupNo;
xlim = zeros(1,2);
ylim = zeros(1,2);
X_bound = zeros(GroupNo/2,2); % sum of xlim
Y_bound = zeros(GroupNo/2,2); % sum of ylim

for i=1:GroupNo/2
    theta = atan(p(1))+((i-1)*step);
    b = y(1)-tan(theta)*x(1);
    X = [1 cols];
    Y = [1 rows];
    temp_x = (Y-b)/tan(theta);
    temp_y = b+tan(theta)*X;
    ind = 0;
    for j=1:2
        if temp_x(j)>=1 && temp_x(j)<=cols
            xlim(ind+1) = temp_x(j);
            ylim(ind+1) = Y(j);
            ind = ind +1;
        end
        if temp_y(j)>=1 && temp_y(j)<=rows
            xlim(ind+1) = X(j);
            ylim(ind+1) = temp_y(j);
            ind = ind +1;
        end
        if ind >=2
            break;
        end
    end    
    Line(i) = line(xlim,ylim, 'Color','r','LineWidth',2);
    X_bound(i,:) = xlim; % Boundary along X
    Y_bound(i,:) = ylim; % Boundary along Y
end

% divide the matrix
XB = round(X_bound);
YB = round(Y_bound);
[t1,t2] = meshgrid(1:cols,1:rows); %Meshgrid
dm = [t1(:),t2(:)];
Mask = zeros(rows,cols,GroupNo);

% points on the 1st row
[m,n] = find(YB==1);
for i=1:size(m)
   Pt1(i,:)=[XB(m(i),n(i)), YB(m(i),n(i))]; 
end
Pt1=sortrows(Pt1,-1);

% points on the 2nd col
[m,n] = find(XB==1);
for i=1:size(m)
   Pt2(i,:)=[XB(m(i),n(i)), YB(m(i),n(i))]; 
end
Pt2=sortrows(Pt2,2);

% points on the 3rd row
[m,n] = find(YB==rows);
for i=1:size(m)
   Pt3(i,:)=[XB(m(i),n(i)), YB(m(i),n(i))]; 
end
Pt3=sortrows(Pt3,1);

% points on the 4th col
[m,n] = find(XB==cols);
index5 = 0;
index6 = 0;
for i=1:size(m)
   Pt4(i,:)=[XB(m(i),n(i)), YB(m(i),n(i))]; 
   if Pt4(i,2)<=Pt4(1,2)
      Pt5(index5+1,:)=Pt4(i,:);
      index5 = index5+1;
   else
      Pt6(index6+1,:)=Pt4(i,:);
      index6 = index6+1;
   end
end

if index6 ~= 0
Pt5=sortrows(Pt5,-2);
Pt6=sortrows(Pt6,-2);
Points=[Pt5; [cols 1]; Pt1; [1 1]; Pt2; [1 rows]; Pt3; [cols rows]; Pt6];
[nP,~]=size(Points); 
id = 1;

for i=1:nP
      if (Points(i,1)==cols && Points(i,2)==1) || (Points(i,1)==1 && Points(i,2)==1)...
              || (Points(i,1)==1 && Points(i,2)==rows) || (Points(i,1)==cols && Points(i,2)==rows)
          in = inpolygon(dm(:,1),dm(:,2),...
              [Points(i,1) Points(i+1,1) x(1) Points(i-1,1)],...
              [Points(i,2) Points(i+1,2) y(1) Points(i-1,2)]);
          mask = reshape(in,[rows,cols]);
%           figure(id-1); imshow(mask,[]);title(num2str(id-1));
          Mask(:,:,id-1)=mask;
          continue;
      end
      
  
      if i==nP
          in = inpolygon(dm(:,1),dm(:,2),...
              [Points(1,1)  x(1) Points(nP,1)],...
              [Points(1,2)  y(1) Points(nP,2)]);
          mask = reshape(in,[rows,cols]);
%           figure(id); imshow(mask,[]);title(num2str(id));
          Mask(:,:,id)=mask;
          continue;
      end
      
      
      in = inpolygon(dm(:,1),dm(:,2),...
              [Points(i,1)  x(1) Points(i+1,1)],...
              [Points(i,2)  y(1) Points(i+1,2)]);
      mask = reshape(in,[rows,cols]);
%       figure(id); imshow(mask,[]);title(num2str(id));
      Mask(:,:,id)=mask;
      id = id+1;     
end

else
Pt5=sortrows(Pt5,-2);
Points=[Pt5; [cols 1]; Pt1; [1 1]; Pt2; [1 rows]; Pt3; [cols rows]];
[nP,~]=size(Points); 
id = 1;

for i=1:nP
      if (Points(i,1)==cols && Points(i,2)==1) || (Points(i,1)==1 && Points(i,2)==1)...
              || (Points(i,1)==1 && Points(i,2)==rows)
          in = inpolygon(dm(:,1),dm(:,2),...
              [Points(i,1) Points(i+1,1) x(1) Points(i-1,1)],...
              [Points(i,2) Points(i+1,2) y(1) Points(i-1,2)]);
          mask = reshape(in,[rows,cols]);
%           figure(id-1); imshow(mask,[]);title(num2str(id-1));
          Mask(:,:,id-1)=mask;
          continue;
      end
      
  
      if i==nP
          in = inpolygon(dm(:,1),dm(:,2),...
              [Points(1,1)  x(1) Points(nP-1,1) Points(nP,1)],...
              [Points(1,2)  y(1) Points(nP-1,2) Points(nP,2)]);
          mask = reshape(in,[rows,cols]);
%           figure(id-1); imshow(mask,[]);title(num2str(id-1));
          Mask(:,:,id-1)=mask;
          continue;
      end
      
      
      in = inpolygon(dm(:,1),dm(:,2),...
              [Points(i,1)  x(1) Points(i+1,1)],...
              [Points(i,2)  y(1) Points(i+1,2)]);
      mask = reshape(in,[rows,cols]);
%       figure(id); imshow(mask,[]);title(num2str(id));
      Mask(:,:,id)=mask;
      id = id+1;     
end
end
% % points above (x,y)
% [m,n] = find(YB<=y(1));
% for i=1:GroupNo/2
%    Pt(i,:)=[XB(m(i),n(i)), YB(m(i),n(i))];
% end
% Pt_up = sortrows(Pt,1); 
% 
% % points below (x,y)
% [m,n] = find(YB>y(1));
% for i=1:GroupNo/2
%    Pt(i,:)=[XB(m(i),n(i)), YB(m(i),n(i))];
% end
% Pt_down = sortrows(Pt,1); 
% 
% % generate mask
% Mask = zeros(rows,cols,GroupNo);
% corner = zeros(1,4);
% for i=1:(GroupNo/2-1)
%    if Pt_up(i,1)==1 % #1
%        in = inpolygon(dm(:,1),dm(:,2),...
%            [Pt_up(i,1) 1 Pt_up(i+1,1) x(1)],...
%            [Pt_up(i,2) 1 Pt_up(i+1,2) y(1)]);
%        mask = reshape(in,[rows,cols]);
%        corner(1) = 1;
% %        figure; imshow(mask,[]); title(num2str(i)); 
%        Mask(:,:,i)=mask;
%    elseif  Pt_up(i+1,1)==cols % #3
%        in = inpolygon(dm(:,1),dm(:,2),...
%            [Pt_up(i+1,1) cols Pt_up(i,1) x(1)],...
%            [Pt_up(i+1,2) 1 Pt_up(i,2) y(1)]);
%        mask = reshape(in,[rows,cols]);
%        corner(2) = 1;
% %        figure; imshow(mask,[]); title(num2str(i));
%        Mask(:,:,i)=mask;
%    else
%        in = inpolygon(dm(:,1),dm(:,2),...
%            [Pt_up(i,1) Pt_up(i+1,1) x(1)],...
%            [Pt_up(i,2) Pt_up(i+1,2) y(1)]);
%        mask = reshape(in,[rows,cols]);
% %        figure; imshow(mask,[]); title(num2str(i));
%        Mask(:,:,i)=mask;
%    end
%    
%    if Pt_down(i,1)==1 % #7
%        in = inpolygon(dm(:,1),dm(:,2),...
%            [Pt_down(i,1) 1 Pt_down(i+1,1) x(1)],...
%            [Pt_down(i,2) rows Pt_down(i+1,2) y(1)]);
%        mask = reshape(in,[rows,cols]);
%        corner(4) = 1;
% %        figure; imshow(mask,[]); title(num2str(GroupNo-i));
%        Mask(:,:,GroupNo-i)=mask;
%    elseif  Pt_down(i+1,1)==cols % #5
%        in = inpolygon(dm(:,1),dm(:,2),...
%            [Pt_down(i+1,1) cols Pt_down(i,1) x(1)],...
%            [Pt_down(i+1,2) rows Pt_down(i,2) y(1)]);
%        mask = reshape(in,[rows,cols]);
%        corner(3) = 1;
% %        figure; imshow(mask,[]); title(num2str(GroupNo-i));
%        Mask(:,:,GroupNo-i)=mask;
%    else
%        in = inpolygon(dm(:,1),dm(:,2),...
%            [Pt_down(i,1) Pt_down(i+1,1) x(1)],...
%            [Pt_down(i,2) Pt_down(i+1,2) y(1)]);
%        mask = reshape(in,[rows,cols]);
% %        figure; imshow(mask,[]); title(num2str(GroupNo-i));
%        Mask(:,:,GroupNo-i)=mask;
%    end
%    
%    if i+1 == GroupNo/2       
%        if  corner(1) == 0
%            if corner(4) ~= 0
%                in = inpolygon(dm(:,1),dm(:,2),...
%                    [Pt_up(1,1) 1 Pt_down(1,1) x(1)],...
%                    [Pt_up(1,2) 1 Pt_down(1,2) y(1)]);
%                mask = reshape(in,[rows,cols]);
% %                figure; imshow(mask,[]);title(num2str(GroupNo));
%                Mask(:,:,GroupNo)=mask;
%            end
%        elseif corner(4) == 0
%            in = inpolygon(dm(:,1),dm(:,2),...
%                 [Pt_up(1,1) 1 Pt_down(1,1) x(1)],...
%                 [Pt_up(1,2) rows Pt_down(1,2) y(1)]);
%            mask = reshape(in,[rows,cols]);
% %            figure; imshow(mask,[]);title(num2str(GroupNo));
%            Mask(:,:,GroupNo)=mask;
%        else
%            in = inpolygon(dm(:,1),dm(:,2),...
%                [Pt_up(1,1) Pt_down(1,1) x(1)],...
%                [Pt_up(1,2) Pt_down(1,2) y(1)]);
%            mask = reshape(in,[rows,cols]);
% %            figure; imshow(mask,[]);title(num2str(GroupNo));
%            Mask(:,:,GroupNo)=mask;
%        end
%        
%        if corner(2) == 0
%            if corner(3) ~= 0
%                in = inpolygon(dm(:,1),dm(:,2),...
%                    [Pt_up(i+1,1) cols Pt_down(i+1,1) x(1)],...
%                    [Pt_up(i+1,2) 1 Pt_down(i+1,2) y(1)]);
%                mask = reshape(in,[rows,cols]);
% %                figure; imshow(mask,[]);title(num2str(GroupNo/2));
%                Mask(:,:,GroupNo/2)=mask;
%            end
%        elseif corner(3) == 0
%            in = inpolygon(dm(:,1),dm(:,2),...
%                [Pt_up(i+1,1) cols Pt_down(i+1,1) x(1)],...
%                [Pt_up(i+1,2) rows Pt_down(i+1,2) y(1)]);
%            mask = reshape(in,[rows,cols]);
% %            figure; imshow(mask,[]);title(num2str(GroupNo/2));
%            Mask(:,:,GroupNo/2)=mask;
%        else
%            in = inpolygon(dm(:,1),dm(:,2),...
%                [Pt_up(i+1,1) Pt_down(i+1,1) x(1)],...
%                [Pt_up(i+1,2) Pt_down(i+1,2) y(1)]);
%            mask = reshape(in,[rows,cols]);
% %            figure; imshow(mask,[]);title(num2str(GroupNo/2));
%            Mask(:,:,GroupNo/2)=mask;
%        end             
%    end
% end

for i=1:GroupNo
   figure; imshow(Mask(:,:,i),[]); title(num2str(i));
   %NewFolder = [ImPath 'dia\' num2str(i)];
   for j=1:num
      Output(:,:,j) = Mask(:,:,i).* SegData(:,:,j);
      filename = [NewFolder{i} '\D' num2str(i) '_' num2str(j) '.tif'];
      imwrite(Output(:,:,j), filename, 'tif');
      disp(['writing' num2str(i) '_' num2str(j)]);
   end
end

% for i=1:GroupNo
%    figure; imshow(Mask(:,:,i),[]); title(num2str(i));
%    %NewFolder = [ImPath 'dia\' num2str(i)];
%    for j=1:num
%       Output(:,:,j) = Mask(:,:,i).* TraData(:,:,j);
%       filename = [TraFolder{i} '\D' num2str(i) '_' num2str(j) '.tif'];
%       imwrite(Output(:,:,j), filename, 'tif');
%       disp(['writing' num2str(i) '_' num2str(j)]);
%    end
% end


clear all; clc; 
%%%%%%%%%%%%%%%%%%%% load data %%%%%%%%%%%%%%%%%%%%%%%%%%%
% raw data root folder
ImPath = 'H:\JCI revision\6dpf\c1\'; %keep the last slash
% load([ImPath 'systole.mat']);
RawPath_dia = [ImPath 'resample_dia\']; %Raw data path; keep the last slash
% SegPath = [ImPath 'crop_label_dia\']; %Segmentation data path; keep the last slash
NewPath_dia = [ImPath 'dia8\'];  %Saving data path; keep the last slash
% TraPath = [ImPath 'Tra8\'];
% list_raw = dir([RawPath '*.tif']);
% list_seg = dir([SegPath '*.tif']);
% [num, ~] = size(list_raw);
rawName_dia = 'diastole_200.resampled.tif';  %registered image
dataName_dia = 'diaLabel.resampled.tif';    %registered Label image
% trabeculationName = 'tralabel.resampled.tif';

cols = 167 ;
rows = 167;
num = 400;
middle =206; %AV canal needs to be clear in both SYS and DIA
GroupNo = 8; % # of divisions

RawData_dia = zeros([rows,cols,num]);
SegData_dia = zeros([rows,cols,num]);
TraData = zeros([rows,cols,num]);
for n = 1:num 
    RawData_dia(:,:,n) = imread([RawPath_dia rawName_dia], n);  %raw data
    SegData_dia(:,:,n) = imread([RawPath_dia dataName_dia], n);  %segmentation
%     TraData(:,:,n) = imread([RawPath_dia trabeculationName], n);
end

% # of divisions
% 
% create new folder

NewFolder = cell(1,GroupNo);
for i = 1:GroupNo
    NewFolder{i} = [NewPath_dia num2str(i)];
    mkdir (NewFolder{i});
end

% TraFolder = cell(1,GroupNo);
% for i = 1:GroupNo
%     TraFolder{i} = [TraPath num2str(i)];
%     mkdir (TraFolder{i});
% end

% % re-order Raw
% Temp = cell(num,1);
% for i = 1:num
%     Temp(i)= {list_raw(i).name};
% end
% [list_rawNat, ~] = sort_nat(Temp);
% 
% % re-order Seg
% Temp = cell(num,1);
% for i = 1:num
%     Temp(i)= {list_seg(i).name};
% end
% [list_segNat, ~] = sort_nat(Temp);
% 
% % load data in natural order
% RawData = zeros([rows,cols,num]);
% SegData = zeros([rows,cols,num]);
% for i = 1:num
%     RawData(:,:,i) = double(imread([RawPath list_rawNat{i}])); % 32-bit raw data 
%     temp = double(imread([SegPath list_segNat{i}])); % RGB data
%     [s1,s2] = find(temp(:,:,3)>=0.8*255);
%     if s1 >0
%         for j=1:size(s1)
%             SegData(s1(j),s2(j),i) = 1;
%         end
%     end
%     disp(['loading #' num2str(i)])
% end
CarData = SegData_dia .* RawData_dia; % Segmented ventricle
% save([NewPath 'CarData.mat'],'CarData');

%%%%%%%%%%%%%%%%%%%% divide ventricle %%%%%%%%%%%%%%%%%%%
% pick up the central axis
sample = RawData_dia(:,:,middle);
figure; imshow(sample,[]);
[x,y] = ginputc(2, 'Color','w'); % 1st: center; 2nd: point to the atrium
p = polyfit(x,y,1);
save([NewPath_dia 'xCenter.mat'], 'x');
save([NewPath_dia 'yCenter.mat'], 'y');

% generate lines
step = 2*pi/GroupNo;
xlim = zeros(1,2);
ylim = zeros(1,2);
X_bound = zeros(GroupNo/2,2); % sum of xlim
Y_bound = zeros(GroupNo/2,2); % sum of ylim

for i=1:GroupNo/2
    theta = atan(p(1))+((i-1)*step);
    b = y(1)-tan(theta)*x(1);
    X = [1 cols];
    Y = [1 rows];
    temp_x = (Y-b)/tan(theta);
    temp_y = b+tan(theta)*X;
    ind = 0;
    for j=1:2
        if temp_x(j)>=1 && temp_x(j)<=cols
            xlim(ind+1) = temp_x(j);
            ylim(ind+1) = Y(j);
            ind = ind +1;
        end
        if temp_y(j)>=1 && temp_y(j)<=rows
            xlim(ind+1) = X(j);
            ylim(ind+1) = temp_y(j);
            ind = ind +1;
        end
        if ind >=2
            break;
        end
    end    
    Line(i) = line(xlim,ylim, 'Color','r','LineWidth',2);
    X_bound(i,:) = xlim; % Boundary along X
    Y_bound(i,:) = ylim; % Boundary along Y
end

% divide the matrix
XB = round(X_bound);
YB = round(Y_bound);
[t1,t2] = meshgrid(1:cols,1:rows); %Meshgrid
dm = [t1(:),t2(:)];
Mask = zeros(rows,cols,GroupNo);

% points on the 1st row
[m,n] = find(YB==1);
for i=1:size(m)
   Pt1(i,:)=[XB(m(i),n(i)), YB(m(i),n(i))]; 
end
Pt1=sortrows(Pt1,-1);

% points on the 2nd col
[m,n] = find(XB==1);
for i=1:size(m)
   Pt2(i,:)=[XB(m(i),n(i)), YB(m(i),n(i))]; 
end
Pt2=sortrows(Pt2,2);

% points on the 3rd row
[m,n] = find(YB==rows);
for i=1:size(m)
   Pt3(i,:)=[XB(m(i),n(i)), YB(m(i),n(i))]; 
end
Pt3=sortrows(Pt3,1);

% points on the 4th col
[m,n] = find(XB==cols);
index5 = 0;
index6 = 0;
for i=1:size(m)
   Pt4(i,:)=[XB(m(i),n(i)), YB(m(i),n(i))]; 
   if Pt4(i,2)<=Pt4(1,2)
      Pt5(index5+1,:)=Pt4(i,:);
      index5 = index5+1;
   else
      Pt6(index6+1,:)=Pt4(i,:);
      index6 = index6+1;
   end
end

if index6 ~= 0
Pt5=sortrows(Pt5,-2);
Pt6=sortrows(Pt6,-2);
Points=[Pt5; [cols 1]; Pt1; [1 1]; Pt2; [1 rows]; Pt3; [cols rows]; Pt6];
[nP,~]=size(Points); 
id = 1;

for i=1:nP
      if (Points(i,1)==cols && Points(i,2)==1) || (Points(i,1)==1 && Points(i,2)==1)...
              || (Points(i,1)==1 && Points(i,2)==rows) || (Points(i,1)==cols && Points(i,2)==rows)
          in = inpolygon(dm(:,1),dm(:,2),...
              [Points(i,1) Points(i+1,1) x(1) Points(i-1,1)],...
              [Points(i,2) Points(i+1,2) y(1) Points(i-1,2)]);
          mask = reshape(in,[rows,cols]);
%           figure(id-1); imshow(mask,[]);title(num2str(id-1));
          Mask(:,:,id-1)=mask;
          continue;
      end
      
  
      if i==nP
          in = inpolygon(dm(:,1),dm(:,2),...
              [Points(1,1)  x(1) Points(nP,1)],...
              [Points(1,2)  y(1) Points(nP,2)]);
          mask = reshape(in,[rows,cols]);
%           figure(id); imshow(mask,[]);title(num2str(id));
          Mask(:,:,id)=mask;
          continue;
      end
      
      
      in = inpolygon(dm(:,1),dm(:,2),...
              [Points(i,1)  x(1) Points(i+1,1)],...
              [Points(i,2)  y(1) Points(i+1,2)]);
      mask = reshape(in,[rows,cols]);
%       figure(id); imshow(mask,[]);title(num2str(id));
      Mask(:,:,id)=mask;
      id = id+1;     
end

else
Pt5=sortrows(Pt5,-2);
Points=[Pt5; [cols 1]; Pt1; [1 1]; Pt2; [1 rows]; Pt3; [cols rows]];
[nP,~]=size(Points); 
id = 1;

for i=1:nP
      if (Points(i,1)==cols && Points(i,2)==1) || (Points(i,1)==1 && Points(i,2)==1)...
              || (Points(i,1)==1 && Points(i,2)==rows)
          in = inpolygon(dm(:,1),dm(:,2),...
              [Points(i,1) Points(i+1,1) x(1) Points(i-1,1)],...
              [Points(i,2) Points(i+1,2) y(1) Points(i-1,2)]);
          mask = reshape(in,[rows,cols]);
%           figure(id-1); imshow(mask,[]);title(num2str(id-1));
          Mask(:,:,id-1)=mask;
          continue;
      end
      
  
      if i==nP
          in = inpolygon(dm(:,1),dm(:,2),...
              [Points(1,1)  x(1) Points(nP-1,1) Points(nP,1)],...
              [Points(1,2)  y(1) Points(nP-1,2) Points(nP,2)]);
          mask = reshape(in,[rows,cols]);
%           figure(id-1); imshow(mask,[]);title(num2str(id-1));
          Mask(:,:,id-1)=mask;
          continue;
      end
      
      
      in = inpolygon(dm(:,1),dm(:,2),...
              [Points(i,1)  x(1) Points(i+1,1)],...
              [Points(i,2)  y(1) Points(i+1,2)]);
      mask = reshape(in,[rows,cols]);
%       figure(id); imshow(mask,[]);title(num2str(id));
      Mask(:,:,id)=mask;
      id = id+1;     
end
end
% % points above (x,y)
% [m,n] = find(YB<=y(1));
% for i=1:GroupNo/2
%    Pt(i,:)=[XB(m(i),n(i)), YB(m(i),n(i))];
% end
% Pt_up = sortrows(Pt,1); 
% 
% % points below (x,y)
% [m,n] = find(YB>y(1));
% for i=1:GroupNo/2
%    Pt(i,:)=[XB(m(i),n(i)), YB(m(i),n(i))];
% end
% Pt_down = sortrows(Pt,1); 
% 
% % generate mask
% Mask = zeros(rows,cols,GroupNo);
% corner = zeros(1,4);
% for i=1:(GroupNo/2-1)
%    if Pt_up(i,1)==1 % #1
%        in = inpolygon(dm(:,1),dm(:,2),...
%            [Pt_up(i,1) 1 Pt_up(i+1,1) x(1)],...
%            [Pt_up(i,2) 1 Pt_up(i+1,2) y(1)]);
%        mask = reshape(in,[rows,cols]);
%        corner(1) = 1;
% %        figure; imshow(mask,[]); title(num2str(i)); 
%        Mask(:,:,i)=mask;
%    elseif  Pt_up(i+1,1)==cols % #3
%        in = inpolygon(dm(:,1),dm(:,2),...
%            [Pt_up(i+1,1) cols Pt_up(i,1) x(1)],...
%            [Pt_up(i+1,2) 1 Pt_up(i,2) y(1)]);
%        mask = reshape(in,[rows,cols]);
%        corner(2) = 1;
% %        figure; imshow(mask,[]); title(num2str(i));
%        Mask(:,:,i)=mask;
%    else
%        in = inpolygon(dm(:,1),dm(:,2),...
%            [Pt_up(i,1) Pt_up(i+1,1) x(1)],...
%            [Pt_up(i,2) Pt_up(i+1,2) y(1)]);
%        mask = reshape(in,[rows,cols]);
% %        figure; imshow(mask,[]); title(num2str(i));
%        Mask(:,:,i)=mask;
%    end
%    
%    if Pt_down(i,1)==1 % #7
%        in = inpolygon(dm(:,1),dm(:,2),...
%            [Pt_down(i,1) 1 Pt_down(i+1,1) x(1)],...
%            [Pt_down(i,2) rows Pt_down(i+1,2) y(1)]);
%        mask = reshape(in,[rows,cols]);
%        corner(4) = 1;
% %        figure; imshow(mask,[]); title(num2str(GroupNo-i));
%        Mask(:,:,GroupNo-i)=mask;
%    elseif  Pt_down(i+1,1)==cols % #5
%        in = inpolygon(dm(:,1),dm(:,2),...
%            [Pt_down(i+1,1) cols Pt_down(i,1) x(1)],...
%            [Pt_down(i+1,2) rows Pt_down(i,2) y(1)]);
%        mask = reshape(in,[rows,cols]);
%        corner(3) = 1;
% %        figure; imshow(mask,[]); title(num2str(GroupNo-i));
%        Mask(:,:,GroupNo-i)=mask;
%    else
%        in = inpolygon(dm(:,1),dm(:,2),...
%            [Pt_down(i,1) Pt_down(i+1,1) x(1)],...
%            [Pt_down(i,2) Pt_down(i+1,2) y(1)]);
%        mask = reshape(in,[rows,cols]);
% %        figure; imshow(mask,[]); title(num2str(GroupNo-i));
%        Mask(:,:,GroupNo-i)=mask;
%    end
%    
%    if i+1 == GroupNo/2       
%        if  corner(1) == 0
%            if corner(4) ~= 0
%                in = inpolygon(dm(:,1),dm(:,2),...
%                    [Pt_up(1,1) 1 Pt_down(1,1) x(1)],...
%                    [Pt_up(1,2) 1 Pt_down(1,2) y(1)]);
%                mask = reshape(in,[rows,cols]);
% %                figure; imshow(mask,[]);title(num2str(GroupNo));
%                Mask(:,:,GroupNo)=mask;
%            end
%        elseif corner(4) == 0
%            in = inpolygon(dm(:,1),dm(:,2),...
%                 [Pt_up(1,1) 1 Pt_down(1,1) x(1)],...
%                 [Pt_up(1,2) rows Pt_down(1,2) y(1)]);
%            mask = reshape(in,[rows,cols]);
% %            figure; imshow(mask,[]);title(num2str(GroupNo));
%            Mask(:,:,GroupNo)=mask;
%        else
%            in = inpolygon(dm(:,1),dm(:,2),...
%                [Pt_up(1,1) Pt_down(1,1) x(1)],...
%                [Pt_up(1,2) Pt_down(1,2) y(1)]);
%            mask = reshape(in,[rows,cols]);
% %            figure; imshow(mask,[]);title(num2str(GroupNo));
%            Mask(:,:,GroupNo)=mask;
%        end
%        
%        if corner(2) == 0
%            if corner(3) ~= 0
%                in = inpolygon(dm(:,1),dm(:,2),...
%                    [Pt_up(i+1,1) cols Pt_down(i+1,1) x(1)],...
%                    [Pt_up(i+1,2) 1 Pt_down(i+1,2) y(1)]);
%                mask = reshape(in,[rows,cols]);
% %                figure; imshow(mask,[]);title(num2str(GroupNo/2));
%                Mask(:,:,GroupNo/2)=mask;
%            end
%        elseif corner(3) == 0
%            in = inpolygon(dm(:,1),dm(:,2),...
%                [Pt_up(i+1,1) cols Pt_down(i+1,1) x(1)],...
%                [Pt_up(i+1,2) rows Pt_down(i+1,2) y(1)]);
%            mask = reshape(in,[rows,cols]);
% %            figure; imshow(mask,[]);title(num2str(GroupNo/2));
%            Mask(:,:,GroupNo/2)=mask;
%        else
%            in = inpolygon(dm(:,1),dm(:,2),...
%                [Pt_up(i+1,1) Pt_down(i+1,1) x(1)],...
%                [Pt_up(i+1,2) Pt_down(i+1,2) y(1)]);
%            mask = reshape(in,[rows,cols]);
% %            figure; imshow(mask,[]);title(num2str(GroupNo/2));
%            Mask(:,:,GroupNo/2)=mask;
%        end             
%    end
% end


for i=1:GroupNo
   figure; imshow(Mask(:,:,i),[]); title(num2str(i));
   %NewFolder = [ImPath 'dia\' num2str(i)];
   for j=1:num
      Output(:,:,j) = Mask(:,:,i).* SegData_dia(:,:,j);
      filename = [NewFolder{i} '\D' num2str(i) '_' num2str(j) '.tif'];
      imwrite(Output(:,:,j), filename, 'tif');
      disp(['writing' num2str(i) '_' num2str(j)]);
   end
end

% 
% for i=1:GroupNo
%    figure; imshow(Mask(:,:,i),[]); title(num2str(i));
%    %NewFolder = [ImPath 'dia\' num2str(i)];
%    for j=1:num
%       Output(:,:,j) = Mask(:,:,i).* TraData(:,:,j);
%       filename = [TraFolder{i} '\D' num2str(i) '_' num2str(j) '.tif'];
%       imwrite(Output(:,:,j), filename, 'tif');
%       disp(['writing' num2str(i) '_' num2str(j)]);
%    end
% end

disp('Finished');


