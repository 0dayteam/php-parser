package ast

type AttributeKey int

type Attribute struct {
	Key  AttributeKey
	Val  string
	Next uintptr
}

type AttributeBuffer struct {
	off int
	buf [][]Attribute
}

func NewAttributeBuffer() *AttributeBuffer {
	return &AttributeBuffer{
		off: 0,
		buf: make([][]Attribute, 0),
	}
}

func (b *AttributeBuffer) Reset() {
	b.off = 0
}

func (b *AttributeBuffer) New() *Attribute {
	if b.off%1024 == 0 && b.off/1024 == len(b.buf) {
		b.buf = append(b.buf, make([]Attribute, 1024))
	}

	a := Attribute{}
	b.buf[len(b.buf)-1][b.off%1024] = a
	b.off++

	return &a
}
