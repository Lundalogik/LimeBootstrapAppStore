var tree = (function () {
    var collapse = function (d) {
        if (d.children) {
            d._children = d.children;
            d._children.forEach(collapse);
            d.children = null;
        }
    };

    var expand = function (d, i, depth) {
        if (i < depth) {
            if (d._children) {
                d.children = d._children;
                d._children = null;
            }
            if (d.children) {
                for (var k = 0, len = d.children.length; k < len; k++) {
                    expand(d.children[k], i + 1, depth);
                }
            }
        } else { collapse(d); }
    };

    // Find node by RecordId, and update tre with selected node as root.
    var selectNodeById = function (treeNode, recordId, viewModel) {

        return traverseChildren(findTopNode(treeNode), recordId);

        function findTopNode(d) {
            if (d.parent) {
                return findTopNode(d.parent);
            } else {
                return d;
            }
        }

        function traverseChildren(d, recordId) {
            if (d.recordId === recordId) {
                //viewModel.selectNode(d);
                return d;
            } else {
                if (d.children) {
                    for (var k = 0, len = d.children.length; k < len; k++) {
                        var soughtNode = traverseChildren(d.children[k], recordId)
                        if (soughtNode) { return soughtNode; }
                    }
                }
                if (d._children) {
                    for (var k = 0, len = d._children.length; k < len; k++) {
                        var soughtNode = traverseChildren(d._children[k], recordId)
                        if (soughtNode) { return soughtNode; }
                    }
                }
            }
        }
    };

    return {
        expand: expand,
        selectNodeById: selectNodeById
    };
}());