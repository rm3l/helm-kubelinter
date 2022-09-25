package cmd

import (
	"fmt"
	"github.com/rm3l/helm-kubelinter/pkg/chart"
	"github.com/rm3l/helm-kubelinter/pkg/lint"
	"os"
	"path/filepath"

	"github.com/spf13/cobra"
)

var (
	kubeLinterAddAllBuiltin        string
	kubeLinterConfig               string
	kubeLinterDoNotAutoAddDefaults string
	kubeLinterExclude              string
	kubeLinterFormat               string
	kubeLinterInclude              string
	kubeLinterVerbose              bool
)

var rootCmd = &cobra.Command{
	Use:   filepath.Base(os.Args[0]),
	Short: "Validate Helm Charts using KubeLinter",
	Long: `This renders your charts locally and checks the resulting output using KubeLinter.
	The difference with calling KubeLinter directly is that it is possible to pass 
any valid options to Helm first (like dedicated values.yaml files) to represent a specific deployment context
that needs to be checked.
`,
	Args: cobra.MinimumNArgs(1),
	Run: func(cmd *cobra.Command, args []string) {
		chartRenderedLocally, closerFunc, err := chart.RenderLocally(args)
		if err != nil {
			panic(err)
		}
		defer closerFunc(chartRenderedLocally)
		fmt.Println("chart rendered locally", chartRenderedLocally.Name())

		if err := lint.Lint(cmd, chartRenderedLocally, args); err != nil {
			panic(err)
		}
	},
}

// Execute executes the CLI
func Execute() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}

func init() {
	rootCmd.PersistentFlags().StringVar(&kubeLinterAddAllBuiltin, "kube-linter-add-all-built-in", "", "AddAllBuiltIn, if set, adds all built-in checks. This allows users to explicitly opt-out of checks that are not relevant using Exclude")
	rootCmd.PersistentFlags().StringVar(&kubeLinterConfig, "kube-linter-config", "", "Path to Kube-Linter config file")
	rootCmd.PersistentFlags().StringVar(&kubeLinterDoNotAutoAddDefaults, "kube-linter-do-not-auto-add-defaults", "", "DoNotAutoAddDefaults, if set, prevents the automatic addition of default checks.")
	rootCmd.PersistentFlags().StringVar(&kubeLinterExclude, "kube-linter-exclude",
		"",
		"Exclude is a list of check names to exclude.")
	rootCmd.PersistentFlags().StringVar(&kubeLinterFormat,
		"kube-linter-format", "",
		"Output format. Allowed values: json, plain, sarif. (default \"plain\")")
	rootCmd.PersistentFlags().StringVar(&kubeLinterInclude,
		"kube-linter-include", "", "Include is a list of check names to include. If a check is in both Include and Exclude, Exclude wins.")
	rootCmd.PersistentFlags().BoolVar(&kubeLinterVerbose, "kube-linter-verbose", false,
		"Enable verbose logging")
	rootCmd.AddCommand()
}
