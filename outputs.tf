output "jenkins_ip" {
  value = aws_eip.jenkins.public_ip
}

output "app_ip" {
  value = aws_eip.app.public_ip
}

output "jenkins_url" {
  value = "http://${aws_eip.jenkins.public_ip}:8080"
}

output "app_url" {
  value = "http://${aws_eip.app.public_ip}"
}