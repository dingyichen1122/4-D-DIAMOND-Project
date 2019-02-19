# 4-D-DIAMOND-Project

4-D Displacement Analysis of Myocardial Mechanical Deformation (DIAMOND) Reveals Segmental Susceptibility to Doxorubicin-Induced Injury and Regeneration in Zebrafish

Authors: Junjie Chen, Yichen Ding, Michael Chen, Jonathan Gau, Nelson Jen, Chadi Nahal, Sally Tu, Cynthia Chen, Steve Zhou, Chih-Chiang Chang, Jintian Lyu, Xiaolei Xu, Tzung K. Hsiai, René R. Sevag Packard

----------------------
MATLAB PACKAGE
This folder contains MATLAB codes and example data for the DIAMOND. To analyze other light-sheet imaging data, please install Amira 6.1 (FEI; Berlin, Germany) and ImageJ / Fiji (NIH, Bethesda, MD) for data preparation. 
DIAMOND is an open-source, modular set of functions for MATLAB and designed for processing data acquired by light-sheet fluorescence microscope. Please see the full manuscript published online in JCI Insight at the following link:  . 
----------------------
COMPATIBILITY NOTES
The functions were mainly developed with 64bit MATLAB versions 2015a in Windows 10.
Note: MATLAB Image Processing Toolbox is required in the analysis. 
----------------------
INSTRUCTIONS (For more information, please see the full manuscript published online in JCI Insight)
1.	Find the diastole and systole phase of a cardiac cycle and save them as 3D tif files with name ‘diastole.tif’ and ‘systole.tif’ in ImageJ / Fiji.

2.	Manually segment out the ventricle and save the label files as 3D tif files with name ‘diastole.Labels.tif’ and ‘systole.Labels.tif’ in Amira 6.1.

3.	Run ‘1_prepImage.m’ in MATLAB (change ImPath to your image folder direction and change variable ‘slice’ in line 4 to the number of slices of the 3D tif).
 
Note: This code will output five 3D tif files: ‘test.tif’, ‘diastole_200.tif’, ‘systole_200.tif’, ‘diaLabel.tif’, and ‘sysLabel200.tif’, as well as two new folders: ‘resample_dia’ and ‘resample_sys’.

4.	Import all five 3D tif files into Amira 6.1 (voxel size is unchanged).

5.	Go to the MULTIPLANR panel. Choose ‘diastole_200.tif’ as the primary data. Align the X-axis (green line in XY plane) with the vertical long axis of the ventricle (you can rotate the axis by placing the cursor at the end of the axis), and align the Z-axis (red line in YZ plane) with the horizontal long axis of the ventricle.  

Choose three random points from the oblique YZ plane (e.g. short axis plane) in a counterclockwise manner and record their 3D position coordinates in Amira 6.1. 

Repeat the same step for ‘systole_200.tif’.

6.	Go to PROJECT panel. Create a ‘Slice’ object for ‘diastole_200.tif’. Left click the Slice object, and in the Properties panel----Options, check ‘set plane’ and choose 3 points in ‘Plane Definition’. Enter the coordinates of the 3 points from step 5 in Amira 6.1. 

Repeat the same step for ‘systole_200.tif’, the object should have name ‘Slice 2’. 

7.	Right click ‘diastole_200.tif’ and search for ‘Resample Transformed Image’ and create the object. In the Properties panel, choose the ‘Reference’ to be ‘Slice’ and click Apply. This should generate an object named ‘diastole_200.transformed’ in Amira 6.1. 

Right click ‘diastole_200.transformed’ and search for ‘Resample’ and create the object. Choose ‘Mode’ to be ‘voxel size’ and change ‘Voxel Size’ to be x=1, y=1, and z=1 in the Properties panel.

Click ‘Apply’ and this should generate an object named ‘diastole_200.resampled’. Right click ‘diastole_200.resampled’ and save it as 3D tif file.  

Repeat the same step for ‘diaLabel.tif’ and ‘test.tif’. Save ‘diaLabel.resampled’ and ‘test.resampled’ as 3D tif files. 

Repeat the same step for ‘systole_200.tif’, ‘sysLabel.tif’ and ‘test.tif’ using ‘Slice 2’ as reference, and save ‘systole_200.resampled’, ‘sysLable.resampled’ and ‘test2.resampled’ as 3D tif files.

8.	Import all resampled files from step 7 to ImageJ (6 files). Select a slice of ‘systole_200.resampled’ where atrioventricular canal could be clearly visualized (may need to adjust the contract in order to see the image). Use the ‘image-transform-rotate’ function of ImageJ so that the atrioventricular canal is vertical (as show in Figure 1E). Apply the same rotation to all files (may use the repeat function of ImageJ ctrl+shift+R). Close all windows and save all changes.

Move ‘diastole_200.resampled’, ‘diaLabel.resampled’ and ‘test.resampled’ to ‘resample_dia’ folder, and move ‘systole_200.resampled’, ‘sysLable.resampled’ and ‘test2.resampled’ to ‘resample_sys’ folder. 

9.	Open ‘2_divider_8_pieces.m’ in MATLAB. Change the ImPath of line 5 and ImPath of line 395 to the image direction. Change variable ‘middle’ in line 22 and line 411 to the number of slices where atrioventricular canal could be clearly visualized in ‘systole_200.resampled’ and ‘diastole_200.resampled’. Run the code and in the prompted windows click once at the center of the ventricle and click once at the center of the atrioventricular canal (need to do this twice for both systole and diastole).

10.	Run ‘3_register.m’ in MATLAB (Please change the ImPath of line 4). It might take 5 to 20 minutes to run this code depending on the computation power of the computer. 

11.	Run ‘4_displacement.m’ in MATLAB, which would generate a ‘vector8.txt’ file in ‘vectors’ folder. Open the ‘vector8.txt’ file, there would be an 8 by 4 matrix. Each row of the matrix has 4 numbers, which are the magnitude of the X component, Y component, Z component and the SUM magnitude of the displacement vector of a specific segment of the ventricle. 

Note: there are total 8 rows. The first row and the eighth row are representing the atrioventricular canal so they are ignored in our analysis. Segment I to VI are represented by the second row to the seventh row.

