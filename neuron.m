function neuron()
disp('hi aseem');
a=imread('lucia.jpg');
imtool(a);
%imview('lucia.jpg'); imview has been removed !!
a(:,:,[2 3])=0;
%%for i=1:3
 %b=a(:,:,i)< 50;
%end %%  
%imshow(a);
b=[1 2 3 4 5 6 7 8 9];

c=[3 4 5 6 7 8 9 10 2];

d=sum(b.*c)
%{
d(1:2,:);


con=[0 0 0;0 1 0;0 0 0];
h = fspecial('disk', 3); % GAUSSIAN FILTER, MATRIX DIMENSION IS 2R+1
pause;
convolved=conv2(d,h,'same');
%}



end