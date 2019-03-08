package ast

type tree struct {
	AttributeBuffer    AttributeBuffer
	FreeFloatingBuffer FreeFloatingBuffer
	PositionBuffer     PositionBuffer
	NodeCollection     NodeBuffer

	Root *Node
}
