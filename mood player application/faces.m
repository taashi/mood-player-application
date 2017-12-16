%Scans through all the images in the faces database and converts them to
%png.

input_dir = 'neutral/faces';
files = dir(fullfile(input_dir,'*.jpg'));
image_num = numel(files);
image_dimensions = [64,64];
images = [];
for n=1:image_num
    file = fullfile(input_dir,files(n).name);
    image = imread(file);
    faceDetector = vision.CascadeObjectDetector;
    face = step(faceDetector,image);
    image = imcrop(image,face);
    image = imresize(image,[64 64]); 
    image = rgb2gray(image);
    imwrite(image,sprintf('%s.gif',files(n).name));
end
input_dir = 'happy/faces';
files = dir(fullfile(input_dir,'*.jpg'));
image_num = numel(files);
image_dimensions = [64,64];
images = [];
for n=1:image_num
    file = fullfile(input_dir,files(n).name);
    image = imread(file);
    faceDetector = vision.CascadeObjectDetector;
    face = step(faceDetector,image);
    image = imcrop(image,face);
    image = imresize(image,[64 64]);
    image = rgb2gray(image);
    imwrite(image,sprintf('%s.gif',files(n).name));
end
input_dir = 'sad/faces';
files = dir(fullfile(input_dir,'*.jpg'));
image_num = numel(files);
image_dimensions = [64,64];
images = [];
for n=1:image_num
    file = fullfile(input_dir,files(n).name);
    image = imread(file);
    faceDetector = vision.CascadeObjectDetector;
    face = step(faceDetector,image);
    image = imcrop(image,face);
    image = imresize(image,[64 64]); 
    imwrite(image,sprintf('%s.gif',files(n).name));
end
input_dir = 'surprised/faces';
files = dir(fullfile(input_dir,'*.tiff'));
image_num = numel(files);
image_dimensions = [64,64];
images = [];
for n=1:image_num
    file = fullfile(input_dir,files(n).name);
    image = imread(file);
    faceDetector = vision.CascadeObjectDetector;
    face = step(faceDetector,image);
    image = imcrop(image,face);
    image = imresize(image,[64 64]);
    imwrite(image,sprintf('%s.gif',files(n).name));
end