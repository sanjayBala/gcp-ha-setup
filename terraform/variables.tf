variable backend_server_count {
  type    = number
  default = 2
}

variable backend_server_prefix {
  type    = string
  default = "backend"
}

variable make_sticky {
  type    = string
  default = "False"
}
