package expr

import (
	"github.com/z7zmey/php-parser/node"
)

// BooleanNot node
type BooleanNot struct {
	Expr node.Node
}

// NewBooleanNot node constuctor
func NewBooleanNot(Expression node.Node) *BooleanNot {
	return &BooleanNot{
		Expression,
	}
}

// Attributes returns node attributes as map
func (n *BooleanNot) Attributes() map[string]interface{} {
	return nil
}

// Walk traverses nodes
// Walk is invoked recursively until v.EnterNode returns true
func (n *BooleanNot) Walk(v node.Visitor) {
	if v.EnterNode(n) == false {
		return
	}

	if n.Expr != nil {
		vv := v.GetChildrenVisitor("Expr")
		n.Expr.Walk(vv)
	}

	v.LeaveNode(n)
}
