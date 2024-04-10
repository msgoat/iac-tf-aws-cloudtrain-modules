variable region_name {
  description = "The AWS region to deploy into (e.g. eu-central-1)."
  type = string
}

// current-generation - Indicates whether this instance type is the latest generation instance type of an instance family (true | false).
variable current_generation {
  description = "Indicates whether this instance type is the latest generation instance type of an instance family (true | false)."
  type = bool
  default = true
}

// ebs-info.ebs-optimized-support - Indicates whether the instance type is EBS-optimized (supported | unsupported | default).
variable ebs_optimized_support {
  description = "Indicates whether the instance type is EBS-optimized (supported | unsupported | default)."
  type = string
  default = "supported"
}

// hypervisor - The hypervisor (nitro | xen).
variable hypervisor {
  description = "The hypervisor (nitro | xen)."
  type = string
  default = "nitro"
}

// processor-info.supported-architecture - The CPU architecture (arm64 | i386 | x86_64).
variable cpu_architecture {
  description = "The CPU architecture (arm64 | i386 | x86_64)."
  type = string
  default = "x86_64"
  validation {
    condition = contains(["arm64","i386","x86_64"], var.cpu_architecture)
    error_message = "Expected cpu_architecture to be one of (arm64 | i386 | x86_64), but was [$var.cpu_architecture]"
  }
}
// memory-info.size-in-mib - The memory size.
variable memory {
  description = "The memory size in GB"
  type = number
  default = 0
}

// vcpu-info.default-cores - The default number of cores for the instance type.
variable cores {
  description = "The default number of cores for the instance type."
  type = number
  default = 0
}


/*
    auto-recovery-supported - Indicates whether Amazon CloudWatch action based recovery is supported (true | false).

    bare-metal - Indicates whether it is a bare metal instance type (true | false).

    burstable-performance-supported - Indicates whether the instance type is a burstable performance T instance type (true | false).

    current-generation - Indicates whether this instance type is the latest generation instance type of an instance family (true | false).

    ebs-info.ebs-optimized-info.baseline-bandwidth-in-mbps - The baseline bandwidth performance for an EBS-optimized instance type, in Mbps.

    ebs-info.ebs-optimized-info.baseline-iops - The baseline input/output storage operations per second for an EBS-optimized instance type.

    ebs-info.ebs-optimized-info.baseline-throughput-in-mbps - The baseline throughput performance for an EBS-optimized instance type, in MB/s.

    ebs-info.ebs-optimized-info.maximum-bandwidth-in-mbps - The maximum bandwidth performance for an EBS-optimized instance type, in Mbps.

    ebs-info.ebs-optimized-info.maximum-iops - The maximum input/output storage operations per second for an EBS-optimized instance type.

    ebs-info.ebs-optimized-info.maximum-throughput-in-mbps - The maximum throughput performance for an EBS-optimized instance type, in MB/s.

    ebs-info.ebs-optimized-support - Indicates whether the instance type is EBS-optimized (supported | unsupported | default).

    ebs-info.encryption-support - Indicates whether EBS encryption is supported (supported | unsupported).

    ebs-info.nvme-support - Indicates whether non-volatile memory express (NVMe) is supported for EBS volumes (required | supported | unsupported).

    free-tier-eligible - Indicates whether the instance type is eligible to use in the free tier (true | false).

    hibernation-supported - Indicates whether On-Demand hibernation is supported (true | false).

    hypervisor - The hypervisor (nitro | xen).

    instance-storage-info.disk.count - The number of local disks.

    instance-storage-info.disk.size-in-gb - The storage size of each instance storage disk, in GB.

    instance-storage-info.disk.type - The storage technology for the local instance storage disks (hdd | ssd).

    instance-storage-info.encryption-support - Indicates whether data is encrypted at rest (required | supported | unsupported).

    instance-storage-info.nvme-support - Indicates whether non-volatile memory express (NVMe) is supported for instance store (required | supported | unsupported).

    instance-storage-info.total-size-in-gb - The total amount of storage available from all local instance storage, in GB.

    instance-storage-supported - Indicates whether the instance type has local instance storage (true | false).

    instance-type - The instance type (for example c5.2xlarge or c5*).

    memory-info.size-in-mib - The memory size.

    network-info.efa-info.maximum-efa-interfaces - The maximum number of Elastic Fabric Adapters (EFAs) per instance.

    network-info.efa-supported - Indicates whether the instance type supports Elastic Fabric Adapter (EFA) (true | false).

    network-info.ena-support - Indicates whether Elastic Network Adapter (ENA) is supported or required (required | supported | unsupported).

    network-info.encryption-in-transit-supported - Indicates whether the instance type automatically encrypts in-transit traffic between instances (true | false).

    network-info.ipv4-addresses-per-interface - The maximum number of private IPv4 addresses per network interface.

    network-info.ipv6-addresses-per-interface - The maximum number of private IPv6 addresses per network interface.

    network-info.ipv6-supported - Indicates whether the instance type supports IPv6 (true | false).

    network-info.maximum-network-cards - The maximum number of network cards per instance.

    network-info.maximum-network-interfaces - The maximum number of network interfaces per instance.

    network-info.network-performance - The network performance (for example, "25 Gigabit").

    nitro-enclaves-support - Indicates whether Nitro Enclaves is supported (supported | unsupported).

    nitro-tpm-support - Indicates whether NitroTPM is supported (supported | unsupported).

    nitro-tpm-info.supported-versions - The supported NitroTPM version (2.0).

    processor-info.supported-architecture - The CPU architecture (arm64 | i386 | x86_64).

    processor-info.sustained-clock-speed-in-ghz - The CPU clock speed, in GHz.

    processor-info.supported-features - The supported CPU features (amd-sev-snp).

    supported-boot-mode - The boot mode (legacy-bios | uefi).

    supported-root-device-type - The root device type (ebs | instance-store).

    supported-usage-class - The usage class (on-demand | spot).

    supported-virtualization-type - The virtualization type (hvm | paravirtual).

    vcpu-info.default-cores - The default number of cores for the instance type.

    vcpu-info.default-threads-per-core - The default number of threads per core for the instance type.

    vcpu-info.default-vcpus - The default number of vCPUs for the instance type.

    vcpu-info.valid-cores - The number of cores that can be configured for the instance type.

    vcpu-info.valid-threads-per-core - The number of threads per core that can be configured for the instance type. For example, "1" or "1,2".
 */
