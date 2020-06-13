%% Programme principal de reconnaissance et de sauvegarde des résultats
% -------------------------------------------------------------------------
% Input :
%           type = 'Test' ou 'Learn' pour définir les images traitées
% Outputs
%           fileOut  :      nom (string) du fichier .mat des résultats de
%                           reconnaissance
%           resizeFactor :  facteur de redimensionnement qui a été appliqué
%                           aux images
% 
%--------------------------------------------------------------------------

clear all;
close all;
clc 

function [fileOut,resizeFactor] = metro(type)


% Sélectionner les images en fonction de la base de données, apprentissage ou test

n = 1:261;
if strcmp(type,'Test')
    numImages  = n(find(mod(n,3)));
elseif strcmp(type,'Learn')
    numImages  = n(find(~mod(n,3)));
else
    ok = 0;
    uiwait(errordlg('Bad identifier (should be ''Learn'' or ''Test'' ','ERRORDLG'));
end
%%

if ok
    % Definir le facteur de redimensionnement
    resizeFactor =  0.5;
    addpath('PICTO')
    % Programme de reconnaissance des images
    for n = numImages

        boxes = segmentation(n,resizeFactor)
        classification(boxes,resize,n)
%         -- RECONNAISSANCE DES SYMBOLES DANS L'IMAGE n
%         
%         -- STOCAGE DANS LA MATRICE BD de 6 colonnes
    end
    
    % Sauvegarde dans un fichier .mat des résulatts
    fileOut  = 'myResuts.mat';
    save(fileOut,'BD');
    
end
end


function segmentedboxes = segmentation(n,resize)
    figure;
    im  = im2double(imread(sprintf('IM (%d).JPG',n)));
    im 	= imresize(im,resize);

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

    boxes = zeros(1,5);
    for row = 1:length(radii)
        boxes(row,1)=n;
        boxes(row,2)=(centers(row,1)-radii(row));
        boxes(row,3)=(centers(row,1)+radii(row));
        boxes(row,4)=(centers(row,2)-radii(row));
        boxes(row,5)=(centers(row,2)+radii(row));
    end
    segmentedboxes = [segmentedboxes;boxes];
end


function pictodetected = classification(segmentedboxes,resize,imagenumber)
    pictodetected = [];
    image = imread(sprintf('IM (%d).JPG',imagenumber));
    image = imresize(image,resize);
    for listpicto = (1:14)
        if listpicto < 10 
            picto = imread(sprintf('0%d.png',listpicto));
        else
            picto = imread(sprintf('%d.png',listpicto));
        end
        pictogray=rgb2gray(picto);
        
    %     close all
    %     figure
        subplot(1,2,1)
        imshow(picto)
        subplot(1,2,2)
        imshow(image)
        pause(0.1);
        for box = 1:length(segmentedboxes)
            x = round(segmentedboxes(box,2));
            y = round(segmentedboxes(box,4));
            width  = round(segmentedboxes(box,3)-x)+10;
            if x-5<=0 || y-5<=0 || x+width > size(image,2)|| y+width > size(image,1)
                continue
            end
            imagebox = image([y-5:y+width],[x-5:x+width],[1:3]);    
            imageboxgray = rgb2gray(imagebox);
            boxPoints = detectSURFFeatures(pictogray);
            scenePoints = detectSURFFeatures(imageboxgray);        
            [boxFeatures, boxPoints] = extractFeatures(pictogray, boxPoints);
            [sceneFeatures, scenePoints] = extractFeatures(imageboxgray, scenePoints);
            boxPairs = matchFeatures(boxFeatures, sceneFeatures);

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
end