# -----------------------------------------------------------------------------
# Variables: General
# -----------------------------------------------------------------------------

variable "availability_zones" {
  type = list(string)
  description = "All 3 availability zones required to spread the application"
  default = ["eu-west-3a", "eu-west-3b", "eu-west-3c"]
}

variable "public_subnet_cidrs" {
 type        = list(string)
 description = "Public Subnet CIDR values"
 default     = ["10.100.1.0/24", "10.100.2.0/24", "10.100.3.0/24"]
}
 
variable "private_subnet_cidrs" {
 type        = list(string)
 description = "Private Subnet CIDR values"
 default     = ["10.100.4.0/24", "10.100.5.0/24", "10.100.6.0/24"]
}

# -----------------------------------------------------------------------------
# Variables: Cloudwatch Alarms Latency
# -----------------------------------------------------------------------------

variable "resources" {
  description = "Methods that have Cloudwatch alarms enabled"
  type        = map
  default     = {}
}

variable "fourRate_threshold" {
  description = "Percentage of errors that will trigger an alert"
  default     = 0.02
  type        = number
}

variable "fourRate_evaluationPeriods" {
  description = "How many periods are evaluated before the alarm is triggered"
  default     = 5
  type        = number
}