resource "buildkite_pipeline" "kibana-ci-stats-main" {
  name        = "kibana-ci-stats / main"
  description = "Runs CI on each commit to kibana-ci-stats repo"
  repository  = "https://github.com/elastic/kibana-ci-stats.git"
  steps       = <<-EOT
  env:
    SLACK_NOTIFICATIONS_CHANNEL: '#kibana-operations-alerts'
    SLACK_NOTIFICATIONS_ENABLED: 'false'
  steps:
    - label: ":pipeline: Pipeline upload"
      command: buildkite-agent pipeline upload .buildkite/pipeline.yml
  EOT

  default_branch       = "main"
  branch_configuration = "main"

  provider_settings {
    build_branches      = true
    build_tags          = false
    build_pull_requests = false

    trigger_mode = "code"
  }
}

resource "buildkite_pipeline" "kibana-ci-stats-pull-request" {
  name        = "kibana-ci-stats / pull request"
  description = "Runs manually for pull requests"
  repository  = "https://github.com/elastic/kibana-ci-stats.git"
  steps       = <<-EOT
  env:
    PR_COMMENTS_ENABLED: 'true'
    GITHUB_COMMIT_STATUS_ENABLED: 'true'
    GITHUB_COMMIT_STATUS_CONTEXT: 'ci'
  steps:
    - label: ":pipeline: Pipeline upload"
      command: buildkite-agent pipeline upload .buildkite/pipeline.yml
  EOT

  default_branch       = "main"
  branch_configuration = ""

  cancel_intermediate_builds = true

  provider_settings {
    build_branches      = false
    build_tags          = false
    build_pull_requests = true

    trigger_mode = "none"

    publish_commit_status = false
  }
}

resource "github_repository_webhook" "kibana-ci-stats-main" {
  repository = "kibana-ci-stats"

  configuration {
    url          = buildkite_pipeline.kibana-ci-stats-main.webhook_url
    content_type = "json"
    insecure_ssl = false
  }

  active = true

  events = ["push"]
}
