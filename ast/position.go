package ast

import (
	"github.com/z7zmey/php-parser/scanner"
)

type Position struct {
	Start     int
	End       int
	StartLine int
	EndLine   int
}

type PositionBuffer struct {
	off int
	buf [][]Position
}

func NewPositionBuffer() *PositionBuffer {
	return &PositionBuffer{
		off: 0,
		buf: make([][]Position, 0),
	}
}

func (b *PositionBuffer) Reset() {
	b.off = 0
}

func (b *PositionBuffer) New() *Position {
	if b.off%1024 == 0 && b.off/1024 == len(b.buf) {
		b.buf = append(b.buf, make([]Position, 1024))
	}

	n := Position{}
	b.buf[len(b.buf)-1][b.off%1024] = n
	b.off++

	return &n
}

func (c *PositionBuffer) NewNodePosition(n *Node) *Position {
	return n.GetPosition()
}

func (c *PositionBuffer) NewTokenPosition(t *scanner.Token) *Position {
	p := c.New()

	p.Start = t.StartPos
	p.End = t.EndPos
	p.StartLine = t.StartLine
	p.EndLine = t.EndLine

	return p
}

func (c *PositionBuffer) NewTokensPosition(t1, t2 *scanner.Token) *Position {
	p := c.New()

	p.Start = t1.StartPos
	p.End = t2.EndPos
	p.StartLine = t1.StartLine
	p.EndLine = t2.EndLine

	return p
}

func (c *PositionBuffer) NewTokenNodePosition(t *scanner.Token, n Node) *Position {
	nodePos := n.GetPosition()
	p := c.New()

	p.Start = t.StartPos
	p.End = nodePos.End
	p.StartLine = t.StartLine
	p.EndLine = nodePos.EndLine

	return p
}

func (c *PositionBuffer) NewNodeTokenPosition(n Node, t *scanner.Token) *Position {
	nodePos := n.GetPosition()
	p := c.New()

	p.Start = nodePos.Start
	p.End = t.EndPos
	p.StartLine = nodePos.StartLine
	p.EndLine = t.EndLine

	return p
}

func (c *PositionBuffer) NewNodesPosition(firstNode, lastNode Node) *Position {
	startPos := firstNode.GetPosition()
	endPos := lastNode.GetPosition()
	p := c.New()

	p.Start = startPos.Start
	p.End = endPos.End
	p.StartLine = startPos.StartLine
	p.EndLine = endPos.EndLine

	return p
}
