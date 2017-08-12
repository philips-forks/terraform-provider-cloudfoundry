TEST?=$$(go list ./... |grep -v 'vendor')
GOFMT_FILES?=$$(find . -name '*.go' |grep -v vendor)

default: build

release: testacc
	rm -fr bin
	mkdir -p bin
	GOARCH=amd64 GOOS=windows go build -o bin/terraform-provider-cloudfoundry_windows_amd64.exe
	GOARCH=amd64 GOOS=linux go build -o bin/terraform-provider-cloudfoundry_linux_amd64
	GOARCH=amd64 GOOS=darwin go build -o bin/terraform-provider-cloudfoundry_darwin_amd64

build: fmtcheck
	go install

test: fmtcheck
	go test -i $(TEST) || exit 1
	echo $(TEST) | \
		xargs -t -n4 go test $(TESTARGS) -timeout=30s -parallel=4

testacc: fmtcheck
	CF_USER=admin \
	CF_PASSWORD=admin \
	CF_SKIP_SSL_VALIDATION=true \
	CF_UAA_CLIENT_ID=admin \
	CF_API_URL=https://api.$$(scripts/pcfdev-public-ip.sh).xip.io \
	CF_UAA_CLIENT_SECRET=admin-client-secret \
	TF_ACC=1 go test $(TEST) -v $(TESTARGS) -timeout 120m

vet:
	@echo "go vet ."
	@go vet $$(go list ./... | grep -v vendor/) ; if [ $$? -eq 1 ]; then \
		echo ""; \
		echo "Vet found suspicious constructs. Please check the reported constructs"; \
		echo "and fix them if necessary before submitting the code for review."; \
		exit 1; \
	fi

fmt:
	gofmt -w $(GOFMT_FILES)

fmtcheck:
	@sh -c "'$(CURDIR)/scripts/gofmtcheck.sh'"

errcheck:
	@sh -c "'$(CURDIR)/scripts/errcheck.sh'"

vendor-status:
	@govendor status

test-compile:
	@if [ "$(TEST)" = "./..." ]; then \
		echo "ERROR: Set TEST to a specific package. For example,"; \
		echo "  make test-compile TEST=./aws"; \
		exit 1; \
	fi
	go test -c $(TEST) $(TESTARGS)

.PHONY: build test testacc vet fmt fmtcheck errcheck vendor-status test-compile
