%% Programme principal de reconnaissance et de sauvegarde des r�sultats
% -------------------------------------------------------------------------
% Input :
%           type = 'Test' ou 'Learn' pour d�finir les images trait�es
% Outputs
%           fileOut  :      nom (string) du fichier .mat des r�sultats de
%                           reconnaissance
%           resizeFactor :  facteur de redimensionnement qui a �t� appliqu�
%                           aux images
% 
%--------------------------------------------------------------------------



function [fileOut,resizeFactor] = metro(type)
tic
% clear all;
% close all;
% clc 
% S�lectionner les images en fonction de la base de donn�es, apprentissage ou test

ok = 1; 
n = 1:261;
if strcmp(type,'Test')
    numImages  = n(find(mod(n,3)));
    fileOut  = 'myTestResults.mat';
elseif strcmp(type,'Learn')
    numImages  = n(find(~mod(n,3)));
    fileOut  = 'myLearnResults.mat';
else
    ok = 0;
    uiwait(errordlg('Bad identifier (should be ''Learn'' or ''Test'' ','ERRORDLG'));
end


if ok
    % Definir le facteur de redimensionnement
    resizeFactor =  0.5;
    addpath('PICTO')
    addpath('BD')
    % Programme de reconnaissance des images
    BD = [];
    progress = waitbar(0, 'Analysing images, please wait...');
    for n = numImages
        
        boxes = segmentation(n,resizeFactor);
        pictodetected = classification(boxes,resizeFactor,n);
        BD = [BD;pictodetected];
%         -- RECONNAISSANCE DES SYMBOLES DANS L'IMAGE n
%         
%         -- STOCAGE DANS LA MATRICE BD de 6 colonnes

        
        waitbar((n/3)/length(numImages),progress,sprintf('image %d out of %d',n/3,length(numImages))); 
    end
    close(progress)
    
    % Sauvegarde dans un fichier .mat des r�sulatts
    
    save(fileOut,'BD');
    toc
end
end