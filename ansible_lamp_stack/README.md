# Ansible LAMP Stack Deployment

This project automates the deployment of a LAMP (Linux, Apache, MySQL, PHP) stack on Ubuntu servers using Ansible.

## Project Structure

```
ansible_lamp_stack/
├── roles/
│   ├── common/
│   │   └── tasks/
│   │       └── main.yml
│   ├── apache/
│   │   └── tasks/
│   │       └── main.yml
│   └── mysql/
│   │   └── tasks/
│   │       └── main.yml
│   └── php/
│       └── tasks/
│           └── main.yml
├── inventory
└── lamp_stack.yml
```

- `roles/`: Contains Ansible roles for each component of the LAMP stack.
  - `common/`: Tasks for common server setup (e.g., updating cache, installing essential packages).
  - `apache/`: Tasks for installing and configuring Apache web server.
  - `mysql/`: Tasks for installing and configuring MySQL database server.
  - `php/`: Tasks for installing PHP and configuring Apache to use PHP.
- `inventory`: Ansible inventory file defining target hosts and groups.
- `lamp_stack.yml`: Main Ansible playbook that orchestrates the deployment of the LAMP stack using the defined roles.

## Setup Instructions

1.  **Prerequisites:**
    *   Install Ansible on your control machine.
    *   Ensure target servers are accessible via SSH with a user that has sudo privileges.

2.  **Clone the Repository:**
    ```bash
    git clone https://github.com/M0stafaKhaled/route-devops
    cd route-devops/ansible-lamp-stack
    ```

3.  **Configure Inventory:**
    *   Update the `inventory` file with the IP addresses or hostnames of your target servers.
    *   Define groups for different environments (e.g., `dev`, `prod`).

4.  **Run the Playbook:**
    ```bash
    ansible-playbook -i inventory lamp_stack.yml
    ```

## Error Handling and Idempotency

*   **Error Handling:** Tasks are designed to be idempotent, meaning they can be run multiple times without unintended side effects. Error handling is implemented using `block`, `rescue`, and `always` constructs to manage potential failures during playbook execution.
*   **Idempotency:** Most tasks use Ansible modules that are idempotent by nature. For example, `apt` module only installs packages if they are not already present, and `service` module only starts services if they are not already running.

## Notes

*   This playbook assumes a Debian-based Linux distribution (e.g., Ubuntu) on the target servers.
*   Adjust variables and configurations in `vars/main.yml` files within each role as needed.
*   For production environments, consider enhancing security measures such as using Ansible Vault for sensitive data, configuring SSL/TLS for Apache, and setting up regular backups.

