class BinaryNode (object):
    """
    @brief One of the nodes in the binary tree for the rsLQR solver
    """
    #How do we initialize binaryNode? - Yana
    def _init_(self):
        self.idx # < knot point index
        self.level # < level in the tree
        self.levelidx # < leaf index at the current level
        self.left_inds # < range of knot point indices of all left children #do we need them? (Srishti - "idk")
        self.right_inds # < range of knot point indices of all right children
        self.parent # < parent node
        self.left_child # < left child
        self.right_child # < right child

def BuildSubTree(start,len): #because it is static needs to be in node class or tree class? -Yana
        """
        actualy builds the tree,need to implement the function (Srishti - "implemented this now, but not sure if it's the correct translation from C")
        """
        mid = (len + 1) // 2
        new_len = mid - 1
        if len > 1:
            root = start + new_len #binaryNode
            left_root = BuildSubTree(start, new_len)
            right_root = BuildSubTree(start + mid, new_len)
            root.left_child = left_root
            root.right_child = right_root
            left_root.parent = root
            right_root.parent = root
            root.left_inds.start = left_root.left_inds.start
            root.left_inds.stop = left_root.right_inds.stop
            root.right_inds.start = right_root.left_inds.start
            root.right_inds.stop = right_root.right_inds.stop
            root.level = left_root.level + 1
            return root
        else:
            k = start.idx
            start.left_inds.start = k
            start.left_inds.stop = k
            start.right_inds.start = k + 1
            start.right_inds.stop = k + 1
            start.level = 0
            start.left_child = None
            start.right_child = None
            return start

class OrderedBinarytree(object):
    """
    @brief The binary tree for the rsLQR solver
    
    Caches useful information to speed up some of the computations during the
    rsLQR solver, mostly around converting form linear knot point indices to
    the hierarchical indexing of the algorithm.
    
    ## Construction and destruction
    A new tree can be constructed solely given the length of the time horizon, which must
    be a power of two. Use ndlqr_BuildTree(N) to build a new tree, 
    """
    def _init_(self,nhorizon): # (Srishti - "why does it have nhorizon as input"; 
    #Yana - "Because we need the length of the length of the time horizon to buils the tree")
        self.root # (C type: BinaryNode*) < root of the tree. Corresponds to the "middle" knot point.
        self.node_list = [] # (C type: BinaryNode*) < a list of all the nodes, ordered by their knot point index
        self.num_elements # (C type: int) < length of the OrderedBinaryTree::node_list
        self.depth # (C type: int) < total depth of the tree

    #Can we call it _init_ instead? - Yana
    def ndlqr_BuildTree(self, nhorizon): # (Srishti - "Is N (of C code) = nhorizon (of Python code)? - I think yes, look at .c file")
        """
        @brief Construct a new binary tree for a horizon of length @p N
        
        
        @param  N horizon length. Must be a power of 2.
        @return A new binary tree
        """
        assert(isPowerOfTwo(nhorizon))

        for i in range (nhorizon):
            self.node_list[i].idx = i # (Srishti - "don't we have to make node_list of length `nhorizon` first?")
                                    # (Yana - "In python we don't have to specify the length of the list")
        self.num_elements = nhorizon
        self.depth = math.log2(nhorizon)
        
        # Build the tree
        self.root = BuildSubTree(node_list, nhorizon - 1)

    #don't need ndlqr_FreeeTree (Srishti - "why not?", Yana - "Because we dont need to free malloc?")
      
    def ndlqr_GetIndexFromLeaf(self, leaf, level):
        """
        @brief Get the knot point index given the leaf index at a given level

        @param tree  An initialized binary tree for the problem horizon
        @param leaf  Leaf index
        @param level Level of tree from which to get the index
        @return
        """
        linear_index = math.pow(2, level) * (2 * leaf + 1) - 1
        return linear_index
    
    def ndlqr_GetIndexLevel(self, index):
        """
        @brief Get the level for a given knot point index

        @param tree  An initialized binary tree for the problem horizon
        @param index Knot point index
        @return      The level for the given index
        """
        return self.node_list[index].level   

    #"Is there const functions in python?"
    def ndlqr_GetNodeAtLevel (node,index,level):
        if(node.level == level):
            return node
        elif(node,level>level):
            if(index <= node.idx):
                return GetNodeAtLevel (node.left_child, index, level)
            else:
                    return GetNodeAtLevel(node.right_child, index, level)
        else:
            return GetNodeAtLevel(node.parent, index, level)

    def ndlqr_GetIndexAtLevel(tree, leaf, level):
        """
        @brief Get the index in 'level' that corresponds to `index`.

        If the level is higher than the level of the given index, it's simply the parent
        at that level. If it's lower, then it's the index that's closest to the given one, with
        ties broken by choosing the left (or smaller) of the two.

        @param tree  Precomputed binary tree
        @param index Start index of the search. The result will be the index closest to this
        index.
        @param level The level in which the returned index should belong to.
        @return int  The index closest to the provided one, in the given level. -1 if
        unsucessful.
        """
        if tree = None: # (Srishti - "is this syntax correct for Python" Yana -"Yep!")
            return -1
        if index < 0 or index >= tree.num_elements:
            print(f"ERROR: Invalid index ({index}). Should be between 0 and {tree.num_elements - 1}.")
        
        if level < 0 or level >= tree.depth:
            print(f"ERROR: Invalid level ({level}). Should be between 0 and {tree.depth - 1}.")

        node = tree.node_list + index
        if index == tree.num_elements - 1:
            node = tree.node_list + index - 1

        base_node = GetNodeAtLevel(node, index, level) # (Srishti - "check how to define const variable here (syntax)")
        return base_node.idx