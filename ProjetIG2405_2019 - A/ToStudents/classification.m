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
%         subplot(1,2,1)
%         imshow(picto)
%         subplot(1,2,2)
%         imshow(image)
%         pause(0.1);
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

