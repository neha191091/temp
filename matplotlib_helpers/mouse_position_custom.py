import matplotlib.pyplot as plt
import numpy as np

import mpld3
from mpld3 import plugins

import os
import scipy.io as sio

def load_mat2numpy(path, key='gradients'):
    mat_data = sio.loadmat(path)
    gradients = mat_data[key]
    return gradients



class MousePositionCustomPlugin(plugins.PluginBase):
    """A simple plugin showing how multiple axes can be linked"""

    JAVASCRIPT = """
    mpld3.register_plugin("mouseposition", MousePositionCustomPlugin);
    MousePositionCustomPlugin.prototype = Object.create(mpld3.Plugin.prototype);
    MousePositionCustomPlugin.prototype.constructor = MousePositionCustomPlugin;
    MousePositionCustomPlugin.prototype.requiredProps = ["shape_0", "shape_1","X"];
    MousePositionCustomPlugin.prototype.defaultProps = {fontsize: 12, fmt: ".3g"};
    function MousePositionCustomPlugin(fig, props){
        mpld3.Plugin.call(this, fig, props);
    };
    
    MousePositionCustomPlugin.prototype.draw = function(){
        var fig = this.fig;
        var fmt = d3.format(this.props.fmt);
        var shape_0 = this.props.shape_0;
        var shape_1 = this.props.shape_1;
        var X = this.props.X;
        var coords = fig.canvas.append("text")
                        .attr("class", "mpld3-coordinates")
                        .style("text-anchor", "end")
                        .style("font-size", this.props.fontsize)
                        .attr("x", this.fig.width - 5)
                        .attr("y", this.fig.height - 5);
    
        for (var i=0; i < this.fig.axes.length; i++) {
          var update_coords = function() {
                var ax = fig.axes[i];
                return function() {
                  var pos = d3.mouse(this),
                      x = ax.x.invert(pos[0]),
                      y = ax.y.invert(pos[1]);
                      x_cell = parseInt(x/shape_1)+1,
                      y_cell = parseInt(y/shape_1)+1;
                      x_pos = parseInt(x) - parseInt(x/shape_1)*shape_1+1,
                      y_pos = parseInt(y) - parseInt(y/shape_1)*shape_1+1;
                      val = parseFloat(X[parseInt(x)][parseInt(y)]);
                      console.log(val);
                  //coords.text("(" + fmt(x) + ", " + fmt(y) + ")");
                  coords.text("(" + fmt(x_cell) + ", " + fmt(y_cell) + " ; " + fmt(x_pos) + ", " + fmt(y_pos) + " ; " + val + ")");
                };
              }();
          fig.axes[i].baseaxes
            .on("mousemove", update_coords)
            .on("mouseout", function() { coords.text(""); });
        }
    };
    """

    def __init__(self, shape_0, shape_1, X, fontsize=12, fmt=".3g"):
        self.dict_ = {"type": "mouseposition",
                      "shape_0": shape_0,
                      "shape_1": shape_1,
                      "X": X,
                      "fontsize": fontsize,
                      "fmt": fmt}

fig, ax = plt.subplots()

fig = plt.figure(figsize=(15,15))
ax = fig.add_subplot(1, 1, 1)

#Load a mat file - Here we are load our gradient from the mat file - format (15,15,21,21) and reformat it
print('Get gradient')
X = load_mat2numpy('/home/neha/Documents/repo/dl4cv_prak/experiments/1ABA_A/1ABA_A_3_20_32.mat')
X = X.transpose(2,0,3,1)
shape_0 = X.shape[0]
shape_1 = X.shape[1]
X = X.reshape(X.shape[0]*X.shape[1],-1)
print(X.shape)

max_abs_val = np.abs(X).max()
vmin = -max_abs_val
vmax = max_abs_val

im = ax.imshow(X, extent=(0, 315, 0, 315), origin='lower', zorder=1, cmap = 'seismic', interpolation = 'nearest', vmin = vmin, vmax = vmax)

ax.set_title('An Image', size=20)

plugins.connect(fig, MousePositionCustomPlugin(shape_0,shape_1,X,fontsize=14))


mpld3.show()
