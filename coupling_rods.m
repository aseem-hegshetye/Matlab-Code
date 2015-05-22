function [final_img_rods]=coupling_rods(radius,nw_rd,img)
%img - ONLY HAS RODS. ZERO FOVEA
%this function groups all rods together. size of group increases with the
%distance from the center.
        
%"img" is matrix where we want to couple rods
% "nw_rd" is the distance from the center where pixels are to be converted
% to rods . "radius" is the radius of the retinal mask ! "radius +1" is the
% center of the image  !
%%final_img_cones=img*0; % final image matrix with all zeros
final_img_rods=img*0; % final image matrix with all zeros
%%final_img_cones(radius+1-nw_rd:radius+1+nw_rd,radius+1-nw_rd:radius+1+nw_rd,:)=img(radius+1-nw_rd:radius+1+nw_rd,radius+1-nw_rd:radius+1+nw_rd,:);%setting fovea to actual value



to1=(2*radius)+(1/4);
to2=sqrt(radius+(1/16));
%for these equations check ur notebook. these are to avoid indexes going
%out of bound.

for nw_rd1=nw_rd: (to1-to2)/2 % !!!!!!!!!!!!!!!change the radius
    
%these two for loops will trace whole radius around the center to check if
%there is any on pixel.
for column= radius+1-nw_rd1:radius+1+nw_rd1 %for diff columns and 2 rows
    if img(radius+1-nw_rd1,column)~=0 % 1st row
       % disp('many col 1st row');
        %pause;
        [final_img_rods,img]=amanda(radius+1-nw_rd1,column,nw_rd1,final_img_rods,img);
        %disp('final_img_rods \n');
        %final_img_rods
        %img(:,:,1)
        %pause;
    end
    if img(radius+1+nw_rd1,column)~=0 % 2nd row
        %disp('many col 2nd row');
        %pause;
        [final_img_rods,img]=amanda(radius+1+nw_rd1,column,nw_rd1,final_img_rods,img);
        %disp('final_img_rods \n');
        %final_img_rods
        %img(:,:,1)
        %pause;
    end
end
for row= radius+1-nw_rd1:radius+1+nw_rd1 %for diff rows and 2 columns
    if img(row,radius+1-nw_rd1)~=0 % 1st column
       % disp('many rows 1st col');
      %  pause;
        [final_img_rods,img]=amanda(row,radius+1-nw_rd1,nw_rd1,final_img_rods,img);
       % final_img(:,:,1)
        %img(:,:,1)
        %pause;
    end
    if img(row,radius+1+nw_rd1)~=0 % 2nd column
       % disp('many rows 2nd col');
       % pause;
        [final_img_rods,img]=amanda(row,radius+1+nw_rd1,nw_rd1,final_img_rods,img);
       % final_img(:,:,1)
        %img(:,:,1)
       % pause;
    end
end





end
%{
final_img(:,:,1)=final_img_cones(:,:,1) + final_img_rods;
final_img(:,:,2:3)=final_img_cones(:,:,2:3);
title('imshow final img complete');
imshow(final_img);
title('imshow final image (:,:,1)');
imshow(final_img(:,:,1));
%}

end

%{
function [final_img,img]=amanda(row_center,column_center,nw_rd1,final_img,img)
%this function takes mean of surrounding on pixels in radius nw_rd and
%replaces all on pixels with mean and sends them to final_img and makes all
%those pixels in img 0. uhh long funtion.

%number of pixels in the surround to be considered arround the non zero
%pixel should be equal to the radius. so as radius increases number of
%pixels increase. there mean is to be calculated. formula below gives
%somewhat accurate number of pixels. refer note book for derivation,ps u
%have derived it.lol
x=floor((sqrt(nw_rd1))/2);

a=img(row_center-x:row_center+x,column_center-x:column_center+x);
mean_value=floor( mean(mean(a)));

%now replacing all non zeros with mean value 
a=(a~=0)*mean_value; % yo man!
% copying whole matrix into new final mat and then replacing the whole
% matrix in original image by 0 so that it is not counted next time !

%following code doesnt replace already positive pixels in final image.It
%just adds new positive grouped values to zero pixels.!

bo=final_img(row_center-x:row_center+x,column_center-x:column_center+x);
 bo1=(bo~=0).*a;
 bo2=a-bo1;
final_img(row_center-x:row_center+x,column_center-x:column_center+x)=final_img(row_center-x:row_center+x,column_center-x:column_center+x)+bo2;
img(row_center-x:row_center+x,column_center-x:column_center+x)=0;


end
%}
% ADD CONDITION IN FIRST FOR for NW_RD AND ADD EXCEPTION CATCH FOR
%a=img(row_center-x:row_center+x,column_center-x:column_center+x);