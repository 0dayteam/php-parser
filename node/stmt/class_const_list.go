package stmt

import (
	"github.com/z7zmey/php-parser/node"
)

type ClassConstList struct {
	Modifiers []node.Node
	Consts    []node.Node
}

func NewClassConstList(Modifiers []node.Node, Consts []node.Node) *ClassConstList {
	return &ClassConstList{
		Modifiers,
		Consts,
	}
}

func (n *ClassConstList) Attributes() map[string]interface{} {
	return nil
}

func (n *ClassConstList) Walk(v node.Visitor) {
	if v.EnterNode(n) == false {
		return
	}

	if n.Modifiers != nil {
		vv := v.GetChildrenVisitor("Modifiers")
		for _, nn := range n.Modifiers {
			if nn != nil {
				nn.Walk(vv)
			}
		}
	}

	if n.Consts != nil {
		vv := v.GetChildrenVisitor("Consts")
		for _, nn := range n.Consts {
			if nn != nil {
				nn.Walk(vv)
			}
		}
	}

	v.LeaveNode(n)
}
