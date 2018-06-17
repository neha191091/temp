import glob
import os

import matplotlib.pyplot as plt
import numpy as np
import tensorflow as tf
from scipy import misc
from shutil import copy
import scipy.ndimage
import cv2

depthpath_test = '/media/neha/ubuntu/data/segmentation/neha_11_5_2_refined/seq_depth00843.png'
#depthpath_train = '/home/neha/Documents/repo/segmentation/segmentation_python/data/raw_data_render_example_by_4/human_0_depth_70_0001.png'
depthpath_train = '/home/neha/Documents/data/blender_data/render_data_corrected/human_0_depth_33_0001.png'

depth_test = misc.imread(depthpath_test, mode='F')
depth_train = misc.imread(depthpath_train, mode='F')

print('depth_test shape: ',depth_test.shape)

depth_test_resized = cv2.resize(depth_test, (depth_test.shape[1], depth_test.shape[0]), interpolation=cv2.INTER_AREA)
depth_test_resized = np.where(depth_test_resized <= 0, 10000, depth_test_resized)
#depth_test_resized = depth_test_resized + 6700
depth_test_resized = np.where(depth_test_resized >= 10000, 10000, depth_test_resized)
print('depth_test resized shape: ',depth_test.shape)

print('depth_train shape: ',depth_train.shape)

print('depth_test')
print('min: ', depth_test.min())
print('max: ', depth_test.max())

print('depth_test resized')
print('min: ', depth_test_resized.min())
print('max: ', np.where(depth_test_resized >= 10000, 0, depth_test_resized).max())
depth_test_min_pos = np.unravel_index(depth_test_resized.argmin(), depth_test_resized.shape)
depth_test_max_pos = np.unravel_index(np.where(depth_test_resized >= 10000, 0, depth_test_resized).argmax(), depth_test_resized.shape)
depth_test_resized[depth_test_min_pos] = 0
depth_test_resized[depth_test_max_pos] = 0
print('min pos: ', depth_test_min_pos)
print('max pos: ', depth_test_max_pos)

print('depth_train')
print('min: ', depth_train.min())
print('max: ', np.where(depth_train >= 10000, 0, depth_train).max())
depth_train_min_pos = np.unravel_index(depth_train.argmin(), depth_train.shape)
depth_train_max_pos = np.unravel_index(np.where(depth_train >= 10000, 0, depth_train).argmax(), depth_train.shape)
depth_train[depth_train_min_pos] = 0
depth_train[depth_train_max_pos] = 0
print('min pos: ', depth_train_min_pos)
print('max pos: ', depth_train_max_pos)


sub_plot = plt.subplot(1, 2, 1)
sub_plot.hlines(y = depth_test_min_pos[0], xmin = 0, xmax = 479, colors = "red", linewidth = 0.5)
sub_plot.vlines(x = depth_test_min_pos[1], ymin = 0, ymax = 639, colors = "red", linewidth = 0.5)
sub_plot.hlines(y = depth_test_max_pos[0], xmin = 0, xmax = 479, colors = "blue", linewidth = 0.5)
sub_plot.vlines(x = depth_test_max_pos[1], ymin = 0, ymax = 639, colors = "blue", linewidth = 0.5)
plt.imshow(depth_test_resized, vmin=0, vmax=10000)
plt.axis('off')
sub_plot = plt.subplot(1, 2, 2)
sub_plot.hlines(y = depth_train_min_pos[0], xmin = 0, xmax = 479, colors = "red", linewidth = 0.5)
sub_plot.vlines(x = depth_train_min_pos[1], ymin = 0, ymax = 639, colors = "red", linewidth = 0.5)
sub_plot.hlines(y = depth_train_max_pos[0], xmin = 0, xmax = 479, colors = "blue", linewidth = 0.5)
sub_plot.vlines(x = depth_train_max_pos[1], ymin = 0, ymax = 639, colors = "blue", linewidth = 0.5)
plt.imshow(depth_train, vmin=0, vmax=10000)
plt.axis('off')
#plt.imshow(depth_test_resized, vmin=0, vmax=10000)
plt.show()