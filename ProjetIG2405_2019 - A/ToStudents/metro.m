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
    
    % Programme de reconnaissance des images
    for n = numImages

        boxes = segmentation(n)
        -- RECONNAISSANCE DES SYMBOLES DANS L'IMAGE n
        
        -- STOCAGE DANS LA MATRICE BD de 6 colonnes
    end
    
    % Sauvegarde dans un fichier .mat des résulatts
    fileOut  = 'myResuts.mat';
    save(fileOut,'BD');
    
end
end


function segmentedboxes = segmentation(n)
    figure;
    im  = im2double(imread(sprintf('IM (%d).JPG',n)));
    im 	= imresize(im,0.5);

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
