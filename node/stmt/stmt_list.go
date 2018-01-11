package stmt

import (
	"github.com/z7zmey/php-parser/node"
)

// StmtList node
type StmtList struct {
	Stmts []node.Node
}

// NewStmtList node constuctor
func NewStmtList(Stmts []node.Node) *StmtList {
	return &StmtList{
		Stmts,
	}
}

// Attributes returns node attributes as map
func (n *StmtList) Attributes() map[string]interface{} {
	return nil
}

// Walk traverses nodes
// Walk is invoked recursively until v.EnterNode returns true
func (n *StmtList) Walk(v node.Visitor) {
	if v.EnterNode(n) == false {
		return
	}

	if n.Stmts != nil {
		vv := v.GetChildrenVisitor("Stmts")
		for _, nn := range n.Stmts {
			if nn != nil {
				nn.Walk(vv)
			}
		}
	}

	v.LeaveNode(n)
}
