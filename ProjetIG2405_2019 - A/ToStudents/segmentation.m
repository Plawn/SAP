function boxes = segmentation(n,resize)
%     figure;
    im  = im2double(imread(sprintf('IM (%d).JPG',n)));
    im 	= imresize(im,resize);

    r=im(:,:,1);
    r=imbinarize(r,graythresh(r));
    g=im(:,:,2);
    g=imbinarize(g,graythresh(g));
    b=im(:,:,3);
    b=imbinarize(b,graythresh(b));
    isum = (r&g&b);
    
    
%     subplot(1,2,1), imshow(im);
%     subplot(1,2,2), imshow(isum);
    
    [centers, radii] = imfindcircles(isum,[10 100],'Sensitivity',0.90,'ObjectPolarity','dark','method','TwoStage');
%     viscircles(centers,radii);

    boxes = zeros(1,5);
    for row = 1:length(radii)
        boxes(row,1)=n;
        boxes(row,2)=(centers(row,1)-radii(row));
        boxes(row,3)=(centers(row,1)+radii(row));
        boxes(row,4)=(centers(row,2)-radii(row));
        boxes(row,5)=(centers(row,2)+radii(row));
    end
 end

