locals {
  current_dev_branches = ["main", "7.16", "7.15"]
  hourly_branches      = ["main", "7.16"]
  daily_branches       = setsubtract(local.current_dev_branches, local.hourly_branches)
}
