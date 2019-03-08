package ast

import (
	"unsafe"
)

// NodeType specifies the type of the node
type NodeType int8

//go:generate stringer -type=NodeType -trimprefix=Type -output ./node_type_string.go
const (
	TypeStmtFunc NodeType = iota + 1
	TypeStmtExpr
	TypeName
)

// NodeKey specifies relationship with a parent node
type NodeKey int8

//go:generate stringer -type=NodeKey -trimprefix=Key -output ./node_key_string.go
const (
	KeyStmts NodeKey = iota + 1
	KeyName
)

type Node struct {
	Type NodeType
	Key  NodeKey

	position     uintptr
	attribute    uintptr
	freefloating uintptr

	parent uintptr
	child  uintptr
	next   uintptr
}

func (n *Node) SetPosition(p *Position) {
	n.position = uintptr(unsafe.Pointer(p))
}

func (n *Node) GetPosition() *Position {
	return (*Position)(unsafe.Pointer(n.position))
}

func (n *Node) SetAttribute(a *Attribute) {
	n.attribute = uintptr(unsafe.Pointer(a))
}

func (n *Node) GetAttribute() *Attribute {
	return (*Attribute)(unsafe.Pointer(n.attribute))
}

func (n *Node) SetFreeFloating(f *FreeFloating) {
	n.freefloating = uintptr(unsafe.Pointer(f))
}

func (n *Node) GetFreeFloating() *FreeFloating {
	return (*FreeFloating)(unsafe.Pointer(n.freefloating))
}

func (n *Node) SetParent(c *Node) {
	n.parent = uintptr(unsafe.Pointer(c))
}

func (n *Node) GetParent() *Node {
	return (*Node)(unsafe.Pointer(n.parent))
}

func (n *Node) SetChild(c *Node) {
	n.child = uintptr(unsafe.Pointer(c))
}

func (n *Node) GetChild() *Node {
	return (*Node)(unsafe.Pointer(n.child))
}

func (n *Node) SetNext(c *Node) {
	n.next = uintptr(unsafe.Pointer(c))
}

func (n *Node) GetNext() *Node {
	return (*Node)(unsafe.Pointer(n.next))
}

type NodeBuffer struct {
	off int
	buf [][]Node
}

func NewNodeBuffer() *NodeBuffer {
	return &NodeBuffer{
		off: 0,
		buf: make([][]Node, 0),
	}
}

func (b *NodeBuffer) Reset() {
	b.off = 0
}

// New creates new Node with unique ID
func (b *NodeBuffer) New() *Node {
	if b.off%1024 == 0 && b.off/1024 == len(b.buf) {
		b.buf = append(b.buf, make([]Node, 1024))
	}

	n := Node{}
	b.buf[len(b.buf)-1][b.off%1024] = n
	b.off++

	return &n
}
