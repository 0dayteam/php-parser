package stmt

import (
	"github.com/z7zmey/php-parser/node"
)

type If struct {
	Cond   node.Node
	Stmt   node.Node
	ElseIf []node.Node
	_else  node.Node
}

func NewIf(Cond node.Node, Stmt node.Node) *If {
	return &If{
		Cond,
		Stmt,
		nil,
		nil,
	}
}

func (n *If) Attributes() map[string]interface{} {
	return nil
}

func (n *If) AddElseIf(ElseIf node.Node) node.Node {
	if n.ElseIf == nil {
		n.ElseIf = make([]node.Node, 0)
	}

	n.ElseIf = append(n.ElseIf, ElseIf)

	return n
}

func (n *If) SetElse(_else node.Node) node.Node {
	n._else = _else

	return n
}

func (n *If) Walk(v node.Visitor) {
	if v.EnterNode(n) == false {
		return
	}

	if n.Cond != nil {
		vv := v.GetChildrenVisitor("Cond")
		n.Cond.Walk(vv)
	}

	if n.Stmt != nil {
		vv := v.GetChildrenVisitor("Stmt")
		n.Stmt.Walk(vv)
	}

	if n.ElseIf != nil {
		vv := v.GetChildrenVisitor("ElseIf")
		for _, nn := range n.ElseIf {
			if nn != nil {
				nn.Walk(vv)
			}
		}
	}

	if n._else != nil {
		vv := v.GetChildrenVisitor("else")
		n._else.Walk(vv)
	}

	v.LeaveNode(n)
}
