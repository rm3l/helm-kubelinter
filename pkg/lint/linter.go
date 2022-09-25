package lint

import (
	"fmt"
	"github.com/spf13/cobra"
	"golang.stackrox.io/kube-linter/pkg/command/lint"
	"os"
)

func Lint(cmd *cobra.Command, chartRenderedFile *os.File, args []string) error {
	fmt.Println(chartRenderedFile.Name(), args)
	commandArgs := []string{chartRenderedFile.Name()}
	for _, arg := range args {
		commandArgs = append(commandArgs, arg)
	}
	command := lint.Command()
	err := command.RunE(cmd, commandArgs)
	return err
}
