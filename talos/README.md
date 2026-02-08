`f5b4219136c4be042f25ee55c87d3b45d639e671e58c4c95a227204883e2114b`
```yaml
customization:
    extraKernelArgs:
        - -init_on_alloc
        - -init_on_free
        - -selinux
        - apparmor=0
        - init_on_alloc=0
        - init_on_free=0
        - intel_idle.max_cstate=0
        - intel_iommu=on
        - iommu=pt
        - mitigations=off
        - security=none
        - talos.auditd.disabled=1
        - talos.dashboard.disabled=1
    systemExtensions:
        officialExtensions:
            - siderolabs/i915
            - siderolabs/intel-ucode
            - siderolabs/mei
            - siderolabs/nut-client
            - siderolabs/thunderbolt
            - siderolabs/util-linux-tools
```
