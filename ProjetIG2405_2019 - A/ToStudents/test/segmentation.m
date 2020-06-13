% function [imageOut, mapOut] = segmentation(im, map)
clear all
close all
clc

%% Load image

n = [1 10 11 12 16 102 103 118 119];
segmentedboxes = [];

for image = 1:length(n)
%     figure;
    im  = im2double(imread(sprintf('IM (%d).JPG',n(image))));
    im 	= imresize(im,0.5);
% 
%     im = im2single(im);
%     [L, Centers] = imsegkmeans(im,3,'MaxIterations',300);
%     B = labeloverlay(im,L);
% 
% %     thresh = multithresh(im,3);
% %     seg_I = imquantize(im,thresh);
% %     RGB = label2rgb(seg_I);



%    tester sans faire les differents canaux
%     



%     subplot(1,2,1), imshow(im);
%     subplot(1,2,2), imshow(B);
%     stats = regionprops('table',B,'Centroid','MajorAxisLength','MinorAxisLength')
%     centers = stats.Centroid;
%     diameters = mean([stats.MajorAxisLength stats.MinorAxisLength],2);
%     radii = diameters/2;
% %     [centers, radii] = imfindcircles(B,[10 100]);
%     viscircles(centers, radii,'EdgeColor','r');

    r=im(:,:,1);
    r=imbinarize(r,graythresh(r));
    g=im(:,:,2);
    g=imbinarize(g,graythresh(g));
    b=im(:,:,3);
    b=imbinarize(b,graythresh(b));
    isum = (r&g&b);
    
    [centers, radii] = imfindcircles(isum,[10 100],'Sensitivity',0.90,'ObjectPolarity','dark','method','TwoStage');
    
    if n(image) == 10 
        figure
        subplot(1,2,1), imshow(im);
        subplot(1,2,2), imshow(isum);
        viscircles(centers,radii);
    end

%     subplot(2,2,3), imshow(g);
%     subplot(2,2,4), imshow(b);
    boxes = zeros(1,5);
    for row = 1:length(radii)
        boxes(row,1)=n(image);
        boxes(row,2)=(centers(row,1)-radii(row));
        boxes(row,3)=(centers(row,1)+radii(row));
        boxes(row,4)=(centers(row,2)-radii(row));
        boxes(row,5)=(centers(row,2)+radii(row));
    end
    segmentedboxes = [segmentedboxes;boxes];
end
% end
%%
% close all
addpath('PICTO')
pictodetected = [];
for listpicto = (1:14)
    if listpicto < 10 
        picto = imread(sprintf('0%d.png',listpicto));
    else
        picto = imread(sprintf('%d.png',listpicto));
    end
    pictogray=rgb2gray(picto);
    imagenumber = 0;
%     close all
%     figure
    subplot(1,2,1)
    imshow(picto)
% corrtable = zeros(length(segmentedboxes),1);
    for box = 1:length(segmentedboxes)

        if segmentedboxes(box) ~= imagenumber
            imagenumber = segmentedboxes(box);
            image = imread(sprintf('IM (%d).JPG',imagenumber));
            image = imresize(image,0.5);
            subplot(1,2,2)
            imshow(image)
            pause(0.5);
        end
        x = round(segmentedboxes(box,2));
        y = round(segmentedboxes(box,4));
        width  = round(segmentedboxes(box,3)-x)+10;
        if x-5<=0 || y-5<=0 || x+width > size(image,2)|| y+width > size(image,1)
            continue
        end
        imagebox = image([y-5:y+width],[x-5:x+width],[1:3]);
    %     if width > 70 && imagenumber == 1 && width < 80
    %         figure
    %         imshow(imagebox)
    %         title(sprintf('box %d',box))
    %     end
    %     if width > 60
    %         imagebox = imresize(imagebox, [60 60]);
    %     elseif width < 60
    %         pad = round((60-length(imagebox))/2);
    %         imagebox = padarray(imagebox,[pad pad],255,'both');
    %         if length(imagebox)==61
    %             imagebox = imagebox(1:end-1,1:end-1,:);
    %         end
    %     elseif length(imagebox)==61
    %         imagebox = imagebox(1:end-1,1:end-1,:);
    %     end

    %     imagebox = rgb2gray(imagebox);
    %     picto = rgb2gray(picto);
    %     corrtable(box) = (corr2(imagebox(:,:,1),picto(:,:,1))+corr2(imagebox(:,:,2),picto(:,:,2))+corr2(imagebox(:,:,3),picto(:,:,3)))/3;


        imageboxgray = rgb2gray(imagebox);
        boxPoints = detectSURFFeatures(pictogray);
        scenePoints = detectSURFFeatures(imageboxgray);
%         figure
%         imshow(pictogray)
%         hold on
%         plot(selectStrongest(boxPoints, 100));
%         figure
%         imshow(imageboxgray)
%         hold on
%         plot(selectStrongest(scenePoints, 100));
        [boxFeatures, boxPoints] = extractFeatures(pictogray, boxPoints);
        [sceneFeatures, scenePoints] = extractFeatures(imageboxgray, scenePoints);
        boxPairs = matchFeatures(boxFeatures, sceneFeatures);
    %     Display putatively matched features.
        matchedBoxPoints = boxPoints(boxPairs(:, 1), :);
        matchedScenePoints = scenePoints(boxPairs(:, 2), :);
%         figure;
%         showMatchedFeatures(pictogray, imageboxgray, matchedBoxPoints, ...
%          matchedScenePoints, 'montage');
%         title('Putatively Matched Points (Including Outliers)');


       if isempty(boxPairs) == 0
           foundpicto = zeros(1,5);
           foundpicto(1)=imagenumber;
           foundpicto(2)=segmentedboxes(box,2);
           foundpicto(3)=segmentedboxes(box,3);
           foundpicto(4)=segmentedboxes(box,4);
           foundpicto(5)=segmentedboxes(box,5);
           foundpicto(6)=listpicto;
           pictodetected = [pictodetected;foundpicto];
       end
    end
    
end

    



    %     [tform, inlierBoxPoints, inlierScenePoints] = ...
    %      estimateGeometricTransform(matchedBoxPoints, matchedScenePoints,...
    %      'affine');
    % 
    %     figure;
    %     showMatchedFeatures(boxImage, sceneImage, inlierBoxPoints, ...
    %      inlierScenePoints, 'montage');
    %     title('Matched Points (Inliers Only)');
    %     
    %     boxPolygon = [1, 1;... % top-left
    %      size(pictogray, 2), 1;... % top-right
    %      size(pictogray, 2), size(pictogray, 1);... % bottom-right
    %      1, size(pictogray, 1);... % bottom-left
    %      1, 1]; % top-left again to close the polygon
    %     newBoxPolygon = transformPointsForward(tform, boxPolygon);
    %     figure;
    %     imshow(imageboxgray);
    %     hold on;
    %     line(newBoxPolygon(:, 1), newBoxPolygon(:, 2), 'Color', 'y');
    %     title('Detected Box');

