function retina()

RetinaFunctions.displaying_test();
obj1=RetinaFunctions;
obj1.display_obj(3);

obj1.x1=10;
obj1.x1
obj1.add(4);
pause;

radius_of_retinal_patch=10; %10% OF IT IS FOVEA.
[image_rods,image_cones]=retinal_convoluter(radius_of_retinal_patch);
%radius - RADIUS OF THE MASK
%final_image_rods - MATRIX WITH ONLY RODS IN SUROUNDING. CENTER FOVEA IS ZERO
%image_cones - 3D MATRIX WITH ONLY CONES.

%[img1,nw_rd]= separate_rods_cones(final_image,radius);
% "nw_rd" is the distance from the center where pixels are to be converted to rods
nw_rd=ceil(0.10*radius_of_retinal_patch )+1; %its the distance from the center where pixels are to be converted to rods
[rods_coupled]=coupling_rods(radius_of_retinal_patch,nw_rd,image_rods); %IT SHOULD RETURN COUPLED MATRIX OF RODS..SOME RODS ON THE BORDER OF RETINA ARE LOST IN COUPLING. ITS FINE.

%never add word figure before image.. it destroys the image, i wonder
%how.but it does.i hate it.
[fovea_rows,fovea_columns,dim]=size(image_cones);%ROWS = COLUMNS
[rod_rows,rod_columns,dim]=size(image_rods);%ROWS = COLUMNS
bipolar_code=randi(4,fovea_rows);%CODE MATRIX. VALUES 1-4. 1=R-G, 2=G-R, 3=B-Y, 4=Y-B. ALL ARE CENTER ON SURROUND OFF.. ROWS = COLUMNS

fovea_cent_suround_mask=FovealCenterSurroundMask(fovea_rows,fovea_columns);%GIVES US A 4 DIMENSIONAL FOVEAL CENTER SURROUND MASK

fovea_cent_suround_mask=FovealCenterSurroundMask(rod_rows,rod_columns);%GIVES US A 4 DIMENSIONAL FOVEAL CENTER SURROUND MASK
end