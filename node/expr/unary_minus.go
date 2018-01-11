package expr

import (
	"github.com/z7zmey/php-parser/node"
)

// UnaryMinus node
type UnaryMinus struct {
	Expr node.Node
}

// NewUnaryMinus node constuctor
func NewUnaryMinus(Expression node.Node) *UnaryMinus {
	return &UnaryMinus{
		Expression,
	}
}

// Attributes returns node attributes as map
func (n *UnaryMinus) Attributes() map[string]interface{} {
	return nil
}

// Walk traverses nodes
// Walk is invoked recursively until v.EnterNode returns true
func (n *UnaryMinus) Walk(v node.Visitor) {
	if v.EnterNode(n) == false {
		return
	}

	if n.Expr != nil {
		vv := v.GetChildrenVisitor("Expr")
		n.Expr.Walk(vv)
	}

	v.LeaveNode(n)
}
