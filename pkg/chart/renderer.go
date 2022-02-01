package chart

import (
	"fmt"
	"os"
	"os/exec"
)

type CloserFunc func(*os.File)

// RenderLocally renders the Chart locally, using the 'helm template ...' command execution.
// This is possible since this is a Helm Plugin, so the Helm command should always be available.
// However, a better strategy could have been to leverage the Helm Go SDK right away, but
// it looks like the logic behind the 'helm template' command cannot be easily called from the outside.
func RenderLocally(args []string) (*os.File, CloserFunc, error) {
	fmt.Println("args", args)
	helmBin, ok := os.LookupEnv("HELM_BIN")
	if !ok {
		fmt.Println("could not find HELM_BIN environment variable. Defaulting to the 'helm' command, hopefully in the PATH")
		helmBin = "helm"
	} else {
		fmt.Println("found HELM_BIN variable:", helmBin)
	}

	cmdArgs := []string{"template"}
	for _, arg := range args {
		cmdArgs = append(cmdArgs, arg)
	}

	cmd := exec.Command(helmBin, cmdArgs...)
	outfile, err := os.CreateTemp("", "helm-template-result")
	if err != nil {
		return nil, nil, err
	}
	cmd.Stdout = outfile

	closerFunc := func(file *os.File) {
		err := os.Remove(file.Name())
		if err != nil {
			fmt.Println("could not remove file", file, err)
		}
	}

	err = cmd.Start()
	if err != nil {
		return nil, closerFunc, err
	}

	err = cmd.Wait()
	if err != nil {
		return nil, closerFunc, err
	}

	return outfile, closerFunc, nil
}
