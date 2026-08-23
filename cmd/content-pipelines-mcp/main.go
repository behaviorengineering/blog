package main

import (
	"fmt"
	"os"

	"github.com/xynova/content-pipelines-mcp/mcp"
)

func main() {
	if err := mcp.Run(os.Args[1:]); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}
