package main

import (
	"fmt"
	"strconv"
	"strings"
)

//go:generate ragel -Z -G2 -o lex.go lex.rl

type yySymType struct {
	data []byte
	line int
}

func main() {
	lexer := newLexer([]byte(`
		html1
		<?
		exit
		b"$3"
	`))

	for {
		out := yySymType{}
		token := lexer.Lex(&out)

		fmt.Printf(
			"%s%s%q\n",
			column(strconv.Itoa(out.line)+":", 5, " "),
			column(token.String(), 26, " => "),
			string(out.data),
		)

		if token == 0 {
			break
		}
	}
}

func column(s string, l int, d string) string {
	return s + strings.Repeat(" ", l-len(s)) + d
}
