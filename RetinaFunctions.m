classdef RetinaFunctions
    properties (GetAccess = public,Constant)
        KP_max_group_size=30; %MAX NUMBER OF GROUPED PIXELS
        KP_max_no_ofGroups=50; %MAX NUMBER OF GROUPS IN A IMAGE..MATLAB IS ANYWAYS FLEXIBLE ABOUT MATRIX DIMENSIONS
        KP_min_pix_per_group=4;% IF A GROUP HAVE MORE PIXELS THEN KP_min_pix_per_group THEN WE ALLOW THEM TO EXIST. ELSE WE CLASSIFY ALL THOSE PIXELS INTO A NEARBY GROUP.
        KP_max_noOf_groups_perQuad=20;% ITS ORIGINALLY THERE IN PYTHON. HERE I JUST HAVE REFERENCED IT FOR FEW FUNCTIONS.MATLAB IS FLEXIBLE BUT PYTHON IS RIGID. SO ANY QUADRANT CANT HAVE MORE PATTERNS THEN SPECIFIED HERE
    end
    
   
    
    methods (Static = true) %CLASS FUNCTIONS
        
        function img2=Kaggle_Plankaton_RemoveExtraSpaceFromBackground(img) % REMOVES UNWANTED EMPTY BOUDARIES OF AN IMAGE AND PUTS THE ACTUAL IMAGE AT THE CENTER
           img=edge(img); % WE WILL DO PROCESSING ON EDGE OF THAT IMAGE.
           img2=img*1;
           [row,col]=size(img2);
           done=0;
           for r = 1:row; %TOP BORDER
               if done==1;
                   break;
               end
               for c=1:col;
                   if img2(r,c)>0;
                       img2=img2(r:row,:);
                       done=1;
                       break;
                   end
               end
           end
                    [row,col]=size(img2);
                    done=0;
                   for r = row:-1:1; %BOTTOM BORDER
                       if done==1;
                           break;
                       end
                       for c=1:col;
                           if img2(r,c)>0;
                               img2=img2(1:r,:);
                               done=1;
                               break;
                           end
                       end
                   end
                   
                   [row,col]=size(img2);
                   done=0;
                   for c = 1:col; %LEFT BORDER
                       if done==1;
                           break;
                       end
                       for r=1:row;
                           if img2(r,c)>0;
                               img2=img2(:,c:col);
                               done=1;
                               break;
                           end
                       end
                   end
                   
                   [row,col]=size(img2);
                   done=0;
                   for c = col:-1:1; %RIGHT BORDER
                       if done==1;
                           break;
                       end
                       for r=1:row;
                           if img2(r,c)>0;
                               img2=img2(:,1:c);
                               done=1;
                               break;
                           end
                       end
                   end
            
            
        end
        
        
        function Kaggle_Plankaton_readAllImages_TEST()%READS ALL IMAGES FROM THAT FOLDER AND ITS SUBFOLDER AND STORES MEAN MAT IN TEXT FORMAT WITH SAME NAMES!!
             
            images_too_small=0; %COUNT OF IMAGES THAT R TOO SMALL TO BE LEARNT.. THERE ARE NO "KP_min_pix_per_group" PIXELS THAT CAN BE GROUPED TOGETHER. SO MEAN MAT IS 0
            imagesPerSubfolder=dir('C:\Users\Aseem\Documents\KAGGLE\Marine plankton\test');
            imagesPerSubfolder_Size=size(imagesPerSubfolder);
            %mkdir('C:\Users\Aseem\Documents\KAGGLE\Marine plankton\train\Mean_Matrix\',subFolders(i).name); %CREATING SUBFOLDERS FOR REPECTIVE MEAN_MAT
            for i2 =129810:imagesPerSubfolder_Size(1);% ACCESSING ALL IMAGES
                img=imread(strcat('C:\Users\Aseem\Documents\KAGGLE\Marine plankton\test\',imagesPerSubfolder(i2).name)); %READS AN IMAGE
                img=RetinaFunctions.Kaggle_Plankaton_RemoveExtraSpaceFromBackground(img);% REMOVING UNNECESARY WHITE BORDER AND CENTERING THE IMAGE. HENCE FORTH THE IMG IS EDGE ONLY
                mean_mat=RetinaFunctions.Kaggle_Plankaton_imgproc(img,RetinaFunctions.KP_max_group_size,RetinaFunctions.KP_max_no_ofGroups,RetinaFunctions.KP_min_pix_per_group); % mean_mat -- X, Y, VALUE, LENGTH,QUADRANT,DIST_FRM_CENTER !!% ORDER BY QUADRANT AND DIST_FROM_CENTER
                mean_mat( ~any(mean_mat,2), : ) = []; %REOMVING ALL ZERO ROWS.
                if size(mean_mat,1)==0;
                    images_too_small=images_too_small+1;
                    disp('somethings wrong. Mean Mat is zero rows.number OF TOO SMALL IMAGES TILL NOW = ');
                    images_too_small
                else
                    mean_mat2=RetinaFunctions.kagal_adding_zeros_for_newQuadrnt_and_newImage(mean_mat,RetinaFunctions.KP_max_noOf_groups_perQuad);%ALSO TRIMS A QUADRANT IF IT HAS MORE THEN ALLOWED PATTERNS

                    dlmwrite(strcat('C:\Users\Aseem\Documents\KAGGLE\Marine plankton\test\Mean_Matrix_test\',strrep(imagesPerSubfolder(i2).name, 'jpg', 'txt')),mean_mat2);
                    i2
                end
            end
             
        end
        
        
        function Kaggle_Plankaton_readAllImages()%READS ALL IMAGES FROM THAT FOLDER AND ITS SUBFOLDER AND STORES MEAN MAT IN TEXT FORMAT WITH SAME NAMES!!
             subFolders=dir('C:\Users\Aseem\Documents\KAGGLE\Marine plankton\train\train\');% subFolders NAMES IN ARRAY
             folderSize=size(subFolders); %[123 1]
             images_too_small=0; %COUNT OF IMAGES THAT R TOO SMALL TO BE LEARNT.. THERE ARE NO "KP_min_pix_per_group" PIXELS THAT CAN BE GROUPED TOGETHER. SO MEAN MAT IS 0
             for i =3:folderSize(1);% ACCESSING ALL SUBFOLDERS
                imagesPerSubfolder=dir(strcat('C:\Users\Aseem\Documents\KAGGLE\Marine plankton\train\train\',subFolders(i).name));
                imagesPerSubfolder_Size=size(imagesPerSubfolder);
                mkdir('C:\Users\Aseem\Documents\KAGGLE\Marine plankton\train\Mean_Matrix\',subFolders(i).name); %CREATING SUBFOLDERS FOR REPECTIVE MEAN_MAT
                for i2 =3:imagesPerSubfolder_Size(1);% ACCESSING ALL IMAGES
                    img=imread(strcat('C:\Users\Aseem\Documents\KAGGLE\Marine plankton\train\train\',subFolders(i).name,'\',imagesPerSubfolder(i2).name)); %READS AN IMAGE
                    img=RetinaFunctions.Kaggle_Plankaton_RemoveExtraSpaceFromBackground(img);% REMOVING UNNECESARY WHITE BORDER AND CENTERING THE IMAGE. HENCE FORTH THE IMG IS EDGE ONLY
                    mean_mat=RetinaFunctions.Kaggle_Plankaton_imgproc(img,RetinaFunctions.KP_max_group_size,RetinaFunctions.KP_max_no_ofGroups,RetinaFunctions.KP_min_pix_per_group); % mean_mat -- X, Y, VALUE, LENGTH,QUADRANT,DIST_FRM_CENTER !!% ORDER BY QUADRANT AND DIST_FROM_CENTER
                    mean_mat( ~any(mean_mat,2), : ) = []; %REOMVING ALL ZERO ROWS.
                    if size(mean_mat,1)==0;
                        images_too_small=images_too_small+1;
                        disp('somethings wrong. Mean Mat is zero rows.number OF TOO SMALL IMAGES TILL NOW = ');
                        images_too_small
                    else
                        mean_mat2=RetinaFunctions.kagal_adding_zeros_for_newQuadrnt_and_newImage(mean_mat,RetinaFunctions.KP_max_noOf_groups_perQuad);%ALSO TRIMS A QUADRANT IF IT HAS MORE THEN ALLOWED PATTERNS
                    
                        dlmwrite(strcat('C:\Users\Aseem\Documents\KAGGLE\Marine plankton\train\Mean_Matrix\',subFolders(i).name,'\',strrep(imagesPerSubfolder(i2).name, 'jpg', 'txt')),mean_mat2);
                    end
                end
             end
        end
        
        function Test_Images_Names=Kaggle_Plankaton_TestImagesNames()
            meanMatPerSubfolder=dir('C:\Users\Aseem\Documents\KAGGLE\Marine plankton\test\Mean_Matrix_test\');
            meanMatPerSubfolder_Size=size(meanMatPerSubfolder);
            Test_Images_Names=cell(1,129811); % WE HAVE 129810 TEST IMAGES CURRENTLY. SOME OTHERS ARE SO SMALL THAT THEY ARE DISCARDED BY ALGORITHM
            Test_Images_Names(1)={'image'}; %FIRST NAME IS IMAGE IN SAMPLE SUBMISSION
            for i2 =3:meanMatPerSubfolder_Size(1);% ACCESSING ALL MEAN MAT PER SUBFOLDER CATEGORY  ----
                Test_Images_Names(i2-1)={strrep(meanMatPerSubfolder(i2).name, '.txt', '.jpg')};
            end
            %THIS DOESNT WORK dlmwrite('C:\Users\Aseem\Documents\KAGGLE\Marine plankton\Test_Images_Names.txt',Test_Images_Names)
        end
        
        function Classes_Names=Kaggle_Plankaton_ClassesNames()
            Classes=dir('C:\Users\Aseem\Documents\KAGGLE\Marine plankton\train\train\');
            meanMatPerSubfolder_Size=size(Classes);
            Classes_Names=cell(1,121); % WE HAVE 129810 TEST IMAGES CURRENTLY. SOME OTHERS ARE SO SMALL THAT THEY ARE DISCARDED BY ALGORITHM
            
            for i2 =3:meanMatPerSubfolder_Size(1);% ACCESSING ALL MEAN MAT PER SUBFOLDER CATEGORY  ----
                Classes_Names(i2-2)={Classes(i2).name};
            end
            %THIS DOESNT WORK dlmwrite('C:\Users\Aseem\Documents\KAGGLE\Marine plankton\Test_Images_Names.txt',Test_Images_Names)
        end
        
        function Kaggle_Plankaton_WritingCellTo_Text(x_cell,size_cell)
             fid = fopen('ClassNames.txt', 'wt');
            for i = 1:size_cell;
                 fprintf(fid, x_cell{1,i}); % x_cell HAS 1 ROW AND 129810 COLUMNS
                 fprintf(fid,'\t');
                
            end
            fclose(fid);
        end
            
        
        function final_matrix=Kaggle_Plankaton_Group_MeanMat_TEST() %GROUPS ALL MEAN_MAT INTO ONE MAT WITH ADDED COLUMN DENOTING THE SUBFOLDER CATEGORY NUMBER.THIS MAKES IT EASY FOR PYTHON TO READ THE MAT LINE BY LINE
            %IF U RUN THIS FUNCTION TWICE.subFolders(3) HAS FINAL_MATRIX.SO IT WILL GIVE ERRORS. FIRST DELETE THE FINAL TEXT MAT.
            final_matrix=zeros(1071253,6); % zeros(1071253,7) .. MAT THAT WILL HAVE ALL IMAGES INFORMATION.-- X, Y, VALUE, LENGTH,QUADRANT,DIST_FRM_CENTER,SUBFOLDER NUMBER( easy for classification in python)
                                            %IN TEST WE DONT KNOW THE CLASS. SO JUST 6 COLUMNS
            count_final_matrix_row=1;% POINTER TO THE LATEST ROW ADDED IN FINAL MAT
            %subFolders=dir('C:\Users\Aseem\Documents\KAGGLE\Marine plankton\train\Mean_Matrix\');% subFolders NAMES IN ARRAY
             %folderSize=size(subFolders); %[123 1].. THERE ARE 121 SUBFOLDERS. FIRST TWO ARE JUST DOTS LOL
             %for i =3:folderSize(1);% ACCESSING ALL SUBFOLDERS
                meanMatPerSubfolder=dir('C:\Users\Aseem\Documents\KAGGLE\Marine plankton\test\Mean_Matrix_test\');
                meanMatPerSubfolder_Size=size(meanMatPerSubfolder);
                for i2 =3:meanMatPerSubfolder_Size(1);% ACCESSING ALL MEAN MAT PER SUBFOLDER CATEGORY  ----
                    mm2=dlmread(strcat('C:\Users\Aseem\Documents\KAGGLE\Marine plankton\test\Mean_Matrix_test\',meanMatPerSubfolder(i2).name));
                    %mm1( ~any(mm1,2), : ) = []; %REOMVING ALL ZERO ROWS.
                    
                    %mm2=RetinaFunctions.kagal_adding_zeros_for_newQuadrnt_and_newImage(mm1); %NICELY ADDING ZERO ROWS WITH EVERY QUADRAN CHANGE AND IMAGE CHANGE. YAY
                    [row_mm2,col_mm2]=size(mm2);
                    
                    %USE THE BELOW ONE INSTEAD OF FOR LOOP. MAY BE THIS IS QUICKER
                    final_matrix(count_final_matrix_row:(count_final_matrix_row+row_mm2-1),:)=mm2(:,:);
                    count_final_matrix_row=count_final_matrix_row+row_mm2;
                    i2
%                     for i3=1:row_mm2;
%                         final_matrix(count_final_matrix_row,1:col_mm2)=mm2(i3,:);
%                         %final_matrix(count_final_matrix_row,col_mm2+1)=i-2; %SUBFOLDER NUMBER ADDED AS 7TH COLUMN VALUE.i-2 BECAUSE IT STARTS FROM 3RD FOLDER. 1,2 ARE DOTS
%                         count_final_matrix_row=count_final_matrix_row+1;
%                     end
                end
             %end
            dlmwrite('C:\Users\Aseem\Documents\KAGGLE\Marine plankton\FINAL_MAT_TEST.txt',final_matrix);
        end
        
        
        function final_matrix=Kaggle_Plankaton_Group_MeanMat() %GROUPS ALL MEAN_MAT INTO ONE MAT WITH ADDED COLUMN DENOTING THE SUBFOLDER CATEGORY NUMBER.THIS MAKES IT EASY FOR PYTHON TO READ THE MAT LINE BY LINE
            %IF U RUN THIS FUNCTION TWICE.subFolders(3) HAS FINAL_MATRIX.SO IT WILL GIVE ERRORS. FIRST DELETE THE FINAL TEXT MAT.
            final_matrix=zeros(30,7); % zeros(1071253,7) .. MAT THAT WILL HAVE ALL IMAGES INFORMATION.-- X, Y, VALUE, LENGTH,QUADRANT,DIST_FRM_CENTER,SUBFOLDER NUMBER( easy for classification in python)
            count_final_matrix_row=1;% POINTER TO THE LATEST ROW ADDED IN FINAL MAT
            subFolders=dir('C:\Users\Aseem\Documents\KAGGLE\Marine plankton\train\Mean_Matrix\');% subFolders NAMES IN ARRAY
             folderSize=size(subFolders); %[123 1].. THERE ARE 121 SUBFOLDERS. FIRST TWO ARE JUST DOTS LOL
             for i =3:folderSize(1);% ACCESSING ALL SUBFOLDERS
                meanMatPerSubfolder=dir(strcat('C:\Users\Aseem\Documents\KAGGLE\Marine plankton\train\Mean_Matrix\',subFolders(i).name));
                meanMatPerSubfolder_Size=size(meanMatPerSubfolder);
                for i2 =3:meanMatPerSubfolder_Size(1);% ACCESSING ALL MEAN MAT PER SUBFOLDER CATEGORY
                    mm2=dlmread(strcat('C:\Users\Aseem\Documents\KAGGLE\Marine plankton\train\Mean_Matrix\',subFolders(i).name,'\',meanMatPerSubfolder(i2).name));
                    %mm1( ~any(mm1,2), : ) = []; %REOMVING ALL ZERO ROWS.
                    
                    %mm2=RetinaFunctions.kagal_adding_zeros_for_newQuadrnt_and_newImage(mm1); %NICELY ADDING ZERO ROWS WITH EVERY QUADRAN CHANGE AND IMAGE CHANGE. YAY
                    [row_mm2,col_mm2]=size(mm2);
                    for i3=1:row_mm2;
                        final_matrix(count_final_matrix_row,1:col_mm2)=mm2(i3,:);
                        final_matrix(count_final_matrix_row,col_mm2+1)=i-2; %SUBFOLDER NUMBER ADDED AS 7TH COLUMN VALUE.i-2 BECAUSE IT STARTS FROM 3RD FOLDER. 1,2 ARE DOTS
                        count_final_matrix_row=count_final_matrix_row+1;
                    end
                end
             end
            dlmwrite('C:\Users\Aseem\Documents\KAGGLE\Marine plankton\train\Mean_Matrix\FINAL_MAT.txt',final_matrix);
        end
        
        
        
        
        function mm2=kagal_adding_zeros_for_newQuadrnt_and_newImage(mm1,KP_max_noOf_groups_perQuad) %WORKS GREAT WHEN WE JUST GIVE ONE IMAGE AT A TIME !! YAY
            %NEW UPDATE TO THIS FUNCTION MAKES IT CAPABLE OF TRIMING DOWN EXTRA ROWS IN A QUADRANT.IF THERE ARE MORE THEN KP_max_noOf_groups_perQuad ROWS IN A QUAD IT CHOSSES TOP "(KP_max_noOf_groups_perQuad=20)" LENGTHS OF GROUPS AND GIVES THE OUTPUT.
            [row_mm1,col_mm1]=size(mm1);
            if row_mm1 ==0;
                disp('something wrong');
            end
                
            static_quad=mm1(1,5);
            mm2_indx=1;
            mm2=zeros(row_mm1,col_mm1); %MATLAB AUTOMATICALLY ADDS EXTRA ROWS INSTEAD OF TRUNCATING.
            rows_per_quadrant=0;
            for i3=1:row_mm1;
                if static_quad~= mm1(i3,5);

                 %QUADRANT CHANGED. IF IT WAS 4TH QUADRANT ITS AN IMAGE CHANGE.
                                    %HERE WE SHALL SEE IF PREVIOUS QUADRANT HAS EXCEEDED THE LIMITS

                if rows_per_quadrant>KP_max_noOf_groups_perQuad; %LOCHA

                    quadrnt=mm1((i3-1)- ( rows_per_quadrant-1): (i3-1),:);
                        mm_quad1=sortrows(quadrnt,-4); %ORDER BY LENGTHS DESCENDING
                        mm_quad1=mm_quad1(1:KP_max_noOf_groups_perQuad,:); %TAKE TOP 20 PATTERNS
                        mm_quad1=sortrows(mm_quad1,6);  % REARRAGNE BY DISTANCE FROM CENTER

                        mm2=cat(1, mm2 (1:(mm2_indx-1) - ( rows_per_quadrant) ,:),mm_quad1);
                        [mm2_indx,mm2_cl]=size(mm2);
                        mm2_indx=mm2_indx+1;
                        
                end

                mm2(mm2_indx,:)=0;
                mm2_indx=mm2_indx+1;
                mm2(mm2_indx,:)=mm1(i3,:);
                mm2_indx=mm2_indx+1;
                static_quad= mm1(i3,5);
                
                rows_per_quadrant =1;
                %old_dist=0;
                
                elseif static_quad== mm1(i3,5);
                    
                        mm2(mm2_indx,:)=mm1(i3,:);
                        mm2_indx=mm2_indx+1;
                        rows_per_quadrant=rows_per_quadrant+1;
                    if i3== row_mm1;
                        if rows_per_quadrant>KP_max_noOf_groups_perQuad; %LOCHA

                        quadrnt=mm1((i3)- ( rows_per_quadrant-1): (i3),:);
                        mm_quad1=sortrows(quadrnt,-4); %ORDER BY LENGTHS DESCENDING
                        mm_quad1=mm_quad1(1:KP_max_noOf_groups_perQuad,:); %TAKE TOP 20 PATTERNS
                        mm_quad1=sortrows(mm_quad1,6);  % REARRAGNE BY DISTANCE FROM CENTER

                        mm2=cat(1, mm2 (1:(mm2_indx-1) - ( rows_per_quadrant) ,:),mm_quad1);
                        %mm2 ((mm2_indx-1) - ( rows_per_quadrant-1): KP_max_noOf_groups_perQuad-1,:)= mm_quad1 ;
                        %DONT KNOW IF DIFFERENT DIMENSIONS WILL WORK ABOVE, MAY BE REMOVE (i3-1).
                        [mm2_indx,mm2_cl]=size(mm2);
                        mm2_indx=mm2_indx+1;
                        end
                        
                    end
                end

            end
            mm2(mm2_indx:mm2_indx+1,:)=0; % ADDING TWO ROWS OF ZEROS AT END OF MEAN_MAT COZ QUADRANT HAS CHANGED AND IMAGE IS OVER
       end
        
        
        
        
        
        
        function Kaggle_Plankaton_Creating_Folders() %CREATING FOLDERS FOR ALL CLASSIFIED CLASSES MEAN MATRICES 
            for i= 3:123;
                mkdir('C:\Users\Aseem\Documents\KAGGLE\Marine plankton\train\Mean_Matrix\',subFolders(i).name);
            end
        end
        
        function mean_mat=Kaggle_Plankaton_imgproc(edg,KP_max_group_size,KP_max_no_ofGroups,KP_min_pix_per_group) % mean_mat -- X, Y, VALUE, LENGTH,QUADRANT,DIST_FRM_CENTER !!
            %edg=edge(img);
            output_mat=RetinaFunctions.Classifying_Pixels(edg);
            [mat3,mean_mat]=RetinaFunctions.Grouping_Pixels(output_mat,KP_min_pix_per_group,KP_max_group_size,KP_max_no_ofGroups);% Grouping_Pixels(mat,KP_min_pix_per_group,KP_max_group_size,KP_max_no_ofGroups)
            %disp(' mean_mat = X, Y, VALUE, LENGTH,QUADRANT,DIST_FRM_CENTER !!');
            mean_mat=sortrows(mean_mat,[5 6]);  % ORDER BY QUADRANT AND DIST_FROM_CENTER
        end

        
        function [output_mat,count]=Neighbouring_Pixels_of_Same_class(mat,x,y,KP_max_group_size) %GIVES LIST OF ALL NEIGHBOURING PIXELS OF SAME CLASS ALONG WITH THERE X(col) Y(row) CO.
            %KP_max_group_size is MAX NUMBER OF PIXELS THAT CAN POSSIBLY BE IN A CLASS
            class=mat(y,x);%(1,2,3,4) CLASS VALUE IS STORED 
            count=1;% COUNT OF PIXELS CLASSIFIED IN THAT SPECIFIC CATEGORY
            test_mat=mat*1; % TO CHECK IF THERE ARE ENOUGH PIXELS IN A GROUP
            goto=1122;
            output_mat=zeros(KP_max_group_size,3); %output_mat HAS 3 COL. -- ROW,COL,CLASS_VALUE
            output_mat(1,:)=[y,x,class]; %FIRST PIXEL STORED IN OUTPUT
            while(1);
                if goto==0000; %MEANS NO MORE SAME CLASS PIXELS IN THE NEIGHBOURHOOD
                    break;
                
                elseif goto==1122;%MEANS NEW PIXEL OF SAME CLASS WAS FOUND !!
                    goto=0000; % RESETTING GOTO
                    output = RetinaFunctions.Go_Around(test_mat,x,y); %[1122]
                    for k= 1:8;
                       if output(k,3)==class; % NEIGHTBOURING SIMILARLY CLASSIFIED PIXEL FOUND
                           count=count+1;
                           
                           test_mat(y,x)=0; %MAKING THE OLD ONE ZERO TO AVOID NEW PIXEL FINDING THE OLD PIXEL AGAIN AS ITS NEIGHBOUR
                           x=output(k,1);%NEW PIXEL COL
                           y=output(k,2); %NEW PIXEL ROW
                           output_mat(count,:)=[y,x,class]; %NEW PIXEL STORED IN OUTPUT
                           goto=1122;%EXECUTION GOES BACK TO GO_AROUND [1122]
                           break; 
                       end
                    end
                end
            end
            %CLIPPING OFF EXTRA ZEROS AT THE BOTTOM
        end
        function [mat,mean_mat]=Grouping_Pixels(mat,KP_min_pix_per_group,KP_max_group_size,KP_max_no_ofGroups) %SMALL GROUP OF PIXELS ARE MERGED INTO BIGGER GROUPS TO MAKE THE IMAGE UNIFORMLY CLASSIFIED
            %MEAN MATRIX TAHT HAS CENTROID OF A GROUP AND ITS LENGTH. -- X, Y, VALUE, LENGTH,QUADRANT,DIST_FRM_CENTER !!
            %mat HAS GROUPED PIXELS
            %EVERY PIXELS HAS A CLASS VALUE. ITS EITHER 1,2,3OR 4.  
            [mat_row,mat_col]=size(mat);
            test_mat=mat*1; % TO CHECK IF THERE ARE ENOUGH PIXELS IN A GROUP
            mean_mat=zeros(KP_max_no_ofGroups,6); %KP_max_no_ofGroups is MAXIMUM NUMBER OF GROUPS THAT MIGHT BE IDENTIFIED IN THIS IMAGE MAT.%FORMING MEAN MATRIX TAHT HAS CENTROID OF A GROUP AND ITS LENGTH. -- X, Y, VALUE, LENGTH,QUADRANT,DIST_FRM_CENTER  !!
            count_ofGroups=1; %INITIALIZING count_ofGroups TO POINT TO FIRST ROW OF MEAN_MAT
            for i=1:(mat_row*mat_col);
                if test_mat(i)>0; % IF WE HAVE ALREADY CHEKED SOME PIXELS OF A CLASS AND THERE COUNT IS ABOVE THRESHOLD THEN DO NOT NEED TO TEST THM AGAIN. IN TEST_MAT WE MAKE THEM ZERO WHEN THERE COUNT IS HIGHER. SO USE TEST_MAT HERE
                    
                    
                    for twice_loop=1:2; %ONCE WE RECLASSIFY SMALL NUMBER OF PIXELS FROM A GROUP TO ITS NEIGBHOURING PIXEL CLASS. WE AGAIN START GROUPING THEM SO AS TO MAKE SURE WE INCLUDE THE WHOLE NEW BIG CLASS.
                        [row,col]=RetinaFunctions.Converting_index_to_XY(i,mat_row);
                        [output_pixSameClass,count]=RetinaFunctions.Neighbouring_Pixels_of_Same_class(test_mat,col,row,KP_max_group_size) ; %output_pixSameClass HAS 3 COL-- ROW,COL,CLASS_VALUE. HERE WE TAKE TEST_MAT INSTEAD OF MAT COZ WE DONT WANT TO RECLASSIFY THE CLASSIFIED PIXEL. LAMBI JUDAI :( TOO DIFFICULT
                        if count<=KP_min_pix_per_group; %NOW WE NEED TO CLASSIFFY THOSE PIXELS IN ANOTHER CLASS CATEGORY. WE ALREADY HAVE EVERYONES INDICES :)

                            for all_pix = count:-1:1; %SUPPOSE last PIX DOESNT HAVE ANY ANOTHER CLASS NEIGHBOUR. THN WE LOOK AT NEIGHBOURS OF ANOTHER PIXEL FROM SAME CLASS
                                substituted_allPixels_withNewClass=0; %THIS MEANS HAVENT FOUND A NEW CLASS YET
                                row11=output_pixSameClass(all_pix,1);
                                col11=output_pixSameClass(all_pix,2);
                                output_goaround = RetinaFunctions.Go_Around(mat,col11,row11); 
                                for in=1:8;
                                    if output_goaround(in,3)~= output_pixSameClass(1,3) && output_goaround(in,3) >0;% output_pixSameClass(1,3) = CLASS VALUE
                                        substituted_allPixels_withNewClass=1; %FOUND A NEW CLASS YAY!!
                                        %HERE WE R FINDING A NEW NEIGHBOURING CLASS FOR THT PIXEL
                                        for pix=1:count;
                                            r=output_pixSameClass(pix,1);
                                            c=output_pixSameClass(pix,2);
                                            new_classification=output_goaround(in,3);
                                            mat(r,c)=new_classification;
                                            test_mat(r,c)=new_classification; %CHANGING SMALL NUMBERED CLASSIFIED PIXELS TO NEIGHBORING CLASS SO NOW THE NUMBER OF PIXELS BELONGING TO THAT CLASS IS SUBSTANTIAL.
                                        end
                                        %WE ARE DONE SUBSTITUTING ALL PIXELS TO NEW CLASS NOW
                                        break; %ONCE WE FIND ANOTHER NEIGHBOURNG CLASS, WE SET ITS VALUE TO THESE SMALL NUMBER OF PIX GROUP AND THEN WE EXIT THIS LOOP.
                                    end
                                end
                                if substituted_allPixels_withNewClass ==1; %DONT HAVE TO AGAIN LOOK FOR A NEW CLASS FOR ANOTHER PIXEL .. WE ARE DONE
                                    break;
                                end
                            end

                        else %count > KP_min_pix_per_group -- YAY!! LET THEM BE.. DONT TOUCH THEM AGAIN!!
                            %SETTING THESE PIXELS IN TEST_MAT =0 . SO WE WONT TOUCH THEM AGAIN
                            col1=output_pixSameClass(1,2);
                            row1=output_pixSameClass(1,1);
                            col2=output_pixSameClass(count,2);
                            row2=output_pixSameClass(count,1);
                           
                            %NOW DOING NEW FINAL CLASSIFICATION OF A GROUP
                            if row1 > row2; % output has X(col), Y(row), VALUE 
                              if col1 > col2;
                                  class=4;
                              elseif  col2>col1;
                                  class=3;
                              elseif col1==col2; %NOW COLUMNS are EQUAL. SO VERTICAL
                                  class=2;
                              end
                            elseif row2>row1;
                              if col1 > col2;
                                  class=3;
                              elseif  col2>col1;
                                  class=4;
                              elseif col1==col2; %NOW COLUMNS are EQUAL. SO VERTICAL
                                  class=2;
                              end
                            elseif row1==row2; %NOW COLUMNS DIFFERENCE DOESNT MATTER LOL
                                class=1;
                            end
                            
                            for pix=1:count;
                                r=output_pixSameClass(pix,1); %output_pixSameClass HAS 3 COL-- ROW,COL,CLASS_VALUE
                                c=output_pixSameClass(pix,2);
                                mat(r,c)=class; 
                                test_mat(r,c)=0; %SO THAT WE DONT CHECK THESE PIXELS AGAIN FOR NUMBER OF NEIGHBOURS.
                            end
                            
                            %FORMING MEAN MATRIX TAHT HAS CENTROID OF A GROUP AND ITS LENGTH. -- X, Y, VALUE, LENGTH,QUADRANT , DISTANCE FROM CENTER
                            rw=mean(output_pixSameClass(1:count,1));
                            clm=mean(output_pixSameClass(1:count,2));
                            [quadrant,dist_frmCent]=RetinaFunctions.Quadrant_and_Dist(clm,rw,ceil(mat_col/2),ceil(mat_row/2));
                            mean_mat(count_ofGroups,:)=[clm,rw,class,count,quadrant,dist_frmCent]; %X, Y, VALUE, LENGTH,QUADRANT,DIST_FRM_CENTER
                            count_ofGroups=count_ofGroups+1;
                            break; %GROUP OF PIXEL IS BIG ENOUG. WE MADE THESE PIXELS ZERO IN TEST_MAT.LETS GO TO ANOTHER PIXEL NOW
                        end
                    end
                end
            end
        end
        
        function [quad,dist_frmCent]=Quadrant_and_Dist(x,y,cen_x,cen_y) %GIVES WHAT QUADRANT THE PIXELS ARE IN AND DISTANCE FROM CENTER
            if x>cen_x;
                if y>cen_y;
                    quad=4;
                elseif y<=cen_y;
                    quad=2;
                end
            elseif x<=cen_x;
                if y>cen_y;
                    quad=3;
                elseif y<=cen_y;
                    quad=1;
                end
            end
            
            dist_frmCent=sqrt(((x-cen_x)^2) +((y-cen_y)^2));
                    
                    
            
        end
        %{
        %BACKUP FUNCTION
        function mat=Grouping_Pixels(mat,KP_min_pix_per_group,KP_max_group_size) %SMALL GROUP OF PIXELS ARE MERGED INTO BIGGER GROUPS TO MAKE THE IMAGE UNIFORMLY CLASSIFIED
            %EVERY PIXELS HAS A CLASS VALUE. ITS EITHER 1,2,3OR 4. 
            [mat_row,mat_col]=size(mat);
            test_mat=mat*1; % TO CHECK IF THERE ARE ENOUGH PIXELS IN A GROUP
            for i=1:(mat_row*mat_col);
                if test_mat(i)>0; % IF WE HAVE ALREADY CHEKED SOME PIXELS OF A CLASS AND THERE COUNT IS ABOVE THRESHOLD THEN DO NOT NEED TO TEST THM AGAIN. IN TEST_MAT WE MAKE THEM ZERO WHEN THERE COUNT IS HIGHER. SO USE TEST_MAT HERE
                    [row,col]=RetinaFunctions.Converting_index_to_XY(i,mat_row);
                    [output_pixSameClass,count]=RetinaFunctions.Neighbouring_Pixels_of_Same_class(mat,col,row,KP_max_group_size) ; %output_pixSameClass HAS 3 COL-- ROW,COL,CLASS_VALUE
                    if count<=KP_min_pix_per_group; %NOW WE NEED TO CLASSIFFY THOSE PIXELS IN ANOTHER CLASS CATEGORY. WE ALREADY HAVE EVERYONES INDICES :)
                        for all_pix = 1: count; %SUPPOSE 1ST PIX DOESNT HAVE ANY ANOTHER CLASS NEIGHBOUR. THN WE LOOK AT NEIGHBOURS OF ANOTHER PIXEL FROM SAME CLASS
                            row11=output_pixSameClass(all_pix,1);
                            col11=output_pixSameClass(all_pix,2);
                            output_goaround = RetinaFunctions.Go_Around(mat,col11,row11); 
                            for in=1:8;
                                if output_goaround(in,3)~= output_pixSameClass(1,3) && output_goaround(in,3) >0;% output_pixSameClass(1,3) = CLASS VALUE
                                    %HERE WE R FINDING A NEW NEIGHBOURING CLASS FOR THT PIXEL
                                    for pix=1:count;
                                        r=output_pixSameClass(pix,1);
                                        c=output_pixSameClass(pix,2);
                                        new_classification=output_goaround(in,3);
                                        mat(r,c)=new_classification;
                                        test_mat(r,c)=0; %SO THAT WE DONT CHECK THESE PIXELS AGAIN FOR NUMBER OF NEIGHBOURS.
                                    end
                                    break; %ONCE WE FIND ANOTHER NEIGHBOURNG CLASS, WE SET ITS VALUE TO THESE SMALL NUMBER OF PIX GROUP AND THEN WE EXIT THIS LOOP.
                                end
                            end
                        end
                    else %count > KP_min_pix_per_group -- YAY!! LET THEM BE.. DONT TOUCH THEM AGAIN!!
                        %SETTING THESE PIXELS IN TEST_MAT =0 . SO WE WONT TOUCH THEM AGAIN
                        for pix=1:count;
                            r=output_pixSameClass(pix,1);
                            c=output_pixSameClass(pix,2);
                            test_mat(r,c)=0; %SO THAT WE DONT CHECK THESE PIXELS AGAIN FOR NUMBER OF NEIGHBOURS.
                        end
                    end
                end
            end
        end
        %}
        
        
        
        function [row,col]=Converting_index_to_XY(index,total_rows) %CONVERTING INDEX TO X AND Y COORDINATE 
            %INDEXING IN MATLAB IS MOTHER FUCKER UNLIKE PYTHON. SO WE CHANGED ROWS TO COL AND COL TO ROWS
            reminder=rem(index,total_rows);
            whole_div=fix(index/total_rows);
            if reminder >0;
                row=reminder;
            else 
                row=total_rows;
            end
            if whole_div ==0;
                col=1;
            elseif whole_div>0 && reminder >0;
                col=whole_div+1;
            elseif whole_div>0 && reminder ==0;
                col=whole_div;
            end
            
        end
        function output = Go_Around(mat,x,y)% GOES AROUND THAT PIXEL IN THAT MATRIX AND RETURNS  X(col), Y(row), VALUE . so output IS A 8 ROWS 3 COL MATRIX
            %ALSO CATCHES OUT OF BOUND EXCEPTIONS !! YAY
            count=0;
            output=zeros(8,3);
            for col = x-1:x+1;
                for row=y-1:y+1;
                    if col==x && row == y;
                        %do nothing
                    else
                        try
                            if mat(row,col)>0 ;
                                count=count+1;
                                output(count,1)=col;
                                output(count,2)=row;
                                output(count,3)=mat(row,col);
                            end
                        catch a
                            %disp(' out of bound in Go_Around function' );
                            
                        end
                    end
                end
            end
         end
        
        function output_mat=Classifying_Pixels(mat) % CLASSIFIES INTO -=1 ,|=2, /=3, \=4
            [row1,col1]=size(mat);
            output_mat=mat*0;
            for i=1:(row1*col1);
                if mat(i)>0;
                    [row,col]=RetinaFunctions.Converting_index_to_XY(i,row1);
                    output = RetinaFunctions.Go_Around(mat,col,row);
                    for k= 1:8;
                       if output(k,3)>0; % NEIGHTBOURING PIXEL FOUND
                           y2=output(k,2);
                           x2=output(k,1);
                          if row > y2; % output has X(col), Y(row), VALUE 
                              if col > x2;
                                  output_mat(row,col)=4; % CLASSIFYING PIX IN NEW MATRIX
                                  output_mat(y2,x2)=4;
                                  mat(row,col)=0;%MAKING PIXELS ZERO IN ORIGINAL MAT SO AS TO AVOID REPETITION
                                  mat(y2,x2)=0;
                                  break;
                              
                              elseif  x2>col;
                                  output_mat(row,col)=3; % CLASSIFYING PIX IN NEW MATRIX
                                  output_mat(y2,x2)=3;
                                  mat(row,col)=0;%MAKING PIXELS ZERO IN ORIGINAL MAT SO AS TO AVOID REPETITION
                                  mat(y2,x2)=0;
                                  break;
                              elseif col==x2; %NOW COLUMNS are EQUAL. SO VERTICAL
                                  output_mat(row,col)=2; % CLASSIFYING PIX IN NEW MATRIX
                                  output_mat(y2,x2)=2;
                                  mat(row,col)=0;%MAKING PIXELS ZERO IN ORIGINAL MAT SO AS TO AVOID REPETITION
                                  mat(y2,x2)=0;
                                  break;
                              end
                          elseif y2>row;
                              if col > x2;
                                  output_mat(row,col)=3; % CLASSIFYING PIX IN NEW MATRIX
                                  output_mat(y2,x2)=3;
                                  mat(row,col)=0;%MAKING PIXELS ZERO IN ORIGINAL MAT SO AS TO AVOID REPETITION
                                  mat(y2,x2)=0;
                                  break;
                              
                              elseif  x2>col;
                                  output_mat(row,col)=4; % CLASSIFYING PIX IN NEW MATRIX
                                  output_mat(y2,x2)=4;
                                  mat(row,col)=0;%MAKING PIXELS ZERO IN ORIGINAL MAT SO AS TO AVOID REPETITION
                                  mat(y2,x2)=0;
                                  break;
                              elseif col==x2; %NOW COLUMNS are EQUAL. SO VERTICAL
                                  output_mat(row,col)=2; % CLASSIFYING PIX IN NEW MATRIX
                                  output_mat(y2,x2)=2;
                                  mat(row,col)=0;%MAKING PIXELS ZERO IN ORIGINAL MAT SO AS TO AVOID REPETITION
                                  mat(y2,x2)=0;
                                  break;
                              end
                          elseif row==y2; %NOW COLUMNS DIFFERENCE DOESNT MATTER LOL
                                  output_mat(row,col)=1; % CLASSIFYING PIX IN NEW MATRIX
                                  output_mat(y2,x2)=1;
                                  mat(row,col)=0;%MAKING PIXELS ZERO IN ORIGINAL MAT SO AS TO AVOID REPETITION
                                  mat(y2,x2)=0;
                                  break;
                          
                          end
                       end
                    end
                end
            end
            
        end
        
        function Center_Surround_Mask(radius) % TAKES DISTANCE FROM CENTER"radius" AND GIVES A MASK WHOS SIZE INCREASES AS RADIUS INCREASES.
            if radius <30;%3^2
                center=ones(1);
                surround=(ones(3)*-1)+ padarray(center,[1,1]);
            elseif radius <250;%5^2
                center=ones(3);
                surround=(ones(5)*-1)+ padarray(center,[1,1]);
            elseif radius <490;% 7^2
                center=ones(5);
                surround=(ones(7)*-1)+ padarray(center,[1,1]);
            elseif radius <810;% 9^2
                center=ones(5);
                surround=(ones(9)*-1)+ padarray(center,[2,2]);
            elseif radius <1210;% 11^2
                center=ones(7);
                surround=(ones(11)*-1)+ padarray(center,[2,2]);
            else
                center=ones(9);
                surround=(ones(13)*-1)+ padarray(center,[2,2]);
            end
            
        end
        
        function output= Break_Matrix(mat) %BREAKS A MATRIX INTO!! X,Y,PIXEL_VALUE,RADIUS(dist from center),QUADRANT(1,2,3,4) -- FOR EVERY NON ZERO PIXEL
            [y,x]=size(mat); %2D MATRIX. ASSUMING THAT IT HAS ODD NUMBER OF ROWS AND COLUMNS SO WE HAVE AN EXACT CENTER TO LOCATE
            % ITS A SQARE MATRIX ALWAYS. SO Y=X
            center=ceil(y/2);
            non_zero_pixels=nnz(mat); %NUMBER OF NON ZERO PIXELS
            output=zeros(non_zero_pixels,5);
            output_row_index=1;%POINTING TO FIRST ROW OF THE MATRIX
            
            if mat(center,center) >0 ;%SETTING UP CENTER PIXEL AT RADIUS 0
                output(output_row_index,1)=center;%COLUMN COORDINATE
                output(output_row_index,2)=center;%ROW COORDINATE
                output(output_row_index,3)=mat(center,center); %ACTUAL PIXEL VALUE
                output(output_row_index,4)=0;%DISTANCE FROM CENTER.WE ASSUMED IT SAME FOR ENTIRE TRACKED SQAURE.ITS CONVINIENT
                output(output_row_index,5)=1; %QUADRANT SET TO 1. INSPITE OF BEING CENTER LOL.refer notebook FOR DIAGRAM
            end
            output_row_index=output_row_index+1;
            
            for r=1:center-1;
                for col=center-r:center+r; %FOR ROWS ABOVE AND BELOW OF THE CENTER
                    if mat(center-r,col)>0; %UPPER ROW
                        output(output_row_index,1)=col;%COLUMN COORDINATE
                        output(output_row_index,2)=center-r;%ROW COORDINATE
                        output(output_row_index,3)=mat(center-r,col); %ACTUAL PIXEL VALUE
                        output(output_row_index,4)=r;%DISTANCE FROM CENTER.WE ASSUMED IT SAME FOR ENTIRE TRACKED SQAURE.ITS CONVINIENT
                        if col<center;
                            output(output_row_index,5)=1; %QUADRANT 
                        else
                            output(output_row_index,5)=2; %QUADRANT 
                        end
                        output_row_index=output_row_index+1;
                    end
                    if mat(center+r,col)>0; %LOWER ROW
                        output(output_row_index,1)=col;%COLUMN COORDINATE
                        output(output_row_index,2)=center+r;%ROW COORDINATE
                        output(output_row_index,3)=mat(center+r,col); %ACTUAL PIXEL VALUE
                        output(output_row_index,4)=r;%DISTANCE FROM CENTER.WE ASSUMED IT SAME FOR ENTIRE TRACKED SQAURE.ITS CONVINIENT
                        if col<center;
                            output(output_row_index,5)=3; %QUADRANT 
                        else
                            output(output_row_index,5)=4; %QUADRANT 
                        end
                        output_row_index=output_row_index+1;
                    end
                end
                for row=(center-r)+1:(center+r)-1; %FOR COLUMNS LEFT AND RIGHT OF THE CENTER.WE SHOULD NOT CONSIDER SQR CORNER PIXELS TWICE.SO WE HAV "(center-r) MINUS 1"
                    if mat(row,center-r)>0; %LEFT COLUMN
                        output(output_row_index,1)=center-r;%COLUMN COORDINATE
                        output(output_row_index,2)=row;%ROW COORDINATE
                        output(output_row_index,3)=mat(row,center-r); %ACTUAL PIXEL VALUE
                        output(output_row_index,4)=r;%DISTANCE FROM CENTER.WE ASSUMED IT SAME FOR ENTIRE TRACKED SQAURE.ITS CONVINIENT
                        if row<center;
                            output(output_row_index,5)=1; %QUADRANT 
                        else
                            output(output_row_index,5)=3; %QUADRANT 
                        end
                        output_row_index=output_row_index+1;
                    end
                    if mat(row,center+r)>0; %RIGHT COLUMN
                        output(output_row_index,1)=center+r;%COLUMN COORDINATE
                        output(output_row_index,2)=row;%ROW COORDINATE
                        output(output_row_index,3)=mat(row,center+r); %ACTUAL PIXEL VALUE
                        output(output_row_index,4)=r;%DISTANCE FROM CENTER.WE ASSUMED IT SAME FOR ENTIRE TRACKED SQAURE.ITS CONVINIENT
                        if row<center;
                            output(output_row_index,5)=2; %QUADRANT 
                        else
                            output(output_row_index,5)=4; %QUADRANT 
                        end
                        output_row_index=output_row_index+1;
                    end
                end
           end
         end
        
        function displaying_test()
            disp('hi this is a object oriented class function ');
        end
        
    end
    
    %         function [final_mm]=Kaggle_Plankaton_mean_mat_Trimer(KP_max_noOf_groups_perQuad,mm) % IF ANY QUADRANT HAS MORE THEN KP_max_noOf_groups_perQuad GROUPS PER QUADRNT THEN THIS FUNCTION SELECTS ONLY THE TOP REQUIRED PATTERNS WITH HIGHEST LENGTH AND DELETES OTHERS
%             [mm_row,mm_col]=size(mm);
%             %for quad=1:4;
%             for row1 =1:mm_row; 
%                 if mm(row1,5)==0; %QUADRANT WILL NEVER BE ZERO UNLESS ITS  A ZERO ROW WHICH INDICATES END OF A QUADRANT
%                     break;
%                 end
%             end
%             if mm(row1-1,5)==1;
%                 mm_quad1=mm(1:row1-1,:); % FIRST QUADRANT SET
%             elseif mm(row1-1,5)==2;
%                 mm_quad2=mm(1:row1-1,:); % 2nd QUADRANT SET
%             elseif mm(row1-1,5)==3;
%                 mm_quad3=mm(1:row1-1,:); % 3rd QUADRANT SET
%             elseif mm(row1-1,5)==4;
%                 mm_quad4=mm(1:row1-1,:); % 4th QUADRANT SET
%             end
%             
%             
%                 
%             
%             
%               
%             for row2 =row1+1:mm_row; 
%                 if mm(row2,5)==0; %QUADRANT WILL NEVER BE ZERO UNLESS ITS  A ZERO ROW WHICH INDICATES END OF A QUADRANT
%                     break;
%                 end
%             end
%             mm_quad2=mm(row1+1:row2-1,:); % FIRST QUADRANT SET
%             
%             for row3 =row2+1:mm_row; 
%                 if mm(row3,5)==0; %QUADRANT WILL NEVER BE ZERO UNLESS ITS  A ZERO ROW WHICH INDICATES END OF A QUADRANT
%                     break;
%                 end
%             end
%             mm_quad3=mm(row2+1:row3-1,:); % FIRST QUADRANT SET
%             
%             
%             for row4 =row3+1:mm_row; 
%                 if mm(row4,5)==0; %QUADRANT WILL NEVER BE ZERO UNLESS ITS  A ZERO ROW WHICH INDICATES END OF A QUADRANT
%                     break;
%                 end
%             end
%             mm_quad4=mm(row3+1:row4-1,:); % FIRST QUADRANT SET
% 
%             [row_mm_quad1,col_mm_quad1]=size(mm_quad1);
%             [row_mm_quad2,col_mm_quad2]=size(mm_quad2);
%             [row_mm_quad3,col_mm_quad3]=size(mm_quad3);
%             [row_mm_quad4,col_mm_quad4]=size(mm_quad4);
%             
%             %ARRANGING QUADRANTS IN DESCENDING ORDER OF EVERY PATTERNS LENGTH
% if row_mm_quad1 >KP_max_noOf_groups_perQuad ;
% mm_quad1=sortrows(mm_quad1,-4); %ORDER BY LENGTHS DESCENDING
% mm_quad1=mm_quad1(1:KP_max_noOf_groups_perQuad,:); %TAKE TOP 20 PATTERNS
% mm_quad1=sortrows(mm_quad1,6);  % REARRAGNE BY DISTANCE FROM CENTER
% end
%                 final_mm=mm_quad1;
%                 final_mm=cat(1,final_mm,zeros(1,mm_col));
%             
%             if row_mm_quad2 >KP_max_noOf_groups_perQuad ;
%                 mm_quad2=sortrows(mm_quad2,-4);%ORDER BY LENGTHS DESCENDING
%                 mm_quad2=mm_quad2(1:KP_max_noOf_groups_perQuad,:); %TAKE TOP 20 PATTERNS
%                 mm_quad2=sortrows(mm_quad2,6);  % REARRAGNE BY DISTANCE FROM CENTER
%             end
%                 final_mm=cat(1,final_mm,mm_quad2);
%                 final_mm=cat(1,final_mm,zeros(1,mm_col));
%             
%             if row_mm_quad3 >KP_max_noOf_groups_perQuad ;
%                mm_quad3=sortrows(mm_quad3,-4);%ORDER BY LENGTHS DESCENDING
%                 mm_quad3=mm_quad3(1:KP_max_noOf_groups_perQuad,:); %TAKE TOP 20 PATTERNS
%                 mm_quad3=sortrows(mm_quad3,6);  % REARRAGNE BY DISTANCE FROM CENTER
%             end
%                 final_mm=cat(1,final_mm,mm_quad3);
%                 final_mm=cat(1,final_mm,zeros(1,mm_col));
%                 
%             if row_mm_quad4 >KP_max_noOf_groups_perQuad ;
%                 mm_quad4=sortrows(mm_quad4,-4);%ORDER BY LENGTHS DESCENDING
%                 mm_quad4=mm_quad4(1:KP_max_noOf_groups_perQuad,:); %TAKE TOP 20 PATTERNS
%                 mm_quad4=sortrows(mm_quad4,6);  % REARRAGNE BY DISTANCE FROM CENTER
%             end
%                 final_mm=cat(1,final_mm,mm_quad4);
%                 final_mm=cat(1,final_mm,zeros(2,mm_col)); %HERE SINCE THE IMAGE ENDS AS ITS 4TH QUADRANT WE ADD 2 ROWS !! YAY
%             
%         end


   
%     methods
%         function obj=display_obj(obj,x)
%             disp('object has a number =');
%             obj.x1=x;
%             disp(x);
%             
%         end
%         function add(tum,x)
%             disp(' tum.x1 in add function');
%            disp((tum.x1)+x);
%         end
%     end


end
