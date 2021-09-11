CC=dart
FMT=format

default: fmt

fmt:
	$(CC) $(FMT) .
	$(CC) analyze .

check:
	$(CC) example/example.dart