# Variable pour la clé d'accès AWS
variable "access_key" {
  # Type de la variable
  type = string
}

# Variable pour la clé secrète AWS
variable "secret_key" {
  # Type de la variable
  type = string
}

# Variable pour la région
variable "aws_region" {
  # Type de la variable
  type = string
}

variable "list_of_files" {
  description = "List of files"

  type = list(string)

  default = ["file_first", "file_second", "file_third"]

  validation {
    condition     = length(var.list_of_files) > 2 && alltrue([for v in var.list_of_files : (split("_", v)[0] == "file")])
    error_message = "Each file item should starting with \"file_\" and list should be more than 3"
  }
}

