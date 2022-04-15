% This script passes detection files from a MOT Challenge file structure to
% OCSORT (in python). Before you run it, read the documentation for getting
% python setup with MATLAB.  When it was tested, it worked with Python 3.8. 
% Type "pyenv" in the Command Window to see which python environment MATLAB 
% will use.  Once you think you have it working, you can try running in the 
% Command Window
%               py.run_ocsort_once.TestFunc()
% to see if MATLAB can see python. If it works, "hello" will be printed,
% and then this script should work fine at that point.

clc
clear all
close all

% Assumed Dataset Structure
% MOT20Labels
%       -- train
%               -- MOT20-01
%                       -- det
%                               -- det.txt
%               -- MOT20-02
% -------------------------------------------------------------------------
% Assumes det.txt file is in standard MOT Challenge structure... 
% columns = [f, id, TLx, TLy, W, H, Conf, -1, -1, -1]
%   f  = frame
%   id = -1 in detection file, or track ID in the results file
%   TLx= top left x coordinate of bounding box
%   TLy= top left y coordinate of bounding box
%   W  = bounding box width
%   H  = bounding box height
%   Conf= confidence of detection - note the MOT20 files only have 0 or 1
%   for this value so if you want to use all of them, set the threshold to
%   a negative value.
% -------------------------------------------------------
DetConf_Thresh = -0.1; % confidence threshold
% -------------------------------------------------------------------------
Directory = 'MOT20Labels/train';
Files = dir(Directory);
Files = Files(3:length(Files)) % Get rid of trash entries - Windows version.  View the files variable to see what I am talking about
for i=1:length(Files)
    % -------------------------------------------------------------------------
    name{i} = Files(i).name;
    disp(name{i})
    InputVidName = sprintf('%s.mp4', name{i}(1:8));
    Det = readmatrix(sprintf('%s/%s/det/det.txt', Directory, name{i}));
    Det = Det(Det(:,7) >  DetConf_Thresh, :);
    % ---------------------------------------------------------------------
    % For MOT20 hyper-parameters are set as follows:
    var_det_thresh=-0.1; % official results use adaptive thresholding for confidence, but here we use all detections
    var_max_age=30;
    var_min_hits=3;
    var_iou_threshold=0.3;
    var_delta_t=3;
    var_inertia=0.2;
    try
        ret = py.run_ocsort_once.run_matlab_wrapper(py.numpy.array(Det), var_det_thresh, var_max_age, var_min_hits, var_iou_threshold, var_delta_t, var_inertia);
        Time = ret{1};
        track_result = double(ret{2}); % [f, ID, TLx, TLy, W, H, Confidence
        writematrix(track_result, sprintf('results/%s.txt', name{i}));
        
        fps = max(Det(:,1)) / Time % processing speed (frames / second)
    catch exception
        disp('error while calling the python tracking module: ')
        disp(' ')
        disp(getReport(exception))
    end
% -------------------------------------------------------------------------
end




