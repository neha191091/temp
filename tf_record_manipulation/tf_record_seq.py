import tensorflow as tf
import os
import pickle
import numpy as np

# train_dir = os.path.join(os.path.curdir, 'yelp')
# data_dir = os.path.join(train_dir, 'data')
#
# for dir in [train_dir, data_dir]:
#     if not os.path.exists(dir):
#         os.makedirs(dir)
#
# trainset_fn = os.path.join(data_dir, 'train.dataset')
#
# with open(trainset_fn, 'rb') as f:
#     x, y = pickle.load(f)
#     x = np.asarray(x)
#     y = np.asarray(y)
#     print(x.shape)
#     print(y.shape)
#     print(x)
#     print(y)
#     print('---------------------------')
#     x, y = pickle.load(f)
#     print(type(x))
#     print(type(y))
#     # x = np.asarray(x)
#     # y = np.asarray(y)
#     # print(x.shape)
#     # print(y.shape)
#     # print(x)
#     # print(y)
#     print('---------------------------')
#
#
# def _read_fn(filename):
#     with open(filename, 'rb') as f:
#         x, y = pickle.load(f)
#         y = np.asarray(y, dtype = np.uint16)
#
#         return x, y
#
#
# dataset = tf.data.Dataset.from_tensors(trainset_fn)
# map_fn = lambda filename: tf.py_func(_read_fn, [filename], [int, int])
# dataset = dataset.map(map_fn, num_parallel_calls = 3)

data = []
doc1 = [[1, 2, 3, 4], [4, 5, 6, 8, 3, 5, 5, 1, 1, ], [3, 4, 4]]
doc2 = [[1, 2, 3], [2, 1, 132]]
data.append(doc1)
data.append(doc2)


def sequence_to_tf_example(review_doc, rating):
    ex = tf.train.SequenceExample()
    ex.context.feature['rating'].int64_list.value.append(rating)
    ex.context.feature['num_sent'].int64_list.value.append(len(review_doc))
    sentences = ex.feature_lists.feature_list['sentences']
    sent_length = ex.feature_lists.feature_list["sent_lengths"]

    for sentence in review_doc:
        words = sentences.feature.add().int64_list
        for word in sentence:
            words.value.append(word)
        sent_length.feature.add().int64_list.value.append(len(sentence))

    return ex


def write_tfrecord():
    with open('test.tfrecord', 'w') as f:
        writer = tf.python_io.TFRecordWriter(f.name)
        for review in data:
            record = sequence_to_tf_example(review, 0)
            print('Record', record)
            writer.write(record.SerializeToString())
        writer.close()


def parse(ex):
    context_features = {
        "rating": tf.FixedLenFeature([], dtype=tf.int64),
        "num_sent": tf.FixedLenFeature([], dtype=tf.int64)
    }

    sequence_features = {
        "text": tf.FixedLenSequenceFeature([], dtype=tf.int64),
        "sent_length": tf.FixedLenSequenceFeature([], dtype=tf.int64)
    }

    context_parsed, sequence_parsed = tf.parse_single_sequence_example(
        serialized=ex,
        context_features=context_features,
        sequence_features=sequence_features
    )

    rating = context_parsed["rating"]
    num_sent = context_parsed["num_sent"]
    text = sequence_parsed["text"]
    sent_length = sequence_parsed["sent_length"]
    return rating

write_tfrecord()

filename_queue = tf.train.string_input_producer(["test.tfrecord"])
reader = tf.TFRecordReader()
key, serialized_example = reader.read(filename_queue)
# print(key)
rating = parse(serialized_example)
print(rating)


# print(dataset.output_types)
# print(dataset.output_shapes)
#
# iterator = dataset.make_one_shot_iterator()
# next_element = iterator.get_next()
#
#with tf.Session() as sess:
#    # print(sess.run(rating))
#    rating.eval()