# Test previous major Kibana against all current major ES versions that are still under development
resource "buildkite_pipeline" "es_forward" {
  # for_each only supports maps and sets of strings
  # This creates a map of { "major.minor" => version_object }
  for_each = { for major in local.kibana_current_majors : join(".", slice(split(".", major["version"]), 0, 2)) => major }

  name        = "kibana / ${local.kibana_previous_major["branch"]} ES ${each.key} forward compatibility"
  description = "Runs full CI daily using ${local.kibana_previous_major["branch"]} kibana and ${each.key} ES"
  repository  = "https://github.com/elastic/kibana.git"
  steps       = <<-EOT
  env:
    SLACK_NOTIFICATIONS_ENABLED: 'true'
    ES_SNAPSHOT_MANIFEST: 'https://storage.googleapis.com/kibana-ci-es-snapshots-daily/${each.value["version"]}/manifest-latest-verified.json'
  steps:
    - label: ":pipeline: Pipeline upload"
      command: buildkite-agent pipeline upload .buildkite/pipelines/es_forward.yml
      agents:
        queue: kibana-default
  EOT

  default_branch       = local.kibana_previous_major["branch"]
  branch_configuration = local.kibana_previous_major["branch"]

  provider_settings {
    build_branches      = false
    build_tags          = false
    build_pull_requests = false

    trigger_mode = "none"
  }

  team {
    slug         = "everyone"
    access_level = "MANAGE_BUILD_AND_READ"
  }
}

resource "buildkite_pipeline_schedule" "es_forward" {
  for_each    = buildkite_pipeline.es_forward
  pipeline_id = each.value.id
  label       = "Daily build"
  cronline    = "0 9 * * * America/New_York"
  branch      = local.kibana_previous_major["branch"]
}

