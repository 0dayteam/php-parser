package scalar

import (
	"github.com/z7zmey/php-parser/node"
)

// String node
type String struct {
	Value string
}

// NewString node constuctor
func NewString(Value string) *String {
	return &String{
		Value,
	}
}

// Attributes returns node attributes as map
func (n *String) Attributes() map[string]interface{} {
	return map[string]interface{}{
		"Value": n.Value,
	}
}

// Walk traverses nodes
// Walk is invoked recursively until v.EnterNode returns true
func (n *String) Walk(v node.Visitor) {
	if v.EnterNode(n) == false {
		return
	}

	v.LeaveNode(n)
}
