package stmt

import (
	"github.com/z7zmey/php-parser/node"
)

// Unset node
type Unset struct {
	Vars []node.Node
}

// NewUnset node constuctor
func NewUnset(Vars []node.Node) *Unset {
	return &Unset{
		Vars,
	}
}

// Attributes returns node attributes as map
func (n *Unset) Attributes() map[string]interface{} {
	return nil
}

// Walk traverses nodes
// Walk is invoked recursively until v.EnterNode returns true
func (n *Unset) Walk(v node.Visitor) {
	if v.EnterNode(n) == false {
		return
	}

	if n.Vars != nil {
		vv := v.GetChildrenVisitor("Vars")
		for _, nn := range n.Vars {
			if nn != nil {
				nn.Walk(vv)
			}
		}
	}

	v.LeaveNode(n)
}
