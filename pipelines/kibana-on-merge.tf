resource "buildkite_pipeline" "on-merge" {
  name        = "kibana / on merge"
  description = "Runs for each commit of Kibana, i.e. each time a PR is merged"
  repository  = "https://github.com/elastic/kibana.git"
  steps       = <<-EOT
  env:
    SLACK_NOTIFICATIONS_CHANNEL: '#kibana-operations-alerts'
    SLACK_NOTIFICATIONS_ENABLED: 'true'
    GITHUB_BUILD_COMMIT_STATUS_ENABLED: 'true'
    GITHUB_COMMIT_STATUS_CONTEXT: 'buildkite/on-merge'
  steps:
    - label: ":pipeline: Pipeline upload"
      command: buildkite-agent pipeline upload .buildkite/pipelines/on_merge.yml
      agents:
        queue: kibana-default
  EOT

  default_branch       = "main"
  branch_configuration = join(" ", local.current_dev_branches)

  provider_settings {
    build_branches      = true
    build_tags          = false
    build_pull_requests = false

    trigger_mode = "code"
  }
}

resource "github_repository_webhook" "on-merge" {
  repository = "kibana"

  configuration {
    url          = buildkite_pipeline.on-merge.webhook_url
    content_type = "json"
    insecure_ssl = false
  }

  active = true

  events = ["push"]
}
