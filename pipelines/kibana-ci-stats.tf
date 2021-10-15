resource "buildkite_pipeline" "kibana-ci-stats-trigger" {
  name        = "kibana-ci-stats / trigger"
  description = "Triggers pipelines on commit based on the changed files in the commit"
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
  repository  = "https://github.com/elastic/ci-stats.git"
  steps       = <<-EOT
  env:
    PR_COMMENTS_ENABLED: 'true'
    GITHUB_COMMIT_STATUS_ENABLED: 'true'
    GITHUB_COMMIT_STATUS_CONTEXT: 'kibana-ci'
  steps:
    - label: ":pipeline: Pipeline upload"
      command: buildkite-agent pipeline upload .buildkite/pipeline.yml
  EOT

  default_branch       = "master"
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

resource "github_repository_webhook" "kibana-ci-stats-trigger" {
  repository = "kibana-ci-stats"

  configuration {
    url          = buildkite_pipeline.kibana-ci-stats-trigger.webhook_url
    content_type = "json"
    insecure_ssl = false
  }

  active = true

  events = ["push"]
}
