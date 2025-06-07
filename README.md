# Mikrotik - Terraform

![Thumbnail](./docs/img/thumbnail.png)

This repository contains Terraform automation for my entire Mikrotik-powered home network. The purpose of this repository is to provide a structured and repeatable way to manage and automate the setup of my MikroTik devices using Infrastructure as Code (IaC) principles.

## Why Terraform for Network Infrastructure?

Fundamentally speaking, there is nothing that sets this approach apart from, say, a configuration script or just backing up and importing the configuration on the device. Yet, I still decided to use Terraform for this. Why?

1. **I'm weird like that**: As someone who works in DevOps as my main gig, manual configurations (or ClickOps, as we also call it 😉), makes me cringe and I avoid it like the plague. I like defining configuration as code whenever possible since it makes it easy to reproduce and tweak this system.

2. **Skill ~~Issue~~Development**: Working on this project provides a practical, hands-on opportunity to explore advanced Terraform features and patterns. Not to mention that breaking something takes my entire internet away until I fix it, and fixing it without internet may be tricker than you think. This forces me to think more carefully about the configuration before applying.

3. **Because I can**: Not everything in life has to have a good reason. Sometimes reinventing the wheel just to learn or doing things for the heck of it are valid reasons.

## Network Overview
*Diagram coming soon!*

This project provides automated deployment and management for the following devices in my infrastructure:

- **RB5009 router** -> Main router + firewall + CAPSMAN server
- **CRS326 switch** -> Main Rack Switch
- **wAP AX Access Point** -> Provisioned via CAPSMAN

## Project Structure

```bash
├── .github/                     # GitHub workflow configurations and automation
├── modules
│   ├── base                     # Base configuration for all devices
│   └── dhcp-server              # DHCP server configuration
├── .mise.toml                   # tool configuration + dev tasks
├── .sops.yaml                   # SOPS configuration
├── credentials.auto.tfvars.sops # SOPS encrypted tfvars file
├── main.tf                      # Local variables
├── providers.tf                 # Provider configuration 
├── router-*.tf                  # RB5009 router configurations
├── switch-*.tf                  # Switch device configuration
├── terraform.tfstate.sops       # SOPS-encrypted TF state file
└── variables.tf                 # Terraform input variables
```

### Applying Terraform Configuration

1. **Initialize Terraform**: `terraform init`
2. **Decrypt secrets**: `task sops:decrypt`
3. **Plan** (and review) **changes**: `task terraform:plan`
4. **Apply changes**: `terraform apply`
5. **Re-encrypt secrets** (state file, mainly): `task sops:encrypt`

## Limitations

While this project aims to provide comprehensive automation for Mikrotik devices, there are some limitations:

- Initial setup still requires manual configuration before Terraform can be applied
- Complex configurations sometimes require a multi-step approach rather than a single `apply`
- The risk of cutting yourself off of the internet may be low... but it's never zero. Ask me how I know! 😉
- Prepare to get close and intimate with `terraform state mv` if you plan to rename or move objects around. Very few things are stateless, so they can't be deleted and recreated generally.

## Sharing & Risks

By publishing this repository, I accept the risk of exposing aspects of my home network topology. Storing the state and tfvars in git, albeit encrypted, doesn't help much in this regard either! 😅  
While I've taken **some** steps to ensure sensitive information is managed securely, sharing this code inherently comes with certain risks.

All that being said, I ultimately decided to open-source this code and publish it for 2 main reasons:

1. I believe that sharing knowledge is valuable to the community. As I have learned from others, so shall others be able to learn from me. Such is the cycle.
2. I truly believe this was an interesting project. I hope that seeing this will inspire others to attempt similar projects and in turn also share their experiences.

## License
MIT License - Derived from [mirceanton/mikrotik-terraform](https://github.com/mirceanton/mikrotik-terraform).

See [LICENSE](LICENSE) for full terms.

## Inspiration & Credits

This project was originally inspired by [mirceanton/mikrotik-terraform](https://github.com/mirceanton/mikrotik-terraform).  
While I've significantly adapted and extended the codebase for my specific needs, the core idea and initial structure owe credit to the original author.