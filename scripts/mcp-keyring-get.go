//go:build keyringget

// Command mcp-keyring-get prints PIPELINES_API_TOKEN from the
// content-pipelines-mcp macOS keychain item. Used by serve-content-pipelines-mcp-inner.sh
// because rebuilt tmp/content-pipelines-mcp binaries lose keychain ACL.
package main

import (
	"fmt"
	"os"

	"github.com/zalando/go-keyring"
)

func main() {
	secret, err := keyring.Get("content-pipelines-mcp", "PIPELINES_API_TOKEN")
	if err != nil || secret == "" {
		os.Exit(1)
	}
	fmt.Print(secret)
}
