package ast

type FreeFloatingKey int

type FreeFloating struct {
	Key  FreeFloatingKey
	Val  string
	Next uintptr
}

type FreeFloatingBuffer struct {
	off int
	buf [][]FreeFloating
}

func NewFreeFloatingBuffer() *FreeFloatingBuffer {
	return &FreeFloatingBuffer{
		off: 0,
		buf: make([][]FreeFloating, 0),
	}
}

func (b *FreeFloatingBuffer) Reset() {
	b.off = 0
}

func (b *FreeFloatingBuffer) New() *FreeFloating {
	if b.off%1024 == 0 && b.off/1024 == len(b.buf) {
		b.buf = append(b.buf, make([]FreeFloating, 1024))
	}

	a := FreeFloating{}
	b.buf[len(b.buf)-1][b.off%1024] = a
	b.off++

	return &a
}
