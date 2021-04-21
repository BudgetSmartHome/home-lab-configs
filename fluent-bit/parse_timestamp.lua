function local_timestamp_to_UTC(tag, timestamp, record)
  local d1 = os.date("*t", 0)
  local d2 = os.date("!*t", 0)
  local zone_diff = os.difftime(os.time(d2), os.time(d1))
  new_timestamp = timestamp + zone_diff
  return 1, new_timestamp, record
end
