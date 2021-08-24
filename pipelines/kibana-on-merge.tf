resource "buildkite_pipeline" "on-merge" {
  name        = "kibana / on merge"
  description = "Runs for each commit of Kibana, i.e. each time a PR is merged"
  repository  = "https://github.com/elastic/kibana.git"
  steps       = <<-EOT
  env:
    SLACK_NOTIFICATIONS_CHANNEL: '#kibana-operations-alerts'
    SLACK_NOTIFICATIONS_ENABLED: 'true'
  steps:
    - label: ":pipeline: Pipeline upload"
      command: buildkite-agent pipeline upload .buildkite/pipelines/on_merge.yml
  EOT

  default_branch       = "master"
  branch_configuration = "master 7.x 7.15 7.14"

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
