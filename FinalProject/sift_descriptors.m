
function [descriptors] = sift_descriptors(images,colorspace,feature_detector)
%%%%%%%%%%%%%
% images: cell of images
% colorspace: string "RGB","rgb","opponent"
% feature_detector: "dense", "keypoints"
%%%%%%%%%%%%%

descriptors_all = [];

for i = 1:length(images)
    
    im = im2single(cell2mat(images(i)));
    
    if (colorspace == 'RGB')
        descriptors = sift3d(im,feature_detector);
        
    elseif (colorspace == 'rgb')
        im = RGB2rgb(im);
        descriptors = sift3d(im,feature_detector);
        
    elseif (colorspace == 'opponent')
        im = rgb2opponent(im);
        descriptors = sift3d(im,feature_detector);
    end   
    
    descriptors_all = cat(1, descriptors_all, descriptors);
    
end

end

