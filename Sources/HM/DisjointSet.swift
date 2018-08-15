/**
    A mechanism for tracking equivalence classes of values.
    A set starts off each element in an equivalence class of
    its own.
*/
class DisjointSet<T: Hashable> {

    private var nodes: [T: Node] = [:]

    init(with elements: [T]) {
        for element in elements {
            nodes[element] = Node(element)
        }
    }

    init(_ elements: T...) {
        for element in elements {
            nodes[element] = Node(element)
        }
    }

    /**
        Return the representative of an element's equivalence class.
    */
    func representative(_ element: T) -> T {
        return findRoot(element).value
    }

    /**
        Make the two elements belong to the same equivalence class.
    */
    func unify(_ a: T, _ b: T) {
        let aRoot = findRoot(a)
        let bRoot = findRoot(b)
        if (aRoot !== bRoot) {
            if (aRoot.size < bRoot.size) {
                aRoot.parent = bRoot
                bRoot.size += aRoot.size
            } else {
                bRoot.parent = aRoot
                aRoot.size += bRoot.size
            }
        }
    }

    private func findRoot(_ element: T) -> Node {
        func topmost(_ node: Node) -> Node {
            return node.parent.map(topmost) ?? node
        }
        return topmost(nodes[element]!)
    }

    private class Node {
        let value: T
        var parent: Node? = nil
        var size: Int = 0
    
        init(_ value: T) {
            self.value = value
        }
    }
}

