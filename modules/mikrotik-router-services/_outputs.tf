output "ddns_hostname" {
  description = "Mikrotik Cloud DDNS hostname"
  value       = routeros_ip_cloud.cloud.dns_name
  sensitive   = true
}

# output "trusted_wifi_password" {
#   description = "The password for the Untrusted Wi-Fi network."
#   value       = random_string.trusted_wifi_password.result
#   sensitive   = true
# }
# output "guest_wifi_password" {
#   description = "The password for the Guest Wi-Fi network."
#   value       = random_string.guest_wifi_password.result
#   sensitive   = true
# }
# output "iot_wifi_password" {
#   description = "The password for the IoT Wi-Fi network."
#   value       = random_string.iot_wifi_password.result
#   sensitive   = true
# }
