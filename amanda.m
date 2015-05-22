
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
mean_value=floor( sum(sum(a))/sum(sum(a~=0))); % MEAN ON ONLY NONZERO VALUES.

%now replacing all non zeros with mean value 
a=(a~=0)*mean_value; % yo man!
% copying whole matrix into new final mat and then replacing the whole
% matrix in original image by 0 so that it is not counted next time !

%following code doesnt replace already positive pixels in final image.It
%just adds new positive grouped values to zero pixels.!

bo=final_img(row_center-x:row_center+x,column_center-x:column_center+x);
 bo1=(bo~=0).*a;
 bo2=a-bo1;
 
 %NEW PATCH !! JUST SUBSTITUTING 1 NONZERO PIXEL AMONG THE GROUP WITH THE
 %MEAN VALUE. THIS GIVES US HORIZONTAL CELL EQUIVALENTS.
 [bo2y,bo2x]=size(bo2);
 bo3=bo2*0;
 for i= 1:bo2y*bo2x;
     if bo2(i)==mean_value;
         break;
     end
 end
 bo3(i)=mean_value;
%disp(' amanda is doing its job of taking mean of a group and replacing just 1pixel with the mean value!!');
 
final_img(row_center-x:row_center+x,column_center-x:column_center+x)=final_img(row_center-x:row_center+x,column_center-x:column_center+x)+bo3;
img(row_center-x:row_center+x,column_center-x:column_center+x)=0;


end