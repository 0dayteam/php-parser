package stmt

import (
	"github.com/z7zmey/php-parser/node"
)

// StaticVar node
type StaticVar struct {
	Variable node.Node
	Expr     node.Node
}

// NewStaticVar node constuctor
func NewStaticVar(Variable node.Node, Expr node.Node) *StaticVar {
	return &StaticVar{
		Variable,
		Expr,
	}
}

// Attributes returns node attributes as map
func (n *StaticVar) Attributes() map[string]interface{} {
	return nil
}

// Walk traverses nodes
// Walk is invoked recursively until v.EnterNode returns true
func (n *StaticVar) Walk(v node.Visitor) {
	if v.EnterNode(n) == false {
		return
	}

	if n.Variable != nil {
		vv := v.GetChildrenVisitor("Variable")
		n.Variable.Walk(vv)
	}

	if n.Expr != nil {
		vv := v.GetChildrenVisitor("Expr")
		n.Expr.Walk(vv)
	}

	v.LeaveNode(n)
}
