PHPFILE=example.php

all: compile fmt build run

fmt:
	find . -type f -iregex '.*\.go' -exec gofmt -l -s -w '{}' +

compile:
	ragel -Z -G2 -o lex.go lex.rl
	go generate

build:
	go build

run:
	./ragel