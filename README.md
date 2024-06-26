# Server Setup Script

This script sets up a Linux server with Apache, PHP, MariaDB, Node.js, and more. It configures virtual hosts and SSL certificates for a given domain.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Script Details](#script-details)
- [License](#license)

## Prerequisites

- A Linux server running Ubuntu.
- Root or sudo access to the server.
- A registered domain name.

## Usage

1. **Clone the Repository or Download the Script:**

   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

   Or download the `serversetup.sh` script directly.

2. **Make the Script Executable:**

   ```bash
   chmod +x serversetup.sh
   ```

3. **Run the Script:**

   ```bash
   sudo ./serversetup.sh
   ```

4. **Follow the On-Screen Prompts:**

   - Enter your domain name when prompted.

## Script Details

The script performs the following steps:

1. **Update the System:**
   
   Updates the package lists and upgrades all installed packages to their latest versions.

2. **Install Required Packages:**

   Installs necessary packages including Apache, PHP, MariaDB, Node.js, and Certbot for SSL certificates.

3. **Start and Enable Apache:**

   Starts the Apache web server and enables it to start on boot.

4. **Add PHP Repository and Install PHP:**

   Adds the PHP repository and installs PHP 8.1 along with common extensions.

5. **Install and Start MariaDB:**

   Installs the MariaDB server, starts it, and enables it to start on boot.

6. **Install Yarn and Composer:**

   Installs Yarn globally using npm and Composer globally using the installer script.

7. **Restart Apache:**

   Restarts Apache to apply the PHP installation.

8. **Configure Virtual Hosts:**

   Asks for your domain name and configures virtual hosts for your domain and subdomains.

9. **Enable Site and Modules:**

   Enables the new site configuration and the `rewrite` module in Apache, then reloads Apache.

10. **Obtain SSL Certificates:**

    Uses Certbot to obtain SSL certificates for your domain and subdomains.

11. **Set Up Automatic Renewal:**

    Sets up a cron job to renew the SSL certificates automatically.

12. **Modify Apache Configuration:**

    Modifies the Apache configuration to allow `.htaccess` overrides.

## License

This script is open source and available under the [MIT License](LICENSE).

---

Feel free to adjust the repository URL and other details as necessary. This README provides an overview of the script, its prerequisites, usage instructions, and a summary of what the script does.