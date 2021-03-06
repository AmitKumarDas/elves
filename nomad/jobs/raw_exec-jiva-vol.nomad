job "demo-vsm" {
	datacenters = ["dc1"]

	# Restrict our job to only linux. We can specify multiple
	# constraints as needed.
	constraint {
		attribute = "${attr.kernel.name}"
		value = "linux"
	}

	#Declare the IP parameters generic to all controllers and replicas
	meta {
		JIVA_VOLNAME = "demo-vol1"
		JIVA_VOLSIZE = "5g"
		JIVA_FRONTENDIP = "172.28.128.101"
	}

	# Create a 'ctl' group. Each task in the group will be
	# scheduled onto the same machine.
	group "ctl" {
		# Configure the restart policy for the task group. If not provided, a
		# default is used based on the job type.
		restart {
			mode = "fail"
			attempts = 1
		}

		# Define the controller task to run
		task "jiva-ctl" {
			# Use a docker wrapper to run the task.
			driver = "raw_exec"
			artifact {
				source = "https://raw.githubusercontent.com/openebs/jiva/master/scripts/launch-jiva-ctl-with-ip"
			}

			env {
				JIVA_CTL_NAME = "${NOMAD_TASK_NAME}"
				JIVA_CTL_VERSION = "openebs/jiva:latest"
				JIVA_CTL_VOLNAME = "${NOMAD_META_JIVA_VOLNAME}"
				JIVA_CTL_VOLSIZE = "${NOMAD_META_JIVA_VOLSIZE}"
				JIVA_CTL_IP = "${NOMAD_META_JIVA_FRONTENDIP}"
				JIVA_CTL_SUBNET = "24"
				JIVA_CTL_IFACE = "enp0s8"
			}

			config {
				command = "launch-jiva-ctl-with-ip"
			}

			# We must specify the resources required for
			# this task to ensure it runs on a machine with
			# enough capacity.
			resources {
				cpu = 500 # 500 MHz
				memory = 256 # 256MB
				network {
					mbits = 20
				}
			}

		}
	}

	# Create a 'rep' group. Each task in the group will be
	# scheduled onto the same machine.
	group "rep" {
		# Configure the restart policy for the task group. If not provided, a
		# default is used based on the job type.
		restart {
			mode = "fail"
			attempts = 1
		}

		# Define the controller task to run
		task "jiva-rep" {
			# Use a docker wrapper to run the task.
			driver = "raw_exec"
			artifact {
				source = "https://raw.githubusercontent.com/openebs/jiva/master/scripts/launch-jiva-rep-with-ip"
			}

			env {
				JIVA_REP_NAME = "${NOMAD_TASK_NAME}"
				JIVA_REP_VERSION = "openebs/jiva:latest"
				JIVA_CTL_IP = "${NOMAD_META_JIVA_FRONTENDIP}"
				JIVA_REP_VOLNAME = "${NOMAD_META_JIVA_VOLNAME}"
				JIVA_REP_VOLSIZE = "${NOMAD_META_JIVA_VOLSIZE}"
				JIVA_REP_IP = "172.28.128.102"
				JIVA_REP_SUBNET = "24"
				JIVA_REP_IFACE = "enp0s8"
				JIVA_REP_VOLSTORE = "/tmp/jiva/rep1"
			}

			config {
				command = "launch-jiva-rep-with-ip"
			}

			# We must specify the resources required for
			# this task to ensure it runs on a machine with
			# enough capacity.
			resources {
				cpu = 500 # 500 MHz
				memory = 256 # 256MB
				network {
					mbits = 20
				}
			}

		}
	}
}
