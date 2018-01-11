package expr

import (
	"github.com/z7zmey/php-parser/node"
)

// ShortArray node
type ShortArray struct {
	Items []node.Node
}

// NewShortArray node constuctor
func NewShortArray(Items []node.Node) *ShortArray {
	return &ShortArray{
		Items,
	}
}

// Attributes returns node attributes as map
func (n *ShortArray) Attributes() map[string]interface{} {
	return nil
}

// Walk traverses nodes
// Walk is invoked recursively until v.EnterNode returns true
func (n *ShortArray) Walk(v node.Visitor) {
	if v.EnterNode(n) == false {
		return
	}

	if n.Items != nil {
		vv := v.GetChildrenVisitor("Items")
		for _, nn := range n.Items {
			if nn != nil {
				nn.Walk(vv)
			}
		}
	}

	v.LeaveNode(n)
}
