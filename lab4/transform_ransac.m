% demo ransac transform

clear all;
close all;

im1 = imread('boat1.pgm');
im2 = imread('boat2.pgm');

A_total = [];
[h,w] = size(im1);
transformed_image = zeros(h,w);
[num_matches,~, best_model, best_model_score] = ransac(im1, im2, 50, 100);

for x = 1:h
    for y = 1:w
    
    A = [x y 0 0 1 0; 0 0 x y 0 1];

    new_coords = round(A * best_model);
    if new_coords(1) < 1  new_coords(1) = 1;  end %#ok<*SEPEX>
    if new_coords(1) > h   new_coords(1) = h;  end
    if new_coords(2) < 1  new_coords(2) = 1;  end
    if new_coords(2) > w   new_coords(2) = w;  end
    
    
    transformed_image(new_coords(1),new_coords(2)) = im1(x,y) ;

    
    
    end
end



figure(3)
imshow(uint8(transformed_image))

    