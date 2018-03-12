
function[best_model, best_model_score] = ransac(im1, im2, n_samples, n_iter)

radius = 10;

im1 = single(im1);
im2 = single(im2);
[f1, d1] = vl_sift(im1);
[f2, d2] = vl_sift(im2);
[matches, scores] = vl_ubcmatch(d1, d2);
num_matches = size(matches, 2);
% matches returs indexes of points, coordinates can then be found in f1
% and f2

figure(1)
imshowpair(im1, im2, 'montage')
hold on

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialise A and b for all matches.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
A_total = [];
b_total = [];
for i = 1:num_matches
    match_indexes = matches(:, i);
       
    % features vecs for both points
    im1_feat = f1(:, match_indexes(1));
    im2_feat = f2(:, match_indexes(2));

    % coordinates
    im1_feat_x = im1_feat(1);
    im1_feat_y = im1_feat(2);

    x_coord = im2_feat(1);
    y_coord = im2_feat(2);

    A = [im1_feat_x im1_feat_y 0 0 1 0; 0 0 im1_feat_x im1_feat_y 0 1];

    A_total = cat(1, A_total, A);
    b_total = cat(1, b_total, [x_coord y_coord]);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RANSAC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
best_model_score = 0;
best_model = zeros(6);

for iter = 1:n_iter
    
    rand_indexes = randperm(num_matches, n_samples);
    A_sample = [];
    b_sample = [];
    
    for rand_i = rand_indexes
        A_sample = cat(1, A_sample, A_total(rand_i, :));
        b_sample = cat(1, b_sample, b_total(rand_i, :));
    end
    
    x = pinv(A_sample) * b_sample;
    preds = A_total * x;
    
    n_inliers = 0;
    for i = 1:num_matches
        match = matches(:, i);
    
        % features vecs for both points
        x_coord = f2(1 , match(2));
        y_coord = f2(2 , match(2));
        
        offset = floor(radius / 2);
        
        for x = -offset:offset
            for y = -offset:offset
                if round(preds(i)) == round([x_coord + x; y_coord + y])
                    n_inliers = n_inliers + 1;
                    break
                end
            end
        end
    end
    
    if n_inliers > best_model_score
        best_model = x;
        best_model_score = n_inliers;
    end
    
end

end