.PHONY: build clean test

build:
	go build -o mdns-proxy.exe .

clean:
	rm -f mdns-proxy.exe
	rm -rf msi_build/
	rm -f *.msi
	rm -f wix.build.json

test:
	go test -v ./...

tidy:
	go mod tidy

help:
	@echo "Available targets:"
	@echo "  build  - Build the mdns-proxy.exe executable"
	@echo "  clean  - Remove build artifacts"
	@echo "  test   - Run tests"
	@echo "  tidy   - Tidy go.mod dependencies"
