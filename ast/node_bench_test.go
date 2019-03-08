package ast

import (
	"runtime"
	"testing"
)

const k = 30000
const g = false

func Benchmark_SliceNodes(b *testing.B) {
	for i := 0; i < b.N; i++ {
		buf := []Node{}
		for i := 0; i < k; i++ {
			buf = append(buf, Node{})
		}

		if g {
			runtime.GC()
		}
		runtime.KeepAlive(buf)
	}
}

func Benchmark_SliceNodes_reuse(b *testing.B) {
	buf := []Node{}
	for i := 0; i < b.N; i++ {
		buf = buf[:0]
		for i := 0; i < k; i++ {
			buf = append(buf, Node{})
		}

		if g {
			runtime.GC()
		}
		runtime.KeepAlive(buf)
	}
}

func Benchmark_SliceRefNodes(b *testing.B) {
	for i := 0; i < b.N; i++ {
		buf := []*Node{}
		for i := 0; i < k; i++ {
			buf = append(buf, &Node{})
		}

		if g {
			runtime.GC()
		}
		runtime.KeepAlive(buf)
	}
}

func Benchmark_SliceRefNodes_reuse(b *testing.B) {
	buf := []*Node{}
	for i := 0; i < b.N; i++ {
		buf = buf[:0]
		for i := 0; i < k; i++ {
			buf = append(buf, &Node{})
		}

		if g {
			runtime.GC()
		}
		runtime.KeepAlive(buf)
	}
}

func Benchmark_BufNodes(b *testing.B) {
	for i := 0; i < b.N; i++ {
		buf := NewNodeBuffer()
		for i := 0; i < k; i++ {
			_ = buf.New()
		}

		if g {
			runtime.GC()
		}
		runtime.KeepAlive(buf)
	}
}

func Benchmark_BufNodes_reuse(b *testing.B) {
	buf := NewNodeBuffer()
	for i := 0; i < b.N; i++ {
		buf.Reset()

		for i := 0; i < k; i++ {
			_ = buf.New()
		}

		if g {
			runtime.GC()
		}
		runtime.KeepAlive(buf)
	}
}
