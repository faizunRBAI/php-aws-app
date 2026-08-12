# php-aws-app — Build Notes

## Project
- **Cloud**: AWS us-east-1
- **Target**: EC2 (t3.micro, Ubuntu 22.04)
- **Stack**: PHP 8.2 / Laravel 11, nginx, PHP-FPM, Composer
- **IaC**: Terraform (infra/)
- **Config**: Ansible (ansible/site.yml)
- **VCS**: GitHub (main branch)

## Status
- [x] Environment probed — default VPC present, 6 subnets, quotas OK
- [x] No marketplace blueprint matched — full generation
- [x] Meta approved
- [x] Skills loaded: terraform_aws, ansible, configure_ansible, pipeline_github, nginx, d2_cloud_architecture, readme_writer
- [x] Architecture written (rev 1)
- [x] Pipeline written (rev 1)
- [x] Design approved
- [x] Plan approved (Tier 1)
- [x] Scaffold: php/laravel
- [x] Terraform: versions.tf, variables.tf, main.tf, outputs.tf
- [x] Ansible: ansible/site.yml
- [x] README.md
- [ ] validate_project
- [ ] test_project
- [ ] create_repo_and_push
- [ ] set_pipeline_secret APP_KEY
- [ ] deploy

## Key decisions
- Ubuntu 22.04 (SSH_USER=ubuntu) with Ondrej PHP PPA for PHP 8.2
- Elastic IP for a stable public address across stop/start cycles
- nginx proxies :80 → PHP-FPM socket; app binds internally only
- No database at Tier 1 — Laravel uses file cache/session drivers
- Ansible copies app code via ansible.builtin.copy (not synchronize — avoids ansible.posix dep)
- APP_KEY secret set via set_pipeline_secret after repo push

## Pitfalls applied
- No cache_valid_time on apt (fresh VM image)
- Only ansible.builtin modules used (no community.general)
- IP read from terraform output in each stage (self-sufficient jobs, not threaded via outputs)
- All shell tasks use changed_when: true or creates: guard
