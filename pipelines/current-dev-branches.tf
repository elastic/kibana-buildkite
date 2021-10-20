locals {
  current_dev_branches = ["master", "7.15"]
  hourly_branches      = ["master", "7.16"]
  daily_branches       = setsubtract(local.current_dev_branches, local.hourly_branches)
}
