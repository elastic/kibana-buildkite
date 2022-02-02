locals {
  current_dev_branches = ["main", "8.1", "8.0", "7.17", "7.16", "7.15"]
  hourly_branches      = ["main", "8.1", "8.0", "7.17"]
  daily_branches       = setsubtract(local.current_dev_branches, local.hourly_branches)
}
