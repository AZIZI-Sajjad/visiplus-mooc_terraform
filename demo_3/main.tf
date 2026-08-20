#TODO : CREATE FIRST FILE
resource "local_file" "file_1" {
    filename = "${path.module}/file_1.txt"
    content = "THIS IS FILE 1"
}

#TODO : CREATE SECOND FILE
resource "local_file" "file_2" {
  filename = "${path.module}/directory/file_2.txt"
  content  = "THIS IS FILE 2"
}

#TODO : CREATE THIRTH FILE
resource "local_file" "file_3" {
  filename = "${path.module}/directory/file_3.txt"
  content  = <<-EOF
  THIS IS FILE 3 LINE 1
  THIS IS FILE 3 LINE 2
  THIS IS FILE 3 LINE 3
  EOF
}

