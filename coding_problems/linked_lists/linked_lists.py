
class Node:
    def __init__(self, value):
        self.value = value
        self.next = None


class LinkedList:
    def __init__(self, head=None):
        self.head = head


def returnk(linked_list, k):
    node_1= linked_list.head
    node_2 = node_1
    for _ in range(k):
        node_2 = node_2.next
    print(node_2.value)
    while node_2:
        node_1 = node_1.next
        node_2 = node_2.next
        #print(node_2.value)
    return node_1.value


if __name__ == '__main__':
    node = Node(1)
    lst = LinkedList(node)
    node.next = Node(2)
    node.next.next = Node(3)
    node.next.next.next = Node(4)
    print(returnk(lst, 3))
