package main

import (
    "fmt"
    "strings"
    "unicode"
    // "unicode/utf8"
)

%%{ 
    machine thermostat;
    write data;
    access lex.;
    variable p lex.p;
    variable pe lex.pe;
}%%

// Allocate Character classes anywhere in [0x80, 0xFF].
const (
	classUnicodeLeter = iota + 0x80
	classUnicodeDigit
	classUnicodeGraphic
	classOther
)

const RuneEOF  = -1

// Rune2Class returns the rune integer id
func Rune2Class(r rune) int {
	if r >= 0 && r < 0x80 { // Keep ASCII as it is.
		return int(r)
	}
	if unicode.IsLetter(r) {
		return classUnicodeLeter
	}
	if unicode.IsDigit(r) {
		return classUnicodeDigit
	}
	if unicode.IsGraphic(r) {
		return classUnicodeGraphic
	}
	if r == RuneEOF {
		return int(r)
	}
	return classOther
}

type lexer struct {
    data []byte
    p, pe, cs int
    ts, te, act int
    curline int
    stack []int
    top int
}

func newLexer(data []byte) *lexer {
    lex := &lexer{ 
        data: data,
        pe: len(data),
        curline: 1,
        stack: make([]int, 0),
    }
    %% write init;
    return lex
}

var curline = 1

func (lex *lexer) Lex(out *yySymType) TokenID {
    eof := lex.pe
    var tok TokenID

    %%{ 
        newline = ('\r' | '\n' | '\r\n') @{lex.curline += 1;};
        any_line = any | newline;
        whitespace = [\t\v\f ];
        whitespace_line = [\t\v\f ] | newline;

        lnum = [0-9]+;
        dnum = ( [0-9]* "." [0-9]+ ) | ( [0-9]+ "." [0-9]* );
        hnum = '0x' [0-9a-fA-F]+;
        bnum = '0b' [01]+;

        exponent_dnum = (lnum | dnum) ('e'|'E') ('+'|'-')? lnum;
        varname       = /[a-zA-Z_\x7f-\xff][a-zA-Z0-9_\x7f-\xff]*/;
        operators     = ';'|':'|','|'.'|'['|']'|'('|')'|'|'|'/'|'^'|'&'|'+'|'-'|'*'|'='|'%'|'!'|'~'|'$'|'<'|'>'|'?'|'@';
        
        prepush { lex.growStack() }


        constant_string =
            start: (
                "'" -> qoute |
                "b"? '"' -> double_qoute
            ),
            qoute: (
                (any_line - [\\']) -> qoute   |
                "\\"               -> qoute_any   |
                "'"                -> final
            ),
            qoute_any: (
                any_line -> qoute
            ),
            double_qoute: (
                (any_line - [\\"${]) -> double_qoute   |
                "\\"                 -> double_qoute_any   |
                '"'                  -> final |
                '$'                  -> double_qoute_nonvarname |
                '{'                  -> double_qoute_nondollar
            ),
            double_qoute_any: (
                any_line -> double_qoute
            ),
            double_qoute_nondollar: (
                '"'  -> final |
                !"$" -> double_qoute
            ),
            double_qoute_nonvarname: (
                '"'                    -> final |
                /[^{a-zA-Z_\x7f-\xff]/ -> double_qoute
            );

        main := |*
            any_line+ -- '<?' => {
                lex.ungetStr("<")
                lex.out(out)
                tok = T_INLINE_HTML;
                fbreak;
            };
            '<?' => {
                fnext php;
            };
            '<?php' ( [ \t] | newline ) => {
                fnext php;
            };
            '<?=' => { lex.out(out); tok = T_ECHO; fnext php; fbreak; };
        *|;

        php := |*
            whitespace_line*;
            '?>' newline?                      => {lex.out(out); tok = TokenID(int(';')); fnext main; fbreak;};
            ';' whitespace_line* '?>' newline? => {lex.out(out); tok = TokenID(int(';')); fnext main; fbreak;};

            (dnum | exponent_dnum)          => {lex.out(out); tok = T_DNUMBER; fbreak;};
            bnum => {
                firstNum := 2
                for i := lex.ts + 2; i < lex.te; i++ {
                    if lex.data[i] == '0' {
                        firstNum++
                    }
                }

                if lex.te - lex.ts - firstNum < 64 {
                    lex.out(out); tok = T_LNUMBER; fbreak;
                }
                lex.out(out); tok = T_DNUMBER; fbreak;
            };
            lnum => {
                if lex.te - lex.ts < 20 {
                    lex.out(out); tok = T_LNUMBER; fbreak;
                }
                lex.out(out); tok = T_DNUMBER; fbreak;
            };
            hnum => {
                firstNum := lex.ts + 2
                for i := lex.ts + 2; i < lex.te; i++ {
                    if lex.data[i] == '0' {
                        firstNum++
                    }
                }

                length := lex.te - firstNum
                if length < 16 || (length == 16 && lex.data[firstNum] <= '7') {
                    lex.out(out); tok = T_LNUMBER; fbreak;
                } 
                lex.out(out); tok = T_DNUMBER; fbreak;
            };

            'abstract'                      => {lex.out(out); tok = T_ABSTRACT; fbreak;};
            'array'                         => {lex.out(out); tok = T_ARRAY; fbreak;};
            'as'                            => {lex.out(out); tok = T_AS; fbreak;};
            'break'                         => {lex.out(out); tok = T_BREAK; fbreak;};
            'callable'                      => {lex.out(out); tok = T_CALLABLE; fbreak;};
            'case'                          => {lex.out(out); tok = T_CASE; fbreak;};
            'catch'                         => {lex.out(out); tok = T_CATCH; fbreak;};
            'class'                         => {lex.out(out); tok = T_CLASS; fbreak;};
            'clone'                         => {lex.out(out); tok = T_CLONE; fbreak;};
            'const'                         => {lex.out(out); tok = T_CONST; fbreak;};
            'continue'                      => {lex.out(out); tok = T_CONTINUE; fbreak;};
            'declare'                       => {lex.out(out); tok = T_DECLARE; fbreak;};
            'default'                       => {lex.out(out); tok = T_DEFAULT; fbreak;};
            'do'                            => {lex.out(out); tok = T_DO; fbreak;};
            'echo'                          => {lex.out(out); tok = T_ECHO; fbreak;};
            'else'                          => {lex.out(out); tok = T_ELSE; fbreak;};
            'elseif'                        => {lex.out(out); tok = T_ELSEIF; fbreak;};
            'empty'                         => {lex.out(out); tok = T_EMPTY; fbreak;};
            'enddeclare'                    => {lex.out(out); tok = T_ENDDECLARE; fbreak;};
            'endfor'                        => {lex.out(out); tok = T_ENDFOR; fbreak;};
            'endforeach'                    => {lex.out(out); tok = T_ENDFOREACH; fbreak;};
            'endif'                         => {lex.out(out); tok = T_ENDIF; fbreak;};
            'endswitch'                     => {lex.out(out); tok = T_ENDSWITCH; fbreak;};
            'endwhile'                      => {lex.out(out); tok = T_ENDWHILE; fbreak;};
            'eval'                          => {lex.out(out); tok = T_EVAL; fbreak;};
            'exit' | 'die'                  => {lex.out(out); tok = T_EXIT; fbreak;};
            'extends'                       => {lex.out(out); tok = T_EXTENDS; fbreak;};
            'final'                         => {lex.out(out); tok = T_FINAL; fbreak;};
            'finally'                       => {lex.out(out); tok = T_FINALLY; fbreak;};
            'for'                           => {lex.out(out); tok = T_FOR; fbreak;};
            'foreach'                       => {lex.out(out); tok = T_FOREACH; fbreak;};
            'function' | 'cfunction'        => {lex.out(out); tok = T_FUNCTION; fbreak;};
            'global'                        => {lex.out(out); tok = T_GLOBAL; fbreak;};
            'goto'                          => {lex.out(out); tok = T_GOTO; fbreak;};
            'if'                            => {lex.out(out); tok = T_IF; fbreak;};
            'isset'                         => {lex.out(out); tok = T_ISSET; fbreak;};
            'implements'                    => {lex.out(out); tok = T_IMPLEMENTS; fbreak;};
            'instanceof'                    => {lex.out(out); tok = T_INSTANCEOF; fbreak;};
            'insteadof'                     => {lex.out(out); tok = T_INSTEADOF; fbreak;};
            'interface'                     => {lex.out(out); tok = T_INTERFACE; fbreak;};
            'list'                          => {lex.out(out); tok = T_LIST; fbreak;};
            'namespace'                     => {lex.out(out); tok = T_NAMESPACE; fbreak;};
            'private'                       => {lex.out(out); tok = T_PRIVATE; fbreak;};
            'public'                        => {lex.out(out); tok = T_PUBLIC; fbreak;};
            'print'                         => {lex.out(out); tok = T_PRINT; fbreak;};
            'protected'                     => {lex.out(out); tok = T_PROTECTED; fbreak;};
            'return'                        => {lex.out(out); tok = T_RETURN; fbreak;};
            'static'                        => {lex.out(out); tok = T_STATIC; fbreak;};
            'switch'                        => {lex.out(out); tok = T_SWITCH; fbreak;};
            'throw'                         => {lex.out(out); tok = T_THROW; fbreak;};
            'trait'                         => {lex.out(out); tok = T_TRAIT; fbreak;};
            'try'                           => {lex.out(out); tok = T_TRY; fbreak;};
            'unset'                         => {lex.out(out); tok = T_UNSET; fbreak;};
            'use'                           => {lex.out(out); tok = T_USE; fbreak;};
            'var'                           => {lex.out(out); tok = T_VAR; fbreak;};
            'while'                         => {lex.out(out); tok = T_WHILE; fbreak;};
            'yield' whitespace_line* 'from' => {lex.out(out); tok = T_YIELD_FROM; fbreak;};
            'yield'                         => {lex.out(out); tok = T_YIELD; fbreak;};
            'include'                       => {lex.out(out); tok = T_INCLUDE; fbreak;};
            'include_once'                  => {lex.out(out); tok = T_INCLUDE_ONCE; fbreak;};
            'require'                       => {lex.out(out); tok = T_REQUIRE; fbreak;};
            'require_once'                  => {lex.out(out); tok = T_REQUIRE_ONCE; fbreak;};
            '__CLASS__'                     => {lex.out(out); tok = T_CLASS_C; fbreak;};
            '__DIR__'                       => {lex.out(out); tok = T_DIR; fbreak;};
            '__FILE__'                      => {lex.out(out); tok = T_FILE; fbreak;};
            '__FUNCTION__'                  => {lex.out(out); tok = T_FUNC_C; fbreak;};
            '__LINE__'                      => {lex.out(out); tok = T_LINE; fbreak;};
            '__NAMESPACE__'                 => {lex.out(out); tok = T_NS_C; fbreak;};
            '__METHOD__'                    => {lex.out(out); tok = T_METHOD_C; fbreak;};
            '__TRAIT__'                     => {lex.out(out); tok = T_TRAIT_C; fbreak;};
            '__halt_compiler'               => {lex.out(out); tok = T_HALT_COMPILER; fbreak;};
            'new'                           => {lex.out(out); tok = T_NEW; fbreak;};
            'and'                           => {lex.out(out); tok = T_LOGICAL_AND; fbreak;};
            'or'                            => {lex.out(out); tok = T_LOGICAL_OR; fbreak;};
            'xor'                           => {lex.out(out); tok = T_LOGICAL_XOR; fbreak;};
            '\\'                            => {lex.out(out); tok = T_NS_SEPARATOR; fbreak;};
            '...'                           => {lex.out(out); tok = T_ELLIPSIS; fbreak;};
            '::'                            => {lex.out(out); tok = T_PAAMAYIM_NEKUDOTAYIM; fbreak;};
            '&&'                            => {lex.out(out); tok = T_BOOLEAN_AND; fbreak;};
            '||'                            => {lex.out(out); tok = T_BOOLEAN_OR; fbreak;};
            '&='                            => {lex.out(out); tok = T_AND_EQUAL; fbreak;};
            '|='                            => {lex.out(out); tok = T_OR_EQUAL; fbreak;};
            '.='                            => {lex.out(out); tok = T_CONCAT_EQUAL; fbreak;};
            '*='                            => {lex.out(out); tok = T_MUL_EQUAL; fbreak;};
            '**='                           => {lex.out(out); tok = T_POW_EQUAL; fbreak;};
            '[/]='                          => {lex.out(out); tok = T_DIV_EQUAL; fbreak;};
            '+='                            => {lex.out(out); tok = T_PLUS_EQUAL; fbreak;};
            '-='                            => {lex.out(out); tok = T_MINUS_EQUAL; fbreak;};
            '^='                            => {lex.out(out); tok = T_XOR_EQUAL; fbreak;};
            '%='                            => {lex.out(out); tok = T_MOD_EQUAL; fbreak;};
            '--'                            => {lex.out(out); tok = T_DEC; fbreak;};
            '++'                            => {lex.out(out); tok = T_INC; fbreak;};
            '=>'                            => {lex.out(out); tok = T_DOUBLE_ARROW; fbreak;};
            '<=>'                           => {lex.out(out); tok = T_SPACESHIP; fbreak;};
            '!=' | '<>'                     => {lex.out(out); tok = T_IS_NOT_EQUAL; fbreak;};
            '!=='                           => {lex.out(out); tok = T_IS_NOT_IDENTICAL; fbreak;};
            '=='                            => {lex.out(out); tok = T_IS_EQUAL; fbreak;};
            '==='                           => {lex.out(out); tok = T_IS_IDENTICAL; fbreak;};
            '<<='                           => {lex.out(out); tok = T_SL_EQUAL; fbreak;};
            '>>='                           => {lex.out(out); tok = T_SR_EQUAL; fbreak;};
            '>='                            => {lex.out(out); tok = T_IS_GREATER_OR_EQUAL; fbreak;};
            '<='                            => {lex.out(out); tok = T_IS_SMALLER_OR_EQUAL; fbreak;};
            '**'                            => {lex.out(out); tok = T_POW; fbreak;};
            '<<'                            => {lex.out(out); tok = T_SL; fbreak;};
            '>>'                            => {lex.out(out); tok = T_SR; fbreak;};
            '??'                            => {lex.out(out); tok = T_COALESCE; fbreak;};

            '(' whitespace* 'array' whitespace* ')'                    => {lex.out(out); tok = T_ARRAY_CAST; fbreak;};
            '(' whitespace* ('bool'|'boolean') whitespace* ')'         => {lex.out(out); tok = T_BOOL_CAST; fbreak;};
            '(' whitespace* ('real'|'double'|'float') whitespace* ')'  => {lex.out(out); tok = T_DOUBLE_CAST; fbreak;};
            '(' whitespace* ('int'|'integer') whitespace* ')'          => {lex.out(out); tok = T_INT_CAST; fbreak;};
            '(' whitespace* 'object' whitespace* ')'                   => {lex.out(out); tok = T_OBJECT_CAST; fbreak;};
            '(' whitespace* ('string'|'binary') whitespace* ')'        => {lex.out(out); tok = T_STRING_CAST; fbreak;};
            '(' whitespace* 'unset' whitespace* ')'                    => {lex.out(out); tok = T_UNSET_CAST; fbreak;};

            ('#' | '//') any* :>> (newline | "?>") => {
                if string(lex.data[lex.te-2:lex.te]) == "?>" {
                    lex.p = lex.p - 2
                }
                // TODO: save freefloating comment
            };
            '/*' any_line* :>> '*/' {
                isDocComment := false;
                if lex.te - lex.ts > 4 && string(lex.data[lex.ts:lex.ts+3]) == "/**" {
                    isDocComment = true;
                }
                _ = isDocComment
                // TODO: save freefloating comment
            };

            operators => {
                // rune, _ := utf8.DecodeRune(lex.data[lex.ts:lex.te]);
                // tok = TokenID(Rune2Class(rune));
                lex.out(out);
                tok = TokenID(int(lex.data[lex.ts]));
                fbreak;
            };

            "{"          => { lex.out(out); tok = TokenID(int('{')); lex.call(fcurs, fentry(php)); goto _out; };
            "}"          => { lex.out(out); tok = TokenID(int('{')); lex.ret(); goto _out; };
            "$" varname  => { lex.out(out); tok = T_VARIABLE; fbreak; };
            varname      => { lex.out(out); tok = T_STRING;   fbreak; };

            "->"         => { lex.out(out); tok = T_OBJECT_OPERATOR; fnext property; fbreak; };

            constant_string => {
                lex.out(out);
                tok = T_CONSTANT_ENCAPSED_STRING;
                fbreak;
            };
        *|;

        property := |*
            whitespace_line*;

            "->"    => { lex.out(out); tok = T_OBJECT_OPERATOR; fbreak; };
            varname => { lex.out(out); tok = T_STRING; fnext php; fbreak; };
            any     => { lex.ungetCnt(1); fgoto php; };
        *|;

        write exec;
    }%%

    return tok;
}

func (lex *lexer) growStack() {
    if lex.top == len(lex.stack) {
        lex.stack = append(lex.stack, 0)
    }
}

func (lex *lexer) call(fcurs int, fnext int) {
    lex.growStack()
    
    lex.stack[lex.top] = fcurs;
    lex.top++;

    lex.p++;
    lex.cs = fnext;
}

func (lex *lexer) ret() {
    lex.top--
    lex.cs = lex.stack[lex.top]
    lex.p++;
}

func (lex *lexer) ungetStr(s string) {
    tokenStr := string(lex.data[lex.ts:lex.te])
    if strings.HasSuffix(tokenStr, s) {
        lex.ungetCnt(len(s))
    }
}

func (lex *lexer) ungetCnt(n int) {
    lex.p = lex.p - n
    lex.te = lex.te - n
}

func (lex *lexer) out(out *yySymType) {
    out.data = lex.data[lex.ts:lex.te];
    out.line = lex.curline
}

func (lex *lexer) Error(e string) {
    fmt.Println("error:", e)
}