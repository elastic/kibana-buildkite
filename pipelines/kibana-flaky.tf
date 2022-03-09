resource "buildkite_pipeline" "flaky_test_suite_runner" {
  name        = "kibana / flaky-test-suite-runner"
  description = "New Build, fill in your PR number, Create Build, then watch the next page"
  repository  = "https://github.com/elastic/kibana.git"
  steps       = <<-EOT
  steps:
    - command: .buildkite/pipelines/flaky_tests/pipeline.sh
      label: 'Create pipeline'
      agents:
        queue: kibana-default
  EOT

  default_branch = "refs/pull/INSERT_PR_NUMBER/head"

  provider_settings {
    trigger_mode = "none"
  }
}
