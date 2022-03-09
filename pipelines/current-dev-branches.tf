locals {
  current_dev_branches = ["main", "8.1", "7.17"]
  hourly_branches      = ["main", "8.1", "7.17"]
  daily_branches       = setsubtract(local.current_dev_branches, local.hourly_branches)
}
