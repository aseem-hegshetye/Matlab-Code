function [final_image_rods,image_cones]=retinal_convoluter(radius)

[h]=retinal_patch(radius); %patch is calculated based on radius defined in retinal_patch
%h = fspecial('disk', radius); % GAUSSIAN FILTER, MATRIX DIMENSION IS 2R+1
%gaussian filter doesnt work for retina
%{
pause;
h=h*100
pause
%}

img=imread('aseem2.jpg');
[y,x,z]=size(img); % SIZE OF IMAGE
imshow (img);
pause;
image_gray=rgb2gray(img);
%CUTTING THE GRAY IMAGE TO FIT THE RETINAL PATCH
image_gray_inaction=(image_gray(ceil((y/2) -radius): ceil((y/2) +radius),ceil((x/2) -radius):ceil((x/2) +radius))); %HERE WE DONT TAKE (RADIUS+1) BECAUSE [(Y/2)+RADIUS] - [(Y/2)-RADIUS] ALREADY GIVES US RADIUS+1 PIXELS :D

%MULTIPLYING image_gray_inaction WITH RETINAL PATCH TO MAKE PIXELS SPARSE
image_rods=double(image_gray_inaction).*(h);
[rows,columns,rgb]=size(image_rods);

%REMOVING FOVEA FROM THE IMAGE
final_image_rods=image_rods*0;
nw_rd=ceil(0.10*radius )+1; %its the distance from the center where pixels are to be converted to rods
final_image_rods(1:(radius+1)-nw_rd,:)= image_rods(1:(radius+1)-nw_rd,:) ;
final_image_rods( (radius+1)+nw_rd:rows,:)= image_rods( (radius+1)+nw_rd:rows,:);
final_image_rods((radius+1)-nw_rd:(radius+1)+nw_rd,1:(radius+1)-nw_rd)=image_rods((radius+1)-nw_rd:(radius+1)+nw_rd,1:(radius+1)-nw_rd);
final_image_rods((radius+1)-nw_rd:(radius+1)+nw_rd,(radius+1)+nw_rd:columns)=image_rods((radius+1)-nw_rd:(radius+1)+nw_rd,(radius+1)+nw_rd:columns);

%WE HAVE EVERY PIXEL FROM FOVEA. WE ONLY NEED TO CONVOLVE RODS WHICH ARE
%GRAY IMAGE OF ORIGINAL IMAGE. WE ONLY SET RETINAL PATCH RADIUS. FOVEA IS
%10% OF THE RETINAL PATCH. WE DONT HAVE TO CONVOLVE ALL 3 VALUES (RGB),.
%RGB ARE ONLY IN FOVEA, RODS JUST HAVE GRAYSCALE IMAGE.


%every where its rows and columns - (rows, colums) and not (X,Y)

%CUTTING SEPARATLY FOR CONES
image_cones=(img(ceil((y/2) -ceil(radius*0.10)): ceil((y/2) +ceil(radius*0.10)),ceil((x/2) -ceil(radius*0.10)):ceil((x/2) +ceil(radius*0.10)),:)); 
% there are 3 matrices  R G B . which one will u use for making retinal



%image_in_action=image_in_action(:,:,1);
%subplot(2,2,1);
%imshow(image_cones);
%pause;
%image_in_action=double (image_in_action); % if we use double before showing the image by imshow the image turns binary. so we used it latter now
%disp('now showing matrix');
% image_in_action
% h=(h) 
 
%image_in_action(:,:,1)
%pause;
%final_image(:,:,1)=double(image_cones(:,:,1)).*(h);
%final_image(:,:,2)=double(image_cones(:,:,2)).*(h);
%final_image(:,:,3)=double(image_cones(:,:,3)).*(h);
%final_image %final image is perfect. its not binary but in imshow its showing binary i dont know why :(



% my "final_image " is 3 dimensioned color image with RGB but this imshow
% and imview are making it binary i dont know why.. they suck !
%imview(final_image);
%imshow sucks.. it converts the gray image into binary 1 and 0.  so i hav
%used image ()
subplot(2,2,4);
% fourth picture is the original patch h.
title('retinal mask');
imshow(h);

end