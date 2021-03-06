%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Image Classification with the Bag-of-Words model %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Fixed parameters
sample_size = 100;
train_set_size = 50;
test_set_size = 50;
n_classes = 4;


%% Hyperparameters
detector_types = ["keypoints", "dense"];
colorspaces = ["RGB", "rgb", "opponent"];
kernels = {'linear', 'RBF'};
vocab_sizes = [400, 800, 1600, 2000, 4000];


%% Image loading

% Training set
images_airplanes = load_image_stack('Caltech4/ImageData/airplanes_train', sample_size + train_set_size, false);
images_cars = load_image_stack('Caltech4/ImageData/cars_train', sample_size + train_set_size, false);
images_faces = load_image_stack('Caltech4/ImageData/faces_train', sample_size + train_set_size, false);
images_motorbikes = load_image_stack('Caltech4/ImageData/motorbikes_train', sample_size + train_set_size, false);

images_vocab_building = [images_airplanes(1:sample_size), ...
    images_cars(1:sample_size),      ...
    images_faces(1:sample_size),     ...
    images_motorbikes(1:sample_size) ...
    ];

images_train = [images_airplanes(sample_size+1:end), ...
    images_cars(sample_size+1:end),      ...
    images_faces(sample_size+1:end),     ...
    images_motorbikes(sample_size+1:end) ...
    ];

% Test set
images_airplanes = load_image_stack('Caltech4/ImageData/airplanes_test', test_set_size, true);
images_cars = load_image_stack('Caltech4/ImageData/cars_test', test_set_size, true);
images_faces = load_image_stack('Caltech4/ImageData/faces_test',  test_set_size, true);
images_motorbikes = load_image_stack('Caltech4/ImageData/motorbikes_test', test_set_size, true);

images_test = [images_airplanes, images_cars, images_faces, images_motorbikes];

% Write classification ranking and average precision to file
file_out = fopen('html_output.txt', 'w');
fclose(file_out);

%% Optimisation
map_values = {};
setting_idx = 1;

for detector_idx = 1:length(detector_types)
    detector = detector_types(detector_idx);
    
    for colorspace_idx = 1:length(colorspaces)
        colorspace = colorspaces(colorspace_idx);
        
        for vocab_size_idx = 1:length(vocab_sizes)
            vocab_size = vocab_sizes(vocab_size_idx);
            
            % obtain a sample of descriptors to build a vocabulary
            descriptors = sift_descriptors(images_vocab_building, colorspace, detector);
            % normalize descriptors
            descriptors = normr(double(descriptors));  
            
            % Find prototypical descriptors, i.e. the visual words
            [~, centroids] = kmeans(descriptors, vocab_size, 'MaxIter', 100);
            centroids = normr(centroids);
            
            for kernel_idx = 1:length(kernels)
                kernel = cell2mat(kernels(kernel_idx));
                
                disp({detector, colorspace, vocab_size, kernel});
                t = cputime;
                
                % run Bag-of-Words and compute mean average precision
                map_values{setting_idx} = BoW(centroids, images_train, ...
                    images_test, colorspace, detector, ...
                    vocab_size, train_set_size, ...
                    test_set_size, kernel);

                disp(cputime - t);
            end
        end
    end
end
