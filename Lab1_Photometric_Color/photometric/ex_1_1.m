[image_stack_5, V_5] = load_image_stack('photometrics_images/SphereGray5');
[image_stack_25, V_25] = load_image_stack('photometrics_images/SphereGray25');

[albedo_5, normal_5] = estimate_alb_nrm(image_stack_5, V_5);
[albedo_25, normal_25] = estimate_alb_nrm(image_stack_25, V_25);

figure;
subplot(2, 3, 1);
imshow(albedo_5);

subplot_idx = 2;

for i = 5:5:25
    [albedo, normal] = estimate_alb_nrm(image_stack_25(:,:,1:i), V_25(1:i, :));
    
    subplot(3, 3, subplot_idx);
    imshow(albedo);
    
    subplot_idx = subplot_idx + 1;
end