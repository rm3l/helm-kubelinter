package cmd

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"
)

var (
	flagDebug bool
)

var rootCmd = &cobra.Command{
	Use:   "helm-kubelinter",
	Short: "Validate Helm Charts using KubeLinter",
	Long:  ``,
}

// Execute executes the CLI
func Execute() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}

func init() {
	cobra.OnInitialize(func() {
		// var err error
		// gcsClient, err = gcs.NewClient(flagServiceAccount)
		// if err != nil {
		// 	panic(err)
		// }
		// if flagDebug {
		// 	repo.Debug = true
		// }
	})
	rootCmd.PersistentFlags().BoolVar(&flagDebug, "debug", false, "activate debug")
}
