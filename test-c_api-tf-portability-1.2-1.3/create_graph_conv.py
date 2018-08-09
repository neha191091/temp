import tensorflow as tf
import numpy as np
from tensorflow.python.tools import freeze_graph
from scipy import misc


def save_checkpoint(sess, checkpoint=0, var_list=None):
    '''
    Saves checkpoint in the chkpt folder
    :param sess: tf.session to be saved
    :param timestamp: timestamp associated with the session
    :param checkpoint: checkpoint number for the session
    :param var_list: variables to be saved in the checkpoint
    :return: N/A
    '''
    fname = 'conv_models/' + 'checkpoint%d.ckpt' % checkpoint
    saver = tf.train.Saver(var_list)
    save_path = saver.save(sess, fname)
    print("Model saved in %s" % save_path)


def freeze_pred(input_graph_path, output_graph_path, checkpoint):
    '''
    Freeze the network with weights
    :param input_graph_path: path to the input graph
    :param output_graph_path: path to store the frozen output graph
    :param checkpoint: path to checkpoint file with the needed weights
    :return:
    '''

    # Freeze the graph
    checkpoint_state_name = "checkpoint"
    input_saver_def_path = ""
    input_binary = False
    output_node_names = "out"
    restore_op_name = "save/restore_all"
    filename_tensor_name = "save/Const:0"
    clear_devices = False
    freeze_graph.freeze_graph(input_graph_path, input_saver_def_path,
                              input_binary, checkpoint,
                              output_node_names, restore_op_name,
                              filename_tensor_name, output_graph_path,
                              clear_devices, "")


def load_graph(frozen_graph_filename):
    '''
    Load the frozen graph into a tensorflow graph def variable
    :param frozen_graph_filename:
    :return:
    '''
    # We load the protobuf file from the disk and parse it to retrieve the
    # unserialized graph_def
    with tf.gfile.GFile(frozen_graph_filename, "rb") as f:
        graph_def = tf.GraphDef()
        graph_def.ParseFromString(f.read())

    # Then, we import the graph_def into a new Graph and returns it
    with tf.Graph().as_default() as graph:
        # The name var will prefix every op/nodes in your graph
        # Since we load everything in a new graph, this is not needed
        tf.import_graph_def(graph_def, name="prefix")
    return graph


def define_and_freeze_graph():
    i = tf.placeholder(tf.float32, shape=[1, 480, 640, 3], name='in') # input
    filter = tf.Variable(tf.truncated_normal([5, 5, 3, 1], stddev=0.05))
    conv = tf.nn.conv2d(i, filter=filter, strides=[1, 1, 1, 1], padding="SAME")
    relu = tf.nn.relu(conv)
    maxpool = tf.nn.max_pool(relu, ksize=[1, 3, 3, 1], strides=[1, 2, 2, 1], padding="SAME")
    shape_maxpool_1 = int(maxpool.shape[1])
    shape_maxpool_2 = int(maxpool.shape[2])
    print("MAXPOOL SHAPE: (", shape_maxpool_1, ", ", shape_maxpool_2, ")")
    filter2 = tf.Variable(tf.truncated_normal([shape_maxpool_1, shape_maxpool_2, 1, 20], stddev=0.05))
    fc = tf.nn.conv2d(maxpool,filter=filter2, strides=[1, 1, 1, 1], padding="VALID", name="out")

    init_op = tf.group(tf.global_variables_initializer(), tf.local_variables_initializer())

    rgb_label = misc.imread('example.png', mode='RGB')
    rgb_label = np.array([rgb_label])

    with tf.Session() as sess:

        sess.run(init_op)

        output = sess.run(fc, feed_dict={i: rgb_label})  # 30.0
        print("Output shape: ", output.shape)

        tf.train.write_graph(sess.graph_def, 'conv_models/', 'input_graph.pbtxt', as_text=True)

        save_checkpoint(sess)

    freeze_pred('conv_models/input_graph.pbtxt', 'conv_models/output_graph.pbtxt', 'conv_models/checkpoint0.ckpt')


def run_frozen_graph():
    op_graph = load_graph('conv_models/output_graph.pbtxt')

    # We can verify that we can access the list of operations in the graph
    for op in op_graph.get_operations():
        print(op.name)
        # prefix/Placeholder/inputs_placeholder
        # ...
        # prefix/Accuracy/predictions

    # We access the input and output nodes
    inp = op_graph.get_tensor_by_name('prefix/in:0')
    outp = op_graph.get_tensor_by_name('prefix/out:0')

    rgb_label = misc.imread('example.png', mode='RGB')
    rgb_label = np.array([rgb_label])

    with tf.Session(graph=op_graph) as sess:
        output = sess.run(outp, feed_dict={inp: rgb_label})
        print(output)
        print("Output shape: ", output.shape)


if __name__ == '__main__':
    print("tf version: ", tf.__version__)
    print("tf graph def version", tf.GRAPH_DEF_VERSION)

    rgb_label = misc.imread('example.png', mode='RGB')
    print("RGB SHAPE : ", rgb_label.shape)
    rgb_label = np.array([rgb_label])
    print("RGB SHAPE after reshaping: ", rgb_label.shape)


    define_and_freeze_graph()
    #run_frozen_graph()