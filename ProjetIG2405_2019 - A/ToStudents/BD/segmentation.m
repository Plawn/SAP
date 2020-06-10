% function [imageOut, mapOut] = segmentation(im, map)
clear all
close all
clc

%% Load image

n = [1 10 11 12 16 102 103 118 119];
segmentedboxes = [];

for image = 1:length(n)
    figure;
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
%   
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
    
    
    subplot(1,2,1), imshow(im);
    subplot(1,2,2), imshow(isum);
    
    [centers, radii] = imfindcircles(isum,[10 100],'Sensitivity',0.90,'ObjectPolarity','dark','method','TwoStage');
    viscircles(centers,radii);

%     subplot(2,2,3), imshow(g);
%     subplot(2,2,4), imshow(b);
    boxes = zeros(1,5);
    for row = 1:length(radii)
        boxes(row,1)=image;
        boxes(row,2)=(centers(row,1)-radii(row));
        boxes(row,3)=(centers(row,1)+radii(row));
        boxes(row,4)=(centers(row,2)-radii(row));
        boxes(row,5)=(centers(row,2)+radii(row));
    end
    segmentedboxes = [segmentedboxes;boxes];
end
% end

