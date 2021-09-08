locals {
  # TODO use current_dev_branches var when it exists and es stuff has been backported
  es_snapshot_branches = ["master"]
}

resource "buildkite_pipeline" "es_snapshot_build" {
  name        = "kibana / elasticsearch snapshot build"
  description = "Build new Elasticsearch snapshots for use by kbn-es / FTR"
  repository  = "https://github.com/elastic/kibana.git"
  steps       = <<-EOT
  env:
    SLACK_NOTIFICATIONS_CHANNEL: '#kibana-operations-alerts'
    SLACK_NOTIFICATIONS_ENABLED: 'true'
  steps:
    - label: ":pipeline: Pipeline upload"
      command: buildkite-agent pipeline upload .buildkite/pipelines/es_snapshots/build.yml
  EOT

  default_branch       = "master"
  branch_configuration = "master"

  provider_settings {
    build_branches      = false
    build_tags          = false
    build_pull_requests = false

    trigger_mode = "none"
  }
}

resource "buildkite_pipeline" "es_snapshot_verify" {
  name        = "kibana / elasticsearch snapshot verify"
  description = "Verify Elasticsearch snapshots for use by kbn-es / FTR"
  repository  = "https://github.com/elastic/kibana.git"
  steps       = <<-EOT
  env:
    SLACK_NOTIFICATIONS_CHANNEL: '#kibana-operations-alerts'
    SLACK_NOTIFICATIONS_ENABLED: 'true'
  steps:
    - label: ":pipeline: Pipeline upload"
      command: buildkite-agent pipeline upload .buildkite/pipelines/es_snapshots/verify.yml
  EOT

  default_branch       = "master"
  branch_configuration = "master"

  provider_settings {
    build_branches      = false
    build_tags          = false
    build_pull_requests = false

    trigger_mode = "none"
  }
}

resource "buildkite_pipeline" "es_snapshot_promote" {
  name        = "kibana / elasticsearch snapshot promote"
  description = "Promote Elasticsearch snapshots for use by kbn-es / FTR"
  repository  = "https://github.com/elastic/kibana.git"
  steps       = <<-EOT
  env:
    SLACK_NOTIFICATIONS_CHANNEL: '#kibana-operations-alerts'
    SLACK_NOTIFICATIONS_ENABLED: 'true'
  steps:
    - label: ":pipeline: Pipeline upload"
      command: buildkite-agent pipeline upload .buildkite/pipelines/es_snapshots/promote.yml
  EOT

  default_branch       = "master"
  branch_configuration = "master"

  provider_settings {
    build_branches      = false
    build_tags          = false
    build_pull_requests = false

    trigger_mode = "none"
  }
}

resource "buildkite_pipeline_schedule" "es_snapshot_build_daily" {
  for_each = toset(local.es_snapshot_branches)

  pipeline_id = buildkite_pipeline.es_snapshot_build.id
  label       = "Daily build"
  cronline    = "0 10 * * * America/New_York"
  branch   = each.value
}
