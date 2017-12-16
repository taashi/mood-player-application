function [y,z,leftimg,rightimg,mouthimg,leftscore,rightscore,mouthscore] = detectfeaturesemotion( input_args )
%DETECTFEATURESEMOTION Summary of this function goes here
%   Detailed explanation goes here
% Each section of the code creates the eigenfeatures of the neutral, sad, happy and surprised emotions and compares them to the features detected in the image from the webcam

input_dir = 'neutral/righteye';
files = dir(fullfile(input_dir,'*.png')); % Detects all the png images in the input directory

neutral_right_eye_files = files; 
image_num = numel(files);
image_dimensions = [24,24];
images = [];
for n=1:image_num
    file = fullfile(input_dir,files(n).name);
    image = imread(file);
    if(n==1)
        images = zeros(prod(image_dimensions),image_num);
    end
    images(:,n) = image(:);
end

% Similar to detecting the face, we calculate the eigenfeature for the righteye, lefteye and mouth for all 4 emotions. 

mean_righteye = mean(images,2);
mean_shifted_images = images - repmat(mean_righteye,1,image_num);
[coefs,scores, variances] = princomp(images');
eigenfaces = 30;
coefs = coefs(:,1:eigenfaces);

features = coefs' * mean_shifted_images;

testimg = imread('righteye.png');
testimg = imresize(testimg,[24 24]); 
mean_test = double(testimg(:)) - mean_righteye;
test_featurevector = coefs' * mean_test;
similarity_score = arrayfun(@(n) 1/(1+norm(features(:,n)-test_featurevector)),1:image_num);

[neutral_righteyescore,neutralrightimg] = max(similarity_score);


input_dir = 'neutral/lefteye';
files = dir(fullfile(input_dir,'*.png'));
neutral_left_eye_files = files;
image_num = numel(files);
image_dimensions = [24,24];
images = [];
for n=1:image_num
    file = fullfile(input_dir,files(n).name);
    image = imread(file);
    if(n==1)
        images = zeros(prod(image_dimensions),image_num);
    end
    images(:,n) = image(:);
end
mean_lefteye = mean(images,2);
mean_shifted_images = images - repmat(mean_lefteye,1,image_num);
[coefs,scores, variances] = princomp(images');
eigenfaces = 30;
coefs = coefs(:,1:eigenfaces);

features = coefs' * mean_shifted_images;

testimg = imread('lefteye.png');
testimg = imresize(testimg,[24 24]); 
mean_test = double(testimg(:)) - mean_lefteye;
test_featurevector = coefs' * mean_test;
similarity_score = arrayfun(@(n) 1/(1+norm(features(:,n)-test_featurevector)),1:image_num);

[neutral_lefteyescore,neutralleftimg] = max(similarity_score);

input_dir = 'neutral/mouth';
files = dir(fullfile(input_dir,'*.png'));
neutral_mouth_files = files;
image_num = numel(files);
image_dimensions = [24,24];
images = [];
for n=1:image_num
    file = fullfile(input_dir,files(n).name);
    image = imread(file); 
    if(n==1)
        images = zeros(prod(image_dimensions),image_num);
    end
    images(:,n) = image(:);
end
mean_mouth = mean(images,2);
mean_shifted_images = images - repmat(mean_mouth,1,image_num);
[coefs,scores, variances] = princomp(images');
eigenfaces = 30;
coefs = coefs(:,1:eigenfaces);

features = coefs' * mean_shifted_images;

testimg = imread('mouth.png');
testimg = imresize(testimg,[24 24]); 
mean_test = double(testimg(:)) - mean_mouth;
test_featurevector = coefs' * mean_test;
similarity_score = arrayfun(@(n) 1/(1+norm(features(:,n)-test_featurevector)),1:image_num);

[neutral_mouth,neutralmouthimg] = max(similarity_score)

% The total neutral score is calculated by adding the mouth score to the average of the left and right eye scores giving the eyes and mouth equal weightage.
                                     
neutral_score = (neutral_mouth)+(neutral_lefteyescore+neutral_righteyescore)/2;
             
% Similar operations are done for 3 emotions remaining

input_dir = 'happy/righteye';
files = dir(fullfile(input_dir,'*.png'));
happy_right_eye_files = files;
image_num = numel(files);
image_dimensions = [24,24];
images = [];
for n=1:image_num
    file = fullfile(input_dir,files(n).name);
    image = imread(file);
    if(n==1)
        images = zeros(prod(image_dimensions),image_num);
    end
    images(:,n) = image(:);
end
mean_righteye = mean(images,2);
mean_shifted_images = images - repmat(mean_righteye,1,image_num);
[coefs,scores, variances] = princomp(images');
eigenfaces = 30;
coefs = coefs(:,1:eigenfaces);

features = coefs' * mean_shifted_images;

testimg = imread('righteye.png');
testimg = imresize(testimg,[24 24]); 
mean_test = double(testimg(:)) - mean_righteye;
test_featurevector = coefs' * mean_test;
similarity_score = arrayfun(@(n) 1/(1+norm(features(:,n)-test_featurevector)),1:image_num);

[happy_righteyescore,happyrightimg] = max(similarity_score);


input_dir = 'happy/lefteye';
files = dir(fullfile(input_dir,'*.png'));
happy_left_eye_files = files;
image_num = numel(files);
image_dimensions = [24,24];
images = [];
for n=1:image_num
    file = fullfile(input_dir,files(n).name);
    image = imread(file);
    if(n==1)
        images = zeros(prod(image_dimensions),image_num);
    end
    images(:,n) = image(:);
end
mean_lefteye = mean(images,2);
mean_shifted_images = images - repmat(mean_lefteye,1,image_num);
[coefs,scores, variances] = princomp(images');
eigenfaces = 30;
coefs = coefs(:,1:eigenfaces);

features = coefs' * mean_shifted_images;

testimg = imread('lefteye.png');
testimg = imresize(testimg,[24 24]); 
mean_test = double(testimg(:)) - mean_lefteye;
test_featurevector = coefs' * mean_test;
similarity_score = arrayfun(@(n) 1/(1+norm(features(:,n)-test_featurevector)),1:image_num);

[happy_lefteyescore,happyleftimg] = max(similarity_score);

input_dir = 'happy/mouth';
files = dir(fullfile(input_dir,'*.png'));
happy_mouth_files = files;
image_num = numel(files);
image_dimensions = [24,24];
images = [];
for n=1:image_num
    file = fullfile(input_dir,files(n).name);
    image = imread(file); 
    if(n==1)
        images = zeros(prod(image_dimensions),image_num);
    end
    images(:,n) = image(:);
end
mean_mouth = mean(images,2);
mean_shifted_images = images - repmat(mean_mouth,1,image_num);
[coefs,scores, variances] = princomp(images');
eigenfaces = 30;
coefs = coefs(:,1:eigenfaces);

features = coefs' * mean_shifted_images;

testimg = imread('mouth.png');
testimg = imresize(testimg,[24 24]); 
mean_test = double(testimg(:)) - mean_mouth;
test_featurevector = coefs' * mean_test;
similarity_score = arrayfun(@(n) 1/(1+norm(features(:,n)-test_featurevector)),1:image_num);

[happy_mouth,happymouthimg] = max(similarity_score)

happy_score = (happy_mouth+(happy_lefteyescore+happy_righteyescore)/2);

input_dir = 'sad/righteye';
files = dir(fullfile(input_dir,'*.png'));
sad_right_eye_files =files;
image_num = numel(files);
image_dimensions = [24,24];
images = [];
for n=1:image_num
    file = fullfile(input_dir,files(n).name);
    image = imread(file);
    if(n==1)
        images = zeros(prod(image_dimensions),image_num);
    end
    images(:,n) = image(:);
end
mean_righteye = mean(images,2);
mean_shifted_images = images - repmat(mean_righteye,1,image_num);
[coefs,scores, variances] = princomp(images');
eigenfaces = 30;
coefs = coefs(:,1:eigenfaces);

features = coefs' * mean_shifted_images;

testimg = imread('righteye.png');
testimg = imresize(testimg,[24 24]); 
mean_test = double(testimg(:)) - mean_righteye;
test_featurevector = coefs' * mean_test;
similarity_score = arrayfun(@(n) 1/(1+norm(features(:,n)-test_featurevector)),1:image_num);

[sad_righteyescore,sadrightimg] = max(similarity_score);


input_dir = 'sad/lefteye';
files = dir(fullfile(input_dir,'*.png'));
sad_left_eye_files =files;
image_num = numel(files);
image_dimensions = [24,24];
images = [];
for n=1:image_num
    file = fullfile(input_dir,files(n).name);
    image = imread(file);
    if(n==1)
        images = zeros(prod(image_dimensions),image_num);
    end
    images(:,n) = image(:);
end
mean_lefteye = mean(images,2);
mean_shifted_images = images - repmat(mean_lefteye,1,image_num);
[coefs,scores, variances] = princomp(images');
eigenfaces = 30;
coefs = coefs(:,1:eigenfaces);

features = coefs' * mean_shifted_images;

testimg = imread('lefteye.png');
testimg = imresize(testimg,[24 24]); 
mean_test = double(testimg(:)) - mean_lefteye;
test_featurevector = coefs' * mean_test;
similarity_score = arrayfun(@(n) 1/(1+norm(features(:,n)-test_featurevector)),1:image_num);

[sad_lefteyescore,sadleftimg] = max(similarity_score);

input_dir = 'sad/mouth';
files = dir(fullfile(input_dir,'*.png'));
sad_mouth_files =files;
image_num = numel(files);
image_dimensions = [24,24];
images = [];
for n=1:image_num
    file = fullfile(input_dir,files(n).name);
    image = imread(file); 
    if(n==1)
        images = zeros(prod(image_dimensions),image_num);
    end
    images(:,n) = image(:);
end
mean_mouth = mean(images,2);
mean_shifted_images = images - repmat(mean_mouth,1,image_num);
[coefs,scores, variances] = princomp(images');
eigenfaces = 30;
coefs = coefs(:,1:eigenfaces);

features = coefs' * mean_shifted_images;

testimg = imread('mouth.png');
testimg = imresize(testimg,[24 24]); 
mean_test = double(testimg(:)) - mean_mouth;
test_featurevector = coefs' * mean_test;
similarity_score = arrayfun(@(n) 1/(1+norm(features(:,n)-test_featurevector)),1:image_num);

[sad_mouth,sadmouthimg] = max(similarity_score);

sad_score = (sad_mouth+(sad_lefteyescore+sad_righteyescore)/2);

input_dir = 'surprised/righteye';
files = dir(fullfile(input_dir,'*.png'));
surprised_right_eye_files =files;
image_num = numel(files);
image_dimensions = [24,24];
images = [];
for n=1:image_num
    file = fullfile(input_dir,files(n).name);
    image = imread(file);
    if(n==1)
        images = zeros(prod(image_dimensions),image_num);
    end
    images(:,n) = image(:);
end
mean_righteye = mean(images,2);
mean_shifted_images = images - repmat(mean_righteye,1,image_num);
[coefs,scores, variances] = princomp(images');
eigenfaces = 30;
coefs = coefs(:,1:eigenfaces);

features = coefs' * mean_shifted_images;

testimg = imread('righteye.png');
testimg = imresize(testimg,[24 24]); 
mean_test = double(testimg(:)) - mean_righteye;
test_featurevector = coefs' * mean_test;
similarity_score = arrayfun(@(n) 1/(1+norm(features(:,n)-test_featurevector)),1:image_num);

[surprised_righteyescore,surprisedrightimg] = max(similarity_score);


input_dir = 'surprised/lefteye';
files = dir(fullfile(input_dir,'*.png'));
surprised_left_eye_files =files;
image_num = numel(files);
image_dimensions = [24,24];
images = [];
for n=1:image_num
    file = fullfile(input_dir,files(n).name);
    image = imread(file);
    if(n==1)
        images = zeros(prod(image_dimensions),image_num);
    end
    images(:,n) = image(:);
end
mean_lefteye = mean(images,2);
mean_shifted_images = images - repmat(mean_lefteye,1,image_num);
[coefs,scores, variances] = princomp(images');
eigenfaces = 30;
coefs = coefs(:,1:eigenfaces);

features = coefs' * mean_shifted_images;

testimg = imread('lefteye.png');
testimg = imresize(testimg,[24 24]); 
mean_test = double(testimg(:)) - mean_lefteye;
test_featurevector = coefs' * mean_test;
similarity_score = arrayfun(@(n) 1/(1+norm(features(:,n)-test_featurevector)),1:image_num);

[surprised_lefteyescore,surprisedleftimg] = max(similarity_score);

input_dir = 'surprised/mouth';
files = dir(fullfile(input_dir,'*.png'));
surprised_mouth_files =files;
image_num = numel(files);
image_dimensions = [24,24];
images = [];
for n=1:image_num
    file = fullfile(input_dir,files(n).name);
    image = imread(file); 
    if(n==1)
        images = zeros(prod(image_dimensions),image_num);
    end
    images(:,n) = image(:);
end
mean_mouth = mean(images,2);
mean_shifted_images = images - repmat(mean_mouth,1,image_num);
[coefs,scores, variances] = princomp(images');
eigenfaces = 30;
coefs = coefs(:,1:eigenfaces);

features = coefs' * mean_shifted_images;

testimg = imread('mouth.png');
testimg = imresize(testimg,[24 24]); 
mean_test = double(testimg(:)) - mean_mouth;
test_featurevector = coefs' * mean_test;
similarity_score = arrayfun(@(n) 1/(1+norm(features(:,n)-test_featurevector)),1:image_num);

[surprised_mouth,surprisedmouthimg] = max(similarity_score);

surprised_score = (surprised_mouth+(surprised_lefteyescore+surprised_righteyescore)/2);
                                     
% Once all the scores are calculated for each emotion, we find the maximum score amongst all the emotions and that is the detected emotion using eigenfeatures. 

emotion_scores = [neutral_score happy_score sad_score surprised_score]

[emotion_score,emotion] = max(emotion_scores);

if(emotion ==1)
    y = 'Neutral';
    leftimg = imread(fullfile('neutral/lefteye',neutral_left_eye_files(neutralleftimg).name));
    rightimg = imread(fullfile('neutral/righteye',neutral_right_eye_files(neutralrightimg).name));
    mouthimg = imread(fullfile('neutral/mouth',neutral_mouth_files(neutralmouthimg).name));
    rightscore = neutral_righteyescore;
    leftscore = neutral_lefteyescore;
    mouthscore = neutral_mouth;
elseif (emotion==2)
    y = 'Happy';
    leftimg = imread(fullfile('happy/lefteye',happy_left_eye_files(happyleftimg).name));
    rightimg = imread(fullfile('happy/righteye',happy_right_eye_files(happyrightimg).name));
    mouthimg = imread(fullfile('happy/mouth',happy_mouth_files(happymouthimg).name));
    rightscore = happy_righteyescore;
    leftscore = happy_lefteyescore;
    mouthscore = happy_mouth;
elseif (emotion ==3)
    y = 'Sad';
    leftimg = imread(fullfile('sad/lefteye',sad_left_eye_files(sadleftimg).name));
    rightimg = imread(fullfile('sad/righteye',sad_right_eye_files(sadrightimg).name));
    mouthimg = imread(fullfile('sad/mouth',sad_mouth_files(sadmouthimg).name));
    rightscore = sad_righteyescore;
    leftscore = sad_lefteyescore;
    mouthscore = sad_mouth;
else
    y = 'Surprised';
    leftimg = imread(fullfile('surprised/lefteye',surprised_left_eye_files(surprisedleftimg).name));
    rightimg = imread(fullfile('surprised/righteye',surprised_right_eye_files(surprisedrightimg).name));
    mouthimg = imread(fullfile('surprised/mouth',surprised_mouth_files(surprisedmouthimg).name));
    rightscore = surprised_righteyescore;
    leftscore = surprised_lefteyescore;
    mouthscore = surprised_mouth;
end

z= emotion_scores;

if(ndims(leftimg)>2)
    leftimg = rgb2gray(leftimg);
end
if(ndims(rightimg)>2)
    rightimg = rgb2gray(rightimg);
end
if(ndims(mouthimg)>2)
    mouthimg = rgb2gray(mouthimg);
end
end

